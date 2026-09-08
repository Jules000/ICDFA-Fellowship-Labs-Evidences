# Lab 3 Walkthrough: Building the Bash Reconnaissance Tool

This guide walks through the whole lab from an empty terminal to a finished, tested `recon_tool.sh`. Each step says **what you type**, **what it does**, **what you should see**, and **exactly when to take a screenshot** for your report.

> ⚠️ **Authorisation reminder:** only ever run this script against targets your instructor has explicitly authorised. Automating a scan doesn't change the ethics or legality of running it — it just makes it easier to run it too often or against the wrong thing.

---

## Part 1 — Set up your workspace

### Step 1: Create and enter the project folder
```bash
mkdir -p ~/lab3-recon
cd ~/lab3-recon
pwd
```
- `mkdir -p` creates the folder (and won't error if it already exists).
- `cd` moves into it.
- `pwd` prints your current path so you can confirm you're in the right place.

**📸 Screenshot #1:** the output of `pwd` — it should end in `/lab3-recon`.

### Step 2: Confirm the tools are installed
```bash
command -v bash
command -v nmap
command -v whatweb
command -v dirb
```
- `command -v <program>` prints the path to that program if it's installed and on your `PATH`, and prints nothing if it isn't.

**What to do if one is missing:** note which tool is missing and tell your instructor before continuing — don't try to install anything undocumented.

### Step 3: Open the script file
```bash
nano recon_tool.sh
```
**📸 Screenshot #2:** the blank Nano editor, before you type anything (proves you started from scratch).

---

## Part 2 — Build the script stage by stage

Type each stage below into Nano, save (see Step 4 later), and where noted, test it before moving on. Building it incrementally makes it much easier to find mistakes.

### Stage A — Header and shebang
```bash
#!/usr/bin/env bash

echo "ICDFA Beginner Reconnaissance Tool"
echo "---------------------------------"
echo "Use only against authorised lab targets."
```
- The **shebang** (`#!/usr/bin/env bash`) tells Linux which interpreter to run the file with.
- The `echo` lines just print a title and a reminder banner every time the script starts.

### Stage B — Ask for the target
```bash
echo
read -rp "Enter authorised target IP address or domain: " target

echo "Target entered: $target"
```
- `read -rp "prompt" varname` shows a prompt, waits for input, and stores whatever you type into the variable `target`.
- `-r` stops backslashes being treated specially (so paths/characters aren't mangled).
- `-p` is what displays the prompt text.
- `$target` later reads back the value you stored.

### Stage C — Reject empty input
```bash
if [[ -z "$target" ]]; then
    echo "Error: no target was entered."
    exit 1
fi
```
- `-z "$target"` is true when the variable is empty.
- `exit 1` stops the script and signals "this run failed."

**Test this now:** save, make it executable (see Step 5), run it, and press **Enter** without typing a target.

**📸 Screenshot #3:** the terminal showing the error message when you submit an empty target.

### Stage D — Build the menu
```bash
echo
echo "Select a reconnaissance tool:"
echo "1) WhatWeb"
echo "2) Nmap"
echo "3) DIRB"
echo "4) Exit"
read -rp "Enter your choice [1-4]: " choice
```
This just prints four numbered options and stores whichever number the user types into `choice`.

### Stage E — Understand `case` (practice block, temporary)
Before writing the real logic, it helps to test the mechanism on its own:
```bash
case "$choice" in
    1) echo "Option 1" ;;
    2) echo "Option 2" ;;
    *) echo "Invalid option" ;;
esac
```
- `case` compares one value (`$choice`) against a list of patterns.
- Each branch ends in `;;`.
- `*` is the catch-all for anything that didn't match — like a `default` in other languages.
- `esac` (`case` spelled backwards) closes the statement.

You can delete this practice block once you understand it — the real version comes in Stage G.

### Stage F — Add a tool-check helper function
```bash
check_tool() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required tool '$1' is not installed or not in PATH."
        exit 1
    fi
}
```
- This defines a reusable function `check_tool`.
- `$1` is whatever tool name is passed in when the function is called (e.g. `check_tool nmap`).
- `>/dev/null 2>&1` hides the normal output of `command -v`, since you only care whether it succeeded or failed, not what it printed.

### Stage G — Wire the menu to the actual tools
```bash
case "$choice" in
    1)
        check_tool whatweb
        echo "[+] Running WhatWeb against $target"
        whatweb "http://$target"
        ;;
    2)
        check_tool nmap
        echo "[+] Running Nmap service detection against $target"
        nmap -sV "$target"
        ;;
    3)
        check_tool dirb
        echo "[+] Running DIRB against $target"
        dirb "http://$target"
        ;;
    4)
        echo "Exiting. No scan was run."
        exit 0
        ;;
    *)
        echo "Error: invalid menu choice."
        exit 1
        ;;
esac
```
This is the core logic: whichever number the user chose determines which branch runs, which tool-check fires, and which command executes against `$target`.

---

## Part 3 — The complete script

Once all the stages are combined (with an extra safety check for spaces in the target added), your file should look like this:

```bash
#!/usr/bin/env bash

echo "ICDFA Beginner Reconnaissance Tool"
echo "---------------------------------"
echo "Use only against authorised lab targets."
echo

read -rp "Enter authorised target IP address or domain: " target

if [[ -z "$target" ]]; then
    echo "Error: no target was entered."
    exit 1
fi

if [[ "$target" =~ [[:space:]] ]]; then
    echo "Error: target must not contain spaces."
    exit 1
fi

check_tool() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required tool '$1' is not installed or not in PATH."
        exit 1
    fi
}

echo "Select a reconnaissance tool:"
echo "1) WhatWeb"
echo "2) Nmap"
echo "3) DIRB"
echo "4) Exit"
read -rp "Enter your choice [1-4]: " choice

case "$choice" in
    1)
        check_tool whatweb
        echo "[+] Running WhatWeb against $target"
        whatweb "http://$target"
        ;;
    2)
        check_tool nmap
        echo "[+] Running Nmap service detection against $target"
        nmap -sV "$target"
        ;;
    3)
        check_tool dirb
        echo "[+] Running DIRB against $target"
        dirb "http://$target"
        ;;
    4)
        echo "Exiting. No scan was run."
        exit 0
        ;;
    *)
        echo "Error: invalid menu choice."
        exit 1
        ;;
esac
```

---

## Part 4 — Save, make executable, and run

### Step 4: Save and exit Nano
Press `Ctrl+O`, then `Enter` to confirm the filename, then `Ctrl+X` to exit.

Verify the contents:
```bash
cat recon_tool.sh
```
**📸 Screenshot #4:** the output of `cat recon_tool.sh` showing your finished code.

### Step 5: Make the script executable
```bash
chmod +x recon_tool.sh
ls -l recon_tool.sh
```
- `chmod +x` adds the execute permission bit.
- `ls -l` lets you confirm it — you're looking for an `x` in the permission string, e.g. `-rwxr-xr-x`.

**📸 Screenshot #5:** the `ls -l` output showing the `x` permission.

### Step 6: Run it for the first time
```bash
./recon_tool.sh
```
- `./` tells the shell to run a file from the current folder rather than searching `PATH`.

**📸 Screenshot #6:** the target prompt and the four-option menu appearing.

---

## Part 5 — Mandatory tool tests

Run the script once per tool you're testing (you need **at least two** successful runs for the assessment, but doing all three is good practice).

### Test 1: WhatWeb
```bash
./recon_tool.sh
```
Enter your authorised target, then choose `1`.

**📸 Screenshot #7:** WhatWeb's output printing successfully in the terminal.

### Test 2: Nmap
```bash
./recon_tool.sh
```
Enter the same target, then choose `2`.

**📸 Screenshot #8:** the `nmap -sV` output (service/version detection results).

### Test 3: DIRB
```bash
./recon_tool.sh
```
Enter the same target, then choose `3`.

**📸 Screenshot #9 (if required):** DIRB's discovered-paths output. Only Screenshots #7 and #8 (or any two tool screenshots) are strictly mandatory, but including all three strengthens your evidence.

---

## Part 6 — Optional improvement: saving output with `tee`

If you want to go further than the minimum requirement, add output logging:
```bash
mkdir -p results
nmap -sV "$target" | tee "results/nmap-$target.txt"
whatweb "http://$target" | tee "results/whatweb-$target.txt"
dirb "http://$target" | tee "results/dirb-$target.txt"
```
`tee` prints the output to your terminal **and** writes an identical copy to a file at the same time, which is handy for keeping records of each scan. Only add this after your mandatory version already works — treat it as a bonus, not a prerequisite.

---

## Part 7 — Evidence checklist for your report

Make sure your submission includes:
- [ ] Screenshot of your working `pwd` path (Screenshot #1)
- [ ] Screenshot of your Bash code (`cat recon_tool.sh`, Screenshot #4)
- [ ] Screenshot of the empty-target error (Screenshot #3)
- [ ] Screenshot of the target prompt and menu (Screenshot #6)
- [ ] Screenshot of successful WhatWeb execution (Screenshot #7)
- [ ] Screenshot of successful Nmap **or** DIRB execution (Screenshot #8 or #9)
- [ ] Screenshot of `chmod +x` / `ls -l` executable evidence (Screenshot #5)
- [ ] A short explanation, in your own words, covering:
  1. The purpose of the script
  2. How `read` stores the target
  3. How the menu stores the choice
  4. How `case` selects a tool
  5. Why no target is hardcoded
  6. Why `chmod +x` is required
  7. Why authorisation matters
- [ ] The `recon_tool.sh` file itself

---

## Part 8 — Quick answers for the understanding questions

These are short reference answers — write your own version for the report rather than copying verbatim:

1. **Shebang** — tells the OS which interpreter should execute the script.
2. **`read -rp`** — displays a prompt and reads user input into a variable, treating backslashes literally.
3. **Quoting `"$target"`** — prevents word-splitting or glob expansion if the value contains spaces or special characters.
4. **`-z`** — tests whether a string is empty (zero length).
5. **`exit 1`** — ends the script and reports a non-zero (failure) status to the shell.
6. **`case` for menus** — cleanly matches one variable against many discrete options without a long `if/elif` chain.
7. **`;;`** — marks the end of one `case` branch.
8. **`*`** — the catch-all pattern matching anything not already handled.
9. **`http://$target`** — WhatWeb and DIRB scan web servers, so the target needs a URL scheme in front of it.
10. **`nmap -sV`** — probes open ports to detect the service and version running on each.
11. **`command -v`** — checks whether a command exists and is executable on the current `PATH`.
12. **`chmod +x`** — grants execute permission on the file.
13. **`./`** — runs a file from the current directory instead of relying on `PATH`.
14. **`tee`** — displays output on screen while simultaneously saving it to a file.
15. **No-hardcoding requirement** — satisfied by using `read` to capture `$target` interactively instead of writing a fixed IP/domain into the script.

---

### Troubleshooting quick reference

| Problem | Likely fix |
|---|---|
| `Permission denied` | Run `chmod +x recon_tool.sh` |
| `No such file or directory` | Check `pwd` and the filename spelling |
| `command not found` | Check spelling; verify with `command -v <tool>` |
| `unexpected token` / syntax error | Look for a missing `fi`, `esac`, `;;`, quote, or bracket |
| Menu always says "Invalid option" | Confirm `read` is storing into `choice` and `case` uses `"$choice"` |
| Web tools can't connect | Confirm the target is actually running HTTP and is authorised |
