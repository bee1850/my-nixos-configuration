#! /usr/bin/env nix-shell
#! nix-shell -i bash

sudo mkdir -p /root/.config/nvim/
sudo ln -s /home/berkan/.config/nvim/init.lua  /root/.config/nvim/init.lua

sudo mkdir -p /root/.ssh/
# sudo ln -s /home/berkan/.ssh/id_ed25519.pub /root/.ssh/id_ed25519.pub
# sudo ln -s /home/berkan/.ssh/id_ed25519 /root/.ssh/id_ed25519
