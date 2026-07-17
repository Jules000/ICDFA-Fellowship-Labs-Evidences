# WADF-2026-M01 — Week 04 Walkthrough
### Network Configuration, Linux Security, User Administration & Capstone Challenges
*A beginner-friendly, step-by-step guide. Follow it top to bottom inside your lab VM.*

> **How to use this guide:** Every command block is something you type exactly as shown (replace anything in `<angle brackets>` with your own value). Every 📸 marks a point where you should take a screenshot for your evidence pack — make sure your terminal prompt is visible in the shot.

---

## 0. Before You Start

1. Open your Ubuntu VM (Desktop or Server) and log in with your regular sudo-enabled user.
2. Take a VM snapshot now, before you touch users/groups/permissions/network settings.
3. Open a terminal. Create a folder to keep your work organized:

```bash
mkdir -p ~/wadf-labs/week4/scripts
mkdir -p ~/wadf-labs/week4/evidence
cd ~/wadf-labs/week4
```

4. Fill in your student identification block at the top of your report (name, registration number, `lsb_release -a` output for distro/version, `hostname` for VM hostname).

```bash
lsb_release -a
hostname
```
📸 **Screenshot 0** — this identification info.

---

## LAB 7 — Network & Security Baseline

**Rule for all of Lab 7: read-only inspection only.** Never run anything that changes routes, restarts networking, or disables a firewall.

### 7A — Interfaces, Addressing, Routes

**Step 1 — List interfaces**
```bash
ip -br link
```
Output looks like:
```
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
enp0s3           UP             08:00:27:xx:xx:xx <BROADCAST,MULTICAST,UP,LOWER_UP>
```
- `lo` = loopback (always present).
- Any interface with `UP` and `LOWER_UP` is your active network card. Note its name (e.g. `enp0s3`, `eth0`).

📸 **Screenshot 1** — `ip -br link` output.

