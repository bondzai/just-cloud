import { NestFactory } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
    const app = await NestFactory.create(AppModule);

    const config = new DocumentBuilder()
        .setTitle('NestJS Cloud POC')
        .setDescription('Simplest Swagger POC for Docker and Vercel')
        .setVersion('1.0')
        .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api', app, document);

    const port = process.env.PORT || 3000;
    await app.listen(port);
    console.log(`🚀 Application is running on: http://localhost:${port}`);
    console.log(`📄 Swagger UI available at: http://localhost:${port}/api`);
}
bootstrap();
