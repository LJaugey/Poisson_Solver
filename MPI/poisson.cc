/* -------------------------------------------------------------------------- */
#include "simulation.hh"
/* -------------------------------------------------------------------------- */
#include <chrono>
#include <iostream>
#include <sstream>
#include <tuple>
#include <chrono>
/* -------------------------------------------------------------------------- */
#include <mpi.h>
/* -------------------------------------------------------------------------- */

#define EPSILON 0.005

typedef std::chrono::high_resolution_clock clk;
typedef std::chrono::duration<double> second;

static void usage(const std::string & prog_name) {
  std::cerr << prog_name << " <grid_size>" << std::endl;
  exit(0);
}

int main(int argc, char * argv[]) {
  MPI_Init(&argc, &argv);
  int prank, psize;

  MPI_Comm_rank(MPI_COMM_WORLD, &prank);
  MPI_Comm_size(MPI_COMM_WORLD, &psize);

  if (argc != 2) usage(argv[0]);

  std::stringstream args(argv[1]);
  int N;
  args >> N;

  if(args.fail()) usage(argv[0]);

  if(N%psize != 0)
  {
    if(prank == 0) std::cerr<<"The size of the problem ("<<N<<") must be divisible by the number of process ("<<psize<<")"<<std::endl;
    MPI_Finalize();
    return 1;
  }
  int part;

  if((prank == 0) || (prank == psize-1))
  {
    part = N/psize + 1;
  }
  else
  {
    part = N/psize + 2;
  }
  
  Simulation simu(part, N);
  
  simu.set_initial_conditions();
  
  simu.set_epsilon(EPSILON);
  
  float l2;
  int k;

  auto start = clk::now();
  std::tie(l2, k) = simu.compute();
  auto end = clk::now();
  //printf("bonjour monde %i\n", prank);
  second time = end - start;

  if(prank == 0)
  {
    std::cout << psize << " " << N << " "
              << k << " " << std::scientific << l2 << " "
              << time.count() << std::endl;
  }

  MPI_Finalize();

  return 0;
}
