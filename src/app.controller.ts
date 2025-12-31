import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';

@ApiTags('poc')
@Controller()
export class AppController {
    constructor(private readonly appService: AppService) { }

    @Get()
    @ApiOperation({ summary: 'Get hello greeting' })
    @ApiResponse({ status: 200, description: 'Return greeting.' })
    getHello(): string {
        return this.appService.getHello();
    }

    @Get('health')
    @ApiOperation({ summary: 'Health check' })
    @ApiResponse({ status: 200, description: 'Service is healthy.' })
    getHealth() {
        return { status: 'ok', timestamp: new Date().toISOString() };
    }
}
