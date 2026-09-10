using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Application.DTOs;
using ConstructionManagement.Infrastructure.Data;
using ConstructionManagement.Domain.Entities.Projects;
using ConstructionManagement.Domain.Entities.Security;

namespace ConstructionManagement.Infrastructure.Services
{
    public class ChangeOrderService : IChangeOrderService
    {
        private readonly ApplicationDbContext _context;

        public ChangeOrderService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<ChangeOrderDto>> GetChangeOrdersAsync(Guid projectId, Guid? customerId, byte userType)
        {
            var project = await _context.Projects.FirstOrDefaultAsync(p => p.ProjectId == projectId);
            if (project == null) throw new KeyNotFoundException("Project not found.");

            if (userType == 2 && project.CustomerId != customerId)
                throw new UnauthorizedAccessException("Unauthorized project access.");

            return await _context.ChangeOrders
                .Where(c => c.ProjectId == projectId)
                .Select(c => new ChangeOrderDto
                {
                    ChangeOrderId = c.ChangeOrderId,
                    ProjectId = c.ProjectId,
                    Title = c.Title,
                    Description = c.Description,
                    AmountChange = c.AmountChange,
                    DurationChangeDays = c.DurationChangeDays,
                    Status = c.Status,
                    CreatedAtUtc = c.CreatedAtUtc,
                    ApprovedBy = c.ApprovedBy,
                    ApprovedAtUtc = c.ApprovedAtUtc
                }).ToListAsync();
        }

        public async Task<ChangeOrderDto> CreateChangeOrderAsync(ChangeOrderDto dto, Guid userId)
        {
            var co = new ChangeOrder
            {
                ChangeOrderId = Guid.NewGuid(),
                ProjectId = dto.ProjectId,
                Title = dto.Title,
                Description = dto.Description,
                AmountChange = dto.AmountChange,
                DurationChangeDays = dto.DurationChangeDays,
                Status = 2, // Pending Approval
                CreatedAtUtc = DateTime.UtcNow,
                CreatedBy = userId
            };
            _context.ChangeOrders.Add(co);
            
            _context.AuditLogs.Add(new AuditLog { AuditLogId = Guid.NewGuid(), UserId = userId, Action = "Create", EntityName = "ChangeOrder", EntityId = co.ChangeOrderId.ToString(), TimestampUtc = DateTime.UtcNow, Details = "Created Change Order" });
            
            await _context.SaveChangesAsync();
            dto.ChangeOrderId = co.ChangeOrderId;
            return dto;
        }

        public async Task<bool> ApproveChangeOrderAsync(Guid changeOrderId, Guid userId, byte userType)
        {
            if (userType == 2) throw new UnauthorizedAccessException("Customers cannot approve change orders.");

            var co = await _context.ChangeOrders.Include(c => c.Project).FirstOrDefaultAsync(c => c.ChangeOrderId == changeOrderId);
            if (co == null) throw new KeyNotFoundException("Change order not found.");
            if (co.Status == 3) throw new InvalidOperationException("Change order is already approved."); // Prevent double approval

            co.Status = 3; // Approved
            co.ApprovedBy = userId;
            co.ApprovedAtUtc = DateTime.UtcNow;

            // Modify Contract Value & End Date
            co.Project.CurrentContractValue += co.AmountChange;
            if (co.Project.PlannedEndDate.HasValue)
            {
                co.Project.PlannedEndDate = co.Project.PlannedEndDate.Value.AddDays(co.DurationChangeDays);
            }

            _context.AuditLogs.Add(new AuditLog { AuditLogId = Guid.NewGuid(), UserId = userId, Action = "Approve", EntityName = "ChangeOrder", EntityId = co.ChangeOrderId.ToString(), TimestampUtc = DateTime.UtcNow, Details = $"Approved Change Order. Value added: {co.AmountChange}" });

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RejectChangeOrderAsync(Guid changeOrderId, Guid userId, byte userType)
        {
            if (userType == 2) throw new UnauthorizedAccessException("Customers cannot reject change orders.");

            var co = await _context.ChangeOrders.FirstOrDefaultAsync(c => c.ChangeOrderId == changeOrderId);
            if (co == null) throw new KeyNotFoundException("Change order not found.");

            co.Status = 4; // Rejected
            _context.AuditLogs.Add(new AuditLog { AuditLogId = Guid.NewGuid(), UserId = userId, Action = "Reject", EntityName = "ChangeOrder", EntityId = co.ChangeOrderId.ToString(), TimestampUtc = DateTime.UtcNow, Details = "Rejected Change Order" });

            await _context.SaveChangesAsync();
            return true;
        }
    }
}
