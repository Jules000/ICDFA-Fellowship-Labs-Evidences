# Lab 1A Step-by-Step Guide
**CIP-B101 – Number Systems, ASCII, Timestamps and Data Representation**

> Read this like a teacher walking beside you. Do the steps **in order**. Every 📸 marks a screenshot you must take. Every ✍️ marks something you must write in your report.
> Everything below is checked against the lab sheet. The expected outputs are given so you can confirm yours is right. **You still must run every command yourself and take your own screenshots**, because the lab says copied screenshots are rejected.

---

## 0. Before you touch the keyboard

1. Read the course slides "Understand Number Systems and Timestamps" first. The lab requires it.
2. Open your Linux terminal (Kali, Ubuntu, WSL or a VM).
3. Install the tools (one time):
   ```bash
   sudo apt update
   sudo apt install -y bc xxd
   python3 --version
   ```
4. Open a document (Word/Google Docs) now. You will paste screenshots into it as you go and export it as a PDF at the end. Name the final file: `CIP-B101_Lab1A_FirstName_LastName.pdf`

### How to take a good screenshot (applies to all 📸)
Every screenshot must clearly show **all four** of these:
- your **name or student ID** (it will show in the prompt/folder name, see Step 1)
- the **command** you typed
- the **output**
- the **file names** involved (where relevant)

Tips: make the terminal window big, zoom the font up, and don't let output scroll off screen. Use `clear` before each task so the screenshot only shows that task.

---

## 1. Set up your working folder

The lab says your name or student ID must appear in the working folder. So **use your own name in the folder** (the lab shows `cip-b101-lab1a`; add your name to it, e.g. `cip-b101-lab1a-jules`). Replace `jules` with your first name or student ID.

```bash
mkdir -p ~/cip-b101-lab1a-jules
cd ~/cip-b101-lab1a-jules
pwd
```

Expected: `pwd` prints something like `/home/yourusername/cip-b101-lab1a-jules`.

📸 **Screenshot 1** – Take it **right after `pwd`**. It must show the three commands and the path printed.

---

## 2. Task A – Number systems

### 2A. Do the math by hand FIRST (on paper)
Your marks (15) depend on **showing the method**. Write each on paper, photograph it (or type it neatly), and put it in the report.

**Exercise 1: 101010₂ → decimal.** Write the weights right to left: 1, 2, 4, 8, 16, 32.

| bit | 1 | 0 | 1 | 0 | 1 | 0 |
|---|---|---|---|---|---|---|
| weight | 32 | 16 | 8 | 4 | 2 | 1 |

Add the weights where the bit is 1: 32 + 8 + 2 = **42**

**Exercise 2: AB2₁₆ → decimal.** A = 10, B = 11.
(10 × 16²) + (11 × 16¹) + (2 × 16⁰) = 2560 + 176 + 2 = **2738**

**Exercise 3: 126₁₀ → binary (divide by 2, read remainders bottom to top).**

| Division | Quotient | Remainder |
|---|---|---|
| 126 ÷ 2 | 63 | 0 |
| 63 ÷ 2 | 31 | 1 |
| 31 ÷ 2 | 15 | 1 |
| 15 ÷ 2 | 7 | 1 |
| 7 ÷ 2 | 3 | 1 |
| 3 ÷ 2 | 1 | 1 |
| 1 ÷ 2 | 0 | 1 |

Read upward: **1111110**

**Exercise 4: 2738₁₀ → hexadecimal (divide by 16).**

| Division | Quotient | Remainder (hex) |
|---|---|---|
| 2738 ÷ 16 | 171 | 2 |
| 171 ÷ 16 | 10 | 11 → B |
| 10 ÷ 16 | 0 | 10 → A |

Read upward: **AB2**

**Exercise 5: 101010110010₂ → hex (group in fours from the right).**
`1010 | 1011 | 0010` → A | B | 2 → **AB2**
(Notice it equals Exercise 2. That is on purpose: same number, two bases.)

### 2B. Validate with Linux and Python

```bash
clear
echo $((2#101010))
echo $((16#AB2))
echo "obase=2;126" | bc
printf "%X\n" 2738
python3 - <<'PY'
print(int('101010', 2))
print(int('AB2', 16))
print(bin(126))
print(hex(2738))
PY
```

> ⚠️ In the lab document, `printf "%X\n" 2738` got broken across lines when it was formatted. Type it on **one line** as above, with `\n` inside the quotes.

Expected output:
```
42
2738
1111110
AB2
42
2738
0b1111110
0xab2
```

