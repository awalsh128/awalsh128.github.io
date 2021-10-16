---
layout: posts
title: Automated Testing for GitHub Actions
excerpt: "Create a testing harness for your created GitHub Actions."
last_modified_at: 2021-10-16 00:00:01 -0700
tags:
- Testing
- GitHub
toc: true
toc_icon: "columns"
---

GitHub actions don't support running tests on created actions from the same repository. In order to do this, another repository needs to be created. There is a way to test locally using [nektos/act](https://github.com/nektos/act) but this doesn't address code being committed upstream and continuously integrated.

There will be two endpoints:

* Action repository when your created action under test lives.
* Test repository that houses the tests.

The general idea is to have your action repository publish an event that a push has occurred, relay it to the test repository which triggers tests on the test repository. For this example I am using my own recently published action ``awalsh128/cache-apt-pkgs-action``. Feel free to swap out this with your equivalent action.

The steps needed are to create:

* a shared secret,
* a staging (or another) branch besides master on the action repository,
* a repository to run tests on your action code,
* tests in your test repository,
* a publish action in your action repository,
* a subscriber action in your test repository.

More details on each step below.

## Create Shared Secret

A Personal Access Token (PAT) will allow the publisher (action repository) to trigger the event that the subscriber (test repository) will then act on. This shared secret will be needed so they can interact.

[Instructions to setup your PAT. Use the arguments below.](https://github.com/settings/tokens)

``Settings > Developer settings > Personal Access Token > Generate New Token``

| Field      | Value                                                       |
| ---------- | ----------------------------------------------------------- |
| Note       | Publish pull requests to awalsh128/cache-apt-pkgs-action-ci |
| Expiration | (whatever you choose this to be)                            |
| Access:    | ``repo_public``                                             |

## Publisher

Now the publisher side (action repository) of the event that will trigger the tests.

### Create a ``staging`` branch in ``awalsh128/cache-apt-pkgs-action``

This will be used as a testing branch. Broken code can live here without going to ``master``. It doesn't have to be called ``staging``, call it whatever you want (e.g. ``dev``, ``whatever``).

```sh
git checkout -b staging
git push origin staging
git push --set-upstream origin staging
```

### Store Shared Secret on Publisher

In order for the action repository to publish the event to the test repository, it will need access to it. The PAT will need to be stored in a variable so it can be used in the action without actually revealing it's value.

To create a scecret, you can use a URL like below. Replace the ``cache-apt-pkgs-action-ci`` repository with your own test repository name.

<https://github.com/awalsh128/cache-apt-pkgs-action-ci/settings/secrets/actions/new>

Use the arguments below when creating the secret.

``Settings > Secrets > New repository secret``

| Field  | Value                                   |
| ------ | --------------------------------------- |
| Name   | TRIGGER_PUBLISH_STAGING_PR_TOKEN        |
| Secret | (value taken from Create Shared Secret) |

### Create Publish Action

In the action repository, create ``.github/workflows/staging_push.yml`` workflow that will trigger on any push to staging.

```yml
name: Publish Staging Push Event
on:
  # Allow manual triggering for debugging.
  workflow_dispatch:
  # Publish when we see a push to staging.
  push:
    branches:
      - staging

jobs:
  publish_event:
    runs-on: ubuntu-latest
    name: Publish staging pull request.
    steps:
      # Note the event_type and URL secrets passed so the action repository 
      # is allowed to post to the test repository.
      - run: |
          curl -i \
            -X POST \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Authorization: token ${{ secrets.TRIGGER_PUBLISH_STAGING_PR_TOKEN }}" \
            https://api.github.com/repos/awalsh128/cache-apt-pkgs-action-ci/dispatches \
            -d '{"event_type":"staging_push"}'
```

## Subscriber

Now on the subscriber (test repository), setup the tests and trigger to respond to the staging push.

### Create Repository and Test

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

That's it. Now anytime code is pushed to staging on your action repository, it will trigger tests on your test repository.

## More Resources

* [Github: Create Repository Dispatch Event](https://docs.github.com/en/rest/reference/repos#create-a-repository-dispatch-event)
* [Github: Create Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
* [Trigger Github Actions between Repositories](https://blog.m157q.tw/posts/2020/07/16/make-one-github-actions-workflow-trigger-another-github-actions-workflow)