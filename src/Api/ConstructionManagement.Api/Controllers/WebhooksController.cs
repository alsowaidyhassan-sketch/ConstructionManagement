using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using System.IO;

namespace ConstructionManagement.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class WebhooksController : ControllerBase
    {
        [HttpPost("payment-gateway")]
        public async Task<IActionResult> PaymentGatewayWebhook()
        {
            using var reader = new StreamReader(Request.Body);
            var payload = await reader.ReadToEndAsync();
            var signature = Request.Headers["X-Signature"];
            
            // Logic to verify signature and mark CustomerPayment as Confirmed (Status = 2)
            // Implementation details hidden for brevity
            
            return Ok();
        }
    }
}
