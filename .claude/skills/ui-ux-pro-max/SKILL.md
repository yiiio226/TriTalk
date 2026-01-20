---
name: ui-ux-pro-max
description: "UI/UX design intelligence. 50 styles, 21 palettes, 50 font pairings, 20 charts, 9 stacks (React, Next.js, Vue, Svelte, SwiftUI, React Native, Flutter, Tailwind, shadcn/ui). Actions: plan, build, create, design, implement, review, fix, improve, optimize, enhance, refactor, check UI/UX code. Projects: website, landing page, dashboard, admin panel, e-commerce, SaaS, portfolio, blog, mobile app, .html, .tsx, .vue, .svelte. Elements: button, modal, navbar, sidebar, card, table, form, chart. Styles: glassmorphism, claymorphism, minimalism, brutalism, neumorphism, bento grid, dark mode, responsive, skeuomorphism, flat design. Topics: color palette, accessibility, animation, layout, typography, font pairing, spacing, hover, shadow, gradient. Integrations: shadcn/ui MCP for component search and examples.
UI/UX 设计智能。包含 50 种风格、21 种调色板、50 种字体搭配、20 种图表、9 种技术栈 (React, Next.js, Vue, Svelte, SwiftUI, React Native, Flutter, Tailwind, shadcn/ui)。功能：规划、构建、创建、设计、实施、审查、修复、改进、优化、增强、重构、检查 UI/UX 代码。项目：网站、着陆页、仪表板、管理面板、电子商务、SaaS、作品集、博客、移动应用、.html、.tsx、.vue、.svelte。元素：按钮、模态框、导航栏、侧边栏、卡片、表格、表单、图表。风格：玻璃拟态、粘土拟态、极简主义、残酷主义、新拟态、便当网格、深色模式、响应式、拟物化、扁平设计。主题：调色板、无障碍性、动画、布局、排版、字体搭配、间距、悬停、阴影、渐变。集成：shadcn/ui MCP 用于组件搜索和示例。
---

# UI/UX Pro Max - Design Intelligence | 设计智能

Comprehensive design guide for web and mobile applications. Contains 50+ styles, 97 color palettes, 57 font pairings, 99 UX guidelines, and 25 chart types across 9 technology stacks. Searchable database with priority-based recommendations.

适用于 Web 和移动应用的综合设计指南。包含 50 多种风格、97 个调色板、57 种字体搭配、99 条 UX 准则和 25 种图表类型，覆盖 9 种技术栈。提供基于优先级的推荐和可搜索数据库。

## When to Apply | 何时应用

Reference these guidelines when:
在以下情况参考这些指南：

- Designing new UI components or pages | 设计新的 UI 组件或页面
- Choosing color palettes and typography | 选择调色板和字体排版
- Reviewing code for UX issues | 审查代码中的 UX 问题
- Building landing pages or dashboards | 构建落地页或仪表盘
- Implementing accessibility requirements | 实现无障碍需求

## Rule Categories by Priority | 规则优先级分类

| Priority | Category | Impact | Domain |
|----------|----------|--------|--------|
| 1 | Accessibility | CRITICAL | `ux` |
| 2 | Touch & Interaction | CRITICAL | `ux` |
| 3 | Performance | HIGH | `ux` |
| 4 | Layout & Responsive | HIGH | `ux` |
| 5 | Typography & Color | MEDIUM | `typography`, `color` |
| 6 | Animation | MEDIUM | `ux` |
| 7 | Style Selection | MEDIUM | `style`, `product` |
| 8 | Charts & Data | LOW | `chart` |

## Quick Reference | 快速参考

### 1. Accessibility (CRITICAL) | 无障碍性 (关键)

- `color-contrast` - Minimum 4.5:1 ratio for normal text | 普通文本至少 4.5:1 的对比度
- `focus-states` - Visible focus rings on interactive elements | 交互元素需有可见的聚焦环
- `alt-text` - Descriptive alt text for meaningful images | 有意义的图片需有描述性 alt 文本
- `aria-labels` - aria-label for icon-only buttons | 纯图标按钮需有 aria-label
- `keyboard-nav` - Tab order matches visual order | Tab 键顺序需与视觉顺序一致
- `form-labels` - Use label with for attribute | 表单使用带有 for 属性的 label

### 2. Touch & Interaction (CRITICAL) | 触控与交互 (关键)

