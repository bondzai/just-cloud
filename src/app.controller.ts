import { Controller, Get, Post, Body } from '@nestjs/common';
import { AppService } from './app.service';
import { ApiProperty, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';

class EchoDto {
    @ApiProperty({ example: 'Hello World', description: 'The message to echo back' })
    message: string;
}

@ApiTags('POC Operations')
@Controller()
export class AppController {
    constructor(private readonly appService: AppService) { }

    @Get()
    @ApiOperation({ summary: 'Welcome Message' })
    getHello(): string {
        return this.appService.getHello();
    }

    @Post('echo')
    @ApiOperation({ summary: 'Echo back a message' })
    @ApiResponse({ status: 201, description: 'Message echo successful.' })
    echo(@Body() echoDto: EchoDto) {
        return { echo: echoDto.message, timestamp: new Date().toISOString() };
    }

    @Get('health')
    @ApiOperation({ summary: 'Check API Health' })
    getHealth() {
        return { status: 'ok', environment: process.env.NODE_ENV || 'development' };
    }
}
