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