- `touch-target-size` - Minimum 44x44px touch targets | 最小 44x44px 的触控目标
- `hover-vs-tap` - Use click/tap for primary interactions | 主要交互使用点击/轻触（而非悬停）
- `loading-buttons` - Disable button during async operations | 异步操作期间禁用按钮
- `error-feedback` - Clear error messages near problem | 在问题附近显示清晰的错误信息
- `cursor-pointer` - Add cursor-pointer to clickable elements | 可点击元素添加 cursor-pointer

### 3. Performance (HIGH) | 性能 (高)

- `image-optimization` - Use WebP, srcset, lazy loading | 使用 WebP、srcset 和懒加载
- `reduced-motion` - Check prefers-reduced-motion | 检查 prefers-reduced-motion 设置
- `content-jumping` - Reserve space for async content | 为异步内容预留空间

### 4. Layout & Responsive (HIGH) | 布局与响应式 (高)

- `viewport-meta` - width=device-width initial-scale=1 | 设置 viewport meta 标签
- `readable-font-size` - Minimum 16px body text on mobile | 移动端正文最小 16px
- `horizontal-scroll` - Ensure content fits viewport width | 确保内容适应视口宽度（无横向滚动）
- `z-index-management` - Define z-index scale (10, 20, 30, 50) | 定义 z-index 层级规范

### 5. Typography & Color (MEDIUM) | 排版与色彩 (中)

- `line-height` - Use 1.5-1.75 for body text | 正文行高使用 1.5-1.75
- `line-length` - Limit to 65-75 characters per line | 每行限制 65-75 个字符
- `font-pairing` - Match heading/body font personalities | 标题与正文字体风格搭配

### 6. Animation (MEDIUM) | 动画 (中)

- `duration-timing` - Use 150-300ms for micro-interactions | 微交互使用 150-300ms
- `transform-performance` - Use transform/opacity, not width/height | 使用 transform/opacity，避免 width/height
- `loading-states` - Skeleton screens or spinners | 使用骨架屏或加载指示器

### 7. Style Selection (MEDIUM) | 风格选择 (中)

- `style-match` - Match style to product type | 风格需匹配产品类型
- `consistency` - Use same style across all pages | 所有页面保持风格一致
- `no-emoji-icons` - Use SVG icons, not emojis | 使用 SVG 图标，避免使用 Emoji

### 8. Charts & Data (LOW) | 图表与数据 (低)

- `chart-type` - Match chart type to data type | 图表类型需匹配数据类型
- `color-guidance` - Use accessible color palettes | 使用无障碍的调色板
- `data-table` - Provide table alternative for accessibility | 提供表格作为无障碍替代方案

## How to Use | 如何使用

Search specific domains using the CLI tool below.
使用下方的 CLI 工具搜索特定领域。

---

## Prerequisites | 前置要求

Check if Python is installed:
检查是否安装了 Python：

```bash
python3 --version || python --version
```

If Python is not installed, install it based on user's OS:
如果未安装 Python，请根据操作系统进行安装：

**macOS:**
```bash
brew install python3
```

**Ubuntu/Debian:**
```bash
sudo apt update && sudo apt install python3
```

**Windows:**
```powershell
winget install Python.Python.3.12
```

---

## How to Use This Skill | 如何使用此技能

When user requests UI/UX work (design, build, create, implement, review, fix, improve), follow this workflow:
当用户请求 UI/UX 工作（设计、构建、创建、实现、审查、修复、改进）时，请遵循以下工作流：

### Step 1: Analyze User Requirements | 第一步：分析用户需求

Extract key information from user request:
从用户请求中提取关键信息：
- **Product type**: SaaS, e-commerce, portfolio, dashboard, landing page, etc. | **产品类型**：SaaS、电商、作品集、仪表盘、落地页等。
- **Style keywords**: minimal, playful, professional, elegant, dark mode, etc. | **风格关键词**：极简、活泼、专业、优雅、暗黑模式等。
- **Industry**: healthcare, fintech, gaming, education, etc. | **行业**：医疗、金融科技、游戏、教育等。
- **Stack**: React, Vue, Next.js, or default to `html-tailwind` | **技术栈**：React, Vue, Next.js, 或默认为 `html-tailwind`。

### Step 2: Generate Design System (REQUIRED) | 第二步：生成设计系统 (必须)

**Always start with `--design-system`** to get comprehensive recommendations with reasoning:
**始终从 `--design-system` 开始**，以获取包含推理的全面建议：

