# WADF-2026-M02 — Week 8 & Month 2 Assessment: Complete Walkthrough
**Deadline:** August 14, 2026, 23:59 WAT

This guide gives you the exact command to run and the exact moment to take a screenshot for every lab (33–42) and every exercise in the Month 2 Assessment. Save screenshots with descriptive names as you go, e.g. `lab33_step1_inode.png`, `ex1_step3_find.png`.

---

## Suggested Folder Structure (set this up first)

```bash
mkdir -p ~/Month2_Assessment_YourName/{Lab_Evidence,Assessment_Practical_YourName}
cd ~/Month2_Assessment_YourName
```
📸 **Screenshot:** the folder tree (`ls -R ~/Month2_Assessment_YourName`) — proves your submission is organized before you start.

---

## LAB 33 — Filesystem Links (1.5 hrs)

**Setup:**
```bash
mkdir -p ~/archive_test/documents
echo "Original content" > ~/archive_test/documents/file1.txt
```

| Step | Command | 📸 Screenshot |
|---|---|---|
| 1. Inodes | `ls -i ~/archive_test/documents/file1.txt` | Terminal showing the inode number |
| 2. Hard link | `ln ~/archive_test/documents/file1.txt ~/archive_test/documents/file1_hardlink.txt` | Run **immediately after**, then `ls -i ~/archive_test/documents/file1*` — capture both files sharing the same inode |
| 3. Verify hard link behavior | `echo "New content" >> ~/archive_test/documents/file1.txt` then `cat ~/archive_test/documents/file1_hardlink.txt` | Output showing "New content" appears in the hard link too |
| 4. Symlink | `ln -s ~/archive_test/documents/file1.txt ~/archive_test/documents/file1_symlink.txt` then `ls -il ~/archive_test/documents/file1*` | Full listing showing symlink's different inode and the `->` arrow |
| 5. Broken symlink | `rm ~/archive_test/documents/file1.txt` then `cat ~/archive_test/documents/file1_symlink.txt` | Error message ("No such file or directory") proving the symlink broke |
| 6. Link count | `ls -l ~/archive_test/documents/` | Full listing — point out the link-count column in your write-up |

**Evidence to submit:** the 4 screenshots listed in the original brief (inode numbers, hard link creation, symlink creation, broken symlink) — steps 1, 2, 4, and 5 above cover these exactly.

---

## LABS 34–42 — Advanced System Administration

These labs weren't spelled out in your brief beyond a title, so here are concrete, safe commands for each. **Read each one before running it** — steps involving GRUB, runlevels, and filesystem repair can affect your system if run carelessly; run them in a VM or container if you're not on a disposable machine.

### Lab 34: Hardware Configuration
```bash
lscpu                      # CPU info
lsblk                      # Block devices/disks
lsusb                      # USB devices (if available)
lspci                      # PCI devices (if available)
free -h                    # Memory
dmesg | less               # Kernel hardware messages
```
📸 **Screenshots:** `lscpu` output, `lsblk` output, `free -h` output.

### Lab 35: The Boot Process
```bash
systemd-analyze                  # Boot time breakdown
systemd-analyze blame            # Time per service at boot
journalctl -b                    # Full boot log
journalctl -b -p err             # Boot errors only
```
📸 **Screenshots:** `systemd-analyze` summary, `systemd-analyze blame` top entries.

### Lab 36: Bootloaders (GRUB)
```bash
cat /boot/grub/grub.cfg | head -50     # View GRUB config (path may vary: grub2)
sudo update-grub                        # Regenerate config (Debian/Ubuntu)
# or: sudo grub2-mkconfig -o /boot/grub2/grub.cfg   (RHEL/Fedora)
ls /etc/default/grub
cat /etc/default/grub
```
⚠️ Do not edit GRUB config on a machine you can't recover — practice viewing only unless instructed otherwise.
📸 **Screenshots:** GRUB config contents, `/etc/default/grub` contents.

### Lab 37: Runlevels / Targets
```bash
systemctl get-default            # Current default target
systemctl list-units --type=target
who -r                           # Legacy runlevel check
sudo systemctl set-default multi-user.target   # Example only — don't run unless asked
```
📸 **Screenshots:** current default target, list of available targets.

### Lab 38: Mounting Filesystems
```bash
lsblk -f                         # Devices + filesystem types
mount | column -t                # Currently mounted filesystems
cat /etc/fstab                   # Persistent mount config
sudo mkdir -p /mnt/testmount
sudo mount /dev/sdXN /mnt/testmount   # replace with a real, safe device/partition
df -h /mnt/testmount
sudo umount /mnt/testmount
```
📸 **Screenshots:** `lsblk -f` output, `/etc/fstab` contents, successful mount (`df -h`), successful unmount.

