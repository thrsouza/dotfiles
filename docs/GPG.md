# GPG Key Configuration

This guide covers the setup and management of GPG (GNU Privacy Guard) keys for secure communication and code signing.

## Initial Setup

### 1. Generate a New GPG Key

Create a new GPG key with RSA 4096-bit encryption (recommended for maximum security):

```sh
gpg --default-new-key-algo rsa4096 --gen-key
```

**What this does:**
- Creates a new GPG key pair (public and private keys)
- Uses RSA algorithm with 4096-bit key length for enhanced security
- Prompts for user information (name, email, passphrase)
- Generates both encryption and signing capabilities

### 2. List Your GPG Keys

View all your GPG keys with detailed information:

```sh
gpg --list-secret-keys --keyid-format=long
```

**Output explanation:**
- Shows key ID, creation date, and expiration
- Displays user information (name and email)
- Indicates key capabilities (encryption, signing, authentication)

### 3. Export Your Public Key

Export your public key for sharing with others or adding to services like GitHub:

```sh
gpg --armor --export 0000000000000000
```

**Usage:**
- Replace `0000000000000000` with your actual key ID
- The `--armor` flag outputs the key in ASCII format (easier to copy/paste)
- Use this output to add your public key to GitHub, GitLab, or other services

## Additional Useful Commands

### View All Keys (Public and Private)
```sh
gpg --list-keys
```

### Delete a Key
```sh
gpg --delete-secret-key KEY_ID
gpg --delete-key KEY_ID
```

### Edit Key Properties
```sh
gpg --edit-key KEY_ID
```

### Set Key Expiration
```sh
gpg --edit-key KEY_ID
> expire
> 2y  # Set to expire in 2 years
> save
```

### Export Private Key (Backup)
```sh
gpg --armor --export-secret-key KEY_ID > private_key.asc
```

## Git Integration

### Configure Git to Use GPG Signing
```sh
git config --global user.signingkey 0000000000000000
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

### Sign Commits Manually
```sh
git commit -S -m "Your commit message"
```

## Best Practices

1. **Key Security:**
   - Use a strong passphrase for your private key
   - Keep your private key secure and never share it
   - Regularly backup your private key

2. **Key Management:**
   - Use descriptive names and emails for your keys
   - Set appropriate expiration dates
   - Rotate keys periodically

3. **Backup Strategy:**
   - Export and securely store your private key
   - Keep multiple backups in different secure locations
   - Document your key recovery process

## Troubleshooting

### Common Issues

**"gpg: signing failed: Inappropriate ioctl for device"**
```sh
export GPG_TTY=$(tty)
```

**"gpg: no default secret key"**
- Ensure you've set the correct signing key in Git config
- Verify the key ID is correct

**"gpg: signing failed: Bad passphrase"**
- Check that you're using the correct passphrase
- Ensure your GPG agent is running properly

## GPG Agent Configuration

Add to your shell configuration (`.zshrc` or `.bashrc`):
```sh
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null
```

This ensures GPG agent works properly in terminal sessions and can prompt for passphrases when needed. 
