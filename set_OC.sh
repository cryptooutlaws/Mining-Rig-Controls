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
