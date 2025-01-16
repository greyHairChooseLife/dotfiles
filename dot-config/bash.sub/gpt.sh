chatGPT() {
  browser --app="https://chatgpt.com/"
  exit
}
# alias gpt='chatGPT'
alias gpt='chatGPT_services'

alias opChatGPT='openSetOfChatGPT'
openSetOfChatGPT() {
  browser --app="https://chat.openai.com/g/g-zjT7l8NAz-neovim-navigator/c/d47c624f-3a63-4351-8dfc-b2cc30920f0c"   # neovim navigator
  browser --app="https://chat.openai.com/g/g-9B0w1emGR-figma-design-buddy/c/c6e981c9-7929-42a6-b31e-f0110bd38938" # figma design buddy
  browser --app="https://chat.openai.com/g/g-4MDJvo2TJ-video-summarizer/c/bb3f8a1b-cb00-411e-bea8-b084fb0a72bb"   # video summarizer
  browser --app="https://chat.openai.com/g/g-lnTXc3PgP-devops-gpt/c/838579ab-62fe-420a-8f63-f74283551892"         # devops gpt
  browser --app="https://chat.openai.com/g/g-AaCO9ep8Y-linux-specialist/c/07e50f1b-0a7a-4521-9713-15f8acb4da6f"   # linux specialist
  browser --app="https://chat.openai.com/g/g-gsrcNqjyL-git-gpt/c/f49f6f00-db6c-4c39-b47f-cec949ec29fb"            # git gpt
  browser --app="https://chat.openai.com/g/g-n7Rs0IK86-grimoire/c/ab225ac1-8274-4183-ab0c-7d6228e02ce5"           # grimoire
  browser --app="https://chat.openai.com/?model=text-davinci-002-render-sha"                                      # 3.5
  browser --app="https://chat.openai.com/?model=gpt-4"                                                            # 4.0

  browser --app="https://papago.naver.com/?sk=en&tk=ko&hn=1" # papago en -> ko
  browser --app="https://papago.naver.com/?sk=ko&tk=en&hn=1" # papago ko -> en

  exit
}

chatGPT_services() {
  local services choices browser_cmd
  declare -A services=(
    ["1.Basic(o1-mini)"]="https://chatgpt.com/?model=o1-mini"
    ["2.Code"]="https://chatgpt.com/g/g-2DQzU5UZl-code-copilot"
    ["3.Youtube"]="https://chatgpt.com/g/g-4MDJvo2TJ-video-summarizer"
    ["4.Vim"]="https://chatgpt.com/g/g-zjT7l8NAz-neovim-navigator"
    ["5.AWS"]="https://chatgpt.com/g/g-CbdJhMyfi-aws-cloud-architect-developer"
    ["tmp_(o1-mini)"]="https://chatgpt.com/?temporary-chat=true&model=o1-mini"
    ["tmp_(4o)"]="https://chatgpt.com/?temporary-chat=true&model=gpt-4o"
  )

  # 순서를 정의하는 인덱스 배열
  local order=("1.Basic(o1-mini)" "2.Code" "3.Youtube" "4.Vim" "5.AWS" "tmp_(o1-mini)" "tmp_(4o)")

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
