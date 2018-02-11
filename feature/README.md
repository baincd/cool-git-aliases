# Git Feature

git commands designed to make it easier to follow feature-based workflows (such as Gitflow and Trunk Based Development).  

## Usage
These commands require 3 variables to be setup:

<table>
  <tr><th>Variable</th><th>Description</th><th>Default</th><th>Gitflow example<br/>(central repo)</th><th>Usage Examples</th></tr>
  <tr><td>PUSH_REMOTE</td><td>Remote to push to</td><td>origin</td><td>origin</td><td>&lt;origin&gt;</td></tr>
  <tr><td>UPSTREAM_REMOTE</td><td>Remote to open Pull Requests to</td><td>upstream</td><td>origin</td><td>&lt;upstream&gt;</td></tr>
  <tr><td>UPSTREAM_BRANCH</td><td>Branch to open Pull Requests to</td><td>master</td><td>develop</td><td>&lt;upstreambr&gt;</td></tr>
 </table>

*Usage descriptions use values from **Usage Examples**, but will use actual git-feature settings*

* `git feature-start <feature>`
    * Fetch from all remotes
    * Then create local branch `<feature>`, branching off of and tracking `<upstream>/<upstreambr>`
* `git feature-restart <feature>`
    * Same as feature-start, except branch off of and track `<upstream>/<feature>`
* `git feature-push [<push-to-branch>] [-u | --track]` - push checkout branch to <origin>
    * IF `<push-to-branch>` is set, push to `<origin>/<push-to-branch>`
    * ELSE IF local branch is tracking a remote branch that is not `(<origin>|<upstream>)/(<upstreambr>|master)`, use the tracking branch
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
    * THEN Checkout local `<upstreambr>` branch
        * IF local `<upstreambr>` branch does exist, checkout and attempt fast forword `<upstream>/<upstreambr>`
        * ELSE create local `<upstreambr>` branch, branching off of `<upstream>/<upstreambr>`
    * THEN delete the feature branch
* `git feature-mergeable [<branch>]` - Check if the current branch is mergeable with another branch
    * IF `<branch>` is not set, default to `<upstream>/<upstreambr>`
    * ELSE use local branch `<branch>` if exists
    * ELSE use `<upstream>/<branch>;` if exists
    * ELSE use `<origin>/<branch>` if exists
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
