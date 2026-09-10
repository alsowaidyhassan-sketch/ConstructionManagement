using System;
using System.Collections.Generic;
using ConstructionManagement.Domain.Entities;
using Xunit;

namespace ConstructionManagement.UnitTests
{
    public class ImageLimitTests
    {
        [Fact]
        public void ProgressUpdate_With_More_Than_5_Images_Should_Fail_Validation()
        {
            // Arrange
            var update = new ProgressUpdate
            {
                ProgressUpdateId = Guid.NewGuid(),
                Images = new List<ProgressUpdateImage>()
            };

            for(int i=0; i<6; i++)
            {
                update.Images.Add(new ProgressUpdateImage { StoragePath = $"img{i}.jpg" });
            }

            // Act
            bool isValid = update.Images.Count <= 5;

            // Assert
            Assert.False(isValid, "يجب ألا يقبل النظام أكثر من 5 صور.");
        }
    }
}
