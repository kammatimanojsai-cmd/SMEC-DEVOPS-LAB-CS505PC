# Experiment 3 – Source Code Management using the Experiment 1 Project

**Status:** ✅ Workflow executed and verified on the real Experiment 1 Flask source code (local central repository). ⏳ Repeat against GitHub on your laptop to show the code on github.com.

## AIM
To practise source code management (clone, add, commit, push, branching, merging and tagging) on the Flask event registration application from Experiment 1.

## Software Requirements
Git 2.40+, Git Bash, a GitHub account, and the Experiment 1 source code.

## Procedure
1. **Developer A** imports the Experiment 1 source code into a new repository, commits it, pushes it to the central repository and tags it `v1.0`.
2. **Developer B** clones the repository, creates `feature/add-workshop-event`, changes `app.py`, commits and pushes the branch.
3. **Developer A** fetches, reviews the branch (`git log main..origin/feature/...`), merges it with `--no-ff`, pushes `main` and deletes the remote feature branch.
4. Verify the remote state with `git log --graph` and `git ls-remote`.

## Execution (Git Bash)
```bash
# local central repo (no GitHub needed)
./scm-workflow.sh

# against GitHub: create an EMPTY repo "event-registration-flask" on github.com first
REMOTE_URL=https://github.com/kammatimanojsai-cmd/event-registration-flask.git ./scm-workflow.sh
```
Then open the GitHub repository and check: the files from Experiment 1, the `v1.0` tag under **Releases/Tags**, the merge commit, and the commit graph under **Insights → Network**.

## Verified Output (excerpt from `evidence/03_scm_workflow.log`)
```
$ git merge --no-ff origin/feature/add-workshop-event -m "Merge feature/add-workshop-event"
 app.py | 2 +-
$ git push origin --delete feature/add-workshop-event
 - [deleted]         feature/add-workshop-event
$ git log --oneline --graph --decorate -6
*   9af4271 (HEAD -> main, origin/main) Merge feature/add-workshop-event
|\
| * 0c5c690 Add Kubernetes Workshop to the event list
|/
* a606812 (tag: v1.0) Import Flask event registration app (Experiment 1)
```

## Result
The Experiment 1 project was put under version control and managed through cloning, feature branching, pushing, merging and release tagging.

## Viva Questions
1. **What is SCM?** Source Code Management: tracking and controlling changes to source code over time.
2. **Why use feature branches?** To isolate new work until it is reviewed, keeping `main` stable.
3. **What does `git fetch` do compared with `git pull`?** `fetch` downloads remote changes only; `pull` = fetch + merge.
4. **What is a tag?** A named pointer to a specific commit, usually used to mark releases such as `v1.0`.
5. **What does `--no-ff` do?** It always creates a merge commit, so the history shows that a feature branch existed.

## GitHub Link
`https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC/tree/main/Experiment-03-Source-Code-Management`

## Demonstration
Run `./scm-workflow.sh` and explain the three developer phases from the output, then show the repository on GitHub.
