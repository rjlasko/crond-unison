#!/bin/sh
set -ex


# Ensure that version numbers are set
: "${UNISON_VERSION:?ERROR: not set!}"
: "${OCAML_VERSION:?ERROR: not set!}"
# derive the minor version number of OCaml
OCAML_MINOR_VERSION=$(echo $OCAML_VERSION | cut -f1,2 -d'.')


# Install applications to support compilation + build of Unison
mkdir -p /tmp/src


# always build OCaml from source as Unison is version dependent on OCaml
apk add --update --no-cache gcc make musl-dev curl
curl -L http://caml.inria.fr/pub/distrib/ocaml-${OCAML_MINOR_VERSION}/ocaml-${OCAML_VERSION}.tar.gz | tar zx -C /tmp/src
chmod -R 0777 /tmp/src/ocaml-${OCAML_VERSION}/*
cd /tmp/src/ocaml-${OCAML_VERSION}
./configure -prefix /tmp/ocaml -with-pthread -no-graph -no-debugger -no-ocamldoc
make world.opt install
export PATH=/tmp/ocaml/bin:$PATH


# Build Unison
apk add --update --no-cache bash
curl -L http://www.seas.upenn.edu/~bcpierce/unison/download/releases/unison-${UNISON_VERSION}/unison-${UNISON_VERSION}.tar.gz | tar zx -C /tmp/src
cd /tmp/src/unison-${UNISON_VERSION}
sed -i -e 's/GLIBC_SUPPORT_INOTIFY 0/GLIBC_SUPPORT_INOTIFY 1/' fsmonitor/linux/inotify_stubs.c
make UISTYLE=text THREADS=true
mv /tmp/src/unison-${UNISON_VERSION}/unison /usr/bin
mv /tmp/src/unison-${UNISON_VERSION}/unison-fsmonitor /usr/bin


# add SSH for remote Unison operations
apk add --update --no-cache openssh


# remove all installation-only packages
apk del gcc make musl-dev curl bash
# and clear the apk cache
rm -rf /var/cache/apk/*

