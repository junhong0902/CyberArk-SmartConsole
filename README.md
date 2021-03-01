# CyberArk-SmartConsole

## What to do
1. Copy everything to PSM\Components directory. (Except readme.md)
2. Create a empty "temp" folder under smartconsole folder.
3. Make sure PSMShadowUsers group have read, write and execute permissions on those files and folders. Check Applocker rule as well.
4. Edit the paths in PSM-CP-SmartConsoleDisparcher.au3
5. Create a connection components in PVWA and edit the target settings. 

``` 
Ex. "C:\Program Files (x86)\AutoIt3\AutoIt3.exe" "{PSMComponentsFolder}\PSM-CP-SmartConsoleDispatcher.au3" "{PSMComponentsFolder}"
```
