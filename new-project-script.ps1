<#
.SYNOPSIS
  Creates a new project folder from template-base with find-and-replace for all placeholders.
.DESCRIPTION
  Copies the template-base folder to a new project directory, then replaces all
  @PLACEHOLDER@ tokens with user-provided values.
.PARAMETER ProjectName
  The folder name and project name for the new website.
.PARAMETER CompanyName
  Your business name (e.g., "Acme Detailing").
.PARAMETER PrimaryColor
  CSS hex color for primary brand color (e.g., "#d9360e").
.PARAMETER SecondaryColor
  CSS hex color for secondary brand color (e.g., "#ff5722").
.PARAMETER Phone
  Contact phone / WhatsApp number (e.g., "+96599977679").
.PARAMETER Email
  Contact email address.
.PARAMETER Address
  Business street address.
.PARAMETER City
  City / location name.
.PARAMETER HeroTitle
  Main hero heading text.
.PARAMETER HeroSubtext
  Hero subtext paragraph.
.PARAMETER AboutText
  About section description text.
.PARAMETER Year
  Copyright year (default: current year).
.EXAMPLE
  .\new-project.ps1 -ProjectName "MyNewSite" -CompanyName "My Company" -PrimaryColor "#d9360e"
#>

param(
  [Parameter(Mandatory=$true)][string]$ProjectName,
  [Parameter(Mandatory=$true)][string]$CompanyName,
  [string]$PrimaryColor = "#d9360e",
  [string]$PrimaryColorDark = "#b82e0a",
  [string]$PrimaryColorLight = "#ff4f22",
  [string]$PrimaryColorGlow = "rgba(217, 54, 14, 0.15)",
  [string]$Phone = "+96599977679",
  [string]$Email = "info@example.com",
  [string]$Address = "123 Main Street",
  [string]$City = "Your City",
  [string]$HeroSubtext = "Premium services tailored for you.",
  [string]$AboutText = "We are a professional service provider dedicated to quality and customer satisfaction.",
  [string]$Year = (Get-Date).Year
)

$TemplatePath = Join-Path $PSScriptRoot "template-base"
$ProjectPath = Join-Path $PSScriptRoot $ProjectName

if (Test-Path $ProjectPath) {
  Write-Error "Project folder '$ProjectName' already exists."
  exit 1
}

Write-Host "Creating project from template..." -ForegroundColor Green
Copy-Item -Path $TemplatePath -Destination $ProjectPath -Recurse -Force

# Build placeholders hashtable
$replacements = @{
  "@COMPANY_NAME@" = $CompanyName
  "@PRIMARY_COLOR@" = $PrimaryColor
  "@PRIMARY_COLOR_DARK@" = $PrimaryColorDark
  "@PRIMARY_COLOR_LIGHT@" = $PrimaryColorLight
  "@PRIMARY_COLOR_GLOW@" = $PrimaryColorGlow
  "@PHONE_NUMBER@" = $Phone
  "@EMAIL@" = $Email
  "@ADDRESS@" = $Address
  "@CITY@" = $City
  "@HERO_SUBTEXT@" = $HeroSubtext
  "@ABOUT_TEXT@" = $AboutText
  "@YEAR@" = $Year.ToString()
}

# Process all files in the new project folder (excluding node_modules, .vercel output)
$files = Get-ChildItem -Path $ProjectPath -Recurse -File |
  Where-Object { $_.FullName -notmatch 'node_modules|\.vercel\\output|\.git' }

foreach ($file in $files) {
  $content = Get-Content $file.FullName -Raw
  $changed = $false
  foreach ($kv in $replacements.GetEnumerator()) {
    if ($content -match [regex]::Escape($kv.Key)) {
      $content = $content -replace [regex]::Escape($kv.Key), $kv.Value
      $changed = $true
    }
  }
  if ($changed) {
    Set-Content -Path $file.FullName -Value $content -NoNewline
    Write-Host "  Updated: $($file.Name)" -ForegroundColor Yellow
  }
}

Write-Host "`nProject created: $ProjectPath" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. cd $ProjectName" -ForegroundColor White
Write-Host "  2. npm install" -ForegroundColor White
Write-Host "  3. Replace images in images/ folder with your own" -ForegroundColor White
Write-Host "  4. Edit services/*.html to match your offerings" -ForegroundColor White
Write-Host "  5. npm run dev (or npx vercel dev) to preview" -ForegroundColor White
