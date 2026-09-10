#!/bin/bash
mkdir -p src/Application/Services
mkdir -p src/Application/DTOs

# Core DTOs
cat << 'CS' > src/Application/DTOs/CoreDtos.cs
using System;

namespace ConstructionManagement.Application.DTOs
{
    public class CustomerDto
    {
        public Guid CustomerId { get; set; }
        public string CustomerCode { get; set; }
        public string FullNameAr { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public bool IsActive { get; set; }
    }
    
    public class ContractorDto
    {
        public Guid ContractorId { get; set; }
        public string Name { get; set; }
        public string Specialization { get; set; }
        public bool IsActive { get; set; }
    }
}
CS

cat << 'CS' > src/Application/DTOs/ProjectDtos.cs
using System;
using System.Collections.Generic;

namespace ConstructionManagement.Application.DTOs
{
    public class ProjectDto
    {
        public Guid ProjectId { get; set; }
        public string ProjectCode { get; set; }
        public string ProjectName { get; set; }
        public decimal OverallProgressPercent { get; set; }
        public decimal CurrentContractValue { get; set; }
        public byte Status { get; set; }
        public Guid CustomerId { get; set; }
        public Guid? ContractorId { get; set; }
    }

    public class ProjectDetailsDto : ProjectDto
    {
        public string Address { get; set; }
        public string Description { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? PlannedEndDate { get; set; }
        public decimal InitialContractValue { get; set; }
        public byte ContractorCompensationType { get; set; }
        public decimal ContractorCompensationValue { get; set; }
        public CustomerDto Customer { get; set; }
        public ContractorDto Contractor { get; set; }
        public List<ProjectStageDto> Stages { get; set; }
    }

    public class ProjectStageDto
    {
        public Guid StageId { get; set; }
        public string Name { get; set; }
        public int SortOrder { get; set; }
        public decimal Weight { get; set; }
        public decimal ProgressPercent { get; set; }
        public byte Status { get; set; }
        public List<WorkItemDto> WorkItems { get; set; }
    }

    public class WorkItemDto
    {
        public Guid WorkItemId { get; set; }
        public string Name { get; set; }
        public decimal Quantity { get; set; }
        public string Unit { get; set; }
        public decimal ProgressPercent { get; set; }
    }

    public class ProgressUpdateDto
    {
        public Guid ProjectId { get; set; }
        public Guid? StageId { get; set; }
        public decimal ProgressPercent { get; set; }
        public string Description { get; set; }
        public List<string> Base64Images { get; set; } // Max 5
    }
}
CS

cat << 'CS' > src/Application/DTOs/FinanceDtos.cs
using System;

namespace ConstructionManagement.Application.DTOs
{
    public class PaymentPlanItemDto
    {
        public Guid PaymentPlanItemId { get; set; }
        public string Name { get; set; }
        public decimal? Amount { get; set; }
        public decimal? Percentage { get; set; }
        public decimal PaidAmount { get; set; }
        public byte Status { get; set; }
        public DateTime? DueDate { get; set; }
    }

    public class CustomerPaymentDto
    {
        public Guid PaymentId { get; set; }
        public Guid ProjectId { get; set; }
        public decimal Amount { get; set; }
        public string PaymentNumber { get; set; }
        public DateTime PaymentDate { get; set; }
        public byte PaymentMethod { get; set; }
        public byte Status { get; set; }
    }
}
CS

# Re-write IProjectService fully
cat << 'CS' > src/Application/Interfaces/IProjectService.cs
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConstructionManagement.Application.DTOs;

namespace ConstructionManagement.Application.Interfaces
{
    public interface IProjectService
    {
        Task<IEnumerable<ProjectDto>> GetProjectsAsync(Guid? companyId, Guid? branchId, Guid? customerId, byte userType);
        Task<ProjectDetailsDto> GetProjectDetailsAsync(Guid projectId, Guid? customerId, byte userType);
        Task<ProgressUpdateDto> AddProgressUpdateAsync(ProgressUpdateDto dto, Guid? customerId, byte userType, Guid createdBy);
    }
}
CS

# Re-write ProjectService fully
cat << 'CS' > src/Application/Services/ProjectService.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Application.DTOs;
using ConstructionManagement.Infrastructure.Data;
using ConstructionManagement.Domain.Entities.Projects;
using ConstructionManagement.Domain.Entities.Files;

namespace ConstructionManagement.Application.Services
{
    public class ProjectService : IProjectService
    {
        private readonly ApplicationDbContext _context;
        private readonly IFileStorage _fileStorage;

        public ProjectService(ApplicationDbContext context, IFileStorage fileStorage)
        {
            _context = context;
            _fileStorage = fileStorage;
        }

