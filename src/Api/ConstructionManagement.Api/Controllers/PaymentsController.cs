using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Infrastructure.Data;
using System.Threading.Tasks;
using System.Linq;
using Microsoft.AspNetCore.Authorization;
using System;
using ConstructionManagement.Domain.Entities.Core;
using ConstructionManagement.Domain.Entities.Files;
using ConstructionManagement.Domain.Entities.Finance;
using ConstructionManagement.Domain.Entities.Projects;
using ConstructionManagement.Domain.Entities.Security;
using ConstructionManagement.Domain.Entities.System;

namespace ConstructionManagement.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize]
    public class PaymentsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        public PaymentsController(ApplicationDbContext context) { _context = context; }

        [HttpGet]
        public async Task<IActionResult> GetPayments()
        {
            var userType = User.Claims.FirstOrDefault(c => c.Type == "UserType")?.Value;
            var customerIdStr = User.Claims.FirstOrDefault(c => c.Type == "CustomerId")?.Value;

            var query = _context.CustomerPayments.Include(p => p.Project).AsQueryable();

            if (userType == "2" && !string.IsNullOrEmpty(customerIdStr) && Guid.TryParse(customerIdStr, out Guid customerId))
            {
                query = query.Where(p => p.CustomerId == customerId);
            }

            var payments = await query.ToListAsync();
            return Ok(payments);
        }

        [HttpPost("process-electronic")]
        public async Task<IActionResult> ProcessElectronicPayment([FromBody] PaymentRequest request)
        {
            // Integration with Gateway Placeholder
            var payment = new CustomerPayment 
            {
                PaymentId = Guid.NewGuid(),
                ProjectId = request.ProjectId,
                CustomerId = request.CustomerId,
                Amount = request.Amount,
                PaymentDate = DateTime.UtcNow,
                Status = 1, // Pending
                PaymentNumber = "PAY-" + new Random().Next(1000, 9999)
            };
            
            _context.CustomerPayments.Add(payment);
            await _context.SaveChangesAsync();
            
            return Ok(new { Message = "تم إنشاء طلب الدفع وتوجيهك للبوابة الإلكترونية", PaymentId = payment.PaymentId });
        }
    }

    public class PaymentRequest
    {
        public Guid ProjectId { get; set; }
        public Guid CustomerId { get; set; }
        public decimal Amount { get; set; }
    }
}
