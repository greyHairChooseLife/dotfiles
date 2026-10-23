#!/bin/bash
# dotfiles setup.
#
# 인자 없이 실행하면 단계(숫자)와 feature(알파벳) 목록을 보여주고 선택을 받는다.
# 인자를 주면 그 값을 선택 입력으로 그대로 해석한다.
#
#   ./setup.sh                 목록을 보여주고 선택
#   ./setup.sh 1,3,5           단계 1·3·5만
#   ./setup.sh a,c-f           feature a, c~f 활성화
#   ./setup.sh -e,-h           feature e, h 비활성화
#   ./setup.sh all             단계 1~6 + 미설치 feature 전부
#   ./setup.sh unstow          $HOME에 만든 심볼릭 링크 제거
set -uo pipefail
cd "$(dirname "$(readlink -f "$0")")" || exit 1

STEPS=(yay mirror packages zsh-plugins stow shell)
STEP_DESC=(
    'AUR helper 설치'
    'pacman mirrorlist 갱신 (reflector)'
    '기본 패키지 설치'
    'pure 프롬프트 + fzf-tab 설치'
    'dotfiles를 $HOME에 심볼릭 링크'
    '기본 쉘을 zsh로 변경'
)

FEATURE_DIRS=()
FEATURE_NAMES=()
FEATURE_DESC=()
LETTERS=(a b c d e f g h i j k l m n o p q r s t u v w x y z)

