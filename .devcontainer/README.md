# Devcontainer GitHub SSH

Inside the devcontainer, generate a GitHub SSH key:

```sh
bash .devcontainer/github-ssh.sh --generate --email you@example.com
```

Copy the printed public key into GitHub:

GitHub Settings -> SSH and GPG keys -> New SSH key

Then test and use Git normally:

```sh
ssh -T git@github.com
git pull
git add .
git commit -m "your message"
git push
```

The devcontainer also installs Node/npm/Python, configures CMake, and runs:

```sh
npm ci --prefix editors/vscode
```

That prepares the VSCode extension dependency used to launch the YCPL LSP in the
Remote Container extension host.

The local YCPL VSCode extension is linked into the Remote Container extension
host by:

```sh
bash .devcontainer/install-vscode-extension.sh
```

After that, run **Developer: Reload Window** in VSCode. Open an `.ec` file and
check that the language mode in the bottom-right status bar says `YCPL`.

If `npm: command not found` appears, the running container was created before
Node/npm was added to the Dockerfile. In VSCode run:

```text
Dev Containers: Rebuild Container
```

After rebuild, confirm:

```sh
node --version
npm --version
npm ci --prefix editors/vscode
```

Temporary workaround inside an existing Ubuntu container:

```sh
sudo apt-get update
sudo apt-get install -y nodejs npm
npm ci --prefix editors/vscode
bash .devcontainer/install-vscode-extension.sh
```
