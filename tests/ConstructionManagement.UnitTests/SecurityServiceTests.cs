using System;
using ConstructionManagement.Domain.Entities;
using ConstructionManagement.Infrastructure.Services;
using Xunit;

namespace ConstructionManagement.UnitTests
{
    public class SecurityServiceTests
    {
        [Fact]
        public void VerifyPassword_Should_Match_HashedPassword()
        {
            // Arrange
            var service = new SecurityService();
            string rawPassword = "StrongPassword123!";
            
            // Act
            string hash = service.HashPassword(rawPassword);
            bool isMatch = service.VerifyPassword(rawPassword, hash);
            
            // Assert
            Assert.True(isMatch);
        }
    }
}
