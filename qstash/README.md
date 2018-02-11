# Git Qstash

A faster way to stash and unstash changes in git.

The stash functionality in git would be useful, but it is very slow.  So I created these commands to do a quick-stash - basically add all changes and commit.  Then when I change back to the branch, a git reset will "unstash" the changes.

I've been using this process directly for years.  Now with these commands, it is even faster and easier!

## Usage
* `git qstash [<msg>]` - Stash all changes (staged, unstaged, and untracked) in a new commit.  Commit subject will begin with "WIP!" with optional `<msg>` appended.  Following this command, the working copy will be clean.
* `git checkpoint [<msg>]` - Same functionality as `git qstash`, but commit subject will begin with "CHECKPOINT!"
* `git qunstash [--all] [--wip-only]` - Unstash a previous qstash.  This will move all qstash-ed changes and staged changes to unstaged/untracked.  The qstash commit will be thrown away and the staging area will be reset.
    * If the HEAD commit is not a qstash commit, then command will abort
    * `--all` will roll back consecutive qstash commits, back to first non-qstash commit
    * qstash commits are determined by the commit message starting with "WIP!" or "CHECKPOINT!"
        * If `--wip-only` option is used, then only commit messages starting with "WIP!" will be considered qstash commits

## Quick Setup
1) Add to `.gitconfig`
```
[include]
    path = ~/.cool-git-aliases/qstash/.gitconfig
```

2) Execute from the command line
```bash
chmod u+x ~/.cool-git-aliases/qstash/git-qstash.sh
```
