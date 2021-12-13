

# Usage git-prune-branch [main-branch]
git-prune-branch() {
    local branch="main"
    if [ $# -ne 0 ]; then
        branch=$1
    fi

    git remote prune origin
    git branch --merged | grep -v $branch | xargs git branch -d
}
