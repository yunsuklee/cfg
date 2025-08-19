# PowerShell equivalent of ~/.bashrc
# Auto-generated PowerShell profile to replicate bash functionality

#######################################################
# MODERN TOOL REPLACEMENTS WITH FALLBACKS
#######################################################

# Find replacement: fd -> find
if (Get-Command fd -ErrorAction SilentlyContinue) {
    function find { fd @args }
} elseif (Get-Command fd-find -ErrorAction SilentlyContinue) {
    function find { fd-find @args }
}

# Grep replacement: rg -> Select-String
if (Get-Command rg -ErrorAction SilentlyContinue) {
    function grep { rg @args }
} else {
    function grep { Select-String @args }
}

# LS replacement: eza -> Get-ChildItem
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls { eza -a --color=auto --group-directories-first --git --icons @args }
    function ll { eza -la --color=auto --group-directories-first --git --icons @args }
} else {
    function ls { Get-ChildItem -Force @args }
    function ll { Get-ChildItem -Force -Name @args | ForEach-Object { Get-ChildItem -Force $_ } | Format-Table Mode, LastWriteTime, Length, Name }
}

# Cat replacement: bat -> Get-Content
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function cat { bat --style=auto @args }
} else {
    function cat { Get-Content @args }
}

#######################################################
# NAVIGATION WITH AUTO-LS
#######################################################

# CD with auto-ls
function Set-LocationWithList {
    param([string]$Path = "~")
    if ($Path) {
        Set-Location $Path
        ls
    } else {
        Set-Location ~
        ls
    }
}
# Remove existing cd alias if it exists and create new one
if (Get-Alias cd -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cd -Force -ErrorAction SilentlyContinue
}
Set-Alias cd Set-LocationWithList

# Z (zoxide equivalent) with auto-ls - requires zoxide to be installed
if (Get-Command z -ErrorAction SilentlyContinue) {
    function Invoke-ZoxideWithList {
        z @args
        ls
    }
    # Remove existing z alias if it exists and create new one
    if (Get-Alias z -ErrorAction SilentlyContinue) {
        Remove-Item Alias:z -Force -ErrorAction SilentlyContinue
    }
    Set-Alias z Invoke-ZoxideWithList
}

#######################################################
# SAFETY ALIASES
#######################################################

# Safe copy (PowerShell doesn't have -i flag, but we can use -Confirm)
function Copy-ItemSafe {
    Copy-Item -Confirm @args
}
# Remove existing cp alias if it exists and create new one
if (Get-Alias cp -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cp -Force -ErrorAction SilentlyContinue
}
Set-Alias cp Copy-ItemSafe

# Safe move (PowerShell doesn't have -i flag, but we can use -Confirm) 
function Move-ItemSafe {
    Move-Item -Confirm @args
}
Set-Alias mv Move-ItemSafe -Force

# Safe remove using trash if available, otherwise use Remove-Item with confirmation
if (Get-Command trash -ErrorAction SilentlyContinue) {
    function Remove-ItemTrash {
        trash -v @args
    }
    Set-Alias rm Remove-ItemTrash -Force
} else {
    function Remove-ItemSafe {
        Remove-Item -Confirm @args
    }
    Set-Alias rm Remove-ItemSafe -Force
}

#######################################################
# BETTER DEFAULTS
#######################################################

# Mkdir with -p equivalent (Force creates intermediate directories)
function New-DirectoryForce {
    New-Item -ItemType Directory -Force @args
}
Set-Alias mkdir New-DirectoryForce -Force

# RMD equivalent - recursive force remove with verbose
function Remove-DirectoryForce {
    Remove-Item -Recurse -Force -Verbose @args
}
Set-Alias rmd Remove-DirectoryForce -Force

#######################################################
# EDITOR ALIASES
#######################################################

# Neovim aliases
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias vi nvim -Force
    Set-Alias vim nvim -Force
}

#######################################################
# NAVIGATION SHORTCUTS
#######################################################

# Directory navigation shortcuts
function Set-LocationParent { Set-Location .. }
Set-Alias .. Set-LocationParent -Force
Set-Alias cd.. Set-LocationParent -Force

function Set-LocationGrandparent { Set-Location ../.. }
Set-Alias ... Set-LocationGrandparent -Force

function Set-LocationGreatGrandparent { Set-Location ../../.. }
Set-Alias .... Set-LocationGreatGrandparent -Force

