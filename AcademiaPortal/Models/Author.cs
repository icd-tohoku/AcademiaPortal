using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AcademiaPortal.Models
{
    public class Author
    {
        public int authorID;
        public String firstName_En;
        public String middleName_En;
        public String familyName_En;
        public String firstName_Ja;
        public String familyName_Ja;
        public String hiragana;
        public String email;
        public Object precedence;

        public Author()
        {
            authorID = -1;
            firstName_En = "";
            middleName_En = "";
            familyName_En = "";
            firstName_Ja = "";
            familyName_Ja = "";
            hiragana = "";
            email = "";
            precedence = DBNull.Value;
        }
        public Author(System.Data.SqlClient.SqlDataReader reader)
        {
            authorID = (int)reader["AuthorID"];
            firstName_En = (String)reader["FirstName_En"];
            middleName_En = (String)reader["MiddleName_En"];
            familyName_En = (String)reader["FamilyName_En"];
            firstName_Ja = (String)reader["FirstName_Ja"];
            familyName_Ja = (String)reader["FamilyName_Ja"];
            hiragana = (String)reader["Hiragana"];
            email = (String)reader["Email"];
            precedence = reader["Precedence"];
        }
    }
}