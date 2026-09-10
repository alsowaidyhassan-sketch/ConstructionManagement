using System.Threading.Tasks;

namespace ConstructionManagement.Application.Interfaces
{
    public interface IPaymentGateway
    {
        Task<PaymentGatewayResult> ProcessPaymentAsync(decimal amount, string currency, string reference);
        Task<bool> VerifyWebhookSignatureAsync(string payload, string signature);
    }
    
    public class PaymentGatewayResult
    {
        public bool IsSuccess { get; set; }
        public string TransactionId { get; set; }
        public string ErrorMessage { get; set; }
        public string RedirectUrl { get; set; }
    }
}
