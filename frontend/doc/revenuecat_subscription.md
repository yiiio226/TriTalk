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
> Text(context.l10n.subscriptionSuccess)
> Text(context.l10n.purchaseFailed)
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
  purchases_flutter: ^8.0.0 # 或最新稳定版
```

### 1.2 RevenueCat 服务重构

#### 1.2.1 文件结构

```
frontend/lib/features/subscription/
├── data/
│   ├── models/
│   │   ├── subscription_tier.dart      # 订阅等级枚举
│   │   └── entitlement_info.dart       # Entitlement 信息
│   └── services/
│       └── revenue_cat_service.dart    # RevenueCat 服务（重构）
├── domain/
│   └── repositories/
│       └── subscription_repository.dart
└── presentation/
    ├── pages/
    │   └── paywall_screen.dart         # Paywall 页面（重构）
    └── widgets/
        ├── product_card.dart           # 产品卡片
        └── subscription_badge.dart     # 订阅标识
```

#### 1.2.2 订阅等级模型

```dart
// subscription_tier.dart
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

  String get displayNameCn {
    switch (this) {
      case SubscriptionTier.free:
        return '免费版';
      case SubscriptionTier.plus:
        return '进阶版';
      case SubscriptionTier.pro:
        return '专业版';
    }
  }

  /// 检查是否有某个 tier 的权限（Pro 包含 Plus 的权限）
  bool hasAccess(SubscriptionTier requiredTier) {
    return index >= requiredTier.index;
  }
}
```

#### 1.2.3 RevenueCat 服务（重构）

```dart
// revenue_cat_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService extends ChangeNotifier {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  // RevenueCat API Keys
  static const String _appleApiKey = 'appl_xxx'; // TODO: 从环境变量获取
  static const String _googleApiKey = 'goog_xxx'; // TODO: 从环境变量获取

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

    await Purchases.setLogLevel(LogLevel.debug); // 生产环境改为 LogLevel.info

    PurchasesConfiguration configuration;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      configuration = PurchasesConfiguration(_appleApiKey);
    } else {
      configuration = PurchasesConfiguration(_googleApiKey);
    }

    // 登录用户（使用 Supabase user ID）
    configuration.appUserID = userId;

    await Purchases.configure(configuration);

    // 监听用户信息变化
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

    // 获取初始数据
    await _fetchCustomerInfo();
    await _fetchOfferings();

    _isInitialized = true;
    notifyListeners();
  }

  /// 用户登录时调用
  Future<void> login(String userId) async {
    try {
      final result = await Purchases.logIn(userId);
      _customerInfo = result.customerInfo;
      notifyListeners();
    } catch (e) {
      debugPrint('RevenueCat login error: $e');
    }
  }

  /// 用户登出时调用
  Future<void> logout() async {
    try {
      _customerInfo = await Purchases.logOut();
      notifyListeners();
    } catch (e) {
      debugPrint('RevenueCat logout error: $e');
    }
  }

  /// 获取 Customer Info
  Future<void> _fetchCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch customer info: $e');
    }
  }

  /// 获取 Offerings（内部使用）
  Future<void> _fetchOfferings() async {
    try {
      _offerings = await Purchases.getOfferings();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch offerings: $e');
    }
  }

  /// 监听用户信息更新
  void _onCustomerInfoUpdated(CustomerInfo info) {
    _customerInfo = info;
    notifyListeners();
  }

  /// 购买产品
  Future<PurchaseResult> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      _customerInfo = result.customerInfo;
      notifyListeners();
      return PurchaseResult.success;
    } on PlatformException catch (e) {
      // RevenueCat 错误通过 PlatformException 抛出
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult.cancelled;
      }
      debugPrint('Purchase error: $e');
      return PurchaseResult.error;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return PurchaseResult.error;
    }
  }

  /// 恢复购买
  Future<bool> restorePurchases() async {
    try {
      _customerInfo = await Purchases.restorePurchases();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Restore error: $e');
      return false;
    }
  }

  /// 刷新客户信息
  Future<void> refreshCustomerInfo() async {
    await _fetchCustomerInfo();
  }

  /// 刷新 Offerings（供外部调用）
  Future<void> refreshOfferings() async {
    await _fetchOfferings();
  }
}

