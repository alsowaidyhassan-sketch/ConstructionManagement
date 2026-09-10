using System;

namespace ConstructionManagement.Domain.Entities
{
    public class Customer
    {
        public Guid CustomerId { get; set; }
        public Guid CompanyId { get; set; }
        public string CustomerCode { get; set; }
        public byte CustomerType { get; set; }
        public string FullNameAr { get; set; }
        public string FullNameEn { get; set; }
        public string Phone { get; set; }
        public string WhatsAppNumber { get; set; }
        public string Email { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAtUtc { get; set; }
    }
}
