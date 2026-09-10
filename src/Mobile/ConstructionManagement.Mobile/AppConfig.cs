namespace ConstructionManagement.Mobile
{
    public static class AppConfig
    {
        // Should be loaded from preferences or environment, not hardcoded to localhost in production
        public static string ApiBaseUrl { get; set; } = "https://api.yourdomain.com/api/v1/";
    }
}
