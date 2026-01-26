export DEV_WIKI="/home/sy/Documents/dev-wiki"
export JOB_WIKI="/home/sy/Documents/job-wiki"


docup() {
    current_path=$(pwd)

    read -p "Will you update english study note? (y/n)" answer
    if [ "$answer" = "y" ]; then
      _update_readme_with_english_study_note
    fi

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

_update_readme_with_english_study_note() {
    local source_dir="$DEV_WIKI/notes/Area/나를_사랑하기/from_codecompanion_conversation"
    local readme_file="$DEV_WIKI/README.md"

    # Check if src directory exist
    if [ ! -d "$source_dir" ]; then
        echo "Error: Source directory '$source_dir' does not exist."
        return 1
    fi

    # Step 1: Get the last file's path by checking filename (assuming date format)
    local latest_file=$(find "$source_dir" -type f -name "*" | sort | tail -n 1)

    if [ -z "$latest_file" ]; then
        echo "No files found in $source_dir"
        return 1
    fi

    # Step 2: update readme with new study
    yes | cp -f "$latest_file" "$readme_file"

    if [ $? -ne 0 ]; then
        echo "Error copying file."
        return 1
    fi
}
