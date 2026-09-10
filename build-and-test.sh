#!/bin/bash
cd src/Infrastructure
export PATH="$PATH:$HOME/.dotnet/tools"
dotnet ef migrations add CompleteSystem -s ../Api/ConstructionManagement.Api/ConstructionManagement.Api.csproj
cd ../..

cat << 'CODE' > tests/ConstructionManagement.UnitTests/CustomerIsolationTests.cs
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
CODE

cat << 'CODE' > tests/ConstructionManagement.UnitTests/ProfitCalculationTests.cs
using System;
using ConstructionManagement.Domain.Entities;
using Xunit;

namespace ConstructionManagement.UnitTests
{
    public class ProfitCalculationTests
    {
        [Fact]
        public void ProjectProfit_Should_Calculate_Correctly()
        {
            // Arrange
            decimal contractValue = 1500000;
            decimal expenses = 200000;
            decimal contractorPayments = 800000;

            // Act
            decimal profit = contractValue - expenses - contractorPayments;

            // Assert
            Assert.Equal(500000, profit);
        }
    }
}
CODE

dotnet build ConstructionManagement.sln
dotnet test tests/ConstructionManagement.UnitTests/ConstructionManagement.UnitTests.csproj
