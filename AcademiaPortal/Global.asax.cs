using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.SessionState;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.Optimization;
using System.Web.Http;

namespace AcademiaPortal
{
    public class Global : System.Web.HttpApplication
    {
        const int TimedOutExceptionCode = -2147467259;
        public static bool IsMaxRequestExceededException(Exception e)
        {
            // unhandled errors = caught at global.ascx level
            // http exception = caught at page level

            Exception main;
            var unhandled = e as HttpUnhandledException;

            if (unhandled != null && unhandled.ErrorCode == TimedOutExceptionCode)
            {
                main = unhandled.InnerException;
            }
            else
            {
                main = e;
            }


            var http = main as HttpException;

            if (http != null && http.ErrorCode == TimedOutExceptionCode)
            {
                // hack: no real method of identifying if the error is max request exceeded as 
                // it is treated as a timeout exception
                if (http.StackTrace.Contains("GetEntireRawContent"))
                {
                    // MAX REQUEST HAS BEEN EXCEEDED
                    return true;
                }
            }

            return false;
        }
        protected void Application_Start(object sender, EventArgs e)
        {
            string JQueryVer = "3.2.1";
            System.Web.UI.ScriptManager.ScriptResourceMapping.AddDefinition("jquery", new System.Web.UI.ScriptResourceDefinition
            {
                ResourceName = "jquery",
                CdnPath = "https://code.jquery.com/jquery-" + JQueryVer + ".min.js",
                CdnDebugPath = "https://code.jquery.com/jquery-" + JQueryVer + ".js",
                CdnSupportsSecureConnection = true,
                LoadSuccessExpression = "window.jQuery"
            });

            AreaRegistration.RegisterAllAreas();

            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            WebApiConfig.Register(GlobalConfiguration.Configuration);
            //RouteConfig.RegisterRoutes(RouteTable.Routes);
            //BundleConfig.RegisterBundles(BundleTable.Bundles);
        }
        protected void Application_Error(object sedner, EventArgs e)
        {
            if (IsMaxRequestExceededException(this.Server.GetLastError()))
            {
                this.Server.ClearError();
                System.Diagnostics.Trace.WriteLine("Request limit exceeded.");
            }
        }
    }
}