### Lab 39: Maintaining Filesystem Integrity
```bash
sudo fsck -N /dev/sdXN           # -N = dry run, shows what would happen (SAFE)
sudo badblocks -sv /dev/sdXN     # Scan for bad blocks (read-only mode is safest: no -w flag)
```
⚠️ Never run `fsck` on a mounted filesystem, and never use `-w` on `badblocks` on a disk with data you need.
📸 **Screenshots:** dry-run `fsck` output, `badblocks` scan output.

### Lab 40: Fixing Filesystems
```bash
# Practice on a throwaway loopback filesystem, not a real disk:
dd if=/dev/zero of=~/testdisk.img bs=1M count=100
mkfs.ext4 ~/testdisk.img
sudo mount -o loop ~/testdisk.img /mnt/testmount
sudo umount /mnt/testmount
sudo fsck -f /dev/loop0          # or the loop device shown by `losetup -a`
```
📸 **Screenshots:** filesystem creation (`mkfs.ext4`), `fsck -f` repair output.

### Lab 41: Package Management
```bash
# Debian/Ubuntu:
sudo apt update
sudo apt install -y tree
apt list --installed | grep tree
sudo apt remove -y tree
# RHEL/Fedora equivalent: sudo dnf install/remove
```
📸 **Screenshots:** install confirmation, verification that the package is installed, removal confirmation.

### Lab 42: Managing Shared Libraries
```bash
ldd /bin/ls                      # Shared libraries used by a binary
ldconfig -p | head -20           # Library cache
sudo ldconfig                    # Rebuild cache after installing new libs
echo $LD_LIBRARY_PATH
```
📸 **Screenshots:** `ldd` output on any binary, `ldconfig -p` snippet.

**For Labs 34–42 submission:** each needs the same structure as Lab 33 — objective/outcome notes, the screenshot(s) above, a one-paragraph explanation of what happened, and a completed checklist. Use the Lab 33 write-up as your template.

---

## MONTH 2 ASSESSMENT — Practical Exercises (60 pts)

Work inside `~/Month2_Assessment_YourName/Assessment_Practical_YourName/`.

### Exercise 1: File Management (10 pts)
```bash
mkdir -p ~/assessment/project/{src,docs,data}
for d in src docs data; do
  for i in 1 2 3 4 5; do
    echo "Sample content $i" > ~/assessment/project/$d/file$i.txt
  done
done
cp -r ~/assessment/project ~/assessment/project_backup
find ~/assessment/project -name "*.txt"
tar -czf ~/assessment/project_archive.tar.gz -C ~/assessment project
```
📸 **Screenshots:** directory structure (`tree ~/assessment` or `ls -R`), the `find` results, the final `ls -lh project_archive.tar.gz`.

### Exercise 2: Text Processing (10 pts)
```bash
cat <<EOF > ~/assessment/employees.csv
name,department,salary
Alice,Engineering,85000
Bob,Sales,62000
Carol,Engineering,91000
Dan,Marketing,58000
Eve,Sales,67000
Frank,Engineering,78000
Grace,HR,55000
Hank,Marketing,60000
Ivy,Engineering,95000
Jack,Sales,64000
EOF

cut -d',' -f1,3 ~/assessment/employees.csv
sort -t',' -k3 -n ~/assessment/employees.csv
grep -iE "engineering|sales" ~/assessment/employees.csv
```
Generate a short report:
```bash
echo "Employee Summary Report" > ~/assessment/report.txt
echo "Total employees: $(tail -n +2 ~/assessment/employees.csv | wc -l)" >> ~/assessment/report.txt
```
📸 **Screenshots:** `cut` output, `sort` output, `grep` output, contents of `report.txt`.

### Exercise 3: System Administration (10 pts)
```bash
sleep 300 &                      # background process
jobs                             # shows the job
top -n 1                         # snapshot of resource usage
( sleep 200 & sleep 100 )        # simple process hierarchy
ps --forest -u $USER             # visualize hierarchy
kill %1                          # terminate by job spec
# or: pkill sleep
```
📸 **Screenshots:** `jobs` output, `top` snapshot, `ps --forest` hierarchy, confirmation the process was terminated (`jobs` again, showing "Terminated").

