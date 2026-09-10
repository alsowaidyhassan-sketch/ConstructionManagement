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
