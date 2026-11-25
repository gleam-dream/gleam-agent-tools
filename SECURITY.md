# Security policy

## Supported versions

This repository is not published as a versioned package and has no release
tags. Security fixes land on the `main` branch only.

Skill text is instruction to an agent that can run commands, and the Nix
package builds a program the agent starts. Install from a commit you have
reviewed, as the README describes, and move to a newer commit deliberately.
After a security fix, move to a commit that contains it.

## Changes to `main`

Consumers of `main` can expect the following, and a departure from it is a
defect to report:

- `main` changes only through a pull request. Direct pushes, force pushes and
  deletion of the branch are refused by a repository ruleset.
- Maintainers merge a pull request only after its checks pass: the title
  check, and the Nix checks on Linux and macOS.
- GitHub Actions used by the workflows are pinned to full commit hashes, and
  the workflows hold read-only repository permissions.

Repository administrators can bypass the ruleset. A pinned commit protects a
consumer from that; following `main` does not.

## Reporting a vulnerability

Please do not open a public issue for a suspected vulnerability. Email
talktoedgar@gmail.com with a description of the issue, the affected version or
commit, and steps to reproduce it.

You can expect an acknowledgement within 7 days. Once the issue is confirmed, a
fix is prepared privately and released, and the report is credited in the
release notes unless you prefer otherwise.
