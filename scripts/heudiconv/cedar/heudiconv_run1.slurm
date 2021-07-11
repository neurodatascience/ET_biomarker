#!/bin/bash
#SBATCH --job-name=heudi_vinc_r1
#SBATCH --time=3:00:00
#SBATCH --account=rpp-aevans-ab
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4GB
#SBATCH --array=1-57
# Outputs ----------------------------------
#SBATCH -o %x-%A-%a_%j.out
#SBATCH -e %x-%A-%a_%j.err
#SBATCH --mail-user=vincent.w.qing@gmail.com
#SBATCH --mail-type=ALL

DATA_NAME=(${@:1:1})
echo ${DATA_NAME}
N_SUB=(${@:2:1})
echo ${N_SUB}

WD_NAME="scratch"
#HEURISTIC_FILE="src/Heuristics_Abbas_all_T1_T2_fMRI_DTI_SWI.py"
WD_DIR=${HOME}/${WD_NAME}
DATA_DIR=${WD_DIR}/${DATA_NAME}
CODE_DIR=${WD_DIR}/src
CON_IMG_DIR=${WD_DIR}/container_images
SUB_LIST=${WD_DIR}/${DATA_NAME}_subjects.list
BIDS_DIR=${DATA_DIR}_BIDS
INFO_DIR=${DATA_DIR}_INFO
INFO_SUM_DIR=${DATA_DIR}_INFO_SUM

# singularity folders
SINGULARITY_MNT_DIR=/${WD_NAME}
SINGULARITY_OUT_DIR=${SINGULARITY_MNT_DIR}/${DATA_NAME}_BIDS
# run heudiconv at subject level.
echo "Starting task ${SLURM_ARRAY_TASK_ID}"
DIR=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SUB_LIST} )
echo "Current Directory: " ${WD_DIR}
DIR_STR=${DIR//\//" " }
subject_id=${DIR_STR[@]:29}
echo ${DATA_NAME} ${DIR} ${DIR_STR} ${subject_id}
ls ${DIR} >> ${subject_id}.ses
N_SES=$(cat ${subject_id}.ses|wc -l )
for i_ses in $(seq 1 ${N_SES});do
ses_id=$(sed -n "${i_ses}p" ${subject_id}.ses )
singularity run -B ${WD_DIR}:${SINGULARITY_MNT_DIR} \
${CON_IMG_DIR}/heudiconv_v0.8.0.simg \
-d ${SINGULARITY_MNT_DIR}/${DATA_NAME}/{subject}/{session}/*/*/*/* \
-s ${subject_id} \
-ss ${ses_id} \
-f convertall \
--grouping studyUID \
-c none --overwrite \
-o ${SINGULARITY_OUT_DIR}
done
echo "Step3: Heudiconv Run1 finishted!"
