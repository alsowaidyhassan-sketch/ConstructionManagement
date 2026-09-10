using System.Threading.Tasks;

namespace ConstructionManagement.Application.Interfaces
{
    public interface IWhatsAppProvider
    {
        Task<bool> SendMessageAsync(string phoneNumber, string message);
        Task<bool> SendTemplateMessageAsync(string phoneNumber, string templateCode, object parameters);
    }
}
