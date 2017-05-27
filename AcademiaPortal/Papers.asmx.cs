using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;

namespace AcademiaPortal
{
    using PaperAuthorship = Dictionary<Int32, List<Int32>>;
    using LinearPaperAuthorship = List<String>;
    /// <summary>
    /// Summary description for Papers
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    [ScriptService]
    public class Papers : System.Web.Services.WebService
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


        [WebMethod]
        public string HelloWorld()
        {
            return "Hello World";
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public List<Models.Paper> GetPapers()
        {
            List<Models.Paper> papers = new List<Models.Paper>();

            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["AcademiaDB"].ConnectionString))
            {
                conn.Open();
                System.Data.SqlClient.SqlCommand retrievePapersCommand = new System.Data.SqlClient.SqlCommand("SELECT * FROM Papers", conn);
                System.Data.SqlClient.SqlDataReader reader = retrievePapersCommand.ExecuteReader();
                while (reader.Read())
                {
                    Models.Paper paper = new Models.Paper(reader);
                    papers.Add(paper);
                }
            }
            return papers;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public LinearPaperAuthorship GetPaperAuthorships()
        {
            LinearPaperAuthorship authorship = new LinearPaperAuthorship();

            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["AcademiaDB"].ConnectionString))
            {
                conn.Open();
                System.Data.SqlClient.SqlCommand retrievePapersCommand = new System.Data.SqlClient.SqlCommand("SELECT * FROM PaperAuthorship", conn);
                System.Data.SqlClient.SqlDataReader reader = retrievePapersCommand.ExecuteReader();
                while (reader.Read())
                {
                    authorship.Add((Int32)reader["PaperID"] + ":" + (Int32)reader["AuthorID"]);
                }
            }
            
            return authorship;
        }

    }
}
