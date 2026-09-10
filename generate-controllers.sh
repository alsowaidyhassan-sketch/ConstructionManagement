#!/bin/bash

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

        private (Guid? CompanyId, Guid? BranchId, Guid? CustomerId, byte UserType, Guid UserId) GetContext()
        {
            byte.TryParse(User.Claims.FirstOrDefault(c => c.Type == "UserType")?.Value, out byte userType);
            
            Guid.TryParse(User.Claims.FirstOrDefault(c => c.Type == "CompanyId")?.Value, out Guid compId);
            Guid? companyId = compId == Guid.Empty ? null : compId;

            Guid.TryParse(User.Claims.FirstOrDefault(c => c.Type == "BranchId")?.Value, out Guid brId);
            Guid? branchId = brId == Guid.Empty ? null : brId;

            Guid.TryParse(User.Claims.FirstOrDefault(c => c.Type == "CustomerId")?.Value, out Guid custId);
            Guid? customerId = custId == Guid.Empty ? null : custId;

            Guid.TryParse(User.Claims.FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.NameIdentifier)?.Value, out Guid userId);

            return (companyId, branchId, customerId, userType, userId);
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ProjectDto>>> GetProjects()
        {
            var ctx = GetContext();
            try 
            {
                var projects = await _projectService.GetProjectsAsync(ctx.CompanyId, ctx.BranchId, ctx.CustomerId, ctx.UserType);
                return Ok(projects);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<ProjectDetailsDto>> GetProject(Guid id)
        {
            var ctx = GetContext();
            try
            {
                var project = await _projectService.GetProjectDetailsAsync(id, ctx.CustomerId, ctx.UserType);
                if (project == null) return NotFound();
                return Ok(project);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
        }
        
        [HttpPost("{id}/progress")]
        public async Task<ActionResult<ProgressUpdateDto>> AddProgress(Guid id, [FromBody] ProgressUpdateDto dto)
        {
            if (id != dto.ProjectId) return BadRequest("Project ID mismatch.");
            var ctx = GetContext();
            
            try
            {
                var result = await _projectService.AddProgressUpdateAsync(dto, ctx.CustomerId, ctx.UserType, ctx.UserId);
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
            catch (KeyNotFoundException ex)
            {
                return NotFound(ex.Message);
            }
        }
    }
}
CS