For Exercise 5 also run (to prove the binary → hex result):
```bash
python3 -c "print(hex(int('101010110010', 2)))"
```
Expected: `0xab2`

📸 **Screenshot 2** – Take it after all these commands have run. If the output doesn't fit on one screen, take two screenshots and call them 2a and 2b.

### 2C. Fill in the evidence table (Section 2.4)

| Evidence Value | Given Base | Manual Answer | Command Used to Verify | Screenshot Ref. |
|---|---|---|---|---|
| 101010 | Binary | 42 (decimal) | `echo $((2#101010))` | Screenshot 2 |
| AB2 | Hexadecimal | 2738 (decimal) | `echo $((16#AB2))` | Screenshot 2 |
| 126 | Decimal | 1111110 (binary) | `echo "obase=2;126" \| bc` | Screenshot 2 |
| 2738 | Decimal | AB2 (hex) | `printf "%X\n" 2738` | Screenshot 2 |
| 101010110010 | Binary | AB2 (hex) | `python3 -c "print(hex(int('101010110010',2)))"` | Screenshot 2 |

---

## 3. Task B – ASCII, UTF-8 and hex

### 3A. Create text evidence and view it as hex
```bash
clear
echo -n "Hello" > evidence_text.txt
cat evidence_text.txt
xxd evidence_text.txt
xxd -p evidence_text.txt
```
Expected:
```
Hello00000000: 4865 6c6c 6f                                Hello
48656c6c6f
```
(`cat` prints `Hello` with no newline, so the next line is glued to it. That is normal because of `-n`.)

📸 **Screenshot 3** – after `xxd -p`. It must show `xxd` output with `48 65 6c 6c 6f`.

