---
name: api-development
description: Node.js/TypeScript API development conventions for TriTalk backend. Use when creating or modifying API endpoints, services, or database operations. | TriTalk 后端的 Node.js/TypeScript API 开发规范。在创建或修改 API 接口、服务或数据库操作时使用。
---

# API Development Skill | API 开发技能

Conventions for TriTalk's Node.js/TypeScript backend development.
TriTalk Node.js/TypeScript 后端开发规范。

## When to use | 何时使用

- Creating new API endpoints | 创建新的 API 端点
- Modifying existing services | 修改现有服务
- Working with database operations | 处理数据库操作
- Handling authentication/authorization | 处理认证/授权

## Project Structure | 项目结构

```
backend/
├── src/
│   ├── routes/          # Express route handlers | Express 路由处理器
│   ├── services/        # Business logic | 业务逻辑
│   ├── models/          # Database models | 数据库模型
│   ├── middleware/      # Auth, validation, etc. | 认证、验证等
│   └── utils/           # Helper functions | 辅助函数
```

## API Response Format | API 响应格式

### Success Response | 成功响应
```typescript
res.status(200).json({
  success: true,
  data: { ... }
});
```

### Error Response | 错误响应
```typescript
res.status(400).json({
  success: false,
  error: {
    code: 'VALIDATION_ERROR',
    message: 'User-friendly error message' // 用户友好的错误信息
  }
});
```

## Error Handling Pattern | 错误处理模式

```typescript
// Always use try-catch with async handlers | 异步处理器始终使用 try-catch
export const handler = async (req: Request, res: Response) => {
  try {
    const result = await someService.doSomething();
    res.json({ success: true, data: result });
  } catch (error) {
    console.error('Handler error:', error);
    res.status(500).json({
      success: false,
      error: { code: 'INTERNAL_ERROR', message: 'Something went wrong' }
    });
  }
};
```

## Input Validation | 输入验证

```typescript
// Validate request body/params before processing | 处理前验证请求体/参数
if (!req.body.userId || !req.body.message) {
  return res.status(400).json({
    success: false,
    error: { code: 'MISSING_PARAMS', message: 'userId and message are required' }
  });
}
```

## Security Checklist | 安全检查清单

- [ ] Never expose sensitive data in responses | 响应中不暴露敏感数据
- [ ] Validate and sanitize all user input | 验证和净化所有用户输入
- [ ] Use parameterized queries (no SQL injection) | 使用参数化查询（防止 SQL 注入）
- [ ] Authenticate protected endpoints | 保护端点需要认证
- [ ] Rate limit public endpoints | 公共端点需要限流
