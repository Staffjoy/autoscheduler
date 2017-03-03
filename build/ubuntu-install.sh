#!/bin/sh
set -e

sudo apt-get update --yes --force-yes
# Sometimes ubuntuneeds these software-properties repos :-(
sudo apt-get install --yes --force-yes  build-essential libffi-dev libssl-dev cmake expect-dev
sudo apt-get update --yes --force-yes # Re-update
sudo add-apt-repository -y ppa:staticfloat/juliareleases
sudo add-apt-repository -y ppa:staticfloat/julia-deps
sudo apt-get update --yes --force-yes
sudo apt-get install julia0.3 --yes --force-yes
julia -v

# Install gurobi
# First remove remnants
rm -rf gurobi605
# Unzip. Sometimes it throws a hard link error - hence the "or" statement
tar xfz gurobi6.0.5_linux64.tar.gz || :

# Set up environment variables
cwd=`pwd`

# Gurobi home
gurobi_home="$cwd/gurobi605/linux64/"
echo "echo \"export GUROBI_HOME=$gurobi_home\" >> /etc/profile" | sudo bash

# Gurobi binary
echo "echo 'export PATH=\"${PATH}:${GUROBI_HOME}/bin\"' >> /etc/profile" | sudo bash

# Gurobi license
# If you want prod - just override environment variable!
echo "echo 'export GRB_LICENSE_FILE=$cwd/../licenses/default.lic' >> /etc/profile" | sudo bash

# Load dat shit
source /etc/profile

cd ..
bash dependencies.sh
