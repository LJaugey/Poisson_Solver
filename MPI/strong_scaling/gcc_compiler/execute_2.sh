#!/bin/sh
#SBATCH -N 2
#SBATCH -n 56
#SBATCH -A phpc2021

module purge
module load gcc
module load mvapich2

srun -n 42 poisson 336
srun -n 48 poisson 336
srun -n 56 poisson 336