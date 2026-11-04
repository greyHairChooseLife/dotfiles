export DEV_WIKI="/home/sy/Documents/dev-wiki"
export JOB_WIKI="/home/sy/Documents/job-wiki"

alias doc='cd ~/Documents/'

docup() {
    current_path=$(pwd)

    for wiki in "$DEV_WIKI" "$JOB_WIKI"; do
        cd "$wiki" || return 1
        git pull

        # MEMO:: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 크래프톤 정글 진행중 특수
        if [ "$wiki" = "$DEV_WIKI" ]; then
            gitpages_deploy="$DEV_WIKI/docs"
            source_to_deploy="$DEV_WIKI/notes/Project/크래프톤_정글"
            rm -rf "$gitpages_deploy"/*
            cp -rf "$source_to_deploy"/* "$gitpages_deploy"
            rm -f "$gitpages_deploy/외부비공개"

            index_md="$gitpages_deploy/index.md"
            if grep -q '^## 비공개' "$index_md"; then
                # "## 비공개"가 등장하는 줄부터 끝까지 삭제
                sed -i '/^## 비공개/,$d' "$index_md"
            fi
        fi
        # MEMO:: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        git add .
        if ! git diff-index --quiet HEAD; then
            git commit -m "write"
            git push
        fi
    done

    cd "$current_path"
}

docpull() {
    current_path=$(pwd)

    for wiki in "$DEV_WIKI" "$JOB_WIKI"; do
        echo "Pulling latest changes in $wiki"
        cd "$wiki" || return 1
        # Save current HEAD
        old_head=$(git rev-parse HEAD)
        git pull
        new_head=$(git rev-parse HEAD)
        if [ "$old_head" != "$new_head" ]; then
            echo "New commits pulled:"
            git log -p "$old_head..$new_head"
        else
            echo "No new commits."
        fi
        echo
    done

    cd "$current_path"
}

alias z='cd $ZK_NOTEBOOK_DIR'
zn() { nvim -c "Zn" }
zf() { nvim -c "Zf" }
zo() { nvim -c "Zo" }
zw() { nvim -c "Zw" }