        public async Task<IEnumerable<ProjectDto>> GetProjectsAsync(Guid? companyId, Guid? branchId, Guid? customerId, byte userType)
        {
            var query = _context.Projects.AsQueryable();

            if (userType == 2) // Customer
            {
                if (!customerId.HasValue) throw new UnauthorizedAccessException("معرف العميل غير موجود.");
                query = query.Where(p => p.CustomerId == customerId.Value);
            }
            else if (userType == 1) // Employee
            {
                if (companyId.HasValue) query = query.Where(p => p.CompanyId == companyId.Value);
                if (branchId.HasValue) query = query.Where(p => p.BranchId == branchId.Value);
            }

            return await query.Select(p => new ProjectDto
            {
                ProjectId = p.ProjectId,
                ProjectCode = p.ProjectCode,
                ProjectName = p.ProjectName,
                OverallProgressPercent = p.OverallProgressPercent,
                CurrentContractValue = p.CurrentContractValue,
                Status = p.Status,
                CustomerId = p.CustomerId,
                ContractorId = p.ContractorId
            }).ToListAsync();
        }

        public async Task<ProjectDetailsDto> GetProjectDetailsAsync(Guid projectId, Guid? customerId, byte userType)
        {
            var project = await _context.Projects
                .Include(p => p.Customer)
                .Include(p => p.Contractor)
                .Include(p => p.Stages)
                    .ThenInclude(s => s.WorkItems)
                .FirstOrDefaultAsync(p => p.ProjectId == projectId);

            if (project == null) return null;

            // ISOLATION
            if (userType == 2 && project.CustomerId != customerId)
                throw new UnauthorizedAccessException("غير مصرح لك بمشاهدة هذا المشروع.");

            return new ProjectDetailsDto
            {
                ProjectId = project.ProjectId,
                ProjectCode = project.ProjectCode,
                ProjectName = project.ProjectName,
                Address = project.Address,
                Description = project.Description,
                StartDate = project.StartDate,
                PlannedEndDate = project.PlannedEndDate,
                Status = project.Status,
                OverallProgressPercent = project.OverallProgressPercent,
                InitialContractValue = project.InitialContractValue,
                CurrentContractValue = project.CurrentContractValue,
                ContractorCompensationType = project.ContractorCompensationType,
                ContractorCompensationValue = project.ContractorCompensationValue,
                CustomerId = project.CustomerId,
                ContractorId = project.ContractorId,
                Customer = project.Customer != null ? new CustomerDto { CustomerId = project.Customer.CustomerId, FullNameAr = project.Customer.FullNameAr } : null,
                Contractor = project.Contractor != null ? new ContractorDto { ContractorId = project.Contractor.ContractorId, Name = project.Contractor.Name } : null,
                Stages = project.Stages?.Select(s => new ProjectStageDto
                {
                    StageId = s.StageId,
                    Name = s.Name,
                    SortOrder = s.SortOrder,
                    Weight = s.Weight,
                    ProgressPercent = s.ProgressPercent,
                    Status = s.Status,
                    WorkItems = s.WorkItems?.Select(w => new WorkItemDto
                    {
                        WorkItemId = w.WorkItemId,
                        Name = w.Name,
                        Quantity = w.Quantity,
                        Unit = w.Unit,
                        ProgressPercent = w.ProgressPercent
                    }).ToList()
                }).OrderBy(s => s.SortOrder).ToList()
            };
        }

        public async Task<ProgressUpdateDto> AddProgressUpdateAsync(ProgressUpdateDto dto, Guid? customerId, byte userType, Guid createdBy)
        {
            var project = await _context.Projects.FirstOrDefaultAsync(p => p.ProjectId == dto.ProjectId);
            if (project == null) throw new KeyNotFoundException("المشروع غير موجود.");

            if (userType == 2)
                throw new UnauthorizedAccessException("لا يمكن للعميل تحديث الإنجاز.");

            if (dto.Base64Images != null && dto.Base64Images.Count > 5)
                throw new InvalidOperationException("يسمح بحد أقصى 5 صور فقط");

            var update = new ProgressUpdate
            {
                ProgressUpdateId = Guid.NewGuid(),
                ProjectId = dto.ProjectId,
                StageId = dto.StageId,
                ProgressPercent = dto.ProgressPercent,
                Description = dto.Description,
                UpdateDate = DateTime.UtcNow,
                CreatedBy = createdBy,
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
            
            // Re-calculate progress if required (simple mapping for now)
            project.OverallProgressPercent = dto.ProgressPercent; 
            
            await _context.SaveChangesAsync();

            dto.Base64Images = null; // Don't return base64
            return dto;
        }
    }
}
CS

