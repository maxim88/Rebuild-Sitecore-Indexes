<%@ page language="C#" autoeventwireup="true" %>
<%@ import namespace="Sitecore.ContentSearch.Maintenance" %>
<%@ import namespace="Sitecore.ContentSearch" %>
<%@ Import Namespace="Sitecore.StringExtensions" %>

<script runat="server">

    readonly List<string> _indexes = new List<string>
    {
        "Your_Index_1",
        "Your_Index_2",
        "Your_Index_3"
    };

    void Page_Load(object sender, EventArgs e)
    {
        repJobs.DataBind();
        Container.Controls.Clear();

        foreach (var index in _indexes)
        {
            var element = new Button
            {
                ID = "btn_" + index,

                Text = string.Format("Rebuild Index: '{0}'", index)
            };

            element.Click += btnRebuildIndex_OnClick;
            element.Attributes.Add("indexName", index);

            element.Style.Add(HtmlTextWriterStyle.Padding, "7px 7px");
            element.Style.Add(HtmlTextWriterStyle.Margin, "10px 10px");
            element.Style.Add(HtmlTextWriterStyle.BackgroundColor, "Green");
            element.Style.Add(HtmlTextWriterStyle.Color, "white");
            Container.Controls.Add(element);
        }
    }

    private void btnRebuildIndex_OnClick(object sender, EventArgs e)
    {
        output.InnerHtml = "btnRebuildIndex_OnClick";
        var button = sender as Button;
        var index = button.Attributes["indexName"];

        output.InnerHtml = " You've selected the '{0}' index to be rebuilt.  <br/>  click 'Refresh to see the list of Jobs'".FormatWith(index);

        IndexCustodian.FullRebuild(ContentSearchManager.GetIndex(index), true); 
    }
      
    public IEnumerable<Sitecore.Jobs.Job> Jobs
    {
        get
        {
            if (!cbShowFinished.Checked)
            { return Sitecore.Jobs.JobManager.GetJobs().Where(job => job.IsDone == false).OrderBy(job => job.QueueTime);}
            
            return Sitecore.Jobs.JobManager.GetJobs().OrderBy(job => job.QueueTime);
        }
    }

    protected string GetJobText(Sitecore.Jobs.Job job)
    {
        return string.Format("{0}\n\n{1}\n\n{2}", job.Name, job.Category, GetJobMessages(job));
    }

    protected string GetJobMessages(Sitecore.Jobs.Job job)
    {
        StringBuilder sb = new StringBuilder();

        if (job.Options.ContextUser != null)
        {
            sb.AppendLine("Context User: " + job.Options.ContextUser.Name);
        }

        sb.AppendLine("Priority: " + job.Options.Priority);
        sb.AppendLine("Texts:");

        foreach (string s in job.Status.Messages)
        {
            sb.AppendLine(s);
        }
        return sb.ToString();
    }

    protected string GetJobColor(Sitecore.Jobs.Job job)
    {
        if (job.IsDone)
            return "#737373";
        return "#000";
    }

    protected void cbShowFinished_CheckedChanged(object sender, EventArgs e)
    {
        repJobs.DataBind();
    }

</script>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<html>
<head>
    <title>Rebuild Indexes</title>
    <link href="/default.css" rel="stylesheet">
</head>

<body style="font-size: 14px">
    <form runat="server">
        <div style="padding: 10px; text-align: center; background-color: #efefef; border-bottom: solid 1px #aaa; border-top: solid 1px white" id="output" runat="server"></div>

        <div style="padding: 10px; text-align: center; background-color: #efefef; border-bottom: solid 1px #aaa; border-top: solid 1px white" id="Container" runat="server"></div>

        <div style="padding: 10px; background-color: #efefef; border-bottom: solid 1px #aaa; border-top: solid 1px white">
            <div style="float: left; width: 200px; padding-top: 4px">
                <asp:checkbox id="cbShowFinished" runat="server" text="Show finished jobs" checked="false" oncheckedchanged="cbShowFinished_CheckedChanged" autopostback="true" />
            </div>
            <div style="float: right;">
                <asp:button id="btnRefresh" runat="server" text="Refresh" backcolor="Green" forecolor="White" width="100px" height="30px" />
            </div>
            <div style="clear: both; height: 1px">&nbsp;</div>
        </div>

        <div style="padding-top: 0px">
            <asp:repeater id="repJobs" runat="server" datasource="<%# Jobs %>">
          <HeaderTemplate>
            <table style="width:100%">
              <thead style="background-color:#eaeaea">
                <td>Job</td>
                <td>Category</td>
                <td>Status</td>
                <td>Processed</td>
                <td>QueueTime</td>
              </thead>
          </HeaderTemplate>
          <FooterTemplate>
            </table>
          </FooterTemplate>
          <ItemTemplate>
            <tr style="background-color:beige; color:<%# GetJobColor((Container.DataItem as Sitecore.Jobs.Job)) %>" title="<%# GetJobText((Container.DataItem as Sitecore.Jobs.Job)) %>">
              <td>
                <%# Sitecore.StringUtil.Clip((Container.DataItem as Sitecore.Jobs.Job).Name, 50, true) %>
              </td>
              <td>
                <%# Sitecore.StringUtil.Clip((Container.DataItem as Sitecore.Jobs.Job).Category, 50, true) %>
              </td>
              <td>
                <%# (Container.DataItem as Sitecore.Jobs.Job).Status.State %>
              </td>
              <td>
                <%# (Container.DataItem as Sitecore.Jobs.Job).Status.Processed %> /
                <%# (Container.DataItem as Sitecore.Jobs.Job).Status.Total %>
              </td>
              <td>
                <%# (Container.DataItem as Sitecore.Jobs.Job).QueueTime.ToLocalTime() %>
              </td>
            </tr>
          </ItemTemplate>
        </asp:repeater>
        </div>
    </form>
</body>
</html>
