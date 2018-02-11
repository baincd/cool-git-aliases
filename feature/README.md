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

* `git feature-start <feature> [<branch-from>]`
    * Fetch from all remotes
    * Then create and checkout local branch `<feature>`, branching from `<upstream>/<upstreambr>`
        * OR branch from `<branch-from>` if set
    * Track `<upstream>/<upstreambr>`
* `git feature-restart <feature>  [<branch-from>]`
    * Fetch from all remotes
    * Then create and checkout local branch `<feature>`, branching from `<origin>/<feature>`
        * OR branch from `<branch-from>` if set
    * Track `<origin>/<feature>`
        * OR track `<branch-from>` or `<origin>/<branch-from>` if `<branch-from>` is set
* `git feature-push [<push-to-branch>] [-u | --track]` - push checkout branch to &lt;origin&gt;
    * Push to `<origin>/<modified-local-branch-name>`, chopping off ticket numbers ("-123", "-123-456") and version numbers ("-v2") off the end.  ex:
        * abc -> `<origin>/abc`
        * abc123 -> `<origin>/abc123`
        * abc-123 -> `<origin>/abc`
        * abc-123-456 -> `<origin>/abc`
        * abc-123-v4 -> `<origin>/abc`
        * abc99-123 -> `<origin>/abc99`
        * OR push to `<origin>/<push-to-branch>` if `<push-to-branch>` is set
        * OR push to the tracking branch if tracking branch is set and is not `(<origin>|<upstream>)/(<upstreambr>|master)`,
    * IF `-u` or `--track` is used, the local branch will track the remote branch
* `git feature-pr [<push-to-branch>]`
    * Execute feature-push
    * Then open Pull Request
* `git feature-end`
    * Fetch from all remotes
    * THEN Checkout local `<upstreambr>` branch and fast forward `<upstream>/<upstreambr>`
        * OR if local `<upstreambr>` branch doesn't exist, create it branching off of `<upstream>/<upstreambr>`
    * THEN delete the feature branch
* `git feature-mergeable [<branch>]` - Check if the current branch is mergeable with `<upstream>/<upstreambr>`
    * OR check against local branch `<branch>` if exists
    * OR check against `<upstream>/<branch>` if exists
    * OR check against `<origin>/<branch>` if exists
    * Command will abort if working copy is dirty

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
