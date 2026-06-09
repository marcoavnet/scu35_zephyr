#******************************************************************************
# Avnet-Silica Demo
# Author: Marco Höfle
# Date: 2026-06-08
# Purpose: Vivado project generation
#******************************************************************************

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir [pwd]
set proj_name "scu35_zephyr"
set bd_name "system"
set build_dir $origin_dir
set tcl_dir $build_dir/../../tcl
set src_dir $build_dir/../../sources
set constr_dir $src_dir/constrs/

# Create project
create_project ${proj_name} $build_dir -part xcsu35p-sbvb625-2-e


# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild


# Set project properties
set obj [current_project]
set_property -name "board_part" -value "xilinx.com:scu35:part0:1.0" -objects $obj
set_property -name "target_language" -value "VHDL" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]


# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

add_files -fileset constrs_1 -norecurse $constr_dir/io_design.xdc
add_files -fileset constrs_1 -norecurse $constr_dir/config.xdc
add_files -fileset constrs_1 -norecurse $constr_dir/target.xdc

source $tcl_dir/create_bd.tcl
cr_bd_system .

make_wrapper -files [get_files */system.bd] -top


add_files -norecurse $build_dir/${proj_name}.gen/sources_1/bd/$bd_name/hdl/${bd_name}_wrapper.vhd

update_compile_order -fileset sources_1
