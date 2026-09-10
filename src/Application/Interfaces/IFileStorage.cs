using System.Threading.Tasks;
namespace ConstructionManagement.Application.Interfaces
{
    public interface IFileStorage
    {
        Task<string> SaveFileAsync(byte[] content, string fileName, string path);
        Task<byte[]> GetFileAsync(string filePath);
    }
}
