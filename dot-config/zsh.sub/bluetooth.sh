
alias blue="bluetui"
_blue() {
    local selected_device
    local mac_address

    # Get devices and let user select with fzf
    selected_device=$(bluetoothctl devices | fzf --prompt="Select Bluetooth device: ")

    # Check if user made a selection
    if [ -z "$selected_device" ]; then
        echo "No device selected."
        return 1
    fi

    # Extract MAC address (second field)
    mac_address=$(echo "$selected_device" | awk '{print $2}')

    # Connect to the selected device
    echo "Connecting to $mac_address..."
    bluetoothctl connect "$mac_address"
}

# Pair with new device
bluepair() {
    local selected_device
    local mac_address

    echo "Starting scan for pairable devices..."
    bluetoothctl scan on &
    scan_pid=$!
    sleep 5

    # Get available devices (excluding already paired ones)
    selected_device=$(bluetoothctl devices Available 2> /dev/null || bluetoothctl devices | fzf --prompt="Select device to pair: ")
    bluetoothctl scan off
    kill $scan_pid 2> /dev/null

    if [ -z "$selected_device" ]; then
        echo "No device selected."
        return 1
    fi

    mac_address=$(echo "$selected_device" | awk '{print $2}')
    echo "Pairing with $mac_address..."
    bluetoothctl pair "$mac_address"
    bluetoothctl connect "$mac_address"
}
