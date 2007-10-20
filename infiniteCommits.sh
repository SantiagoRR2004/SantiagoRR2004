#!/usr/bin/env bash

alphabet="abcdefghijklmnopqrstuvwxyz"
fileName="$alphabet.$(echo "$alphabet" | rev)"

initialTime=1192795200
currentTime=$(date +%s)

username="${GITHUB_REPOSITORY_OWNER:-$(git config user.name)}"
userID="${GITHUB_REPOSITORY_OWNER_ID:-}"

if [[ -n "$userID" && -n "$username" ]]; then
    email="${userID}+${username}@users.noreply.github.com"
else
    email="$(git config user.email)"
fi

COLLABORATORS=$(cat collaborators.json)

# Loop until initialTime is greater than currentTime
while
    randomSeconds=$(( 86400 + RANDOM % 86401 ))
    ((initialTime+=randomSeconds))
    ((initialTime < currentTime))
do
    # Add 1 to fileName
    echo -n "1" >> "$fileName"

    randomCollaborator=$(echo "$COLLABORATORS" | jq -r 'to_entries[] | "\(.value.username) \(.value.emailAddress)"' | shuf -n 1)

    read -r randomUsername randomEmail <<< "$randomCollaborator"

    if (( RANDOM % 2 == 0 )); then
        mainUser="$username"
        mainEmail="$email"
        coUser="$randomUsername"
        coEmail="$randomEmail"
    else
        mainUser="$randomUsername"
        mainEmail="$randomEmail"
        coUser="$username"
        coEmail="$email"
    fi

    git add "$fileName"

    GIT_AUTHOR_NAME="$mainUser" \
    GIT_AUTHOR_EMAIL="$mainEmail" \
    GIT_AUTHOR_DATE="$initialTime" \
    GIT_COMMITTER_NAME="$mainUser" \
    GIT_COMMITTER_EMAIL="$mainEmail" \
    GIT_COMMITTER_DATE="$initialTime" \
    git commit \
        -m "Commit" \
        -m "Co-authored-by: $coUser <$coEmail>"

done

git push
