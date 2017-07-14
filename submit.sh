#!/bin/bash
#SBATCH -J <SCRIPT> 	# name of the script to run
#SBATCH -o /n/regal/debivort_lab/claire/…/<SCRIPT>.out
#SBATCH -e /n/regal/debivort_lab/claire/…/<SCRIPT>.err
#SBATCH -N 1 		# number of machines – keep to a single one!!!
#SBATCH -c 36 		# number of cores requested
#SBATCH -t 0-12:00 	# D-HH-MM
#SBATCH -p general 	# port on which to run the job
#SBATCH --mem=32000	# maximum memory
#SBATCH --mail-type=END	# send email once the job is completed
#SBATCH --mail-user=guerin.claire01@gmail.com

mkdir -p /scratch/$USER/$SLURM_JOB_ID

srun -c 36 matlab-default -nosplash -nodesktop -r "<SCRIPT>;exit"

rm -rf /scratch/$USER/$SLURM_JOB_ID
