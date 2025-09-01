# Windows-Activation-Script

This project contains a Windows batch script that automates two tasks:
- **Activating Windows** using license keys stored in a local file.
- **Initializing uninitialized drives** using a separate PowerShell script.

- ##Features

-  Detects if your system is running Windows Home or Pro and selects the correct key file.
-  Grabs an unused Windows key from the configured file, copies it to your clipboard, then marks it as used by appending `*` to the end of the line.
-  Installs and attempts to activate Windows with the fetched key.
-  Calls a configurable PowerShell script to initialize any uninitialized drives.

-  ## How to configure the script

-  assign the path for your Windows key files and disk initialization script to global variables at the top of your batch script:

-  :: ----------- GLOBAL FILE PATHS -----------
set "HOME_KEY_FILE=C:\Users\User\Desktop\win.txt"
set "PRO_KEY_FILE=C:\Users\User\Desktop\win pro.txt"
set "DISK_SCRIPT=C:\Users\User\Desktop\diskini.ps1"
:: -----------------------------------------

Ensure your disk initialization PowerShell script exists at the specified location.
