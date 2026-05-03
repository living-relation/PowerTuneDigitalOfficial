import os
import subprocess
import sys

print("Python {}.{}.{}".format(*sys.version_info))  # Python 3.8

# Fail fast if git_diff.txt is missing or unreadable so CI indicates misconfiguration.
if not os.path.isfile("git_diff.txt"):
    print("ERROR: git_diff.txt not found. The workflow step that generates it may have failed.", file=sys.stderr)
    sys.exit(2)

try:
    with open("git_diff.txt", encoding="utf-8", errors="replace") as in_file:
        modified_files = sorted(in_file.read().splitlines())
except OSError as exc:
    print(f"ERROR: Could not read git_diff.txt: {exc}", file=sys.stderr)
    sys.exit(2)

print("{} modified files were read from git_diff.txt.".format(len(modified_files)))

# Remove files that do not exist from the list.
existing_files = [file for file in modified_files if os.path.isfile(file)]
print("{} of those files exist on disk.".format(len(existing_files)))

cpp_exts = tuple(".c .c++ .cc .cpp .cu .cuh .cxx .h .h++ .hh .hpp .hxx".split())
cpp_files = [file for file in existing_files if file.lower().endswith(cpp_exts)]
print("{} C/C++ files will be linted.".format(len(cpp_files)))
if not cpp_files:
    sys.exit(0)

print("cpplint:")

# Run the lint command, capture the output and return code.
# The return code will be non-zero if there are errors.
args = ["cpplint"]
args.extend(["--linelength=120", "--filter=-legal/copyright,-whitespace/braces", "--output=vs7", "--counting=toplevel"])
args.extend(cpp_files)
# Print a safe representation of the command so filenames with spaces are unambiguous.
print(repr(args))
result = subprocess.run(
    args,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    encoding="utf-8",
    errors="replace",
    check=False,
)

# Save full cpplint output to a file with a short summary at the top.
stderr_lines = result.stderr.splitlines()
summary = "\n".join(stderr_lines[:10])

with open("cpplint.txt", "w", encoding="utf-8") as out_file:
    out_file.write("Here are the first 10 encountered errors:\n```\n")
    out_file.write(summary)
    out_file.write("\n```\n\nFull cpplint output:\n```\n")
    out_file.write(result.stderr)
    out_file.write("\n```\n")
    if result.stdout:
        out_file.write(result.stdout)

# Persist cpplint's return code for later workflow steps and exit successfully
# so they can still publish cpplint.txt back to the PR.
with open("cpplint_status.txt", "w", encoding="utf-8") as status_file:
    status_file.write(f"{result.returncode}\n")

if result.returncode != 0:
    print(
        "cpplint reported lint errors; see cpplint.txt for details. "
        "The return code was written to cpplint_status.txt for later workflow handling.",
        file=sys.stderr,
    )

sys.exit(0)
