#!/bin/sh
#SBATCH -N 3
#SBATCH -n 84
#SBATCH -A phpc2021
#SBATCH --constraint=E5v4

module purge
module load intel
module load intel-mpi

srun -n 84 poisson 672