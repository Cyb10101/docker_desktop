#!/usr/bin/env bash

PASSWORD=${PASSWORD:-Admin123!}

# Set passwords
echo 'root:'$PASSWORD | chpasswd
