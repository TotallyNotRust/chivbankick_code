import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

// Define the keybd_event function
typedef KeybdEventC = Void Function(
  Uint8 bVk,
  Uint8 bScan,
  Uint32 dwFlags,
  IntPtr dwExtraInfo,
);

typedef KeybdEventDart = void Function(
  int bVk,
  int bScan,
  int dwFlags,
  int dwExtraInfo,
);



class Utils {
  static void paste({bool run = false}) {
    print("Desktop was run");
    if (Platform.isLinux) {
      Utils._linux();
    }
    else if (Platform.isWindows) {
      Utils._windows(run);
    }
    else if (Platform.isMacOS) {

    }

  }

  static void _linux() async {
    // Check if required tool is installed
    final result = await Process.run('which', ['xdotool']);
    if (result.exitCode != 0) {
        throw Exception('xdotool is not installed. Please install it using `sudo apt-get install xdotool`.');
      }
    await Process.run("bash", ["-c", "xdotool search --name \"Chivalry 2\" windowactivate --sync key --clearmodifiers ctrl+v"]);
  }

  static void _windows(bool run) {
    // Change window
    final hwnd = FindWindow("UnrealWindow".toNativeUtf16(), "Chivalry 2  ".toNativeUtf16());


    if (hwnd == 0) {
      throw Exception('Failed to find window: Chivalry 2 not open, or window does not have the correct name.');
    }

    print('Window handle: $hwnd');

    // Bring the window to the foreground
    if (SetForegroundWindow(hwnd) == 0) {
      throw Exception("Failed to focus on window: Chivalry 2 not open, or window does not have the correct name.");
    }

    // Paste, probably a different way to do this but google isnt helping 🤷
    final user32 = DynamicLibrary.open('user32.dll');

    final KeybdEventDart keybdEvent = user32
        .lookupFunction<KeybdEventC, KeybdEventDart>('keybd_event');

    // Simulate pressing 'Ctrl + V'
    keybdEvent(0x11, 0, 0, 0);  // Ctrl key down
    keybdEvent(0x56, 0, 0, 0);  // V key down
    keybdEvent(0x56, 0, 2, 0);  // V key up
    keybdEvent(0x11, 0, 2, 0);  // Ctrl key up

    if (run) {
      keybdEvent(0x0D, 0, 0, 0);
      keybdEvent(0x0D, 0, 2, 0);
    }
  }
}