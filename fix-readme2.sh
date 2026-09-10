#!/bin/bash
cat << 'README' > README.md
# Construction Management System (CMS) - Production Ready

نظام متكامل واحترافي لإدارة شركات البناء والمقاولات، مصمم ببنية معمارية نظيفة (Clean Architecture) وتم تصميمه ليكون **Production-Ready**.

## 🏗 البنية المعمارية (Architecture)

1. **قاعدة البيانات:** SQL Server مع Entity Framework Core (EF Core Migrations).
2. **الـ Backend API:** ASP.NET Core 8 Web API. (يحوي Authentication حقيقي عبر JWT و BCrypt Hash).
3. **تطبيق سطح المكتب للموظفين:** VB.NET Windows Forms مبني على `.NET Framework 4.8` بواجهة MaterialSkin قابلة للتصميم في الـ Designer.
4. **تطبيق الهاتف للعملاء:** .NET MAUI (Android & iOS).

## 🔒 الأمن (Security & Isolation)
- تم نقل الـ **JWT Secret** إلى `appsettings.json` لمنع تخزينه في الكود الصلب.
- تم تطبيق العزل الأمني التام للعملاء (Customer Isolation) في **كل الـ Endpoints**.
- يتم قراءة `CustomerId` من الـ JWT Token المولد من الـ API (`DashboardController.cs`, `ProjectsController.cs`, إلخ).
- تشفير قوي لكلمات المرور باستخدام `BCrypt`.
- تم تحديد الصور المرفوعة للمراحل بـ 5 صور كحد أقصى (مطبقة في Controller + Unit Test).

## 🗂 الهيكلة المتقدمة والكود النظيف (Clean Code & DTOs)
- الـ Controllers لا تتعامل مع Entities قاعدة البيانات بشكل مباشر؛ تم إعداد `DTOs` لنقل البيانات.
- تم تطبيق (Dependency Injection) بالكامل لجميع الخدمات: `IFileStorage` (للملفات السحابية/المحلية)، `IPaymentGateway` (للدفع الإلكتروني)، و `IWhatsAppProvider` (لإرسال الرسائل).

## 💻 تطبيق سطح المكتب (.NET 4.8 VB.NET)
- كافة الواجهات متوافقة ومصممة برمجياً للعمل مع الـ Designer. 
- أضفنا `DashboardForm` متكاملة تتصل بالـ API عبر `ApiClient.vb` وتجلب إجمالي المقبوضات والمشاريع بشكل حي.

## 📱 تطبيق الهاتف (MAUI)
- تم تطوير `ProjectDetailsPage` لتكون Comprehensive Page للعميل (تعرض التايم لاين، الدفعات، صور الإنجاز، وأوامر التغيير الخاصة بمشروعه فقط).

## 🚀 دليل التشغيل (EF Core Migrations)
لأن النظام يعتمد على EF Core، لا تحتاج إلى تنفيذ أي سكربت SQL يدوياً:
1. افتح الـ Solution في **Visual Studio 2022**.
2. افتح الـ Package Manager Console واكتب `Update-Database` لتوليد القاعدة.

## 🧪 الاختبارات (Unit Tests)
- تمت إضافة اختبارات قوية للـ (Customer Isolation) لمنع تسريب بيانات العملاء.
- اختبارات لمنع تجاوز الحد الأقصى من صور تقدم المشروع (5 صور).
- اختبارات لمعادلة احتساب الأرباح (قيمة العقد - مصاريف المشروع - دفعات المقاول).
README
