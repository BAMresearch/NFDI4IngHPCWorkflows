# MPI C-Compiler Wrapper // Adapt if necessary
MPICC ?= mpicc
# C-Compiler Flags
CFLAGS ?=
CFLAGS += -std=c99 -g -O3
# MPI Launcher
MPIEXEC ?= mpiexec
# Default number of MPI processes to start
NPROCS=4

PROG = mpitest
SRC = $(PROG).c
EXE = $(PROG).exe

default: $(EXE)

$(EXE): $(SRC)
	$(MPICC) $(CFLAGS) $(SRC) -o $(EXE) -lm

run: $(EXE)
	$(MPIEXEC) -np $(NPROCS) ./$(EXE) $(PROG_ARGS)

clean:
	@rm -f $(EXE) core* *.o *.mod a.out *.exe*
