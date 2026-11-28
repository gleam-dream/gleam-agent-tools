"""Check that each library skill names functions its library defines.

A library skill records its library and a commit of it in frontmatter:

    metadata:
      library: gleam-dream/example
      library-ref: <full commit hash>

Every backticked `module.function` in such a skill must be a public function
or constant of a module with that name in the library at that commit. Modules
are read from `src/` of the root package and of the packages under `adapters/`,
`integrations/` and `packages/`. A module `example_postmark` also answers to
`postmark`, the name an application imports an adapter under.

A backticked `name.name` that is not a library function (a record field of a
value, a function of another package) is listed in the metadata, separated
by spaces:

      not-in-library: buffered.status other_package.function

Usage: check_skill_identifiers.py [--libraries DIRECTORY] [SKILL.md ...]

With --libraries, the library `owner/name` is read from DIRECTORY/name, which
must be a Git checkout holding the commit; its working tree is not read.
Without it, each commit is fetched from GitHub into a temporary directory.
"""

import argparse
from pathlib import Path
import re
import subprocess
import sys
import tempfile

SKILLS = Path(__file__).resolve().parents[2] / "skills"
SPAN = re.compile(r"`([^`\n]+)`")
IDENTIFIER = re.compile(r"((?:[a-z][a-z0-9_]*/)*[a-z][a-z0-9_]*)\.([a-z][a-z0-9_]*)\b")
FILE_SUFFIXES = {"toml", "gleam", "md", "json", "erl", "mjs", "js", "lock", "nix"}
PACKAGE = re.compile(r"(?:(?:adapters|integrations|packages)/[^/]+/)?src/(.+)\.gleam")
REF = re.compile(r"[0-9a-f]{40}")


def git(directory, *arguments):
    return subprocess.run(
        ["git", "-C", str(directory), *arguments],
        capture_output=True,
        text=True,
    )


def metadata(text):
    """Return the `metadata` map of a skill's frontmatter."""
    frontmatter = text.split("---\n")[1]
    block = re.search(r"^metadata:\n((?:[ ]+\S.*\n)+)", frontmatter, re.MULTILINE)
    if not block:
        return {}
    pairs = (line.strip().split(": ", 1) for line in block.group(1).splitlines())
    return {key: value.strip("\"'") for key, value in pairs}


def identifiers(text):
    """Return (line number, module, function) for each backticked identifier."""
    body = text.split("---\n", 2)[2]
    first_line = text.count("\n") - body.count("\n") + 1
    found = []
    for number, line in enumerate(body.splitlines(), first_line):
        for span in SPAN.findall(line):
            match = IDENTIFIER.match(span)
            if match and match.group(2) not in FILE_SUFFIXES:
                found.append((number, match.group(1), match.group(2)))
    return found


def checkout(library, ref, libraries, scratch):
    """Return a Git directory that holds `ref` of `library`, or an error."""
    name = library.split("/")[1]
    if libraries:
        directory = libraries / name
    else:
        directory = scratch / name
        if not directory.exists():
            subprocess.run(["git", "init", "--quiet", str(directory)], check=True)
        git(
            directory,
            "fetch",
            "--quiet",
            "--depth=1",
            f"https://github.com/{library}",
            ref,
        )
    if git(directory, "cat-file", "-e", f"{ref}^{{commit}}").returncode != 0:
        return None, f"commit {ref} of {library} not found in {directory}"
    return directory, None


def modules(directory, ref):
    """Map each module name and path suffix to its source files at `ref`."""
    listing = git(directory, "ls-tree", "-r", "--name-only", ref).stdout
    found = {}
    for path in listing.splitlines():
        match = PACKAGE.fullmatch(path)
        if not match:
            continue
        parts = match.group(1).split("/")
        names = {"/".join(parts[start:]) for start in range(len(parts))}
        if "_" in parts[-1]:
            names.add(parts[-1].split("_", 1)[1])
        for name in names:
            found.setdefault(name, []).append(path)
    return found


def defines(directory, ref, paths, function):
    pattern = re.compile(rf"^pub (fn|const) {function}\b", re.MULTILINE)
    sources = (git(directory, "show", f"{ref}:{path}").stdout for path in paths)
    return any(pattern.search(source) for source in sources)


def check(skill, libraries, scratch):
    text = skill.read_text()
    fields = metadata(text)
    library, ref = fields.get("library"), fields.get("library-ref")
    if not library and not ref:
        return None
    if not library or not ref or not REF.fullmatch(ref):
        return [f"{skill}: metadata needs `library` and a 40-character `library-ref`"]
    directory, error = checkout(library, ref, libraries, scratch)
    if error:
        return [f"{skill}: {error}"]
    known = modules(directory, ref)
    outside = set(fields.get("not-in-library", "").split())
    problems = [
        f"{skill}: `{name}` is listed in `not-in-library` but not used"
        for name in sorted(outside - {f"{m}.{f}" for _, m, f in identifiers(text)})
    ]
    for number, module, function in identifiers(text):
        if f"{module}.{function}" in outside:
            continue
        if module not in known:
            problems.append(
                f"{skill}:{number}: `{module}.{function}`: "
                f"{library} has no module `{module}` at {ref[:12]}"
            )
        elif not defines(directory, ref, known[module], function):
            problems.append(
                f"{skill}:{number}: `{module}.{function}`: no public function "
                f"or constant `{function}` in {', '.join(known[module])} "
                f"of {library} at {ref[:12]}"
            )
    return problems


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--libraries", type=Path)
    parser.add_argument("skills", nargs="*", type=Path)
    arguments = parser.parse_args()
    skills = arguments.skills or sorted(SKILLS.glob("*/SKILL.md"))
    checked, problems = 0, []
    with tempfile.TemporaryDirectory() as scratch:
        for skill in skills:
            result = check(skill, arguments.libraries, Path(scratch))
            if result is not None:
                checked += 1
                problems += result
    for problem in problems:
        print(problem)
    print(f"{checked} library skills checked, {len(problems)} problems")
    if checked == 0:
        print("no skill records a library in its metadata")
    sys.exit(1 if problems or checked == 0 else 0)


if __name__ == "__main__":
    main()
