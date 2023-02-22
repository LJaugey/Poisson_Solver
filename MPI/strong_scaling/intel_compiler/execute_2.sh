#!/bin/sh
#SBATCH -N 2
#SBATCH -n 56
#SBATCH -A phpc2021
#SBATCH --constraint=E5v4

module purge
module load intel
module load intel-mpi

srun -n 42 poisson 672
srun -n 48 poisson 672
srun -n 56 poisson 672