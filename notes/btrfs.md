# Arch Linux Btrfs Install (Minimal) + systemd-boot

## Assumptions

* /dev/sda1 = EFI (already exists, systemd-boot installed)
* /dev/sda2 = Rescue OS (ext4, used for recovery)
* /dev/sda3 = main Arch system (Btrfs)

---

# 1. Format sda3 (destroys data)
```
wipefs -a /dev/sda3
mkfs.btrfs /dev/sda3
```

---

# 2. Create minimal layout (clean separation)
```
mount /dev/sda3 /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@snapshots

umount /mnt
```
---

# 3. Mount root + snapshots
```
mount -o subvol=@,compress=zstd,noatime /dev/sda3 /mnt

mkdir /mnt/.snapshots
mount -o subvol=@snapshots /dev/sda3 /mnt/.snapshots
```
---

# 4. Install base system
```
pacstrap /mnt base linux linux-firmware networkmanager btrfs-progs
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```
---

# 5. Basic configuration
```
ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
hwclock --systohc

echo "arch" > /etc/hostname
systemctl enable NetworkManager
```
---

# 6. systemd-boot (reuse existing EFI)

```
bootctl install
```

## /boot/loader/loader.conf
```
default arch.conf
timeout 3
editor no
```
## /boot/loader/entries/arch.conf
```
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=/dev/sda3 rw rootflags=subvol=@
```
---

# 7. Create initial snapshot (baseline)

```
btrfs subvolume snapshot -r / /.snapshots/clean
```

---

# 8. Finish
```
exit
umount -R /mnt
reboot
```
---

# RESULT

Structure:
```
Btrfs filesystem
├── @             → mounted as /
└── @snapshots    → mounted as /.snapshots
```

Boot options:

* Arch Linux → main system
* Rescue OS → recovery environment

---

# DAILY SNAPSHOT (manual)

Create snapshot when needed:

btrfs subvolume snapshot -r / /.snapshots/clean

If it already exists:

btrfs subvolume delete /.snapshots/clean
btrfs subvolume snapshot -r / /.snapshots/clean

Or use another name:

btrfs subvolume snapshot -r / /.snapshots/before-upgrade

---

# RECOVERY (from rescue OS)

1. Boot into rescue OS

2. Mount filesystem (top-level, not subvol):

mount /dev/sda3 /mnt

3. Restore snapshot safely:
```
btrfs subvolume delete /mnt/@
btrfs subvolume snapshot /mnt/@snapshots/clean /mnt/@
```
4. Reboot

(After confirming system works, you may delete old root)

btrfs subvolume delete /mnt/@broken

---

# NOTES

* Two subvolumes only: @ and @snapshots
* Snapshots stored outside root → no recursion
* No automation, no extra tools
* Rescue OS required for safe restore
* Snapshots consume space → delete old ones if needed:

btrfs subvolume delete /.snapshots/<name>

---

# OPTIONAL (recommended)

Run periodic scrub to detect corruption:

btrfs scrub start -Bd /

---

# MENTAL MODEL

* / → your live system (@)
* /.snapshots/* → restore points (@snapshots)
* Rescue OS → swap snapshot → restore system