```bash
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "<product_type> <industry> <keywords>" --design-system [-p "Project Name"]
```

This command: | 此命令将：
1. Searches 5 domains in parallel (product, style, color, landing, typography) | 1. 并行搜索 5 个领域（产品、风格、色彩、落地页、排版）
2. Applies reasoning rules from `ui-reasoning.csv` to select best matches | 2. 应用 `ui-reasoning.csv` 中的推理规则选择最佳匹配
3. Returns complete design system: pattern, style, colors, typography, effects | 3. 返回完整的设计系统：模式、风格、色彩、排版、效果
4. Includes anti-patterns to avoid | 4. 包含需避免的反模式

**Example:**
```bash
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "beauty spa wellness service" --design-system -p "Serenity Spa"
```

### Step 2b: Persist Design System (Master + Overrides Pattern) | 步骤 2b：持久化设计系统 (Master + Overrides 模式)

To save the design system for **hierarchical retrieval across sessions**, add `--persist`:
要保存设计系统以实现**跨会话的分层检索**，请添加 `--persist`：

```bash
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "<query>" --design-system --persist -p "Project Name"
```

This creates: | 这将创建：
- `design-system/MASTER.md` — Global Source of Truth with all design rules | 全局设计规则的唯一事实来源
- `design-system/pages/` — Folder for page-specific overrides | 用于页面特定覆盖的文件夹

**With page-specific override:** | **使用页面特定覆盖：**
```bash
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "<query>" --design-system --persist -p "Project Name" --page "dashboard"
```

This also creates: | 这还将创建：
- `design-system/pages/dashboard.md` — Page-specific deviations from Master | 页面特定的规则（覆盖 Master）

**How hierarchical retrieval works:** | **分层检索如何工作：**
1. When building a specific page (e.g., "Checkout"), first check `design-system/pages/checkout.md` | 1. 构建特定页面（如 "Checkout"）时，首先检查 `design-system/pages/checkout.md`
2. If the page file exists, its rules **override** the Master file | 2. 如果页面文件存在，其规则将**覆盖** Master 文件
3. If not, use `design-system/MASTER.md` exclusively | 3. 如果不存在，则仅使用 `design-system/MASTER.md`

**Context-aware retrieval prompt:** | **上下文感知检索提示词：**
```
I am building the [Page Name] page. Please read design-system/MASTER.md.
Also check if design-system/pages/[page-name].md exists.
If the page file exists, prioritize its rules.
If not, use the Master rules exclusively.
Now, generate the code...
```

### Step 3: Supplement with Detailed Searches (as needed) | 第三步：补充详细搜索 (按需)

After getting the design system, use domain searches to get additional details:
获取设计系统后，使用领域搜索获取更多细节：

```bash
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "<keyword>" --domain <domain> [-n <max_results>]
```

**When to use detailed searches:** | **何时使用详细搜索：**

| Need | Domain | Example |
|------|--------|---------|
| More style options | `style` | `--domain style "glassmorphism dark"` |
| Chart recommendations | `chart` | `--domain chart "real-time dashboard"` |
| UX best practices | `ux` | `--domain ux "animation accessibility"` |
| Alternative fonts | `typography` | `--domain typography "elegant luxury"` |
| Landing structure | `landing` | `--domain landing "hero social-proof"` |

### Step 4: Stack Guidelines (Default: html-tailwind) | 第四步：技术栈指南 (默认：html-tailwind)

Get implementation-specific best practices. If user doesn't specify a stack, **default to `html-tailwind`**.
获取特定实现的最佳实践。如果用户未指定技术栈，**默认为 `html-tailwind`**。

```bash
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "<keyword>" --stack html-tailwind
```

Available stacks: `html-tailwind`, `react`, `nextjs`, `vue`, `svelte`, `swiftui`, `react-native`, `flutter`, `shadcn`, `jetpack-compose`
可用技术栈：`html-tailwind`, `react`, `nextjs`, `vue`, `svelte`, `swiftui`, `react-native`, `flutter`, `shadcn`, `jetpack-compose`

---

## Search Reference | 搜索参考

### Available Domains | 可用领域

