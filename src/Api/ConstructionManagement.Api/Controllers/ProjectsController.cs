using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Infrastructure.Data;
using System.Threading.Tasks;
using System.Linq;
using System.Security.Claims;

namespace ConstructionManagement.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    // [Authorize]
    public class ProjectsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        public ProjectsController(ApplicationDbContext context) { _context = context; }

        [HttpGet]
        public async Task<IActionResult> GetProjects()
        {
            // Implementation of isolation: if customer, return only their projects
            var userType = User.Claims.FirstOrDefault(c => c.Type == "UserType")?.Value;
            var customerIdStr = User.Claims.FirstOrDefault(c => c.Type == "CustomerId")?.Value;

            var query = _context.Projects.Include(p => p.Customer).AsQueryable();

            if (userType == "2" && !string.IsNullOrEmpty(customerIdStr))
            {
                var customerId = System.Guid.Parse(customerIdStr);
                query = query.Where(p => p.CustomerId == customerId);
            }

            var projects = await query.ToListAsync();
            return Ok(projects);
        }
    }
}
