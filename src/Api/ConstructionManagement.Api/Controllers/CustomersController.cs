using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Infrastructure.Data;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
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
    // [Authorize] // Commented out for easier local testing, uncomment for prod
    public class CustomersController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        public CustomersController(ApplicationDbContext context) { _context = context; }

        [HttpGet]
        public async Task<IActionResult> GetCustomers()
        {
            var customers = await _context.Customers.ToListAsync();
            return Ok(customers);
        }

        [HttpPost]
        public async Task<IActionResult> CreateCustomer([FromBody] Customer customer)
        {
            customer.CustomerId = System.Guid.NewGuid();
            customer.CreatedAtUtc = System.DateTime.UtcNow;
            _context.Customers.Add(customer);
            await _context.SaveChangesAsync();
            return Ok(customer);
        }
    }
}
