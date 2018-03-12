HOME=/usr/local
FC = ifort

MKLPATH=/public/software/intel/parallel_studio_xe_2013/composer_xe_2013_sp1.0.080/mkl
#MKLPATH=/public/software/compiler/mkl
MKLLIB=-lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core
FFLAGS=-I$(MKLPATH)/include
LDFLAGS=-L$(MKLPATH)/lib/intel64

INC = -I/usr/include  -I/usr/local/include -I$(HOME)/include

# linking
LDPATH = -L$(HOME)/lib  $(LDFLAGS)

# libraries
LIBS = $(MKLLIB)  -lpthread  -lm

# optimization
OP= -parallel  -O3

#------------------------------------------------------------
# Main target (this is been made when you just type 'make')
all: tdse.x

tdse.x: tdse.f90 const.o functions.o vectors.o laser.o ground.f90 propagate.f90 analysis.f90 
	$(FC) $(FFLAGS) $(INC) $(LDPATH) $(OP) -o $*.x tdse.f90 ground.f90 propagate.f90 const.o functions.o vectors.o laser.o analysis.f90 $(LIBS)

ground.x: ground.f90 const.o vectors.o functions.o
	$(FC) $(FFLAGS) $(INC) $(LDPATH) $(OP) -o $*.x ground.f90 const.o vectors.o functions.o $(LIBS)

propagate.x: propagate.f90 consts.o vectors.o functions.o
	$(FC) $(FFLAGS) $(INC) $(LDPATH) $(OP) -o $*.x propagate.f90 consts.o vectors.o functions.o $(LIBS)

analysis.x: analysis.f90 consts.o vectors.o functions.o
	$(FC) $(FFLAGS) $(INC) $(LDPATH) $(OP) -o $*.x analysis.f90 consts.o vectors.o functions.o $(LIBS)

const.x: const.f90
	$(FC) $(FFLAGS) -o $*.x const.f90

vectors.x: vector.f90 const.f90 const.o
	$(FC) $(FFLAGS) $(INC) $(LDPATH) $(OP) -o $*.x const.f90 const.o vectors.f90

functions.x: functions.f90 const.f90 const.o
	$(FC) $(FFLAGS) $(INC) $(LDPATH) $(OP) -o $*.x const.f90 const.o functions.f90

laser.x: laser.f90 const.f90 const.o
	$(FC) $(FFLAGS) $(INC) $(LDPATH) $(OP) -o $*.x const.f90 const.o laser.f90

.SUFFIXES: .f90 .o .x

.f90.o:
	$(FC) $(FFLAGS) $(INC) -c $*.f90

.o.x:
	$(FC) $(LDPATH) -o $*.x $*.o $(LIBS)

clean:
	rm -f $(bins) a.out *.x *.o *.mod $(data) pe po err output

run:
	nohup ./tdse.x 1>output 2>err&

.PHONY: clean all
