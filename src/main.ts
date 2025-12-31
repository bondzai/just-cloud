import { NestFactory } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { ExpressAdapter } from '@nestjs/platform-express';
import express from 'express';

const config = new DocumentBuilder()
    .setTitle('NestJS Cloud POC')
    .setDescription('Simplest Swagger POC for Docker and Vercel')
    .setVersion('1.0')
    .build();

function setupSwagger(app: any, isServerless: boolean) {
    const document = SwaggerModule.createDocument(app, config);
    const options = isServerless
        ? {
            customCssUrl:
                'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui.min.css',
            customJs: [
                'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui-bundle.js',
                'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui-standalone-preset.js',
            ],
        }
        : undefined;
    SwaggerModule.setup('api', app, document, options);
}

const server = express();

export const createVercelHandler = async (expressInstance: any) => {
    const app = await NestFactory.create(
        AppModule,
        new ExpressAdapter(expressInstance),
    );
    setupSwagger(app, true);
    await app.init();
    return app;
};

// Vercel Entry Point (Serverless)
if (process.env.VERCEL) {
    createVercelHandler(server);
} else {
    // Local / Docker Entry Point (Standard)
    async function bootstrap() {
        const app = await NestFactory.create(AppModule);
        setupSwagger(app, false);

        const port = process.env.PORT || 3000;
        await app.listen(port);
        console.log(`🚀 Application is running on: http://localhost:${port}`);
        console.log(`📄 Swagger UI available at: http://localhost:${port}/api`);
    }
    bootstrap();
}

export default server;
