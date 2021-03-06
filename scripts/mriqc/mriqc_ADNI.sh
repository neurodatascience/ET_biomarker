#!/bin/bash
DATA_NAME=(${@:1:1})
echo ${DATA_NAME}

DATA_NAME=ADNI
WD_DIR=${HOME}/scratch
MRIQC_VERSION=0.16.1
CON_IMG=${HOME}/scratch/container_images/mriqc_${MRIQC_VERSION}.simg
BIDS_DIR=${WD_DIR}/${DATA_NAME}_BIDS
DATA_DIR=${WD_DIR}/${DATA_NAME}_fmriprep_anat_20.2.0/fmriprep
OUT_DIR=${WD_DIR}/${DATA_NAME}_mriqc-${MRIQC_VERSION}
WORK_DIR=${WD_DIR}/${DATA_NAME}_mriqc_work
templateflow_DIR=${WD_DIR}/templateflow
LOG_FILE=${WD_DIR}/${DATA_NAME}_mriqc.log

echo "" > ${LOG_FILE}

if [ -d ${OUT_DIR} ];then
  rm -rf ${OUT_DIR}
  rm -rf ${OUT_DIR}.tar.gz
  echo "MRIQC out dir already exists, deleted!"
fi
mkdir -p ${OUT_DIR}

if [ -d ${WORK_DIR} ];then
  rm -rf ${WORK_DIR}
  echo "MRIQC work dir already exists, deleted!"
fi
mkdir -p ${WORK_DIR}


N_SUB=$(( $( wc -l ${BIDS_DIR}/participants.tsv | cut -f1 -d' ' ) - 1 ))

# individual level run
echo "Start ${DATA_NAME} participants QC..."
unset PYTHONPATH

for sub_id in sub-002S0413 \
sub-003S0907 \
sub-003S4081 \
sub-003S4119 \
sub-003S4840 \
sub-003S4900 \
sub-005S0553 \
sub-006S0731 \
sub-006S4357 \
sub-007S1222 \
sub-007S4387 \
sub-007S4620 \
sub-007S4637 \
sub-009S4337 \
sub-009S4388 \
sub-011S0021 \
sub-013S4616 \
sub-014S0548 \
sub-014S4577 \
sub-016S0359 \
sub-016S4638 \
sub-018S0055 \
sub-021S0337 \
sub-021S0984 \
sub-021S4254 \
sub-021S4276 \
sub-021S4421 \
sub-021S4558 \
sub-022S0096 \
sub-022S0130 \
sub-023S0061 \
sub-023S4020 \
sub-024S4084 \
sub-024S4158 \
sub-027S0120 \
sub-029S4279 \
sub-029S4290 \
sub-029S4585 \
sub-031S4218 \
sub-031S4474 \
sub-032S1169 \
sub-032S4304 \
sub-032S4348 \
sub-032S4429 \
sub-032S4921 \
sub-033S0741 \
sub-033S0920 \
sub-033S0923 \
sub-033S1016 \
sub-033S1098 \
sub-033S4176 \
sub-035S0555 \
sub-035S4464 \
sub-036S4389 \
sub-037S0467 \
sub-037S4028 \
sub-037S4071 \
sub-037S4410 \
sub-041S4014 \
sub-041S4041 \
sub-041S4083 \
sub-041S4427 \
sub-041S4509 \
sub-053S4578 \
sub-067S0059 \
sub-067S0257 \
sub-068S0127 \
sub-068S0473 \
sub-068S4340 \
sub-070S4856 \
sub-073S0311 \
sub-073S4382 \
sub-073S4552 \
sub-073S4739 \
sub-094S4234 \
sub-094S4460 \
sub-094S4503 \
sub-094S4560 \
sub-098S4003 \
sub-098S4018 \
sub-098S4506 \
sub-099S4076 \
sub-099S4086 \
sub-123S0298 \
sub-123S4362 \
sub-126S0605 \
sub-127S0259 \
sub-127S4604 \
sub-127S4645 \
sub-127S4843 \
sub-128S0229 \
sub-128S0230 \
sub-128S0272 \
sub-128S0522 \
sub-128S4586 \
sub-128S4599 \
sub-128S4607 \
sub-129S0778 \
sub-130S0969 \
sub-131S0123 \
sub-131S0441 \
sub-136S4269 \
sub-136S4433 \
sub-136S4727 \
sub-137S0301 \
sub-137S0972 \
sub-153S4151 \
sub-941S1203 \
sub-941S4100 \
sub-941S4255

do
singularity run -B $HOME:/home/mriqc --home /home/mriqc --cleanenv \
        -B ${DATA_DIR}:/data:ro \
        -B ${OUT_DIR}:/out \
        -B ${WORK_DIR}:/mriqc_work \
        -B ${templateflow_DIR}:/templateflow \
        ${CON_IMG} /data /out participant \
        --participant-label $sub_id -w /mriqc_work --run-id 1 --ica --no-sub --verbose-repo --profile -vvv >> ${LOG_FILE}
done
# group level run
echo "Start group QC..."
singularity run -B $HOME:/home/mriqc --home /home/mriqc --cleanenv \
        -B ${DATA_DIR}:/data:ro \
        -B ${OUT_DIR}:/out \
        -B ${WORK_DIR}:/mriqc_work \
        -B ${templateflow_DIR}:/templateflow \
        ${CON_IMG} /data /out group -w /mriqc_work --verbose-reports >> ${LOG_FILE}

echo Finished QC for ${DATA_NAME}, zipping!
zip -r ${DATA_NAME}_mriqc-${MRIQC_VERSION}.zip ${DATA_NAME}_mriqc-${MRIQC_VERSION}
