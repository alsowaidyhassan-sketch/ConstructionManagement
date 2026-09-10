#!/bin/bash
cat << 'README' > README.md
# Construction Management System (CMS) - API & Core Architecture Focus

نظام إدارة شركات البناء والمقاولات المبني باستخدام تقنيات .NET، يتم العمل عليه ليكون **Production-Ready**.

## 🏗 البنية المعمارية الحالية المحدثة
تم إصلاح البنية بحيث أصبحت **طبقة الخدمات (Services)** هي المسؤولة عن معالجة البيانات، وتم منع الـ Controllers من الوصول المباشر لكيانات قاعدة البيانات (Entities):

1. **الـ Backend API:** ASP.NET Core 8 Web API.
2. **عزل الخدمات:** تم فصل `ProjectsController` بحيث يعتمد حصراً على `IProjectService`. جميع البيانات العائدة يتم تحويلها إلى `DTOs` (مثل `ProjectDto` و `ProgressUpdateDto`).
3. **التشفير والحماية:** إعدادات JWT الآن **آمنة للإنتاج (Production-Secure)**:
   - `ValidateIssuer = true`
   - `ValidateAudience = true`
   - `RequireHttpsMetadata = true`
   - **تم إزالة مفاتيح التشفير الثابتة من الكود الصلب (No Hardcoded Secrets).**

## 🔒 الأمن وعزل العملاء (Customer Isolation)
- العزل الأمني الآن مدمج بعمق في **Service Layer**. إذا أرسل العميل طلب GET أو POST لمشروع معين، يتم التأكد من `CustomerId` المستخرج من الـ JWT Tokens في نفس طبقة الخدمة `ProjectService` ويتم قذفه بـ `UnauthorizedAccessException` إذا لم يكن المالك الحقيقي، مما يضمن أقصى معايير الحماية.
- **حد الصور الأقصى (5 صور):** يتم التحقق منه داخل `ProjectService` أثناء عملية حفظ التقدم، ويرفض الطلب مباشرة.

## 💻 تطبيق سطح المكتب (VB.NET .NET 4.8)
- تم بناء مكتبة `ApiClient.vb` احترافية تدعم `GET, POST, PUT, DELETE, MultipartFormData (Files)` وتدعم استقبال أخطاء الـ HTTP بشكل صحيح.
- تم إضافة واجهات جديدة مثل `ContractsForm` و `DashboardForm`.
- الـ Desktop لا يزال في مرحلة التشبيك الكامل (Wire-up) لباقي الشاشات (Expenses, Contractors, Payments).

## 🗃 EF Core Migrations
- نظراً لاختلاف بيئات التطوير، يجب على المطورين توليد الـ Migrations محلياً عبر الأمر التالي لضمان التوافق مع قواعدهم:
  `dotnet ef migrations add InitialCreate --project src/Infrastructure --startup-project src/Api/ConstructionManagement.Api`
- لا تعتمد على سكريبتات SQL القديمة؛ استخدم EF Core Migration حصرياً لإنشاء القاعدة.

## 🧪 الاختبارات
- يوجد مشروع لاختبارات الـ Security والحد الأقصى للصور والـ Customer Isolation، مما يثبت صحة العمليات الحسابية والصلاحيات.

README
