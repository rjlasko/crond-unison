FROM rjlasko/minikron:0.4
MAINTAINER rjlasko

COPY fsroot /
RUN /bin/sh /tmp/build.sh && \
	rm -rf /tmp/*
