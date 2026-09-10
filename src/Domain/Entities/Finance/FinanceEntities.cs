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
