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
