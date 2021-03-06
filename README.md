﻿# ChickBreeds

This repository contains all necessary files to track chicks with the BEEtag system. The BEEtag software was developed under MATLAB by James Crall at Harvard University, to track bumble bee individuals with QR-like tags glues on their backs. The software is found under BEEtag folder, or can be downloaded here: https://github.com/jamescrall/BEEtag. 

Elisabetta Versace (CIMec, University of Trento) used the same tags to track chicks instead, and I brought some adaptations to the original software. Additional MATLAB functions can be found in the CEEtag folder (CEE stands both for CIMec and Chicks, and mirrors the BEEtag-software naming).

These new functions are set to run high-throughput analyses on a cluster. Thus, there is an additional .sh file to help launch a job on SLURM that will analyse video files recursively. 
