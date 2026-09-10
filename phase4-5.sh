#!/bin/bash
mkdir -p src/Application/DTOs
mkdir -p src/Application/Interfaces
mkdir -p src/Application/Services
mkdir -p src/Api/ConstructionManagement.Api/Controllers

# DTOs
cat << 'CS' > src/Application/DTOs/ContractDtos.cs
using System;
using System.Collections.Generic;

namespace ConstructionManagement.Application.DTOs
{
    public class ContractDto
    {
        public Guid ContractId { get; set; }
        public Guid ProjectId { get; set; }
        public string ContractNumber { get; set; }
        public decimal OriginalValue { get; set; }
        public decimal CurrentValue { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public byte Status { get; set; }
    }
}
CS

cat << 'CS' > src/Application/DTOs/ChangeOrderDtos.cs
using System;

namespace ConstructionManagement.Application.DTOs
{
    public class ChangeOrderDto
    {
        public Guid ChangeOrderId { get; set; }
        public Guid ProjectId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public decimal AmountChange { get; set; }
        public int DurationChangeDays { get; set; }
        public byte Status { get; set; } 
        public DateTime CreatedAtUtc { get; set; }
        public Guid? ApprovedBy { get; set; }
        public DateTime? ApprovedAtUtc { get; set; }
    }
    
    public class ApproveChangeOrderRequest
    {
        public Guid ChangeOrderId { get; set; }
        public string Notes { get; set; }
    }
}
CS

# Interfaces
cat << 'CS' > src/Application/Interfaces/IContractService.cs
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConstructionManagement.Application.DTOs;

namespace ConstructionManagement.Application.Interfaces
{
    public interface IContractService
    {
        Task<IEnumerable<ContractDto>> GetContractsAsync(Guid? customerId, byte userType);
        Task<ContractDto> GetContractByIdAsync(Guid contractId, Guid? customerId, byte userType);
        Task<ContractDto> CreateContractAsync(ContractDto dto, Guid userId);
    }
}
CS

cat << 'CS' > src/Application/Interfaces/IChangeOrderService.cs
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConstructionManagement.Application.DTOs;

namespace ConstructionManagement.Application.Interfaces
{
    public interface IChangeOrderService
    {
        Task<IEnumerable<ChangeOrderDto>> GetChangeOrdersAsync(Guid projectId, Guid? customerId, byte userType);
        Task<ChangeOrderDto> CreateChangeOrderAsync(ChangeOrderDto dto, Guid userId);
        Task<bool> ApproveChangeOrderAsync(Guid changeOrderId, Guid userId, byte userType);
        Task<bool> RejectChangeOrderAsync(Guid changeOrderId, Guid userId, byte userType);
    }
}
CS

# Services
cat << 'CS' > src/Application/Services/ContractService.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Application.DTOs;
using ConstructionManagement.Infrastructure.Data;
using ConstructionManagement.Domain.Entities.Projects;

namespace ConstructionManagement.Application.Services
{
    public class ContractService : IContractService
    {
        private readonly ApplicationDbContext _context;

        public ContractService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<ContractDto>> GetContractsAsync(Guid? customerId, byte userType)
        {
            var query = _context.Contracts.Include(c => c.Project).AsQueryable();

            if (userType == 2) 
            {
                if (!customerId.HasValue) throw new UnauthorizedAccessException("Customer ID missing.");
                query = query.Where(c => c.Project.CustomerId == customerId.Value);
            }

            return await query.Select(c => new ContractDto
            {
                ContractId = c.ContractId,
                ProjectId = c.ProjectId,
                ContractNumber = c.ContractNumber,
                OriginalValue = c.OriginalValue,
                CurrentValue = c.CurrentValue,
                StartDate = c.StartDate,
                EndDate = c.EndDate,
                Status = c.Status
            }).ToListAsync();
        }

