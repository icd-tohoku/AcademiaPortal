using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AcademiaPortal.Controllers
{
    public class AuthorsController : ApiController
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
                        "(" + String.Join(",", authorColumnLabels) + ");" +
                        "SELECT CAST(scope_identity() AS int)";
        static String updateAuthorSQLTemplate = "UPDATE Authors SET " +
            String.Join(", ", authorColumns.Select(column => column + " = @" + column)) + " " +
            "WHERE " + authorPrimaryKeyColumn + " = @" + authorPrimaryKeyColumn + ";";

        // GET api/<controller>
        public IEnumerable<Models.Author> Get()
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

        // POST api/<controller>
        public IHttpActionResult Post([FromBody]Models.Author author)
        {
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
            return Ok(author);
        }

        // PUT api/<controller>/5
        public IHttpActionResult Put(int id, [FromBody]Models.Author author)
        {
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
                    updateAuthorCommand.Parameters.AddWithValue(authorPrimaryKeyColumn, id);

                    updateAuthorCommand.ExecuteNonQuery();
                }
            }
            return Ok(author);
        }
    }
}
