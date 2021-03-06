#!/bin/bash

## Setup:
# Your local git repo will require 2 remotes to be setup:
# * PUSH_REMOTE : this will be the remote you can push directly to
# * UPSTREAM_REMOTE : this will be the remote you start feature branches off of and open pull requests to
# These remotes can point to the same repo.
#
# Update the git-*-pr functions to use correct URL for Pull Requests

# Settings for using gitflow with central repo
# PUSH_REMOTE=origin
# UPSTREAM_REMOTE=origin
# UPSTREAM_BRANCH=develop

# Settings for opening pull requests to different repos that only use master (ex: many Open Source projects)
PUSH_REMOTE=origin # Push Destination Remote
UPSTREAM_REMOTE=upstream # Pull Request Destination Remote
UPSTREAM_BRANCH=master # Pull Request Destination Branch

git-feature-start() {
    if [ "$(is-working-copy-clean)" = "false" ]; then
        echo -e "\e[1;31mERROR!\e[0m: Working Copy is not clean"
        return
    fi
    fetch-all

    if ! [ "${3}" = "" ]; then
        local BRANCHFROM="${3}"
    else
        if [ "${1}" = "START" ]; then
            local BRANCHFROM="${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}"
        elif [ "${1}" = "RESTART" ]; then
            local BRANCHFROM="${PUSH_REMOTE}/$2"
        fi
    fi

    if [ "${1}" = "START" ]; then
        local TR="${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}"
    elif [ "${1}" = "RESTART" ]; then
        if [ "${3}" = "" ]; then
            local TR="${BRANCHFROM}"
        elif [[ "${3}" == "${PUSH_REMOTE}/"* ]] || [[ "${A}" == "${UPSTREAM_REMOTE}/"* ]]; then
            local TR="${3}"
        else
            local TR="${PUSH_REMOTE}/${3}"
        fi
    fi

    set -e
    git checkout --no-track ${BRANCHFROM} -b $2
    git branch -u ${TR}
}

git-feature-end() {
    local BR=`current-branch`
    if [ "$(is-feature-branch ${BR})" = "false" ]; then
        echo -e "\e[1;31mERROR!\e[0m: Not on a feature branch"
        return
    fi

    # Removed - conflicts with set upstream not being default in feature-push
    # if ! [ "${1}" = "--force" ]; then
    #     local TR=`current-tracking-branch`
    #     local COMMITS_NOT_PUSHED=`git log --oneline \`git rev-parse ${BR}\` ^\`git rev-parse ${TR}\` | wc -l`
    #     if ! [ "${COMMITS_NOT_PUSHED}" = "0" ]; then
    #         echo -e "\e[1;31mERROR!\e[0m: local feature branch has commits not pushed (use --force to delete anyway)"
    #         return
    #     fi
    # fi
    #
    local LOCAL_DEVELOP_BR=`git branch | sed -rn "s/^ *(${UPSTREAM_BRANCH})$/\1/p"`
    fetch-all
    if [ "${LOCAL_DEVELOP_BR}" = "${UPSTREAM_BRANCH}" ]; then
        git checkout ${UPSTREAM_BRANCH}
        git merge @{u} --ff-only
    else
        git checkout --track ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH} -b ${UPSTREAM_BRANCH}
    fi

    git branch -D $BR
}

git-feature-pr() {
    local BR_REV=`git rev-parse HEAD`
    local TR_REV=`git rev-parse ${PUSH_REMOTE}/${1}`
    if ! [ "${BR_REV}" = "${TR_REV}" ]; then
        echo -e "\e[1;31mERROR!\e[0m: Push Failed"
    else
        # GitHub
        git-feature-github-pr $TR
        # BitBucket
        git-feature-bitbucket-pr $TR
    fi
}

