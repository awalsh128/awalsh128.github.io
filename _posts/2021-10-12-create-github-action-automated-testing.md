---
layout: posts
title: Code Analysis for GitHub Projects
excerpt: "Integrate your GitHub projects with a code analysis tool."
last_modified_at: 2021-10-12 00:00:01 -0700
tags:
- Testing
- GitHub
toc: true
toc_icon: "columns"
---

For this example I am using my own recently published action ``awalsh128/cache-apt-pkgs-action``. Feel free to swap out this with your equivalent action.

Steps to get automated setup going.

## Create Shared Secret

A Personal Access Token (PAT) will allow the publisher to trigger the event that the subscriber will then act on.

https://github.com/settings/tokens

``Settings > Developer settings > Personal Access Token > Generate New Token``

| Field      | Value                                                       |
| ---------- | ----------------------------------------------------------- |
| Note       | Publish pull requests to awalsh128/cache-apt-pkgs-action-ci |
| Expiration | (whatever you choose this to be)                            |
| Access:    | ``repo_public``                                             |

## Publisher

### Create a ``staging`` branch in ``awalsh128/cache-apt-pkgs-action``

```sh
git checkout -b staging
git push origin staging
git push --set-upstream origin staging
```

### Store Shared Secret on Publisher

The PAT will need to be stored in a variable so it can be used in the action without actually revealing it's value.

https://github.com/awalsh128/cache-apt-pkgs-action-ci/settings/secrets/actions/new

``Settings > Secrets > New repository secret``

| Field  | Value                                   |
| ------ | --------------------------------------- |
| Name   | TRIGGER_PUBLISH_STAGING_PR_TOKEN        |
| Secret | (value taken from Create Shared Secret) |

### Create Publish Action

Create ``.github/workflows/publish_staging_pr.yml`` workflow that will trigger on any pull request from staging.

```yml
name: Publish Staging Pull Request
on:
  workflow_dispatch:
  pull_request:
    branches:
      - staging

jobs:
  publish_event:
    runs-on: ubuntu-latest
    name: Publish staging pull request.
    steps:
      - run: |
          curl -i \
            -X POST \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Authorization: token ${{ secrets.TRIGGER_PUBLISH_STAGING_PR_TOKEN }}" \
            https://api.github.com/repos/awalsh128/cache-apt-pkgs-action-ci/dispatches \
            -d '{"event_type":"staging_pull_request"}'
```

## Subscriber

### Create Testing Harness

* Create ``awalsh128/cache-apt-pkgs-action-ci`` repository (ci = continuous integration) for testing.
* Create a workflow ``.github/workflows/tests.yml`` that subscribes to ``staging_pull_request`` events and runs tests.

```yml
name: Staging Pull Request Tests
on:
  # Allow for manual dispatches so we can test the workflow if needed.
  workflow_dispatch:
  repository_dispatch:
    # Name of the event that will by pubsub'd.
    types: [staging_pull_request]

jobs:
  install:
    runs-on: ubuntu-latest
    name: Install and cache.
    steps:
      - uses: actions/checkout@v2
      # Note that the action uses the @staging version.
      # Allows testing to happen on that branch so it can get pulled into master once it passes.
      - uses: awalsh128/cache-apt-pkgs-action@staging
        with:
          cache_key: ${{ github.run_id }}
          packages: xdot rolldice
```

https://docs.github.com/en/developers/apps/building-oauth-apps/scopes-for-oauth-apps
https://docs.github.com/en/rest/reference/repos#create-a-repository-dispatch-event

https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token



## More Resources

https://blog.m157q.tw/posts/2020/07/16/make-one-github-actions-workflow-trigger-another-github-actions-workflow/