#!/bin/bash

#########################################################
#########################################################
###### Set up your Overclocking for NVIDIA Rigs     #####
###### Created by sales@CryptoOutlaws.com           #####
#########################################################
#########################################################

# set_OC.sh
#
# DEv Log
#
# version: 1.0.0: Initial Script creation
#

CryptoOC_Ver="1.0.0"

echo ""
echo " $CryptoOC_Ver "
echo ""

POWERLIMIT_MODE="GLOBAL"
POWERLIMIT_WATTS="160"
FAN_SPEED="80"
CORE="50"
MEM="900"

sudo ldconfig /usr/local/cuda/lib64

numGPUS=$(nvidia-smi -i 0 --query-gpu=count --format=csv,noheader,nounits)
NVDS=nvidia-settings
 
export DISPLAY=:0


###Setup Headless mode###
HEADLESS_MODE == "NO"
XORG="FAIL"

if [[ $HEADLESS_MODE == YES ]]
then
  if ! grep -q "XORG_UPDATED" ${NVOC}/xorg_flag;
  then
    sudo nvidia-xconfig -a --enable-all-gpus --allow-empty-initial-configuration --cool-bits=28
    cd ${NVOC}
    echo XORG_UPDATED > "${NVOC}/xorg_flag"
    sleep 4
    echo "XORG UPDATED"
    echo ""
    echo "Rebooting in 5"
    echo ""
    echo "disconnect monitor if connected"
    sleep 5
    sudo reboot
  else
    XORG="OK"
  fi
fi

if grep -q "28800" /etc/X11/xorg.conf;
then
  XORG="OK"
fi

if [[ $XORG == FAIL ]]
then
  echo ""
  echo "Xorg PROBLEM DETECTED"
  echo ""
fi

if [[ $POWERLIMIT_MODE == GLOBAL ]]
then
  sudo nvidia-smi -pl "$POWERLIMIT_WATTS"
fi

#####################
### Set Fan Speed
#####################

gpu=0
while (( gpu < numGPUS ))
do
  NVD_SETTINGS="${NVD_SETTINGS} -a [gpu:$gpu]/GPUFanControlState=1 -a [fan:$gpu]/GPUTargetFanSpeed=${FAN_SPEED}"
  gpu=$((gpu+1))
done

#####################
### Set OC
#####################

gpu=0
while (( gpu < numGPUS ))
do
 NVD_SETTINGS="${NVD_SETTINGS} -a [gpu:$gpu]/GPUGraphicsClockOffset[3]=$CORE -a [gpu:$gpu]/GPUMemoryTransferRateOffset[3]=$MEM"
 gpu=$((gpu+1))
done

# Apply GPU settings
sudo ${NVDS} $NVD_SETTINGS &

#####################
### Display Temps
#####################

# Infinite Loop
while true
do
  sleep 30
  nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader
done
