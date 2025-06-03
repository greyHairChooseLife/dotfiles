btkb() {
    if [ "$HOSTNAME" != "Lenovo-ideapad" ] && [ "$HOSTNAME" != "cbpm-labtop" ]; then
        exit 0
    fi

    DEVICE_NAME="AT Translated Set 2 keyboard" # 내장 키보드 이름

    if [ "$1" == "on" ]; then
        echo "Bluetooth 키보드를 사용합니다."
        xinput disable "$DEVICE_NAME"
        setxkbmap -option
        echo "  - 내장 키보드       : 비활성화"
        echo "  - ctrl/capsLck swap : 비활성화"

    elif [ "$1" == "off" ]; then
        echo "내장 키보드를 사용합니다."
        xinput enable "$DEVICE_NAME"

        # 내장 키보드가 활성화될 때까지 최대 10번 시도 (총 5초)
        for i in {1..10}; do
            DEVICE_ID=$(xinput list --id-only "$DEVICE_NAME")
            if [ -n "$DEVICE_ID" ]; then
                break
            fi
            sleep 0.5
        done

        if [ -z "$DEVICE_ID" ]; then
            echo "내장 키보드 ID를 찾을 수 없습니다. [btkb off]를 다시 실행하세요."
            return 1
        fi

        for i in {1..10}; do
            setxkbmap -device "$DEVICE_ID" -option ctrl:swapcaps
            sleep 0.01
        done
        echo "  - 내장 키보드       : 활성화"
        echo "  - ctrl/capsLck swap : 활성화"
    else
        echo "사용법: btkb {on|off}"
        return 1 # 오류 반환
    fi
}

blue() {
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
