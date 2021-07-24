#!/bin/bash
DATA_NAME=(${@:1:1})
echo ${DATA_NAME}

DATA_NAME=PPMI
WD_DIR=${HOME}/scratch
MRIQC_VERSION=0.16.1
CON_IMG=${HOME}/scratch/container_images/mriqc_${MRIQC_VERSION}.simg
BIDS_DIR=${WD_DIR}/${DATA_NAME}_BIDS
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

for sub_id in sub-3853 \
sub-3805 \
sub-3106 \
sub-3171 \
sub-3756 \
sub-3517 \
sub-3859 \
sub-3614 \
sub-3525 \
sub-3115 \
sub-3029 \
sub-3016 \
sub-3357 \
sub-3521 \
sub-3857 \
sub-3526 \
sub-3767 \
sub-3301 \
sub-3165 \
sub-3188 \
sub-3551 \
sub-4018 \
sub-3600 \
sub-3350 \
sub-3316 \
sub-3816 \
sub-3569 \
sub-3503 \
sub-3161 \
sub-3157 \
sub-3008 \
sub-3779 \
sub-3854 \
sub-3811 \
sub-3368 \
sub-3610 \
sub-3570 \
sub-3635 \
sub-4085 \
sub-3769 \
sub-3541 \
sub-3361 \
sub-3362 \
sub-3563 \
sub-3011 \
sub-3850 \
sub-3806 \
sub-3636 \
sub-3812 \
sub-3320 \
sub-3613 \
sub-3172 \
sub-3555 \
sub-3519 \
sub-3191 \
sub-3112 \
sub-3353 \
sub-3276 \
sub-3271 \
sub-3318 \
sub-3013 \
sub-3358 \
sub-3156 \
sub-3759 \
sub-4067 \
sub-3615 \
sub-3523 \
sub-3768 \
sub-3804 \
sub-3803 \
sub-3852 \
sub-3369 \
sub-3572 \
sub-3000 \
sub-3355 \
sub-3627 \
sub-4139 \
sub-3114 \
sub-3389 \
sub-3390 \
sub-3817 \
sub-4010 \
sub-3855 \
sub-3169 \
sub-3310 \
sub-3151 \
sub-3750 \
sub-4004 \
sub-3765 \
sub-3620 \
sub-3554 \
sub-3809 \
sub-3257 \
sub-3518 \
sub-3813 \
sub-3260 \
sub-3611 \
sub-3565 \
sub-3264 \
sub-3004 \
sub-3274 \
sub-3351 \
sub-3515 \
sub-3160 \
sub-3571 \
sub-3370 \
sub-3300 \
sub-3637 \
sub-3851 \
sub-3624 \
sub-3527 \
sub-3807 \
sub-4032 \
sub-3104 \
sub-3270 \
sub-3277
do
singularity run -B $HOME:/home/mriqc --home /home/mriqc --cleanenv \
        -B ${BIDS_DIR}:/data:ro \
        -B ${OUT_DIR}:/out \
        -B ${WORK_DIR}:/mriqc_work \
        -B ${templateflow_DIR}:/templateflow \
        ${CON_IMG} /data /out participant \
        --participant-label $sub_id -w /mriqc_work --run-id 1 --ica --no-sub --verbose-repo --profile -vvv >> ${LOG_FILE}
done
# group level run
echo "Start group QC..."
singularity run -B $HOME:/home/mriqc --home /home/mriqc --cleanenv \
        -B ${BIDS_DIR}:/data:ro \
        -B ${OUT_DIR}:/out \
        -B ${WORK_DIR}:/mriqc_work \
        -B ${templateflow_DIR}:/templateflow \
        ${CON_IMG} /data /out group -w /mriqc_work --verbose-reports >> ${LOG_FILE}

echo Finished QC for ${DATA_NAME}, zipping!
zip -r ${DATA_NAME}_mriqc-${MRIQC_VERSION}.zip ${DATA_NAME}_mriqc-${MRIQC_VERSION}
