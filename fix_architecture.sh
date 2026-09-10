#!/bin/bash

# 1. Add IProjectService and ProjectService
cat << 'CS' > src/Application/Interfaces/IProjectService.cs
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConstructionManagement.Application.DTOs;

namespace ConstructionManagement.Application.Interfaces
{
    public interface IProjectService
    {
        Task<IEnumerable<ProjectDto>> GetProjectsAsync(Guid? customerId, string userType);
        Task<ProjectDto> GetProjectByIdAsync(Guid projectId, Guid? customerId, string userType);
        Task<ProgressUpdateDto> AddProgressUpdateAsync(ProgressUpdateDto dto, Guid? customerId, string userType);
    }
}
CS

cat << 'CS' > src/Application/Services/ProjectService.cs
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
CS

mkdir -p src/Application/Services

# 2. Refactor ProjectsController to use IProjectService ONLY (No DbContext)
cat << 'CS' > src/Api/ConstructionManagement.Api/Controllers/ProjectsController.cs
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
    public class ProjectsController : ControllerBase
    {
        private readonly IProjectService _projectService;

        public ProjectsController(IProjectService projectService) 
        { 
            _projectService = projectService; 
        }

        private (Guid? CustomerId, string UserType) GetContextContext()
        {
            var userType = User.Claims.FirstOrDefault(c => c.Type == "UserType")?.Value;
            var customerIdStr = User.Claims.FirstOrDefault(c => c.Type == "CustomerId")?.Value;
            Guid? customerId = Guid.TryParse(customerIdStr, out var cid) ? cid : null;
            return (customerId, userType);
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ProjectDto>>> GetProjects()
        {
            var ctx = GetContextContext();
            var projects = await _projectService.GetProjectsAsync(ctx.CustomerId, ctx.UserType);
            return Ok(projects);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<ProjectDto>> GetProject(Guid id)
        {
            var ctx = GetContextContext();
            try
            {
                var project = await _projectService.GetProjectByIdAsync(id, ctx.CustomerId, ctx.UserType);
                if (project == null) return NotFound();
                return Ok(project);
            }
            catch (UnauthorizedAccessException)
            {
                return Forbid();
            }
        }
        
        [HttpPost("{id}/progress")]
        public async Task<ActionResult<ProgressUpdateDto>> AddProgress(Guid id, [FromBody] ProgressUpdateDto dto)
        {
            if (id != dto.ProjectId) return BadRequest("Project ID mismatch.");
            var ctx = GetContextContext();
            
            try
            {
                var result = await _projectService.AddProgressUpdateAsync(dto, ctx.CustomerId, ctx.UserType);
                return Ok(result);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
            catch (KeyNotFoundException)
            {
                return NotFound();
            }
        }
    }
}
CS

# Register Service in Program.cs
sed -i 's/\/\/ builder.Services.AddScoped<IProjectService, ProjectService>();/builder.Services.AddScoped<IProjectService, ConstructionManagement.Application.Services.ProjectService>();/g' src/Api/ConstructionManagement.Api/Program.cs

# We no longer need ProgressController since we merged it securely into ProjectsController/ProjectService
rm src/Api/ConstructionManagement.Api/Controllers/SystemControllers.cs

