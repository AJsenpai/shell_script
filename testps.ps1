# Load necessary .NET assemblies for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create form and set properties
$form = New-Object System.Windows.Forms.Form
$form.Text = "Remote Server Connector"
$form.Size = New-Object System.Drawing.Size(400, 300)

# Create text boxes and labels for server name, username, and password
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
$submitButton.Add_Click({
    # Retrieve entered values
    $server = $textBoxServer.Text
    $username = $textBoxUsername.Text
    $password = $textBoxPassword.Text | ConvertTo-SecureString -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential($username, $password)

    # Check connection
    try {
        $session = New-PSSession -ComputerName $server -Credential $creds -ErrorAction Stop
        [System.Windows.Forms.MessageBox]::Show("Connected successfully to $server", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        $form.Hide()
        ShowServerActions $session
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to connect: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})
$form.Controls.Add($submitButton)

# Function to display the server actions
function ShowServerActions {
    param ($session)

    # Create form for server actions
    $actionForm = New-Object System.Windows.Forms.Form
    $actionForm.Text = "Server Actions"
    $actionForm.Size = New-Object System.Drawing.Size(300, 200)

    # Button to download a file
    $downloadButton = New-Object System.Windows.Forms.Button
    $downloadButton.Text = "Download File"
    $downloadButton.Location = New-Object System.Drawing.Point(50, 20)
    $downloadButton.Add_Click({
        $remotePath = [System.Windows.Forms.MessageBox]::Show("Enter remote file path:", "Download File", [System.Windows.Forms.MessageBoxButtons]::OKCancel, [System.Windows.Forms.MessageBoxIcon]::Information)
        if ($remotePath -ne "") {
            $localPath = [System.Windows.Forms.MessageBox]::Show("Enter local save path:", "Save File", [System.Windows.Forms.MessageBoxButtons]::OKCancel, [System.Windows.Forms.MessageBoxIcon]::Information)
            if ($localPath -ne "") {
                Copy-Item -Path $remotePath -Destination $localPath -FromSession $session
                [System.Windows.Forms.MessageBox]::Show("File downloaded successfully.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            }
        }
    })
    $actionForm.Controls.Add($downloadButton)

    # Button to display running services
    $servicesButton = New-Object System.Windows.Forms.Button
    $servicesButton.Text = "Show Running Services"
    $servicesButton.Location = New-Object System.Drawing.Point(50, 60)
    $servicesButton.Add_Click({
        $services = Invoke-Command -Session $session -ScriptBlock { Get-Service | Where-Object { $_.Status -eq 'Running' } }
        [System.Windows.Forms.MessageBox]::Show(($services | Out-String), "Running Services", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    })
    $actionForm.Controls.Add($servicesButton)

    # Button to display memory and CPU usage
    $resourceButton = New-Object System.Windows.Forms.Button
    $resourceButton.Text = "Show Memory & CPU Usage"
    $resourceButton.Location = New-Object System.Drawing.Point(50, 100)
    $resourceButton.Add_Click({
        $usage = Invoke-Command -Session $session -ScriptBlock {
            Get-WmiObject Win32_Processor | Select-Object Name, LoadPercentage
            Get-WmiObject Win32_OperatingSystem | Select-Object TotalVisibleMemorySize, FreePhysicalMemory
        }
        [System.Windows.Forms.MessageBox]::Show(($usage | Out-String), "Memory & CPU Usage", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    })
    $actionForm.Controls.Add($resourceButton)

    $actionForm.ShowDialog()
}

# Show initial form
$form.ShowDialog()
