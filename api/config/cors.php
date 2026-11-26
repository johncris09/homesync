<?php

/*
| The web app (Cloudflare Pages) calls the hub from another origin. Only the
| origins in CORS_ALLOWED_ORIGINS (comma-separated) may; auth is a bearer
| token, never cookies. Outside production the default is any origin, so a
| local web build can reach a local hub.
*/

$default = env('APP_ENV') === 'production' ? '' : '*';
$origins = array_values(array_filter(array_map('trim', explode(',', (string) env('CORS_ALLOWED_ORIGINS', $default)))));

return [
    'paths' => ['api/*'],
    'allowed_methods' => ['*'],
    'allowed_origins' => $origins,
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => ['X-HomeSync-Version'],
    'max_age' => 86400,
    'supports_credentials' => false,
];
