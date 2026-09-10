using System.IO;
using System.Text.RegularExpressions;

class Program
{
    static void Main()
    {
        var path = "src/Api/ConstructionManagement.Api/Program.cs";
        var content = File.ReadAllText(path);
        
        var servicesToAdd = @"
builder.Services.AddScoped<IContractService, ConstructionManagement.Application.Services.ContractService>();
builder.Services.AddScoped<IChangeOrderService, ConstructionManagement.Application.Services.ChangeOrderService>();
builder.Services.AddScoped<IFinanceService, ConstructionManagement.Application.Services.FinanceService>();
builder.Services.AddScoped<IDocumentService, ConstructionManagement.Application.Services.DocumentService>();
builder.Services.AddScoped<IReportService, ConstructionManagement.Application.Services.ReportService>();
";
        
        if (!content.Contains("IContractService"))
        {
            content = content.Replace("builder.Services.AddScoped<IWhatsAppProvider, MockWhatsAppProvider>();", 
                "builder.Services.AddScoped<IWhatsAppProvider, MockWhatsAppProvider>();\n" + servicesToAdd);
            File.WriteAllText(path, content);
        }
    }
}
