using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AcademiaPortal.App_Code
{
    public class Submission
    {
        public enum SubmissionType
        {
            Journal,
            InternationalConference,
            DomesticConference,
            Review,
            EnglishJournal,
            Other
        }

        public enum PaperType
        {
            LongPaper,
            ShortPaper,
            Abstract,
            other
        }
        public enum PresentationType
        {
            OralPresentation,
            PosterPresentation,
            Demonstration,
            None
        }

        public int Id
        {
            get;
            set;
        }
        public DateTime Date
        {
            get;
            set;
        }
        public string Title
        {
            get;
            set;
        }
        public Author[] Authors
        {
            get;
            set;
        }
        public string Source
        {
            get;
            set;
        }
        public string Volume
        {
            get;
            set;

        }
        public string Page
        {
            get;
            set;
        }
        public SubmissionType Type
        {
            get;
            set;
        }
        public string DOI
        {
            get;
            set;
        }
        public string URL
        {
            get;
            set;
        }
        public int review
        {
            get;
            set;
        }
        public PaperType paper
        {
            get;
            set;
        }
        public PresentationType presentation
        {
            get;
            set;
        }

        public string PdfFile
        {
            get;
            set;
        }
        public string VideoFile
        {
            get;
            set;
        }
        public string PackageFile
        {
            get;
            set;
        }

        public string JapaneseString
        {
            get
            {
                return ToString();
            }
        }
        public override string ToString()
        {
            System.Text.StringBuilder result = new System.Text.StringBuilder();

            //result.Append(Id);

            for (int i = 0; i < Authors.Length; i++)
            {
                if ((Type == SubmissionType.InternationalConference || Type == SubmissionType.EnglishJournal) && Authors.Length > 1)
                {
                    if (i == Authors.Length - 1)
                    {
                        result.Append("and ");
                    }
                    result.Append(Authors[i].EnglishName);
                }
                else
                {
                    result.Append(Authors[i].ChineseName);
                }
                if (i != Authors.Length - 1)
                    result.Append(", ");
            }

            result.Append(", ");
            result.Append(Title);
            result.Append(", ");
            switch (Type)
            {
                case SubmissionType.InternationalConference:
                    // result.Append("In Proceedings of ");
                    result.Append(Source);
                    break;
                default:
                    result.Append(Source);
                    break;
            }

            result.Append(", ");
            result.Append(Volume);
            if (Volume != "")
            {
                result.Append(", ");
            }
            result.Append(Page);
            if (Page != "")
            {
                result.Append(", ");
            }

            if (Type == SubmissionType.InternationalConference || Type == SubmissionType.EnglishJournal)
            {
                result.Append(Date.ToString("MMMMM",
                      System.Globalization.CultureInfo.CreateSpecificCulture("en-US")));
                result.Append(" ");
                result.Append(Date.Year);
            }
            else
            {
                result.Append(Date.Year);
                result.Append("年");
                result.Append(Date.ToString("MMMMM",
                     System.Globalization.CultureInfo.CreateSpecificCulture("ja-JP")));

            }

            result.Append(".");
            return result.ToString();
        }
    }
}