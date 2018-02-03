# Gitflow feature commands

git commands designed to make it easier to follow gitflow, and other feature-based workflows.  

Most of these commands are useful even outside of feature-based  workflows.

## Usage
* `git feature-start <feature>` - create branch `feature` off of upstream/develop
* `git feature-restart <feature>` - same as feature-start, but set HEAD to origin/&lt;feature&gt;
* `git feature-push [<push-to-branch>] [-u | --track]` - push to origin
    * `<push-to-branch>` will be used as the branch to push to
    * else use existing tracking branch if set AND is not origin/develop, origin/master, upstream/develop, or upstream/master
    * else use local branch name, chopping off ticket numbers ("-123", "-123-456") and version numbers ("-v2") off the end.
        * abc -> abc
        * abc123 -> abc123
        * abc-123 -> abc
        * abc-123-456 -> abc
        * abc-123-v4 -> abc
        * abc99-123 -> abc99
    * if `-u` or `--track` is used, the local branch will track the remote branch
* `git feature-pr [<push-to-branch>]` - execute feature-push, then open Pull Request
* `git feature-end` - checkout develop (create if necessary), fast forward to upstream/develop, and delete the feature branch
* `git feature-mergeable [<branch>]` - Check if the current branch is mergeable with another branch
    * Default to upstream/develop if no `<branch>`
    * else use local branch `<branch>` if exists
    * else use upstream/&lt;branch&gt; if exists
    * else use origin/&lt;branch&gt; if exists
    * else abort
    * Command will abort if there are unpushed commits.

## Quick Setup
1) Add to `.gitconfig`
```
[include]
    path = ~/.cool-git-aliases/gitflow/.gitconfig
```

2) Execute from the command line
```bash
chmod u+x ~/.cool-git-aliases/gitflow/git-feature.sh
```

3) Configure for your workflow
* In git-feature.sh, modify PUSH_REMOTE, UPSTREAM_REMOTE, and UPSTREAM_BRANCH to match your workflow.
* Configure your local git repo's remotes to match your git-feature.sh configuration
