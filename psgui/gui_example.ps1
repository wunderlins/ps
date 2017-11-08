#Write-Host $MyInvocation.MyCommand.Path
$content = [IO.File]::ReadAllText("$PSScriptRoot\..\wpf_2\wpf_2\MainWindow.xaml")
$guiXML = $content -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
#Write-Host $guiXML

[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $guiXML
#Read XAML
 
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try{
    $Form=[Windows.Markup.XamlReader]::Load( $reader )
} catch{
    Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."
}


#===========================================================================
# Load XAML Objects In PowerShell
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
Function Get-FormVariables{
    if ($global:ReadmeDisplay -ne $true) {
        Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true
    }
    write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
    get-variable WPF*
}

# enable this line to get a list of adressable objects 
#Get-FormVariables
<#
Name                           Value                                                                
----                           -----                                                                
WPFbtn_cancel                  System.Windows.Controls.Button: Cancel                               
WPFbtn_save                    System.Windows.Controls.Button: Save                                 
WPFlbl_name                    System.Windows.Controls.Label: Name                                  
WPFtxt_name                    System.Windows.Controls.TextBox: TextBox                             
#>

#===========================================================================
# Initialize the form
$WPFtxt_name.Text = 'Hello World'

# close form when cancel is clicked
$WPFbtn_cancel.Add_Click({$form.Close()})

# event handler to get data from text input field
$WPFbtn_save.Add_Click({
    Write-Host $WPFtxt_name.Text
})

#===========================================================================
# Shows the form
$Form.ShowDialog() | out-null