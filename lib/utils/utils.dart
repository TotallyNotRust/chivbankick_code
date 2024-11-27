// Import ffi package

export 'utils_stub.dart'
  if (dart.library.ffi) 'desktop.dart'
  if (dart.library.html) 'web.dart';