git-feature-github-pr() {
    local UPSTREAM_OWNER=`get-github-remote-part ${UPSTREAM_REMOTE} 1`
    local UPSTREAM_REPO=`get-github-remote-part ${UPSTREAM_REMOTE} 2`
    local PUSH_OWNER=`get-github-remote-part ${PUSH_REMOTE} 1`
    if [ "${UPSTREAM_OWNER}" = "" ]; then
        echo -e "\e[1;31mERROR!\e[0m: remote ${UPSTREAM_REMOTE} not found!"
    else
        # Windows: Create ~/bin/firefox.bat, and change command to "firefox.bat"
        #     @"c:\Program Files (x86)\Mozilla Firefox\firefox.exe" %*
        firefox "https://github.com/${UPSTREAM_OWNER}/${UPSTREAM_REPO}/compare/${UPSTREAM_BRANCH}...${PUSH_OWNER}:${1}"
    fi
}

get-github-remote-part() {
    local REMOTE_NAME=$1
    local PART_NUM=""\\${2}""
    git remote -v | sed -rn 's/(\.git)? \(fetch\).*$//p' | sed -rn "s|^${REMOTE_NAME}\s.*https://github.com/([^/]*)/([^/]*)$|${PART_NUM}|p"
}

git-feature-bitbucket-pr() {
    local UPSTREAM_PROJECT=`get-bitbucket-remote-part ${UPSTREAM_REMOTE} 1`
    local UPSTREAM_REPO=`get-bitbucket-remote-part ${UPSTREAM_REMOTE} 2`
    local PUSH_PROJECT=`get-bitbucket-remote-part ${PUSH_REMOTE} 1`
    local PUSH_REPO=`get-bitbucket-remote-part ${PUSH_REMOTE} 2`
    local PUSH_BRANCH="${1}"
    if [ "${UPSTREAM_PROJECT}" = "" ]; then
        echo -e "\e[1;31mERROR!\e[0m: remote ${UPSTREAM_REMOTE} not found!"
    else
        # Windows: Create ~/bin/firefox.bat, and change command to "firefox.bat"
        #     @"c:\Program Files (x86)\Mozilla Firefox\firefox.exe" %*
        firefox "https://bitbucket.org/${PUSH_PROJECT}/${PUSH_REPO}/branches/compare/${PUSH_PROJECT}/${PUSH_REPO}:${PUSH_BRANCH}%0D${UPSTREAM_PROJECT}/${UPSTREAM_REPO}:${UPSTREAM_BRANCH}"
    fi
}

get-bitbucket-remote-part() {
    local REMOTE_NAME=$1
    local PART_NUM="\\${2}"

    git remote -v \
        | sed -rn "s,^${REMOTE_NAME}.*(https|ssh)://([^@]*@)?bitbucket.org(:7999)?/,,p" \
        | sed -rn "s|/?(\.git)? \(fetch\).*$||p" \
        | sed -rn "s|([^/]*)/([^/]*)|${PART_NUM}|p"
}

git-feature-push() {
    if [ "${1}" = "PR" ]; then
        local DO_PR="true"
    else
        local DO_PR="false"
    fi
    shift

    local TR=""
    local OPTS=""
    for arg; do
        if ! [ "$(echo ${arg} | sed -n '/^-/p')" = "" ]; then
            if [ "$arg" = "--track" ] || [ "$arg" = "-u" ]; then
                OPTS="${OPTS} -u"
            else
                echo -e "\e[1;31mERROR!\e[0m: Unknown arg: $arg"
                return
            fi
        else
            if [ "${TR}" = "" ]; then
                TR="${arg}"
            else
                echo -e "\e[1;31mERROR!\e[0m: Cannot push to multiple branches"
                return
            fi
        fi
    done

    local BR=`current-branch`
    if [ "$(is-feature-branch ${BR})" = "false" ]; then
        echo -e "\e[1;31mERROR!\e[0m: Not on a feature branch"
        return
    fi
    if [ "${TR}" = "" ]; then
        local TR=`current-tracking-branch | sed 's,^[^/]*/,,'`
        if [ "$(is-feature-branch ${TR})" = "false" ]; then
            # Chop off -1234  or -1234-2  or -1234-v2 from branch name.
            # To disable chop off, change to TR="${BR}"
            TR=`echo ${BR} | sed -r 's/-[0-9-]*(-v[0-9]+)?$//'`
        fi
    fi
    # echo UpstreamBranch=$TR
    # echo CurrentBranch=$BR
    git push ${PUSH_REMOTE} ${OPTS} ${BR}:${TR}

    if [ "${DO_PR}" = "true" ]; then
        git-feature-pr $TR
    fi
}

