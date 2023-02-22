#!/bin/sh
#SBATCH -N 3
#SBATCH -n 84
#SBATCH -A phpc2021

module purge
module load gcc
module load mvapich2

srun -n 84 poisson 3079