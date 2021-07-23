#!/bin/bash
mkdir -p NC_mriqc_0.15.2
mkdir -p NC_mriqc_work
rm -r NC_mriqc_0.15.2/*
rm -r NC_mriqc_work/*
echo "" > NC_mriqc.log
echo "Start NC 35 participants QC..."
unset PYTHONPATH
singularity run -B $HOME:/home/mriqc --home /home/mriqc --cleanenv \
        -B ${HOME}/project/NC_BIDS:/data:ro \
        -B ${HOME}/project/NC_mriqc_0.15.2:/out \
        -B ${HOME}/project/NC_mriqc_work:/mriqc_work \
        -B ${HOME}/project/templateflow:/templateflow \
        ${HOME}/container_images/mriqc_v0.15.2.simg /data /out participant \
        --participant-label sub-0039 \
sub-0041 \
sub-0042 \
sub-0043 \
sub-0044 \
sub-0053 \
sub-0057 \
sub-0058 \
sub-0060 \
sub-0062 \
sub-0064 \
sub-0066 \
sub-0067 \
sub-0071 \
sub-0072 \
sub-0073 \
sub-0077 \
sub-0078 \
sub-0079 \
sub-0080 \
sub-0082 \
sub-0083 \
sub-0085 \
sub-0100 \
sub-0102 \
sub-0104 \
sub-0107 \
sub-0108 \
sub-0110 \
sub-0113 \
sub-0117 \
sub-0121 \
sub-0124 \
sub-0128 \
sub-0130 -w /mriqc_work --session-id 1 --ica --mem_gb 18 --no-sub --verbose-repo --profile
echo "Start group QC..."
singularity run -B $HOME:/home/mriqc --home /home/mriqc --cleanenv \
        -B ${HOME}/project/NC_BIDS:/data:ro \
        -B ${HOME}/project/NC_mriqc_0.15.2:/out \
        -B ${HOME}/project/NC_mriqc_work:/mriqc_work \
        -B ${HOME}/project/templateflow:/templateflow \
        ${HOME}/container_images/mriqc_v0.15.2.simg /data /out group -w /mriqc_work --verbose-reports

