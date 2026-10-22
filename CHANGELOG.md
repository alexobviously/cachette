### 1.1.0
- Bump Dart SDK (3.13.4) and dependencies.
- Code modernisation and style improvements.
- Added lifecycle to `Cachette`, i.e. you can now call `close()` on it. The main reason for this is to dispose a stream controller.

### 1.0.0
- Upgraded to Dart 3; relevant package updates.
- Switched to the `Result` class from [`elegant`](https://pub.dev/packages/elegant), instead of duplicating it here.
- Users system and `UserCachette`: cache entries can now have 'users', which can be used to differentiate between different parts of an application using the entry, and facilitates unused entries to being removed automatically.

### 0.1.1
- Package updates.

### 0.1.0
- Initial version.