### 3B. Hex → ASCII
```bash
clear
printf "\x48\x65\x6c\x6c\x6f\n"
printf "48656c6c6f" | xxd -r -p
echo
```
Expected: `Hello` printed twice.
(The lab's `printf "Hello\n"` line was broken in the formatting; the idea is the `\x..` hex escape method.)

### 3C. Python version
```bash
python3 - <<'PY'
import binascii
text = b'Hello'
print('ASCII bytes:', text)
print('ASCII to hex:', binascii.hexlify(text).decode())
print('Hex to ASCII:', binascii.unhexlify('48656c6c6f').decode())
print('ord(H):', ord('H'))
print('chr(72):', chr(72))
PY
```
Expected:
```
ASCII bytes: b'Hello'
ASCII to hex: 48656c6c6f
Hex to ASCII: Hello
ord(H): 72
chr(72): H
```

📸 **Screenshot 4** – Take it after 3B and 3C together (you can show both on one screen): the hex → ASCII outputs.

### 3D. Student exercise (items 6–10)
Use **your own first name** in the file name. I'll use `jules`.

```bash
clear
echo -n "Digital Forensics Begins With Bytes." > jules_lab1a.txt   # item 6
xxd jules_lab1a.txt                                                  # item 7
xxd -p jules_lab1a.txt                                               # item 8
xxd -p jules_lab1a.txt | xxd -r -p                                   # item 9
echo
echo "Digital Forensics Begins With Bytes." > jules_newline_demo.txt # for item 10
xxd jules_newline_demo.txt
```

Expected `xxd -p` (item 8), the single hex string:
`4469676974616c20466f72656e7369637320426567696e7320576974682042797465732e`
(If you hadn't used `-n`, you'd see an extra `0a` at the end.)

The task says "containing the text". I used `-n` so the file has exactly 36 bytes with no hidden newline. If you want the "real world" version, drop `-n`; just say in the report which one you did.

📸 **Screenshot 3b** (or add to Screenshot 3) – shows `jules_lab1a.txt` xxd output and hex → text result.

✍️ **Item 10: why does `0A` appear at the end?**
> `echo` without `-n` automatically adds a newline character at the end of the text. In ASCII, newline (line feed, LF) is byte `0x0A`. So `xxd` shows an extra `0a` as the last byte. It is invisible as text but it is a real byte of the file.

✍️ **Forensic explanation requirement (must be in your report):**
> An examiner must not assume every hex value is readable text. A byte like `0x48` happens to map to `H`, but the same byte values can be part of a binary structure (e.g. file header, a number, a pointer), pixels of an image, compressed data, or encrypted data. Treating them all as text gives garbage or wrong conclusions. The examiner needs context (file type, signature, structure, encoding) to decide how bytes should be interpreted. Also, UTF-8 characters outside basic ASCII use more than one byte.

---

## 4. Task C – Timestamps

### 4A. Unix epoch
```bash
clear
date +%s
date -u -d @1643643491
python3 - <<'PY'
from datetime import datetime, timezone
print(datetime.fromtimestamp(1643643491, tz=timezone.utc))
PY
```
Expected:
```
<current number, e.g. 17xxxxxxxx>
Mon Jan 31 15:38:11 UTC 2022
2022-01-31 15:38:11+00:00
```
📸 **Screenshot 5** – after these commands.

### 4B. Local vs UTC
```bash
clear
date
date -u
python3 - <<'PY'
from datetime import datetime, timezone
print('Local:', datetime.now())
print('UTC :', datetime.now(timezone.utc))
PY
```
Expected: `date` shows your local time zone (e.g. `WAT` or whatever your system has); `date -u` shows `UTC`. If your VM is set to UTC, both will look the same. Say so in the report, don't hide it.

📸 Include this in **Screenshot 5** or take it as 5b.

### 4C. Mac Absolute Time
```bash
clear
python3 - <<'PY'
from datetime import datetime, timezone
unix_epoch = datetime(1970, 1, 1, tzinfo=timezone.utc)
mac_epoch = datetime(2001, 1, 1, tzinfo=timezone.utc)
print(int((mac_epoch - unix_epoch).total_seconds()))
mac_value = 725846400
unix_value = mac_value + 978307200
print(datetime.fromtimestamp(unix_value, tz=timezone.utc))
PY
```
Expected:
```
978307200
2024-01-02 00:00:00+00:00
```
📸 **Screenshot 6** – after this command.

### 4D. Convert the other values for the worksheet
```bash
date -u -d @1675008832
date -u -d @$((725846400 + 978307200))
date +%s
date -u -d @$(date +%s)
```
Expected: `1675008832` → **Sun Jan 29 16:13:52 UTC 2023**; the Mac value → **Tue Jan 2 00:00:00 UTC 2024**.

### 4E. Fill in the timestamp worksheet (Section 4.4)

| Timestamp | Format | Conversion Command | Readable UTC Result | Screenshot |
|---|---|---|---|---|
| 1643643491 | Unix seconds | `date -u -d @1643643491` | 2022-01-31 15:38:11 UTC | 5 |
| 1675008832 | Unix seconds | `date -u -d @1675008832` | 2023-01-29 16:13:52 UTC | 5 |
| 725846400 | Mac Absolute Time | add 978307200 (= 1704153600), then `date -u -d @1704153600` *(or the Python from 4C)* | 2024-01-02 00:00:00 UTC | 6 |
| Current time | Unix seconds | `date +%s` then `date -u -d @<value>` | *your own value* | 5 |

> For the Mac row, simplest is to write: `Python: datetime.fromtimestamp(725846400+978307200, tz=timezone.utc)`. Use whatever you actually ran. Don't put a command in the table that you didn't run.

✍️ **Important warning:** In every result write **UTC** or **local** explicitly.

---

## 5. Task D – Hashing and newline

### 5A. Create two files and hash them
```bash
clear
echo "Hello" > hello_with_newline.txt
echo -n "Hello" > hello_without_newline.txt
xxd hello_with_newline.txt
xxd hello_without_newline.txt
md5sum hello_with_newline.txt hello_without_newline.txt
sha256sum hello_with_newline.txt hello_without_newline.txt
```
Expected:
```
00000000: 4865 6c6c 6f0a                           Hello.
00000000: 4865 6c6c 6f                             Hello
09f7e02f1290be211da707a266f153b3  hello_with_newline.txt
8b1a9953c4611296a827abf8c47804d7  hello_without_newline.txt
66a045b452102c59d840ec097d59d9467e13a3f34f6494e539ffd32c1bb35f18  hello_with_newline.txt
185f8db32271fe25f561a6fc938b2e264306ec304eda518007d1764826381969  hello_without_newline.txt
```
📸 **Screenshot 7** – show all six commands and outputs (zoom out/enlarge window so the long SHA-256 lines don't wrap oddly).

### 5B. Student exercise (items 11–15) with your name
```bash
clear
echo "Jules" > name_with_newline.txt          # item 11
echo -n "Jules" > name_without_newline.txt    # item 11
xxd name_with_newline.txt                     # item 12
xxd name_without_newline.txt                  # item 12
md5sum name_with_newline.txt name_without_newline.txt        # item 13
sha256sum name_with_newline.txt name_without_newline.txt     # item 13
```
Use **your own first name** instead of "Jules". Your hashes will be different from anyone else's. That's the point.

📸 **Screenshot 7b** – this output (name must be visible in the command).

✍️ Hash comparison table for the report:

| File | Bytes | MD5 | SHA-256 |
|---|---|---|---|
| hello_with_newline.txt | 48 65 6c 6c 6f **0a** | 09f7e02f… | 66a045b4… |
| hello_without_newline.txt | 48 65 6c 6c 6f | 8b1a9953… | 185f8db3… |
| name_with_newline.txt | *yours* | *yours* | *yours* |
| name_without_newline.txt | *yours* | *yours* | *yours* |

(Write the full hashes, not shortened, in the real report.)

✍️ **Item 14: why do hashes differ?**
> One file has one extra byte (`0x0A`). A cryptographic hash is calculated over every byte, so even a single byte difference produces a completely different hash (the avalanche effect). The files look the same on screen, but they are not the same evidence.

✍️ **Item 15:** To hash only the visible characters: use **`echo -n`** (or `printf "text"`) which does not add a newline.

---

## 6. Task E – Endianness

### 6A. Check your system byte order
```bash
clear
python3 - <<'PY'
import sys
print('System byte order:', sys.byteorder)
PY
```
Expected on a normal PC/VM: `System byte order: little`

### 6B. Same bytes, two interpretations
```bash
python3 - <<'PY'
raw = bytes.fromhex('78563412')
print('Raw bytes:', raw.hex())
print('Interpreted as little-endian:', int.from_bytes(raw, 'little'))
print('Interpreted as big-endian :', int.from_bytes(raw, 'big'))
PY
```
Expected:
```
Raw bytes: 78563412
Interpreted as little-endian: 305419896
Interpreted as big-endian : 2018915346
```

### 6C. Student worksheet: run all four values at once
```bash
clear
python3 - <<'PY'
for h in ['01000000', 'FF000000', '00000100', '78563412']:
    raw = bytes.fromhex(h)
    print(h, 'little =', int.from_bytes(raw, 'little'), '| big =', int.from_bytes(raw, 'big'))
PY
```
Expected:
```
01000000 little = 1 | big = 16777216
FF000000 little = 255 | big = 4278190080
00000100 little = 65536 | big = 256
78563412 little = 305419896 | big = 2018915346
```

📸 **Screenshot 8** – 6A + 6B + 6C (all outputs visible).

✍️ Fill in the table (Section 6.3):

| Raw Hex | Little-Endian | Big-Endian | Command Used | Explanation |
|---|---|---|---|---|
| 01000000 | 1 | 16777216 | `int.from_bytes(raw,'little'/'big')` | Little: first byte is the lowest-value byte, so `01` is 1. Big: first byte is the most significant, so `01` sits in the top position (0x01000000). |
| FF000000 | 255 | 4278190080 | same | Little: only the lowest byte is `FF` = 255. Big: `FF` is the top byte (0xFF000000). |
| 00000100 | 65536 | 256 | same | Little: byte 3 holds `01`, which is 0x00010000 = 65536. Big: the `01` is in byte 3 of 4 from the top, which gives 0x00000100 = 256. |
| 78563412 | 305419896 | 2018915346 | same | Little: reads as 0x12345678. Big: reads as 0x78563412. |

✍️ **Forensic explanation requirement (write in your own words):** Point to cover:
> Endianness is the order in which a number's bytes are stored. In little-endian the least significant byte comes first; in big-endian the most significant comes first. The same four bytes, e.g. `78 56 34 12`, are 305,419,896 in little-endian and 2,018,915,346 in big-endian. In forensics, many structures (disk metadata, file system fields such as sizes, offsets, timestamps, and memory dumps on Intel x86 systems) store numbers in little-endian, while network protocols use big-endian. If the examiner reads bytes with the wrong order, sizes, offsets and timestamps are wrong, which can lead to wrong conclusions.

---

## 7. Task F – Mini forensic case

```bash
clear
# EVID-001: hex -> text
echo "48656c6c6f204943444641" | xxd -r -p; echo

# EVID-002: binary -> text
python3 -c "print(bytes(int(b,2) for b in '01001000 01101001'.split()).decode())"

# EVID-003: Unix timestamp
date -u -d @1675008832

# EVID-004: Mac Absolute Time
python3 -c "from datetime import datetime,timezone; print(datetime.fromtimestamp(725846400+978307200, tz=timezone.utc))"

# EVID-005: endianness
python3 -c "r=bytes.fromhex('78563412'); print(int.from_bytes(r,'little'), int.from_bytes(r,'big'))"
```
Expected:
```
Hello ICDFA
Hi
Sun Jan 29 16:13:52 UTC 2023
2024-01-02 00:00:00+00:00
305419896 2018915346
```
📸 **Screenshot 9** – all five commands and their outputs on screen.

✍️ Fill the table:

| Item | Value | Interpretation | Command |
|---|---|---|---|
| EVID-001 | 48656c6c6f204943444641 | ASCII text: **"Hello ICDFA"** (`20` is a space) | `xxd -r -p` |
| EVID-002 | 01001000 01101001 | Binary → bytes 0x48 0x69 → ASCII **"Hi"** | Python |
| EVID-003 | 1675008832 | Unix time = **2023-01-29 16:13:52 UTC** | `date -u -d @…` |
| EVID-004 | 725846400 (Mac) | Mac time + 978307200 = **2024-01-02 00:00:00 UTC** | Python |
| EVID-005 | 78563412 | Little-endian: **305419896** (0x12345678); big-endian: **2018915346** (0x78563412) | Python |

### 7.1 Case narrative (write 1–2 paragraphs, in your own words)
Cover these four points from the lab sheet:
1. What each item represents (the table above).
2. For timestamps: UTC result **and** the method used.
3. For byte-order: both interpretations and why they differ (same bytes, different reading order).
4. **Timeline vs content:** EVID-003 and EVID-004 are useful for **timeline analysis** (when something happened). EVID-001 and EVID-002 are useful for **text/content interpretation** (what it says). EVID-005 helps interpret binary fields such as sizes/offsets.

---

## 8. Build the PDF report

Order required by the lab (Section 8.1):

1. **Cover page**: course code (CIP-B101), lab title, full name, student ID, date, platform used (e.g. "Kali Linux 2025 in VirtualBox").
2. Conversion worksheet (Task A table + hand-written working).
3. Screenshots of shell/Python validation (Screenshots 1–2).
4. ASCII/hex conversion evidence + explanation (Screenshots 3–4, items 6–10 + forensic explanation).
5. Timestamp table with UTC clearly stated (Screenshots 5–6).
6. Hash comparison table (Screenshot 7).
7. Endianness worksheet + explanation (Screenshot 8).
8. Mini case narrative (Screenshot 9).
9. **Reflection**: one paragraph on why number systems and timestamps matter in digital forensics.

Example reflection (rewrite in your own words):
> Digital evidence is stored as bytes, and examiners see it as hex, binary or decimal depending on the tool. Without understanding number systems, an examiner can misread a file header, offset or hash. Timestamps build the timeline of an incident, and a wrong epoch, timezone or byte order can place an action at the wrong time and weaken the reliability of findings in court.

### Final screenshot checklist (Section 8.2)

| # | Screenshot | Where in this guide | Done |
|---|---|---|---|
| 1 | Folder creation + `pwd` | Step 1 | ☐ |
| 2 | Binary/hex/decimal commands | Step 2B | ☐ |
| 3 | `xxd` output for text evidence | Step 3A / 3D | ☐ |
| 4 | Hex-to-ASCII output | Step 3B / 3C | ☐ |
| 5 | Unix timestamp conversion | Step 4A / 4B | ☐ |
| 6 | Mac Absolute Time conversion | Step 4C | ☐ |
| 7 | `md5sum` + `sha256sum` comparison | Step 5A / 5B | ☐ |
| 8 | Endianness Python output | Step 6 | ☐ |
| 9 | Mini-case commands | Step 7 | ☐ |

Before exporting, check:
- [ ] Your name/ID is visible in each screenshot (folder name in the prompt, or file names containing your name)
- [ ] Every table cell is filled in
- [ ] Every timestamp states UTC or local
- [ ] Hand-calculated working is shown for Task A (the marks are for the method, not only the answer)
- [ ] File is named `CIP-B101_Lab1A_FirstName_LastName.pdf`
- [ ] Everything is in **your own words** and from **your own** terminal

---

## Common problems

| Problem | Fix |
|---|---|
| `xxd: command not found` | `sudo apt install -y xxd` (or `vim-common`) |
| `bc: command not found` | `sudo apt install -y bc` |
| `date: invalid date` on macOS | The `-d @` option is GNU/Linux only. Use a Linux VM or WSL. |
| `printf "%X"` prints on the wrong line | Add `\n`: `printf "%X\n" 2738` |
| Syntax error on `printf "%X\n" 2738` | You are probably at a Python (`>>>`) or unfinished (`>`) prompt, or pasted curly quotes. Type `exit()` or press Ctrl+C, retype the quotes by hand, or use `echo "obase=16;2738" \| bc` instead. |
| Hashes don't match the ones in this guide for "Hello" | You probably used `echo` where `-n` was needed (or the reverse). Check with `xxd`. |
| Heredoc (`<<'PY'`) doesn't finish | Make sure the closing `PY` is alone on its line, no spaces before it. |
