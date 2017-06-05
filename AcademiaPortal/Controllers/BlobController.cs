using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;

namespace AcademiaPortal.Controllers
{
    public class CustomMultipartFormDataStreamProvider : MultipartFormDataStreamProvider
    {
        public CustomMultipartFormDataStreamProvider(string path) : base(path) { }
        public override string GetLocalFileName(HttpContentHeaders headers)
        {
            return Guid.NewGuid().ToString() + "-" + headers.ContentDisposition.FileName.Replace("\"", string.Empty);
        }

    }
    public class BlobController : ApiController
    {
        // GET api/<controller>
        public IEnumerable<string> Get()
        {
            return new string[] { "value1", "value2" };
        }

        // GET api/<controller>/5
        public string Get(int id)
        {
            return "value";
        }

        // PUT api/<controller>/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/<controller>/5
        public void Delete(int id)
        {
        }

        // POST api/<controller>
        public Task<HttpResponseMessage> Post()
        {
            // Check if the request contains multipart/form-data.
            if (!Request.Content.IsMimeMultipartContent())
            {
                throw new HttpResponseException(HttpStatusCode.UnsupportedMediaType);
            }

            Trace.WriteLine("Request.Content.Headers.ContentLength=" + Request.Content.Headers.ContentLength);
            System.Configuration.Configuration config = System.Web.Configuration.WebConfigurationManager.OpenWebConfiguration("~");
            System.Web.Configuration.HttpRuntimeSection section = config.GetSection("system.web/httpRuntime") as System.Web.Configuration.HttpRuntimeSection;
            Trace.WriteLine("system.web/httpRuntime.MaxRequestLength" + section.MaxRequestLength);

            if (Request.Content.Headers.ContentLength > section.MaxRequestLength * 1024)
            {
                return Task.FromResult(Request.CreateErrorResponse(HttpStatusCode.RequestEntityTooLarge, "File should be smaller than " + Math.Round(section.MaxRequestLength / 1024.0) + "MB."));
            }

            string root = HttpContext.Current.Server.MapPath("~/uploads");
            var provider = new CustomMultipartFormDataStreamProvider(root);

            // Read the form data and return an async task.
            var task = Request.Content.ReadAsMultipartAsync(provider).
                ContinueWith<HttpResponseMessage>(t =>
                {
                    List<String> server_side_file_names = new List<String>();
                    if (t.IsFaulted || t.IsCanceled)
                    {
                        Request.CreateErrorResponse(HttpStatusCode.InternalServerError, t.Exception);
                    }

                    // This illustrates how to get the file names.
                    foreach (MultipartFileData file in provider.FileData)
                    {
                        Trace.WriteLine(file.Headers.ContentDisposition.FileName);
                        server_side_file_names.Add(System.IO.Path.GetFileName(file.LocalFileName));
                        Trace.WriteLine("Server file path: " + file.LocalFileName);
                    }
                    return Request.CreateResponse(HttpStatusCode.OK, server_side_file_names);
                });

            return task;
        }
    }
}