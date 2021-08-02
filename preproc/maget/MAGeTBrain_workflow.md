# Workflow to segment cerebellum using [MAGeTBrain](https://github.com/CoBrALab/MAGeTbrain) pipeline.

1. Apply brain masks using fMRIPrep output
2. Convert [nifti to minc](./scripts)
3. Sample [template libraries](./metadata) separately for NC,ET,PD cohorts
4. Copy Cerebellum atlases (brain+labels) from [here](https://github.com/CoBrALab/atlases/tree/master/cerebellum)
5. run MAGeT Brain
6. Convert [minc to nifti](./scripts)
