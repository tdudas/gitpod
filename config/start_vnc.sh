#!/usr/bin/env bash

vncserver :1 -geometry 1512x982 -depth 24 -localhost no
novnc_proxy --vnc localhost:5901 --listen 6080
