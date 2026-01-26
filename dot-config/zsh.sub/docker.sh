# 1. Docker Context 전환 (fzf 활용)
# 사용법: dctx
dctx() {
    # 1. 현재 컨텍스트를 가져오되, 실패하면 'default'로 간주
    local current_context
    current_context=$(docker context show 2> /dev/null || echo "default")

    # 2. 컨텍스트 목록 추출 (NAME 컬럼만 정확히 추출)
    local selection
    selection=$(docker context ls --format "{{.Name}}" | sort \
                                                            | fzf-tmux -p 60% --header "󰛂 Switch Docker Context (Current: $current_context)" \
            --tac \
            --preview "docker context inspect {}" \
            --preview-window "right,60%")

    # 3. 선택 결과에 따른 처리
    if [[ -n "$selection" ]]; then
        docker context use "$selection"
        echo "󰄬 Switched to context: $selection"
    fi
}

# 2. ssh-config 기반 신규 Context 생성
# 사용법: dctx-add
dctx-add() {
    local config_file="$HOME/.ssh/config"
    local host

    # 1. Host 목록 추출 (Host * 제외)
    host=$(grep -E "^Host [^-*]" "$config_file" | awk '{print $2}' \
                                                                 | fzf-tmux -p 60% --header " Select SSH Host to create Docker Context" \
            --preview "sed -n '/^Host {}$/,/^$/p' $config_file" \
            --preview-window "right,60%")

    if [[ -n "$host" ]]; then
        # 이름 입력 (기본값 제공)
        printf "Enter context name (default: %s): " "$host"
        read -r ctx_name
        ctx_name=${ctx_name:-$host}

        # 2. 컨텍스트 생성 시도
        if docker context create "$ctx_name" --docker "host=ssh://$host"; then
            echo "󰄬 Context '$ctx_name' created successfully."

            # 생성 후 바로 전환할지 묻기
            printf "Switch to '$ctx_name' now? [y/N]: "
            read -r opt
            if [[ "$opt" =~ ^[yY]$ ]]; then
                docker context use "$ctx_name"
                echo "󰄬 Switched to $ctx_name"
            fi
        fi
    fi
}

# 3. Context 삭제 모드
# 사용법: dctx-rm
dctx-rm() {
    local contexts
    contexts=$(docker context ls --format "{{.Name}}" | grep -v "default" \
                                                                        | fzf-tmux -p 60% --multi --header " Select Contexts to REMOVE (TAB to multi-select)")

    if [[ -n "$contexts" ]]; then
        echo "$contexts" | xargs -I {} docker context rm {}
        echo "󰛂 Selected contexts removed."
    fi
}
