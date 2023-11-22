# Setting up the folder structure
1. clone the repo into /etc/nixos/
2. set perms for all files and folders to root:root
3. set perms for .git to root:users 
```bash
sudo chown -R root:users .git
```
4. Add write permissions for the group
```bash
sudo chmod -R g+rw .git
```
5. Now you only should be able to commit and push as user but not write arbitrary data (without trying to change data in the .git folder)

