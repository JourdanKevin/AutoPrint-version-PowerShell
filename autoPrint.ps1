##[Ps1 To Exe]
##
##Kd3HDZOFADWE8uO1
##Nc3NCtDXTlaDjrPF8zh45krifkk+esqrq7+p0L2d6v7jqzfQR45aQFd49g==
##Kd3HFJGZHWLWoLaVvnQnhQ==
##LM/RF4eFHHGZ7/K1
##K8rLFtDXTiW5
##OsHQCZGeTiiZ4dI=
##OcrLFtDXTiW5
##LM/BD5WYTiiZ4tI=
##McvWDJ+OTiiZ4tI=
##OMvOC56PFnzN8u+Vs1Q=
##M9jHFoeYB2Hc8u+Vs1Q=
##PdrWFpmIG2HcofKIo2QX
##OMfRFJyLFzWE8uK1
##KsfMAp/KUzWI0g==
##OsfOAYaPHGbQvbyVvnQnqxKgEiZ7Dg==
##LNzNAIWJGmPcoKHc7Do3uAu+DDFlPovL2Q==
##LNzNAIWJGnvYv7eVvnRW8F/hcnoiYNH7
##M9zLA5mED3nfu77Q7TV64AuzAkk+esqrq7+p0OE=
##NcDWAYKED3nfu77Q7TV64AuzAkk+esqrq7+p0OE=
##OMvRB4KDHmHQvbyVvnRH90LgVigqYsnbv7+rwcG18arqtCndTIh0
##P8HPFJGEFzWE8tI=
##KNzDAJWHD2fS8u+Vgw==
##P8HSHYKDCX3N8u+VyDFk7F3nIg==
##LNzLEpGeC3fMu77Ro2k3hQ==
##L97HB5mLAnfMu77Ro2k3hQ==
##P8HPCZWEGmaZ7/K1
##L8/UAdDXTlaDjrPF8zh45krifkk+esqrq7+p0L2d6v7jizfQR45aTExy9g==
##Kc/BRM3KXxU=
##
##
##fd6a9f26a06ea3bc99616d4851b372ba
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
Add-Type -AssemblyName PresentationFramework


[xml]$XML = @'
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Autoprint" Height="150" Width="555">
    <Grid Background="#FFC1C3CB">
        <Label Name="cheminLabel" Content="Chemin" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" Width="130"/>
        <TextBox Name="chemin" HorizontalAlignment="Left" Height="23" Margin="145,10,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="250"/>
        <Button Name="Parcourir" Content="..." HorizontalAlignment="Left" Margin="396,10,0,0" VerticalAlignment="Top" Width="30" Height="23"/>
        <Label Name="CopiLabel" Content="Nombre de copies" HorizontalAlignment="Left" Margin="10,41,0,0" VerticalAlignment="Top" Width="130"/>
        <TextBox Name="Copi" HorizontalAlignment="Left" Margin="145,41,0,0" VerticalAlignment="Top" Width="250" Height="23" Text="1"/>
        <Button Name="ok" Content="Imprimer" HorizontalAlignment="Left" Margin="430,10,0,0" VerticalAlignment="Top" Width="100" Height="85"/>
        <Label Name="extensionLabel" Content="Extension" HorizontalAlignment="Left" Margin="10,72,0,0" VerticalAlignment="Top" Width="130"/>
        <ComboBox Name="extension" HorizontalAlignment="Left" Margin="145,72,0,0" VerticalAlignment="Top" Width="250">
        </ComboBox>
    </Grid>
</Window>
'@
$FormXML = (New-Object System.Xml.XmlNodeReader $XML)
$Window = [Windows.Markup.XamlReader]::Load($FormXML)

$Window.FindName("ok").add_click({
    $Window.Close()
    $script:chemin = $Window.FindName("chemin").Text.ToString()
    $script:copi = $Window.FindName("Copi").Text.ToString()
    $script:extension = $Window.FindName("extension").SelectedItem  
})

$Window.FindName("Parcourir").add_click({
  $objForm = New-Object System.Windows.Forms.FolderBrowserDialog
  $Show = $objForm.ShowDialog()
  if ($Show -eq "OK")
  {
     $Window.FindName("chemin").text =$objForm.SelectedPath 
  }
})

$Window.FindName("chemin").Add_TextChanged({
    $chemintTemp = $Window.FindName("chemin").Text.ToString()
    $allExtension = Get-ChildItem $chemintTemp -Recurse -file | select directoryname, Extension -Unique
    $Window.FindName("extension").Items.Clear()
    $Window.FindName("extension").Items.add("") | out-null
    foreach ($ext in $allExtension){
        $Window.FindName("extension").Items.add($ext.Extension) | out-null
    }
})

$Window.ShowDialog()

$varCheminRepertoireScript = $chemin #repertoire du dossier
$copi = $copi -as [int] #nombre de copie
$extension = $extension

$extension

$MonFolder = Get-ChildItem -Path $varCheminRepertoireScript -File | Where-Object {$_.Name -match "$extension$"} #On récupère la liste des fichiers de ce répertoire
foreach ($MyFile in $MonFolder){
    For($i=0;$i -lt $copi;$i++){ 
        Start-Process -FilePath $MyFile –Verb Print -PassThru | %{sleep 10;$_} | kill
    }    
}