---
name: api-development
description: Node.js/TypeScript API development conventions for TriTalk backend. Use when creating or modifying API endpoints, services, or database operations. | TriTalk 后端的 Node.js/TypeScript API 开发规范。在创建或修改 API 接口、服务或数据库操作时使用。
---

# API Development Skill

Conventions for TriTalk's Node.js/TypeScript backend development.

## When to use

- Creating new API endpoints
- Modifying existing services
- Working with database operations
- Handling authentication/authorization

## Project Structure

```
backend/
├── src/
│   ├── routes/          # Express route handlers
│   ├── services/        # Business logic
│   ├── models/          # Database models
│   ├── middleware/      # Auth, validation, etc.
│   └── utils/           # Helper functions
```

## API Response Format

### Success Response
```typescript
res.status(200).json({
  success: true,
  data: { ... }
});
```

### Error Response
```typescript
res.status(400).json({
  success: false,
  error: {
    code: 'VALIDATION_ERROR',
    message: 'User-friendly error message'
  }
});
```

## Error Handling Pattern

```typescript
// Always use try-catch with async handlers
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

## Input Validation

```typescript
// Validate request body/params before processing
if (!req.body.userId || !req.body.message) {
  return res.status(400).json({
    success: false,
    error: { code: 'MISSING_PARAMS', message: 'userId and message are required' }
  });
}
```

## Security Checklist

- [ ] Never expose sensitive data in responses
- [ ] Validate and sanitize all user input
- [ ] Use parameterized queries (no SQL injection)
- [ ] Authenticate protected endpoints
- [ ] Rate limit public endpoints
