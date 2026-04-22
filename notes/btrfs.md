# Arch Linux Btrfs Install (Minimal) + systemd-boot

## Assumptions

- `/dev/sda1` = EFI partition (systemd-boot installed or reused)
- `/dev/sda2` = Rescue OS (ONLY used for recovery)
- `/dev/sda3` = Arch Linux system (Btrfs)

---

# 1. Format system partition (WARNING: destroys data)

```bash
wipefs -a /dev/sda3
mkfs.btrfs /dev/sda3
```

---

# 2. Create Btrfs subvolumes

```bash
mount /dev/sda3 /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots

umount /mnt
```

---

# 3. Mount system

```bash
mount -o subvol=@,compress=zstd,noatime /dev/sda3 /mnt

mkdir -p /mnt/home
mkdir -p /mnt/.snapshots

mount -o subvol=@home,compress=zstd,noatime /dev/sda3 /mnt/home
mount -o subvol=@snapshots /dev/sda3 /mnt/.snapshots
```

---

# 4. Install base system

```bash
pacstrap /mnt base linux linux-firmware networkmanager btrfs-progs
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```

---

# 5. Basic configuration

```bash
ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
hwclock --systohc

echo "arch" > /etc/hostname
systemctl enable NetworkManager
```

---

# 6. systemd-boot (EFI reuse)

```bash
bootctl install
```

## /boot/loader/loader.conf

```ini
default arch.conf
timeout 3
editor no
```

## /boot/loader/entries/arch.conf

```ini
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=/dev/sda3 rw rootflags=subvol=@
```

---

# 7. First snapshot (baseline)

```bash
btrfs subvolume snapshot -r / /.snapshots/base-clean
```

---

# 8. Finish installation

```bash
exit
umount -R /mnt
reboot
```

---

# FINAL SYSTEM STRUCTURE

```text
Btrfs filesystem
├── @              → root (/)
├── @home          → /home
└── @snapshots     → /.snapshots
```

---

# SNAPSHOT USAGE (manual only)

## Create snapshot before changes

```bash
btrfs subvolume snapshot -r / /.snapshots/before-upgrade
```

## Create baseline snapshot

```bash
btrfs subvolume snapshot -r / /.snapshots/base-clean
```

---

# RECOVERY (ONLY via Rescue OS)

## IMPORTANT RULE:
Recovery is ALWAYS done from `/dev/sda2` (Rescue OS), not from Arch.

---

## 1. Boot into Rescue OS

---

## 2. Mount Btrfs system

```bash
mount /dev/sda3 /mnt
```

---

## 3. List available snapshots (optional check)

```bash
btrfs subvolume list /mnt
```

---

## 4. Restore system snapshot

```bash
btrfs subvolume delete /mnt/@
btrfs subvolume snapshot /mnt/@snapshots/base-clean /mnt/@
```

OR restore another snapshot:

```bash
btrfs subvolume snapshot /mnt/@snapshots/before-upgrade /mnt/@
```

---

## 5. Cleanup (optional)

```bash
btrfs subvolume delete /mnt/@broken
```

---

## 6. Reboot into Arch

```bash
reboot
```

---

# NOTES

- Only `@` is restored during rollback
- `/home` (`@home`) is NEVER touched during recovery
- Snapshots are system-only restore points
- Rescue OS is the ONLY recovery environment

---

# OPTIONAL MAINTENANCE

```bash
btrfs scrub start -Bd /
```

---

# MENTAL MODEL

- `/` → active system (`@`)
- `/home` → persistent user data (`@home`)
- `/.snapshots` → system restore points
- `/dev/sda2` → recovery environment (Rescue OS only)
