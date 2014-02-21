<%@ WebHandler Language="C#" Class="AjaxPosterHandler" %>

using System;
using System.Web;

public class AjaxPosterHandler : IHttpHandler {

    public void ProcessRequest(HttpContext context)
    {
        string fname = ""; ;
        if (context.Request.Files.Count > 0)
        {
            HttpFileCollection files = context.Request.Files;

            HttpPostedFile file = files[0];
            fname = file.FileName;
            string fullname = context.Server.MapPath("~/Upload/" + file.FileName);
            file.SaveAs(fullname);
        }
        context.Response.ContentType = "text/plain";
        context.Response.Write("../Upload/" + fname);
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}