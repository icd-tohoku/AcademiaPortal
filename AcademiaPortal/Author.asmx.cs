using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;

namespace AcademiaPortal
{
    /// <summary>
    /// Summary description for Author
    /// </summary>
    [WebService]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    [ScriptService]
    public class Author : System.Web.Services.WebService
    {
        static String authorPrimaryKeyColumn = "AuthorID";
        static String[] authorColumns = {
                "FirstName_En",
                "MiddleName_En",
                "FamilyName_En",
                "FirstName_Ja",
                "FamilyName_Ja",
                "Hiragana",
                "Email",
                "Precedence"
            };
        static String[] authorColumnLabels = authorColumns.Select(column => "@" + column).ToArray();
        static String insertAuthorSQLTemplate = "INSERT INTO Authors " +
                        "(" + String.Join(",", authorColumns) + ")" +
                        "VALUES " +
                        "(" + String.Join(",", authorColumnLabels) + ");"+
                        "SELECT CAST(scope_identity() AS int)";
        static String updateAuthorSQLTemplate = "UPDATE Authors SET " +
            String.Join(", ", authorColumns.Select(column => column + " = @" + column)) + " " +
            "WHERE "+ authorPrimaryKeyColumn+" = @"+ authorPrimaryKeyColumn+";";

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public string HelloWorld()
        {
            return "Hello World";
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public List<Models.Author> GetAuthors()
        {
            List<Models.Author> authors = new List<Models.Author>();

            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["AcademiaDB"].ConnectionString))
            {
                conn.Open();
                System.Data.SqlClient.SqlCommand retrieveAuthorsCommand = new System.Data.SqlClient.SqlCommand("SELECT * FROM Authors", conn);
                System.Data.SqlClient.SqlDataReader reader = retrieveAuthorsCommand.ExecuteReader();
                while (reader.Read())
                {
                    Models.Author author = new Models.Author(reader);
                    authors.Add(author);
                }
            }
            return authors;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public Models.Author AddAuthor(Models.Author author)
        {
            //HttpContext.Current.Request
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["AcademiaDB"].ConnectionString))
            {
                conn.Open();

                using (System.Data.SqlClient.SqlCommand insertAuthorCommand = new System.Data.SqlClient.SqlCommand(insertAuthorSQLTemplate, conn))
                {

                    insertAuthorCommand.Parameters.AddWithValue(authorColumns[0], author.firstName_En);
                    insertAuthorCommand.Parameters.AddWithValue(authorColumns[1], author.middleName_En);
                    insertAuthorCommand.Parameters.AddWithValue(authorColumns[2], author.familyName_En);
                    insertAuthorCommand.Parameters.AddWithValue(authorColumns[3], author.firstName_Ja);
                    insertAuthorCommand.Parameters.AddWithValue(authorColumns[4], author.familyName_Ja);
                    insertAuthorCommand.Parameters.AddWithValue(authorColumns[5], author.hiragana);
                    insertAuthorCommand.Parameters.AddWithValue(authorColumns[6], author.email);
                    insertAuthorCommand.Parameters.AddWithValue(authorColumns[7], author.precedence);
                    author.authorID = (int)insertAuthorCommand.ExecuteScalar();
                }
            }
            return author;
        }


        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public Models.Author UpdateAuthor(Models.Author author)
        {
            //HttpContext.Current.Request
            using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["AcademiaDB"].ConnectionString))
            {
                conn.Open();

                using (System.Data.SqlClient.SqlCommand updateAuthorCommand = new System.Data.SqlClient.SqlCommand(updateAuthorSQLTemplate, conn))
                {
                    updateAuthorCommand.Parameters.AddWithValue(authorColumns[0], author.firstName_En);
                    updateAuthorCommand.Parameters.AddWithValue(authorColumns[1], author.middleName_En);
                    updateAuthorCommand.Parameters.AddWithValue(authorColumns[2], author.familyName_En);
                    updateAuthorCommand.Parameters.AddWithValue(authorColumns[3], author.firstName_Ja);
                    updateAuthorCommand.Parameters.AddWithValue(authorColumns[4], author.familyName_Ja);
                    updateAuthorCommand.Parameters.AddWithValue(authorColumns[5], author.hiragana);
                    updateAuthorCommand.Parameters.AddWithValue(authorColumns[6], author.email);
                    updateAuthorCommand.Parameters.AddWithValue(authorColumns[7], author.precedence);
                    updateAuthorCommand.Parameters.AddWithValue(authorPrimaryKeyColumn, author.authorID);
                    
                    updateAuthorCommand.ExecuteNonQuery();
                }
            }
            return author;
        }
    }
}
