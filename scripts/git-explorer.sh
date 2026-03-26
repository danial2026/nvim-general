#!/bin/bash
# Interactive Git Explorer: commits -> files -> full-file diff

THEME="OneHalfDark"

commit_fzf_state=""
file_fzf_state=""

function commit_view() {
    result=$(git log --graph --decorate --color=always \
        --pretty=format:'%C(blue)%h %C(magenta)%ad %C(reset)%s %C(yellow)%d' \
        --date=short | \
    awk '{gsub(/\*/, "●"); print}' | \
    fzf --ansi --height 40% --reverse --border \
        --query "$commit_fzf_state" \
        --preview-window=right:60%:wrap \
        --preview '
            line=$(echo {} | sed -E "s/^([│├└─●|\/\\ ])+//")
            commit=$(echo "$line" | awk "{print \$1}")
            [ -n "$commit" ] && git show --color=always --stat --pretty=fuller "$commit"
        ' \
        --prompt "Select commit: " \
        --bind "esc:clear-query" \
        --exit-0)

    # If ESC pressed, result is empty -> reset query
    if [ -z "$result" ]; then
        commit_fzf_state=""
    fi

    echo "$result"
}

function file_view() {
    local commit_hash="$1"

    result=$(git diff-tree --no-commit-id -r "$commit_hash" --name-only | \
    fzf --height 40% --reverse --border \
        --query "$file_fzf_state" \
        --preview "
            file={}
            commit='$commit_hash'
            printf \"\n%-70s %-20s %-20s\n\" \"FILE\" \"ADDED\" \"DELETED\"
            git diff --numstat \$commit^! -- \"\$file\" |
            awk '{printf \"%-70s %-20s %-20s\\n\", \$3, \$1, \$2}'
        " \
        --prompt "Select file (ESC to go back): " \
        --bind "esc:abort+clear-query" \
        --exit-0)

    # If ESC pressed, result is empty -> reset query
    if [ -z "$result" ]; then
        file_fzf_state=""
    fi

    echo "$result"
}

while true; do
    commit_line=$(commit_view)
    # ESC in commit view resets the state
    [ -z "$commit_line" ] && commit_fzf_state="" && break

    # extract commit hash
    commit_hash=$(echo "$commit_line" | awk '{
        for(i=1;i<=NF;i++){
            if($i ~ /^[0-9a-f]{7,40}$/){
                print $i
                exit
            }
        }
    }')

    # store only hash, not full line
    commit_fzf_state="$commit_hash"

    # reset file search state whenever you select a new commit
    file_fzf_state=""

    while true; do
        file=$(file_view "$commit_hash")
        # ESC in file view resets file query
        [ -z "$file" ] && file_fzf_state="" && break

        file_fzf_state="$file"

        lang="${file##*.}"
        lang=$(echo "$lang" | awk '{print tolower($0)}')

        git diff "$commit_hash^" "$commit_hash" -- "$file" --color=always \
        | bat --paging=always --style=changes,numbers --theme="$THEME" --language="$lang"
    done
done
