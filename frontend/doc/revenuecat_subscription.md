# RevenueCat Frontend Implementation

[Return to Main Documentation](../../docs/revenuecat_subscription.md)

## 1. 前端实现 (Flutter)

> **⚠️ 国际化 (i18n) 规范**
>
> **所有用户可见的文本必须使用 i18n 方法**，禁止在代码中硬编码中文或英文字符串。
>
> - 使用 `context.l10n.xxx` 获取国际化文本
> - 在 `lib/l10n/intl_en.arb` 中定义 Key（英文先行）
> - 使用 LLM 翻译其他语言文件（如 `intl_zh.arb`）
>
> **正确示例：**
>
> ```dart
> // ✅ 正确：使用 i18n
> Text(context.l10n.subscription_purchaseSuccess)
> Text(context.l10n.subscription_purchaseFailed)
>
> // ❌ 错误：硬编码字符串
> Text('订阅成功！')
> Text('购买失败，请重试')
> ```
>
> 📖 详细规范请参考：[frontend/doc/i18n.md](i18n.md)

### 1.1 依赖配置

```yaml
# pubspec.yaml
dependencies:
  purchases_flutter: ^9.10.6 # 最新稳定版 (2026年1月)
```

### 1.2 RevenueCat 服务实现

#### 1.2.1 文件结构

```
frontend/lib/features/subscription/
├── data/
│   └── services/
│       └── revenue_cat_service.dart    # RevenueCat 服务
├── domain/
│   └── models/
│       └── subscription_tier.dart      # 订阅等级枚举
└── presentation/
    └── pages/
        └── paywall_screen.dart         # Paywall 页面
```

#### 1.2.2 订阅等级模型

```dart
// domain/models/subscription_tier.dart
enum SubscriptionTier {
  free,
  plus,
  pro,
}

extension SubscriptionTierExtension on SubscriptionTier {
  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.plus:
        return 'Plus';
      case SubscriptionTier.pro:
        return 'Pro';
    }
  }

  /// 检查是否有某个 tier 的权限（Pro 包含 Plus 的权限）
  bool hasAccess(SubscriptionTier requiredTier) {
    return index >= requiredTier.index;
  }

  /// 从字符串转换为枚举
  static SubscriptionTier fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pro':
        return SubscriptionTier.pro;
      case 'plus':
        return SubscriptionTier.plus;
      default:
        return SubscriptionTier.free;
    }
  }
}
```

#### 1.2.3 RevenueCat 服务

```dart
// data/services/revenue_cat_service.dart
import 'package:purchases_flutter/purchases_flutter.dart';

/// 购买结果枚举（内部使用，避免与 SDK 的 PurchaseResult 冲突）
enum SubscriptionPurchaseResult {
  success,
  cancelled,
  error,
}

class RevenueCatService extends ChangeNotifier {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;
  CustomerInfo? _customerInfo;
  Offerings? _offerings;

  // Getters
  CustomerInfo? get customerInfo => _customerInfo;
  Offerings? get offerings => _offerings;
  bool get isInitialized => _isInitialized;

  /// 当前订阅等级
  SubscriptionTier get currentTier {
    if (_customerInfo == null) return SubscriptionTier.free;

    if (_customerInfo!.entitlements.active.containsKey('pro')) {
      return SubscriptionTier.pro;
    }
    if (_customerInfo!.entitlements.active.containsKey('plus')) {
      return SubscriptionTier.plus;
    }
    return SubscriptionTier.free;
  }

  /// 是否有 Plus 或更高权限
  bool get hasPlus => currentTier.hasAccess(SubscriptionTier.plus);

  /// 是否有 Pro 权限
  bool get hasPro => currentTier.hasAccess(SubscriptionTier.pro);

  /// 初始化 RevenueCat
  Future<void> initialize(String userId) async {
    if (_isInitialized) return;

    await Purchases.setLogLevel(
      EnvConfig.isProd ? LogLevel.info : LogLevel.debug,
    );

    final apiKey = defaultTargetPlatform == TargetPlatform.iOS
        ? Env.revenueCatAppleApiKey
        : Env.revenueCatGoogleApiKey;

    final configuration = PurchasesConfiguration(apiKey)..appUserID = userId;
    await Purchases.configure(configuration);

    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

    await _fetchCustomerInfo();
    await _fetchOfferings();

    _isInitialized = true;
    notifyListeners();
  }

  /// 购买产品 (使用新的 purchase API)
  Future<SubscriptionPurchaseResult> purchasePackage(Package package) async {
    try {
      // 使用 PurchaseParams.package() 命名构造函数 (SDK 9.x+)
      final purchaseParams = PurchaseParams.package(package);
      final result = await Purchases.purchase(purchaseParams);
      _customerInfo = result.customerInfo;
      notifyListeners();
      return SubscriptionPurchaseResult.success;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return SubscriptionPurchaseResult.cancelled;
      }
      return SubscriptionPurchaseResult.error;
    } catch (e) {
      return SubscriptionPurchaseResult.error;
    }
  }

  /// 恢复购买
  Future<bool> restorePurchases() async {
    try {
      _customerInfo = await Purchases.restorePurchases();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
```

### 1.3 Paywall 页面

