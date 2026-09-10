using System;
using System.Collections.Generic;

namespace ConstructionManagement.Domain.Entities
{
    public class ChangeOrder
    {
        public Guid ChangeOrderId { get; set; }
        public Guid ProjectId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public decimal AmountChange { get; set; }
        public int DurationChangeDays { get; set; }
        public byte Status { get; set; } // 1: Draft, 2: Pending, 3: Approved, 4: Rejected
        public DateTime CreatedAtUtc { get; set; }
        
        public Project Project { get; set; }
    }

    public class Expense
    {
        public Guid ExpenseId { get; set; }
        public Guid? ProjectId { get; set; } // Null means Company Expense
        public string Category { get; set; }
        public decimal Amount { get; set; }
        public DateTime ExpenseDate { get; set; }
        public string Notes { get; set; }
        
        public Project Project { get; set; }
    }

    public class Document
    {
        public Guid DocumentId { get; set; }
        public Guid? ProjectId { get; set; }
        public Guid? CustomerId { get; set; }
        public string FileName { get; set; }
        public string StoragePath { get; set; }
        public bool IsCustomerVisible { get; set; }
        
        public Project Project { get; set; }
    }
    
    public class AuditLog
    {
        public Guid AuditLogId { get; set; }
        public Guid UserId { get; set; }
        public string Action { get; set; }
        public string EntityName { get; set; }
        public string Details { get; set; }
        public DateTime TimestampUtc { get; set; }
    }
}