function Set-LocationGreatGreatGrandparent { Set-Location ../../../.. }
Set-Alias ..... Set-LocationGreatGreatGrandparent -Force

#######################################################
# PRODUCTIVITY ALIASES
#######################################################

# Clear screen
Set-Alias cl Clear-Host -Force

# File search function (equivalent to find . | grep)
function Find-Files {
    param([string]$Pattern)
    if ($Pattern) {
        if (Get-Command fd -ErrorAction SilentlyContinue) {
            fd $Pattern
        } else {
            Get-ChildItem -Recurse -Name | Where-Object { $_ -match $Pattern }
        }
    } else {
        Write-Host "Usage: f <pattern>"
    }
}
Set-Alias f Find-Files -Force

#######################################################
# CUSTOM FUNCTIONS
#######################################################

# Make directory and enter it
function New-DirectoryAndEnter {
    param([string]$Path)
    if (-not $Path) {
        Write-Host "Usage: mkdirg <directory_path>"
        return
    }
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
    Set-Location $Path
    ls
}
Set-Alias mkdirg New-DirectoryAndEnter -Force

# Copy and go to destination (if directory)
function Copy-ItemAndEnter {
    param([string]$Source, [string]$Destination)
    if (-not $Source -or -not $Destination) {
        Write-Host "Usage: cpg <source> <destination>"
        return
    }
    Copy-Item -Recurse $Source $Destination
    if (Test-Path $Destination -PathType Container) {
        Set-Location $Destination
        ls
    }
}
Set-Alias cpg Copy-ItemAndEnter -Force

# Move and go to destination (if directory)
function Move-ItemAndEnter {
    param([string]$Source, [string]$Destination)
    if (-not $Source -or -not $Destination) {
        Write-Host "Usage: mvg <source> <destination>"
        return
    }
    Move-Item $Source $Destination
    if (Test-Path $Destination -PathType Container) {
        Set-Location $Destination
        ls
    }
}
Set-Alias mvg Move-ItemAndEnter -Force

# Search for text in files
function Find-TextInFiles {
    param([string]$SearchTerm)
    if (-not $SearchTerm) {
        Write-Host "Usage: ftext <search_term>"
        return
    }
    if (Get-Command rg -ErrorAction SilentlyContinue) {
        rg -i -n --color=always $SearchTerm
    } else {
        Get-ChildItem -Recurse -File | Select-String -Pattern $SearchTerm -CaseSensitive:$false
    }
}
Set-Alias ftext Find-TextInFiles -Force

# Detailed ls with file/directory counts
function Get-DetailedListing {
    param([string]$Path = ".")
    
    if (Get-Command eza -ErrorAction SilentlyContinue) {
        eza -la --color=auto --group-directories-first --git --icons --bytes --time-style=long-iso $Path
    } else {
        Get-ChildItem -Force $Path | Format-Table Mode, LastWriteTime, Length, Name -AutoSize
    }
    
    Write-Host ""
    $files = @(Get-ChildItem -Path $Path -File)
    $dirs = @(Get-ChildItem -Path $Path -Directory)
    $totalSize = (Get-ChildItem -Path $Path -Recurse -File | Measure-Object -Property Length -Sum).Sum
    
    # Convert bytes to human readable format
    if ($totalSize -gt 1GB) {
        $sizeStr = "{0:N2} GB" -f ($totalSize / 1GB)
    } elseif ($totalSize -gt 1MB) {
        $sizeStr = "{0:N2} MB" -f ($totalSize / 1MB)
    } elseif ($totalSize -gt 1KB) {
        $sizeStr = "{0:N2} KB" -f ($totalSize / 1KB)
    } else {
        $sizeStr = "$totalSize bytes"
    }
    
    Write-Host "Files: $($files.Count)  Dirs: $($dirs.Count)  Size: $sizeStr"
}
Set-Alias lsc Get-DetailedListing -Force

#######################################################
# ENVIRONMENT SETUP
#######################################################

# Set default editor
$env:EDITOR = "nvim"
$env:VISUAL = "nvim"

#######################################################
# TOOL INITIALIZATION  
#######################################################

# Initialize zoxide if available
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# Initialize starship if available
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (starship init powershell | Out-String) })
}

Write-Host "PowerShell profile loaded with bash-like functionality!" -ForegroundColor Green