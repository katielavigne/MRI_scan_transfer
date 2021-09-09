#!/bin/bash
# Script to rename, move, convert and link dicoms.
# Usage: ./renamedicoms.sh directory_to_rename subjectID timepoint

dir=${1}
subj=${2}
vis=${3}

echo ${subj} Visit${vis}... Renaming files...

#Update Patient Name
dcmodify -ma PatientName=${subj}_${vis} ${dir}/*
rm ${dir}/*bak

#Update Patient ID
dcmodify -ma PatientID=${subj}_${vis} ${dir}/*
rm ${dir}/*bak

