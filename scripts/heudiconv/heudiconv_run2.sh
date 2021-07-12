#!/bin/bash
DATA_NAME=(${@:1:1})
echo ${DATA_NAME}

WD_NAME="scratch"
LOG_FILE=${DATA_NAME}_heudiconv_run2.log
HEURISTIC_FILE="src/Heuristics_Abbas_all_T1_T2_fMRI_DTI_SWI.py"
WD_DIR=${HOME}/${WD_NAME}
DATA_DIR=${WD_DIR}/${DATA_NAME}
CODE_DIR=${WD_DIR}/src/heudiconv_run2.slurm
SUB_LIST=${WD_DIR}/${DATA_NAME}_subjects.list

BIDS_DIR=${DATA_DIR}_BIDS
SLURM_LOG_OUT_DIR=${DATA_DIR}_Heudiconv_SLURM_LOG_OUT_r2
CON_IMG_DIR=${WD_DIR}/container_images

RUN_ID=$(tail -c 9 ${DATA_NAME}_heudiconv_run2.log)
if [ -z $RUN_ID ];then
  echo 'no previous run found...'
else
  echo "previous run $RUN_ID found, deleting logs..."
  rm heudic_r2_vin-${RUN_ID}*.out
  rm heudic_r2_vin-${RUN_ID}*.err
fi


# submit batch job
sbatch ${CODE_DIR} ${DATA_NAME} ${HEURISTIC_FILE} ${CON_IMG_DIR} ${SUB_LIST}>> ${LOG_FILE}
