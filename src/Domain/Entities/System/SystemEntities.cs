using System;
using ConstructionManagement.Domain.Entities.Security;
using ConstructionManagement.Domain.Entities.Projects;

namespace ConstructionManagement.Domain.Entities.System
{
    public class Notification
    {
        public Guid NotificationId { get; set; }
        public Guid UserId { get; set; }
        public Guid? ProjectId { get; set; }
        public string Title { get; set; }
        public string Message { get; set; }
        public byte Type { get; set; } // 1: Progress, 2: Payment, 3: Change Order, 4: Document
        public bool IsRead { get; set; }
        public DateTime CreatedAtUtc { get; set; }

        public User User { get; set; }
        public Project Project { get; set; }
    }

    public class WhatsAppMessageLog
    {
        public Guid LogId { get; set; }
        public string RecipientPhone { get; set; }
        public string MessageBody { get; set; }
        public string TemplateName { get; set; }
        public bool IsSuccess { get; set; }
        public string ErrorMessage { get; set; }
        public DateTime SentAtUtc { get; set; }
    }
}
