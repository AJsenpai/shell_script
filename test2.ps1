# Ensure CF CLI is installed and logged in
if (-not (Get-Command "cf" -ErrorAction SilentlyContinue)) {
    Write-Host "CF CLI not installed. Please install it first."
    exit
}

# Function to get the latest version of an app
function Get-LatestAppVersion {
    param (
        [string]$appName
    )
    
    # Get the list of apps with similar names
    $apps = cf apps | Select-String -Pattern "^$appName___\d+" | ForEach-Object { $_.Line }

    if ($apps.Count -eq 0) {
        Write-Host "No versions found for app $appName."
        return
    }

    # Sort apps based on the numeric suffix
    $latestApp = $apps | Sort-Object { [int]($_ -replace '^.*___', '') } -Descending | Select-Object -First 1
    return $latestApp
}

# Get the list of all orgs
$orgs = cf orgs | Select-Object -Skip 3 # Skip the first 3 lines which are headers and extra text

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

        foreach ($app in $apps) {
            # Extract the base app name (before ___)
            $baseAppName = ($app -split '___')[0]

            # Get the latest version of the app
            $latestApp = Get-LatestAppVersion -appName $baseAppName

            if ($latestApp) {
                Write-Host "Restaging app: $latestApp"
                cf restage $latestApp
            }
        }
    }
}
