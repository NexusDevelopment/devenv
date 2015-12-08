FROM phusion/baseimage:0.9.17
MAINTAINER ryepdx

# Pre-reqs 
RUN apt-get -y -q update
RUN apt-get -y install language-pack-en-base
RUN dpkg-reconfigure locales
RUN apt-get -y install software-properties-common curl wget
RUN wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | apt-key add -
RUN add-apt-repository "deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.7 main"
RUN add-apt-repository -y ppa:ethereum/ethereum-qt
RUN add-apt-repository -y ppa:ethereum/ethereum
RUN add-apt-repository -y ppa:ethereum/ethereum-dev
RUN apt-add-repository -y ppa:george-edison55/cmake-3.x
RUN apt-get -y -q update
RUN apt-get -y -q upgrade

RUN apt-get install -y -q build-essential libgmp3-dev golang git cmake libboost-all-dev libgmp-dev libleveldb-dev libminiupnpc-dev libreadline-dev libncurses5-dev libcurl4-openssl-dev libcryptopp-dev libjson-rpc-cpp-dev libmicrohttpd-dev libjsoncpp-dev libargtable2-dev llvm-3.7-dev libedit-dev mesa-common-dev ocl-icd-libopencl1 opencl-headers libgoogle-perftools-dev qtbase5-dev qt5-default qtdeclarative5-dev libqt5webkit5-dev libqt5webengine5-dev ocl-icd-dev libv8-dev

# Solidity
RUN cd ~ && git clone https://github.com/ethereum/webthree-helpers && webthree-helpers/scripts/ethupdate.sh --no-push --simple-pull --project solidity && webthree-helpers/scripts/ethbuild.sh --no-git --cores 2 --project solidity

# Geth
RUN cd ~ && git clone https://github.com/ethereum/go-ethereum
ENV GOPATH /root/go
RUN mkdir -p ~/go; echo "export GOPATH=\$HOME/go" >> ~/.bashrc
RUN cd ~/go-ethereum && make geth

# Python
RUN apt-get -y -q update
RUN apt-get install -q -y git python python-pip
RUN pip completion --bash >> ~/.bashrc
RUN export WORKON_HOME=~/.virtualenvs && mkdir ~/.virtualenvs && echo "export WORKON_HOME=\$WORKON_HOME" >> ~/.bashrc && echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc && echo "export PIP_VIRTUALENV_BASE=\$WORKON_HOME" >> ~/.bashrc 
RUN pip install virtualenvwrapper
RUN /bin/bash -c 'source /usr/local/bin/virtualenvwrapper.sh && mkvirtualenv nexus && workon nexus && pip install mkdocs'
RUN apt-get -y -q install vim

RUN echo "workon nexus" >> $HOME/.bashrc

RUN cd ~ && git clone --recursive https://github.com/NexusDevelopment/devenv && cd devenv && git submodule init && git submodule update
RUN /bin/bash -c 'source /usr/local/bin/virtualenvwrapper.sh && cd ~/devenv/dapple && git pull origin master && cd ~/devenv/dapple/pydapple && workon nexus && python setup.py install'

RUN ln -s ~/solidity/build/solc/solc /bin/solc
RUN ln -s ~/go-ethereum/build/bin/geth /bin/geth

# IPFS
RUN echo "export PATH=\$GOPATH/bin:\$PATH:" >> ~/.bashrc && echo "export PATH=\$PATH:/usr/local/opt/go/libexec/bin" >> ~/.bashrc
RUN go get -u github.com/ipfs/go-ipfs/cmd/ipfs
ENV PATH $PATH:$GOPATH/bin
RUN ipfs init

# Node
ENV NODE_VERSION node-v5.1.1-linux-x64
RUN cd /bin && wget https://nodejs.org/dist/v5.1.1/$NODE_VERSION.tar.gz && tar xzf $NODE_VERSION.tar.gz && ln -s $NODE_VERSION/bin/npm npm && ln -s $NODE_VERSION/bin/node node && rm $NODE_VERSION.tar.gz && cd ~/devenv/dapple && sudo npm install
RUN echo "export PATH=\$PATH:/bin/$NODE_VERSION/bin" >> ~/.bashrc

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 4001 5001 8080

CMD ["ipfs", "daemon"]
