# Mantra packages

Automation and public metadata for installing [Mantra](https://github.com/Nabwinsaud/mantra).

This repository publishes:

- a signed APT repository at `https://nabwinsaud.github.io/mantra-packages/`
- the checksum-verifying installer at `https://nabwinsaud.github.io/mantra-packages/install.sh`
- shared release metadata consumed by future Arch/AUR automation

Once Pages has been deployed, the checksum-verifying direct installer is available with:

```sh
curl -fsSL https://nabwinsaud.github.io/mantra-packages/install.sh | sh
```

On macOS it installs through the Mantra Homebrew tap. On Debian and Ubuntu it downloads the
matching release package, verifies it against the release `SHA256SUMS`, and installs it with APT.

## One-time owner setup

The workflow is intentionally unable to sign anything until the repository owner supplies a
dedicated signing key.

1. Create a dedicated key on your own trusted machine. This first version uses an unprotected,
   repository-only key because the signer runs unattended inside an encrypted GitHub Actions
   secret:

   ```sh
   gpg --batch --quick-generate-key "Mantra APT Repository" ed25519 sign 2y
   gpg --list-secret-keys --keyid-format long "Mantra APT Repository"
   ```

2. Export the private key directly into the GitHub secret without printing it:

   ```sh
   gpg --armor --export-secret-keys "Mantra APT Repository" \
     | gh secret set APT_GPG_PRIVATE_KEY --repo Nabwinsaud/mantra-packages
   ```

3. In the repository settings, open **Pages → Build and deployment** and select **GitHub Actions**.

4. Run **Actions → Publish signed APT repository → Run workflow** once. Later runs happen hourly
   and always synchronize from Mantra's latest GitHub release.

The key must be used only for this repository. Do not reuse a personal signing or identity key.

## AUR owner setup

Arch publishing requires an account at <https://aur.archlinux.org> and a dedicated SSH key added to
that account. Once the account exists, the Mantra repository can store that private key as
`AUR_SSH_PRIVATE_KEY` and push the generated `PKGBUILD`/`.SRCINFO` after package validation.
