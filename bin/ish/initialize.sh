### Pakete nachinstallieren
apk update 
apk upgrade
apk add curl git nano openssh less

### git Konfiguration setzen
# Who am I
git config --global user.name "Carsten Söhrens"
git config --global user.email "soehrens@gmail.com"

# nano as the editor
git config --global core.editor "nano"

# colorful output
git config --global --add color.ui true
git config --global core.pager 'less -R'

# Enable helper to temporarily store passwords in memory
git config --global credential.helper cache

# tell git to automatically rebase when pulling
git config --global pull.rebase true

# Reuse Recorded Resolution
# allows to ask Git to remember how you’ve resolved a hunk conflict so that the next time it sees the same conflict, Git can resolve it for you automatically
git config --global rerere.enabled true

### toolbox holen und ins System einklinken
git clone https://github.com/casoe/toolbox ~/toolbox
rm -rf ~/bin
ln -s  ~/toolbox/bin/ish ~/bin
cp ~/toolbox/alias/profile-ish ~/.profile
source ~/.profile


