using System;
using System.IO;
using System.Threading.Tasks;
using ConstructionManagement.Application.Interfaces;
using Microsoft.Extensions.Configuration;

namespace ConstructionManagement.Infrastructure.Services
{
    public class LocalFileStorageService : IFileStorage
    {
        private readonly string _basePath;
        public LocalFileStorageService(IConfiguration config)
        {
            _basePath = config["FileStorage:BasePath"] ?? "Uploads";
            if (!Directory.Exists(_basePath)) Directory.CreateDirectory(_basePath);
        }

        public async Task<string> SaveFileAsync(byte[] content, string fileName, string path)
        {
            var fullPath = Path.Combine(_basePath, path);
            if (!Directory.Exists(fullPath)) Directory.CreateDirectory(fullPath);
            var filePath = Path.Combine(fullPath, fileName);
            await File.WriteAllBytesAsync(filePath, content);
            return Path.Combine(path, fileName).Replace("\\", "/");
        }

        public async Task<byte[]> GetFileAsync(string filePath)
        {
            var fullPath = Path.Combine(_basePath, filePath);
            if (File.Exists(fullPath)) return await File.ReadAllBytesAsync(fullPath);
            return null;
        }
    }

    public class MockPaymentGateway : IPaymentGateway
    {
        public Task<string> CreateTransactionAsync(decimal amount, string currency, string reference) => Task.FromResult(Guid.NewGuid().ToString());
        public Task<bool> VerifyTransactionAsync(string transactionId) => Task.FromResult(true);
    }

    public class MockWhatsAppProvider : IWhatsAppProvider
    {
        public Task<bool> SendMessageAsync(string phone, string message) => Task.FromResult(true);
    }
}
