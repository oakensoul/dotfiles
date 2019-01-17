# Contributing
Contributions are welcome, and they are greatly appreciated! Every little bit helps, and credit will always be given.

You can contribute in many ways:
- [Bug Reports](#bug-reports)
- [Feature Requests](#feature-requests)
- [Implement Features](#implement-features)
- [Write Documentation](#write-documentation)
- [Submit Feedback](#submit-feedback)

## Bug Reports
When the inevitable happens and you discover a bug in the documentation or the code, please follow the process below
to help us out.

* Search the [existing issues](#0) to see if the issue has already been filed
* Make sure the issue is a bug and not simply a preference
* If you've found a new issue, please then file it
* Please make sure to fill out as many sections in the template as possible

From that point, if you're interest in contributing some code, ask in the issue if we're willing to accept a failing
test case, and/or a fix. If we are, then follow the steps for contributing and we can go from there!

## Feature Requests
With most projects, every new feature request should be scrutinized to make sure you're not going to experience feature
bloat. Every new feature should fit the Vision for the project. If you've got an idea for a new feature and you feel it
fits the vision, file an issue and we can discuss it.

Make sure any feature request you make fits the
[INVEST](http://en.wikipedia.org/wiki/INVEST_(mnemonic) mnemonic.

## Implement Features
Look through the [Project Issues](#0) for bugs. Anything tagged with "bug"
and "help wanted" is open to whoever wants to implement it.

## Write Documentation
dot_files could always use more documentation, whether as part of the
official dot_files docs, in docstrings, or even on the web in blog posts,
articles, and such.

## Submit Feedback
The best way to submit feedback is to file a [Project Issues](#0).

# Get Started

This project uses the "GitHub" branching model. If you'd like to read more on some of the various branching models, the
two big Elephants in the room are the [GitHub Flow](http://scottchacon.com/2011/08/31/github-flow.html) and the
[Gitflow](http://nvie.com/posts/a-successful-git-branching-model/) branching model.

## Setup your Development Environment

1. [Fork](http://help.github.com/fork-a-repo/) the project, clone your fork,
   and configure the remotes:

   ```bash
   # Clone your fork of the repo into the current directory
   git clone https://github.com/<your-username>/dotfiles
   # Navigate to the newly cloned directory
   cd dotfiles
   # Assign the original repo to a remote called "upstream"
   git remote add upstream https://github.com/oakensoul/dotfiles
   ```

2. If you cloned a while ago, get the latest changes from upstream:

   ```bash
   git checkout master
   git pull upstream master
   ```

3. Setup your Virtual Environment
   - You can use PyEnv, VirtualEnv, whatever works for you
   - source <yourenv> activate

4. Install the App
   - pip install -e .

6. Install Testing tools
   - pip install -e ".[testing]"

## Running Tests
The most important part of changes are their tests. Every new feature or issue being fixed should have a matching test.

## Pull Requests
A well written pull request is a huge piece of the success of any open source project. Please make sure to take the time
to think out the request and document/comment well. A good pull request should be the smallest amount of code to achieve
the desired goal. Please try not to stack too many issues into the same pull request.

Make sure if you're not a project member and just getting started that you have a related issue for your Pull Request
and that a project owner approves the work before putting the effort in to make the change. Most of the time as long as
you're following the project vision, we'll welcome additions, but it's better to be save than sorry.

Also, make sure your pull request is built with a compilation of great
[commit messages](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).

Adhering to the following this process is the best way to get your work included in the project:

1. If you cloned a while ago, get the latest changes from upstream:

   ```bash
   git checkout master
   git pull upstream master
   ```

2. Create a new topic branch (off the main project development branch) to
   contain your feature, change, or fix:

   ```bash
   git checkout -b topic-branch-name
   ```

3. Make sure to update, or add to the tests when appropriate. Patches and features will not be accepted without tests.
   Run the tests as relevant to make sure all tests pass after you've made changes.

4. Commit your changes in logical chunks. Please adhere to these
     [git commit message guidelines](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
   or your code is unlikely be merged into the main project. Use Git's
     [interactive rebase](https://help.github.com/articles/interactive-rebase)
   feature to tidy up your commits before making them public.

5. Locally merge (or rebase) the upstream development branch into your topic branch:

   ```bash
   git pull [--rebase] upstream master
   ```

6. Push your topic branch up to your fork:

   ```bash
   git push origin <topic-branch-name>
   ```

7. [Open a Pull Request](https://help.github.com/articles/using-pull-requests/)
    with a clear title and description.

8. If you are asked to amend your changes before they can be merged in, please use `git commit --amend` (or rebasing
   for multi-commit Pull Requests) and force push to your remote feature branch. You may also be asked to squash 
   commits.

**IMPORTANT**: By submitting a patch, you agree to license your work under the
same license as that used by the project.
