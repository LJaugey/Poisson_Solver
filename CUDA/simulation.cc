/* -------------------------------------------------------------------------- */
#include "simulation.hh"
/* -------------------------------------------------------------------------- */
#include <cmath>
#include <iostream>
#include <cuda_runtime.h>
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
Simulation::Simulation(int m, int n)
    : m_global_m(m), m_global_n(n), m_h_m(1. / m),
      m_h_n(1. / n), m_grids(m, n), m_f(m, n),
      m_dumper(new DumperBinary(m_grids.old())) {}

/* -------------------------------------------------------------------------- */
void Simulation::set_initial_conditions() {
  for (int i = 0; i < m_global_m; i++) {
    for (int j = 0; j < m_global_n; j++) {
      m_f(i, j) = -2. * 100. * M_PI * M_PI * std::sin(10. * M_PI * i * m_h_m) *
                  std::sin(10. * M_PI * j * m_h_n);
    }
  }
}

/* -------------------------------------------------------------------------- */
int Simulation::compute(int block_size) {
  int s;

  for(s = 0; s < 1000; ++s) {
    compute_step(block_size);
    m_grids.swap();
  }

  //m_dumper->dump(s);
  return s;
}

