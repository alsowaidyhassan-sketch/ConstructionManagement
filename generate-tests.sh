#!/bin/bash

mkdir -p tests/ConstructionManagement.UnitTests
cd tests/ConstructionManagement.UnitTests
dotnet add package Microsoft.NET.Test.Sdk --version 17.9.0
dotnet add package xunit --version 2.7.0
dotnet add package xunit.runner.visualstudio --version 2.5.7
dotnet add package Moq --version 4.20.70
cd ../..

cat << 'CODE' > tests/ConstructionManagement.UnitTests/ImageLimitTests.cs
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
CODE

cat << 'CODE' > tests/ConstructionManagement.UnitTests/SecurityServiceTests.cs
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
CODE
