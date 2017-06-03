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
        public void Post([FromBody]string value)
        {
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
