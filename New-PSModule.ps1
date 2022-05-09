function Get-TimeStamp {
    <#
        .SYNOPSIS
            Get a time stamp

        .DESCRIPTION
            Get a time date and time to create a custom time stamp

        .EXAMPLE
            None

        .NOTES
            Internal function
    #>

    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
}
function Save-Output {
    <#
    .SYNOPSIS
        Save output to disk

    .DESCRIPTION
        Overload function for Write-Output

    .PARAMETER StringObject
        Inbound object to be printed and saved to log

    .PARAMETER LastRun
        Switch to indicate last logged line

    .EXAMPLE
        None

    .NOTES
        None
    #>

    [Cmdletbinding(DefaultParameterSetName = 'Default')]
    [OutputType('System.String')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $StringObject,

        [string]
        $LoggingDirectory = "C:\PSModuleLogging",

        [string]
        $LogFileName = "PSModuleOutput.log",

        [switch]
        $LastRun
    )

    process {
        try {
            if (-NOT( Test-Path -Path $LoggingDirectory)) { New-Item -Path $LoggingDirectory -ItemType Directory -ErrorAction Stop }
        }
        catch {
            Write-Output "Error: $_"
        }

        try {
            # Console and log file output
            Write-Output $StringObject
            Out-File -FilePath (Join-Path -Path $LoggingDirectory -ChildPath $LogFileName) -InputObject $StringObject -Encoding utf8 -Append -ErrorAction Stop

            if ($LastRun) { Write-Output "Please see $(Join-Path -Path $LoggingDirectory -ChildPath $LogFileName) for more information." }
        }
        catch {
            Write-Output "Error while saving data to $LoggingDirectory"
            return
        }
    }
}

