using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AcademiaPortal.App_Code
{
    public static class Database
    {
        static string ConnectionString
        {
            get
            {
                return System.Configuration.ConfigurationManager.ConnectionStrings["AcademiaDB"].ConnectionString;
            }
        }

        public static bool AddAuthor(string firstName, string middleName, string familyName, string chineseFirst, string chineseFamily, string emailAddress, string hiragana)
        {
            if (string.IsNullOrEmpty(firstName) || string.IsNullOrEmpty(familyName))
                return false;
            using (System.Data.SqlClient.SqlConnection sql = new System.Data.SqlClient.SqlConnection(ConnectionString))
            {
                sql.Open();
                string select = string.Format("SELECT * FROM Author WHERE firstname='{0}' AND familyname='{1}'",
                    firstName, familyName);
                var command = sql.CreateCommand();
                command.CommandText = select;
                using (var reader = command.ExecuteReader())
                {
                    if (reader.HasRows)
                    {
                        return false;
                    }
                }
                var index = emailAddress.IndexOf('@');
                emailAddress = emailAddress.Replace("@", "'+char(64)+'");
                command.CommandText = string.Format("INSERT INTO Author(firstname,middlename,familyname,chinesefirst,chinesefamily,email,hiragana) VALUES('{0}','{1}','{2}','{3}','{4}','{5}','{6}')",
                    firstName, middleName, familyName, chineseFirst, chineseFamily, emailAddress, hiragana);
                command.ExecuteNonQuery();
                return true;
            }
        }


        public static Author[] GetAuthors()
        {
            using (System.Data.SqlClient.SqlConnection sql = new System.Data.SqlClient.SqlConnection(ConnectionString))
            {
                sql.Open();
                string select = string.Format("SELECT * FROM Author   ORDER BY CASE WHEN [Order] IS NULL THEN 0 ELSE 1 END DESC, [Order], CASE WHEN [hiragana] IS NULL THEN 0 ELSE 1 END DESC, [hiragana];");
                var command = sql.CreateCommand();
                command.CommandText = select;
                List<Author> authors = new List<Author>();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Author a = new Author();
                        a.FirstName = ((string)reader["firstname"]).Trim();
                        a.MiddleName = ((string)reader["middlename"]).Trim();
                        a.FamilyName = ((string)reader["familyname"]).Trim();
                        a.ChineseFirstName = ((string)reader["chinesefirst"]).Trim();
                        a.ChineseFamilyName = ((string)reader["chinesefamily"]).Trim();
                        a.Id = Convert.ToInt32(reader["authorid"]);
                        a.Email = ((string)reader["email"]).Trim();
                        authors.Add(a);
                    }
                }
                return authors.ToArray();
            }
        }

        public static void UpdateSubmission(Submission sub, string id)
        {
            using (System.Data.SqlClient.SqlConnection sql = new System.Data.SqlClient.SqlConnection(ConnectionString))
            {
                sql.Open();
                var command = sql.CreateCommand();
                string updateQuery = "UPDATE Submission SET";
                updateQuery += " title = '" + sub.Title + "'";
                updateQuery += ", type = '" + (int)sub.Type + "'";
                updateQuery += ", source = '" + sub.Source + "'";
                updateQuery += ", volume = '" + sub.Volume + "'";
                updateQuery += ", pp = '" + sub.Page + "'";
                updateQuery += ", yearmonth = '" + sub.Date.ToString() + "'";
                updateQuery += ", DOI = '" + sub.DOI + "'";
                updateQuery += ", URL = '" + sub.URL + "'";
                updateQuery += ", review = '" + sub.review + "'";
                updateQuery += ", paper = '" + (int)sub.paper + "'";
                updateQuery += ", presentation = '" + (int)sub.presentation + "'";


                for (int i = 0; i < sub.Authors.Length; i++)
                {
                    updateQuery += ", author" + i + "= '" + sub.Authors[i].Id + "'";
                }
                for (int i = sub.Authors.Length; i < 10; i++)
                {
                    updateQuery += ", author" + i + "= NULL";
                }
                updateQuery += " WHERE submissionid = " + id;

                command.CommandText = updateQuery;
                var ModDataID = command.ExecuteNonQuery();

            }
        }

        public static bool DeleteSubmission(string id)
        {

            int check = 0;

            using (System.Data.SqlClient.SqlConnection sql = new System.Data.SqlClient.SqlConnection(ConnectionString))
            {
                sql.Open();
                var command = sql.CreateCommand();
                string updateQuery = "Delete FROM Submission WHERE submissionid = " + id;
                command.CommandText = updateQuery;
                check = command.ExecuteNonQuery();

            }

            if (check == 1)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public static int NewSubmission(Submission sub)
        {
            using (System.Data.SqlClient.SqlConnection sql = new System.Data.SqlClient.SqlConnection(ConnectionString))
            {
                sql.Open();
                string table = "Submission(title,type,source,volume,pp,yearmonth,DOI,URL,review,paper,presentation";
                string value = "VALUES(@title,@type,@source,@volume,@pp,@yearmonth,@DOI,@URL,@review,@paper,@presentation";
                for (int i = 0; i < sub.Authors.Length; i++)
                {
                    table += ",author" + i;
                    value += ",@author" + i;
                }
                table += ")";
                value += ")";
                var command = sql.CreateCommand();
                command.CommandText = "INSERT INTO " + table + " " + value + " \n SELECT @@IDENTITY";
                command.Parameters.AddWithValue("@title", sub.Title);
                command.Parameters.AddWithValue("@type", (int)sub.Type);
                command.Parameters.AddWithValue("@source", sub.Source);
                command.Parameters.AddWithValue("@volume", sub.Volume);
                command.Parameters.AddWithValue("@pp", sub.Page);
                command.Parameters.AddWithValue("@yearmonth", sub.Date.ToString());
                command.Parameters.AddWithValue("@DOI", sub.DOI);
                command.Parameters.AddWithValue("@URL", sub.URL);
                command.Parameters.AddWithValue("@review", sub.review);
                command.Parameters.AddWithValue("@paper", (int)sub.paper);
                command.Parameters.AddWithValue("@presentation", (int)sub.presentation);
                for (int i = 0; i < sub.Authors.Length; i++)
                {
                    command.Parameters.AddWithValue("@author" + i, sub.Authors[i].Id);
                }
                int resultId = (int)(decimal)command.ExecuteScalar();
                return resultId;
            }
        }

        public static void SetFilePath(int id, string pdf, string video, string package)
        {
            if (string.IsNullOrEmpty(pdf) && string.IsNullOrEmpty(video) && string.IsNullOrEmpty(package))
                return;
            using (System.Data.SqlClient.SqlConnection sql = new System.Data.SqlClient.SqlConnection(ConnectionString))
            {
                sql.Open();
                var command = sql.CreateCommand();
                command.CommandText = "UPDATE Submission SET ";
                bool comma = false;
                if (!string.IsNullOrEmpty(pdf))
                {
                    command.CommandText += string.Format("pdffilename='{0}' ", pdf);
                    comma = true;
                }
                if (!string.IsNullOrEmpty(video))
                {
                    if (comma)
                        command.CommandText += ",";
                    command.CommandText += string.Format("videofilename='{0}' ", video);
                    comma = true;
                }
                if (!string.IsNullOrEmpty(package))
                {
                    if (comma)
                        command.CommandText += ",";
                    command.CommandText += string.Format("packagefilename='{0}' ", package);
                }
                command.CommandText += "WHERE submissionid=" + id;
                command.ExecuteNonQuery();
            }
        }

        public static Submission[] ModSubmissions(string id)
        {
            using (System.Data.SqlClient.SqlConnection sql = new System.Data.SqlClient.SqlConnection(ConnectionString))
            {
                sql.Open();
                string select = "SELECT * FROM Submission WHERE submissionid = " + id;


                var command = sql.CreateCommand();
                command.CommandText = select;

                List<Submission> submissions = new List<Submission>();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Submission sub = GetSubmissionFromSqlReader(reader);

                        submissions.Add(sub);
                    }
                }
                return submissions.ToArray();
            }

        }



        public static Submission[] QuerySubmissions(int[] authors, int year, int year2)
        {
            using (System.Data.SqlClient.SqlConnection sql = new System.Data.SqlClient.SqlConnection(ConnectionString))
            {
                sql.Open();
                string select = "SELECT * FROM Submission WHERE (yearmonth BETWEEN ";
                select += string.Format("CAST('{0}-04-01' as datetime) and CAST('{1}-03-31' as datetime))",
                    year, year2 + 1);
                if (authors.Length > 0)
                {
                    string nameQuery = "";
                    for (int i = 0; i < authors.Length; i++)
                    {
                        nameQuery += string.Format("author{0}={1}", i, authors[i]);
                        if (i < authors.Length - 1)
                        {
                            nameQuery += " OR ";
                        }
                    }
                    nameQuery = string.Format(" AND ( {0} )", nameQuery);
                    select += nameQuery;
                }
                select += " ORDER BY yearmonth DESC";

                var command = sql.CreateCommand();
                command.CommandText = select;

                List<Submission> submissions = new List<Submission>();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Submission sub = GetSubmissionFromSqlReader(reader);

                        submissions.Add(sub);
                    }
                }
                return submissions.ToArray();
            }
        }

        //オーバーライドメソッド　著者All検索の場合
        public static Submission[] QuerySubmissions(string Author, int year, int year2)
        {
            if (Author == "All")
            {
                using (System.Data.SqlClient.SqlConnection sql = new System.Data.SqlClient.SqlConnection(ConnectionString))
                {
                    sql.Open();
                    string select = "SELECT * FROM Submission WHERE (yearmonth BETWEEN ";
                    select += string.Format("CAST('{0}-04-01' as datetime) and CAST('{1}-03-31' as datetime))",
                        year, year2 + 1);

                    select += " ORDER BY yearmonth DESC";

                    var command = sql.CreateCommand();
                    command.CommandText = select;

                    List<Submission> submissions = new List<Submission>();
                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Submission sub = GetSubmissionFromSqlReader(reader);

                            submissions.Add(sub);
                        }
                    }
                    return submissions.ToArray();
                }
            }
            else
            {
                List<Submission> submissions = new List<Submission>();
                return submissions.ToArray();
            }

        }



        public static Submission[] TypeQuerySubmissions(int[] authors, int year, int year2, int Type)
        {
            using (System.Data.SqlClient.SqlConnection sql = new System.Data.SqlClient.SqlConnection(ConnectionString))
            {
                sql.Open();
                string select = "SELECT * FROM Submission WHERE (yearmonth BETWEEN ";
                select += string.Format("CAST('{0}-04-01' as datetime) and CAST('{1}-03-31' as datetime))",
                    year, year2 + 1);
                if (authors.Length > 0)
                {
                    string nameQuery = "";
                    for (int i = 0; i < authors.Length; i++)
                    {
                        nameQuery += string.Format("author{0}={1}", i, authors[i]);
                        if (i < authors.Length - 1)
                        {
                            nameQuery += " OR ";
                        }
                    }
                    nameQuery = string.Format(" AND ( {0} )", nameQuery);
                    select += nameQuery;
                }
                select += string.Format(" AND (type = {0}) ", Type);

                select += " ORDER BY yearmonth DESC";

                var command = sql.CreateCommand();
                command.CommandText = select;

                List<Submission> submissions = new List<Submission>();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Submission sub = GetSubmissionFromSqlReader(reader);

                        submissions.Add(sub);
                    }
                }
                return submissions.ToArray();
            }
        }

        //オーバーライドメソッド　著者All検索の場合
        public static Submission[] TypeQuerySubmissions(string Author, int year, int year2, int Type)
        {
            if (Author == "All")
            {
                using (System.Data.SqlClient.SqlConnection sql = new System.Data.SqlClient.SqlConnection(ConnectionString))
                {
                    sql.Open();
                    string select = "SELECT * FROM Submission WHERE (yearmonth BETWEEN ";
                    select += string.Format("CAST('{0}-04-01' as datetime) and CAST('{1}-03-31' as datetime))",
                        year, year2 + 1);

                    select += string.Format(" AND (type = {0}) ", Type);

                    select += " ORDER BY yearmonth DESC";

                    var command = sql.CreateCommand();
                    command.CommandText = select;

                    List<Submission> submissions = new List<Submission>();
                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Submission sub = GetSubmissionFromSqlReader(reader);

                            submissions.Add(sub);
                        }
                    }
                    return submissions.ToArray();
                }
            }
            else
            {
                List<Submission> submissions = new List<Submission>();
                return submissions.ToArray();
            }
        }

        private static Submission GetSubmissionFromSqlReader(System.Data.SqlClient.SqlDataReader reader)
        {
            Submission sub = new Submission();
            sub.Id = ((int)reader["submissionid"]);
            sub.Title = ((string)reader["title"]).Trim();
            sub.Type = (Submission.SubmissionType)(Convert.ToInt32(reader["type"]));
            sub.Volume = ((string)reader["volume"]).Trim();
            sub.Page = ((string)reader["pp"]).Trim();
            sub.Date = Convert.ToDateTime(reader["yearmonth"]);
            sub.URL = (string)(reader["URL"]);
            sub.review = Convert.ToInt32(reader["review"]);
            sub.DOI = (string)(reader["DOI"]);
            sub.paper = (Submission.PaperType)Convert.ToInt32(reader["paper"]);
            sub.presentation = (Submission.PresentationType)Convert.ToInt32(reader["presentation"]);
            sub.Source = Convert.ToString(reader["source"]).Trim();
            sub.PdfFile = Convert.ToString(reader["pdffilename"]).Trim();
            sub.VideoFile = Convert.ToString(reader["videofilename"]).Trim();
            sub.PackageFile = Convert.ToString(reader["packagefilename"]).Trim();
            List<Author> authorList = new List<Author>();
            for (int i = 0; i < 10; i++)
            {
                if (!(reader["author" + i] is DBNull))
                {
                    authorList.Add(Author.authorDictionary[Convert.ToInt32(reader["author" + i])]);
                }
            }

            sub.Authors = authorList.ToArray();
            return sub;
        }

        public static ErrorType DataCheck(Submission sub)
        {
            ErrorType checkResult = ErrorType.noError;

            if (sub.Authors.Count() == 0 || sub.Title == "" || sub.Source == "")
            {
                checkResult = ErrorType.lackItem;
            }


            if (sub.Title.Length >= 256 || sub.Volume.Length >= 100 || sub.Source.Length > 256 || sub.Page.Length >= 24 || sub.DOI.Length >= 40 || sub.URL.Length >= 500)
            {
                checkResult = ErrorType.dataIncorrect;
            }


            return checkResult;



        }

        public enum ErrorType
        {
            dataIncorrect,
            lackItem,
            noError
        }
    }
}