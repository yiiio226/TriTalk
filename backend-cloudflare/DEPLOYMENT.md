# 部署指南 / Deployment Guide

本文档介绍如何配置自动部署到 Cloudflare Workers。

## 自动部署配置

### 前置要求

1. GitHub 仓库已启用 Actions
2. 拥有 Cloudflare 账户和 Workers 权限
3. 拥有 OpenRouter API Key

### 配置 GitHub Secrets

在 GitHub 仓库中配置以下 Secrets：

1. 进入仓库页面
2. 点击 **Settings** > **Secrets and variables** > **Actions**
3. 点击 **New repository secret** 添加以下 secrets：

#### 1. CLOUDFLARE_API_TOKEN

**如何获取：**

1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. 点击右上角头像 > **My Profile**
3. 左侧菜单选择 **API Tokens**
4. 点击 **Create Token**
5. 选择 **Edit Cloudflare Workers** 模板，或创建自定义 token
6. 确保 token 有以下权限：
   - Account > Cloudflare Workers Scripts > Edit
7. 复制生成的 token

**在 GitHub 中添加：**
- Name: `CLOUDFLARE_API_TOKEN`
- Secret: 粘贴你的 API token

#### 2. CLOUDFLARE_ACCOUNT_ID

**如何获取：**

1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. 选择任意一个域名或进入 Workers & Pages
3. 在右侧栏可以看到 **Account ID**
4. 或者在 URL 中找到：`https://dash.cloudflare.com/<account-id>/...`

**在 GitHub 中添加：**
- Name: `CLOUDFLARE_ACCOUNT_ID`
- Secret: 粘贴你的 Account ID

#### 3. OPENROUTER_API_KEY

**如何获取：**

1. 登录 [OpenRouter](https://openrouter.ai/)
2. 进入 **Keys** 页面
3. 创建或复制现有的 API key

**在 GitHub 中添加：**
- Name: `OPENROUTER_API_KEY`
- Secret: 粘贴你的 OpenRouter API key

### 部署触发条件

自动部署会在以下情况触发：

1. **自动触发**：推送代码到 `main` 分支，且 `backend-cloudflare/` 目录下有文件变更
2. **手动触发**：在 GitHub Actions 页面手动运行 workflow

### 部署流程

```bash
# 1. 提交代码
git add .
git commit -m "Update backend"

# 2. 推送到 main 分支
git push origin main

# 3. GitHub Actions 自动执行部署
# 可以在 GitHub 仓库的 Actions 标签页查看部署进度
```

## 本地部署

如果需要手动从本地部署：

```bash
cd backend-cloudflare

# 部署到生产环境
npm run deploy

# 首次部署需要先设置 secret
wrangler secret put OPENROUTER_API_KEY
# 然后输入你的 API key
```

## 查看部署日志

### GitHub Actions 日志

1. 进入仓库的 **Actions** 标签页
2. 选择 **Deploy to Cloudflare Workers** workflow
3. 查看最近的运行记录

### Cloudflare Workers 日志

```bash
cd backend-cloudflare

# 实时查看 worker 日志
npm run tail
```

或在 [Cloudflare Dashboard](https://dash.cloudflare.com/) 中：
1. 进入 **Workers & Pages**
2. 选择 **tritalk-backend**
3. 查看 **Logs** 标签页

## 故障排查

### 部署失败

**检查清单：**

1. ✅ 确认所有 GitHub Secrets 已正确配置
2. ✅ 确认 CLOUDFLARE_API_TOKEN 有正确的权限
3. ✅ 确认 CLOUDFLARE_ACCOUNT_ID 正确
4. ✅ 检查 GitHub Actions 日志中的错误信息

**常见错误：**

- **Authentication error**: API Token 无效或权限不足
- **Account ID mismatch**: Account ID 不正确
- **Deployment failed**: 检查代码是否有语法错误，运行 `npm run dev` 本地测试

### Secret 未生效

如果修改了 GitHub Secrets，需要重新触发部署：

```bash
# 方法 1: 推送一个新的 commit
git commit --allow-empty -m "Trigger deployment"
git push origin main

# 方法 2: 在 GitHub Actions 页面手动运行 workflow
```

## 环境变量

### 开发环境

本地开发使用 `.dev.vars` 文件（已在 `.gitignore` 中）：

```bash
OPENROUTER_API_KEY=your-dev-key-here
```

### 生产环境

生产环境的环境变量通过两种方式配置：

1. **Secrets**（敏感信息）：通过 GitHub Actions 或 `wrangler secret put` 设置
   - `OPENROUTER_API_KEY`

2. **Variables**（非敏感配置）：在 `wrangler.toml` 中配置
   - `OPENROUTER_MODEL`

## 回滚部署

如果需要回滚到之前的版本：

1. 在 Cloudflare Dashboard 中：
   - 进入 **Workers & Pages** > **tritalk-backend**
   - 选择 **Deployments** 标签页
   - 找到之前的部署版本，点击 **Rollback**

2. 或者从 Git 回滚：
   ```bash
   # 回滚到指定 commit
   git revert <commit-hash>
   git push origin main
   ```

## 监控和告警

建议配置以下监控：

1. **GitHub Actions 通知**：在仓库 Settings > Notifications 中配置
2. **Cloudflare Workers 监控**：在 Cloudflare Dashboard 中查看请求量、错误率等指标
3. **日志监控**：使用 `wrangler tail` 实时监控生产环境日志

## 安全建议

1. ✅ 定期轮换 API tokens
2. ✅ 使用最小权限原则配置 API token
3. ✅ 不要在代码中硬编码 secrets
4. ✅ 定期检查 GitHub Actions 日志，确保没有泄露敏感信息
5. ✅ 启用 Cloudflare Workers 的访问控制（如需要）
