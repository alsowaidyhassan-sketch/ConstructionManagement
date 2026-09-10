using System;

namespace ConstructionManagement.Application.DTOs
{
    public class CustomerDto
    {
        public Guid CustomerId { get; set; }
        public string CustomerCode { get; set; }
        public string FullNameAr { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public bool IsActive { get; set; }
    }
    
    public class ContractorDto
    {
        public Guid ContractorId { get; set; }
        public string Name { get; set; }
        public string Specialization { get; set; }
        public bool IsActive { get; set; }
    }
}
