using System;
using System.Collections.Generic;

namespace ConstructionManagement.Domain.Entities
{
    public class User
    {
        public Guid UserId { get; set; }
        public Guid? CompanyId { get; set; }
        public Guid? CustomerId { get; set; }
        public string UserName { get; set; }
        public string NormalizedUserName { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public string FullNameAr { get; set; }
        public byte UserType { get; set; } // 1: Company, 2: Customer
        public bool IsActive { get; set; }
        public DateTime CreatedAtUtc { get; set; }
        
        public Customer Customer { get; set; }
    }

    public class Customer
    {
        public Guid CustomerId { get; set; }
        public Guid CompanyId { get; set; }
        public string CustomerCode { get; set; }
        public string FullNameAr { get; set; }
        public string Phone { get; set; }
        public string WhatsAppNumber { get; set; }
        public string Email { get; set; }
        public bool IsActive { get; set; }
        
        public ICollection<Project> Projects { get; set; }
    }

    public class Project
    {
        public Guid ProjectId { get; set; }
        public Guid CompanyId { get; set; }
        public Guid CustomerId { get; set; }
        public string ProjectCode { get; set; }
        public string ProjectName { get; set; }
        public decimal OverallProgressPercent { get; set; }
        public decimal? CurrentContractValue { get; set; }
        public bool IsArchived { get; set; }
        
        public Customer Customer { get; set; }
        public ICollection<ProjectStage> Stages { get; set; }
        public ICollection<CustomerPayment> Payments { get; set; }
        public ICollection<ProgressUpdate> ProgressUpdates { get; set; }
    }

    public class ProjectStage
    {
        public Guid StageId { get; set; }
        public Guid ProjectId { get; set; }
        public string StageNameAr { get; set; }
        public decimal ProgressPercent { get; set; }
        public int SortOrder { get; set; }
        public Project Project { get; set; }
    }

    public class ProgressUpdate
    {
        public Guid ProgressUpdateId { get; set; }
        public Guid ProjectId { get; set; }
        public decimal ProgressPercent { get; set; }
        public string Description { get; set; }
        public DateTime UpdateDate { get; set; }
        public Project Project { get; set; }
        public ICollection<ProgressUpdateImage> Images { get; set; }
    }

    public class ProgressUpdateImage
    {
        public Guid ProgressUpdateImageId { get; set; }
        public Guid ProgressUpdateId { get; set; }
        public string StoragePath { get; set; }
        public ProgressUpdate ProgressUpdate { get; set; }
    }

    public class CustomerPayment
    {
        public Guid PaymentId { get; set; }
        public Guid ProjectId { get; set; }
        public Guid CustomerId { get; set; }
        public string PaymentNumber { get; set; }
        public decimal Amount { get; set; }
        public DateTime PaymentDate { get; set; }
        public byte Status { get; set; } // 1: Pending, 2: Confirmed, 3: Rejected
        
        public Project Project { get; set; }
        public Customer Customer { get; set; }
    }
}
