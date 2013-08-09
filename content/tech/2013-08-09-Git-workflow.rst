My blogging workflow with git
=============================
:summary: Create a topical branch and make commits in that.  When ready, rebase the topical branch on master and merge.  Publish.

This is a description of my `git <http://git-scm.org>`_ workflow for writing blog posts.  I will use this very post as an example and explain in detail how it was made.

Start a new topical branch
--------------------------
I create a topical branch named ``workflow`` (because I'm working on a post about my workflow) from the ``master`` branch

.. code-block:: bash

    $ git checkout -b workflow

I edit the file ``content/tech/2013-08-09-Git-workflow.rst`` and start writing the post.  When I have enough typing for the day I commit the changes:

.. code-block:: bash

    $ git add content/tech/2013-08-09-Git-workflow.rst
    $ git commit -m 'Add post: Git workflow.'

It rarely happens that I finish a post in one go.  When I feel like writing more I make some modifications (still on the ``workflow`` branch) and commit them:

.. code-block:: bash

    $ git commit -a -m 'Continue workflow post.'

It typically takes two or three iterations, adding parts, fixing typos, etc. until the post is finished.  In the end the topical branch contains quite a few commits since it was forked off from ``master``:

.. code-block:: bash

    $ git log master..
    [there may be some more commits here]

    commit 4f721af41b2c0d52a8456bb6735ad0f56754ea98
    Author: David Wagner
    Date:   Fri Aug 9 10:44:58 2013 +0200

        git log output.

    commit f77de095d0d5225a566782c52133be7f65166016
    Author: David Wagner
    Date:   Fri Aug 9 10:44:30 2013 +0200

        Add summary.

    commit e332a4b53c8cdd94f3117a949a99367b56a8bc6e
    Author: David Wagner
    Date:   Fri Aug 9 10:39:38 2013 +0200

        Add post: Git workflow.


Rebase on master and squash commits
-----------------------------------
I want to "compress" all these into one single commit, since there's no point having commits in the ``master`` branch with messages such as "Add summary", "Fix typo.", "Continue this and that.".  In git's words this is called interactive rebasing.

.. code-block:: bash

    $ git rebase -i master

This pops up ``$EDITOR`` with a file to edit the rebase plan:

.. code-block:: bash

    pick e332a4b Add post: Git workflow.
    pick f77de09 Add summary.
    pick 4f721af git log output.

    # Rebase 6ed71cf..9be73d2 onto 6ed71cf
    #
    # Commands:
    #  p, pick = use commit
    #  r, reword = use commit, but edit the commit message
    #  e, edit = use commit, but stop for amending
    #  s, squash = use commit, but meld into previous commit
    #  f, fixup = like "squash", but discard this commit's log message
    #  x, exec = run command (the rest of the line) using shell
    #
    # These lines can be re-ordered; they are executed from top to bottom.
    #
    # If you remove a line here THAT COMMIT WILL BE LOST.
    # However, if you remove everything, the rebase will be aborted.
    #

The comments explain very clearly what I need to do: I modify the file to contain the following (omitting the comments)::

    pick e332a4b Add post: Git workflow.
    squash f77de09 Add summary.
    squash 4f721af git log output.

When the file is saved, I exit from the editor.  Git starts the rebase offering to edit the commit message for each posts to remain, then finally reporting::

    [...]
    Successfully rebased and updated refs/heads/workflow.


Merge into master and publish
-----------------------------
Now I switch back to ``master`` and merge, then delete the topical branch:

.. code-block:: bash

    $ git checkout master
    $ git merge workflow
    $ git branch -d workflow

The new post is ready, the blog can be regenerated and published.

Summary
-------
In short, I'm quite pleased with this setup.  Using the combination of git and the `Pelican <http://docs.getpelican.com>`_ static blog generator is really easy and has a lot of advantages: I can work on multiple posts at the same time, even offline and publishing is just a matter of a ``git push``.  The above workflow rose naturally, when I became to know enough about git's branches and rebasing.

Evidently this whole thing may appear way more complicated than necessary for the faint hearted on Blogger, however this branch juggling turns out to be quite powerful when it's about software development in the wild where clean commits and keeping track of changes you make on the codebase are essential.
