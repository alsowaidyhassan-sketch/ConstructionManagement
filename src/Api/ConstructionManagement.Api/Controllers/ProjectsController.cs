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
