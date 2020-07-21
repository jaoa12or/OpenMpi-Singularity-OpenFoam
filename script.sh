#!/usr/bin/env bash

# install prerequisites
sudo yum update -y
sudo yum groupinstall -y 'Development Tools' 
sudo yum install -y openssl-devel libuuid-devel \
    libseccomp-devel wget squashfs-tools cryptsetup
# install go
sudo curl https://dl.google.com/go/go1.14.4.linux-amd64.tar.gz -o go1.14.4.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.14.4.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/vagrant/.bashrc
export PATH=$PATH:/usr/local/go/bin
# install singularity
sudo wget https://github.com/sylabs/singularity/releases/download/v3.5.2/singularity-3.5.2.tar.gz
sudo tar -xzf singularity-3.5.2.tar.gz
cd singularity
./mconfig
make -C ./builddir
sudo make -C ./builddir install
export PATH=$PATH:/usr/local/bin
cd /home/vagrant
# pull singularity image
singularity pull library://fertinaz-hpc/openfoam/of-7.sif:sha256.87a06205d8f66a4d3c2391e1a8eed8358e85de63588682e398fa81eded65d417
# changing image name
mv of-7.sif_sha256.87a06205d8f66a4d3c2391e1a8eed8358e85de63588682e398fa81eded65d417.sif of-7.sif
# install openmpi
sudo wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.4.tar.gz
sudo tar xf openmpi-4.0.4.tar.gz && rm -f openmpi-4.0.4.tar.gz
cd openmpi-4.0.4
./configure --prefix=/opt/openmpi-4.0.4
sudo make all install
# export openmpi variables
echo 'export MPI_DIR=/opt/openmpi-4.0.4' >> /home/vagrant/.bashrc
export MPI_DIR=/opt/openmpi-4.0.4
echo 'export MPI_BIN=$MPI_DIR/bin' >> /home/vagrant/.bashrc
export MPI_BIN=$MPI_DIR/bin
echo 'export MPI_LIB=$MPI_DIR/lib' >> /home/vagrant/.bashrc
export MPI_LIB=$MPI_DIR/lib
echo 'export MPI_INC=$MPI_DIR/include' >> /home/vagrant/.bashrc
export MPI_INC=$MPI_DIR/include
echo 'export PATH=$MPI_BIN:$PATH' >> /home/vagrant/.bashrc
export PATH=$MPI_BIN:$PATH
echo 'export LD_LIBRARY_PATH=$MPI_LIB:$LD_LIBRARY_PATH' >> /home/vagrant/.bashrc
export LD_LIBRARY_PATH=$MPI_LIB:$LD_LIBRARY_PATH
# clean
sudo rm -rf /home/vagrant/go1.14.4.linux-amd64.tar.gz
sudo rm -rf /home/vagrant/singularity-3.5.2.tar.gz
