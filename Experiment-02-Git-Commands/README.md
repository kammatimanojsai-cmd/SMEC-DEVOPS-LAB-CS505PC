# Experiment 2 – Exploring Git and GitHub Commands

**Status:** ✅ All Git commands executed and verified with a local "remote". ⏳ The GitHub push and the pull request must be done on your laptop (steps below).

## AIM
To explore and practise the basic Git and GitHub commands: init, status, add, commit, log, branch, checkout/switch, merge, remote, push, clone and pull request.

## Software Requirements
Git 2.40+ (Git for Windows includes Git Bash), a GitHub account, and optionally the GitHub CLI (`gh`).

## Procedure
1. Create a folder and initialise a repository (`git init`).
2. Create a file, check `git status`, stage it (`git add`) and commit it (`git commit`).
3. Make more commits and view the history (`git log --oneline`).
4. Create a branch, switch to it, commit work on it, switch back and merge it.
5. Add a remote (`git remote add origin <url>`), push the branches, then clone the repository into a new folder.
6. On GitHub, push a feature branch and open a pull request, then merge it.

## Commands and Their Purpose
| Command | Purpose |
|---|---|
| `git init -b main` | Create a new repository with a `main` branch |
| `git status` | Show changed, staged and untracked files |
| `git add <file>` | Stage changes for the next commit |
| `git commit -m "msg"` | Save a snapshot with a message |
| `git log --oneline --graph` | Show commit history |
| `git branch <name>` | Create a branch |
| `git switch <name>` / `git checkout <name>` | Move to a branch |
| `git merge <branch>` | Merge a branch into the current branch |
| `git remote add origin <url>` | Link to a remote repository (GitHub) |
| `git push -u origin main` | Upload commits to the remote |
| `git clone <url>` | Copy a remote repository to your machine |
| `git pull` | Fetch and merge remote changes |
| `gh pr create` | Open a pull request on GitHub |

## Execution
The whole sequence is scripted in `git-commands-demo.sh` (run it in **Git Bash**):
```bash
# local demo (no GitHub needed) - uses a local bare repo as the remote
./git-commands-demo.sh

# real GitHub demo: first create an EMPTY repo named git-lab-demo on github.com
REMOTE_URL=https://github.com/kammatimanojsai-cmd/git-lab-demo.git ./git-commands-demo.sh
```

### Pull Request (do this on your laptop)
```bash
cd git-demo-workspace/git-lab-demo
git switch -c feature-docs
echo "Usage: python greet.py" >> README.md
git commit -am "Add usage notes"
git push -u origin feature-docs
gh pr create --title "Add usage notes" --body "Experiment 2 pull request demo" --base main
gh pr list
gh pr merge --merge          # or click "Merge pull request" on github.com
git switch main && git pull
```
Without `gh`: push the branch, then open the repository on github.com → **Compare & pull request** → **Create pull request** → **Merge**.

## Verified Output (excerpt from `evidence/02_git_commands.log`)
```
$ git log --oneline --graph --all
*   da268cc Merge branch 'feature-login'
|\
| * 25ec368 Add login feature
|/
* a810fee Add greet function
* 8abeece Initial commit: add README

$ git push -u origin main
 * [new branch]      main -> main
$ git clone <workspace>/remote-repo.git cloned-copy
Cloning into 'cloned-copy'... done.
```

## Result
The Git commands for creating a repository, committing, branching, merging, pushing and cloning were executed successfully. The pull request workflow is documented for GitHub.

## Viva Questions
1. **What is Git?** A distributed version control system that tracks changes to files.
2. **Git vs GitHub?** Git is the tool; GitHub is an online hosting service for Git repositories with collaboration features such as pull requests.
3. **What is the staging area?** An intermediate area where changes are collected (`git add`) before they are committed.
4. **What is a branch?** An independent line of development, so features can be built without disturbing `main`.
5. **What is a pull request?** A request to review and merge changes from one branch into another on GitHub.

## GitHub Link
`https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC/tree/main/Experiment-02-Git-Commands`

## Demonstration
Run `./git-commands-demo.sh` in Git Bash and walk through the output, then show the merged pull request on GitHub.

## Pull Request Demonstration (done)
This section was added on branch `exp2-pull-request-demo` and merged into `main` through a GitHub pull request.
