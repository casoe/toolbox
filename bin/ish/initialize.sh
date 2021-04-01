apk update 
apk upgrade
apk add curl git nano openssh

git config --global user.name "Carsten Söhrens"
git config --global user.email "soehrens@gmail.com"
git config --global core.editor "nano"

git clone https://github.com/casoe/toolbox ~/toolbox
rm -rf ~/bin
ln -s  ~/toolbox/bin/ish ~/bin
cp ~/toolbox/alias/profile-ish ~/.profile
source ~/.profile
