using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Infrastructure.Data;
using System.Threading.Tasks;
using System.Linq;
using Microsoft.AspNetCore.Authorization;
using System;
using ConstructionManagement.Domain.Entities;

namespace ConstructionManagement.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize]
    public class ProjectsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        public ProjectsController(ApplicationDbContext context) { _context = context; }

        [HttpGet]
        public async Task<IActionResult> GetProjects()
        {
            var userType = User.Claims.FirstOrDefault(c => c.Type == "UserType")?.Value;
            var customerIdStr = User.Claims.FirstOrDefault(c => c.Type == "CustomerId")?.Value;

            var query = _context.Projects.Include(p => p.Customer).AsQueryable();

            // Customer Isolation Security Rule
            if (userType == "2" && !string.IsNullOrEmpty(customerIdStr) && Guid.TryParse(customerIdStr, out Guid customerId))
            {
                query = query.Where(p => p.CustomerId == customerId);
            }

            var projects = await query.ToListAsync();
            return Ok(projects);
        }

        [HttpPost("{projectId}/progress")]
        public async Task<IActionResult> AddProgressUpdate(Guid projectId, [FromBody] ProgressUpdate update)
        {
            if (update.Images != null && update.Images.Count > 5)
            {
                return BadRequest(new { Message = "يُسمح بحد أقصى 5 صور لكل تحديث إنجاز." });
            }

            update.ProjectId = projectId;
            update.UpdateDate = DateTime.UtcNow;
            
            _context.ProgressUpdates.Add(update);
            await _context.SaveChangesAsync();
            return Ok(update);
        }
    }
}
