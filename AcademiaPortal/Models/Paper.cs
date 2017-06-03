using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AcademiaPortal.Models
{
    public class Paper
    {
        public int paperID;
        public String title;
        public Int32 publicationCategory;
        public String publication;
        public String volume;
        public String page;
        // UTC(GMT) is used
        private DateTime _publishDate;
        public String digitalObjectID;
        public String documentURL;
        public Boolean peerReviewed;
        public Int32 genre;
        public Int32 presentationStyle;
        private Object _documentFilePath;
        private Object _videoFilePath;
        private Object _packageFilePath;
        public Boolean hasEnterprisePartnership;
        public Boolean hasInternationalCoAuthor;
        public Boolean isCollaborativeProject;
        public String acknowledgment;
        private Object _publicationConfirmationFilePath;
        public List<Int32> authorIDs;

        public static Int64 GetEpoch(DateTime t)
        {
            return (Int64)t.Subtract(new DateTime(1970, 1, 1)).TotalMilliseconds;
        }
        public static DateTime GetDateTime(Int64 epoch)
        {
            DateTime t = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
            t = t.AddMilliseconds(epoch);
            return t;
        }
        public Int64 publishDate
        {
            get
            {
                return GetEpoch(this._publishDate);
            }
            set
            {
                this._publishDate = GetDateTime(value);
            }
        }
        public DateTime GetPublishDate()
        {
            return _publishDate;
        }
        public Object documentFilePath
        {
            get
            {
                return this._documentFilePath;
            }
            set
            {
                if (value == null)
                {
                    this._documentFilePath = DBNull.Value;
                }
                else
                {
                    this._documentFilePath = value;
                }
            }
        }

        public Object videoFilePath
        {
            get
            {
                return this._videoFilePath;
            }
            set
            {
                if (value == null)
                {
                    this._videoFilePath = DBNull.Value;
                }
                else
                {
                    this._videoFilePath = value;
                }
            }
        }
        public Object packageFilePath
        {
            get
            {
                return this._packageFilePath;
            }
            set
            {
                if (value == null)
                {
                    this._packageFilePath = DBNull.Value;
                }
                else
                {
                    this._packageFilePath = value;
                }
            }
        }
        public Object publicationConfirmationFilePath
        {
            get
            {
                return this._publicationConfirmationFilePath;
            }
            set
            {
                if (value == null)
                {
                    this._publicationConfirmationFilePath = DBNull.Value;
                }
                else
                {
                    this._publicationConfirmationFilePath = value;
                }
            }
        }


        public Paper()
        {
            paperID = -1;
            title = "";
            publicationCategory = 0;
            publication = "";
            volume = "";
            page = "";
            publishDate = 0;
            digitalObjectID = "";
            documentURL = "";
            peerReviewed = false;
            genre = 0;
            presentationStyle = 0;
            documentFilePath = DBNull.Value;
            videoFilePath = DBNull.Value;
            packageFilePath = DBNull.Value;
            hasEnterprisePartnership = false;
            hasInternationalCoAuthor = false;
            isCollaborativeProject = false;
            acknowledgment = "";
            publicationConfirmationFilePath = DBNull.Value;
            authorIDs = new List<Int32>();
        }
        public Paper(System.Data.SqlClient.SqlDataReader reader)
        {
            paperID = (int)reader["PaperID"];
            title = (String)reader["Title"];
            publicationCategory = (Int32)reader["PublicationCategory"];
            publication = (String)reader["Publication"];
            volume = (String)reader["Volume"];
            page = (String)reader["Page"];
            publishDate = GetEpoch((DateTime)reader["PublishDate"]);
            digitalObjectID = (String)reader["DigitalObjectID"];
            documentURL = (String)reader["DocumentURL"];
            peerReviewed = (Boolean)reader["PeerReviewed"];
            genre = (Int32)reader["Genre"];
            presentationStyle = (Int32)reader["PresentationStyle"];
            documentFilePath = reader["DocumentFilePath"];
            videoFilePath = reader["VideoFilePath"];
            packageFilePath = reader["PackageFilePath"];
            hasEnterprisePartnership = (Boolean)reader["HasEnterprisePartnership"];
            hasInternationalCoAuthor = (Boolean)reader["HasInternationalCoAuthor"];
            isCollaborativeProject = (Boolean)reader["IsCollaborativeProject"];
            acknowledgment = (String)reader["Acknowledgment"];
            publicationConfirmationFilePath = reader["PublicationConfirmationFilePath"];
            authorIDs = new List<Int32>();
        }
    }
}