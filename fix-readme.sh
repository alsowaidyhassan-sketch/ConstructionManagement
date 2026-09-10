#!/bin/bash

cat << 'README' > README.md
# Construction Management System (CMS) - Production Ready

نظام متكامل واحترافي لإدارة شركات البناء والمقاولات، مصمم ببنية معمارية نظيفة (Clean Architecture) وتم تصميمه ليكون **Production-Ready**.

## 🏗 البنية المعمارية (Architecture)

1. **قاعدة البيانات:** SQL Server مع Entity Framework Core (EF Core Migrations).
2. **الـ Backend API:** ASP.NET Core 8 Web API. (يحوي Authentication حقيقي عبر JWT و BCrypt Hash).
3. **تطبيق سطح المكتب للموظفين:** VB.NET Windows Forms مبني على `.NET Framework 4.8` بواجهة MaterialSkin قابلة للتصميم في الـ Designer.
4. **تطبيق الهاتف للعملاء:** .NET MAUI (Android & iOS).

*جميع الاتصالات من Desktop و Mobile تتم عبر الـ API حصراً لمنع الوصول المباشر لقاعدة البيانات.*

## 🔒 الأمن (Security & Isolation)
- تم تطبيق العزل الأمني التام للعملاء (Customer Isolation).
- يتم قراءة `CustomerId` من الـ JWT Token المولد من الـ API (`ProjectsController.cs`).
- لا توجد أي بيانات دخول ثابتة (No Admin/Admin Hardcoded).
- تشفير قوي لكلمات المرور باستخدام `BCrypt`.
- تحديد الصور المرفوعة للمراحل بـ 5 صور كحد أقصى للطلب. (مطبقة في Controller + Unit Test).

## 🚀 دليل التشغيل

### 1. إعداد الـ Database (EF Core Migrations)
لأن النظام يعتمد على EF Core، لا تحتاج إلى تنفيذ أي سكربت SQL يدوياً:
1. افتح الـ Solution في **Visual Studio 2022**.
2. افتح الـ Package Manager Console.
3. اكتب الأمر `Update-Database` وتأكد أن المشروع الافتراضي هو `ConstructionManagement.Infrastructure`.
4. (اختياري) يمكنك توليد Migration جديد عبر `Add-Migration NewUpdate`.
5. النظام يحتوي على `DbInitializer` سيقوم بتوليد مستخدم "مدير النظام" بكلمة مرور `Admin@123` مشفرة.

### 2. إعداد الـ API
1. افتح ملف `appsettings.json` في مشروع `ConstructionManagement.Api`.
2. حدد نص الاتصال `DefaultConnection`.
3. قم بتشغيل مشروع الـ API لفتح واجهة Swagger وتجربة الـ Endpoints.

### 3. تطبيق سطح المكتب (VB.NET .NET 4.8)
1. اجعل `ConstructionManagement.WinForms` هو الـ Startup Project.
2. النظام سيعمل بتوافق كامل. تم بناء Class `ApiClient` للتعامل مع الـ JWT Tokens.
3. جميع النماذج (`.Designer.vb` و `.resx`) تم إنشاؤها لتدعم بيئة التصميم مباشرة في Visual Studio (RTL/Arabic).

### 4. تطبيق الهاتف (MAUI)
1. اجعل `ConstructionManagement.Mobile` هو مشروع البدء ليعمل على Android/iOS.
2. تم بناء صفحات `ProjectDetailsPage` و `PaymentsPage` متوافقة مع الـ API ومتطلبات العميل.

## 📦 التخزين والدفع والواتساب
- تم إعداد Interfaces جاهزة للربط: `IFileStorage` لربط تخزين سحابي، `IPaymentGateway` لبوابات الدفع الإلكتروني، و `IWhatsAppProvider` لتنبيهات الواتساب.

## 🧪 الاختبارات (Unit Tests)
- يوجد مشروع لاختبارات الـ Security والحد الأقصى للصور في `tests/ConstructionManagement.UnitTests`.
README
