/* -------------------------------------------------------------------------- */
#include "simulation.hh"
#include "grid.hh"
/* -------------------------------------------------------------------------- */
#include <iostream>
#include <exception>
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
__global__ void compute_step_one_thread_per_row(Grid uo, Grid u, Grid f, float h)
{
    int i = blockIdx.x*blockDim.x + threadIdx.x;
    int M = u.m();
    int N = u.n();
    
    if((i>0) && (i < M-1))
    {
        for(int j = 1; j<N-1; j++)
        {
            u(i, j) = 0.25 * (  uo(i - 1, j) + uo(i + 1, j) +
                                uo(i, j - 1) + uo(i, j + 1) - 
                                f(i, j) * h * h);
        }
    }
}

/* -------------------------------------------------------------------------- */
__global__ void compute_step_one_thread_per_column(Grid uo, Grid u, Grid f, float h)
{
    int j = blockIdx.x*blockDim.x + threadIdx.x;
    int M = u.m();
    int N = u.n();
    
    if((j>0) && (j < M-1))
    {
        for(int i = 1; i<M-1; i++)
        {
            u(i, j) = 0.25 * (  uo(i - 1, j) + uo(i + 1, j) +
                                uo(i, j - 1) + uo(i, j + 1) - 
                                f(i, j) * h * h);
        }
    }
}

/* -------------------------------------------------------------------------- */
__global__ void compute_step_one_thread_per_entry(Grid uo, Grid u, Grid f, float h)
{
    int j = blockIdx.x*blockDim.x + threadIdx.x;
    int i = blockIdx.y*blockDim.y + threadIdx.y;

    int M = u.m();
    int N = u.n();

    if((i>0) && (i < M-1) && (j>0) && (j < N-1))
    {
        u(i, j) = 0.25 * (  uo(i - 1, j) + uo(i + 1, j) +
                            uo(i, j - 1) + uo(i, j + 1) - 
                            f(i, j) * h * h);
    }
}

/* -------------------------------------------------------------------------- */
__global__ void compute_step_one_thread_per_entry_shared(Grid uo, Grid u, Grid f, float h)
{
    extern __shared__ float s[];
    int J = blockIdx.x*blockDim.x;
    int I = blockIdx.y*blockDim.y;

    int j = threadIdx.x;
    int i = threadIdx.y;

    int M = u.m();
    int N = u.n();

    int a,b;
    
    if((I+i>0) && (I+i < M-1) && (J+j>0) && (J+j < N-1))
    {
        for(int k = i*blockDim.x + j; k<(blockDim.x+2)*(blockDim.y+2); k+=blockDim.x*blockDim.y)
        {
            a = k/(blockDim.x+2);
            b = k%(blockDim.x+2);
            
            if((I-1 + a > 0) && (J-1 + b > 0) && (I-1 + a < M-1) && (J-1 + b < N-1))
            {
                s[k] = uo(I-1 + a, J-1 + b);
            }
        }

        __syncthreads();
        
        // Have to add a "+1" in both dimensions when using s since s[0] corresonds to uo(I-1, J-1)
        u(I+i, J+j) = 0.25 * (  s[(i - 1 + 1)*(blockDim.x+2) + j + 1] + s[(i + 1 + 1)*(blockDim.x+2) + j + 1] +
                                s[(i + 1)*(blockDim.x+2) + j - 1 + 1] + s[(i + 1)*(blockDim.x+2) + j + 1 + 1] - 
                                f(I+i, J+j) * h * h);
    }
}

/* -------------------------------------------------------------------------- */
void Simulation::compute_step(int block_size) {
    Grid & u = m_grids.current();
    Grid & uo = m_grids.old();

    int m = u.m();
    int n = u.n();

    if(m!=n)
    {
        std::cerr<<"Error, matrix must be square"<<std::endl;
        return;
    }

    double h = 1./n;

    // add the kernel call here

    
    // One thread per row

    int dimGrid = (n-1)/block_size + 1;
    int dimBlock = block_size;

    
    compute_step_one_thread_per_row<<<dimGrid, dimBlock>>>(uo, u, m_f, h);
    cudaDeviceSynchronize();
    

    
    /*
    // One thread per column
    
    int dimGrid = (n-1)/block_size + 1;
    int dimBlock = block_size;
    

    compute_step_one_thread_per_column<<<dimGrid, dimBlock>>>(uo, u, m_f, h);
    cudaDeviceSynchronize();
    */

    /*
    // One thread per entry
    
    dim3 dimGrid = dim3((n-1)/block_size + 1, (n-1)/block_size + 1);
    dim3 dimBlock = dim3(block_size, block_size);
    
    compute_step_one_thread_per_entry<<<dimGrid, dimBlock>>>(uo, u, m_f, h);
    cudaDeviceSynchronize();
    */


    /*
    // One thread per entry shared memory
    
    dim3 dimGrid = dim3((n-1)/block_size + 1, (n-1)/block_size + 1);
    dim3 dimBlock = dim3(block_size, block_size);

    compute_step_one_thread_per_entry_shared<<<dimGrid, dimBlock, (block_size+2)*(block_size+2)*sizeof(float)>>>(uo, u, m_f, h);
    cudaDeviceSynchronize();
    */

    auto error = cudaGetLastError();
    if(error != cudaSuccess) {
        throw std::runtime_error("Error Launching Kernel: "
                                 + std::string(cudaGetErrorName(error)) + " - "
                                 + std::string(cudaGetErrorString(error)));
    }
}
