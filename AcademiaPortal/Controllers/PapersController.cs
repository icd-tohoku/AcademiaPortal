using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AcademiaPortal.Controllers
{
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
            Dictionary<Int32, Models.Paper> papersByID = new Dictionary<Int32, Models.Paper>();
            //List<Models.Paper> papers = new List<Models.Paper>();

            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["AcademiaDB"].ConnectionString))
            {
                conn.Open();
                System.Data.SqlClient.SqlCommand retrievePapersCommand = new System.Data.SqlClient.SqlCommand("SELECT * FROM Papers", conn);
                System.Data.SqlClient.SqlDataReader reader = retrievePapersCommand.ExecuteReader();
                while (reader.Read())
                {
                    Models.Paper paper = new Models.Paper(reader);
                    papersByID.Add(paper.paperID, paper);
                }
            }

            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["AcademiaDB"].ConnectionString))
            {
                conn.Open();
                System.Data.SqlClient.SqlCommand retrievePapersCommand = new System.Data.SqlClient.SqlCommand("SELECT * FROM PaperAuthorship", conn);
                System.Data.SqlClient.SqlDataReader reader = retrievePapersCommand.ExecuteReader();
                while (reader.Read())
                {
                    papersByID[(Int32)reader["PaperID"]].authorIDs.Add((Int32)reader["AuthorID"]);
                }
            }

            return papersByID.Select(kvp => kvp.Value);
        }

        // GET: api/Papers/5
        public string Get(int id)
        {
            return "value";
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
