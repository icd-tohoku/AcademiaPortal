using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AcademiaPortal.App_Code
{
    public class Author
    {
        public int Id
        {
            get;
            set;
        }
        public string FirstName
        {
            get;
            set;
        }
        public string MiddleName
        {
            get;
            set;
        }
        public string FamilyName
        {
            get;
            set;
        }
        public string ChineseFirstName
        {
            get;
            set;
        }
        public string ChineseFamilyName
        {
            get;
            set;
        }
        public string Email
        {
            get;
            set;
        }
        public override string ToString()
        {
            switch (System.Globalization.CultureInfo.InstalledUICulture.TwoLetterISOLanguageName)
            {
                case "zh":
                case "ja":
                    return ChineseName;
                default:
                    return EnglishName;
            }
        }
        public string ChineseName
        {
            get
            {
                System.Text.RegularExpressions.Regex re = new System.Text.RegularExpressions.Regex("^[ァ-ー]+$");
                if (re.IsMatch(ChineseFirstName))
                    return ChineseFirstName + " " + ChineseFamilyName;
                return string.IsNullOrEmpty(ChineseFamilyName) ? EnglishName : ChineseFamilyName + " " + ChineseFirstName;
            }
        }
        public string EnglishName
        {
            get
            {
                if (MiddleName != "")
                {
                    return FirstName + " " + MiddleName + " " + FamilyName;
                }
                else
                {
                    return FirstName + " " + FamilyName;
                }
            }
        }
        public static Dictionary<int, Author> authorDictionary = new Dictionary<int, Author>();
        public static Dictionary<string, Author> authorByNames = new Dictionary<string, Author>();
    }
}