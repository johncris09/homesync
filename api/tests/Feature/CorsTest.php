<?php

namespace Tests\Feature;

use Tests\TestCase;

class CorsTest extends TestCase
{
    public function test_only_the_configured_web_origin_may_call_the_api(): void
    {
        config(['cors.allowed_origins' => ['https://homesync.pages.dev']]);
        $preflight = fn (string $origin) => $this->call('OPTIONS', '/api/sync/pull', server: [
            'HTTP_ORIGIN' => $origin,
            'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET',
            'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' => 'authorization,x-homesync-protocol',
        ]);

        $preflight('https://homesync.pages.dev')
            ->assertHeader('Access-Control-Allow-Origin', 'https://homesync.pages.dev');
        // Another origin never gets itself back, so the browser blocks it.
        $this->assertNotSame('https://evil.example', $preflight('https://evil.example')->headers->get('Access-Control-Allow-Origin'));
    }
}
