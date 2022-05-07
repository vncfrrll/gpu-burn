CUDAPATH ?= /usr/lib/cuda

NVCC     :=  ${CUDAPATH}/bin/nvcc
CCPATH   ?= /usr/bin/clang

CFLAGS   ?=
CFLAGS   += -O3
CFLAGS   += -Wno-unused-result
CFLAGS   += -I${CUDAPATH}/include

LDFLAGS  ?=
LDFLAGS  += -lcuda
LDFLAGS  += -L${CUDAPATH}/lib64
LDFLAGS  += -L${CUDAPATH}/lib
LDFLAGS  += -Wl,-rpath=${CUDAPATH}/lib64
LDFLAGS  += -Wl,-rpath=${CUDAPATH}/lib
LDFLAGS  += -lcublas
LDFLAGS  += -lcudart

COMPUTE   ?= 50

NVCCFLAGS ?=
NVCCFLAGS += -I${CUDAPATH}/include
NVCCFLAGS += -arch=compute_$(subst .,,${COMPUTE})

.PHONY: clean

gpu_burn: gpu_burn-drv.o compare.ptx
	g++ -o $@ $< -O3 ${LDFLAGS}

%.o: %.cpp
	g++ ${CFLAGS} -c $<

%.ptx: %.cu
	$PATH=${PATH}:${CCPATH}:. ${NVCC} ${NVCCFLAGS} -ptx $< -o $@

clean:
	$(RM) *.o

image:
	docker build -t gpu-burn .
