#!/bin/sh
#SBATCH -N 4
#SBATCH -n 112
#SBATCH -A phpc2021
#SBATCH --constraint=E5v4

module purge
module load intel
module load intel-mpi

srun -n 112 poisson 672