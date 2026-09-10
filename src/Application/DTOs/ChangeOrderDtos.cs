using System;

namespace ConstructionManagement.Application.DTOs
{
    public class ChangeOrderDto
    {
        public Guid ChangeOrderId { get; set; }
        public Guid ProjectId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public decimal AmountChange { get; set; }
        public int DurationChangeDays { get; set; }
        public byte Status { get; set; } 
        public DateTime CreatedAtUtc { get; set; }
        public Guid? ApprovedBy { get; set; }
        public DateTime? ApprovedAtUtc { get; set; }
    }
    
    public class ApproveChangeOrderRequest
    {
        public Guid ChangeOrderId { get; set; }
        public string Notes { get; set; }
    }
}
