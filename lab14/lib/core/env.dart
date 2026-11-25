// The only file that knows the variable names. Values are baked in at build
// time with --dart-define / --dart-define-from-file; they are `const`, so the
// branch that is not taken is tree-shaken out of the release binary.
abstract final class Env {
  static const host = String.fromEnvironment(
    'API_HOST',
    defaultValue: 'jsonplaceholder.typicode.com',
  );
  static const useFakes = bool.fromEnvironment('USE_FAKES');
  static const name = String.fromEnvironment('ENV', defaultValue: 'local');
}
