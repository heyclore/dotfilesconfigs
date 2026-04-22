# Arch Linux Btrfs Install (sda3 only) + systemd-boot

Assumption:
- sda1 = EFI (already exists, systemd-boot installed)
- sda2 = Rescue OS (already installed, ext4)
- sda3 = target for main Arch system (Btrfs)

---

# 1. Format sda3 (WARNING: destroys data)

wipe filesystem signatures:

wipefs -a /dev/sda3

format as Btrfs:

mkfs.btrfs /dev/sda3

---

# 2. Mount and create subvolume layout

mount /dev/sda3 /mnt

create main root subvolume:

btrfs subvolume create /mnt/@

optional snapshot folder:

btrfs subvolume create /mnt/.snapshots

unmount:

umount /mnt

---

# 3. Mount root subvolume (@)

mount main system:

mount -o subvol=@ /dev/sda3 /mnt

create snapshot directory mount (optional but recommended structure):

mkdir -p /mnt/.snapshots

---

# 4. Install base system

pacstrap /mnt base linux linux-firmware vim networkmanager btrfs-progs

generate fstab:

genfstab -U /mnt >> /mnt/etc/fstab

---

# 5. Chroot into new system

arch-chroot /mnt

set timezone:

ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
hwclock --systohc

hostname:

echo "arch" > /etc/hostname

enable network:

systemctl enable NetworkManager

---

# 6. Install systemd-boot (use existing EFI sda1)

bootctl install

---

create loader config:

/boot/loader/loader.conf

default arch.conf
timeout 3
editor no

---

create boot entry:

/boot/loader/entries/arch.conf

title   Arch Linux (@)
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=/dev/sda3 rw rootflags=subvol=@

---

# 7. (Optional) create initial snapshot

after install:

btrfs subvolume snapshot -r / /.snapshots/clean

---

# 8. Exit and reboot

exit
umount -R /mnt
reboot

---

# RESULT

Boot options:
- Arch Linux (@ system) → daily system
- Rescue OS (sda2) → recovery tool

---

# RECOVERY RULE

If system breaks:

1. Boot Rescue OS
2. Mount sda3:
   mount -o subvol=@ /dev/sda3 /mnt
3. Restore snapshot if needed:

   btrfs subvolume delete /mnt/@
   btrfs subvolume snapshot /mnt/.snapshots/clean /mnt/@

4. reboot
