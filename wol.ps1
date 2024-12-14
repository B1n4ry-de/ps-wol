# Function to send a Wake-on-LAN magic packet
function Send-WOL {
    param (
        [string]$MacAddress,
        [string]$BroadcastAddress = "255.255.255.255"
    )

    # Remove any delimiters like "-" or ":" from the MAC address
    $macAddressClean = $MacAddress -replace "[-:]", ""

    # Validate MAC address length
    if ($macAddressClean.Length -ne 12) {
        Write-Error "Invalid MAC Address format. Ensure it is a 12-character hexadecimal string."
        return
    }

    # Convert MAC address to byte array
    $macBytes = @()
    for ($i = 0; $i -lt $macAddressClean.Length; $i += 2) {
        $macBytes += [byte]("0x" + $macAddressClean.Substring($i, 2))
    }

    # Construct the magic packet (6 x 0xFF followed by 16 repetitions of the MAC address)
    $magicPacket = @([byte]0xFF) * 6 + ($macBytes * 16)

    # Send the magic packet via UDP
    try {
        $udpClient = New-Object System.Net.Sockets.UdpClient
        $udpClient.Connect($BroadcastAddress, 9)  # Port 9 is typically used for WOL
        $udpClient.Send($magicPacket, $magicPacket.Length)
        $udpClient.Close()

        Write-Output "Magic packet sent to $MacAddress via $BroadcastAddress"
    } catch {
        Write-Error "Failed to send the magic packet. Error: $_"
    }
}


# Example usage
Send-WOL -MacAddress "40:A8:F0:5D:4F:A4"
