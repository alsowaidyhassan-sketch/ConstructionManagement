using System;

namespace ConstructionManagement.Domain.Entities
{
    public class CustomerPayment
    {
        public Guid PaymentId { get; set; }
        public Guid CompanyId { get; set; }
        public Guid ProjectId { get; set; }
        public Guid CustomerId { get; set; }
        public string PaymentNumber { get; set; }
        public DateTime PaymentDate { get; set; }
        public decimal Amount { get; set; }
        public string CurrencyCode { get; set; }
        public byte PaymentMethodId { get; set; }
        public string GatewayTransactionId { get; set; }
        public byte Status { get; set; } // 1 Pending, 2 Confirmed, 3 Rejected
    }
}