scan_features() {
    local d
    FEATURE_DIRS=()
    FEATURE_NAMES=()
    FEATURE_DESC=()
    for d in features/*/; do
        [ -f "${d}install.sh" ] || continue
        FEATURE_DIRS+=("$d")
        FEATURE_NAMES+=("$(basename "$d")")
        FEATURE_DESC+=("$(awk 'NR>1 && NF {print; exit}' "${d}README.md" 2>/dev/null)")
    done
}

step_state() {
    case "$1" in
        yay) command -v yay >/dev/null 2>&1 && echo installed || echo '-' ;;
        mirror) echo '-' ;;
        packages) echo '-' ;;
        zsh-plugins)
            { [ -d "$HOME/.zsh/pure" ] && [ -d "$HOME/.zsh/fzf-tab" ]; } && echo installed || echo '-'
            ;;
        stow)
            { [ -L "$HOME/.config/nvim" ] && [ -L "$HOME/.pi" ]; } && echo linked || echo '-'
            ;;
        shell) basename "${SHELL:-unknown}" ;;
    esac
}

feature_state() { # $1 = feature index
    if bash "${FEATURE_DIRS[$1]}install.sh" --status >/dev/null 2>&1; then
        echo installed
    else
        echo '-'
    fi
}

trunc() { # $1 text, $2 width
    local t="$1" w="${2:-58}"
    if [ "${#t}" -gt "$w" ]; then
        printf '%s…' "${t:0:$((w - 1))}"
    else
        printf '%s' "$t"
    fi
}

print_menu() {
    local i n
    printf '\n  #   step          state      description\n'
    for i in "${!STEPS[@]}"; do
        printf '  %-3s %-13s %-10s %s\n' "$((i + 1))" "${STEPS[$i]}" "$(step_state "${STEPS[$i]}")" "$(trunc "${STEP_DESC[$i]}" 50)"
    done

    printf '\n  #   feature        state      description\n'
    for i in "${!FEATURE_NAMES[@]}"; do
        printf '  %-3s %-13s %-10s %s\n' "${LETTERS[$i]}" "${FEATURE_NAMES[$i]}" "$(feature_state "$i")" "$(trunc "${FEATURE_DESC[$i]}" 58)"
    done
    printf '\n'
}

letter_index() { # $1 = letter -> feature index, fails when no such feature
    local i
    for i in "${!LETTERS[@]}"; do
        if [ "${LETTERS[$i]}" = "$1" ]; then
            [ "$i" -lt "${#FEATURE_NAMES[@]}" ] || return 1
            echo "$i"
            return 0
        fi
    done
    return 1
}

# ---- 선택 해석 -------------------------------------------------------------

SEL_ALL=0
SEL_QUIT=0
SEL_STEPS=()
SEL_ENABLE=()
SEL_DISABLE=()

add_step_range() { # $1 start, $2 end
    local n
    for ((n = $1; n <= $2; n++)); do
        [ "$n" -ge 1 ] && [ "$n" -le "${#STEPS[@]}" ] && SEL_STEPS+=("$n")
    done
}

add_feature_range() { # $1 start letter, $2 end letter
    local start end i
    start=$(letter_index "$1") || return 1
    end=$(letter_index "$2") || return 1
    for ((i = start; i <= end; i++)); do
        [ -n "${FEATURE_NAMES[$i]:-}" ] && SEL_ENABLE+=("$i")
    done
}

parse_selection() {
    local input="$1" tok
    input="${input//,/ }"

    for tok in $input; do
        case "$tok" in
            all | ALL) SEL_ALL=1 ;;
            q | quit | exit) SEL_QUIT=1 ;;
            -[a-z])
                letter=$(letter_index "${tok#-}") && SEL_DISABLE+=("$letter") ||
                    echo "  ! feature 없음: ${tok#-}" >&2
                ;;
            -*) echo "  ! 알 수 없는 입력: $tok" >&2 ;;
            [0-9]-[0-9]) add_step_range "${tok%-*}" "${tok#*-}" ;;
            [a-z]-[a-z]) add_feature_range "${tok%-*}" "${tok#*-}" || echo "  ! feature 범위 오류: $tok" >&2 ;;
            [0-9])
                if [ "$tok" -ge 1 ] && [ "$tok" -le "${#STEPS[@]}" ]; then
                    SEL_STEPS+=("$tok")
                else
                    echo "  ! 단계 없음: $tok" >&2
                fi
                ;;
            [a-z])
                letter=$(letter_index "$tok") && SEL_ENABLE+=("$letter") ||
                    echo "  ! feature 없음: $tok" >&2
                ;;
            *) echo "  ! 알 수 없는 입력: $tok" >&2 ;;
        esac
    done
}

dedup() {
    printf '%s\n' "$@" | awk 'NF && !seen[$0]++'
}

# ---- 단계 실행 -------------------------------------------------------------

RESULT_ORDER=()
RESULT_STATE=()

record() { # $1 label, $2 ok|fail|skip
    RESULT_ORDER+=("$1")
    RESULT_STATE+=("$2")
}

step_yay() {
    if command -v yay >/dev/null 2>&1; then
        record "1 yay" skip
        return 0
    fi
    bash setup.d/install_yay.sh && record "1 yay" ok || record "1 yay" fail
}

step_mirror() {
    bash setup.d/update_mirror.sh && record "2 mirror" ok || record "2 mirror" fail
}

step_packages() {
    bash setup.d/install_pkgs.sh && record "3 packages" ok || record "3 packages" fail
}

step_zsh_plugins() {
    local ok=0
    mkdir -p "$HOME/.zsh"
    if [ -d "$HOME/.zsh/pure" ]; then
        echo "[skip] $HOME/.zsh/pure 이미 있음"
    else
        git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure" || ok=1
    fi
    if [ -d "$HOME/.zsh/fzf-tab" ]; then
        echo "[skip] $HOME/.zsh/fzf-tab 이미 있음"
    else
        git clone https://github.com/Aloxaf/fzf-tab "$HOME/.zsh/fzf-tab" || ok=1
    fi
    [ "$ok" -eq 0 ] && record "4 zsh-plugins" ok || record "4 zsh-plugins" fail
}

step_stow() {
    if ! command -v stow >/dev/null 2>&1; then
        echo "  ! stow가 없다. 3 packages를 먼저 실행한다." >&2
        record "5 stow" fail
        return 1
    fi
    # plain text 파일이 있으면 stow가 실패한다
    [ -f "$HOME/.Xresources" ] && rm -f "$HOME/.Xresources"
    if stow --target "$HOME" --dotfiles -R .; then
        record "5 stow" ok
    else
        record "5 stow" fail
    fi
}

step_shell() {
    if [ "$(basename "${SHELL:-}")" = "zsh" ]; then
        record "6 shell" skip
        return 0
    fi
    if ! command -v zsh >/dev/null 2>&1; then
        echo "  ! zsh가 없다. 3 packages를 먼저 실행한다." >&2
        record "6 shell" fail
        return 1
    fi
    if chsh -s "$(command -v zsh)"; then
        record "6 shell" ok
        echo "  기본 쉘 변경 완료. 재로그인 후 적용된다."
    else
        record "6 shell" fail
    fi
}

run_step() { # $1 = step number
    case "$1" in
        1) step_yay ;;
        2) step_mirror ;;
        3) step_packages ;;
        4) step_zsh_plugins ;;
        5) step_stow ;;
        6) step_shell ;;
    esac
}

enable_feature() { # $1 = feature index
    local name="${FEATURE_NAMES[$1]}" dir="${FEATURE_DIRS[$1]}"
    if bash "${dir}install.sh"; then
        record "${LETTERS[$1]} $name" ok
    else
        record "${LETTERS[$1]} $name" fail
    fi
}

disable_feature() { # $1 = feature index
    local name="${FEATURE_NAMES[$1]}" dir="${FEATURE_DIRS[$1]}"
    if bash "${dir}uninstall.sh"; then
        record "-${LETTERS[$1]} $name" ok
    else
        record "-${LETTERS[$1]} $name" fail
    fi
}

print_summary() {
    local i state
    printf '\n---- 요약 ----\n'
    for i in "${!RESULT_ORDER[@]}"; do
        state="${RESULT_STATE[$i]}"
        case "$state" in
            ok) printf '  [ok]   %s\n' "${RESULT_ORDER[$i]}" ;;
            skip) printf '  [skip] %s\n' "${RESULT_ORDER[$i]}" ;;
            *) printf '  [FAIL] %s\n' "${RESULT_ORDER[$i]}" ;;
        esac
    done
    printf '\n재로그인하면 쉘/세션 설정이 반영된다.\n'
}

# ---- 진입점 ----------------------------------------------------------------

scan_features

if [ "${1:-}" = "unstow" ]; then
    stow --target "$HOME" --dotfiles -D . && echo "심볼릭 링크를 모두 제거했다."
    exit 0
fi

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
fi

if [ $# -gt 0 ]; then
    selection="$*"
else
    print_menu
    cat <<'EOF'
예)  1,3,5        단계 1·3·5만 실행
     a,c-f        feature a, c~f 활성화
     -e,-h        feature e, h 비활성화
     all          1~6 단계 + 미설치 feature 전부
     q            종료

EOF
    read -rp 'Select (예: 2,5,a-c,-e / all / q): ' selection
fi

parse_selection "$selection"

if [ "$SEL_QUIT" -eq 1 ]; then
    echo "취소."
    exit 0
fi

if [ "$SEL_ALL" -eq 1 ]; then
    for ((n = 1; n <= ${#STEPS[@]}; n++)); do SEL_STEPS+=("$n"); done
    for i in "${!FEATURE_NAMES[@]}"; do
        [ "$(feature_state "$i")" = installed ] || SEL_ENABLE+=("$i")
    done
fi

# 의존 단계 자동 포함
if [ ${#SEL_STEPS[@]} -gt 0 ]; then
    steps_sorted=$(dedup "${SEL_STEPS[@]}" | sort -n)
    SEL_STEPS=($steps_sorted)

    needs_yay=0
    needs_stow=0
    for n in "${SEL_STEPS[@]}"; do
        [ "$n" = 3 ] && ! command -v yay >/dev/null 2>&1 && needs_yay=1
        [ "$n" = 6 ] && [ "$(step_state stow)" != linked ] && needs_stow=1
    done
    if [ "$needs_yay" -eq 1 ]; then
        echo "  + 1 yay 를 함께 실행한다 (3 packages가 필요로 한다)"
        SEL_STEPS=(1 "${SEL_STEPS[@]}")
    fi
    if [ "$needs_stow" -eq 1 ]; then
        echo "  + 5 stow 를 함께 실행한다 (6 shell이 필요로 한다)"
        SEL_STEPS=($(printf '%s\n' "${SEL_STEPS[@]}" 5 | sort -nu))
    fi
fi

SEL_ENABLE=($(dedup "${SEL_ENABLE[@]}"))
SEL_DISABLE=($(dedup "${SEL_DISABLE[@]}"))

if [ ${#SEL_STEPS[@]} -eq 0 ] && [ ${#SEL_ENABLE[@]} -eq 0 ] && [ ${#SEL_DISABLE[@]} -eq 0 ]; then
    echo "실행할 것이 없다."
    exit 0
fi

for n in "${SEL_STEPS[@]}"; do
    run_step "$n"
done

for i in "${SEL_ENABLE[@]}"; do
    enable_feature "$i"
done

for i in "${SEL_DISABLE[@]}"; do
    disable_feature "$i"
done

print_summary
