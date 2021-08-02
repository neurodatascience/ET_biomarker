import os
# Heuristics created by Vincent for Abbas dataset sample6.
# 27th Nov. 2019
# updated 23th Jan. 2020
def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')
    return template, outtype, annotation_classes

def infotodict(seqinfo):
    """Heuristic evaluator for determining which runs belong where
    allowed template fields - follow python string module:
    item: index within category
    subject: participant id
    seqitem: run number during scanning
    subindex: sub index within group
    """
    t1w = create_key('sub-{subject}/anat/sub-{subject}_run-{item:01d}_T1w')
    info = {t1w: []}
    data = create_key('run{item:03d}')
    last_run = len(seqinfo)
    for idx, s in enumerate(seqinfo):
        print(s)
        if ('RAGE' in s.series_description) or ('SPGR' in s.series_description):
            print("****** T1 ******")
            info[t1w].append(s.series_id);
    return info