```dart
// presentation/pages/paywall_screen.dart
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = RevenueCatService();
      if (service.offerings == null) {
        await service.refreshOfferings();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offerings = RevenueCatService().offerings;
    final currentOffering = offerings?.current;
    final packages = currentOffering?.availablePackages ?? [];

    // 匹配产品（跨平台兼容）
    final plusMonthly = packages.firstWhereOrNull(
      (p) => _matchesProduct(p, 'tritalkplusmonthly'),
    );
    // ... 其他产品匹配

    return Scaffold(
      // ... UI 实现
    );
  }

  /// 匹配产品 ID，兼容 Apple 和 Google Play 格式
  ///
  /// Apple: identifier == 'tritalkplusmonthly'
  /// Google Play: identifier == 'tritalkplusmonthly:monthly-autorenewing'
  bool _matchesProduct(Package package, String productId) {
    final identifier = package.storeProduct.identifier;
    return identifier == productId || identifier.startsWith('$productId:');
  }
}
```

### 1.4 环境变量配置

```dart
// lib/core/env/env_dev.dart (env_local.dart, env_prod.dart 类似)
class EnvDev {
  // RevenueCat API Keys
  static const String revenueCatAppleApiKey = 'appl_xxx';
  static const String revenueCatGoogleApiKey = 'goog_xxx';
}

// lib/core/env/env.dart
class Env {
  static String get revenueCatAppleApiKey {
    switch (EnvConfig.current) {
      case Environment.local:
        return EnvLocal.revenueCatAppleApiKey;
      case Environment.dev:
        return EnvDev.revenueCatAppleApiKey;
      case Environment.prod:
        return EnvProd.revenueCatAppleApiKey;
    }
  }

  static String get revenueCatGoogleApiKey {
    switch (EnvConfig.current) {
      case Environment.local:
        return EnvLocal.revenueCatGoogleApiKey;
      case Environment.dev:
        return EnvDev.revenueCatGoogleApiKey;
      case Environment.prod:
        return EnvProd.revenueCatGoogleApiKey;
    }
  }
}
```

### 1.5 App 初始化

```dart
// main.dart 或 app_startup.dart
Future<void> initializeRevenueCat() async {
  final authService = AuthService();
  final user = authService.currentUser;

  if (user != null) {
    await RevenueCatService().initialize(user.id);
  }
}

// 在用户登录后调用
Future<void> onUserLogin(User user) async {
  await RevenueCatService().login(user.id);
}

// 在用户登出时调用
Future<void> onUserLogout() async {
  await RevenueCatService().logout();
}
```

## 2. i18n 字符串

以下 i18n 键已添加到 `intl_en.arb` 和 `intl_zh.arb`：

| Key                                     | English                            | 中文                   |
| --------------------------------------- | ---------------------------------- | ---------------------- |
| `subscription_upgrade`                  | Upgrade                            | 升级                   |
| `subscription_choosePlan`               | Choose a Plan                      | 选择订阅方案           |
| `subscription_restore`                  | Restore                            | 恢复购买               |
| `subscription_unlockPotential`          | Unlock Full Potential              | 解锁全部潜能           |
| `subscription_description`              | Get unlimited conversations...     | 获取无限对话...        |
| `subscription_recommended`              | POPULAR                            | 热门                   |
| `subscription_monthlyPlan`              | Monthly                            | 月付                   |
| `subscription_yearlyPlan`               | Yearly                             | 年付                   |
| `subscription_purchaseSuccess`          | Subscription activated! Welcome!   | 订阅已激活！欢迎！     |
| `subscription_purchaseFailed`           | Purchase failed. Please try again. | 购买失败，请重试。     |
| `subscription_purchasesRestored`        | Purchases Restored                 | 购买已恢复             |
| `subscription_noPurchasesToRestore`     | No previous purchases found.       | 未找到之前的购买记录。 |
| `subscription_restoreFailed`            | Failed to restore purchases.       | 恢复购买失败。         |
| `subscription_noProductsAvailable`      | No products available.             | 暂无可用产品。         |
| `subscription_featureUnlimitedMessages` | Unlimited messages                 | 无限消息               |
| `subscription_featureAdvancedFeedback`  | Advanced grammar feedback          | 高级语法反馈           |
| `subscription_featureAllPlusFeatures`   | All Plus features included         | 包含所有 Plus 功能     |
| `subscription_featurePremiumScenarios`  | Premium scenarios                  | 高级场景               |
| `subscription_featurePrioritySupport`   | Priority support                   | 优先客服支持           |

## 3. 前端测试清单

- [ ] Paywall 正确显示产品和价格
- [ ] 购买流程完整性
- [ ] 订阅状态 UI 更新
- [ ] 离线状态处理
- [ ] 错误处理和重试
- [ ] 恢复购买功能

## 附录: RevenueCat SDK 安装

### iOS (已包含在 purchases_flutter)

无需额外配置。

### Android

```gradle
// android/build.gradle
buildscript {
    ext.kotlin_version = '1.7.10' // 确保 Kotlin 版本兼容
}
```

## 附录: SDK 版本说明

**purchases_flutter 9.x 重要变更：**

1. **购买 API 变更**：使用 `Purchases.purchase(PurchaseParams.package(package))` 替代废弃的 `Purchases.purchasePackage(package)`

2. **PurchaseParams 命名构造函数**：
   - `PurchaseParams.package(package)` - 购买 Package
   - `PurchaseParams.storeProduct(product)` - 购买 StoreProduct
   - `PurchaseParams.subscriptionOption(option)` - 购买 SubscriptionOption (Google Play)

3. **PurchaseResult 命名冲突**：SDK 内置 `PurchaseResult` 类，项目内部使用 `SubscriptionPurchaseResult` 避免冲突
