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
        public Boolean authorConjunctiveMatch;

        public DateTime? publishDateFrom;
        public DateTime? publishDateTo;

        public Boolean? hasEnterprisePartnership;
        public Boolean? hasInternationalCoAuthor;
        public Boolean? isCollaborativeProject;
        public Boolean? peerReviewed;

        public Int32? genre;
        public Int32? publicationCategory;
        public Int32? presentationStyle;

        public PapersSearchCriteria(IEnumerable<KeyValuePair<String, String>> queryParams)
        {
            authorIDs = new List<int>();
            firstAuthorOnly = false;
            authorConjunctiveMatch = false;
            foreach (var queryParam in queryParams)
            {
                String key = queryParam.Key;
                String value = queryParam.Value;
                Int32 parsedInt32;
                Int64 parsedInt64;
                Boolean parsedBoolean;

                switch (key)
                {
                    case "authorIDs":
                        if (Int32.TryParse(value, out parsedInt32))
                        {
                            authorIDs.Add(parsedInt32);
                        }
                        break;
                    case "firstAuthorOnly":
                        if (Boolean.TryParse(value, out parsedBoolean))
                        {
                            firstAuthorOnly = parsedBoolean;
                        }
                        break;
                    case "authorConjunctiveMatch":
                        if (Boolean.TryParse(value, out parsedBoolean))
                        {
                            authorConjunctiveMatch = parsedBoolean;
                        }
                        break;
                    case "publishDateFrom":
                        if (Int64.TryParse(value, out parsedInt64))
                        {
                            publishDateFrom = Models.Paper.GetDateTime(parsedInt64);
                        }
                        break;
                    case "publishDateTo":
                        if (Int64.TryParse(value, out parsedInt64))
                        {
                            publishDateTo = Models.Paper.GetDateTime(parsedInt64);
                        }
                        break;
                    case "hasEnterprisePartnership":
                        if (Boolean.TryParse(value, out parsedBoolean))
                        {
                            hasEnterprisePartnership = parsedBoolean;
                        }
                        break;
                    case "hasInternationalCoAuthor":
                        if (Boolean.TryParse(value, out parsedBoolean))
                        {
                            hasInternationalCoAuthor = parsedBoolean;
                        }
                        break;
                    case "isCollaborativeProject":
                        if (Boolean.TryParse(value, out parsedBoolean))
                        {
                            isCollaborativeProject = parsedBoolean;
                        }
                        break;
                    case "peerReviewed":
                        if (Boolean.TryParse(value, out parsedBoolean))
                        {
                            peerReviewed = parsedBoolean;
                        }
                        break;
                    case "genre":
                        if (Int32.TryParse(value, out parsedInt32))
                        {
                            genre = parsedInt32;
                        }
                        break;
                    case "publicationCategory":
                        if (Int32.TryParse(value, out parsedInt32))
                        {
                            publicationCategory = parsedInt32;
                        }
                        break;
                    case "presentationStyle":
                        if (Int32.TryParse(value, out parsedInt32))
                        {
                            presentationStyle = parsedInt32;
                        }
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
                filteringConjunctiveConditions.Add("Papers.HasEnterprisePartnership = " + ((bool)hasEnterprisePartnership ? 1 : 0));
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
            if (genre != null)
            {
                filteringConjunctiveConditions.Add("Papers.Genre = " + genre);
            }
            if (publicationCategory != null)
            {
                filteringConjunctiveConditions.Add("Papers.PublicationCategory = " + publicationCategory);
            }
            if (presentationStyle != null)
            {
                filteringConjunctiveConditions.Add("Papers.PresentationStyle = " + presentationStyle);
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
            String sqlTemplate = "DELETE FROM PaperAuthorship WHERE " +
                paperAuthorshipColumns[0] + " = @" + paperAuthorshipColumns[0] + "; " +
                "INSERT INTO PaperAuthorship" +
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
            var papers = papersByID.Select(kvp => kvp.Value);
            if (criteria.authorConjunctiveMatch)
            {
                papers = papers.Where(paper => criteria.authorIDs.Except(paper.authorIDs).Count() == 0);
            }
            return papers;
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
            updatePaperAuthorship(paper.paperID, paper.authorIDs);

            return Ok(paper);
        }

        // PUT api/Papers/5
        public IHttpActionResult Put(int id, [FromBody]Models.Paper paper)
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["AcademiaDB"].ConnectionString))
            {
                conn.Open();

                using (System.Data.SqlClient.SqlCommand updatePaperCommand = new System.Data.SqlClient.SqlCommand(updatePaperSQLTemplate, conn))
                {

                    updatePaperCommand.Parameters.AddWithValue(paperColumns[0], paper.title);
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[1], paper.publicationCategory);
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[2], paper.publication);
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[3], paper.volume);
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[4], paper.page);
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[5], paper.GetPublishDate());
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[6], paper.digitalObjectID);
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[7], paper.documentURL);
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[8], paper.peerReviewed);
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[9], paper.genre);
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[10], paper.presentationStyle);
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[11], paper.documentFilePath);
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[12], paper.videoFilePath);
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[13], paper.packageFilePath);
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[14], paper.hasEnterprisePartnership);
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[15], paper.hasInternationalCoAuthor);
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[16], paper.isCollaborativeProject);
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[17], paper.acknowledgment);
                    updatePaperCommand.Parameters.AddWithValue(paperColumns[18], paper.publicationConfirmationFilePath);
                    updatePaperCommand.Parameters.AddWithValue(paperPrimaryKeyColumn, id);

                    updatePaperCommand.ExecuteNonQuery();
                }
            }
            updatePaperAuthorship(id, paper.authorIDs);
            return Ok(paper);
        }

        protected int updatePaperAuthorship(int id, List<int> authorIDs)
        {
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["AcademiaDB"].ConnectionString))
            {
                conn.Open();
                String insertPaperAuthorshipSQLTemplate = GetInsertPaperAuthorshipSQLTemplate(authorIDs.Count);
                using (System.Data.SqlClient.SqlCommand insertPaperAuthorshipCommand = new System.Data.SqlClient.SqlCommand(insertPaperAuthorshipSQLTemplate, conn))
                {
                    insertPaperAuthorshipCommand.Parameters.AddWithValue(paperAuthorshipColumns[0], id);
                    for (int i = 0; i < authorIDs.Count; i++)
                    {
                        Int32 authorID = authorIDs.ElementAt(i);
                        insertPaperAuthorshipCommand.Parameters.AddWithValue(paperAuthorshipColumns[1] + i, authorID);
                    }
                    return insertPaperAuthorshipCommand.ExecuteNonQuery();
                }
            }
        }

        // DELETE: api/Papers/5
        public void Delete(int id)
        {
        }
    }
}