        public async Task<ContractDto> GetContractByIdAsync(Guid contractId, Guid? customerId, byte userType)
        {
            var contract = await _context.Contracts.Include(c => c.Project).FirstOrDefaultAsync(c => c.ContractId == contractId);
            if (contract == null) return null;

            if (userType == 2 && contract.Project.CustomerId != customerId)
                throw new UnauthorizedAccessException("Access denied to this contract.");

            return new ContractDto
            {
                ContractId = contract.ContractId,
                ProjectId = contract.ProjectId,
                ContractNumber = contract.ContractNumber,
                OriginalValue = contract.OriginalValue,
                CurrentValue = contract.CurrentValue,
                StartDate = contract.StartDate,
                EndDate = contract.EndDate,
                Status = contract.Status
            };
        }

        public async Task<ContractDto> CreateContractAsync(ContractDto dto, Guid userId)
        {
            var contract = new Contract
            {
                ContractId = Guid.NewGuid(),
                ProjectId = dto.ProjectId,
                ContractNumber = dto.ContractNumber ?? $"CONT-{DateTime.UtcNow:yyyyMMddHHmmss}",
                OriginalValue = dto.OriginalValue,
                CurrentValue = dto.OriginalValue,
                StartDate = dto.StartDate,
                EndDate = dto.EndDate,
                Status = 1 // Draft
            };
            
            _context.Contracts.Add(contract);
            await _context.SaveChangesAsync();
            dto.ContractId = contract.ContractId;
            return dto;
        }
    }
}
CS

cat << 'CS' > src/Application/Services/ChangeOrderService.cs
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

namespace ConstructionManagement.Application.Services
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
CS

# Controllers
cat << 'CS' > src/Api/ConstructionManagement.Api/Controllers/ContractsController.cs
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using System;
using System.Linq;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Application.DTOs;
using System.Collections.Generic;

namespace ConstructionManagement.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize]
    public class ContractsController : ControllerBase
    {
        private readonly IContractService _contractService;

        public ContractsController(IContractService contractService) 
        { 
            _contractService = contractService; 
        }

        private (Guid? CustomerId, byte UserType) GetAuthContext()
        {
            byte.TryParse(User.Claims.FirstOrDefault(c => c.Type == "UserType")?.Value, out byte userType);
            Guid.TryParse(User.Claims.FirstOrDefault(c => c.Type == "CustomerId")?.Value, out Guid custId);
            return (custId == Guid.Empty ? null : custId, userType);
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ContractDto>>> GetContracts()
        {
            var ctx = GetAuthContext();
            var contracts = await _contractService.GetContractsAsync(ctx.CustomerId, ctx.UserType);
            return Ok(contracts);
        }
    }
}
CS

cat << 'CS' > src/Api/ConstructionManagement.Api/Controllers/ChangeOrdersController.cs
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using System;
using System.Linq;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Application.DTOs;

namespace ConstructionManagement.Api.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize]
    public class ChangeOrdersController : ControllerBase
    {
        private readonly IChangeOrderService _coService;

        public ChangeOrdersController(IChangeOrderService coService) 
        { 
            _coService = coService; 
        }

        private (Guid? CustomerId, byte UserType, Guid UserId) GetAuthContext()
        {
            byte.TryParse(User.Claims.FirstOrDefault(c => c.Type == "UserType")?.Value, out byte userType);
            Guid.TryParse(User.Claims.FirstOrDefault(c => c.Type == "CustomerId")?.Value, out Guid custId);
            Guid.TryParse(User.Claims.FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.NameIdentifier)?.Value, out Guid userId);
            return (custId == Guid.Empty ? null : custId, userType, userId);
        }

        [HttpPost("{id}/approve")]
        public async Task<IActionResult> Approve(Guid id)
        {
            var ctx = GetAuthContext();
            try
            {
                await _coService.ApproveChangeOrderAsync(id, ctx.UserId, ctx.UserType);
                return Ok(new { Message = "Approved successfully." });
            }
            catch(UnauthorizedAccessException ex) { return Forbid(ex.Message); }
            catch(InvalidOperationException ex) { return BadRequest(ex.Message); }
            catch(System.Collections.Generic.KeyNotFoundException ex) { return NotFound(ex.Message); }
        }
    }
}
CS
