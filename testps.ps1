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
    $actionForm.Size = New-Object System.Drawing.Size(600, 400)
    $actionForm.StartPosition = "CenterScreen"
    $actionForm.FormBorderStyle = 'FixedDialog'
    $actionForm.MaximizeBox = $false

    # Button to download a file
    $downloadButton = New-Object System.Windows.Forms.Button
    $downloadButton.Text = "Download File"
    $downloadButton.Location = New-Object System.Drawing.Point(50, 20)
    $downloadButton.Size = New-Object System.Drawing.Size(250, 40)
    $downloadButton.Add_Click({
        # Start file browsing from the root of the drive
        $currentPath = "D:\"

        # File browsing loop
        while ($true) {
            # Fetch directories and files
            $remoteItems = Invoke-Command -Session $session -ScriptBlock {
                param ($path)
                Get-ChildItem -Path $path | Select-Object Name, FullName, PSIsContainer
            } -ArgumentList $currentPath

            if ($remoteItems) {
                # Display items in a selection dialog
                $fileSelectionForm = New-Object System.Windows.Forms.Form
                $fileSelectionForm.Text = "Browse Files on $serverName - $currentPath"
                $fileSelectionForm.Size = New-Object System.Drawing.Size(600, 400)
                $fileSelectionForm.StartPosition = "CenterScreen"
                $fileSelectionForm.FormBorderStyle = 'FixedDialog'
                $fileSelectionForm.MaximizeBox = $false

                $listBox = New-Object System.Windows.Forms.ListBox
                $listBox.Location = New-Object System.Drawing.Point(10, 10)
                $listBox.Size = New-Object System.Drawing.Size(560, 300)
                foreach ($item in $remoteItems) {
                    $listBox.Items.Add(($item.PSIsContainer ? "[DIR] " : "[FILE] ") + $item.Name)
                }
                $fileSelectionForm.Controls.Add($listBox)

                $navigateBtn = New-Object System.Windows.Forms.Button
                $navigateBtn.Text = "Navigate"
                $navigateBtn.Location = New-Object System.Drawing.Point(50, 320)
                $navigateBtn.Size = New-Object System.Drawing.Size(100, 30)
                $navigateBtn.Add_Click({
                    $selectedItem = $listBox.SelectedItem
                    if ($selectedItem -like "[DIR]*") {
                        $folderName = $selectedItem -replace "\[DIR\] ", ""
                        $currentPath = Join-Path -Path $currentPath -ChildPath $folderName
                        $fileSelectionForm.Close()
                    }
                })
                $fileSelectionForm.Controls.Add($navigateBtn)

                $downloadBtn = New-Object System.Windows.Forms.Button
                $downloadBtn.Text = "Download"
                $downloadBtn.Location = New-Object System.Drawing.Point(170, 320)
                $downloadBtn.Size = New-Object System.Drawing.Size(100, 30)
                $downloadBtn.Add_Click({
                    $selectedItem = $listBox.SelectedItem
                    if ($selectedItem -like "[FILE]*") {
                        $fileName = $selectedItem -replace "\[FILE\] ", ""
                        $remoteFilePath = Join-Path -Path $currentPath -ChildPath $fileName
                        $localPath = "C:\temp\$fileName"

                        # Download the file
                        Invoke-Command -Session $session -ScriptBlock {
                            param ($remotePath, $localPath)
                            Copy-Item -Path $remotePath -Destination $localPath -Force
                        } -ArgumentList $remoteFilePath, $localPath

                        [System.Windows.Forms.MessageBox]::Show("File downloaded successfully to $localPath.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                        $fileSelectionForm.Close()
                    }
                })
                $fileSelectionForm.Controls.Add($downloadBtn)

                $backBtn = New-Object System.Windows.Forms.Button
                $backBtn.Text = "Back"
                $backBtn.Location = New-Object System.Drawing.Point(290, 320)
                $backBtn.Size = New-Object System.Drawing.Size(100, 30)
                $backBtn.Add_Click({
                    $currentPath = [System.IO.Path]::GetDirectoryName($currentPath)
                    if ([string]::IsNullOrEmpty($currentPath)) {
                        $currentPath = "D:\"
                    }
                    $fileSelectionForm.Close()
                })
                $fileSelectionForm.Controls.Add($backBtn)

                $fileSelectionForm.ShowDialog()
            } else {
                [System.Windows.Forms.MessageBox]::Show("No items found in the selected directory.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                break
            }
        }
    })
    $actionForm.Controls.Add($downloadButton)

    # Button to display all services
    $servicesButton = New-Object System.Windows.Forms.Button
    $servicesButton.Text = "Show All Services"
    $servicesButton.Location = New-Object System.Drawing.Point(50, 70)
    $servicesButton.Size = New-Object System.Drawing.Size(250, 40)
    $servicesButton.Add_Click({
        $services = Invoke-Command -Session $session -ScriptBlock {
            Get-Service | Select-Object -Property Name, DisplayName, Status, StartType
        }

        # Create a form to display services
        $servicesForm = New-Object System.Windows.Forms.Form
        $servicesForm.Text = "Services on $serverName"
        $servicesForm.Size = New-Object System.Drawing.Size(600, 400)
        $servicesForm.StartPosition = "CenterScreen"
        $servicesForm.FormBorderStyle = 'FixedDialog'
        $servicesForm.MaximizeBox = $false

        # Create a DataGridView to display services in tabular format
        $dataGridView = New-Object System.Windows.Forms.DataGridView
        $dataGridView.Location = New-Object System.Drawing.Point(10, 10)
        $dataGridView.Size = New-Object System.Drawing.Size(560, 330)
        $dataGridView.AutoSizeColumnsMode = "Fill"
        $dataGridView.DataSource = $services
        $dataGridView.ScrollBars = "Vertical"
        $servicesForm.Controls.Add($dataGridView)

        # Show the services form
        $servicesForm.ShowDialog()
    })
    $actionForm.Controls.Add($servicesButton)

    # Button to display memory and disk usage
    $resourceButton = New-Object System.Windows.Forms.Button
    $resourceButton.Text = "Show Memory & Disk Usage"
    $resourceButton.Location = New-Object System.Drawing.Point(50, 120)
    $resourceButton.Size = New-Object System.Drawing.Size(250, 40)
    $resourceButton.Add_Click({
        # Fetch CPU, Memory, and Disk usage details
        $usage = Invoke-Command -Session $session -ScriptBlock {
            $cpuLoad = Get-WmiObject -Query "SELECT LoadPercentage FROM Win32_Processor" | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
            $totalMem = (Get-WmiObject -Class Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1MB
            $freeMem = (Get-WmiObject Win32_OperatingSystem).FreePhysicalMemory / 1KB
            $usedMem = $totalMem - $freeMem
            $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
            $totalDisk = [math]::round($disk.Size / 1GB, 2)
            $freeDisk = [math]::round($disk.FreeSpace / 1GB, 2)
            $usedDisk = [math]::round($totalDisk - $freeDisk, 2)
            return @{
                CPU = [math]::Round($cpuLoad, 2)
                TotalMem = [math]::Round($totalMem, 2)
                UsedMem = [math]::Round($usedMem, 2)
                FreeMem = [math]::Round($freeMem, 2)
                TotalDisk = $totalDisk
                FreeDisk = $freeDisk
                UsedDisk = $usedDisk
            }
        }

        $usageText = "CPU Load: $($usage.CPU)%`n" +
                     "Total RAM: $($usage.TotalMem) MB`nUsed RAM: $($usage.UsedMem) MB`nFree RAM: $($usage.FreeMem) MB`n" +
                     "Total Disk Space (C:): $($usage.TotalDisk) GB`nFree Disk Space (C:): $($usage.FreeDisk) GB`nUsed Disk Space (C:): $($usage.UsedDisk) GB"
        [System.Windows.Forms.MessageBox]::Show($usageText, "Memory & Disk Usage on $serverName", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    })
    $actionForm.Controls.Add($resourceButton)

    # Show the server actions form
    $actionForm.ShowDialog()
}

# Show the main form
$form.ShowDialog()
