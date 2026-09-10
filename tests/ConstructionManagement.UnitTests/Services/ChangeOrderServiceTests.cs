using System;
using System.Threading.Tasks;
using Xunit;
using Microsoft.EntityFrameworkCore;
using ConstructionManagement.Application.Services;
using ConstructionManagement.Application.DTOs;
using ConstructionManagement.Infrastructure.Data;
using ConstructionManagement.Domain.Entities.Projects;

namespace ConstructionManagement.UnitTests.Services
{
    public class ChangeOrderServiceTests
    {
        private ApplicationDbContext GetDbContext()
        {
            var options = new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            return new ApplicationDbContext(options);
        }

        [Fact]
        public async Task ApproveChangeOrder_Should_Update_ContractValue_And_Audit()
        {
            // Arrange
            var db = GetDbContext();
            var projectId = Guid.NewGuid();
            var changeOrderId = Guid.NewGuid();
            
            db.Projects.Add(new Project { ProjectId = projectId, CurrentContractValue = 100000 });
            db.ChangeOrders.Add(new ChangeOrder { ChangeOrderId = changeOrderId, ProjectId = projectId, AmountChange = 5000, Status = 2 });
            await db.SaveChangesAsync();

            var service = new ChangeOrderService(db);
            var empUserId = Guid.NewGuid();

            // Act
            await service.ApproveChangeOrderAsync(changeOrderId, empUserId, 1);

            // Assert
            var co = await db.ChangeOrders.FindAsync(changeOrderId);
            var proj = await db.Projects.FindAsync(projectId);
            var audit = await db.AuditLogs.FirstOrDefaultAsync();

            Assert.Equal(3, co.Status);
            Assert.Equal(105000, proj.CurrentContractValue);
            Assert.NotNull(audit);
            Assert.Equal("Approve", audit.Action);
        }

        [Fact]
        public async Task Customer_Cannot_Approve_ChangeOrder()
        {
            // Arrange
            var db = GetDbContext();
            var service = new ChangeOrderService(db);

            // Act & Assert
            await Assert.ThrowsAsync<UnauthorizedAccessException>(() => 
                service.ApproveChangeOrderAsync(Guid.NewGuid(), Guid.NewGuid(), 2));
        }
    }
}
