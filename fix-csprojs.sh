#!/bin/bash

# Infrastructure csproj
cat << 'PROJ' > src/Infrastructure/ConstructionManagement.Infrastructure.csproj
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="BCrypt.Net-Next" Version="4.0.3" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="8.0.2" />
    <PackageReference Include="System.IdentityModel.Tokens.Jwt" Version="7.4.0" />
  </ItemGroup>
  <ItemGroup>
    <ProjectReference Include="..\Domain\ConstructionManagement.Domain.csproj" />
    <ProjectReference Include="..\Application\ConstructionManagement.Application.csproj" />
  </ItemGroup>
</Project>
PROJ

# Domain csproj
cat << 'PROJ' > src/Domain/ConstructionManagement.Domain.csproj
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
</Project>
PROJ

# Application csproj
cat << 'PROJ' > src/Application/ConstructionManagement.Application.csproj
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
  <ItemGroup>
    <ProjectReference Include="..\Domain\ConstructionManagement.Domain.csproj" />
  </ItemGroup>
</Project>
PROJ

# Api csproj
cat << 'PROJ' > src/Api/ConstructionManagement.Api/ConstructionManagement.Api.csproj
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.Authentication.JwtBearer" Version="8.0.2" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="8.0.2">
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
      <PrivateAssets>all</PrivateAssets>
    </PackageReference>
    <PackageReference Include="Swashbuckle.AspNetCore" Version="6.4.0" />
  </ItemGroup>
  <ItemGroup>
    <ProjectReference Include="..\..\Application\ConstructionManagement.Application.csproj" />
    <ProjectReference Include="..\..\Infrastructure\ConstructionManagement.Infrastructure.csproj" />
  </ItemGroup>
</Project>
PROJ

