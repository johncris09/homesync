/// Release version of this build, set by the release workflow:
/// `--dart-define=APP_VERSION=1.2.3`. Local builds show "dev".
const appVersion = String.fromEnvironment('APP_VERSION', defaultValue: 'dev');

/// Response header naming the hub's release version (sync-protocol §5.4).
const hubVersionHeader = 'x-homesync-version';
