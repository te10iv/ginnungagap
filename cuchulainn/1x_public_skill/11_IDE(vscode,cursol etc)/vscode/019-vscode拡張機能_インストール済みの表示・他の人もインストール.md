
## インストール済みvscode拡張を確認するコマンド
code --list-extensions

▼結果
4ops.terraform
batisteo.vscode-django
bibhasdn.unique-lines
GitHub.copilot
GitHub.copilot-chat
hashicorp.terraform
hediet.vscode-drawio
mhutchie.git-graph
ms-azuretools.vscode-docker
MS-CEINTL.vscode-language-pack-ja
ms-python.black-formatter
ms-python.debugpy
ms-python.mypy-type-checker
ms-python.python
ms-python.vscode-pylance
ms-vscode-remote.remote-containers
ms-vscode-remote.remote-ssh
ms-vscode-remote.remote-ssh-edit
ms-vscode.remote-explorer
ms-vsliveshare.vsliveshare
mushan.vscode-paste-image
oderwat.indent-rainbow
PKief.material-icon-theme
shardulm94.trailing-spaces
usernamehw.errorlens
yzhang.markdown-all-in-one


## 他の人（後輩・部下など）のPCに同じ拡張機能をインストールする手順（Mac）

#元のPC
cd ~/Desktop
code --list-extensions > vscode-extensions.txt


#新PC
xargs -n 1 code --install-extension < vscode-extensions.txt




