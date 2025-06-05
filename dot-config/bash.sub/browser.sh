# alias browser='google-chrome'
alias browser='brave'

google() {
    browser --app="https://www.google.com/search?q=$1"
    exit
}
youtube() {
    if [ -z "$1" ]; then
        browser --app="https://www.youtube.com"
        exit
    fi

    browser --app="https://www.youtube.com/results?search_query=$1"
    exit
}
pacsearch() {
    browser --new-window "https://archlinux.org/packages/?sort=&q=$1&maintainer=&flagged="
    browser "https://aur.archlinux.org/packages?O=0&SeB=nd&K=$1&outdated=&SB=n&SO=a&PP=50&submit=Go"
    exit
}
figma() {
    browser --app="https://www.figma.com/files/recents"
    exit
}
discord() {
    browser --app="https://discord.com/channels/1071395189219938354/1071395190016843912"
    exit
}

google_gmail() {
    browser --app="https://www.gmail.com"
    exit
}
google_calendar() {
    browser --app="https://calendar.google.com/calendar/u/0/r/month"
    exit
}
google_drive() {
    browser --app="https://drive.google.com/drive/my-drive"
    exit
}
google_tasks() {
    browser --app="https://tasks.google.com/embed/?origin=https://calendar.google.com"
    exit
}
google_keep() {
    browser --app="https://keep.google.com"
    exit
}
google_docs_new() {
    browser --app="https://docs.new"
    exit
}
google_sheet_new() {
    # browser --app="https://sheet.new"
    browser --app="https://docs.google.com/spreadsheets/u/0/"
    exit
}

alias G='G_services'
G_services() {
    local services choices browser_cmd
    declare -A services=(
         ["1.Mail"]="https://www.gmail.com"
         ["2.Calendar"]="https://calendar.google.com/calendar/u/0/r/month"
         ["3.Tasks"]="https://tasks.google.com/embed/?origin=https://calendar.google.com"
         ["4.Keep"]="https://keep.google.com"
         ["5.Drive"]="https://drive.google.com/drive/my-drive"
         ["-.Docs"]="https://docs.new"
         ["-.Sheet"]="https://docs.google.com/spreadsheets/u/0/"
         ["-.Hwp"]="https://hwp.polarisoffice.com"
         ["-.All"]="all"
    )

    # 순서를 정의하는 인덱스 배열
    local order=("1.Mail" "2.Calendar" "3.Tasks" "4.Keep" "5.Drive" "-.Docs" "-.Sheet" "-.Hwp" "-.All")

    # fzf를 사용하여 서비스 선택
    choices=$(for i in "${order[@]}"; do echo "$i"; done | fzf --padding 20% --reverse --multi --bind 'tab:toggle-down' --bind 'shift-tab:toggle-up' --header='')

    # 선택된 서비스에 따라 해당 서비스를 확인
    for choice in $choices; do
        if [[ "$choice" == "-.All" ]]; then
            # 'All Services'가 선택되면 모든 서비스를 실행
            for key in "${!services[@]}"; do
                if [[ "${services[$key]}" != "all" ]] && ! [[ "$key" == "-.Docs" || "$key" == "-.Sheet" ]]; then
                    browser --app="${services[$key]}"
                fi
            done
        elif [[ -n "${services[$choice]}" ]]; then
            browser --app="${services[$choice]}"
        else
            echo "No valid service selected or invalid option."
        fi
    done

    exit
}
