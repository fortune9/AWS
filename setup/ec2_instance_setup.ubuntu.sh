#!/bin/bash
## stored at s3://zymo-filesystem/home/zzhang/setup/aws/ubuntu/aws_ec2_instance_setup.txt
## Also at https://github.com/fortune9/AWS/setup/ec2_instance_setup.ubuntu.sh
## The steps to install required software my EC2 instance
## instance request id: sir-b2284n4j
## login: ssh -Y  -l ubuntu 10.1.28.43

mountPoint=$HOME/tools/extra
sudo mkfs -t ext4 /dev/xvdb
mkdir -p $mountPoint
sudo mount /dev/xvdb $mountPoint
sudo chown ubuntu: $mountPoint
cd $mountPoint
mkdir tmp-work && cd tmp-work
mkdir software
mkdir github
cd github
git clone https://github.com/fortune9/NGS.git
cd ..
git config --global user.name 'Zhenguo Zhang'
git config --global user.email 'zhangz.sci@gmail.com'
git config --global credential.https://github.com.username fortune9

## update packages
sudo apt-get update
sudo apt upgrade -y
sudo apt install -y libxt-dev libxrender1 unzip libfontconfig1-dev \
        dos2unix libcurl4-openssl-dev libssl-dev git parallel vim

## install latest R, following https://cloud.r-project.org/bin/linux/ubuntu/
## to install multiple versions of R, see https://docs.rstudio.com/resources/install-r/
sudo apt install -y --no-install-recommends software-properties-common dirmngr
### sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
sudo apt install -y --no-install-recommends r-base r-base-dev
# sudo add-apt-repository ppa:c2d4u.team/c2d4u4.0+ # add the repository to allow installing CRAN packages using apt install r-cran-package
mkdir -p $mountPoint/tmp-work/bin
ln -s /usr/bin/R $mountPoint/tmp-work/bin/
ln -s /usr/bin/Rscript $mountPoint/tmp-work/bin/
echo "export PATH=$mountPoint/tmp-work/bin:\$PATH" >>$HOME/.bashrc

## install bioinfo packages
anaFile=Anaconda3-2020.02-Linux-x86_64.sh
wget https://repo.anaconda.com/archive/$anaFile
chmod u+x ./$anaFile
./$anaFile # follow instruction to finish installation
### restart a window
conda install -y -c bioconda bedtools samtools bowtie2 bwa MethylDackel
#conda install -y r-base
pip install awscli && aws configure

sudo apt install -y sra-toolkit
#wget http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.9.6-1/sratoolkit.2.9.6-1-ubuntu64.tar.gz
#tar -xzf sratoolkit.2.9.6-1-ubuntu64.tar.gz
#mv sratoolkit.2.9.6-1-ubuntu64 software/sratoolkit
#export PATH=$HOME/tools/extra/tmp-work/software/sratoolkit/bin:$PATH
export PATH=$HOME/tools/extra/tmp-work/github/NGS/programs:$PATH
wget https://download.asperasoft.com/download/sw/connect/3.9.1/ibm-aspera-connect-3.9.1.171801-linux-g2.12-64.tar.gz
tar -xzf ibm-aspera-connect-3.9.1.171801-linux-g2.12-64.tar.gz && ./ibm-aspera-connect-3.9.1.171801-linux-g2.12-64.sh
export PATH=$HOME/.aspera/connect/bin:$PATH

sraConfigFile=$HOME/.ncbi/user-settings.mkfg
sed -e 's!\(/repository/user/default-path\)\s*=.*!\1="/home/ubuntu/tools/extra/tmp-work/ncbi"!' $sraConfigFile >tmp1.$$
echo '/repository/user/main/public/root = "/home/ubuntu/tools/extra/tmp-work/ncbi"' >>tmp1.$$
mv tmp1.$$  $sraConfigFile
#vdb-config --set /repository/user/default-path=/alternative/dir/ncbi
#vdb-config --set /repository/user/main/public/root=/alternative/dir/ncbi/public

## install dx-toolkit
wget https://dnanexus-sdk.s3.amazonaws.com/dx-toolkit-v0.290.1-ubuntu-16.04-amd64.tar.gz
tar -xzf dx-toolkit-v0.290.1-ubuntu-16.04-amd64.tar.gz
conda create -n py27 python=2.7


## update configuration files
cd
git clone https://github.com/fortune9/config.git
cd config/dot-files && \
    cp -a .dircolors .Rprofile .vimrc .gitconfig ~/ && cd
#for i in .dircolors .Rprofile .vimrc;
#do
#        aws s3 cp s3://zymo-filesystem/home/zzhang/setup/Linux/config/$i .
#done
#ln .dir_colors .dircolors  # ubuntu use the latter name

## Add vim plugins
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
### Add code like below to add more vim plugins
### Plug 'jalvesaq/Nvim-R', {'branch': 'stable'}
### then reopen vim, and run :PlugInstall to install plugins.
### See https://github.com/junegunn/vim-plug for more ideas

## download UCSC tools
mkdir -p $HOME/work/bin/
cd $HOME/work/bin/
ucscDir=http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64
for exe in twoBitToFa faToTwoBit
do
        wget $ucscDir/$exe && chmod u+x $exe
done

# also install R packages
R -e \
        "install.packages(c('R.utils', 'data.table', 'parallel','optparse'), repos='https://cloud.r-project.org')"
R -e \
        "install.packages(c('rmarkdown','kableExtra','ggplot2'), repos='https://cloud.r-project.org')"
