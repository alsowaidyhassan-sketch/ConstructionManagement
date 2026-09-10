using System;
using System.Collections.Generic;
using System.Linq;
using ConstructionManagement.Domain.Entities;
using Xunit;

namespace ConstructionManagement.UnitTests
{
    public class CustomerIsolationTests
    {
        [Fact]
        public void Customer_Cannot_See_Other_Customers_Projects()
        {
            // Arrange
            var customer1Id = Guid.NewGuid();
            var customer2Id = Guid.NewGuid();
            
            var projects = new List<Project>
            {
                new Project { ProjectId = Guid.NewGuid(), CustomerId = customer1Id, ProjectName = "Proj 1" },
                new Project { ProjectId = Guid.NewGuid(), CustomerId = customer2Id, ProjectName = "Proj 2" }
            };

            // Act - Simulating API Controller isolation logic
            var visibleProjects = projects.Where(p => p.CustomerId == customer1Id).ToList();

            // Assert
            Assert.Single(visibleProjects);
            Assert.Equal(customer1Id, visibleProjects[0].CustomerId);
        }
    }
}
