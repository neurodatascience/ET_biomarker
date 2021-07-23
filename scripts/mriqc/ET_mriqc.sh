#!/bin/bash
mkdir -p ET_mriqc_0.15.2
mkdir -p ET_mriqc_work
rm -r ET_mriqc_0.15.2/*
rm -r ET_mriqc_work/*
echo "" > ET_mriqc.log
unset PYTHONPATH
singularity run -B $HOME:/home/mriqc --home /home/mriqc --cleanenv \
        -B ${HOME}/project/ET_BIDS:/data:ro \
        -B ${HOME}/project/ET_mriqc_0.15.2:/out \
        -B ${HOME}/project/ET_mriqc_work:/mriqc_work \
        -B ${HOME}/project/templateflow:/templateflow \
        ${HOME}/container_images/mriqc_v0.15.2.simg /data /out participant \
        --participant-label sub-0119 \
sub-0046 \
sub-1920 \
sub-1340 \
sub-0134 \
sub-1160 \
sub-1450 \
sub-7000 \
sub-1090 \
sub-4200 \
sub-2800 \
sub-0115 \
sub-1012 \
sub-0016 \
sub-5700 \
sub-1690 \
sub-1310 \
sub-4000 \
sub-3900 \
sub-0061 \
sub-7400 \
sub-1890 \
sub-1500 \
sub-0138 \
sub-4300 \
sub-1230 \
sub-8000 \
sub-1790 \
sub-3700 \
sub-0178 \
sub-2400 \
sub-1120 \
sub-4700 \
sub-9200 \
sub-2000 \
sub-7800 \
sub-0081 \
sub-3600 -w /mriqc_work --session-id 1 --ica --no-sub --verbose-repo --profile -vvv
singularity run -B $HOME:/home/mriqc --home /home/mriqc --cleanenv \
        -B ${HOME}/project/ET_BIDS:/data:ro \
        -B ${HOME}/project/ET_mriqc_0.15.2:/out \
        -B ${HOME}/project/ET_mriqc_work:/mriqc_work \
        -B ${HOME}/project/templateflow:/templateflow \
        ${HOME}/container_images/mriqc_v0.15.2.simg /data /out participant \
        --participant-label sub-0122 -w /mriqc_work --session-id 1 --ica --run-id 2 --no-sub --verbose-repo --profile -vvv 

