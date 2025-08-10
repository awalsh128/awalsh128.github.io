---
title: Git Notes
date: '2020-10-06T00:00:00.000-07:00'
tags:
- git
modified_time: '2020-10-06T00:00:00.000-07:00'
excerpt: "Git notes giving commonly used commands and some handy special workflows."
toc: true
---

## Common Commands

| Short Description      | Command                          | Description                  |
| ---------------------- | -------------------------------- | ---------------------------- |
| Add                    | ``git add <pattern>``            |
| Add All                | ``git add -u``                   | Add all pending changes.     |
| Clean                  | ``git clean``                    | Clean all untracked changes. |
| Clean Preview          | ``git clean -n``                 |
| Clone Repository       | ``git clone <project URL>``      |
| Commit Pending         | ``git commit -m "<message>"``    |
| Initialize Repository  | ``git init <project name>``      |
| Move                   | ``git mv <source> <target>``     |
| Pull from Master       | ``git pull origin master``       | 
| Push to Master         | ``git push origin master``       |
| Remove                 | ``git rm <target>``              |
| Revert                 | ``git revert <version>``         |
| Repository Status      | ``git status``                   |
| View Pending           | ``git log origin/master..HEAD``  |
| View Pending Diff      | ``git diff origin/master..HEAD`` |


## Special Workflows

### Reset History

```bash
#!/bin/bash

git checkout --orphan latest_branch
git add -A
git commit -am "Initial commit."
git branch -D master
git branch -m master
git push -f origin master
```

```
rm -rf .git;
git init;
git add .;
git commit -m "Initial commit";
git remote add origin https://github.com/<username>/<repo>.git;
git push -u --force origin master;
```

### Delete Tag

Can be used to delete tags upstream (e.g. GitHub).

```bash
git push --delete origin v1.0
```

## Other Options

Cache credentials for a day.

```bash
git config credential.helper 'cache --timeout 86400'
```

## Resources

* [GitLab: Git Cheat Sheet](https://about.gitlab.com/images/press/git-cheat-sheet.pdf) - Larger font in landscape.
* [GitHub: Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf) - Only 2 pages as smaller font in potrait.