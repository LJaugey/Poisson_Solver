#!/bin/bash

#SBATCH --nodes=1
#SBATCH --time=1:0:0
#SBATCH --account=phpc2021
#SBATCH --gres=gpu:1
#SBATCH --qos=gpu_free
#SBATCH --partition=gpu

module purge
module load gcc cuda

#srun nvprof ./poisson 2048 32


srun ./poisson 4096 1
srun ./poisson 4096 2
srun ./poisson 4096 4
srun ./poisson 4096 8
srun ./poisson 4096 16
srun ./poisson 4096 32


# Only for 1D
#srun ./poisson 4096 64
#srun ./poisson 4096 128
#srun ./poisson 4096 256
#srun ./poisson 4096 512
#srun ./poisson 4096 1024