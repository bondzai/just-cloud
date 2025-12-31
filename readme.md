# NestJS with Swagger, Docker, and Vercel

This project is a NestJS application with built-in Swagger documentation, Docker support, and Vercel deployment configuration.

## Features
- **Swagger Documentation**: Available at `/api`.
- **Health Check**: Endpoint at `/health`.
- **Docker**: Optimized multi-stage build.
- **Vercel**: Configured for serverless deployment.

## Development

```bash
npm install
npm run start:dev
```

## Docker
```bash
docker build -t nest-app .
docker run -p 3000:3000 nest-app
```