# Ensure CF CLI is installed and logged in
if (-not (Get-Command "cf" -ErrorAction SilentlyContinue)) {
    Write-Host "CF CLI not installed. Please install it first."
    exit
}

# Function to get the latest version of an app based on the highest numeric suffix
function Get-LatestAppVersion {
    param (
        [string[]]$appList
    )
    
    # Regex to match app names ending with a number (e.g., AppName__12)
    $regex = "^(.*)__([0-9]+)$"
    
    # Filter the apps that match the pattern and extract the numeric suffix
    $appsWithVersion = @()

    foreach ($app in $appList) {
        if ($app -match $regex) {
            $baseName = $matches[1]
            $version = [int]$matches[2]
            $appsWithVersion += [PSCustomObject]@{
                AppName  = $app
                BaseName = $baseName
                Version  = $version
            }
        }
    }

    if ($appsWithVersion.Count -eq 0) {
        Write-Host "No apps found with numeric suffix."
        return $null
    }

    # Group by base name and select the app with the highest version number
    $latestApps = $appsWithVersion | Group-Object -Property BaseName | ForEach-Object {
        $_.Group | Sort-Object -Property Version -Descending | Select-Object -First 1
    }

    return $latestApps
}

# Get the list of all orgs
$orgs = cf orgs | Select-Object -Skip 3 # Skip the first 3 lines (headers and extra text)

foreach ($org in $orgs) {
    Write-Host "Switching to Org: $org"
    cf target -o $org

    # Get the list of spaces in the org
    $spaces = cf spaces | Select-Object -Skip 3

    foreach ($space in $spaces) {
        Write-Host "Switching to Space: $space"
        cf target -s $space

        # Get the list of apps in the space
        $apps = cf apps | Select-Object -Skip 4 # Skip the first 4 lines (headers and extra text)

        # Find the latest version for each app group
        $latestApps = Get-LatestAppVersion -appList $apps

        if ($latestApps) {
            foreach ($app in $latestApps) {
                Write-Host "Restaging app: $($app.AppName)"
                cf restage $app.AppName
            }
        }
    }
}