enum PurchaseResult {
  success,
  cancelled,
  error,
}
```

### 1.3 Paywall 页面重构

```dart
// paywall_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于 PlatformException
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:collection/collection.dart'; // 提供 firstWhereOrNull 扩展

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isLoading = true;
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
        await service.refreshOfferings(); // 使用公开方法
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

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || currentOffering == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Upgrade')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? 'No products available'),
              ElevatedButton(
                onPressed: _loadOfferings,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // 从 Offering 获取产品包
    final packages = currentOffering.availablePackages;

    // 按等级和周期分组
    // 使用辅助方法匹配产品，兼容 Apple 和 Google Play 格式
    final plusMonthly = packages.firstWhereOrNull(
      (p) => _matchesProduct(p, 'tritalkplusmonthly'),
    );
    final plusYearly = packages.firstWhereOrNull(
      (p) => _matchesProduct(p, 'tritalkplusyearly'),
    );
    final proMonthly = packages.firstWhereOrNull(
      (p) => _matchesProduct(p, 'tritalkpromonthly'),
    );
    final proYearly = packages.firstWhereOrNull(
      (p) => _matchesProduct(p, 'tritalkproyearly'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('选择订阅方案'),
        actions: [
          TextButton(
            onPressed: _restorePurchases,
            child: const Text('恢复购买'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Plus 套餐
          _buildTierSection(
            tier: SubscriptionTier.plus,
            monthlyPackage: plusMonthly,
            yearlyPackage: plusYearly,
          ),
          const SizedBox(height: 24),

          // Pro 套餐
          _buildTierSection(
            tier: SubscriptionTier.pro,
            monthlyPackage: proMonthly,
            yearlyPackage: proYearly,
          ),
        ],
      ),
    );
  }

  Widget _buildTierSection({
    required SubscriptionTier tier,
    Package? monthlyPackage,
    Package? yearlyPackage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${tier.displayName} ${tier.displayNameCn}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        if (monthlyPackage != null)
          _buildPackageCard(monthlyPackage, isYearly: false),
        if (yearlyPackage != null)
          _buildPackageCard(yearlyPackage, isYearly: true),
      ],
    );
  }

  Widget _buildPackageCard(Package package, {required bool isYearly}) {
    final product = package.storeProduct;

    return Card(
      child: ListTile(
        title: Text(isYearly ? '年付方案' : '月付方案'),
        subtitle: Text(product.priceString),
        trailing: ElevatedButton(
          onPressed: () => _purchasePackage(package),
          child: const Text('订阅'),
        ),
      ),
    );
  }

  Future<void> _purchasePackage(Package package) async {
    final result = await RevenueCatService().purchasePackage(package);

    if (!mounted) return;

    switch (result) {
      case PurchaseResult.success:
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('订阅成功！')),
        );
        break;
      case PurchaseResult.cancelled:
        // 用户取消，不做处理
        break;
      case PurchaseResult.error:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('购买失败，请重试')),
        );
        break;
    }
  }

  Future<void> _restorePurchases() async {
    final success = await RevenueCatService().restorePurchases();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '购买已恢复' : '恢复失败，请重试'),
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  /// 匹配产品 ID，兼容 Apple 和 Google Play 格式
  ///
  /// Apple: identifier == 'tritalkplusmonthly'
  /// Google Play: identifier == 'tritalkplusmonthly:monthly-autorenewing'
  ///
  /// 使用 startsWith 匹配，确保跨平台兼容
  bool _matchesProduct(Package package, String productId) {
    final identifier = package.storeProduct.identifier;
    return identifier == productId || identifier.startsWith('$productId:');
  }
}
```

### 1.4 App 初始化

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

## 2. 环境变量配置 (Flutter)

```dart
// lib/core/config/env.dart
/// 环境配置抽象接口
abstract class Env {
  String get revenueCatAppleApiKey;
  String get revenueCatGoogleApiKey;
  // ... 其他环境变量
}

// lib/core/config/env_dev.dart
class EnvDev implements Env {
  @override
  String get revenueCatAppleApiKey => 'appl_xxx'; // 测试环境

  @override
  String get revenueCatGoogleApiKey => 'goog_xxx';
}

// lib/core/config/env_prod.dart
class EnvProd implements Env {
  @override
  String get revenueCatAppleApiKey => 'appl_yyy'; // 生产环境

  @override
  String get revenueCatGoogleApiKey => 'goog_yyy';
}

// lib/core/config/env_config.dart
/// 全局环境配置单例
class EnvConfig {
  static late Env _env;

  static void init(Env env) {
    _env = env;
  }

  static Env get current => _env;
}

// main.dart 中使用
void main() {
  // 通过编译时参数选择环境
  // flutter run --dart-define=ENV=dev
  // flutter run --dart-define=ENV=prod
  const envName = String.fromEnvironment('ENV', defaultValue: 'dev');

  final env = switch (envName) {
    'prod' => EnvProd(),
    _ => EnvDev(),
  };

  EnvConfig.init(env);
  runApp(const MyApp());
}

// RevenueCatService 中使用
class RevenueCatService extends ChangeNotifier {
  // ...

  /// 初始化 RevenueCat
  Future<void> initialize(String userId) async {
    if (_isInitialized) return;

    await Purchases.setLogLevel(
      EnvConfig.current is EnvProd ? LogLevel.info : LogLevel.debug,
    );

    final apiKey = defaultTargetPlatform == TargetPlatform.iOS
        ? EnvConfig.current.revenueCatAppleApiKey
        : EnvConfig.current.revenueCatGoogleApiKey;

    final configuration = PurchasesConfiguration(apiKey)
      ..appUserID = userId;

    await Purchases.configure(configuration);
    // ...
  }
}
```

## 3. 前端测试

- [ ] Paywall 正确显示产品和价格
- [ ] 购买流程完整性
- [ ] 订阅状态 UI 更新
- [ ] 离线状态处理
- [ ] 错误处理和重试

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
