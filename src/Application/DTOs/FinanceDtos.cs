using System;

namespace ConstructionManagement.Application.DTOs
{
    public class PaymentPlanItemDto
    {
        public Guid PaymentPlanItemId { get; set; }
        public string Name { get; set; }
        public decimal? Amount { get; set; }
        public decimal? Percentage { get; set; }
        public decimal PaidAmount { get; set; }
        public byte Status { get; set; }
        public DateTime? DueDate { get; set; }
    }

    public class CustomerPaymentDto
    {
        public Guid PaymentId { get; set; }
        public Guid ProjectId { get; set; }
        public decimal Amount { get; set; }
        public string PaymentNumber { get; set; }
        public DateTime PaymentDate { get; set; }
        public byte PaymentMethod { get; set; }
        public byte Status { get; set; }
    }
}
