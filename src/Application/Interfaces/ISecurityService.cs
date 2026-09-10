using System.Threading.Tasks;
using ConstructionManagement.Domain.Entities.Core;
using ConstructionManagement.Domain.Entities.Files;
using ConstructionManagement.Domain.Entities.Finance;
using ConstructionManagement.Domain.Entities.Projects;
using ConstructionManagement.Domain.Entities.Security;
using ConstructionManagement.Domain.Entities.System;

namespace ConstructionManagement.Application.Interfaces
{
    public interface ISecurityService
    {
        string HashPassword(string password);
        bool VerifyPassword(string password, string hash);
        string GenerateJwtToken(User user);
    }
}
