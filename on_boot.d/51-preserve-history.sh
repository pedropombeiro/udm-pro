#!/bin/bash

mkdir -p /data/.home
if [ ! -f /data/.home/.ash_history ]; then
  cp /root/.ash_history /data/.home/.ash_history
fi
ln -sf /data/.home/.ash_history /root/.ash_history
