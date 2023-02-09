using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Playwright;
using Newtonsoft.Json;
using System.IO;
using System.Threading.Tasks;

namespace playwright_docker
{
	public static class pdf
	{
		[FunctionName("pdf")]
		public static async Task<IActionResult> Run(
			[HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
			ILogger log)
		{
			log.LogInformation("C# HTTP trigger function processed a request.");

			string name = req.Query["name"];

			string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
			dynamic data = JsonConvert.DeserializeObject(requestBody);
			name = name ?? data?.name;

			byte[] bytes = await CreateAsync("<div>hello world!</div>");
			var result = new FileContentResult(bytes, "application/octet-stream");
			result.FileDownloadName = "test.pdf";

			return result;
		}

		public static async Task<byte[]> CreateAsync(string html)
		{
			using var playwright = await Playwright.CreateAsync();
			await using var browser = await playwright.Chromium.LaunchAsync();
			var page = await browser.NewPageAsync();
			await page.EmulateMediaAsync(new PageEmulateMediaOptions { Media = Media.Screen });
			await page.SetContentAsync(html, new PageSetContentOptions() { WaitUntil = WaitUntilState.Load });
			return await page.PdfAsync(new PagePdfOptions { Format = "A4" });
		}
	}
}
