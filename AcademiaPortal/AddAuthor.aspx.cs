using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace AcademiaPortal
{
    public partial class AddAuthor : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            TableRow row = new TableRow();
            TableCell cell = new TableCell();

            foreach (var author in App_Code.Database.GetAuthors())
            {

                //AuthorList.Items.Add(author.ToString());

                if (author != null)
                {

                    row = new TableRow();

                    cell = new TableCell();
                    cell.CssClass = "mdl-data-table__cell--non-numeric";
                    cell.Text = author.ChineseFamilyName.ToString() + " " + author.ChineseFirstName.ToString();
                    row.Cells.Add(cell);

                    //cell = new TableCell();
                    //cell.Text = author.ChineseFirstName.ToString();
                    //row.Cells.Add(cell);



                    cell = new TableCell();
                    cell.Text = author.FirstName.ToString();
                    cell.CssClass = "mdl-data-table__cell--non-numeric";
                    if (author.MiddleName != "")
                    {
                        cell.Text += " " + author.MiddleName.ToString();
                        row.Cells.Add(cell);
                    }

                    cell.Text += " " + author.FamilyName.ToString();
                    row.Cells.Add(cell);

                    row.CssClass = "mdl-data-table__cell--non-numeric";

                    authorTable.Rows.Add(row);
                }
            }
        }
        protected void authorRegisterButton_Click(object sender, EventArgs e)
        {
            string family_ja = family_ja_input.Text;
            string first_ja = first_ja_input.Text;
            string hiragana_ja = hiragana_ja_input.Text;
            string family_en = family_en_input.Text;
            string middle_en = middle_en_input.Text;
            string first_en = first_en_input.Text;
            string mail = "";

            if (family_ja == "" || first_ja == "" || hiragana_ja == "" || family_en == "" || first_en == "")
            {
                // TODO: feedback
                return;
            }

            if (App_Code.Database.AddAuthor(first_en, middle_en, family_en, first_ja, family_ja, mail, hiragana_ja))
            {
                // TODO: 追加できたらページ更新
                Response.Redirect(Request.Url.OriginalString);

                // TODO: 追加し旨を伝えるメッセージを表示予定

                // clear form only when insertion is successful
                family_ja_input.Text = "";
                first_ja_input.Text = "";
                hiragana_ja_input.Text = "";
                family_en_input.Text = "";
                middle_en_input.Text = "";
                first_en_input.Text = "";
                return;
            }
            // TODO: エラーメッセージ追加予定

        }
    }
}