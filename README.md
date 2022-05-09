# New-PSModule

This helper script will create a new PowerShell module with PSFramework integration (if selected). I purposely left this as a script file for simplicity. Just
copy the entire script and run one of the following examples

> EXAMPLE 1: New-PSModule -ModuleName YourModuleName -Description "This is my module" -ModuleAuthor "Author name"

        Creates a new module with your module name, description author

> EXAMPLE 2: New-PSModule -ModuleName YourModuleName -Description "This is my module" -ModuleAuthor "Author name" -Path c:\Temp

        Creates a new module with your module name, description author and save it to the c:\Temp location

> EXAMPLE 3: New-PSModule -ModuleName YourModuleName -Description "This is my module" -ModuleAuthor "Author name" -Path c:\Temp -InstallPSFramework

        Creates a new module with your module name, description author and save it to the c:\Temp location and installs PSFramework with configuration subsystem

> EXAMPLE 4: New-PSModule -ModuleName YourModuleName -Description "This is my module" -ModuleAuthor "Author name" -Path c:\Temp -InstallPSModuleDevelopment

        Creates a new module with your module name, description author and save it to the c:\Temp location and installs the PSModuleDevelopment module

> EXAMPLE 5: New-PSModule -ModuleName YourModuleName -Description "This is my module" -ModuleAuthor "Author name" -Path c:\Temp -InstallPSUtil

        Creates a new module with your module name, description author and save it to the c:\Temp location and installs the PSUtil module
        
> EXAMPLE 7: New-PSModule -ModuleName YourModuleName -Description "This is my module" -ModuleAuthor "Author name" -Path c:\Temp -InstallPSFramework -InstallPSModuleDevelopment -InstallPSUtil

        Creates a new module with your module name, description author and save it to the c:\Temp location and installs PSFramework, PSModuleDevelopment and the PSUtil modules with PSFramework configuration

> NOTES: For more information on PSFramework please visit: http://PSFramework.org
