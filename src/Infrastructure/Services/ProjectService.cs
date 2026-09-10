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

namespace ConstructionManagement.Infrastructure.Services
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
