using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AcademiaPortal.Controllers
{
    public class PapersSearchCriteria
    {
        public List<int> authorIDs;
        public Boolean firstAuthorOnly;
        public Boolean authorsMatchAny;

        public DateTime? publishDateFrom;
        public DateTime? publishDateTo;

        public Boolean? hasEnterprisePartnership;
        public Boolean? hasInternationalCoAuthor;
        public Boolean? isCollaborativeProject;
        public Boolean? peerReviewed;

        public PapersSearchCriteria(IEnumerable<KeyValuePair<String, String>> queryParams)
        {
            authorIDs = new List<int>();
            foreach (var queryParam in queryParams)
            {
                String key = queryParam.Key;
                String value = queryParam.Value;
                switch (key)
                {
                    case "authorIDs":
                        authorIDs.Add(Int32.Parse(value));
                        break;
                    case "firstAuthorOnly":
                        firstAuthorOnly = Boolean.Parse(value);
                        break;
                    case "authorsMatchAny":
                        authorsMatchAny = Boolean.Parse(value);
                        break;
                    case "publishDateFrom":
                        publishDateFrom = Models.Paper.GetDateTime(Int64.Parse(value));
                        break;
                    case "publishDateTo":
                        publishDateTo = Models.Paper.GetDateTime(Int64.Parse(value));
                        break;
                    case "hasEnterprisePartnership":
                        hasEnterprisePartnership = Boolean.Parse(value);
                        break;
                    case "hasInternationalCoAuthor":
                        hasInternationalCoAuthor = Boolean.Parse(value);
                        break;
                    case "isCollaborativeProject":
                        isCollaborativeProject = Boolean.Parse(value);
                        break;
                    case "peerReviewed":
                        peerReviewed = Boolean.Parse(value);
                        break;
                    default:
                        break;

                }

            }
        }

        public String getSQLTemplate()
        {
            String paperFilteringSQLTemplate =
                "SELECT DISTINCT Papers.PaperID " +
                "FROM Papers ";

            List<String> filteringConjunctiveConditions = new List<String>();
            if (authorIDs.Count > 0)
            {
                paperFilteringSQLTemplate += "INNER JOIN PaperAuthorship ON PaperAuthorship.PaperID = Papers.PaperID ";
                List<String> authorshipDisjuctiveConditions = new List<String>();
                for (int i = 0; i < authorIDs.Count; i++)
                {
                    String condition = "(PaperAuthorship.AuthorID = " + "@AuthorID" + i;
                    if (firstAuthorOnly)
                    {
                        condition += " AND PaperAuthorship.Precedence = 0";
                    }
                    condition += ")";
                    authorshipDisjuctiveConditions.Add(condition);
                }
                filteringConjunctiveConditions.Add(String.Join(" OR ", authorshipDisjuctiveConditions));
            }
            if (publishDateFrom != null)
            {
                filteringConjunctiveConditions.Add("Papers.PublishDate >= " + "@PublishDateFrom");
            }
            if (publishDateTo != null)
            {
                filteringConjunctiveConditions.Add("Papers.PublishDate < " + "@PublishDateTo");
            }
            if (hasEnterprisePartnership != null)
            {
                filteringConjunctiveConditions.Add("Papers.HasEnterprisePartnership = " + ((bool)hasInternationalCoAuthor ? 1 : 0));
            }
            if (isCollaborativeProject != null)
            {
                filteringConjunctiveConditions.Add("Papers.IsCollaborativeProject = " + ((bool)isCollaborativeProject ? 1 : 0));
            }
            if (hasInternationalCoAuthor != null)
            {
                filteringConjunctiveConditions.Add("Papers.HasInternationalCoAuthor = " + ((bool)hasInternationalCoAuthor ? 1 : 0));
            }
            if (peerReviewed != null)
            {
                filteringConjunctiveConditions.Add("Papers.PeerReviewed = " + ((bool)peerReviewed ? 1 : 0));
            }

            if (filteringConjunctiveConditions.Count > 0)
            {
                paperFilteringSQLTemplate += "WHERE ";
                paperFilteringSQLTemplate += String.Join(" AND ", filteringConjunctiveConditions.Select(line => "(" + line + ")"));
            }

            String selectSQLTemplate =
                "SELECT Papers.*, PaperAuthorship.AuthorID " +
                "FROM Papers " +
                "INNER JOIN PaperAuthorship ON PaperAuthorship.PaperID = Papers.PaperID " +
                "WHERE Papers.PaperID IN(" + paperFilteringSQLTemplate + ") " +
                "ORDER BY Papers.PaperID ASC, PaperAuthorship.Precedence ASC";

            return selectSQLTemplate;
        }

        public void AddParameters(System.Data.SqlClient.SqlCommand command)
        {

            for (int i = 0; i < authorIDs.Count; i++)
            {
                command.Parameters.AddWithValue("AuthorID" + i, authorIDs.ElementAt(i));
            }
            if (publishDateFrom != null)
            {
                command.Parameters.AddWithValue("PublishDateFrom", publishDateFrom);

            }
            if (publishDateTo != null)
            {
                command.Parameters.AddWithValue("PublishDateTo", publishDateTo);
            }
        }
    }

    public class PapersController : ApiController
    {
        static String paperPrimaryKeyColumn = "PaperID";
        static String[] paperColumns =
        {
            "Title",
            "PublicationCategory",
            "Publication",
            "Volume",
            "Page",
            "PublishDate",
            "DigitalObjectID",
            "DocumentURL",
            "PeerReviewed",
            "Genre",
            "PresentationStyle",
            "DocumentFilePath",
            "VideoFilePath",
            "PackageFilePath",
            "HasEnterprisePartnership",
            "HasInternationalCoAuthor",
            "IsCollaborativeProject",
            "Acknowledgment",
            "PublicationConfirmationFilePath"
        };
        static String[] paperColumnLabels = paperColumns.Select(column => "@" + column).ToArray();

        static String insertPaperSQLTemplate = "INSERT INTO Papers " +
                        "(" + String.Join(",", paperColumns) + ")" +
                        "VALUES " +
                        "(" + String.Join(",", paperColumnLabels) + ");" +
                        "SELECT CAST(scope_identity() AS int)";
        static String updatePaperSQLTemplate = "UPDATE Papers SET " +
            String.Join(", ", paperColumns.Select(column => column + " = @" + column)) + " " +
            "WHERE " + paperPrimaryKeyColumn + " = @" + paperPrimaryKeyColumn + ";";

        static String[] paperAuthorshipColumns =
        {
            "PaperID",
            "AuthorID",
            "Precedence"
        };

        public static String GetInsertPaperAuthorshipSQLTemplate(int author_count)
        {
            String sqlTemplate = "INSERT INTO PaperAuthorship" +
                "(" + String.Join(",", paperAuthorshipColumns) + ")" +
                                        "VALUES ";
            List<String> rowTemplates = new List<String>();
            for (int i = 0; i < author_count; i++)

            {
                rowTemplates.Add("(@" + paperAuthorshipColumns[0] + ", @" + paperAuthorshipColumns[1] + i + "," + i + ")");
            }

            return sqlTemplate + String.Join(",", rowTemplates.ToArray()) + ";";
        }

        // GET: api/Papers
        public IEnumerable<Models.Paper> Get()
        {
            PapersSearchCriteria criteria = new PapersSearchCriteria(Request.GetQueryNameValuePairs());

            Dictionary<Int32, Models.Paper> papersByID = new Dictionary<Int32, Models.Paper>();

            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["AcademiaDB"].ConnectionString))
            {
                conn.Open();
                System.Data.SqlClient.SqlCommand retrievePapersCommand = new System.Data.SqlClient.SqlCommand(criteria.getSQLTemplate(), conn);
                criteria.AddParameters(retrievePapersCommand);
                System.Data.SqlClient.SqlDataReader reader = retrievePapersCommand.ExecuteReader();
                while (reader.Read())
                {
                    Models.Paper paper = new Models.Paper(reader);
                    if (papersByID.ContainsKey(paper.paperID))
                    {
                        papersByID[paper.paperID].CombineAuthorship(paper);
                    }
                    else
                    {
                        papersByID.Add(paper.paperID, paper);
                    }
                }
            }
            return papersByID.Select(kvp => kvp.Value);
        }

        // POST: api/Papers
        public IHttpActionResult Post([FromBody]Models.Paper paper)
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["AcademiaDB"].ConnectionString))
            {
                conn.Open();

                using (System.Data.SqlClient.SqlCommand insertPaperCommand = new System.Data.SqlClient.SqlCommand(insertPaperSQLTemplate, conn))
                {
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[0], paper.title);
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[1], paper.publicationCategory);
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[2], paper.publication);
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[3], paper.volume);
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[4], paper.page);
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[5], paper.GetPublishDate());
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[6], paper.digitalObjectID);
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[7], paper.documentURL);
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[8], paper.peerReviewed);
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[9], paper.genre);
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[10], paper.presentationStyle);
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[11], paper.documentFilePath);
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[12], paper.videoFilePath);
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[13], paper.packageFilePath);
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[14], paper.hasEnterprisePartnership);
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[15], paper.hasInternationalCoAuthor);
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[16], paper.isCollaborativeProject);
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[17], paper.acknowledgment);
                    insertPaperCommand.Parameters.AddWithValue(paperColumns[18], paper.publicationConfirmationFilePath);

                    paper.paperID = (int)insertPaperCommand.ExecuteScalar();
                }
            }
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["AcademiaDB"].ConnectionString))
            {
                conn.Open();
                String insertPaperAuthorshipSQLTemplate = GetInsertPaperAuthorshipSQLTemplate(paper.authorIDs.Count);
                using (System.Data.SqlClient.SqlCommand insertPaperAuthorshipCommand = new System.Data.SqlClient.SqlCommand(insertPaperAuthorshipSQLTemplate, conn))
                {
                    insertPaperAuthorshipCommand.Parameters.AddWithValue(paperAuthorshipColumns[0], paper.paperID);
                    for (int i = 0; i < paper.authorIDs.Count; i++)
                    {
                        Int32 authorID = paper.authorIDs.ElementAt(i);
                        insertPaperAuthorshipCommand.Parameters.AddWithValue(paperAuthorshipColumns[1] + i, authorID);
                    }
                    insertPaperAuthorshipCommand.ExecuteNonQuery();
                }
            }
            return Ok(paper);
        }

        // PUT: api/Papers/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE: api/Papers/5
        public void Delete(int id)
        {
        }
    }
}
