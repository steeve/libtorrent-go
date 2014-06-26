// Note that the previous declarations of crosscall2/_cgo_allocate/_cgo_panic
// should be commented out. See Makefile.

%insert(runtime) %{
#include <windows.h>
#include <assert.h>

#ifdef __cplusplus
extern "C" {
#endif
void (*crosscall2)(void (*fn)(void *, int), void *, int);
void (*_cgo_allocate)(void *, int);
void (*_cgo_panic)(void *, int);
#ifdef __cplusplus
}
#endif

extern "C" BOOL WINAPI
DllMain (HANDLE hDll, DWORD dwReason, LPVOID lpReserved)
{
    switch (dwReason)
    {
        case DLL_PROCESS_ATTACH:
            HMODULE hModule;
            hModule = GetModuleHandle(NULL);
            crosscall2 = (void (*)(void (*fn)(void *, int), void *, int))GetProcAddress(hModule, "crosscall2");
            assert(crosscall2 != NULL);
            _cgo_allocate = (void (*)(void *, int))GetProcAddress(hModule, "_cgo_allocate");
            assert(_cgo_allocate != NULL);
            _cgo_panic = (void (*)(void *, int))GetProcAddress(hModule, "_cgo_panic");
            assert(_cgo_panic != NULL);
            break;

        case DLL_PROCESS_DETACH:
            break;

        case DLL_THREAD_ATTACH:
            break;

        case DLL_THREAD_DETACH:
            break;
    }
    return TRUE;
}
%}
