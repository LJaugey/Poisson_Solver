/* -------------------------------------------------------------------------- */
#include "simulation.hh"
/* -------------------------------------------------------------------------- */
#include <cmath>
#include <iostream>
/* -------------------------------------------------------------------------- */
#include <mpi.h>
/* -------------------------------------------------------------------------- */
Simulation::Simulation(int m, int n)
    : m_global_m(m), m_global_n(n), m_epsilon(1e-7), m_h_m(1. / n),
      m_h_n(1. / n), m_grids(m, n), m_f(m, n),
      m_dumper(new DumperASCII(m_grids.old())) {}

/* -------------------------------------------------------------------------- */
void Simulation::set_initial_conditions() {
  /*// original code
  for (int i = 0; i < m_global_m; i++) {
    for (int j = 0; j < m_global_n; j++) {
      m_f(i, j) = -2. * 100. * M_PI * M_PI * std::sin(10. * M_PI * i * m_h_m) *
                  std::sin(10. * M_PI * j * m_h_n);
    }
  }*/

  // modified code
  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  int N = m_global_n;

  int start, end;

  if(rank == 0)
  {
    start = 0;
  }
  else
  {
    start = rank*(N/size)-1;
  }
   
  end = start + m_global_m;

  for (int i = start; i < end; i++) {
    for (int j = 0; j < m_global_n; j++) {
      m_f(i-start, j) = -2. * 100. * M_PI * M_PI * std::sin(10. * M_PI * i * m_h_m) *
                  std::sin(10. * M_PI * j * m_h_n);
    }
  }
}
/* -------------------------------------------------------------------------- */
std::tuple<float, int> Simulation::compute() {
  int s = 0;
  float l2 = 0;
  do {
    l2 = compute_step();

    m_grids.swap();

    ++s;
  } while (l2 > m_epsilon);
  
  //m_dumper->dump(s);

  return std::make_tuple(l2, s);
}

/* -------------------------------------------------------------------------- */
void Simulation::set_epsilon(float epsilon) { m_epsilon = epsilon; }

/* -------------------------------------------------------------------------- */
float Simulation::epsilon() const { return m_epsilon; }

/* -------------------------------------------------------------------------- */
float Simulation::compute_step() {
  /*// original code
  float l2 = 0.;
 
  Grid & u = m_grids.current();
  Grid & uo = m_grids.old();
  
  
  for (int i = 1; i < m_global_m - 1; i++) {
    for (int j = 1; j < m_global_n - 1; j++) {
      // computation of the new step
      u(i, j) = 0.25 * (uo(i - 1, j) + uo(i + 1, j) + uo(i, j - 1) +
                        uo(i, j + 1) - m_f(i, j) * m_h_m * m_h_n);

      // L2 norm
      l2 += (uo(i, j) - u(i, j)) * (uo(i, j) - u(i, j));
    }
  }*/

  // modified code
  float l2 = 0.;
  float sum = 0.;
  int rank, size;
  
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
 
  Grid & u = m_grids.current();
  Grid & uo = m_grids.old();


  // Communication between processes to exchange ghost lines
  MPI_Request req1, req2, dummy;
  
  if(rank != 0)   //top ghost line communication
  {
    // send top line to previous process' bottom ghost line
    MPI_Isend(&uo(1,0), m_global_n, MPI_FLOAT, rank-1, 0, MPI_COMM_WORLD, &dummy);

    // receive top ghost line from previous process
    MPI_Irecv(&uo(0,0), m_global_n, MPI_FLOAT, rank-1, MPI_ANY_TAG, MPI_COMM_WORLD, &req1);
  }
  

  if(rank != size-1)  //bottom ghost line communication
  {
    // send last line to next process' top ghost line
    MPI_Isend(&uo(m_global_m-2,0), m_global_n, MPI_FLOAT, rank+1, 1, MPI_COMM_WORLD, &dummy);

    // receive bottom ghost line from next process
    MPI_Irecv(&uo(m_global_m-1,0), m_global_n, MPI_FLOAT, rank+1, MPI_ANY_TAG, MPI_COMM_WORLD, &req2);
  }
  
  // ======= VERSION 1 =======//
  
  //waiting for communications
  if(rank != 0)   MPI_Wait(&req1, MPI_STATUS_IGNORE);
  if(rank != size-1)  MPI_Wait(&req2, MPI_STATUS_IGNORE);

  for (int i = 1; i < m_global_m - 1; i++) {
    for (int j = 1; j < m_global_n - 1; j++) {
      // computation of the new step
      u(i, j) = 0.25 * (uo(i - 1, j) + uo(i + 1, j) + uo(i, j - 1) +
                        uo(i, j + 1) - m_f(i, j) * m_h_m * m_h_n);

      // L2 norm
      sum += (uo(i, j) - u(i, j)) * (uo(i, j) - u(i, j));
    }
  }
  // ======= END VERSION 1 =======//



  // ======= VERSION 2 =======//
  /*
  Wanted to hide communication time by first computing the values that do not require ghost lines and
  then wait for communications and compute the rest. However, this slows the code down (on gcc/MVAPICH2).
  My guess is that since the work is evenly splitted among processors, it does not change to do the
  communication before or after the work. Indeed, one core/processor must handle the communication and the
  others have to wait on it. So if the worload is very even, the total time would be T_comm + T_work or 
  T_work + T_comm which is the same since T_comm cannot be hidden by T_work. One way to solve this issue could
  be to dedicate one core to the communication but we loose one core for computation. 
  Now the code is probably slower due to the overhead of creating two additional for loops (and maybe because
  of additional cache misses). */

  /*
  for (int i = 2; i < m_global_m - 2; i++) {
      for (int j = 1; j < m_global_n - 1; j++) {
        // computation of the new step
        u(i, j) = 0.25 * (uo(i - 1, j) + uo(i + 1, j) + uo(i, j - 1) +
                          uo(i, j + 1) - m_f(i, j) * m_h_m * m_h_n);

        // L2 norm
        sum += (uo(i, j) - u(i, j)) * (uo(i, j) - u(i, j));
      }
    }

  int i = 1;
    
  if(rank != 0)   MPI_Wait(&req1, MPI_STATUS_IGNORE);

  for (int j = 1; j < m_global_n - 1; j++) {        // First row
      // computation of the new step
      u(i, j) = 0.25 * (uo(i - 1, j) + uo(i + 1, j) + uo(i, j - 1) +
                        uo(i, j + 1) - m_f(i, j) * m_h_m * m_h_n);

      // L2 norm
      sum += (uo(i, j) - u(i, j)) * (uo(i, j) - u(i, j));
  }

  if(rank != size-1)  MPI_Wait(&req2, MPI_STATUS_IGNORE);
  
  i = m_global_m - 2;

  for (int j = 1; j < m_global_n - 1; j++) {      // Last row
    // computation of the new step
    u(i, j) = 0.25 * (uo(i - 1, j) + uo(i + 1, j) + uo(i, j - 1) +
                      uo(i, j + 1) - m_f(i, j) * m_h_m * m_h_n);

    // L2 norm
    sum += (uo(i, j) - u(i, j)) * (uo(i, j) - u(i, j));
  }
  */
  // ======= END VERSION 2 =======//


  MPI_Allreduce(&sum, &l2, 1, MPI_FLOAT, MPI_SUM, MPI_COMM_WORLD);
  
  return l2;
}