### Exercise 4: Permissions and Security (10 pts)
```bash
mkdir ~/assessment/secure_dir
sudo groupadd projectgroup 2>/dev/null
sudo chown $USER:projectgroup ~/assessment/secure_dir
chmod 750 ~/assessment/secure_dir
sudo chmod u+s /usr/bin/some_test_binary   # example only — use a copy, not a real system binary
chmod +t ~/assessment/secure_dir           # sticky bit example
ls -ld ~/assessment/secure_dir
```
⚠️ Never set setuid on a real system binary for a demo — copy a harmless script instead:
```bash
cp /bin/echo ~/assessment/myecho
chmod u+s ~/assessment/myecho
ls -l ~/assessment/myecho
```
📸 **Screenshots:** `ls -ld` showing group ownership + 750 permissions, `ls -l` showing the `s` bit on `myecho`, `ls -ld` showing the sticky bit (`t`).

### Exercise 5: Archiving and Backup (10 pts)
```bash
tar -czf ~/assessment/full_backup.tar.gz -C ~/assessment project
touch ~/assessment/project/src/newfile.txt
find ~/assessment/project -newer ~/assessment/full_backup.tar.gz -type f
tar -czf ~/assessment/incremental_backup.tar.gz $(find ~/assessment/project -newer ~/assessment/full_backup.tar.gz -type f)
gzip -k ~/assessment/report.txt
bzip2 -k ~/assessment/employees.csv
tar -tzf ~/assessment/full_backup.tar.gz     # verify archive contents
```
📸 **Screenshots:** full backup listing, incremental backup file list, both compressed files (`ls -lh *.gz *.bz2`), verification output.

### Exercise 6: Advanced Skills (10 pts)
```bash
mkdir ~/assessment/final_project
cp ~/assessment/employees.csv ~/assessment/final_project/
cp ~/assessment/report.txt ~/assessment/final_project/
ln -s ~/assessment/final_project/employees.csv ~/assessment/final_project/data_link.csv
ln ~/assessment/final_project/report.txt ~/assessment/final_project/report_hardlink.txt
chmod 640 ~/assessment/final_project/employees.csv
chmod 750 ~/assessment/final_project
tar -czf ~/assessment/final_project_backup.tar.gz -C ~/assessment final_project
```
📸 **Screenshots:** `ls -l` showing both link types, `ls -ld` showing permissions, final archive listing.

Write a short `documentation.md` in this exercise's folder describing what you did and why — this is required for full marks.

---

## MONTH 2 ASSESSMENT — Multiple-Choice (40 pts)

No screenshots needed here — put answers with one-line justifications in `MCQ_Answers.txt`.

| # | Answer | Quick justification to write |
|---|---|---|
| 1 | B — `pwd` | `pwd` = print working directory |
| 2 | B — `?` | `?` matches exactly one character; `*` matches any number |
| 3 | B | `>` redirects (overwrites) stdout |
| 4 | A | `> file 2>&1` sends stdout to file, then stderr to where stdout now points |
| 5 | B — `ps` | `ps` lists processes; `top` is interactive, not a listing command |
| 6 | C | Trailing `&` backgrounds a process at launch |
| 7 | A | 7=rwx, 5=r-x, 5=r-x |
| 8 | B | A hard link is another directory entry for the same inode |
| 9 | B — `ln -s` | `-s` flag makes it symbolic |
| 10 | C | `c`=create, `z`=gzip, `f`=file |
| 11 | B | `find` searches by name, type, time, size, etc. |
| 12 | B | `-i` = case-insensitive |
| 13 | C — `:wq` | write and quit |
| 14 | B | `-r` reverses sort order |
| 15 | C | `-c` prefixes each unique line with its count |
| 16 | B | `nice` sets scheduling priority |
| 17 | B | `/dev/null` discards anything written to it |
| 18 | B | `umask` sets the default permission mask for new files |
| 19 | B | `chown` changes owner (and optionally group with `chown user:group`) |
| 20 | C | `>` overwrites the file, `>>` appends to it |

---

## Final Submission Checklist

```bash
cd ~/Month2_Assessment_YourName
touch README.md                     # summarize what's inside, per-lab notes
# Fill README.md with an index of folders/screenshots
tar -czf ~/Month2_Assessment_YourName.tar.gz -C ~ Month2_Assessment_YourName
```

- [ ] Lab 33 folder complete with 4 required screenshots + checklist filled in
- [ ] Labs 34–42 each have their own subfolder, screenshots, and short write-up
- [ ] `Assessment_Practical_YourName/` has all 6 exercises with screenshots + documentation
- [ ] `MCQ_Answers.txt` has all 20 answers with justifications
- [ ] `README.md` written at the top level indexing everything
- [ ] Everything zipped/tarred as `Month2_Assessment_YourName.tar.gz` before 23:59 WAT, Aug 14, 2026

📸 **Final screenshot:** `ls -lh ~/Month2_Assessment_YourName.tar.gz` — proof the archive exists and is non-empty, right before you submit.
