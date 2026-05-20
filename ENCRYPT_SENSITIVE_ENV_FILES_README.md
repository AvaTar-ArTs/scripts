# Encryption of Sensitive Environment Files

This document provides instructions for encrypting sensitive environment zip files to enhance security.

## About

The script `encrypt_sensitive_env_files.sh` is designed to encrypt sensitive environment zip files using GPG (GNU Privacy Guard) with AES256 encryption. This adds an extra layer of security to protect API keys and other sensitive environment variables stored in zip files.

## Prerequisites

Before using the encryption script, ensure you have GPG installed:

On macOS:
```bash
brew install gnupg
```

On Ubuntu/Debian:
```bash
sudo apt-get install gnupg
```

## Usage

### Encrypt Files
Run the script to encrypt sensitive environment zip files:
```bash
/Users/steven/scripts/encrypt_sensitive_env_files.sh
```

The script will:
1. Identify the sensitive environment zip files
2. Ask for confirmation before proceeding
3. Encrypt each file using AES256 cipher
4. Create a .gpg file alongside the original

### Decrypt Files
To decrypt a file when needed:
```bash
gpg --output original_filename.zip --decrypt encrypted_filename.zip.gpg
```

You'll be prompted to enter the passphrase used during encryption.

## Files Protected

The script targets these specific files:
- `/Users/steven/.env.d.zip`
- `/Users/steven/.env 2.d.zip`

These files contain environment variables and API keys that should be protected.

## Security Best Practices

1. Use a strong passphrase when encrypting files
2. Store the passphrase securely, separate from the encrypted files
3. Consider removing the original unencrypted files after verifying the encrypted versions
4. Regularly review and update encryption keys as needed

## Automation

For regular encryption of backup files, you can add this to your crontab:
```
# Monthly encryption of environment backups (manual process due to passphrase requirement)
# This would need to be run manually or with a secure passphrase management system
```

Note: Automated decryption would require storing the passphrase, which reduces security. Manual decryption is recommended for sensitive environment files.