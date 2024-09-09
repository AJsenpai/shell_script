# Load necessary .NET assemblies for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main form and set properties
$form = New-Object System.Windows.Forms.Form
$form.Text = "Remote Server Connector"
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

# Create labels and text boxes for server name, username, and password
$labelServer = New-Object System.Windows.Forms.Label
$labelServer.Text = "Server Name:"
$labelServer.Location = New-Object System.Drawing.Point(10, 20)
$form.Controls.Add($labelServer)

$textBoxServer = New-Object System.Windows.Forms.TextBox
$textBoxServer.Location = New-Object System.Drawing.Point(120, 20)
$textBoxServer.Width = 250
$form.Controls.Add($textBoxServer)

$labelUsername = New-Object System.Windows.Forms.Label
$labelUsername.Text = "Username:"
$labelUsername.Location = New-Object System.Drawing.Point(10, 60)
$form.Controls.Add($labelUsername)

$textBoxUsername = New-Object System.Windows.Forms.TextBox
$textBoxUsername.Location = New-Object System.Drawing.Point(120, 60)
$textBoxUsername.Width = 250
$form.Controls.Add($textBoxUsername)

$labelPassword = New-Object System.Windows.Forms.Label
$labelPassword.Text = "Password:"
$labelPassword.Location = New-Object System.Drawing.Point(10, 100)
$form.Controls.Add($labelPassword)

$textBoxPassword = New-Object System.Windows.Forms.TextBox
$textBoxPassword.Location = New-Object System.Drawing.Point(120, 100)
$textBoxPassword.Width = 250
$textBoxPassword.UseSystemPasswordChar = $true
$form.Controls.Add($textBoxPassword)

