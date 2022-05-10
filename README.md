    .. -*- mode: rst -*-

.. image:: https://img.shields.io/badge/License-BSD%202--Clause-orange.svg
   :target: https://opensource.org/licenses/BSD-2-Clause
   :alt: BSD-2-Clause License
   
ET_biomarker
=========================

This repository contains codes for the MNI ET data set analysis. 
Matching and confounder are the 2 main tools used in this analysis.

| (More details will be added latter.)

Pre-registration report:
-------------

    `Pre-registration report  <https://osf.io/ucrxf/>`_ on OSF;
    
    `Approved Pre-registration report <https://figshare.com/s/3279b808bb70f9f01a46>`_ from *Sci. Rep.* on figshare

Requirements
-------------

Dependencies :

* `nibabel>=3.1 <http://nipy.org/nibabel/>`_
* `numpy>=1.18 <http://www.numpy.org/>`_
* `matplotlib <https://matplotlib.org/>`_
* `pandas <https://pandas.pydata.org/>`_
* `scipy <https://www.scipy.org/>`_
* `scikit-learn <http://scikit-learn.org/stable/>`_
* `statsmodels>=0.12.0 <https://www.statsmodels.org/stable/index.html>`_
* `pydicom>=2.1.2 <https://www.statsmodels.org/stable/index.html>`_

Installation (need update)
------------

First, make sure you have installed all the dependencies listed above.
Then you can install cog-align by running the following commands::

    git clone https://github.com/neurodatascience/ET_biomarker
    cd ET_biomarker
    pip install -e .

You can confirm that the package has successfully installed by opening a Python
terminal and running the following commands::

    import ET_biomarker

Getting started
---------------
The main analysis codes are organized as jupyter notebooks located in the root folder of ET_biomarker, and they are:

0) 0_power_analysis.ipynb: The power analysis for this project;

1) 1_cohort_matching.ipynb: The matching procedure to make sure that the ET and control groups are sex and age matched;

2) 2_analysis_cerebellar_roi.ipynb: The freesurfer and SUIT results analysis;

3) TBD...

-1) Execute a file directly in shell, codes are located in ``experiments`` folder (which includes code to re-execute all of the main and
supplemental experiments included in the manuscript)::

    python experiments/exp1.py
