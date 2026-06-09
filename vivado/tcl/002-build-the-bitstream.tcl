#******************************************************************************
# Avnet-Silica Demo
# Author: Marco Höfle
# Date: 2026-05-04
# Purpose: Builds the bitstream
#******************************************************************************

set origin_dir [pwd]
set proj_name "scu35_zephyr"
set proj_path $origin_dir/$proj_name.xpr

open_project $proj_path
update_compile_order -fileset sources_1

# with default implementation settings timing might not be met.
set_property strategy Performance_ExtraTimingOpt [get_runs impl_1]

launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run -timeout 90 impl_1

