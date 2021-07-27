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

for sub_id in sub-018S0055 \
sub-068S4340 \
sub-036S4389 \
sub-136S4433 \
sub-035S4464 \
sub-094S4234 \
sub-153S4151 \
sub-011S0021 \
sub-127S4604 \
sub-035S0555 \
sub-033S4176 \
sub-003S4119 \
sub-123S0298 \
sub-131S0441 \
sub-070S4856 \
sub-067S0059 \
sub-129S0778 \
sub-021S4276 \
sub-007S4387 \
sub-024S4158 \
sub-067S0257 \
sub-033S0920 \
sub-127S4843 \
sub-128S0272 \
sub-032S4921 \
sub-009S4337 \
sub-128S4599 \
sub-037S0467 \
sub-013S4616 \
sub-136S4269 \
sub-031S4474 \
sub-126S0605 \
sub-137S0301 \
sub-021S4421 \
sub-041S4014 \
sub-128S0230 \
sub-130S0969 \
sub-073S4382 \
sub-127S0259 \
sub-073S4552 \
sub-941S1203 \
sub-007S4637 \
sub-032S1169 \
sub-128S0229 \
sub-005S0553 \
sub-032S4348 \
sub-021S0337 \
sub-007S1222 \
sub-033S0741 \
sub-006S0731 \
sub-024S4084 \
sub-033S1016 \
sub-009S4388 \
sub-128S0522 \
sub-003S0907 \
sub-014S4577 \
sub-016S0359 \
sub-941S4100 \
sub-053S4578 \
sub-037S4071 \
sub-029S4585 \
sub-099S4076 \
sub-023S0061 \
sub-006S4357 \
sub-023S4020 \
sub-032S4429 \
sub-941S4255 \
sub-027S0120 \
sub-007S4620 \
sub-094S4560 \
sub-016S4638 \
sub-033S0923 \
sub-073S0311 \
sub-041S4083 \
sub-021S4254 \
sub-131S0123 \
sub-037S4410 \
sub-041S4427 \
sub-032S4304 \
sub-068S0127 \
sub-029S4290 \
sub-029S4279 \
sub-033S1098 \
sub-098S4506 \
sub-123S4362 \
sub-128S0545 \
sub-136S4727 \
sub-002S0413 \
sub-021S4558 \
sub-094S4460 \
sub-098S4003 \
sub-099S4086 \
sub-127S4198 \
sub-137S0972 \
sub-128S4607 \
sub-068S0473 \
sub-029S4384 \
sub-014S0548 \
sub-002S0295 \
sub-127S4645 \
sub-094S4503 \
sub-009S0751 \
sub-037S4308 \
sub-003S4900 \
sub-007S4488 \
sub-041S4041 \
sub-031S4218 \
sub-007S4516 \
sub-129S4396 \
sub-941S4376 \
sub-006S0498 \
sub-073S4739 \
sub-137S4482 \
sub-003S4840 \
sub-022S0096 \
sub-022S0130 \
sub-041S4509 \
sub-014S4576 \
sub-128S4586 \
sub-098S4018 \
sub-021S0984 \
sub-003S4872 \
sub-003S4081 \
sub-031S4496 \
sub-136S0186 \
sub-037S4028 \
sub-036S1023 \
sub-941S4066 \
sub-073S4559 \
sub-006S4485 \
sub-127S0260 \
sub-029S0824 \
sub-941S1202 \
sub-941S4365 \
sub-114S0173 \
sub-002S4264 \
sub-013S4580 \
sub-002S4213 \
sub-027S0074 \
sub-100S4511 \
sub-016S4097 \
sub-098S4275 \
sub-003S0981 \
sub-073S4762 \
sub-099S0352 \
sub-024S0985 \
sub-070S5040 \
sub-073S0089 \
sub-003S4441 \
sub-057S0934 \
sub-032S0479 \
sub-031S4032 \
sub-100S5246 \
sub-037S0454 \
sub-032S0677 \
sub-016S4951 \
sub-036S4878 \
sub-941S1195 \
sub-033S4508 \
sub-009S4612 \
sub-082S4090 \
sub-003S4288 \
sub-031S4021 \
sub-128S4832 \
sub-003S4555 \
sub-009S0842 \
sub-073S4795 \
sub-941S4292 \
sub-021S4335 \
sub-099S4104 \
sub-013S4731 \
sub-035S0156 \
sub-029S4652 \
sub-029S4385 \
sub-016S4688 \
sub-033S4177 \
sub-098S4050 \
sub-006S4449 \
sub-126S0680 \
sub-023S4164 \
sub-033S0734 \
sub-033S4179 \
sub-073S4393 \
sub-141S0767 \
sub-067S0056 \
sub-022S4320 \
sub-041S4037 \
sub-023S0031 \
sub-051S1123 \
sub-136S4726 \
sub-018S4400 \
sub-094S4459 \
sub-100S0069 \
sub-068S0210 \
sub-098S4002 \
sub-128S0863 \
sub-002S0685 \
sub-019S4367 \
sub-005S0610 \
sub-023S0926 \
sub-072S4391 \
sub-123S0113 \
sub-018S4349 \
sub-002S4225 \
sub-016S4952 \
sub-020S1288 \
sub-023S1190 \
sub-128S1242 \
sub-023S0058 \
sub-127S4148 \
sub-002S1280 \
sub-018S4257 \
sub-013S4579 \
sub-072S0315 \
sub-141S0717 \
sub-082S1256 \
sub-114S0416 \
sub-003S4839 \
sub-016S4121 \
sub-007S1206 \
sub-003S4350 \
sub-094S4649 \
sub-098S0896

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
