#!/bin/bash
# Script to link mincs and niftis (bids compliant) for LAM study on CIC
# Usage: ./mklinks.sh ${subject} ${timepoint}

# MODIFY FOR YOUR STUDY
PIname="lepage" # PI storage dir
studyname="LAM" # Study name dir

# DEFINE DIRECTORIES
mincdir="/data/${PIname}/${studyname}/raw-minc"
mincoutdir="/data/${PIname}/${studyname}/minc-output"
niftidir="/data/${PIname}/${studyname}/nifti"
bidsdir="/data/${PIname}/${studyname}/bids"

subj="$1"
vis="$2"

echo "Creating minc and bids links for preprocessing..."

mkdir -p ${bidsdir}/sub-${subj}/ses-${vis}/{anat,func,fmap,dwi}
mkdir -p ${mincoutdir}/{t1w,t2w,qt1}

# MINC
## MPRAGE (T1w)
counter=1
for file in `ls ${mincdir}/${subj}/Scan${vis} | grep -v "PosDisp" | grep -i mprage`; do
  if [ ${counter} == 1 ]; then
    ln -sv ${mincdir}/${subj}/Scan${vis}/${file} ${mincoutdir}/t1w/${subj}_${vis}_T1.mnc
  else
    ln -sv ${mincdir}/${subj}/Scan${vis}/${file} ${mincoutdir}/t1w/${subj}_${vis}_run-${counter}_T1.mnc
  fi
((counter++))
done

## MP2RAGE (qT1)
counter=1
for file in `ls ${mincdir}/${subj}/Scan${vis} | grep -i T1_Images`; do
  if [ ${counter} == 1 ]; then
    ln -sv ${mincdir}/${subj}/Scan${vis}/${file} ${mincoutdir}/qt1/${subj}_${vis}_T1map.mnc
  else
    ln -sv ${mincdir}/${subj}/Scan${vis}/${file} ${mincoutdir}/qt1/${subj}_${vis}_run-${counter}_T1map.mnc
  fi
  ((counter++))
done

## T2W
counter=1
for file in `ls ${mincdir}/${subj}/Scan${vis} | grep -i T2W_space`; do
  if [ ${counter} == 1 ]; then
    ln -sv ${mincdir}/${subj}/Scan${vis}/${file} ${mincoutdir}/t2w/${subj}_${vis}_T2.mnc
  else
    ln -sv ${mincdir}/${subj}/Scan${vis}/${file} ${mincoutdir}/t2w/${subj}_${vis}_run-${counter}_T2.mnc
  fi
  ((counter++))
done

# BIDS
## MPRAGE
counter=1
for file in `ls ${niftidir}/${subj}/Scan${vis} | grep -v "PosDisp" | grep -i mprage | grep -i .nii`; do
  ln -sv ${niftidir}/${subj}/Scan${vis}/${file} ${bidsdir}/sub-${subj}/ses-${vis}/anat/sub-${subj}_ses-${vis}_run-${counter}_T1w.nii.gz
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".json ${bidsdir}/sub-${subj}/ses-${vis}/anat/sub-${subj}_ses-${vis}_run-${counter}_T1w.json
  ((counter++))
done

## MP2RAGE
counter=1
for file in `ls ${niftidir}/${subj}/Scan${vis} | grep -i T1_Images | grep -i .nii`; do
  ln -sv ${niftidir}/${subj}/Scan${vis}/${file} ${bidsdir}/sub-${subj}/ses-${vis}/anat/sub-${subj}_ses-${vis}_run-${counter}_T1map.nii.gz
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".json ${bidsdir}/sub-${subj}/ses-${vis}/anat/sub-${subj}_ses-${vis}_run-${counter}_T1map.json
  ((counter++))
done

## T2W
counter=1
for file in `ls ${niftidir}/${subj}/Scan${vis} | grep -i T2W_space  | grep -i .nii`; do
  ln -sv ${niftidir}/${subj}/Scan${vis}/${file} ${bidsdir}/sub-${subj}/ses-${vis}/anat/sub-${subj}_ses-${vis}_run-${counter}_T2w.nii.gz
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".json ${bidsdir}/sub-${subj}/ses-${vis}/anat/sub-${subj}_ses-${vis}_run-${counter}_T2w.json
  ((counter++))
done

## RESTING STATE
counter=1
for file in `ls ${niftidir}/${subj}/Scan${vis} | grep -i rest | grep -i nii`; do
  ln -sv ${niftidir}/${subj}/Scan${vis}/${file} ${bidsdir}/sub-${subj}/ses-${vis}/func/sub-${subj}_ses-${vis}_task-rest_run-${counter}_bold.nii.gz
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".json ${bidsdir}/sub-${subj}/ses-${vis}/func/sub-${subj}_ses-${vis}_task-rest_run-${counter}_bold.json
  ((counter++))
done

