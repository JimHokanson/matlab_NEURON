typedef unsigned long HWND;

short GetAsyncKeyState(int vKey);

short GetKeyState(int nVirtKey);

long GetWindowThreadProcessId(HWND hwnd);

HWND FindWindowA(int lpClassName, char* lpWindowName); //Note first input is optional, pass in as 0 null

char SetForegroundWindow(HWND hwnd);

int ShowWindow(HWND hWnd, int nCmdShow);


//DWORD WINAPI GetWindowThreadProcessId(
//  __in       HWND hWnd,
//  __out_opt  LPDWORD lpdwProcessId
//);





