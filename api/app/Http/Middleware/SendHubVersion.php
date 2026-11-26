<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Every API response, errors included, carries X-HomeSync-Version: the hub's
 * release version (docs/sync-protocol.md §5.4). The app shows it next to its own.
 */
class SendHubVersion
{
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);
        $response->headers->set('X-HomeSync-Version', (string) config('homesync.version'));

        return $response;
    }
}
