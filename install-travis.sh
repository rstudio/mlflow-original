#!/usr/bin/env bash

set -e
set -x

sudo mkdir -p /travis-install
sudo chown travis /travis-install

# (The conda installation steps below are taken from http://conda.pydata.org/docs/travis.html)
# We do this conditionally because it saves us some downloading if the
# version is the same.
if [[ "$TRAVIS_PYTHON_VERSION" == "2.7" ]]; then
  wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh -O /travis-install/miniconda.sh;
else
  wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /travis-install/miniconda.sh;
fi

bash /travis-install/miniconda.sh -b -p $HOME/miniconda
export PATH="$HOME/miniconda/bin:$PATH"
hash -r
conda config --set always_yes yes --set changeps1 no

# Useful for debugging any issues with conda
conda info -a
conda create -q -n test-environment python=$TRAVIS_PYTHON_VERSION
source activate test-environment
python --version
pip install --upgrade pip
pip install -r dev-requirements.txt -q
if [[ "$MLFLOW_TEST_REQUIREMENTS" != "false" ]]; then
  pip install -r test-requirements.txt -q;
fi
pip install .
export MLFLOW_HOME=$(pwd)

# Remove boto config present in Travis VMs (https://github.com/travis-ci/travis-ci/issues/7940)
sudo rm -f /etc/boto.cfg

# Install protoc
wget https://github.com/google/protobuf/releases/download/v3.6.0/protoc-3.6.0-linux-x86_64.zip -O /travis-install/protoc.zip
sudo unzip /travis-install/protoc.zip -d /usr
