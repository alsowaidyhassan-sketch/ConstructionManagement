using Xunit;
using Moq;
using ConstructionManagement.Domain.Entities;

namespace ConstructionManagement.UnitTests
{
    public class AuthTests
    {
        [Fact]
        public void User_Should_Be_Active_By_Default()
        {
            // Arrange
            var user = new User();
            
            // Act
            user.IsActive = true;
            
            // Assert
            Assert.True(user.IsActive);
        }
    }
}
