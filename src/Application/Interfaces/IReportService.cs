using System;
using System.Threading.Tasks;
using ConstructionManagement.Application.DTOs;

namespace ConstructionManagement.Application.Interfaces
{
    public interface IReportService
    {
        Task<ReportDto> GetProjectStatementAsync(Guid projectId, Guid? customerId, byte userType);
    }
}
