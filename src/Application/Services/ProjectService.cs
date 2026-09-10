using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Application.Interfaces;
using ConstructionManagement.Application.DTOs;
using ConstructionManagement.Infrastructure.Data;
using ConstructionManagement.Domain.Entities;

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

        public async Task<IEnumerable<ProjectDto>> GetProjectsAsync(Guid? customerId, string userType)
        {
            var query = _context.Projects.AsQueryable();

            // STRICT CUSTOMER ISOLATION
            if (userType == "2") // Customer
            {
                if (!customerId.HasValue) throw new UnauthorizedAccessException("Customer ID is missing from context.");
                query = query.Where(p => p.CustomerId == customerId.Value);
            }

            return await query.Select(p => new ProjectDto
            {
                ProjectId = p.ProjectId,
                ProjectName = p.ProjectName,
                OverallProgressPercent = p.OverallProgressPercent,
                CurrentContractValue = p.CurrentContractValue
            }).ToListAsync();
        }

        public async Task<ProjectDto> GetProjectByIdAsync(Guid projectId, Guid? customerId, string userType)
        {
            var project = await _context.Projects.FirstOrDefaultAsync(p => p.ProjectId == projectId);
            if (project == null) return null;

            // STRICT CUSTOMER ISOLATION
            if (userType == "2" && project.CustomerId != customerId)
            {
                throw new UnauthorizedAccessException("You do not have permission to access this project.");
            }

            return new ProjectDto
            {
                ProjectId = project.ProjectId,
                ProjectName = project.ProjectName,
                OverallProgressPercent = project.OverallProgressPercent,
                CurrentContractValue = project.CurrentContractValue
            };
        }

        public async Task<ProgressUpdateDto> AddProgressUpdateAsync(ProgressUpdateDto dto, Guid? customerId, string userType)
        {
            // Verify Project exists and authorization
            var project = await _context.Projects.FirstOrDefaultAsync(p => p.ProjectId == dto.ProjectId);
            if (project == null) throw new KeyNotFoundException("Project not found.");

            if (userType == "2" && project.CustomerId != customerId)
                throw new UnauthorizedAccessException("You cannot add progress to a project you do not own.");
            
            if (userType == "2")
                throw new UnauthorizedAccessException("Customers cannot submit progress updates."); // Only employees can submit progress

            if (dto.Base64Images != null && dto.Base64Images.Count > 5)
                throw new InvalidOperationException("يسمح بحد أقصى 5 صور فقط");

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
            project.OverallProgressPercent = dto.ProgressPercent; // Update parent
            await _context.SaveChangesAsync();

            // Clear base64 for response
            dto.Base64Images = null;
            return dto;
        }
    }
}