git-feature-mergeable() {
    # Param - branch to merge in
    if [ "$(is-working-copy-clean)" = "false" ]; then
        echo -e "\e[1;31mERROR!\e[0m: Working Copy is not clean"
        return
    fi
    if [ "$(current-branch)" = "" ]; then
        echo -e "\e[1;31mERROR!\e[0m: Not on a branch!"
        return
    fi

    if [ "${1}" = "" ]; then
        local MERGE_BRANCH="${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}"
    elif [ "$(does-branch-exist ${1})" = "true" ]; then
        local MERGE_BRANCH="${1}"
    elif [ "$(does-branch-exist ${PUSH_REMOTE}/${1})" = "true" ]; then
        local MERGE_BRANCH=${UPSTREAM_REMOTE}/${1}
    elif [ "$(does-branch-exist ${UPSTREAM_REMOTE}/${1})" = "true" ]; then
        local MERGE_BRANCH=${PUSH_REMOTE}/${1}
    else
        echo -e "\e[1;31mERROR!\e[0m: Unable to find branch ${1}"
        return
    fi

    local START_HEAD=`git rev-parse HEAD`
    fetch-all
    git merge $MERGE_BRANCH >> /dev/null
    if [ "$(is-working-copy-clean)" = "true" ]; then
        echo -e "\e[1;32mOK!\e[0m $(current-branch) is mergeable with ${MERGE_BRANCH}"
    else
        echo -e "\e[1;31mERROR!\e[0m: $(current-branch) has merge conflicts with ${MERGE_BRANCH}"
        echo "The following files have conflicts:"
        echo -e "$(git diff --name-only | uniq | sed -r 's/^(.*)$/  \\e[1;31m\1\\e[0m/')"
    fi
    git reset --hard $START_HEAD >> /dev/null
}

current-tracking-branch() {
    git branch -vv | sed -rn "s,^\*.*\[(${PUSH_REMOTE}|${UPSTREAM_REMOTE})/,\1/,p" | sed 's/\].*$//' | sed -r 's/:( ahead [0-9]+)?,?( behind [0-9]+)?$//'
}

current-branch() {
    git branch | grep "^* " | sed 's|^* (HEAD detached at .*||' | sed 's|^* \(.*\)|\1|'
}

is-feature-branch() {
    if [ "${1}" = "" ] || [ "${1}" = "${UPSTREAM_BRANCH}" ] || [ "${1}" = "master" ]; then
        echo false
    else
        echo true
    fi
}

is-working-copy-clean() {
    if [ -z "$(git status --porcelain)" ]; then
      echo true
    else
      echo false
    fi
}

does-branch-exist() {
    if [ -z "$(git branch -a | awk '{$1=$1};1' | sed 's,^remotes/,,' | grep -x ${1})" ]; then
        echo false
    else
        echo true
    fi
}

fetch-all() {
    git fetch $UPSTREAM_REMOTE
    if ! [ "${UPSTREAM_REMOTE}" = "$PUSH_REMOTE" ]; then
        git fetch $PUSH_REMOTE
    fi
}

if [ "${1}" = "START" ] || [ "${1}" = "RESTART" ]; then
    git-feature-start $1 $2 $3
elif [ "${1}" = "END" ]; then
    git-feature-end $2
elif [ "${1}" = "PUSH" ] || [ "${1}" = "PR" ]; then
    git-feature-push $@
elif [ "${1}" = "MERGEABLE" ]; then
    git-feature-mergeable $2
fi
