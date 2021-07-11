#!/bin/bash
DATA_NAME=(${@:1:1})
echo ${DATA_NAME}

WD_NAME="scratch"
SEARCH_LV=1
LOG_FILE=${DATA_NAME}_heudiconv
HEURISTIC_FILE="src/Heuristics_Abbas_all_T1_T2_fMRI_DTI_SWI.py"
WD_DIR=${HOME}/${WD_NAME}
DATA_DIR=${WD_DIR}/${DATA_NAME}
CODE_DIR=${WD_DIR}/src
SUB_LIST=${WD_DIR}/${DATA_NAME}_subjects.list

BIDS_DIR=${DATA_DIR}_BIDS
INFO_DIR=${DATA_DIR}_INFO
INFO_SUM_DIR=${DATA_DIR}_INFO_SUM
SLURM_LOG_OUT_DIR=${DATA_DIR}_Heudiconv_SLURM_LOG_OUT

rm -rf ${BIDS_DIR}
rm -rf ${BIDS_DIR}.zip
rm -rf ${INFO_SUM_DIR}
rm -rf ${INFO_SUM_DIR}.zip
rm -rf ${SLURM_LOG_OUT_DIR}_run1
rm -rf ${SLURM_LOG_OUT_DIR}_run2
rm ${SUB_LIST}
rm ${LOG_FILE}_run1.log ${LOG_FILE}_run2.log
rm *.ses *.out

chmod 777 src/heudiconv_run1.slurm
chmod 777 src/heudiconv_run1.format
chmod 777 src/heudiconv_run2.sh
chmod 777 src/heudiconv_run2.slurm
chmod 777 src/heudiconv_run2.format

# get all subject dicom foldernames.
find ${DATA_DIR} -maxdepth ${SEARCH_LV} -mindepth ${SEARCH_LV} >> ${SUB_LIST}
N_SUB=$(cat ${SUB_LIST}|wc -l )
echo "Step1: subjects.list created!"
# folder check
if [ -d ${BIDS_DIR} ];then
  echo "BIDS folder already exists!"
else
  mkdir -p ${BIDS_DIR}
fi
if [ -d ${INFO_SUM_DIR} ];then
  echo "INFO_SUM folder already exists!"
else
  mkdir -p ${INFO_SUM_DIR}
fi
if [ -d ${SLURM_LOG_OUT_DIR}_run1 ];then
  echo "SLURM_LOG_OUT_DIR_run1 folder already exists!"
else
  mkdir -p ${SLURM_LOG_OUT_DIR}_run1
fi
if [ -d ${SLURM_LOG_OUT_DIR}_run2 ];then
  echo "SLURM_LOG_OUT_DIR_run2 folder already exists!"
else
  mkdir -p ${SLURM_LOG_OUT_DIR}_run2
fi
echo "Step2: folders created!"

# submit batch job
sbatch ${CODE_DIR}/heudiconv_run1.slurm ${DATA_NAME} ${N_SUB}>> ${LOG_FILE}_run1.log
