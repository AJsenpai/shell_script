Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create a Form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'XML File Parser'
$form.Width = 600
$form.Height = 400
$form.StartPosition = 'CenterScreen'

# Create an OpenFileDialog to select XML file
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Filter = 'XML Files (*.xml)|*.xml|All Files (*.*)|*.*'
$openFileDialog.Title = 'Select an XML File'

# Create a TextBox to display XML content
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Multiline = $true
$textBox.ScrollBars = 'Vertical'
$textBox.Dock = 'Fill'
$form.Controls.Add($textBox)

# Create a Button to open the file dialog
$buttonOpen = New-Object System.Windows.Forms.Button
$buttonOpen.Text = 'Open XML File'
$buttonOpen.Dock = 'Top'
$buttonOpen.Add_Click({
    if ($openFileDialog.ShowDialog() -eq 'OK') {
        $xmlPath = $openFileDialog.FileName
        $xmlContent = [System.IO.File]::ReadAllText($xmlPath)
        $textBox.Text = $xmlContent
    }
})
$form.Controls.Add($buttonOpen)

# Create a Button to parse the XML file and display values
$buttonParse = New-Object System.Windows.Forms.Button
$buttonParse.Text = 'Parse XML'
$buttonParse.Dock = 'Top'
$buttonParse.Add_Click({
    if ($textBox.Text -ne '') {
        try {
            $xmlDoc = [xml]$textBox.Text
            $parsedOutput = $xmlDoc.OuterXml
            $parsedOutput = $parsedOutput -replace '(<[^>]*>)', "`n$1`n"
            $parsedOutput = $parsedOutput -replace '(</[^>]*>)', "`n$1`n"
            [System.Windows.Forms.MessageBox]::Show($parsedOutput, 'Parsed XML Values')
        } catch {
            [System.Windows.Forms.MessageBox]::Show('Error parsing XML file. Please ensure the file is valid XML.', 'Error')
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show('No XML file loaded. Please open an XML file first.', 'Error')
    }
})
$form.Controls.Add($buttonParse)

# Show the Form
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
