# archlinux test dockerfile

FROM base/centos
LABEL maintainer strivetobelazy@gmail.com

# updating and installing base packages
RUN pacman -Syu
RUN pacman -S --noconfirm base-devel

# installing essential developer tools
RUN pacman -S --noconfirm gcc-fortran
RUN pacman -S --noconfirm go
RUN pacman -S --noconfirm openmpi
RUN pacman -S --noconfirm lapack
RUN pacman -S --noconfirm gdb

# Editor and other stuff
RUN pacman -S --noconfirm vim
ADD bashrc /root/.bashrc
ADD inputrc /root/.inputrc

# going home
WORKDIR /root
