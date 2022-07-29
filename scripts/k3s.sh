#!/bin/bash

usage() {
  echo "Usage: Utility script for installing a k3s cluster"
  echo "  -m              main k3s server (flag)"
  echo "  -n [string_val] node name"
  echo "  -t [string_val] cluster join token, generate a random secret"
  echo "  -s [string_val] main server url format: https://10.0.10.215:6443"
  echo "  -d              debug flag, prints extra information"
  echo "--------------------------------------------------"
  echo " Quick Start:"
  echo "     Node 1: ./k3s.sh -m -t rand_uuid_secret -s https://1.2.3.4:6443"
  echo "     Node N: ./k3s.sh -t rand_uuid_secret -s https://1.2.3.4:6443"
  exit 1
}

check_config() {
  echo "###DEBUG###"
  echo "main = $main"
  echo "INSTALL_K3S_EXEC = $INSTALL_K3S_EXEC"
  echo "K3S_TOKEN = $K3S_TOKEN"
  echo "K3S_NODE_NAME = $K3S_NODE_NAME"
  if [ -z "$K3S_NODE_NAME" ]; then
    echo "K3S_NODE_NAME is required"
    usage
  fi
  echo "K3S_URL = $K3S_URL"
  echo "###DEBUG###"
}

export INSTALL_K3S_EXEC="server"
main=0

while getopts "uhdmn:t:s:" o; do
  case "${o}" in
  m)
    main=1
    export K3S_TOKEN=$(date +%s | sha256sum | base64 | head -c 32)
    ;;
  n)
    export K3S_NODE_NAME=${OPTARG}
    ;;
  t)
    K3S_TOKEN=${OPTARG}
    ;;
  s)
    K3S_URL=${OPTARG}
    ;;
  d)
    DEBUG=1
    ;;
  k)
    copy_kubeconfig
    exit
    ;;
  *)
    usage
    ;;
  esac
done
shift $((OPTIND - 1))

if [ -n "$DEBUG" ]; then
  check_config
fi

if [ $main -eq 1 ]; then
  echo "[setup main k3s server]"
  curl -sfL https://get.k3s.io | K3S_TOKEN=$K3S_TOKEN sh -s - server --cluster-init --disable traefik
  # Note: kubevip as alternative to servicelb, --no-deploy servicelb
elif [[ "$main" -eq 0 ]] && [[ -n "$K3S_TOKEN" ]] && [[ -n "$K3S_URL" ]]; then
  echo "[setup non-main k3s server]"
  curl -sfL https://get.k3s.io | K3S_TOKEN=$K3S_TOKEN sh -s - server --server "$K3S_URL" --disable traefik
fi
