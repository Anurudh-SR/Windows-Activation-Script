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


<img width="535" height="106" alt="image" src="https://github.com/user-attachments/assets/a50ba055-4f0d-47c1-9cb7-5d485ca91a90" />

Ensure your disk initialization PowerShell script exists at the specified location.
