#******************************************************************************
# Avnet-Silica Demo
# Author: Marco Höfle
# Date: 2026-05-04
# Purpose: creates xsa file for Vitis
#******************************************************************************

set BUILD_DIR .
set XSA_DIR $BUILD_DIR
set PROJ_NAME scu35_zephyr
set PROJ_PATH $BUILD_DIR/$PROJ_NAME.xpr

open_project $PROJ_PATH
write_hw_platform -fixed -force -include_bit -file $XSA_DIR/$PROJ_NAME.xsa

