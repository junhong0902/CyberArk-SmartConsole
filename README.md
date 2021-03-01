# CyberArk-SmartConsole

## What to do
1. Copy everything to PSM\Components directory. (Except readme.md)
2. Make sure PSMShadowUsers group have read, write and execute permissions on those files and folders.
3. Edit the paths in PSM-CP-SmartConsoleDisparcher.au3
4. Create a connection components in PVWA and edit the target settings. 

``` 
Ex. "C:\Program Files (x86)\AutoIt3\AutoIt3.exe" "{PSMComponentsFolder}\PSM-CP-SmartConsoleDispatcher.au3" "{PSMComponentsFolder}"
```
