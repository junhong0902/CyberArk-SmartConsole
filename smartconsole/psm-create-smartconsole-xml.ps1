﻿###################################################################################################
# Developed by: NSSG
# Date: 2021-02-26
###################################################################################################

<# Testing values - To be removed in Production deployment
#$strUsername = "chkpointadm"
#$strAddress = "1.1.1.2"
#>

# Init
$strUsername = $args[0]
$strAddress = $args[1]
$HexPath = $args[2]
$HexPassword = $args[3]

# Custom functions
function hextostring
{
    # Function params
    Param (
    $hex
    )

	$hex = for($i=0; $i -lt $hex.length; $i+=2)
	{
		[char][int]::Parse($hex.substring($i,2),'HexNumber')
	}

    # Return result
    return (-join $hex)
}

# Convert HexPassword & HexPath to String
$strPassword = hextostring $HexPassword
$smartConsoleFile = hextostring $HexPath


$objXmlWriter = New-Object System.Xml.XmlTextWriter($smartConsoleFile,$null)

# Formatting
$objXmlWriter.Formatting = 'Indented'
$objXmlWriter.Indentation = 1
$objXmlWriter.IndentChar = "`t"

# Write the header and set XLS statements
$objXmlWriter.WriteStartDocument()

# Write the content to xml
$objXmlWriter.WriteStartElement('RemoteLaunchParemeters')
$objXmlWriter.WriteElementString('Username', $strUsername)
$objXmlWriter.WriteElementString('ServerIP', $strAddress)
$objXmlWriter.WriteElementString('Password', $strPassword)
$objXmlWriter.WriteElementString('ReadOnly', 'False')
$objXmlWriter.WriteElementString('CloudDemoMode', 'False')
$objXmlWriter.WriteEndElement()

# Finalize the xml file
$objXmlWriter.WriteEndDocument()
$objXmlWriter.Flush()
$objXmlWriter.Close()

# Wait 10 sec for autoIT to load the xml and delete it after. Delete recursively to make sure the folder is empty
Sleep(10)
write-host (get-item $smartConsoleFile).Directory.FullName
get-childitem (get-item $smartConsoleFile).Directory.FullName -include *.xml -recurse | remove-item -Force -Recurse
