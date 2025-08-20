   ~ gpg --export 349BC7808577C592 | sudo pacman-key --add -
==> Updating trust database...
gpg: next trustdb check due at 2025-10-10
   ~ sudo pacman-key --lsign-key 349BC7808577C592
  -> Locally signed 1 key.
==> Updating trust database...
gpg: Note: third-party key signatures using the SHA1 algorithm are rejected
gpg: (use option "--allow-weak-key-signatures" to override)
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   1  signed:   6  trust: 0-, 0q, 0n, 0m, 0f, 1u
gpg: depth: 1  valid:   6  signed: 102  trust: 1-, 0q, 0n, 5m, 0f, 0u
gpg: depth: 2  valid:  75  signed:  19  trust: 75-, 0q, 0n, 0m, 0f, 0u
gpg: next trustdb check due at 2025-10-10
   ~ sudo pacman -S chaotic-keyring chaotic-mirrorlist
resolving dependencies...
looking for conflicting packages...

Packages (2) chaotic-keyring-20250614-1  chaotic-mirrorlist-20240724-3

Total Installed Size:  0.02 MiB

:: Proceed with installation? [Y/n] y
(2/2) checking keys in keyring                                        [--------------------------------------] 100%
downloading required keys...
:: Import PGP key 3A40CB5E7E5CBC30, "Garuda Builder <team@garudalinux.org>"? [Y/n] y
error: key "3A40CB5E7E5CBC30" could not be looked up remotely
error: required key missing from keyring
error: failed to commit transaction (unexpected error)
Errors occurred, no packages were upgraded.
   ~ gpg --keyserver hkps://keyserver.ubuntu.com --recv-key 3A40CB5E7E5CBC30
gpg: key 3056513887B78AEB: public key "Pedro Henrique Lara Campos <root@pedrohlc.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
   ~ sudo pacman -S chaotic-keyring chaotic-mirrorlist
resolving dependencies...
looking for conflicting packages...

Packages (2) chaotic-keyring-20250614-1  chaotic-mirrorlist-20240724-3

Total Installed Size:  0.02 MiB

:: Proceed with installation? [Y/n] y
(2/2) checking keys in keyring                                        [--------------------------------------] 100%
downloading required keys...
:: Import PGP key 3A40CB5E7E5CBC30, "Garuda Builder <team@garudalinux.org>"? [Y/n] y
(2/2) checking package integrity                                      [--------------------------------------] 100%
error: chaotic-keyring: signature from "Pedro Henrique Lara Campos <root@pedrohlc.com>" is unknown trust
:: File /var/cache/pacman/pkg/chaotic-keyring-20250614-1-any.pkg.tar.zst is corrupted (invalid or corrupted package (PGP signature)).
Do you want to delete it? [Y/n] y
error: failed to commit transaction (invalid or corrupted package)
Errors occurred, no packages were upgraded.
