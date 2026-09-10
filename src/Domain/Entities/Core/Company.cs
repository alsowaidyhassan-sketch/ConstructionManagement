using System;
using System.Collections.Generic;

namespace ConstructionManagement.Domain.Entities.Core
{
    public class Company
    {
        public Guid CompanyId { get; set; }
        public string Name { get; set; }
        public string CommercialRecord { get; set; }
        public string TaxNumber { get; set; }
        public string Address { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAtUtc { get; set; }

        public ICollection<Branch> Branches { get; set; }
    }

    public class Branch
    {
        public Guid BranchId { get; set; }
        public Guid CompanyId { get; set; }
        public string Name { get; set; }
        public string Location { get; set; }
        public bool IsActive { get; set; }

        public Company Company { get; set; }
    }
}
