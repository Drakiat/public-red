Set oShell = CreateObject ("Wscript.Shell")
Dim strArgs
strArgs = "cmd /c trail.bat"
oShell.Run strArgs, 0, false