| Domain | Use For | Example Keywords |
|--------|---------|------------------|
| `product` | Product type recommendations (产品类型推荐) | SaaS, e-commerce, portfolio, healthcare, beauty, service |
| `style` | UI styles, colors, effects (UI 风格、颜色、效果) | glassmorphism, minimalism, dark mode, brutalism |
| `typography` | Font pairings, Google Fonts (字体搭配) | elegant, playful, professional, modern |
| `color` | Color palettes by product type (产品配色) | saas, ecommerce, healthcare, beauty, fintech, service |
| `landing` | Page structure, CTA strategies (页面结构) | hero, hero-centric, testimonial, pricing, social-proof |
| `chart` | Chart types, library recommendations (图表类型) | trend, comparison, timeline, funnel, pie |
| `ux` | Best practices, anti-patterns (最佳实践) | animation, accessibility, z-index, loading |
| `react` | React/Next.js performance (React 性能) | waterfall, bundle, suspense, memo, rerender, cache |
| `web` | Web interface guidelines (Web 指南) | aria, focus, keyboard, semantic, virtualize |
| `prompt` | AI prompts, CSS keywords (AI 提示词) | (style name) |

### Available Stacks | 可用技术栈

| Stack | Focus |
|-------|-------|
| `html-tailwind` | Tailwind utilities, responsive, a11y (DEFAULT) |
| `react` | State, hooks, performance, patterns |
| `nextjs` | SSR, routing, images, API routes |
| `vue` | Composition API, Pinia, Vue Router |
| `svelte` | Runes, stores, SvelteKit |
| `swiftui` | Views, State, Navigation, Animation |
| `react-native` | Components, Navigation, Lists |
| `flutter` | Widgets, State, Layout, Theming |
| `shadcn` | shadcn/ui components, theming, forms, patterns |
| `jetpack-compose` | Composables, Modifiers, State Hoisting, Recomposition |

---

## Example Workflow | 工作流示例

**User request:** "Làm landing page cho dịch vụ chăm sóc da chuyên nghiệp" (Create a landing page for professional skin care service)

### Step 1: Analyze Requirements | 第一步：分析需求
- Product type: Beauty/Spa service
- Style keywords: elegant, professional, soft
- Industry: Beauty/Wellness
- Stack: html-tailwind (default)

### Step 2: Generate Design System (REQUIRED) | 第二步：生成设计系统 (必须)

```bash
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "beauty spa wellness service elegant" --design-system -p "Serenity Spa"
```

**Output:** Complete design system with pattern, style, colors, typography, effects, and anti-patterns.
**输出：** 完整的设计系统，包含模式、风格、色彩、排版、效果和反模式。

### Step 3: Supplement with Detailed Searches (as needed) | 第三步：补充详细搜索 (按需)

```bash
# Get UX guidelines for animation and accessibility
# 获取动画和无障碍的 UX 指南
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "animation accessibility" --domain ux

# Get alternative typography options if needed
# 如果需要，获取替代字体选项
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "elegant luxury serif" --domain typography
```

### Step 4: Stack Guidelines | 第四步：技术栈指南

```bash
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "layout responsive form" --stack html-tailwind
```

**Then:** Synthesize design system + detailed searches and implement the design.
**然后：** 综合设计系统 + 详细搜索结果，并实现设计。

---

## Output Formats | 输出格式

The `--design-system` flag supports two output formats:
`--design-system` 参数支持两种输出格式：

```bash
# ASCII box (default) - best for terminal display
# ASCII 框 (默认) - 最适合终端显示
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "fintech crypto" --design-system

# Markdown - best for documentation
# Markdown - 最适合文档
python3 .claude/skills/ui-ux-pro-max/scripts/search.py "fintech crypto" --design-system -f markdown
```

---

## Tips for Better Results | 获取更好结果的技巧

1. **Be specific with keywords** - "healthcare SaaS dashboard" > "app"
   **关键词要具体** - "healthcare SaaS dashboard" 优于 "app"
2. **Search multiple times** - Different keywords reveal different insights
   **多次搜索** - 不同的关键词会揭示不同的见解
3. **Combine domains** - Style + Typography + Color = Complete design system
   **组合领域** - 风格 + 排版 + 色彩 = 完整设计系统
4. **Always check UX** - Search "animation", "z-index", "accessibility" for common issues
   **始终检查 UX** - 搜索 "animation", "z-index", "accessibility" 查找常见问题
5. **Use stack flag** - Get implementation-specific best practices
   **使用技术栈参数** - 获取特定实现的最佳实践
6. **Iterate** - If first search doesn't match, try different keywords
   **迭代** - 如果第一次搜索不匹配，尝试不同的关键词

---

## Common Rules for Professional UI | 专业 UI 的通用规则

