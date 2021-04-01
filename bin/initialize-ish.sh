apk update 
apk upgrade
apk add nano
apk add openssh
apk add git

cp ~/toolbox/alias/profile-ish ~/.profile
git config --global core.editor "nano"

   0 apk add curl openssh nano
   1 wget -qO- http://dl-cdn.alpinelinux.org/alpine/v3.12/main/x86/apk-tools-static-2.10.5-r1.apk | tar -xz sbin/apk.static && ./sbin/apk.static add apk-tools && rm sbin/apk.static
   2 cd /ish/apk/
   3 ls
   4 apk update
   5 apk upgrade
   6 apk add git
   7 apk add ssh
   8 apk
   9 apk search ssh
  10 apk add openssh
  11 git clone https://github.com/casoe/toolbox
  12 ll
  13 ls
  14 cd toolbox/
  15 ll
  16 ls
  17 cd bin/
  18 ls
  19 ce ..
  20 cd ..
  21 ln -s toolbox/bin/ bin
  22 ls
  23 ps x
  24 ssh pi@192.168.178.52
  25 git status
  26 cd toolbox/
  27 git pull
  28 git status
  29 cd toolbox/
  30 ll
  31 ls
  32 cd ..
  33 nano .profile
  34 apk add nano
  35 nano .profile
  36 l
  37 ll
  38 gs
  39 cd toolbox/
  40 gs
  41 git pull
  42 cd
  43 ll
  44 cd toolbox/
  45 mkdir alias
  46 uname -a
  47 uname
  48 cp ../.profile alias/profile_ish
  49 ll
  50 cd
  51 nano .profile 
  52 ssh-
  53 ssh-matthias
  54 ll
  55 mv id_rsa .ssh/
  56 ssh-matthias
  57 cd toolbox/
  58 ll
  59 gs
  60 cd ..
  61 ln -s .ssh ssh
  62 ll
  63 cd ssh/
  64 ll
  65 cat id_rsa 
  66 ll
  67 cd ..
  68 l
  69 rm ssh/
  70 mv id_rsa* .ssh/
  71 ll
  72 cd .ssh/
  73 ll
  74 cat known_hosts 
  75 ssh-matthias
  76 ll
  77 apk update
  78 apk upgrade
  79 ssh-matthias
  80 cd toolbox/
  81 gs
  82 git add -A
  83 gs
  84 git commit
  85 git config --global user.name "Carsten Söhrens"
  86 git config --global user.email "casoe@gmx.de"
  87 git commit
  88 gl
  89 git push
  90 git pull
  91 ll
  92 cd bin 
  93 nano initialize-ish.sh
  94 his
  95 history
  96 history >> initialize-ish.sh 
