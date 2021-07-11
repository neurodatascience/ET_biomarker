#!/bin/bash
#SBATCH --job-name=heudic_r2_vin
#SBATCH --time=6:00:00
#SBATCH --account=rpp-aevans-ab
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4GB
#SBATCH --array=1-57
# Outputs ----------------------------------
#SBATCH -o %x-%A-%a_%j.out
#SBATCH -e %x-%A-%a_%j.err
#SBATCH --mail-user=vincent.w.qing@gmail.com
#SBATCH --mail-type=ALL
# usage:
#sbatch Abbas_raw_heudiconv_slurm_run2.sh ${WD_NAME} ${STUDY_NAME} ${SEARCH_LV} ${HEURISTIC_FILE} >> ${LOG_FILE}_run2.log
DATA_NAME=(${@:1:1})
echo ${DATA_NAME}
HEURISTIC_FILE=(${@:2:1})
echo ${HEURISTIC_FILE}
CON_IMG_DIR=(${@:3:1})
SUB_LIST=(${@:4:1})
WD_DIR=${HOME}/scratch
BIDS_DIR=${WD_DIR}/${DATA_NAME}_BIDS
# singularity folders
SINGULARITY_MNT_DIR=/scratch
SINGULARITY_OUT_DIR=${SINGULARITY_MNT_DIR}/${DATA_NAME}_BIDS
# run heudiconv at session level.
echo "Starting task ${SLURM_ARRAY_TASK_ID}"
DIR=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SUB_LIST})
echo "Current Directory: " ${DIR}
DIR_STR=${DIR//\//" " }
subject_id=${DIR_STR[@]:29}
echo ${DATA_NAME} ${DIR} ${DIR_STR} ${subject_id}
#ls ${DIR} >> ${subject_id}.ses
N_SES=$(cat ${subject_id}.ses|wc -l )
for i_ses in $(seq 1 ${N_SES});do
ses_id=$(sed -n "${i_ses}p" ${subject_id}.ses )
singularity run --cleanenv \
-B ${WD_DIR}:${SINGULARITY_MNT_DIR} ${CON_IMG_DIR}/heudiconv_v0.8.0.simg \
-d ${SINGULARITY_MNT_DIR}/${DATA_NAME}/{subject}/{session}/*/*/*/* \
-s ${subject_id} \
-ss ${ses_id} \
-f ${SINGULARITY_MNT_DIR}/${HEURISTIC_FILE} \
--grouping studyUID \
-c dcm2niix -b --overwrite --minmeta \
-o ${SINGULARITY_OUT_DIR}
done
echo "Step5: Heudiconv Run2 finishted, conversion complete!"
