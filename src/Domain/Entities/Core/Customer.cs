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