These are frequently overlooked issues that make UI look unprofessional:
这些是经常被忽视的问题，会让 UI 看起来不专业：

### Icons & Visual Elements | 图标与视觉元素

| Rule | Do | Don't |
|------|----|----- |
| **No emoji icons** | Use SVG icons (Heroicons, Lucide, Simple Icons) | Use emojis like 🎨 🚀 ⚙️ as UI icons |
| **Stable hover states** | Use color/opacity transitions on hover | Use scale transforms that shift layout |
| **Correct brand logos** | Research official SVG from Simple Icons | Guess or use incorrect logo paths |
| **Consistent icon sizing** | Use fixed viewBox (24x24) with w-6 h-6 | Mix different icon sizes randomly |

### Interaction & Cursor | 交互与光标

| Rule | Do | Don't |
|------|----|----- |
| **Cursor pointer** | Add `cursor-pointer` to all clickable/hoverable cards | Leave default cursor on interactive elements |
| **Hover feedback** | Provide visual feedback (color, shadow, border) | No indication element is interactive |
| **Smooth transitions** | Use `transition-colors duration-200` | Instant state changes or too slow (>500ms) |

### Light/Dark Mode Contrast | 亮/暗模式对比度

| Rule | Do | Don't |
|------|----|----- |
| **Glass card light mode** | Use `bg-white/80` or higher opacity | Use `bg-white/10` (too transparent) |
| **Text contrast light** | Use `#0F172A` (slate-900) for text | Use `#94A3B8` (slate-400) for body text |
| **Muted text light** | Use `#475569` (slate-600) minimum | Use gray-400 or lighter |
| **Border visibility** | Use `border-gray-200` in light mode | Use `border-white/10` (invisible) |

### Layout & Spacing | 布局与间距

| Rule | Do | Don't |
|------|----|----- |
| **Floating navbar** | Add `top-4 left-4 right-4` spacing | Stick navbar to `top-0 left-0 right-0` |
| **Content padding** | Account for fixed navbar height | Let content hide behind fixed elements |
| **Consistent max-width** | Use same `max-w-6xl` or `max-w-7xl` | Mix different container widths |

---

## Pre-Delivery Checklist | 交付前检查清单

Before delivering UI code, verify these items:
在交付 UI 代码前，请验证以下项目：

### Visual Quality | 视觉质量
- [ ] No emojis used as icons (use SVG instead) | 不使用 Emoji 作为图标（使用 SVG）
- [ ] All icons from consistent icon set (Heroicons/Lucide) | 所有图标来自一致的图标集
- [ ] Brand logos are correct (verified from Simple Icons) | 品牌 Logo 正确（通过 Simple Icons 验证）
- [ ] Hover states don't cause layout shift | 悬停状态不会导致布局偏移
- [ ] Use theme colors directly (bg-primary) not var() wrapper | 直接使用主题色 (bg-primary) 而非 var() 包装器

### Interaction | 交互
- [ ] All clickable elements have `cursor-pointer` | 所有可点击元素都有 `cursor-pointer`
- [ ] Hover states provide clear visual feedback | 悬停状态提供清晰的视觉反馈
- [ ] Transitions are smooth (150-300ms) | 过渡动画平滑 (150-300ms)
- [ ] Focus states visible for keyboard navigation | 键盘导航时聚焦状态可见

### Light/Dark Mode | 亮/暗模式
- [ ] Light mode text has sufficient contrast (4.5:1 minimum) | 亮色模式文本有足够对比度 (最小 4.5:1)
- [ ] Glass/transparent elements visible in light mode | 玻璃/透明元素在亮色模式下可见
- [ ] Borders visible in both modes | 边框在两种模式下均可见
- [ ] Test both modes before delivery | 交付前测试两种模式

### Layout | 布局
- [ ] Floating elements have proper spacing from edges | 悬浮元素与边缘有适当间距
- [ ] No content hidden behind fixed navbars | 内容不被固定导航栏遮挡
- [ ] Responsive at 375px, 768px, 1024px, 1440px | 在 375/768/1024/1440px 下响应式良好
- [ ] No horizontal scroll on mobile | 移动端无横向滚动

### Accessibility | 无障碍性
- [ ] All images have alt text | 所有图片都有 alt 文本
- [ ] Form inputs have labels | 表单输入框有标签
- [ ] Color is not the only indicator | 颜色不是唯一的指示器
- [ ] `prefers-reduced-motion` respected | 尊重 `prefers-reduced-motion` 设置