# Create a submit button to connect
$submitButton = New-Object System.Windows.Forms.Button
$submitButton.Text = "Connect"
$submitButton.Location = New-Object System.Drawing.Point(150, 140)
$submitButton.Size = New-Object System.Drawing.Size(100, 30)
$submitButton.Add_Click({
    # Retrieve entered values
    $server = $textBoxServer.Text
    $username = $textBoxUsername.Text
    $password = $textBoxPassword.Text | ConvertTo-SecureString -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential($username, $password)

    # Attempt to connect to the remote server
    try {
        $session = New-PSSession -ComputerName $server -Credential $creds -ErrorAction Stop
        [System.Windows.Forms.MessageBox]::Show("Connected successfully to $server", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        $form.Hide()
        ShowServerActions $session $server
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to connect: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})
$form.Controls.Add($submitButton)

# Function to display server actions form
function ShowServerActions {
    param ($session, $serverName)

    # Create form for server actions
    $actionForm = New-Object System.Windows.Forms.Form
    $actionForm.Text = "Server Actions - $serverName"
    $actionForm.Size = New-Object System.Drawing.Size(350, 250)
    $actionForm.StartPosition = "CenterScreen"
    $actionForm.FormBorderStyle = 'FixedDialog'
    $actionForm.MaximizeBox = $false

    # Button to download a file
    $downloadButton = New-Object System.Windows.Forms.Button
    $downloadButton.Text = "Download File"
    $downloadButton.Location = New-Object System.Drawing.Point(50, 20)
    $downloadButton.Size = New-Object System.Drawing.Size(250, 40)
    $downloadButton.Add_Click({
        # Command to open remote file dialog for selecting files from D: drive
        $remoteFiles = Invoke-Command -Session $session -ScriptBlock {
            param ($remotePath)
            [System.Windows.Forms.MessageBox]::Show("Select a file from the D: drive on the remote server.")
            $files = Get-ChildItem -Path $remotePath -File | ForEach-Object { $_.FullName }
            $files
        } -ArgumentList "D:\"
        
        if ($remoteFiles) {
            # Display file selection dialog
            $fileSelectionForm = New-Object System.Windows.Forms.Form
            $fileSelectionForm.Text = "Select File to Download from $serverName"
            $fileSelectionForm.Size = New-Object System.Drawing.Size(400, 300)
            $fileSelectionForm.StartPosition = "CenterScreen"
            $fileSelectionForm.FormBorderStyle = 'FixedDialog'
            $fileSelectionForm.MaximizeBox = $false

            $listBox = New-Object System.Windows.Forms.ListBox
            $listBox.Location = New-Object System.Drawing.Point(10, 10)
            $listBox.Size = New-Object System.Drawing.Size(360, 200)
            $listBox.Items.AddRange($remoteFiles)
            $fileSelectionForm.Controls.Add($listBox)

            $downloadBtn = New-Object System.Windows.Forms.Button
            $downloadBtn.Text = "Download"
            $downloadBtn.Location = New-Object System.Drawing.Point(150, 220)
            $downloadBtn.Size = New-Object System.Drawing.Size(100, 30)
            $downloadBtn.Add_Click({
                $selectedFile = $listBox.SelectedItem
                if ($selectedFile) {
                    $localPath = [System.IO.Path]::Combine([Environment]::GetFolderPath('MyDocuments'), 'Downloads', [System.IO.Path]::GetFileName($selectedFile))
                    Copy-Item -Path $selectedFile -Destination $localPath -FromSession $session
                    [System.Windows.Forms.MessageBox]::Show("File downloaded successfully to $localPath.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                    $fileSelectionForm.Close()
                }
            })
            $fileSelectionForm.Controls.Add($downloadBtn)
            $fileSelectionForm.ShowDialog()
        } else {
            [System.Windows.Forms.MessageBox]::Show("No files available on D: drive.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })
    $actionForm.Controls.Add($downloadButton)

    # Button to display running services
    $servicesButton = New-Object System.Windows.Forms.Button
    $servicesButton.Text = "Show Running Services"
    $servicesButton.Location = New-Object System.Drawing.Point(50, 70)
    $servicesButton.Size = New-Object System.Drawing.Size(250, 40)
    $servicesButton.Add_Click({
        $services = Invoke-Command -Session $session -ScriptBlock {
            Get-Service | Where-Object { $_.Status -eq 'Running' } | Select-Object -Property Name, DisplayName, Status
        }
        $serviceList = $services | Format-Table -AutoSize | Out-String
        [System.Windows.Forms.MessageBox]::Show($serviceList, "Running Services on $serverName", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    })
    $actionForm.Controls.Add($servicesButton)

    # Button to display memory and CPU usage
    $resourceButton = New-Object System.Windows.Forms.Button
    $resourceButton.Text = "Show Memory & Disk Usage"
    $resourceButton.Location = New-Object System.Drawing.Point(50, 120)
    $resourceButton.Size = New-Object System.Drawing.Size(250, 40)
    $resourceButton.Add_Click({
        $usage = Invoke-Command -Session $session -ScriptBlock {
            $cpu = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
            $memory = Get-WmiObject Win32_OperatingSystem
            $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"

            # Format memory and disk space
            $totalMem = [math]::round($memory.TotalVisibleMemorySize / 1MB, 2)
            $freeMem = [math]::round($memory.FreePhysicalMemory / 1MB, 2)
            $usedMem = [math]::round($totalMem - $freeMem, 2)

            $totalDisk = [math]::round($disk.Size / 1GB, 2)
            $freeDisk = [math]::round($disk.FreeSpace / 1GB, 2)
            $usedDisk = [math]::round($totalDisk - $freeDisk, 2)

            "CPU Load: ${cpu}%`n" +
            "Total RAM: ${totalMem} MB`nUsed RAM: ${usedMem} MB`nFree RAM: ${freeMem} MB`n" +
            "Total Disk Space (C:): ${totalDisk} GB`nFree Disk Space (C:): ${freeDisk} GB`nUsed Disk Space (C:): ${usedDisk} GB"
        }
        [System.Windows.Forms.MessageBox]::Show($usage, "Memory & Disk Usage on $serverName", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    })
    $actionForm.Controls.Add($resourceButton)

    # Show the server actions form
    $actionForm.ShowDialog()
}

# Show the main form
$form.ShowDialog()
