#!/bin/sh
#SBATCH -N 1
#SBATCH -n 28
#SBATCH -A phpc2021

module purge
module load gcc
module load mvapich2


srun -n 1 poisson 336
srun -n 2 poisson 476
srun -n 4 poisson 672
srun -n 6 poisson 822
srun -n 7 poisson 889
srun -n 8 poisson 952
srun -n 12 poisson 1164
srun -n 14 poisson 1260
srun -n 16 poisson 1344
srun -n 21 poisson 1533
srun -n 24 poisson 1656
srun -n 28 poisson 1764