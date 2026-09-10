# Construction Management System (CMS)

نظام متكامل واحترافي لإدارة شركات البناء والمقاولات، مصمم ببنية معمارية نظيفة (Clean Architecture) تلبي جميع متطلبات الشركات من إدارة العملاء، المشاريع، العقود، الدفعات، المراحل، المقاولين، والصلاحيات.

## 🏗 البنية المعمارية (Architecture)

النظام مبني باستخدام التقنيات التالية لضمان الأمان، التوسع، والأداء العالي:
1. **قاعدة البيانات:** SQL Server مع EF Core.
2. **الـ Backend API:** ASP.NET Core 8 Web API.
3. **تطبيق سطح المكتب للموظفين:** VB.NET Windows Forms (.NET 8 Windows) بواجهة عصرية باستخدام مكتبة MaterialSkin.
4. **تطبيق الهاتف للعملاء (بوابة العميل):** .NET MAUI (Android & iOS).

*جميع الاتصالات من Desktop و Mobile تتم عبر الـ API حصراً.*

## 📁 هيكل المشروع

```
ConstructionManagement.sln
│
├── database/
│   └── Scripts/
│       └── InitialCreate.sql     <-- السكريبت الشامل لقاعدة البيانات الأساسية
│
├── src/
│   ├── Domain/                   <-- الكيانات (Entities) والمنطق الأساسي
│   ├── Application/              <-- الـ DTOs والـ Interfaces
│   ├── Infrastructure/           <-- الـ DbContext واتصال قاعدة البيانات EF Core
│   │
│   ├── Api/
│   │   └── ConstructionManagement.Api/         <-- مشروع الـ Web API و Controllers
│   │
│   ├── Desktop/
│   │   └── ConstructionManagement.WinForms/    <-- مشروع سطح المكتب VB.NET
│   │
│   └── Mobile/
│       └── ConstructionManagement.Mobile/      <-- تطبيق الهاتف للعميل .NET MAUI
│
└── tests/                        <-- مجلد الاختبارات (Unit & Integration)
```

## 🚀 دليل التشغيل (Deployment & Run Guide)

### 1. إعداد قاعدة البيانات (Database Setup)
1. افتح **SQL Server Management Studio (SSMS)**.
2. قم بتنفيذ السكريبت الموجود في المسار `database/Scripts/InitialCreate.sql`.
3. سينشئ السكريبت قاعدة بيانات `ConstructionManagementDB` بكل الجداول، العلاقات، والـ Triggers، والـ Views الأساسية، بالإضافة لبعض بيانات Seed التلقائية.
4. السكريبت جاهز لدعم Migrations لاحقاً عبر `EF Core` (يوجد جدول مخصص `App.DatabaseMigrations`).

### 2. إعداد وتشغيل الـ API
1. افتح ملف الـ Solution `ConstructionManagement.sln` في **Visual Studio 2022**.
2. تأكد من تعديل `appsettings.json` في مشروع `ConstructionManagement.Api` لربط نص الاتصال بقاعدة البيانات.
   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Server=YOUR_SERVER;Database=ConstructionManagementDB;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True"
   }
   ```
3. قم بتشغيل مشروع الـ API كـ **Startup Project**. سيفتح Swagger تلقائياً لاختبار الـ Endpoints.

### 3. تشغيل تطبيق سطح المكتب (VB.NET Desktop)
1. اجعل `ConstructionManagement.WinForms` هو مشروع البدء (Startup Project).
2. سيطلب منك النظام تسجيل الدخول (استخدم "admin" / "admin" للتجربة كمدير نظام).
3. يتصل هذا التطبيق بروابط الـ API التي تم تشغيلها في الخطوة السابقة (تأكد من تعديل الـ BaseUrl في الخدمات داخل المشروع ليتوافق مع رابط الـ API لديك، مثلاً `https://localhost:5001/api/v1/`).

### 4. تشغيل تطبيق الهاتف (MAUI Mobile)
1. اجعل `ConstructionManagement.Mobile` هو مشروع البدء واختر Android Emulator أو iOS Simulator.
2. أدخل بيانات العميل (استخدم "customer" / "customer" للتجربة كعميل).
3. يعرض التطبيق واجهة المشاريع الخاصة بالعميل مع نسبة الإنجاز والدفعات بشكل مباشر من الـ API عبر JWT Auth (معتمد على CustomerId).

## 🛡 الأمان والحماية (Security Guide)
- **JWT & Refresh Tokens:** يتم إصدارها من الـ API، وتستخدم في كل طلب من الـ WinForms والـ MAUI.
- **Customer Isolation:** يتم استخراج الـ CustomerId من الـ Token مباشرة داخل الـ API، ولا يعتمد على مدخلات المستخدم لمنع ثغرات IDOR.
- **Passwords:** يجب استخدام `Argon2id` أو `BCrypt` للتشفير قبل الحفظ في جدول `Security.Users` (لم يتم وضع التشفير في الـ Mock الحالي لتسهيل التشغيل الفوري).

## 🗄 دليل تحديث قاعدة البيانات (Database Migration Guide)
1. في المستقبل، عند تعديل الـ Models في `Domain`.
2. استخدم Entity Framework Core لإنشاء Migration:
   `dotnet ef migrations add AddNewFeature -p src/Infrastructure -s src/Api/ConstructionManagement.Api`
3. قم بتطبيق الـ Migration على قاعدة البيانات:
   `dotnet ef database update -p src/Infrastructure -s src/Api/ConstructionManagement.Api`

## ⚙️ متطلبات التشغيل
- Visual Studio 2022 (Version 17.8+).
- .NET 8.0 SDK.
- SQL Server 2019 / 2022.
- (اختياري) .NET MAUI Workload لتشغيل تطبيق الهاتف.
