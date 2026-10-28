#!/bin/sh

# api-url — Convert GitHub file URLs into raw.githubusercontent.com URLs

usage() {
    printf 'Usage: api-url <github-url>\n' >&2
    exit 1
}

[ "$#" -eq 1 ] || usage

url=$1

# Remove query strings and fragments
url=${url%%\#*}
url=${url%%\?*}
url=${url%/}

# Strip GitHub's hostname
case "$url" in
    https://github.com/*) path=${url#https://github.com/} ;;
    http://github.com/*)  path=${url#http://github.com/} ;;
    github.com/*)         path=${url#github.com/} ;;
    *)
        printf 'api-url: not a GitHub URL: %s\n' "$url" >&2
        exit 1
        ;;
esac

# Extract owner and repository
case "$path" in
    */*) ;;
    *) usage ;;
esac

owner=${path%%/*}
rest=${path#*/}
repo=${rest%%/*}

[ -n "$owner" ] && [ -n "$repo" ] || usage

# Get the remaining path
case "$rest" in
    */*) file=${rest#*/} ;;
    *) file="" ;;
esac

[ -n "$file" ] || usage

# Handle /blob/BRANCH/PATH and /tree/BRANCH/PATH
case "$file" in
    blob/*|tree/*)
        file=${file#*/}
        branch=${file%%/*}

        case "$file" in
            */*) file=${file#*/} ;;
            *)
                printf 'api-url: missing file path\n' >&2
                exit 1
                ;;
        esac
        ;;
    *)
        # Short form: assume the default branch is main
        branch=main
        ;;
esac

[ -n "$file" ] || usage

printf 'https://raw.githubusercontent.com/%s/%s/%s/%s\n' \
    "$owner" "$repo" "$branch" "$file"
