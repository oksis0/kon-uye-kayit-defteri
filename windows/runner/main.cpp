#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  // Ensure current working directory is the application directory
  // and pass absolute path to DartProject for 100% path safety.
  wchar_t exe_path[MAX_PATH];
  std::wstring data_path = L"data";
  if (::GetModuleFileNameW(nullptr, exe_path, MAX_PATH) > 0) {
    std::wstring path(exe_path);
    size_t last_slash = path.find_last_of(L"\\/");
    if (last_slash != std::wstring::npos) {
      std::wstring dir = path.substr(0, last_slash);
      ::SetCurrentDirectoryW(dir.c_str());
      data_path = dir + L"\\data";
    }
  }

  flutter::DartProject project(data_path);

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"KON Üye Kayıt Defteri", origin, size)) {
    // Write error file for diagnostics
    FILE* f = nullptr;
    _wfopen_s(&f, L"baslatma_hatasi.txt", L"w");
    if (f) {
      fwprintf(f, L"Hata: FlutterWindow::Create basarisiz oldu. data_path: %s\n", data_path.c_str());
      fclose(f);
    }
    ::MessageBoxW(
        nullptr,
        L"Uygulama penceresi başlatılamadı.\n\nLütfen uygulamanın kurulu olduğu klasördeki 'data' klasörünün ve gerekli sistem bileşenlerinin mevcut olduğunu kontrol edin.",
        L"KON Üye Kayıt Defteri",
        MB_ICONERROR | MB_OK);
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
