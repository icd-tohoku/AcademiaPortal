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
            string En_first = En_family.Text;
            string EN_middle = En_middle.Text;
            string En_last = En_family.Text;
            string Ja_first = ja_First.Text;
            string Ja_last = ja_fimily.Text;
            string hiragana = Hiragana.Text;

            //not necesally
            string mail = "";

            //必須項目チェック
            if (En_first == "" || En_last == "" || Ja_first == "" || Ja_last == "" || hiragana == "")
            {
                //エラー処理追加予定
            }
            else
            {
                if (App_Code.Database.AddAuthor(En_first, EN_middle, En_last, Ja_first, Ja_last, mail, hiragana))
                {
                    //追加できたらページ更新
                    Response.Redirect(Request.Url.OriginalString);

                    //追加し旨を伝えるメッセージを表示予定
                }
                else
                {
                    //エラーメッセージ追加予定
                }
            }
            //フォームをクリア
            En_family.Text = "";
            En_middle.Text = "";
            En_family.Text = "";
            ja_First.Text = "";
            ja_fimily.Text = "";
            Hiragana.Text = "";
        }
    }
}