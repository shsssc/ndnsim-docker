FROM ubuntu:20.04

RUN export DEBIAN_FRONTEND=noninteractive &&\
	apt-get update && apt-get install -y xterm sudo xfce4 desktop-base xfce4-terminal build-essential libsqlite3-dev libboost-all-dev\
	libssl-dev git python-setuptools castxml git gir1.2-goocanvas-2.0 gir1.2-gtk-3.0 nano leafpad \
	libgirepository1.0-dev python3-dev python3-gi python3-gi-cairo python3-pip python3-pygraphviz python3-pygccxml && \
	apt-get clean

RUN pip3 install kiwi

# Replace 1000 with your user / group id to forward X in Linux. Will not work on Mac or Windows

RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    mkdir -p /etc/sudoers.d/ && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers &&\
	echo "developer:!:18382:0:99999:7:::" >> /etc/shadow &&\
    chown ${uid}:${gid} -R /home/developer

RUN cd /home/developer &&\
	mkdir ndnSIM &&\
	cd ndnSIM &&\
	git clone https://github.com/named-data-ndnSIM/ns-3-dev.git ns-3 &&\
	git clone https://github.com/named-data-ndnSIM/pybindgen.git pybindgen &&\
	git clone --recursive https://github.com/named-data-ndnSIM/ndnSIM.git ns-3/src/ndnSIM &&\
	cd /home/developer/ndnSIM/pybindgen &&\
	python3 setup.py install &&\
	cd /home/developer/ndnSIM/ns-3 &&\
	./waf configure --enable-examples -d optimized &&\
	./waf -j`nproc` &&\
	./waf install &&\
	cd /home/developer &&\
	chown -R developer ./*

RUN cd /home/developer &&\
	apt-get install -y python &&\
	git clone https://github.com/named-data-ndnSIM/scenario-template.git scenario &&\
	cd scenario &&\
	cp /home/developer/ndnSIM/ns-3/src/ndnSIM/examples/ndn-simple.cpp /home/developer/scenario/scenarios &&\
	chown -R developer /home/developer/scenario/

RUN echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/developer/ndnSIM/ns-3/build/lib' >> /home/developer/.bashrc &&\
	echo 'export PATH=/home/developer/ndnSIM/ns-3/build/src/fd-net-device:/home/developer/ndnSIM/ns-3/build/src/tap-bridge:$PATH' >> /home/developer/.bashrc &&\
	echo 'export NS3_MODULE_PATH=/usr/lib/gcc/x86_64-linux-gnu/9:/home/developer/ndnSIM/ns-3/build/lib' >> /home/developer/.bashrc &&\
	echo 'export PYTHONPATH=/home/developer/ndnSIM/ns-3/build/bindings/python:/home/developer/ndnSIM/ns-3/src/visualizer:/home/developer/ndnSIM/pybindgen' >> /home/developer/.bashrc &&\
	echo 'export NS3_EXECUTABLE_PATH=/home/developer/ndnSIM/ns-3/build/src/fd-net-device:/home/developer/ndnSIM/ns-3/build/src/tap-bridge' >> /home/developer/.bashrc

USER developer
ENV HOME /home/developer
WORKDIR /home/developer/ndnSIM
CMD /usr/bin/thunar

