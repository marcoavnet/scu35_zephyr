DIR_PRJ = $(shell pwd)
DIR_BUILD = ${DIR_PRJ}/build
DIR_BUILD_VIVADO = ${DIR_PRJ}/build/prj
DIR_SRC = ${DIR_PRJ}/sources
DIR_TCL = ${DIR_PRJ}/tcl
VIVADO_ROOT := $(XILINX_VIVADO)
HLS_ROOT := $(XILINX_HLS)


RM = rm -f
RMDIR = rm -rf

VIVADO:=${VIVADO_ROOT}/bin/vivado
VITIS_HLS:=${HLS_ROOT}/bin/vitis_hls


ifndef XILINX_HLS
$(error Please source Xilinx HLS 2025.2 tools first)
endif

.PHONY: all clean

all : create bitstream xsa

create:
	@mkdir -p ${DIR_BUILD_VIVADO}
	cd ${DIR_BUILD_VIVADO}; $(VIVADO) -mode batch -nojournal -nolog -notrace -source ${DIR_TCL}/001-create_proj.tcl


bitstream:
	cd ${DIR_BUILD_VIVADO}; $(VIVADO) -mode batch -nojournal -nolog -notrace -source ${DIR_TCL}/002-build-the-bitstream.tcl


xsa:
	cd ${DIR_BUILD_VIVADO}; $(VIVADO) -mode batch -nojournal -nolog -notrace -source ${DIR_TCL}/003-export_xsa.tcl


bit2bin:
	cd cd ${DIR_BUILD_VIVADO}; $(VIVADO) -mode batch -nojournal -nolog -notrace -source ${DIR_TCL}/004-bit2bin.tcl



clean:
	${RMDIR} build
