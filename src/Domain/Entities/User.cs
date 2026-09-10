using System;

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
        public string Phone { get; set; }
        public string PasswordHash { get; set; }
        public string FullNameAr { get; set; }
        public string FullNameEn { get; set; }
        public byte UserType { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAtUtc { get; set; }
    }
}
