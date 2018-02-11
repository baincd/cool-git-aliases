# Git Feature

git commands designed to make it easier to follow feature-based workflows (such as Gitflow and Trunk Based Development).  

## Usage
* `git feature-start <feature>`
    * Fetch from all remotes
    * Then create local branch `<feature>`, branching off of and tracking upstream/develop
* `git feature-restart <feature>`
    * Same as feature-start, except branch off of and track `origin/<feature>`
* `git feature-push [<push-to-branch>] [-u | --track]` - push to origin
    * IF set, `<push-to-branch>` will be used as the branch to push to
    * ELSE use existing tracking branch if set AND is not origin/develop, origin/master, upstream/develop, or upstream/master
    * ELSE use local branch name, chopping off ticket numbers ("-123", "-123-456") and version numbers ("-v2") off the end.
        * abc -> abc
        * abc123 -> abc123
        * abc-123 -> abc
        * abc-123-456 -> abc
        * abc-123-v4 -> abc
        * abc99-123 -> abc99
    * IF `-u` or `--track` is used, the local branch will track the remote branch
* `git feature-pr [<push-to-branch>]`
    * Execute feature-push
    * Then open Pull Request
* `git feature-end`
    * Fetch from all remotes
    * THEN Checkout local develop branch
        * IF local develop branch does exist, checkout develop and attempt fast forword upstream/develop
        * ELSE create local develop branch, branching off of upstream/develop
    * THEN delete the feature branch
* `git feature-mergeable [<branch>]` - Check if the current branch is mergeable with another branch
    * IF `<branch>` is not set, default to upstream/develop
    * ELSE use local branch `<branch>` if exists
    * ELSE use upstream/&lt;branch&gt; if exists
    * ELSE use origin/&lt;branch&gt; if exists
    * ELSE abort
    * Command will abort if there are unpushed commits.

## Quick Setup
1) Add to `.gitconfig`
```
[include]
    path = ~/.cool-git-aliases/feature/.gitconfig
```

2) Execute from the command line
```bash
chmod u+x ~/.cool-git-aliases/gitflow/git-feature.sh
```

3) Configure for your workflow
* In git-feature.sh, modify PUSH_REMOTE, UPSTREAM_REMOTE, and UPSTREAM_BRANCH to match your workflow.
* Configure your local git repo's remotes to match your git-feature.sh configuration
