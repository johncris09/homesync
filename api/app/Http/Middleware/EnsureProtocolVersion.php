<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Every app request sends X-HomeSync-Protocol. An app older than the server
 * supports gets 426 and pauses sync with an "Update the app" message.
 */
class EnsureProtocolVersion
{
    public function handle(Request $request, Closure $next): Response
    {
        $sent = $request->header('X-HomeSync-Protocol');
        $min = (int) config('homesync.min_protocol');

        if ($sent === null || ! ctype_digit($sent) || (int) $sent < $min) {
            return response()->json([
                'message' => 'This version of the app is too old to sync. Update the app.',
                'min_protocol' => $min,
            ], 426);
        }

        return $next($request);
    }
}
