using System;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace ConstructionManagement.Application.Interfaces
{
    public interface IFileStorage
    {
        Task<string> SaveFileAsync(byte[] content, string fileName, string path);
        Task<byte[]> GetFileAsync(string filePath);
    }
    
    public interface IPaymentGateway
    {
        Task<string> CreateTransactionAsync(decimal amount, string currency, string reference);
        Task<bool> VerifyTransactionAsync(string transactionId);
    }

    public interface IWhatsAppProvider
    {
        Task<bool> SendMessageAsync(string phone, string message);
    }
}
