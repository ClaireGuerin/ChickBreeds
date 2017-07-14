#!/bin/bash
#SBATCH -J trackchicks
#SBATCH -o /n/regal/debivort_lab/claire/pulcini/trackchicks.out
#SBATCH -e /n/regal/debivort_lab/claire/pulcini/trackchicks.err
#SBATCH -N 1 		
#SBATCH -c 36 		
#SBATCH -t 0-12:00 	
#SBATCH -p general 	
#SBATCH --mem=32000	
#SBATCH --mail-type=END
#SBATCH --mail-user=guerin.claire01@gmail.com

mkdir -p /scratch/$USER/$SLURM_JOB_ID

srun -c 36 matlab-default -nosplash -nodesktop -r "trackchicks;exit"

rm -rf /scratch/$USER/$SLURM_JOB_ID
