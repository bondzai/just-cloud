import { NestFactory } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ExpressAdapter } from '@nestjs/platform-express';
import { AppModule } from '../src/app.module';
import express from 'express';

const server = express();

export const createServer = async (expressInstance: any) => {
    const app = await NestFactory.create(
        AppModule,
        new ExpressAdapter(expressInstance),
    );

    const config = new DocumentBuilder()
        .setTitle('NestJS Cloud POC')
        .setDescription('Simplest Swagger POC for Docker and Vercel')
        .setVersion('1.0')
        .build();

    const document = SwaggerModule.createDocument(app, config);

    // Vercel specific Swagger fix: Use CDN for UI assets
    // This prevents the "white screen" issue caused by missing local static assets
    SwaggerModule.setup('api', app, document, {
        customCssUrl:
            'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui.min.css',
        customJs: [
            'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui-bundle.js',
            'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui-standalone-preset.js',
        ],
    });

    await app.init();
    return app;
};

createServer(server);

export default server;
