# 🎨 TriTalk 闪屏页面 - Floating Elements 风格

## ✨ 设计特点

新的闪屏页面采用 **Floating Elements（浮动元素）** 风格，完美契合 TriTalk 的语言学习主题。

### 核心特性

1. **🌍 多语言浮动文字**
   - Hello (英语) - 淡蓝色
   - 你好 (中文) - 淡红色
   - Bonjour (法语) - 淡绿色
   - Hola (西班牙语) - 淡黄色
   - こんにちは (日语) - 淡紫色
   - Ciao (意大利语) - 淡橙色
   - 안녕하세요 (韩语) - 淡蓝色

2. **✨ 流畅动画效果**
   - 上下浮动动画（4秒循环）
   - 轻微旋转效果（20秒循环）
   - 淡入动画（1.5秒）
   - 所有元素协调运动

3. **🎯 主题明确**
   - 直观展示语言学习主题
   - 友好活泼的视觉风格
   - 符合品牌定位

## 🎨 设计系统集成

完美使用 TriTalk 设计系统：

### 色彩
```dart
- AppColors.lb100 (淡蓝)
- AppColors.lr100 (淡红)
- AppColors.lg100 (淡绿)
- AppColors.ly100 (淡黄)
- AppColors.lp100 (淡紫)
- AppColors.lo100 (淡橙)
- AppColors.lightBackground (背景)
```

### 字体
```dart
- AppTypography.headline1 (标题)
- AppTypography.body1 (副标题)
- AppTypography.body2 (浮动文字)
```

### 间距与圆角
```dart
- AppSpacing.sm, md, lg, xl
- AppRadius.full (完全圆角)
- AppShadows.sm, xl (阴影)
```

## 🔧 技术实现

### 动画控制器
```dart
- _fadeController: 淡入动画（1.5秒）
- _floatController: 浮动动画（4秒，往复）
- _rotateController: 旋转动画（20秒，循环）
```

### 性能优化
- 使用 `AnimatedBuilder` 优化重绘
- `Listenable.merge` 合并动画监听
- 轻量级动画，流畅 60fps

## 📱 用户体验

1. **启动流程**
   - 应用启动 → 显示闪屏
   - 浮动元素淡入并开始动画
   - 后台初始化认证状态
   - 动画完成 60% 后根据认证状态导航

2. **导航逻辑**
   - ✅ 已认证 + 需要引导 → 引导页面
   - ✅ 已认证 + 无需引导 → 主页
   - ❌ 未认证 → 登录页面
   - ⏳ 状态未知 → 继续等待

## 🎯 与原设计的对比

| 特性 | 原设计 (Shimmer) | 新设计 (Floating Elements) |
|------|-----------------|---------------------------|
| 主题性 | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| 动画复杂度 | ⭐⭐ | ⭐⭐⭐⭐ |
| 视觉吸引力 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 品牌契合度 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 性能 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 依赖包 | shimmer | 无额外依赖 |

## 📝 代码结构

```
splash_screen.dart
├── SplashScreen (ConsumerStatefulWidget)
│   ├── 3 个 AnimationController
│   ├── Auth 初始化逻辑
│   ├── 导航逻辑
│   └── UI 构建
│       ├── 浮动语言元素 (_buildFloatingElements)
│       └── 中心内容（Logo + 标题）
```

## 🚀 使用方式

闪屏页面已集成到主应用中，无需额外配置：

```dart
// 在 main.dart 中
MaterialApp(
  home: const SplashScreen(), // 自动使用新设计
  // ...
)
```

## 🎨 自定义调整

如需调整，可修改以下参数：

### 调整浮动速度
```dart
_floatController = AnimationController(
  duration: const Duration(seconds: 4), // 修改这里
  vsync: this,
)..repeat(reverse: true);
```

### 调整旋转速度
```dart
_rotateController = AnimationController(
  duration: const Duration(seconds: 20), // 修改这里
  vsync: this,
)..repeat();
```

### 添加/移除语言
```dart
final elements = [
  {'text': 'Hello', 'color': AppColors.lb100, 'x': 0.1, 'y': 0.15},
  // 添加更多语言...
];
```

### 调整浮动幅度
```dart
final offset = 20 * (index % 2 == 0 ? 1 : -1) * _floatController.value;
//            ^^ 修改这个数值
```

## 💡 设计理念

这个设计的核心理念是：

1. **主题先行** - 用多语言元素直观传达应用的核心价值
2. **动态活泼** - 浮动和旋转营造轻松友好的氛围
3. **简洁优雅** - 不过度设计，保持清晰的视觉层次
4. **性能优先** - 在视觉效果和性能之间取得平衡

## 🎉 效果预览

启动应用即可看到：
- 7 个不同语言的文字气泡在屏幕上优雅地浮动
- 每个气泡都有轻微的旋转效果
- 中心的 Logo 和标题稳定展示
- 整体氛围友好、活泼、专业

---

**设计日期**: 2026-01-28  
**设计风格**: Floating Elements  
**主题**: 多语言学习  
**状态**: ✅ 已集成到主应用
