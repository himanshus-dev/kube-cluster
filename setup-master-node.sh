##################################################
# This scripts sets the machine as a master node #
# by installing all related software and setting #
# related settings on the host.                  #
##################################################
# NOTE: Requires sudo access to run.             #
##################################################

sudo su # Acquire superuser privilages

swapoff -a # turn off swap
sed -i 's/\/swapfile/\#\/swapfile/' /etc/fstab # comment swapfile line from fstab

echo "kmaster" > /etc/hostname # Updtae hostname

MY_IP = $(ip a show ens33 | grep inet\ | awk '{print $2}'| cut -f1 -d'/') # extract the eth ip
# add setting for static IP
echo "# Settings for static ip adress for adapter ens33" >> /etc/network/interfaces
echo "auto ens33" >> /etc/network/interfaces
echo "iface ens33 inet static" >> /etc/network/interfaces
echo "address ${MY_IP}" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces # a blank line at end

echo "${MY_IP} kmaster" >> /etc/hosts # add master to /etc/hosts

# Here goes the installation stuff
apt-get update && apt update && apt upgrade -y # Check for updates and update
apt-get install -y openssh-server # Install openssh server
apt-get install -y docker.io # Install docker container runtime
# Prepare for kubernetes installation
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
# Install kubernetes adm
apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# According to kubernetes official site - it should detect the cgroups-driver
# automatically. If it doesn't go that way. I have to add a way to set it.
