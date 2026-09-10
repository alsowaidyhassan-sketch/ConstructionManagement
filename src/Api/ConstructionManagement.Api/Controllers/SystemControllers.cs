using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Infrastructure.Data;
using System.Threading.Tasks;
using System.Linq;
using Microsoft.AspNetCore.Authorization;
using System;
using ConstructionManagement.Domain.Entities;
using ConstructionManagement.Application.DTOs;
using ConstructionManagement.Application.Interfaces;
using System.Collections.Generic;

namespace ConstructionManagement.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize]
    public class DashboardController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        public DashboardController(ApplicationDbContext context) { _context = context; }

        [HttpGet]
        public async Task<IActionResult> GetDashboardStats()
        {
            var userType = User.Claims.FirstOrDefault(c => c.Type == "UserType")?.Value;
            var customerIdStr = User.Claims.FirstOrDefault(c => c.Type == "CustomerId")?.Value;
            bool isCustomer = userType == "2";
            
            var projectsQuery = _context.Projects.AsQueryable();
            var paymentsQuery = _context.CustomerPayments.AsQueryable();
            
            if (isCustomer && Guid.TryParse(customerIdStr, out Guid customerId))
            {
                projectsQuery = projectsQuery.Where(p => p.CustomerId == customerId);
                paymentsQuery = paymentsQuery.Where(p => p.CustomerId == customerId);
            }

            var totalProjects = await projectsQuery.CountAsync();
            var totalPayments = await paymentsQuery.SumAsync(p => p.Amount);

            return Ok(new { TotalProjects = totalProjects, TotalPayments = totalPayments });
        }
    }

    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize]
    public class ChangeOrdersController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        public ChangeOrdersController(ApplicationDbContext context) { _context = context; }

        [HttpPost("{id}/approve")]
        public async Task<IActionResult> ApproveChangeOrder(Guid id)
        {
            var userType = User.Claims.FirstOrDefault(c => c.Type == "UserType")?.Value;
            if (userType == "2") return Forbid("Customers cannot approve change orders."); // Customer Isolation - Prevent unauthorized action

            var changeOrder = await _context.ChangeOrders.Include(c => c.Project).FirstOrDefaultAsync(c => c.ChangeOrderId == id);
            if (changeOrder == null) return NotFound();

            changeOrder.Status = 3; // Approved
            if (changeOrder.Project != null)
            {
                changeOrder.Project.CurrentContractValue = (changeOrder.Project.CurrentContractValue ?? 0) + changeOrder.AmountChange;
            }
            
            _context.AuditLogs.Add(new AuditLog { AuditLogId = Guid.NewGuid(), Action = "Approve", EntityName = "ChangeOrder", Details = $"Approved CO {id}", TimestampUtc = DateTime.UtcNow });
            await _context.SaveChangesAsync();
            return Ok(new { Message = "Approved successfully." });
        }
    }

    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize]
    public class ProgressController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IFileStorage _fileStorage;
        public ProgressController(ApplicationDbContext context, IFileStorage fileStorage) 
        { 
            _context = context;
            _fileStorage = fileStorage;
        }

        [HttpPost]
        public async Task<IActionResult> CreateProgressUpdate([FromBody] ProgressUpdateDto dto)
        {
            if (dto.Base64Images != null && dto.Base64Images.Count > 5)
                return BadRequest(new { Message = "يسمح بحد أقصى 5 صور فقط" });

            var update = new ProgressUpdate
            {
                ProgressUpdateId = Guid.NewGuid(),
                ProjectId = dto.ProjectId,
                ProgressPercent = dto.ProgressPercent,
                Description = dto.Description,
                UpdateDate = DateTime.UtcNow,
                Images = new List<ProgressUpdateImage>()
            };

            if (dto.Base64Images != null)
            {
                foreach (var img in dto.Base64Images)
                {
                    var bytes = Convert.FromBase64String(img);
                    var path = await _fileStorage.SaveFileAsync(bytes, $"{Guid.NewGuid()}.jpg", $"Projects/{dto.ProjectId}/Progress");
                    update.Images.Add(new ProgressUpdateImage { ProgressUpdateImageId = Guid.NewGuid(), StoragePath = path });
                }
            }

            _context.ProgressUpdates.Add(update);
            await _context.SaveChangesAsync();
            return Ok(update);
        }
    }
}
