using System;
using System.Collections.Generic;
using ConstructionManagement.Domain.Entities.Core;

namespace ConstructionManagement.Domain.Entities.Security
{
    public class User
    {
        public Guid UserId { get; set; }
        public Guid? CompanyId { get; set; }
        public Guid? BranchId { get; set; }
        public Guid? CustomerId { get; set; }
        public string UserName { get; set; }
        public string NormalizedUserName { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public string FullNameAr { get; set; }
        public byte UserType { get; set; } // 1: Employee, 2: Customer, 3: Contractor
        public bool IsActive { get; set; }
        public int FailedLoginAttempts { get; set; }
        public DateTime? LockoutEndUtc { get; set; }
        public DateTime CreatedAtUtc { get; set; }

        public Company Company { get; set; }
        public Branch Branch { get; set; }
        public Customer Customer { get; set; }
        public ICollection<UserRole> UserRoles { get; set; }
    }

    public class Role
    {
        public Guid RoleId { get; set; }
        public Guid? CompanyId { get; set; } // Null for system roles
        public string Name { get; set; }
        public string NormalizedName { get; set; }

        public ICollection<UserRole> UserRoles { get; set; }
        public ICollection<RolePermission> RolePermissions { get; set; }
    }

    public class UserRole
    {
        public Guid UserId { get; set; }
        public Guid RoleId { get; set; }

        public User User { get; set; }
        public Role Role { get; set; }
    }

    public class Permission
    {
        public Guid PermissionId { get; set; }
        public string SystemName { get; set; } // e.g., "Projects.View", "Projects.Create"
        public string DisplayName { get; set; }
        public string Group { get; set; }

        public ICollection<RolePermission> RolePermissions { get; set; }
    }

    public class RolePermission
    {
        public Guid RoleId { get; set; }
        public Guid PermissionId { get; set; }

        public Role Role { get; set; }
        public Permission Permission { get; set; }
    }

    public class AuditLog
    {
        public Guid AuditLogId { get; set; }
        public Guid? UserId { get; set; }
        public Guid? CompanyId { get; set; }
        public string Action { get; set; }
        public string EntityName { get; set; }
        public string EntityId { get; set; }
        public string Details { get; set; }
        public string IpAddress { get; set; }
        public DateTime TimestampUtc { get; set; }
    }
}
