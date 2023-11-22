# Setting Up the Folder Structure

1. Clone the repository into `/etc/nixos/`.
2. Set permissions for all files and folders to `root:root`.
3. Set permissions for `.git` to `root:users` using the command: 
```bash
sudo chown -R root:users .git
```
4. Add write permissions for the group using the command:
```bash
sudo chmod -R g+rw .git
```
5. Now, you should only be able to commit and push as a user but not write arbitrary data (without trying to change data in the .git folder).