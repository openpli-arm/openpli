openpli
=======

openpli arm build howto(with Ubuntu 12.04 64bit)

1.Install needded packages:

  ~$ sudo apt-get install -y autoconf automake bison bzip2 cvs diffstat flex g++ gawk gcc gettext git-core gzip help2man ncurses-bin ncurses-dev libc6-dev libtool make texinfo patch perl pkg-config subversion tar texi2html wget zlib1g-dev chrpath libxml2-utils xsltproc libglib2.0-dev python-setuptools libc6-i386 genromfs guile-1.8-libs gparted zlib1g:i386

2.In terminal type:

  ~$ sudo dpkg-reconfigure dash
  
  answer no

3.In terminal type:

  ~$ ssh anoncvs@cvs.tuxbox.org 
  
  answer yes

4.Creat directory openpli by typing:
  ~$ mkdir openpli

5.Go to openpli directory:
  ~$ cd openpli

6.Download openpli arm Makefile
  ~$ wget https://raw.github.com/openpli-arm/openpli/master/Makefile

7.Now just type:
  ~$ make image
