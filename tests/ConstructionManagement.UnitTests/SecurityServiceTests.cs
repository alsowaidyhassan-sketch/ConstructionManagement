using System;
using System.Collections.Generic;
using ConstructionManagement.Domain.Entities.Security;
using ConstructionManagement.Infrastructure.Services;
using Microsoft.Extensions.Configuration;
using Xunit;

namespace ConstructionManagement.UnitTests
{
    public class SecurityServiceTests
    {
        private IConfiguration GetMockConfig()
        {
            var inMemorySettings = new Dictionary<string, string> {
                {"JwtSettings:Secret", "A_Very_Secure_Super_Secret_Key_For_Jwt_Generation_12345!"},
                {"JwtSettings:Issuer", "Test"},
                {"JwtSettings:Audience", "Test"},
                {"JwtSettings:ExpiryMinutes", "120"}
            };
            return new ConfigurationBuilder()
                .AddInMemoryCollection(inMemorySettings)
                .Build();
        }

        [Fact]
        public void VerifyPassword_Should_Match_HashedPassword()
        {
            // Arrange
            var config = GetMockConfig();
            var service = new SecurityService(config);
            string rawPassword = "StrongPassword123!";
            
            // Act
            string hash = service.HashPassword(rawPassword);
            bool isMatch = service.VerifyPassword(rawPassword, hash);
            
            // Assert
            Assert.True(isMatch);
        }
    }
}
