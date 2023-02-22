#!/bin/sh
#SBATCH -N 1
#SBATCH -n 28
#SBATCH -A phpc2021
#SBATCH --constraint=E5v4

module purge
module load intel
module load intel-mpi


srun -n 1 poisson 672
srun -n 2 poisson 672
srun -n 4 poisson 672
srun -n 6 poisson 672
srun -n 7 poisson 672
srun -n 8 poisson 672
srun -n 12 poisson 672
srun -n 14 poisson 672
srun -n 16 poisson 672
srun -n 21 poisson 672
srun -n 24 poisson 672
srun -n 28 poisson 672