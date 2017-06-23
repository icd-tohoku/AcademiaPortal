<%@ Page Language="C#" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        Response.RedirectPermanent("/");
        base.OnLoad(e);
    }
</script>
