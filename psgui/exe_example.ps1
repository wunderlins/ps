#Write-Host $MyInvocation.MyCommand.Path
$content = @"
<Window x:Class="wpf_2.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:wpf_2"
        mc:Ignorable="d"
        Title="Window" Height="126.229" Width="280.43">
    <Grid Height="83" VerticalAlignment="Top">
        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>
        <Label x:Name="lbl_name" Content="Name" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="txt_name" HorizontalAlignment="Left" Height="23" Margin="85,14,0,0" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="160"/>
        <Button x:Name="btn_cancel" Content="Cancel" HorizontalAlignment="Left" Margin="85,53,0,0" VerticalAlignment="Top" Width="75"/>
        <Button x:Name="btn_save" Content="Save" HorizontalAlignment="Left" Margin="170,53,0,0" VerticalAlignment="Top" Width="75"/>

    </Grid>
</Window>

"@;
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