function New-PSModule {
    <#
    .SYNOPSIS
        Create a new PowerShell module

    .DESCRIPTION
        Create a new PowerShell module with full directory structure and function templates

    .PARAMETER ModuleName
        Name of the module

    .PARAMETER Description
        Module description

    .PARAMETER ModuleAuthor
        Name of module author

    .PARAMETER Path
        Save path for module

    .PARAMETER InstallPSFramework
        Switch to indicate that you want to install the PSFramework module
    
    .PARAMETER InstallPSModuleDevelopment
        Switch to indicate that you want to install the PSModuleDevelopment module

    .PARAMETER InstallPSUtil
        Switch to indicate that you want to install the PSUtils module

    .EXAMPLE
        New-PSModule -ModuleName YourModuleName -Description "This is my module" -ModuleAuthor "Author name"

        Creates a new module with your module name, description author

    .EXAMPLE
        New-PSModule -ModuleName YourModuleName -Description "This is my module" -ModuleAuthor "Author name" -Path c:\Temp

        Creates a new module with your module name, description author and save it to the c:\Temp location

    .EXAMPLE
        New-PSModule -ModuleName YourModuleName -Description "This is my module" -ModuleAuthor "Author name" -Path c:\Temp -InstallPSFramework

        Creates a new module with your module name, description author and save it to the c:\Temp location and install the PSFramework with configuration subsystem

    .NOTES
        For more information on PSFramework please visit: http://PSFramework.org
    #>

    [OutputType('System.String')]
    [CmdletBinding(DefaultParameterSetName = 'Default', SupportsShouldProcess = $True)]
    param (
        [parameter(Mandatory = $True, Position = 0, HelpMessage = "Please enter the name for your module.")]
        [string]
        $ModuleName,

        [parameter(Mandatory = $True, Position = 1, HelpMessage = "Please enter the description for your module.")]
        [string]
        $Description,

        [parameter(Mandatory = $True, Position = 2, HelpMessage = "Please enter your name.")]
        [string]
        $ModuleAuthor,

        [string]
        $Path = [environment]::GetFolderPath("MyDocuments"),

        [switch]
        $InstallPSFramework,

        [switch]
        $InstallPSModuleDevelopment,

        [switch]
        $InstallPSUtil
    )

    begin {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Save-Output "$(Get-TimeStamp) - Creating new PowerShell module called $($ModuleName)"
        $rootDirectoriesCreated = $False
        $parameters = $PSBoundParameters
        $rootRirectoriesToCreate = @($ModuleName, '1.0')
        $subDirectoriesToCreate = @('bin', 'docs', 'en-us', 'functions', 'xml', 'internal')
        $internalDirectoriesToCreate = @('configurations', 'functions', 'scriptblocks', 'scripts')
    }

    process {
        if ($parameters.ContainsKey('InstallPSFramework') -or ($parameters.ContainsKey('InstallPSModuleDevelopment') -or ($parameters.ContainsKey('InstallPSUtil')))) {
            
            # Get list of modules to install
            foreach ($param in $parameters.Keys) { 
                if ($param -like "InstallPS*") {
                    [string[]]$moduleToInstall += $param -replace 'Install', ''
                }
            }
            
            foreach ($module in $moduleToInstall) {
                if (-NOT (Get-Module -Name $module -ListAvailable)) {
                    Save-Output "$(Get-TimeStamp) - Checking for the $($module) module"
                    if (Install-Module -Name $module -Repository PowerShellGallery -PassThru -Force -ErrorAction Stop) {
                        Save-Output "$(Get-TimeStamp) - Installing $($module)"
                        if (Import-Module -Name $module -PassThru -ErrorAction Stop) {
                            Save-Output "$(Get-TimeStamp) - Importing $module"
                        }
                    }
                    Save-Output "$(Get-TimeStamp) - For more information about PSFramework please visit: https://PSFramework.org/"
                }
            }
        }

        try {
            Save-Output "$(Get-TimeStamp) - Creating new PowerShell module directory structure"
            foreach ($directory in $rootRirectoriesToCreate) {
                if ($rootDirectoriesCreated) { $newPath = (Join-Path -Path $newPath -ChildPath $directory) } else { $newPath = (Join-Path -Path $Path -ChildPath $directory) }
                if (-NOT( Test-Path -Path $newPath)) {
                    $null = New-Item -Path $newPath -ItemType Directory -ErrorAction Stop
                    Save-Output "$(Get-TimeStamp) - Folder $newPath created!"
                    $rootDirectoriesCreated = $True
                }
                else {
                    Save-Output "$(Get-TimeStamp) - Folder: $($directory) already exists"
                }
            }

            foreach ($directory in $subDirectoriesToCreate) {
                if (-NOT(Test-Path -Path (Join-Path -Path "$Path\$ModuleName\1.0" -ChildPath $directory))) {
                    $null = New-Item -Path (Join-Path -Path "$Path\$ModuleName\1.0" -ChildPath $directory) -ItemType Directory -ErrorAction Stop
                    Save-Output "$(Get-TimeStamp) - Sub folder $(Join-Path -Path "$Path\$ModuleName\1.0" -ChildPath $directory) created!"
                }
                else {
                    Save-Output "$(Get-TimeStamp) - Folder: $($directory) already exists"
                }
            }

            foreach ($directory in $internalDirectoriesToCreate) {
                if (-NOT(Test-Path -Path (Join-Path -Path "$Path\$ModuleName\1.0\internal" -ChildPath $directory))) {
                    $null = New-Item -Path (Join-Path -Path "$Path\$ModuleName\1.0\internal" -ChildPath $directory) -ItemType Directory -ErrorAction Stop
                    Save-Output "$(Get-TimeStamp) - Internal Sub folder $(Join-Path -Path "$Path\$ModuleName\1.0\internal" -ChildPath $directory) created!"
                }
                else {
                    Save-Output "$(Get-TimeStamp) - Folder: $($directory) already exists"
                }
            }
        }
        catch {
            Save-Output "$(Get-TimeStamp) ERROR: $_"
            return
        }

        try {
            Save-Output "$(Get-TimeStamp) - Creating new PowerShell module manifest file"
            $params = @{
                Path              = $("$Path\$ModuleName\1.0\$ModuleName.psd1")
                RootModule        = $ModuleName + ".psm1"
                ModuleVersion     = '1.0'
                Author            = $ModuleAuthor
                Company           = ' '
                Description       = $Description
                FunctionsToExport = "New-Function" # FunctionsToExport will be all of the functions you want to be publicly exposed to the end user
            }

            if ($parameters.ContainsKey('InstallPSFramework')) {
                Save-Output "$(Get-TimeStamp) - Configuring module manifest for for PSFramework"
                $params.RequiredModules = @(@{ModuleName = 'PSFramework'; RequiredVersion = '1.6.205' })
            }

            if (New-ModuleManifest @params -PassThru -ErrorAction Stop) { Save-Output "$(Get-TimeStamp) - New PowerShell module manifest file $($ModuleName).psd1 created" }
            $manifestContent = @'
$script:ModuleRoot = $PSScriptRoot

# Import internal functions and module PSFramework configurations
foreach ($file in (Get-ChildItem "$ModuleRoot\internal" -Filter *.ps1 -Recurse -ErrorAction Ignore)) { . $file.FullName }

# Import Public Functions
foreach ($file in (Get-ChildItem "$ModuleRoot\functions" -Filter *.ps1 -Recurse -ErrorAction Ignore)) { . $file.FullName }

# Import XML View Files
foreach ($file in (Get-ChildItem "$ModuleRoot\xml" -Filter *.ps1 -Recurse -ErrorAction Ignore)) { . $file.FullName }
'@
            Out-File -FilePath (Join-Path -Path "$Path\$ModuleName\1.0" -ChildPath "$($ModuleName).psm1") -InputObject $manifestContent -Encoding utf8 -ErrorAction Stop
            Save-Output "$(Get-TimeStamp) - New PowerShell script file: $($ModuleName).psm1 created"

            $functionWithoutPSFramework = @'
function New-Function {
    <#
        .SYNOPSIS
            Default test function

        .DESCRIPTION
            This is a test module function

        .PARAMETER ParameterOne
            Passed in parameter

        .EXAMPLE
            C:\PS> New-Function -Parameter "This is a test"

            Calls the New-Function method and passes in a string as an argument

        .NOTES
            This method returns a string
    #>

    [OutputType('System.String')]
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
    [string]
    $Parameter
    )

    begin { Write-Verbose "Starting New-Function" }

    process {
        try{
            If($Parameter){ Write-Host "Passed in argument: $Parameter" }
            else{ Write-Host "No argument passed in" }
        }
        catch{
            Write-Host "Error detected: $_"
        }
    }

    end { Write-Verbose "Function Finsihed" }
}
'@

            $functionWithPSFramework = @'
function New-Function {
    <#
        .SYNOPSIS
            Default test function

        .DESCRIPTION
            This is a test module function

        .PARAMETER Parameter
            Passed in parameter

        .EXAMPLE
            C:\PS> New-Function -Parameter "This is a test"

            Calls the New-Function method and passes in a string as an argument

        .NOTES
            This method returns a string
    #>

    [OutputType('System.String')]
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
    [string]
    $Parameter
    )

    begin { Write-Verbose "Starting New-Function" }

    process {
        try{
            If($Parameter){ Write-Host "Passed in argument: $Parameter" }
            else{ Write-Host "No argument passed in" }

            # Pulling value from the PSFramework Configuration
            $moduleName = (Get-ChildItem .\*.psd1).Name -replace ".psd1", ""
            $repository = Get-PSFConfigValue -FullName "$moduleName.PSGallery.Repository"
            $repositoryUrl = Get-PSFConfigValue -FullName "$moduleName.PSGallery.Url"

            Write-Host "Values from local configuration show - PowerShell repository is: $($repository) and the url is: $($repositoryUrl)"
        }
        catch{
            Write-Host "Error detected: $_"
        }
    }

    end { Write-Verbose "Function Finsihed" }
}
'@

            if ($parameters.ContainsKey('InstallPSFramework')) {
                Out-File -FilePath (Join-Path -Path "$Path\$ModuleName\1.0\functions\" -ChildPath "New-Function.ps1") -InputObject $functionWithPSFramework -Encoding utf8 -ErrorAction Stop
            }
            else {
                Out-File -FilePath (Join-Path -Path "$Path\$ModuleName\1.0\functions\" -ChildPath "New-Function.ps1") -InputObject $functionWithoutPSFramework -Encoding utf8 -ErrorAction Stop    <# Action when all if and elseif conditions are false #>
            }

            Out-File -FilePath (Join-Path -Path "$Path\$ModuleName\1.0\internal\functions\" -ChildPath "New-Function.ps1") -InputObject $function -Encoding utf8 -ErrorAction Stop
            Save-Output "$(Get-TimeStamp) - Created new PowerShell script file New-Function.ps1"

            if ($parameters.ContainsKey('InstallPSFramework')) {
                Save-Output "$(Get-TimeStamp) - Configuring module for PSFramework support"
                $configuration = @"
<#
This is an example configuration file

By default, it is enough to have a single one of them,
however if you have enough configuration settings to justify having multiple copies of it,
feel totally free to split them into multiple files.
#>

<#
# Example Configuration
#Set-PSFConfig -Module '$ModuleName' -Name 'TempDirectory' -Value "$($env:Temp)" -Initialize -Validation 'string' -Handler { } -Description "Example configuration setting. Your module can then use the setting using 'Get-PSFConfigValue'"
#>
# Defining PowerShell Gallery Repository
Set-PSFConfig -Module '$ModuleName' -Name 'PSGallery.Repository' -Value "PSGallery" -Initialize -Validation 'string' -Handler { } -Description "PowerShell Gallery Repository"
Set-PSFConfig -Module '$ModuleName' -Name 'PSGallery.Url' -Value "https://www.powershellgallery.com/api/v2" -Initialize -Validation 'string' -Handler { } -Description "PowerShell Gallery Repository Url"
"@
                Out-File -FilePath (Join-Path -Path "$Path\$ModuleName\1.0\internal\configurations" -ChildPath "configurations.ps1") -InputObject $configuration
                Save-Output "$(Get-TimeStamp) - Created new PowerShell configuration file for module created using PSFramework"
            }

            Save-Output "$(Get-TimeStamp) - Creating default XML formatting view"
            $xmlFormat = @"
<?xml version="1.0" encoding="utf-8" ?>

<Configuration>
    <ViewDefinitions>
    <Configuration>
    <ViewDefinitions>
        <!--$($ModuleName).YourFunctionName-->
        <View>
            <Name>$($ModuleName).YourFunctionName</Name>
            <ViewSelectedBy>
                <TypeName>$($ModuleName).YourFunctionName</TypeName>
            </ViewSelectedBy>
            <TableControl>
                <TableHeaders>
                    <TableColumnHeader>
                        <Label>One</Label>
                    </TableColumnHeader>
                    <TableColumnHeader>
                        <Label>Two</Label>
                    </TableColumnHeader>
                    <TableColumnHeader>
                        <Label>Three</Label>
                    </TableColumnHeader>
                    <TableColumnHeader>
                        <Label>Four</Label>
                    </TableColumnHeader>
                    <TableColumnHeader>
                        <Label>Five</Label>
                    </TableColumnHeader>
                </TableHeaders>
                <TableRowEntries>
                    <TableRowEntry>
                        <TableColumnItems>
                            <TableColumnItem>
                                <PropertyName>One</PropertyName>
                            </TableColumnItem>
                            <TableColumnItem>
                                <PropertyName>Two</PropertyName>
                            </TableColumnItem>
                            <TableColumnItem>
                                <PropertyName>Three</PropertyName>
                            </TableColumnItem>
                            <TableColumnItem>
                                <PropertyName>Four</PropertyName>
                            </TableColumnItem>
                            <TableColumnItem>
                                <PropertyName>Five</PropertyName>
                            </TableColumnItem>
                        </TableColumnItems>
                    </TableRowEntry>
                </TableRowEntries>
            </TableControl>
        </View>
    </ViewDefinitions>
</Configuration>
"@
            Out-File -FilePath (Join-Path -Path "$Path\$ModuleName\1.0\xml\" -ChildPath "$($ModuleName).Formats.ps1xml") -InputObject $xmlFormat
            Save-Output "$(Get-TimeStamp) - Created new PowerShell foramts xml template"
        }
        catch {
            Save-Output "$(Get-TimeStamp) ERROR: $_"
            return
        }
    }

    end {
        Save-Output "$(Get-TimeStamp) - Finished creating PowerShell Module." -LastRun:$True
    }
}