**Step 2 — Record IP addressing**
```bash
ip -br addr
```
Note the IPv4 (e.g. `192.168.x.x/24`) and IPv6 addresses next to your active interface. If your instructor requires it, mask the last two digits of a public IP with `x` in your written report (don't alter the actual screenshot unless told to blur it).

📸 **Screenshot 2** — `ip -br addr` output.

**Step 3 — Inspect the routing table**
```bash
ip route
ip route get 1.1.1.1
```
The line starting `default via ... dev ...` is your default gateway and the interface used to reach it. `ip route get 1.1.1.1` confirms which interface/source address would be used to reach the internet.

📸 **Screenshot 3** — both outputs.

**Step 4 — Test local reachability**
```bash
getent hosts localhost
getent hosts "$(hostname)"
ping -c 3 127.0.0.1
```
`getent hosts` proves name resolution works for loopback and your own hostname.

📸 **Screenshot 4** — this block.

**Step 5 — Write the explanation (goes in your report, not the terminal)**
Write 4–6 sentences in your own words along these lines: *a network interface is the physical/virtual device that sends and receives frames; the IP address is the logical address assigned to that interface so it can participate in a network; the default route tells the kernel which interface/gateway to use when no more specific route matches the destination — so all three work together: the interface is the "door", the IP is the "address on the door", and the default route is "which door to use when you don't know the exact path".*

---

### 7B — DNS, Name Resolution, Listening Services

**Step 1 — Resolver configuration**
```bash
resolvectl status 2>/dev/null || cat /etc/resolv.conf
cat /etc/hosts
```
📸 **Screenshot 5** — resolver + hosts file.

**Step 2 — Test resolution**
```bash
getent ahosts example.com | head
getent ahosts icdfa.edu.ng | head
getent hosts "$(hostname)"
```
Record honestly if one fails (e.g. no internet on the VM, or the domain doesn't resolve) — that's fine, just note it and explain why in your report (e.g. "VM has NAT networking but DNS forwarding is not configured").

📸 **Screenshot 6** — the three lookups (success or failure, as they actually happen).

**Step 3 — List listening services**
```bash
ss -tulpn 2>/dev/null || ss -tul
```
If `ss -tulpn` shows `Permission denied` for process names, that's expected without sudo — record it anyway, then try:
```bash
sudo ss -tulpn
```
📸 **Screenshot 7** — listening services output.

**Step 4 — Associate a service with a process**
Pick one line from the output above, e.g. one showing `127.0.0.1:631` (CUPS) or `:22` (SSH). The last column with `sudo` shows `users:(("sshd",pid=1234,fd=3))` — that's the process name and PID.

**Step 5 — Interpret exposure**
For each listening service you captured, write one line: is the local address `127.0.0.1` / `::1` (loopback only — not reachable from the network) or `0.0.0.0` / `*` / your LAN IP (reachable from other machines)?

---

### 7C — Basic Security Posture

**Step 1 — Review privileged access**
```bash
sudo -l
id
getent group sudo 2>/dev/null || getent group wheel
```
📸 **Screenshot 8** — this block.

**Step 2 — Review SSH posture**
```bash
grep -E '^(PermitRootLogin|PasswordAuthentication)' /etc/ssh/sshd_config 2>/dev/null || echo "SSH server config not found"
```
If SSH isn't installed, that's a normal result on a Desktop VM — just record it.

📸 **Screenshot 9** — SSH check.

**Step 3 — Check firewall state**
```bash
sudo ufw status verbose 2>/dev/null || true
sudo nft list ruleset 2>/dev/null | head -n 40 || true
```
Do **not** run `sudo ufw disable` or similar — you're only reporting the state.

📸 **Screenshot 10** — firewall check.

**Step 4 — Review updates**
```bash
sudo apt update -qq
apt list --upgradable 2>/dev/null | head -n 25
```
📸 **Screenshot 11** — updates output.

**Step 5 — Hardening note (write in report)**
Three example low-risk recommendations you can adapt to what you actually observed:
1. Disable SSH password authentication in favor of key-based login (if SSH is exposed with `PasswordAuthentication yes`).
2. Enable and configure UFW to default-deny incoming traffic if it was found inactive.
3. Apply pending security updates regularly (`unattended-upgrades` package) since updates were found pending.

---

## LAB 8 — User Management, Ownership, Permissions, Capstone

**Critical:** Use unique, obviously fake lab names — never real staff/student names or passwords.

### 8A — Foundations

**Step 1 — Create a test group and user**
Pick your own unique names, e.g. `wadf-team` and `wadf-tester1` (replace with something identifiable to you, like your initials).

```bash
sudo groupadd wadf-team
sudo useradd -m -s /bin/bash -g wadf-team wadf-tester1
sudo passwd wadf-tester1
```
(Set a lab-only throwaway password when prompted — do **not** screenshot the password prompt itself with visible characters; it's masked anyway.)

**Step 2 — Verify**
```bash
id wadf-tester1
getent passwd wadf-tester1
getent group wadf-team
```
📸 **Screenshot 12** — creation + verification.

**Step 3 — Create a shared directory**
```bash
sudo mkdir -p /srv/wadf-practice/wadf-team
sudo chown wadf-tester1:wadf-team /srv/wadf-practice/wadf-team
```

**Step 4 — Apply shared-directory permissions**
```bash
sudo chmod 2770 /srv/wadf-practice/wadf-team
ls -ld /srv/wadf-practice/wadf-team
```
`2770` breaks down as:
- `2` = **setgid bit** — new files/subdirectories created inside inherit the directory's group (`wadf-team`), instead of the creator's primary group.
- `7` (owner) = read/write/execute for `wadf-tester1`.
- `7` (group) = read/write/execute for `wadf-team` members.
- `0` (others) = no access at all.

📸 **Screenshot 13** — `ls -ld` showing `drwxrws---`.

**Step 5 — Explain special permissions (write in report)**
- **setgid on a directory**: files created inside inherit the directory's group, not the creator's — used for team collaboration folders so everyone's uploads stay in the shared group automatically.
- **sticky bit on a directory**: even if a user has write access to the directory, they can only delete/rename files *they own* — used on shared/public directories like `/tmp` to stop users from deleting each other's files.

---

### 8B / Challenge A — Department Users & Confidential Data

**Step 1 — Prepare the namespace**
```bash
sudo mkdir -p /srv/wadf-departments/engineering
sudo mkdir -p /srv/wadf-departments/sales
sudo mkdir -p /srv/wadf-departments/is
```

**Step 2 — Create department groups**
```bash
sudo groupadd engineering
sudo groupadd sales
sudo groupadd is
```

**Step 3 — Create administrative users** (one admin per department)
```bash
sudo useradd -m -s /bin/bash -g engineering eng-admin
sudo useradd -m -s /bin/bash -g sales sales-admin
sudo useradd -m -s /bin/bash -g is is-admin
sudo passwd eng-admin
sudo passwd sales-admin
sudo passwd is-admin
```

**Step 4 — Create department users** (two normal users per department)
```bash
sudo useradd -m -s /bin/bash -g engineering eng-user1
sudo useradd -m -s /bin/bash -g engineering eng-user2
sudo useradd -m -s /bin/bash -g sales sales-user1
sudo useradd -m -s /bin/bash -g sales sales-user2
sudo useradd -m -s /bin/bash -g is is-user1
sudo useradd -m -s /bin/bash -g is is-user2
sudo passwd eng-user1
sudo passwd eng-user2
sudo passwd sales-user1
sudo passwd sales-user2
sudo passwd is-user1
sudo passwd is-user2
```
📸 **Screenshot 14** — run `getent passwd | grep -E 'eng-|sales-|is-'` to show all 9 accounts at once.

**Step 5 — Secure the directories**

For each department (repeat the pattern for `sales` and `is`):
```bash
sudo chown eng-admin:engineering /srv/wadf-departments/engineering
sudo chmod 2770 /srv/wadf-departments/engineering
sudo chmod +t /srv/wadf-departments/engineering
```
```bash
sudo chown sales-admin:sales /srv/wadf-departments/sales
sudo chmod 2770 /srv/wadf-departments/sales
sudo chmod +t /srv/wadf-departments/sales
```
```bash
sudo chown is-admin:is /srv/wadf-departments/is
sudo chmod 2770 /srv/wadf-departments/is
sudo chmod +t /srv/wadf-departments/is
```
Why `2770` **plus** sticky bit (mode becomes `drwxrws--T` or `drwxrws--t`):
- Owner (department admin) and group (department staff) get full rwx.
- Others get nothing — no cross-department access.
- setgid (`2`) → new files automatically belong to the department group.
- sticky bit (`+t`) → a normal group member can create files but can't delete a **peer's** file just because the directory is group-writable; only the file's owner (or the admin/root) can delete it.

```bash
ls -ld /srv/wadf-departments/*
```
📸 **Screenshot 15** — the `ls -ld` for all three department directories (should show `drwxrws--T`).

**Step 6 — Create confidential notices**
For each department:
```bash
echo "This file contains confidential information for the department." | sudo tee /srv/wadf-departments/engineering/confidential.txt
sudo chown eng-admin:engineering /srv/wadf-departments/engineering/confidential.txt
sudo chmod 640 /srv/wadf-departments/engineering/confidential.txt
```
Repeat with `sales-admin:sales` and `is-admin:is` for the other two files.

`640` = owner (admin) read/write, group (department) read-only, others none — exactly matching "admin can modify, department users can read, others get nothing."

```bash
ls -l /srv/wadf-departments/*/confidential.txt
```
📸 **Screenshot 16** — this listing (should show `-rw-r-----`).

**Step 7 — Validate: full verification table + access tests**

Verification commands:
```bash
find /srv/wadf-departments -maxdepth 2 -printf '%M %u:%g %p\n' | sort
```
📸 **Screenshot 17** — full recursive permission listing. Use this to build your evidence table (columns: user, primary group, directory owner/group/mode, file owner/group/mode).

**Allowed-access test** — switch to a normal department user and read the confidential file:
```bash
sudo -u eng-user1 cat /srv/wadf-departments/engineering/confidential.txt
```
Expected: the file content prints — proves group read access works.

**Denied-access test** — a user from a *different* department tries to enter the directory:
```bash
sudo -u sales-user1 ls /srv/wadf-departments/engineering
```
Expected: `Permission denied` — proves others have no access.

📸 **Screenshot 18** — both the allowed test (success) and denied test (Permission denied) in the same shot or two consecutive shots.

---

### 8C / Challenge B — Onboarding Script

**Step 1 — Create the script file**
```bash
nano ~/wadf-labs/week4/scripts/onboard_user.sh
```
Paste the following, then save (`Ctrl+O`, `Enter`, `Ctrl+X` in nano):

```bash
#!/bin/bash
# onboard_user.sh — creates a lab-only group + user + protected home-style directory
# Usage: sudo ./onboard_user.sh <username> <groupname>

set -u

# 1. Require root
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: this script must be run with sudo/root privileges." >&2
    exit 1
fi

USERNAME="${1:-}"
GROUPNAME="${2:-}"

if [[ -z "$USERNAME" || -z "$GROUPNAME" ]]; then
    read -rp "Enter new username: " USERNAME
    read -rp "Enter new group name: " GROUPNAME
fi

# 2. Check duplicate group
if getent group "$GROUPNAME" >/dev/null 2>&1; then
    echo "ERROR: group '$GROUPNAME' already exists." >&2
    exit 2
fi

# 3. Check duplicate user
if getent passwd "$USERNAME" >/dev/null 2>&1; then
    echo "ERROR: user '$USERNAME' already exists." >&2
    exit 3
fi

# 4. Create group and user
groupadd "$GROUPNAME" || { echo "ERROR: failed to create group." >&2; exit 4; }
useradd -m -s /bin/bash -g "$GROUPNAME" "$USERNAME" || { echo "ERROR: failed to create user." >&2; exit 5; }

# 5. Set password securely (prompts, never echoed/logged)
passwd "$USERNAME"

# 6. Create protected directory
USERDIR="/srv/wadf-userdirs/$USERNAME"
mkdir -p "$USERDIR"
chown "$USERNAME":"$GROUPNAME" "$USERDIR"
chmod 2770 "$USERDIR"
chmod +t "$USERDIR"

echo "SUCCESS: user '$USERNAME' created with group '$GROUPNAME' and protected directory '$USERDIR'."
exit 0
```

**Step 2 — Make it executable**
```bash
chmod +x ~/wadf-labs/week4/scripts/onboard_user.sh
```

**Step 3 — Test a successful run**
```bash
cd ~/wadf-labs/week4/scripts
sudo ./onboard_user.sh newlabuser newlabgroup
echo "Exit code: $?"
```
📸 **Screenshot 19** — the successful run and `echo $?` showing `0`. (Do not let the actual password characters show — they won't, since `passwd` masks input.)

**Step 4 — Verify it**
```bash
getent passwd newlabuser
id newlabuser
ls -ld /srv/wadf-userdirs/newlabuser
```
📸 **Screenshot 20** — verification block.

**Step 5 — Test duplicate group failure**
```bash
sudo ./onboard_user.sh anotheruser newlabgroup
echo "Exit code: $?"
```
Expected: `ERROR: group 'newlabgroup' already exists.` and exit code `2`.

**Step 6 — Test duplicate user failure**
```bash
sudo ./onboard_user.sh newlabuser anothergroup
echo "Exit code: $?"
```
Expected: `ERROR: user 'newlabuser' already exists.` and exit code `3`.

📸 **Screenshot 21** — both duplicate-failure tests with their exit codes.

---

### 8D / Challenge C — Log Archiving

**Step 1 — Create controlled source data**
```bash
mkdir -p ~/wadf-challenge/log-source ~/archive ~/backup
for f in alternatives auth bootstrap cron dpkg kern mail; do
  printf 'Controlled lab evidence for %s.log — %s\n' "$f" "$(date -Is)" > ~/wadf-challenge/log-source/${f}.log
done
ls -1 ~/wadf-challenge/log-source
```
📸 **Screenshot 22** — the seven files listed.

**Step 2 — Archive the files (names only, no source path) with verbose output**
```bash
tar -cvf ~/archive/log.tar -C ~/wadf-challenge/log-source .
```
The `-C ~/wadf-challenge/log-source` tells tar to change into that directory *before* adding files, so only bare filenames (like `auth.log`) go into the archive — not the full `/home/you/wadf-challenge/log-source/auth.log` path.

📸 **Screenshot 23** — the verbose creation output (7 filenames listed).

**Step 3 — List before extraction**
```bash
tar -tf ~/archive/log.tar
```
Compare this list against your 7 required filenames.

📸 **Screenshot 24** — the `tar -tf` listing.

**Step 4 — Extract to backup**
```bash
tar -xvf ~/archive/log.tar -C ~/backup
ls -1 ~/backup
```
📸 **Screenshot 25** — extraction output + backup directory listing showing all 7 restored files.

---

### 8E / Challenge D — Pipes, Redirection, Regex

**Step 1 — Create the controlled dataset**
```bash
mkdir -p ~/wadf-challenge
cat > ~/wadf-challenge/auth-events.log <<'EOF'
2026-07-12T08:00:01Z AUTH FAILED user=alice src=198.51.100.23 reason=bad_password
2026-07-12T08:01:19Z AUTH SUCCESS user=alice src=198.51.100.23 method=password
2026-07-12T08:03:44Z AUTH FAILED user=unknown src=203.0.113.57 reason=invalid_user
2026-07-12T08:04:10Z AUTH FAILED user=admin src=198.51.100.23 reason=bad_password
2026-07-12T08:05:31Z AUTH FAILED user=admin src=198.51.100.23 reason=bad_password
2026-07-12T08:07:02Z AUTH SUCCESS user=bob src=192.0.2.44 method=key
2026-07-12T08:08:27Z AUTH FAILED user=guest src=203.0.113.57 reason=bad_password
2026-07-12T08:09:16Z AUTH FAILED user=guest src=203.0.113.57 reason=bad_password
2026-07-12T08:11:58Z AUTH FAILED user=root src=192.0.2.99 reason=bad_password
2026-07-12T08:13:42Z AUTH SUCCESS user=carol src=192.0.2.44 method=key
EOF
cd ~/wadf-challenge
cat auth-events.log
```
📸 **Screenshot 26** — the source data.

**Step 2 — Identify failed authentication events**
```bash
grep -E 'AUTH FAILED' auth-events.log > failed_events.txt
cat failed_events.txt
```
`AUTH FAILED` (with the space, no wildcard) matches the literal phrase and deliberately will **not** match `AUTH SUCCESS` lines, because "SUCCESS" never contains the substring "FAILED".

📸 **Screenshot 27** — `failed_events.txt` contents (7 lines).

**Step 3 — Summarise source IPs (count, highest → lowest)**
```bash
grep -E 'AUTH FAILED' auth-events.log \
  | grep -oE 'src=[0-9.]+' \
  | cut -d= -f2 \
  | sort \
  | uniq -c \
  | sort -rn > failed_ip_summary.txt
cat failed_ip_summary.txt
```
Pipeline explanation (put this in your report):
1. `grep -E 'AUTH FAILED'` — keeps only failed-login lines.
2. `grep -oE 'src=[0-9.]+'` — prints only the matching `src=<ip>` token from each line.
3. `cut -d= -f2` — splits on `=` and keeps the IP address only.
4. `sort` — groups identical IPs together (required before `uniq -c`).
5. `uniq -c` — counts consecutive duplicate lines (i.e. counts occurrences per IP).
6. `sort -rn` — sorts numerically, highest count first.

📸 **Screenshot 28** — `failed_ip_summary.txt` contents.

**Step 4 — Identify suspicious IPs (≥3 failed events), then append a timestamp**
```bash
awk '$1 >= 3 {print $2}' failed_ip_summary.txt > suspicious_ips.txt
cat suspicious_ips.txt
echo "Report generated: $(date -Is)" >> suspicious_ips.txt
cat suspicious_ips.txt
```
Note `>` creates/overwrites the file with the IP list; `>>` appends the timestamp afterward without erasing the IPs already written.

📸 **Screenshot 29** — `suspicious_ips.txt` before and after the timestamp append.

**Step 5 — Capture a controlled error separately**
```bash
grep -E 'AUTH FAILED' this-file-does-not-exist.log 2> command_errors.txt
cat command_errors.txt
```
`2>` redirects only standard error (the "file not found" message) into `command_errors.txt`, separate from normal output.

📸 **Screenshot 30** — `command_errors.txt` contents.

**Step 6 — One-paragraph explanation (write in report)**
Summarize in your own words: the pipeline filters raw log lines down to only failed events, extracts just the IP address field from each, groups and counts identical IPs, and ranks them by frequency; the regex `AUTH FAILED` is specific enough that it can never match an `AUTH SUCCESS` line since that exact substring doesn't appear there, so no successful logins leak into the failed-event report.

---

## Final Reflection (write this in your report)

Answer briefly:
- **One key skill you feel confident with** — e.g. "I'm confident with chmod/chown and designing directory permissions for shared team access."
- **One error you hit and how you fixed it** — e.g. "My first `tar` archive included the full path because I forgot `-C`; I recreated it using `-C ~/wadf-challenge/log-source .` and verified with `tar -tf`."
- **One skill to practise more** — e.g. regex, or firewall configuration.

---

## Submission Packing Checklist

Before zipping/exporting, confirm you have:
- [ ] All 30 screenshots above, each showing your terminal prompt clearly.
- [ ] Your written explanations for 7A step 5, 8A step 5, 8E step 6, and the hardening note.
- [ ] `onboard_user.sh` saved as its own file.
- [ ] `~/archive/log.tar` plus its creation/listing/restore screenshots.
- [ ] `failed_events.txt`, `failed_ip_summary.txt`, `suspicious_ips.txt`, `command_errors.txt` zipped together.
- [ ] The verification table for Challenge A (user/group/directory/file ownership + mode).
- [ ] Final reflection paragraph.

Rename your files exactly as required before submitting:
```
WADF-2026-M01_Week04_<RegistrationNumber>_Assessment-Evidence.pdf
WADF-2026-M01_Week04_<RegistrationNumber>_onboard_user.sh
WADF-2026-M01_Week04_<RegistrationNumber>_challengeD-reports.zip
```

You can zip the Challenge D reports like this:
```bash
cd ~/wadf-challenge
zip WADF-2026-M01_Week04_<RegistrationNumber>_challengeD-reports.zip \
  failed_events.txt failed_ip_summary.txt suspicious_ips.txt command_errors.txt
```

Deadline: **17 July 2026, 23:59 WAT** — that's today, so pace yourself: Lab 7 (~1 hr), 8A (~20 min), Challenge A (~45 min), Challenge B (~40 min), Challenge C (~20 min), Challenge D (~30 min), report writing (~45 min).
