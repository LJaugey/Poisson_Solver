CXX=nvcc
LD=${CXX}
CXXFLAGS+=-Xcompiler="-Wall -Wextra -Werror" -std c++11 -O3
LDFLAGS+=-lm $(CXXFLAGS)

OBJS=poisson.o simulation.o simulation_gpu.o double_buffer.o dumpers.o

all: clean poisson

poisson: $(OBJS)
	$(LD) -o $@ $(OBJS) $(LDFLAGS)

%.o:%.cu
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f hello poisson *.o *~
