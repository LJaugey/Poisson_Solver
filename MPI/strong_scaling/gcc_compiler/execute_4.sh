#!/bin/sh
#SBATCH -N 4
#SBATCH -n 112
#SBATCH -A phpc2021

module purge
module load gcc
module load mvapich2

srun -n 112 poisson 336