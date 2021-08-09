#!/bin/bash
# Script to convert DICOMs (dcm) to NIFTI (nii) and MINC (mnc) on CIC
# See documentation: https://github.com/katielavigne/documentation/wiki/CIC-scan-transfer

# MODIFY FOR YOUR STUDY
PIname="lepage" # PI storage dir
studyname="LAM" # Study name dir

# DEFINE DIRECTORIES
cicdir="/home/cic/dicom/transfers"
dicomdir="/data/${PIname}/${studyname}/dicom"
mincdir="/data/${PIname}/${studyname}/raw-minc"
niftidir="/data/${PIname}/${studyname}/nifti"
logdir="/data/${PIname}/${studyname}/logs"

# SET DEFAULT CREATION PERMISSIONS
umask u=rwx,g=rwx,o=

mkdir -p $logdir

# SET COLOURS
YELLOW='\033[1;33m'
RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

# LOAD MODULES
if module load dcm2niix/1.0.20200331 ;then
  module load minc-toolkit/1.9.18
else
  echo -e "${RED}ERROR: module load not found. Please login to a cic workstation (e.g., ssh cicws05) and try again.${NC}"
  exit 1
fi

while read line; do
  # Skip empty lines
  if [ -z "${line}" ]; then
    continue
  fi

  # Define subject & visit
  read -a strarr <<< $line
  subjdir="${strarr[0]}"
  subj="${strarr[1]}"
  vis="${strarr[2]}"

  echo "${subj} Visit${vis}: ${subjdir} ..."

  #CHECK FOR DICOM FOLDER ON CIC
  if [ ! -d ${cicdir}/${subjdir} ]; then
    echo -e "${YELLOW}Skipping DICOM transfer... ${dir} not found on ${cicdir}${NC}"
  else
    echo Transferring DICOMs to ${dicomdir}/${subj}/Scan${vis}...
    mkdir -p ${dicomdir}/${subj}/Scan${vis}
    touch ${logdir}/${subj}_Scan${vis}_dicom_transfer.log
    rsync -tvh --info=progress2 --ignore-existing ${cicdir}/${subjdir}/* ${dicomdir}/${subj}/Scan${vis}/ --log-file=${logdir}/${subj}_Scan${vis}_dicom_transfer.log
    if [ "$?" -eq "0" ];then
      echo -e "${GREEN}...DICOM TRANSFER COMPLETE!${NC}"
    else
      echo -e "${RED}ERROR with DICOM transfer: see ${logdir}/${subj}_Scan${vis}_dicom_transfer.log${NC}"
      continue
    fi
  fi

  # CONVERT TO MINC
  if [ -d ${mincdir}/${subj}/Scan${vis} ]; then
    echo -e "${YELLOW}Skipping MINC conversion... ${subj} Scan${vis} directory exists.${NC}"
  else
    echo Converting DICOMs to MINC...
    mkdir -p ${mincdir}/${subj}/Scan${vis}
    touch ${logdir}/${subj}_Scan${vis}_minc_convert.log
    {
    dcm2mnc -usecoordinates -dname '' ${dicomdir}/${subj}/Scan${vis}/* ${mincdir}/${subj}/Scan${vis}

    # # RENAME MINC
    echo Renaming MINCs...
    suffix=1
    for file in ${mincdir}/${subj}/Scan${vis}/*.mnc; do
      path="${file%/*}"
      acq_id=$(mincheader ${file} | grep acquisition_id | grep -Eo '".*"' | sed 's/"//g' | sed 's/*//g' | tr -d ' ')
      series=$(mincheader ${file} | grep series_description | grep -Eo '".*"' | sed 's/"//g' | sed 's/*//g' | tr -d ' ')
      mv -v ${file} ${path}/${subj}_${vis}_${series}_${acq_id}_${suffix}.mnc
      let "suffix++"
    done
    } >> ${logdir}/${subj}_Scan${vis}_minc_convert.log 2>&1
    echo -e "${GREEN}... MINC CONVERSION COMPLETE! See ${subj}_Scan${vis}_minc_convert.log.${NC}"
  fi

  # CONVERT TO NIFTI
  if [ -d ${niftidir}/${subj}/Scan${vis} ]; then
    echo -e "${YELLOW}Skipping NIFTI conversion... ${subj} Scan${vis} directory exists.${NC}"
  else
    echo Converting DICOMs to NIFTI...
    mkdir -p ${niftidir}/${subj}/Scan${vis}
    touch ${logdir}/${subj}_Scan${vis}_nifti_convert.log
    {
    dcm2niix -b y -z y -f ${subj}_${vis}_%d_%s -o ${niftidir}/${subj}/Scan${vis} ${dicomdir}/${subj}/Scan${vis}
    } >> ${logdir}/${subj}_Scan${vis}_nifti_convert.log 2>&1
    echo -e "${GREEN}... NIFTI CONVERSION COMPLETE! See ${subj}_Scan${vis}_nifti_convert.log.${NC}"
  fi

  # CREATE LINKS
  ./mklinks.sh ${subj} ${vis}

  echo -e "${GREEN}${subj} Scan${vis} scan transfer COMPLETE! Please check outputs.${NC}"
done<"$1"
