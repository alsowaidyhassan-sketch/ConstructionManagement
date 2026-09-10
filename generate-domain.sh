#!/bin/bash

mkdir -p src/Domain/Entities/Security
mkdir -p src/Domain/Entities/Core
mkdir -p src/Domain/Entities/Projects
mkdir -p src/Domain/Entities/Finance
mkdir -p src/Domain/Entities/Files
mkdir -p src/Domain/Entities/System

# Cleanup old entity files to start fresh
rm -f src/Domain/Entities/*.cs

cat << 'CS' > src/Domain/Entities/Core/Company.cs
using System;
using System.Collections.Generic;

namespace ConstructionManagement.Domain.Entities.Core
{
    public class Company
    {
        public Guid CompanyId { get; set; }
        public string Name { get; set; }
        public string CommercialRecord { get; set; }
        public string TaxNumber { get; set; }
        public string Address { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAtUtc { get; set; }

        public ICollection<Branch> Branches { get; set; }
    }

    public class Branch
    {
        public Guid BranchId { get; set; }
        public Guid CompanyId { get; set; }
        public string Name { get; set; }
        public string Location { get; set; }
        public bool IsActive { get; set; }

        public Company Company { get; set; }
    }
}
CS

cat << 'CS' > src/Domain/Entities/Security/SecurityEntities.cs
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
CS

cat << 'CS' > src/Domain/Entities/Core/Customer.cs
using System;
using System.Collections.Generic;
using ConstructionManagement.Domain.Entities.Projects;

namespace ConstructionManagement.Domain.Entities.Core
{
    public class Customer
    {
        public Guid CustomerId { get; set; }
        public Guid CompanyId { get; set; }
        public string CustomerCode { get; set; }
        public string FullNameAr { get; set; }
        public string Phone { get; set; }
        public string WhatsAppNumber { get; set; }
        public string Email { get; set; }
        public string Address { get; set; }
        public string IdentityNumber { get; set; }
        public string Notes { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAtUtc { get; set; }

        public Company Company { get; set; }
        public ICollection<Project> Projects { get; set; }
    }
}
CS

cat << 'CS' > src/Domain/Entities/Core/Contractor.cs
using System;
using System.Collections.Generic;
using ConstructionManagement.Domain.Entities.Projects;

namespace ConstructionManagement.Domain.Entities.Core
{
    public class Contractor
    {
        public Guid ContractorId { get; set; }
        public Guid CompanyId { get; set; }
        public string Name { get; set; }
        public string ContactPerson { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string Specialization { get; set; }
        public bool IsActive { get; set; }

        public Company Company { get; set; }
        public ICollection<Project> Projects { get; set; } // The projects they are assigned to
    }
}
CS

cat << 'CS' > src/Domain/Entities/Projects/ProjectEntities.cs
using System;
using System.Collections.Generic;
using ConstructionManagement.Domain.Entities.Core;
using ConstructionManagement.Domain.Entities.Finance;
using ConstructionManagement.Domain.Entities.Files;

namespace ConstructionManagement.Domain.Entities.Projects
{
    public class ProjectType
    {
        public Guid ProjectTypeId { get; set; }
        public Guid CompanyId { get; set; }
        public string Name { get; set; }
    }

    public class Project
    {
        public Guid ProjectId { get; set; }
        public Guid CompanyId { get; set; }
        public Guid BranchId { get; set; }
        public Guid CustomerId { get; set; }
        public Guid? ProjectTypeId { get; set; }
        public Guid? ContractorId { get; set; } // Max 1 contractor as per requirements

        public string ProjectCode { get; set; }
        public string ProjectName { get; set; }
        public string Address { get; set; }
        public string Description { get; set; }
        
        public DateTime? StartDate { get; set; }
        public DateTime? PlannedEndDate { get; set; }
        public DateTime? ActualEndDate { get; set; }
        
        public byte Status { get; set; } // 1: Planning, 2: Active, 3: Suspended, 4: Completed, 5: Cancelled
        
        public decimal InitialContractValue { get; set; }
        public decimal CurrentContractValue { get; set; }
        
        public byte ContractorCompensationType { get; set; } // 1: Percentage, 2: Fixed, 3: Stage Based
        public decimal ContractorCompensationValue { get; set; } // E.g. 15 for 15% or 50000 for Fixed
        
        public decimal OverallProgressPercent { get; set; }
        public byte ProgressCalculationMode { get; set; } // 1: Manual, 2: Weighted, 3: Average

        public bool IsArchived { get; set; }
        public string Notes { get; set; }
        public DateTime CreatedAtUtc { get; set; }
        public Guid CreatedBy { get; set; }

        public Company Company { get; set; }
        public Branch Branch { get; set; }
        public Customer Customer { get; set; }
        public ProjectType ProjectType { get; set; }
        public Contractor Contractor { get; set; }
        
        public ICollection<ProjectStage> Stages { get; set; }
        public ICollection<CustomerPayment> CustomerPayments { get; set; }
        public ICollection<ContractorPayment> ContractorPayments { get; set; }
        public ICollection<Expense> Expenses { get; set; }
        public ICollection<ProgressUpdate> ProgressUpdates { get; set; }
        public ICollection<ChangeOrder> ChangeOrders { get; set; }
        public ICollection<Document> Documents { get; set; }
        public ICollection<Contract> Contracts { get; set; }
        public ICollection<PaymentPlanItem> PaymentPlanItems { get; set; }
        public ICollection<ProjectNote> ProjectNotes { get; set; }
    }

    public class ProjectStage
    {
        public Guid StageId { get; set; }
        public Guid ProjectId { get; set; }
        public Guid? ParentStageId { get; set; } // Null if Main Stage
        public string Name { get; set; }
        public string Description { get; set; }
        public int SortOrder { get; set; }
        
        // For ProgressCalculationMode = Weighted
        public decimal Weight { get; set; } 
        
        public DateTime? PlannedStart { get; set; }
        public DateTime? PlannedEnd { get; set; }
        public DateTime? ActualStart { get; set; }
        public DateTime? ActualEnd { get; set; }
        
        public decimal ProgressPercent { get; set; }
        public byte Status { get; set; } // 1: Pending, 2: InProgress, 3: Completed
        public bool IsCustomerVisible { get; set; }
        
        public Project Project { get; set; }
        public ProjectStage ParentStage { get; set; }
        public ICollection<ProjectStage> SubStages { get; set; }
        public ICollection<WorkItem> WorkItems { get; set; }
    }

    public class WorkItem
    {
        public Guid WorkItemId { get; set; }
        public Guid StageId { get; set; }
        public string Name { get; set; }
        public decimal Quantity { get; set; }
        public string Unit { get; set; }
        public decimal UnitCost { get; set; }
        public decimal TotalCost { get; set; }
        public decimal ProgressPercent { get; set; }
        public decimal Weight { get; set; } // Relative to Stage

        public ProjectStage Stage { get; set; }
    }

    public class ProgressUpdate
    {
        public Guid ProgressUpdateId { get; set; }
        public Guid ProjectId { get; set; }
        public Guid? StageId { get; set; }
        public Guid? WorkItemId { get; set; }
        
        public decimal ProgressPercent { get; set; }
        public string Description { get; set; }
        public string Notes { get; set; }
        public DateTime UpdateDate { get; set; }
        public Guid CreatedBy { get; set; }

        public Project Project { get; set; }
        public ProjectStage Stage { get; set; }
        public WorkItem WorkItem { get; set; }
        public ICollection<ProgressUpdateImage> Images { get; set; } // Max 5 enforced in Service
    }

    public class Contract
    {
        public Guid ContractId { get; set; }
        public Guid ProjectId { get; set; }
        public string ContractNumber { get; set; }
        public decimal OriginalValue { get; set; }
        public decimal CurrentValue { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string Terms { get; set; }
        public string Notes { get; set; }
        public byte Status { get; set; } // 1: Draft, 2: Active, 3: Completed, 4: Terminated

        public Project Project { get; set; }
        public ICollection<ContractVersion> Versions { get; set; }
    }

    public class ContractVersion
    {
        public Guid VersionId { get; set; }
        public Guid ContractId { get; set; }
        public int VersionNumber { get; set; }
        public string ChangeDescription { get; set; }
        public decimal Value { get; set; }
        public DateTime CreatedAtUtc { get; set; }
        public Guid CreatedBy { get; set; }

        public Contract Contract { get; set; }
    }

    public class ChangeOrder
    {
        public Guid ChangeOrderId { get; set; }
        public Guid ProjectId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public decimal AmountChange { get; set; }
        public int DurationChangeDays { get; set; }
        public byte Status { get; set; } // 1: Draft, 2: Pending Approval, 3: Approved, 4: Rejected, 5: Cancelled
        public DateTime CreatedAtUtc { get; set; }
        public Guid CreatedBy { get; set; }
        public Guid? ApprovedBy { get; set; }
        public DateTime? ApprovedAtUtc { get; set; }

        public Project Project { get; set; }
    }

    public class ProjectNote
    {
        public Guid NoteId { get; set; }
        public Guid ProjectId { get; set; }
        public string NoteText { get; set; }
        public bool IsCustomerVisible { get; set; }
        public DateTime CreatedAtUtc { get; set; }
        public Guid CreatedBy { get; set; }

        public Project Project { get; set; }
    }
}
CS

cat << 'CS' > src/Domain/Entities/Finance/FinanceEntities.cs
using System;
using ConstructionManagement.Domain.Entities.Core;
using ConstructionManagement.Domain.Entities.Projects;
using ConstructionManagement.Domain.Entities.Files;

namespace ConstructionManagement.Domain.Entities.Finance
{
    public class PaymentPlanItem
    {
        public Guid PaymentPlanItemId { get; set; }
        public Guid ProjectId { get; set; }
        public Guid? StageId { get; set; } // If Stage based
        public string Name { get; set; }
        public DateTime? DueDate { get; set; }
        public decimal? Amount { get; set; } // Can be fixed
        public decimal? Percentage { get; set; } // Or Percentage of Contract
        public decimal PaidAmount { get; set; }
        public byte Status { get; set; } // 1: Pending, 2: Partial, 3: Paid

        public Project Project { get; set; }
        public ProjectStage Stage { get; set; }
    }

    public class CustomerPayment
    {
        public Guid PaymentId { get; set; }
        public Guid ProjectId { get; set; }
        public Guid CustomerId { get; set; }
        public Guid? PaymentPlanItemId { get; set; } // Links to the schedule
        public string PaymentNumber { get; set; }
        public decimal Amount { get; set; }
        public DateTime PaymentDate { get; set; }
        public byte PaymentMethod { get; set; } // 1: Cash, 2: Bank Transfer, 3: Electronic, 4: Card
        public string Reference { get; set; } // Bank trans ID or Gateway ID
        public string Notes { get; set; }
        public byte Status { get; set; } // 1: Pending Verification, 2: Confirmed, 3: Rejected, 4: Reversed
        public Guid? ReceiptDocumentId { get; set; }
        public Guid CreatedBy { get; set; }
        public DateTime CreatedAtUtc { get; set; }

        public Project Project { get; set; }
        public Customer Customer { get; set; }
        public PaymentPlanItem PaymentPlanItem { get; set; }
        public Document ReceiptDocument { get; set; }
    }

    public class ContractorPayment
    {
        public Guid PaymentId { get; set; }
        public Guid ProjectId { get; set; }
        public Guid ContractorId { get; set; }
        public string PaymentNumber { get; set; }
        public decimal Amount { get; set; }
        public DateTime PaymentDate { get; set; }
        public byte PaymentMethod { get; set; }
        public string Reference { get; set; }
        public string Notes { get; set; }
        public Guid CreatedBy { get; set; }

        public Project Project { get; set; }
        public Contractor Contractor { get; set; }
    }

    public class ExpenseType
    {
        public Guid ExpenseTypeId { get; set; }
        public Guid CompanyId { get; set; }
        public string Name { get; set; }
    }

    public class Expense
    {
        public Guid ExpenseId { get; set; }
        public Guid CompanyId { get; set; }
        public Guid? ProjectId { get; set; } // Null means Company Overhead Expense
        public Guid ExpenseTypeId { get; set; }
        
        public decimal Amount { get; set; }
        public DateTime ExpenseDate { get; set; }
        public byte PaymentMethod { get; set; }
        public string Payee { get; set; }
        public string Reference { get; set; }
        public string Notes { get; set; }
        public Guid? ReceiptDocumentId { get; set; }
        public Guid CreatedBy { get; set; }

        public Company Company { get; set; }
        public Project Project { get; set; }
        public ExpenseType ExpenseType { get; set; }
        public Document ReceiptDocument { get; set; }
    }
}
CS

cat << 'CS' > src/Domain/Entities/Files/FileEntities.cs
using System;
using ConstructionManagement.Domain.Entities.Projects;
using ConstructionManagement.Domain.Entities.Core;
using ConstructionManagement.Domain.Entities.Security;

namespace ConstructionManagement.Domain.Entities.Files
{
    public class Document
    {
        public Guid DocumentId { get; set; }
        public Guid CompanyId { get; set; }
        public Guid? ProjectId { get; set; }
        public Guid? CustomerId { get; set; }
        
        public string FileName { get; set; }
        public string OriginalFileName { get; set; }
        public string ContentType { get; set; }
        public long FileSizeBytes { get; set; }
        public string StoragePath { get; set; }
        
        public byte DocumentType { get; set; } // 1: General, 2: Contract, 3: Receipt, 4: Change Order
        public bool IsCustomerVisible { get; set; }
        
        public DateTime UploadedAtUtc { get; set; }
        public Guid UploadedBy { get; set; }

        public Company Company { get; set; }
        public Project Project { get; set; }
        public Customer Customer { get; set; }
        public User Uploader { get; set; }
    }

    public class ProgressUpdateImage
    {
        public Guid ProgressUpdateImageId { get; set; }
        public Guid ProgressUpdateId { get; set; }
        public string StoragePath { get; set; }
        public string ThumbnailPath { get; set; }
        public long FileSizeBytes { get; set; }

        public ProgressUpdate ProgressUpdate { get; set; }
    }
}
CS

cat << 'CS' > src/Domain/Entities/System/SystemEntities.cs
using System;
using ConstructionManagement.Domain.Entities.Security;
using ConstructionManagement.Domain.Entities.Projects;

namespace ConstructionManagement.Domain.Entities.System
{
    public class Notification
    {
        public Guid NotificationId { get; set; }
        public Guid UserId { get; set; }
        public Guid? ProjectId { get; set; }
        public string Title { get; set; }
        public string Message { get; set; }
        public byte Type { get; set; } // 1: Progress, 2: Payment, 3: Change Order, 4: Document
        public bool IsRead { get; set; }
        public DateTime CreatedAtUtc { get; set; }

        public User User { get; set; }
        public Project Project { get; set; }
    }

    public class WhatsAppMessageLog
    {
        public Guid LogId { get; set; }
        public string RecipientPhone { get; set; }
        public string MessageBody { get; set; }
        public string TemplateName { get; set; }
        public bool IsSuccess { get; set; }
        public string ErrorMessage { get; set; }
        public DateTime SentAtUtc { get; set; }
    }
}
CS

