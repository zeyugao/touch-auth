<p align="center">
  <img src="./images/t2s-2.png" alt="touch-auth prompt">
</p>

# touch-auth

<p align="center">
  <img src="./images/t2s-1.png" alt="touch-auth in use">
</p>

`touch-auth` is a small macOS authentication helper for `SSH_ASKPASS`-style flows. It exits with status `0` after a successful local authentication and non-zero otherwise.

The tool is mainly useful for gating remote `sudo` flows through `ssh-agent`, but it can also be used anywhere a simple askpass helper is enough.

When biometrics are available, `touch-auth` uses a biometrics-only prompt. If the machine has no biometric device available, it falls back to regular device-owner authentication.

## Requirements

* macOS
* Touch ID if you want biometric prompts
* Xcode Command Line Tools if you build from source

If you have not set up Touch ID yet, Apple documents it here:
https://support.apple.com/en-us/HT212225

## Install with Homebrew

```sh
brew tap zeyugao/touch-auth
brew install touch-auth
brew services start touch-auth
```

`brew services start touch-auth` loads the included LaunchAgent, which exports `SSH_ASKPASS` for GUI sessions.

## Build from source

```sh
git clone https://github.com/zeyugao/touch-auth.git
cd touch-auth
make universal_app
```

This produces a universal `touch-auth` binary at the repository root.

If you want to install it manually:

```sh
install -m 0755 touch-auth /usr/local/bin/touch-auth
cp touch-auth.plist ~/Library/LaunchAgents/com.github.theseal.touch-auth.plist
launchctl bootstrap "gui/$(id -u)" ~/Library/LaunchAgents/com.github.theseal.touch-auth.plist
launchctl enable "gui/$(id -u)/com.github.theseal.touch-auth"
launchctl kickstart -k "gui/$(id -u)/com.github.theseal.touch-auth"
```

## Using it with ssh-agent

Generate a dedicated SSH key for privileged sudo use:

```sh
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa_sudo
```

Start an agent that uses `touch-auth` as the confirmation program:

```sh
export SSH_ASKPASS=/usr/local/bin/touch-auth
export DISPLAY=touch-auth
eval "$(ssh-agent)"
ssh-add -c ~/.ssh/id_rsa_sudo
```

The `-c` flag tells `ssh-agent` to require confirmation for each use of the key. That confirmation is where `touch-auth` is invoked.

To use this for remote `sudo`, the server side still needs `pam-ssh-agent-auth` or an equivalent PAM setup that trusts the forwarded agent.

## Security Notes

* Use a dedicated key and, ideally, a dedicated `ssh-agent` for privileged sudo access.
* Avoid forwarding a general-purpose agent that also holds unrelated keys.
* Use `ForwardAgent` selectively and only for hosts where you intend to use this workflow.

For the original end-to-end background and setup ideas, see:
https://medium.com/@prbinu/touch2sudo-enable-remote-sudo-two-factor-authentication-using-mac-touch-id-df638b7da594

## Releases

This repository publishes releases from GitHub Actions:

* `Release` is a manually triggered workflow that can either take an explicit `x.y.z` version or auto-bump `major`, `minor`, or `patch`.
* `Update Homebrew Tap` runs after each published GitHub release, recalculates the archive checksum, and updates `zeyugao/homebrew-touch-auth`.

To allow the tap-update workflow to push into the Homebrew repo, add a repository secret named `HOMEBREW_TAP_TOKEN` with `contents:write` access to `zeyugao/homebrew-touch-auth`.