## GRE FIELD MAP
### ph
counter=1
for file in `ls ${niftidir}/${subj}/Scan${vis} | grep -i gre_field | grep -i ph.nii`; do
  ln -sv ${niftidir}/${subj}/Scan${vis}/${file} ${bidsdir}/sub-${subj}/ses-${vis}/fmap/sub-${subj}_ses-${vis}_run-${counter}_phasediff.nii.gz
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".json ${bidsdir}/sub-${subj}/ses-${vis}/fmap/sub-${subj}_ses-${vis}_run-${counter}_phasediff.json
  ((counter++))
done

### e1
counter=1
for file in `ls ${niftidir}/${subj}/Scan${vis} | grep -i gre_field | grep -i e1.nii`; do
  ln -sv ${niftidir}/${subj}/Scan${vis}/${file} ${bidsdir}/sub-${subj}/ses-${vis}/fmap/sub-${subj}_ses-${vis}_run-${counter}_magnitude1.nii.gz
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".json ${bidsdir}/sub-${subj}/ses-${vis}/fmap/sub-${subj}_ses-${vis}_run-${counter}_magnitude1.json
  ((counter++))
done

#e2
counter=1
for file in `ls ${niftidir}/${subj}/Scan${vis} | grep -i gre_field | grep -i e2.nii`; do
  ln -sv ${niftidir}/${subj}/Scan${vis}/${file} ${bidsdir}/sub-${subj}/ses-${vis}/fmap/sub-${subj}_ses-${vis}_run-${counter}_magnitude2.nii.gz
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".json ${bidsdir}/sub-${subj}/ses-${vis}/fmap/sub-${subj}_ses-${vis}_run-${counter}_magnitude2.json
  ((counter++))
done

## DWI b0 AP
counter=1
for file in `ls ${niftidir}/${subj}/Scan${vis} | grep -v TRACE | grep -i dwi_b0 | grep -i AP | grep -i .nii`; do
  ln -sv ${niftidir}/${subj}/Scan${vis}/${file} ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b0AP_run-${counter}_dwi.nii.gz
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".json ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b0AP_run-${counter}_dwi.json
  ((counter++))
done

## DWI b0 AP
counter=1
for file in `ls ${niftidir}/${subj}/Scan${vis} | grep -v TRACE | grep -i dwi_b0 | grep -i PA | grep -i .nii`; do
  ln -sv ${niftidir}/${subj}/Scan${vis}/${file} ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b0PA_run-${counter}_dwi.nii.gz
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".json ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b0PA_run-${counter}_dwi.json
  ((counter++))
done

## DWI b1000 AP
counter=1
for file in `ls ${niftidir}/${subj}/Scan${vis} | grep -v TRACE | grep -i dwi_b1000 | grep -i AP | grep -i .nii`; do
  ln -sv ${niftidir}/${subj}/Scan${vis}/${file} ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b1000AP_run-${counter}_dwi.nii.gz
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".json ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b1000AP_run-${counter}_dwi.json
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".bval ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b1000AP_run-${counter}_dwi.bval
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".bvec ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b1000AP_run-${counter}_dwi.bvec
  ((counter++))
done

## DWI b1000 PA
counter=1
for file in `ls ${niftidir}/${subj}/Scan${vis} | grep -v TRACE | grep -i dwi_b1000 | grep -i PA | grep -i .nii`; do
  ln -sv ${niftidir}/${subj}/Scan${vis}/${file} ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b1000PA_run-${counter}_dwi.nii.gz
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".json ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b1000PA_run-${counter}_dwi.json
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".bval ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b1000PA_run-${counter}_dwi.bval
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".bvec ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b1000PA_run-${counter}_dwi.bvec
  ((counter++))
done

## DWI b2000 AP
counter=1
for file in `ls ${niftidir}/${subj}/Scan${vis} | grep -v TRACE | grep -i dwi_b2000 | grep -i AP | grep -i .nii`; do
  ln -sv ${niftidir}/${subj}/Scan${vis}/${file} ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b2000AP_run-${counter}_dwi.nii.gz
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".json ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b2000AP_run-${counter}_dwi.json
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".bval ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b2000AP_run-${counter}_dwi.bval
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".bvec ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b2000AP_run-${counter}_dwi.bvec
  ((counter++))
done

## DWI b2000 PA
counter=1
for file in `ls ${niftidir}/${subj}/Scan${vis} | grep -v TRACE | grep -i dwi_b2000 | grep -i PA | grep -i .nii`; do
  ln -sv ${niftidir}/${subj}/Scan${vis}/${file} ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b2000PA_run-${counter}_dwi.nii.gz
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".json ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b2000PA_run-${counter}_dwi.json
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".bval ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b2000PA_run-${counter}_dwi.bval
  ln -sv ${niftidir}/${subj}/Scan${vis}/"${file%%.*}".bvec ${bidsdir}/sub-${subj}/ses-${vis}/dwi/sub-${subj}_ses-${vis}_acq-b2000PA_run-${counter}_dwi.bvec
  ((counter++))
done

echo "... LINK CREATION COMPLETE!"
