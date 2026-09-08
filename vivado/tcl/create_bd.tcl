# Proc to create BD system
proc cr_bd_system { parentCell } {

  # CHANGE DESIGN NAME HERE
  set design_name system

  common::send_gid_msg -ssname BD::TCL -id 2010 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

  create_bd_design $design_name

  set bCheckIPsPassed 1
  ##################################################################
  # CHECK IPs
  ##################################################################
  set bCheckIPs 1
  if { $bCheckIPs == 1 } {
     set list_check_ips "\ 
  xilinx.com:ip:microblaze_riscv:*\
  xilinx.com:ip:axi_intc:*\
  xilinx.com:inline_hdl:ilconcat:*\
  xilinx.com:ip:mdm_riscv:*\
  xilinx.com:ip:lmb_v10:*\
  xilinx.com:ip:lmb_bram_if_cntlr:*\
  xilinx.com:ip:blk_mem_gen:*\
  xilinx.com:ip:axi_iic:*\
  xilinx.com:ip:axi_ethernetlite:*\
  xilinx.com:ip:axi_timer:*\
  xilinx.com:ip:axi_gpio:*\
  xilinx.com:ip:axi_uartlite:*\
  xilinx.com:ip:axi_quad_spi:*\
  xilinx.com:ip:smartconnect:*\
  xilinx.com:ip:clk_wiz:*\
  xilinx.com:ip:proc_sys_reset:*\
  "

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

  }

  if { $bCheckIPsPassed != 1 } {
    common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
    return 3
  }

  
# Hierarchical cell: clk_rst
proc create_hier_cell_clk_rst { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_clk_rst() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_diff_clock


  # Create pins
  create_bd_pin -dir O -type clk clk_out1
  create_bd_pin -dir I -type rst reset
  create_bd_pin -dir O -type clk clk_out2
  create_bd_pin -dir O -from 0 -to 0 -type rst bus_struct_reset
  create_bd_pin -dir O -type rst mb_reset
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn
  create_bd_pin -dir I -type rst mb_debug_sys_rst

  # Create instance: clk_wiz_1, and set properties
  set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz clk_wiz_1 ]
  set_property -dict [list \
    CONFIG.CLKOUT1_JITTER {102.086} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200.000} \
    CONFIG.CLKOUT2_JITTER {115.831} \
    CONFIG.CLKOUT2_PHASE_ERROR {87.180} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLK_IN1_BOARD_INTERFACE {sys_diff_clock} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {6.000} \
    CONFIG.MMCM_CLKOUT1_DIVIDE {12} \
    CONFIG.NUM_OUT_CLKS {2} \
    CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
    CONFIG.RESET_BOARD_INTERFACE {reset} \
    CONFIG.RESET_PORT {resetn} \
    CONFIG.RESET_TYPE {ACTIVE_LOW} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $clk_wiz_1


  # Create instance: rst_clk_wiz_1_200M, and set properties
  set rst_clk_wiz_1_200M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset rst_clk_wiz_1_200M ]
  set_property -dict [list \
    CONFIG.RESET_BOARD_INTERFACE {reset} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $rst_clk_wiz_1_200M


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins clk_wiz_1/CLK_IN1_D] [get_bd_intf_pins sys_diff_clock]

  # Create port connections
  connect_bd_net -net clk_wiz_1_clk_out1  [get_bd_pins clk_wiz_1/clk_out1] \
  [get_bd_pins clk_out1] \
  [get_bd_pins rst_clk_wiz_1_200M/slowest_sync_clk]
  connect_bd_net -net clk_wiz_1_clk_out2  [get_bd_pins clk_wiz_1/clk_out2] \
  [get_bd_pins clk_out2]
  connect_bd_net -net clk_wiz_1_locked  [get_bd_pins clk_wiz_1/locked] \
  [get_bd_pins rst_clk_wiz_1_200M/dcm_locked]
  connect_bd_net -net mb_debug_sys_rst_1  [get_bd_pins mb_debug_sys_rst] \
  [get_bd_pins rst_clk_wiz_1_200M/mb_debug_sys_rst]
  connect_bd_net -net reset_1  [get_bd_pins reset] \
  [get_bd_pins rst_clk_wiz_1_200M/ext_reset_in] \
  [get_bd_pins clk_wiz_1/resetn]
  connect_bd_net -net rst_clk_wiz_1_200M_bus_struct_reset  [get_bd_pins rst_clk_wiz_1_200M/bus_struct_reset] \
  [get_bd_pins bus_struct_reset]
  connect_bd_net -net rst_clk_wiz_1_200M_mb_reset  [get_bd_pins rst_clk_wiz_1_200M/mb_reset] \
  [get_bd_pins mb_reset]
  connect_bd_net -net rst_clk_wiz_1_200M_peripheral_aresetn  [get_bd_pins rst_clk_wiz_1_200M/peripheral_aresetn] \
  [get_bd_pins peripheral_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}
  
# Hierarchical cell: peripherals
proc create_hier_cell_peripherals { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_peripherals() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic_acl_main

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic_eeprom_main

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:mii_rtl:1.0 mii

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_mdc

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic_ina_main

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 DIP

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 push_buttons

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 scu35_uartb

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 LEDs

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 PMOD_i

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI


  # Create pins
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_pin -dir O -type intr irpt_iic_acl
  create_bd_pin -dir O -type intr irpt_iic_eeprom
  create_bd_pin -dir O -type intr irpt_eth
  create_bd_pin -dir O -type intr irpt_iic_ina
  create_bd_pin -dir O -type intr irpt_timer
  create_bd_pin -dir O -type intr irpt_uart0
  create_bd_pin -dir I -type clk ext_spi_clk
  create_bd_pin -dir O -type intr irpt_spi_flash

  # Create instance: iic_acl, and set properties
  set iic_acl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic iic_acl ]
  set_property -dict [list \
    CONFIG.IIC_BOARD_INTERFACE {iic_acl_main} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $iic_acl


  # Create instance: iic_eeprom, and set properties
  set iic_eeprom [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic iic_eeprom ]
  set_property -dict [list \
    CONFIG.IIC_BOARD_INTERFACE {iic_eeprom_main} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $iic_eeprom


  # Create instance: axi_ethernetlite_0, and set properties
  set axi_ethernetlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernetlite axi_ethernetlite_0 ]
  set_property -dict [list \
    CONFIG.MDIO_BOARD_INTERFACE {mdio_mdc} \
    CONFIG.MII_BOARD_INTERFACE {mii} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $axi_ethernetlite_0


  # Create instance: iic_ina, and set properties
  set iic_ina [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic iic_ina ]
  set_property -dict [list \
    CONFIG.IIC_BOARD_INTERFACE {iic_ina_main} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $iic_ina


  # Create instance: axi_timer_0, and set properties
  set axi_timer_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer axi_timer_0 ]

  # Create instance: gpio_pushB_DIP, and set properties
  set gpio_pushB_DIP [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio gpio_pushB_DIP ]
  set_property -dict [list \
    CONFIG.C_GPIO2_WIDTH {8} \
    CONFIG.C_IS_DUAL {1} \
    CONFIG.GPIO_BOARD_INTERFACE {push_buttons} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $gpio_pushB_DIP


  # Create instance: axi_uartlite_0, and set properties
  set axi_uartlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite axi_uartlite_0 ]
  set_property -dict [list \
    CONFIG.C_BAUDRATE {115200} \
    CONFIG.C_S_AXI_ACLK_FREQ_HZ {200000000} \
    CONFIG.UARTLITE_BOARD_INTERFACE {scu35_uartb} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $axi_uartlite_0


  # Create instance: axi_quad_spi_0, and set properties
  set axi_quad_spi_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi axi_quad_spi_0 ]
  set_property -dict [list \
    CONFIG.C_FIFO_DEPTH {16} \
    CONFIG.C_SCK_RATIO {16} \
    CONFIG.C_USE_STARTUP {1} \
    CONFIG.C_USE_STARTUP_INT {1} \
  ] $axi_quad_spi_0


  # Create instance: gpio_LEDs, and set properties
  set gpio_LEDs [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio gpio_LEDs ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {0} \
    CONFIG.C_GPIO_WIDTH {15} \
    CONFIG.C_TRI_DEFAULT {0x00000000} \
  ] $gpio_LEDs


  # Create instance: gpio_PMOD_i, and set properties
  set gpio_PMOD_i [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio gpio_PMOD_i ]
  set_property CONFIG.C_GPIO_WIDTH {32} $gpio_PMOD_i


  # Create instance: microblaze_riscv_0_axi_periph, and set properties
  set microblaze_riscv_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect microblaze_riscv_0_axi_periph ]
  set_property -dict [list \
    CONFIG.ADVANCED_PROPERTIES {__experimental_features__ {legacy_low_area_mode 1}} \
    CONFIG.NUM_MI {11} \
    CONFIG.NUM_SI {1} \
  ] $microblaze_riscv_0_axi_periph


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins iic_acl/IIC] [get_bd_intf_pins iic_acl_main]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins microblaze_riscv_0_axi_periph/M00_AXI] [get_bd_intf_pins M00_AXI]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins iic_eeprom/IIC] [get_bd_intf_pins iic_eeprom_main]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins microblaze_riscv_0_axi_periph/S00_AXI] [get_bd_intf_pins S00_AXI]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins axi_ethernetlite_0/MII] [get_bd_intf_pins mii]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins axi_ethernetlite_0/MDIO] [get_bd_intf_pins mdio_mdc]
  connect_bd_intf_net -intf_net Conn8 [get_bd_intf_pins iic_ina/IIC] [get_bd_intf_pins iic_ina_main]
  connect_bd_intf_net -intf_net Conn11 [get_bd_intf_pins gpio_pushB_DIP/GPIO2] [get_bd_intf_pins DIP]
  connect_bd_intf_net -intf_net Conn12 [get_bd_intf_pins gpio_pushB_DIP/GPIO] [get_bd_intf_pins push_buttons]
  connect_bd_intf_net -intf_net Conn14 [get_bd_intf_pins axi_uartlite_0/UART] [get_bd_intf_pins scu35_uartb]
  connect_bd_intf_net -intf_net Conn18 [get_bd_intf_pins gpio_LEDs/GPIO] [get_bd_intf_pins LEDs]
  connect_bd_intf_net -intf_net Conn19 [get_bd_intf_pins gpio_PMOD_i/GPIO] [get_bd_intf_pins PMOD_i]
  connect_bd_intf_net -intf_net microblaze_riscv_0_axi_periph_M01_AXI [get_bd_intf_pins axi_timer_0/S_AXI] [get_bd_intf_pins microblaze_riscv_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net microblaze_riscv_0_axi_periph_M02_AXI [get_bd_intf_pins axi_uartlite_0/S_AXI] [get_bd_intf_pins microblaze_riscv_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net microblaze_riscv_0_axi_periph_M03_AXI [get_bd_intf_pins gpio_LEDs/S_AXI] [get_bd_intf_pins microblaze_riscv_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net microblaze_riscv_0_axi_periph_M04_AXI [get_bd_intf_pins gpio_pushB_DIP/S_AXI] [get_bd_intf_pins microblaze_riscv_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net microblaze_riscv_0_axi_periph_M05_AXI [get_bd_intf_pins iic_acl/S_AXI] [get_bd_intf_pins microblaze_riscv_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net microblaze_riscv_0_axi_periph_M06_AXI [get_bd_intf_pins iic_eeprom/S_AXI] [get_bd_intf_pins microblaze_riscv_0_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net microblaze_riscv_0_axi_periph_M07_AXI [get_bd_intf_pins iic_ina/S_AXI] [get_bd_intf_pins microblaze_riscv_0_axi_periph/M07_AXI]
  connect_bd_intf_net -intf_net microblaze_riscv_0_axi_periph_M08_AXI [get_bd_intf_pins gpio_PMOD_i/S_AXI] [get_bd_intf_pins microblaze_riscv_0_axi_periph/M08_AXI]
  connect_bd_intf_net -intf_net microblaze_riscv_0_axi_periph_M09_AXI [get_bd_intf_pins axi_ethernetlite_0/S_AXI] [get_bd_intf_pins microblaze_riscv_0_axi_periph/M09_AXI]
  connect_bd_intf_net -intf_net microblaze_riscv_0_axi_periph_M10_AXI [get_bd_intf_pins axi_quad_spi_0/AXI_LITE] [get_bd_intf_pins microblaze_riscv_0_axi_periph/M10_AXI]

  # Create port connections
  connect_bd_net -net axi_ethernetlite_0_ip2intc_irpt  [get_bd_pins axi_ethernetlite_0/ip2intc_irpt] \
  [get_bd_pins irpt_eth]
  connect_bd_net -net axi_quad_spi_0_ip2intc_irpt  [get_bd_pins axi_quad_spi_0/ip2intc_irpt] \
  [get_bd_pins irpt_spi_flash]
  connect_bd_net -net axi_timer_0_interrupt  [get_bd_pins axi_timer_0/interrupt] \
  [get_bd_pins irpt_timer]
  connect_bd_net -net axi_uartlite_0_interrupt  [get_bd_pins axi_uartlite_0/interrupt] \
  [get_bd_pins irpt_uart0]
  connect_bd_net -net ext_spi_clk_1  [get_bd_pins ext_spi_clk] \
  [get_bd_pins axi_quad_spi_0/ext_spi_clk]
  connect_bd_net -net iic_acl_iic2intc_irpt  [get_bd_pins iic_acl/iic2intc_irpt] \
  [get_bd_pins irpt_iic_acl]
  connect_bd_net -net iic_eeprom_iic2intc_irpt  [get_bd_pins iic_eeprom/iic2intc_irpt] \
  [get_bd_pins irpt_iic_eeprom]
  connect_bd_net -net iic_ina_iic2intc_irpt  [get_bd_pins iic_ina/iic2intc_irpt] \
  [get_bd_pins irpt_iic_ina]
  connect_bd_net -net s_axi_aclk_1  [get_bd_pins s_axi_aclk] \
  [get_bd_pins axi_ethernetlite_0/s_axi_aclk] \
  [get_bd_pins axi_quad_spi_0/s_axi_aclk] \
  [get_bd_pins axi_timer_0/s_axi_aclk] \
  [get_bd_pins axi_uartlite_0/s_axi_aclk] \
  [get_bd_pins gpio_LEDs/s_axi_aclk] \
  [get_bd_pins gpio_PMOD_i/s_axi_aclk] \
  [get_bd_pins gpio_pushB_DIP/s_axi_aclk] \
  [get_bd_pins iic_acl/s_axi_aclk] \
  [get_bd_pins iic_eeprom/s_axi_aclk] \
  [get_bd_pins iic_ina/s_axi_aclk] \
  [get_bd_pins microblaze_riscv_0_axi_periph/aclk]
  connect_bd_net -net s_axi_aresetn_1  [get_bd_pins s_axi_aresetn] \
  [get_bd_pins axi_ethernetlite_0/s_axi_aresetn] \
  [get_bd_pins axi_quad_spi_0/s_axi_aresetn] \
  [get_bd_pins axi_timer_0/s_axi_aresetn] \
  [get_bd_pins axi_uartlite_0/s_axi_aresetn] \
  [get_bd_pins gpio_LEDs/s_axi_aresetn] \
  [get_bd_pins gpio_PMOD_i/s_axi_aresetn] \
  [get_bd_pins gpio_pushB_DIP/s_axi_aresetn] \
  [get_bd_pins iic_acl/s_axi_aresetn] \
  [get_bd_pins iic_eeprom/s_axi_aresetn] \
  [get_bd_pins iic_ina/s_axi_aresetn] \
  [get_bd_pins microblaze_riscv_0_axi_periph/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}
  
# Hierarchical cell: microblaze_riscv_0_local_memory
proc create_hier_cell_microblaze_riscv_0_local_memory { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_microblaze_riscv_0_local_memory() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB

  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB


  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -type rst SYS_Rst

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10 dlmb_v10 ]
  set_property CONFIG.C_LMB_NUM_SLAVES {2} $dlmb_v10


  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10 ilmb_v10 ]
  set_property CONFIG.C_LMB_NUM_SLAVES {2} $ilmb_v10


  # Create instance: dlmb_bram_if_cntlr0, and set properties
  set dlmb_bram_if_cntlr0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr dlmb_bram_if_cntlr0 ]
  set_property CONFIG.C_ECC {0} $dlmb_bram_if_cntlr0


  # Create instance: ilmb_bram_if_cntlr0, and set properties
  set ilmb_bram_if_cntlr0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr ilmb_bram_if_cntlr0 ]
  set_property CONFIG.C_ECC {0} $ilmb_bram_if_cntlr0


  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen lmb_bram ]
  set_property -dict [list \
    CONFIG.Enable_B {Use_ENB_Pin} \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
    CONFIG.Port_B_Clock {100} \
    CONFIG.Port_B_Enable_Rate {100} \
    CONFIG.Port_B_Write_Rate {50} \
    CONFIG.Use_RSTB_Pin {true} \
    CONFIG.use_bram_block {BRAM_Controller} \
  ] $lmb_bram


  # Create instance: dlmb_bram_if_cntlr1, and set properties
  set dlmb_bram_if_cntlr1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr dlmb_bram_if_cntlr1 ]
  set_property CONFIG.C_ECC {0} $dlmb_bram_if_cntlr1


  # Create instance: ilmb_bram_if_cntlr1, and set properties
  set ilmb_bram_if_cntlr1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr ilmb_bram_if_cntlr1 ]
  set_property CONFIG.C_ECC {0} $ilmb_bram_if_cntlr1


  # Create instance: lmb_bram1, and set properties
  set lmb_bram1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen lmb_bram1 ]
  set_property -dict [list \
    CONFIG.Enable_B {Use_ENB_Pin} \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
    CONFIG.Port_B_Clock {100} \
    CONFIG.Port_B_Enable_Rate {100} \
    CONFIG.Port_B_Write_Rate {50} \
    CONFIG.Use_RSTB_Pin {true} \
    CONFIG.use_bram_block {BRAM_Controller} \
  ] $lmb_bram1


  # Create interface connections
  connect_bd_intf_net -intf_net Conn [get_bd_intf_pins dlmb_bram_if_cntlr1/SLMB] [get_bd_intf_pins dlmb_v10/LMB_Sl_1]
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins ilmb_bram_if_cntlr1/SLMB] [get_bd_intf_pins ilmb_v10/LMB_Sl_1]
  connect_bd_intf_net -intf_net microblaze_riscv_0_dlmb [get_bd_intf_pins dlmb_v10/LMB_M] [get_bd_intf_pins DLMB]
  connect_bd_intf_net -intf_net microblaze_riscv_0_dlmb_bus [get_bd_intf_pins dlmb_v10/LMB_Sl_0] [get_bd_intf_pins dlmb_bram_if_cntlr0/SLMB]
  connect_bd_intf_net -intf_net microblaze_riscv_0_dlmb_cntlr [get_bd_intf_pins dlmb_bram_if_cntlr0/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net microblaze_riscv_0_dlmb_cntlr1 [get_bd_intf_pins dlmb_bram_if_cntlr1/BRAM_PORT] [get_bd_intf_pins lmb_bram1/BRAM_PORTA]
  connect_bd_intf_net -intf_net microblaze_riscv_0_ilmb [get_bd_intf_pins ilmb_v10/LMB_M] [get_bd_intf_pins ILMB]
  connect_bd_intf_net -intf_net microblaze_riscv_0_ilmb_bus [get_bd_intf_pins ilmb_v10/LMB_Sl_0] [get_bd_intf_pins ilmb_bram_if_cntlr0/SLMB]
  connect_bd_intf_net -intf_net microblaze_riscv_0_ilmb_cntlr [get_bd_intf_pins ilmb_bram_if_cntlr0/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]
  connect_bd_intf_net -intf_net microblaze_riscv_0_ilmb_cntlr1 [get_bd_intf_pins ilmb_bram_if_cntlr1/BRAM_PORT] [get_bd_intf_pins lmb_bram1/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net SYS_Rst_1  [get_bd_pins SYS_Rst] \
  [get_bd_pins dlmb_v10/SYS_Rst] \
  [get_bd_pins ilmb_v10/SYS_Rst] \
  [get_bd_pins dlmb_bram_if_cntlr0/LMB_Rst] \
  [get_bd_pins dlmb_bram_if_cntlr1/LMB_Rst] \
  [get_bd_pins ilmb_bram_if_cntlr0/LMB_Rst] \
  [get_bd_pins ilmb_bram_if_cntlr1/LMB_Rst]
  connect_bd_net -net microblaze_riscv_0_Clk  [get_bd_pins LMB_Clk] \
  [get_bd_pins dlmb_v10/LMB_Clk] \
  [get_bd_pins ilmb_v10/LMB_Clk] \
  [get_bd_pins dlmb_bram_if_cntlr0/LMB_Clk] \
  [get_bd_pins dlmb_bram_if_cntlr1/LMB_Clk] \
  [get_bd_pins ilmb_bram_if_cntlr0/LMB_Clk] \
  [get_bd_pins ilmb_bram_if_cntlr1/LMB_Clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}
  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set sys_diff_clock [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_diff_clock ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   ] $sys_diff_clock

  set push_buttons [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 push_buttons ]

  set DIP [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 DIP ]

  set iic_acl_main [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic_acl_main ]

  set scu35_uartb [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 scu35_uartb ]

  set iic_eeprom_main [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic_eeprom_main ]

  set iic_ina_main [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic_ina_main ]

  set LEDs [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 LEDs ]

  set PMOD_i [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 PMOD_i ]

  set mii [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mii_rtl:1.0 mii ]

  set mdio_mdc [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_mdc ]


  # Create ports
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $reset

  # Create instance: microblaze_riscv_0, and set properties
  set microblaze_riscv_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze_riscv microblaze_riscv_0 ]
  set_property -dict [list \
    CONFIG.C_DEBUG_ENABLED {1} \
    CONFIG.C_D_AXI {1} \
    CONFIG.C_D_LMB {1} \
    CONFIG.C_ILL_INSTR_EXCEPTION {1} \
    CONFIG.C_I_LMB {1} \
    CONFIG.C_OPTIMIZATION {1} \
    CONFIG.C_USE_COMPRESSION {1} \
    CONFIG.C_USE_MULDIV {2} \
    CONFIG.G_TEMPLATE_LIST {1} \
  ] $microblaze_riscv_0


  # Create instance: microblaze_riscv_0_local_memory
  create_hier_cell_microblaze_riscv_0_local_memory [current_bd_instance .] microblaze_riscv_0_local_memory

  # Create instance: microblaze_riscv_0_axi_intc, and set properties
  set microblaze_riscv_0_axi_intc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc microblaze_riscv_0_axi_intc ]
  set_property -dict [list \
    CONFIG.C_DISABLE_SYNCHRONIZERS {0} \
    CONFIG.C_HAS_FAST {0} \
    CONFIG.C_MB_CLK_NOT_CONNECTED {0} \
  ] $microblaze_riscv_0_axi_intc


  # Create instance: microblaze_riscv_0_concat, and set properties
  set microblaze_riscv_0_concat [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat microblaze_riscv_0_concat ]
  set_property CONFIG.NUM_PORTS {7} $microblaze_riscv_0_concat


  # Create instance: mdm_1, and set properties
  set mdm_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm_riscv mdm_1 ]

  # Create instance: peripherals
  create_hier_cell_peripherals [current_bd_instance .] peripherals

  # Create instance: clk_rst
  create_hier_cell_clk_rst [current_bd_instance .] clk_rst

  # Create interface connections
  connect_bd_intf_net -intf_net microblaze_riscv_0_M_AXI_DP [get_bd_intf_pins microblaze_riscv_0/M_AXI_DP] [get_bd_intf_pins peripherals/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_riscv_0_debug [get_bd_intf_pins mdm_1/MBDEBUG_0] [get_bd_intf_pins microblaze_riscv_0/DEBUG]
  connect_bd_intf_net -intf_net microblaze_riscv_0_dlmb_1 [get_bd_intf_pins microblaze_riscv_0/DLMB] [get_bd_intf_pins microblaze_riscv_0_local_memory/DLMB]
  connect_bd_intf_net -intf_net microblaze_riscv_0_ilmb_1 [get_bd_intf_pins microblaze_riscv_0/ILMB] [get_bd_intf_pins microblaze_riscv_0_local_memory/ILMB]
  connect_bd_intf_net -intf_net microblaze_riscv_0_interrupt [get_bd_intf_pins microblaze_riscv_0_axi_intc/interrupt] [get_bd_intf_pins microblaze_riscv_0/INTERRUPT]
  connect_bd_intf_net -intf_net peripherals_DIP [get_bd_intf_ports DIP] [get_bd_intf_pins peripherals/DIP]
  connect_bd_intf_net -intf_net peripherals_LEDs [get_bd_intf_ports LEDs] [get_bd_intf_pins peripherals/LEDs]
  connect_bd_intf_net -intf_net peripherals_M00_AXI [get_bd_intf_pins microblaze_riscv_0_axi_intc/s_axi] [get_bd_intf_pins peripherals/M00_AXI]
  connect_bd_intf_net -intf_net peripherals_PMOD_i [get_bd_intf_ports PMOD_i] [get_bd_intf_pins peripherals/PMOD_i]
  connect_bd_intf_net -intf_net peripherals_iic_acl_main [get_bd_intf_ports iic_acl_main] [get_bd_intf_pins peripherals/iic_acl_main]
  connect_bd_intf_net -intf_net peripherals_iic_eeprom_main [get_bd_intf_ports iic_eeprom_main] [get_bd_intf_pins peripherals/iic_eeprom_main]
  connect_bd_intf_net -intf_net peripherals_iic_ina_main [get_bd_intf_ports iic_ina_main] [get_bd_intf_pins peripherals/iic_ina_main]
  connect_bd_intf_net -intf_net peripherals_mdio_mdc [get_bd_intf_ports mdio_mdc] [get_bd_intf_pins peripherals/mdio_mdc]
  connect_bd_intf_net -intf_net peripherals_mii [get_bd_intf_ports mii] [get_bd_intf_pins peripherals/mii]
  connect_bd_intf_net -intf_net peripherals_push_buttons [get_bd_intf_ports push_buttons] [get_bd_intf_pins peripherals/push_buttons]
  connect_bd_intf_net -intf_net peripherals_scu35_uartb [get_bd_intf_ports scu35_uartb] [get_bd_intf_pins peripherals/scu35_uartb]
  connect_bd_intf_net -intf_net sys_diff_clock_1 [get_bd_intf_ports sys_diff_clock] [get_bd_intf_pins clk_rst/sys_diff_clock]

  # Create port connections
  connect_bd_net -net SYS_Rst_1  [get_bd_pins clk_rst/bus_struct_reset] \
  [get_bd_pins microblaze_riscv_0_local_memory/SYS_Rst]
  connect_bd_net -net clk_rst_mb_reset  [get_bd_pins clk_rst/mb_reset] \
  [get_bd_pins microblaze_riscv_0/Reset]
  connect_bd_net -net ext_spi_clk_1  [get_bd_pins clk_rst/clk_out2] \
  [get_bd_pins peripherals/ext_spi_clk]
  connect_bd_net -net mdm_1_Debug_SYS_Rst  [get_bd_pins mdm_1/Debug_SYS_Rst] \
  [get_bd_pins clk_rst/mb_debug_sys_rst]
  connect_bd_net -net microblaze_riscv_0_Clk  [get_bd_pins clk_rst/clk_out1] \
  [get_bd_pins microblaze_riscv_0_local_memory/LMB_Clk] \
  [get_bd_pins peripherals/s_axi_aclk] \
  [get_bd_pins microblaze_riscv_0/Clk] \
  [get_bd_pins microblaze_riscv_0_axi_intc/s_axi_aclk]
  connect_bd_net -net microblaze_riscv_0_intr  [get_bd_pins microblaze_riscv_0_concat/dout] \
  [get_bd_pins microblaze_riscv_0_axi_intc/intr]
  connect_bd_net -net peripherals_iic2intc_irpt  [get_bd_pins peripherals/irpt_iic_acl] \
  [get_bd_pins microblaze_riscv_0_concat/In2]
  connect_bd_net -net peripherals_iic2intc_irpt1  [get_bd_pins peripherals/irpt_iic_eeprom] \
  [get_bd_pins microblaze_riscv_0_concat/In3]
  connect_bd_net -net peripherals_iic2intc_irpt2  [get_bd_pins peripherals/irpt_iic_ina] \
  [get_bd_pins microblaze_riscv_0_concat/In4]
  connect_bd_net -net peripherals_interrupt  [get_bd_pins peripherals/irpt_timer] \
  [get_bd_pins microblaze_riscv_0_concat/In1]
  connect_bd_net -net peripherals_interrupt1  [get_bd_pins peripherals/irpt_uart0] \
  [get_bd_pins microblaze_riscv_0_concat/In0]
  connect_bd_net -net peripherals_ip2intc_irpt  [get_bd_pins peripherals/irpt_eth] \
  [get_bd_pins microblaze_riscv_0_concat/In6]
  connect_bd_net -net peripherals_ip2intc_irpt1  [get_bd_pins peripherals/irpt_spi_flash] \
  [get_bd_pins microblaze_riscv_0_concat/In5]
  connect_bd_net -net reset_1  [get_bd_ports reset] \
  [get_bd_pins clk_rst/reset]
  connect_bd_net -net rst_clk_wiz_1_100M_peripheral_aresetn  [get_bd_pins clk_rst/peripheral_aresetn] \
  [get_bd_pins peripherals/s_axi_aresetn] \
  [get_bd_pins microblaze_riscv_0_axi_intc/s_axi_aresetn]

  # Create address segments
  assign_bd_address -offset 0x40E00000 -range 0x00020000 -target_address_space [get_bd_addr_spaces microblaze_riscv_0/Data] [get_bd_addr_segs peripherals/axi_ethernetlite_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x40020000 -range 0x00010000 -with_name SEG_axi_gpio_0_Reg -target_address_space [get_bd_addr_spaces microblaze_riscv_0/Data] [get_bd_addr_segs peripherals/gpio_PMOD_i/S_AXI/Reg] -force
  assign_bd_address -offset 0x44A00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_riscv_0/Data] [get_bd_addr_segs peripherals/axi_quad_spi_0/AXI_LITE/Reg] -force
  assign_bd_address -offset 0x41C00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_riscv_0/Data] [get_bd_addr_segs peripherals/axi_timer_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x40600000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_riscv_0/Data] [get_bd_addr_segs peripherals/axi_uartlite_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x00020000 -range 0x00008000 -target_address_space [get_bd_addr_spaces microblaze_riscv_0/Data] [get_bd_addr_segs microblaze_riscv_0_local_memory/dlmb_bram_if_cntlr1/SLMB/Mem] -force
  assign_bd_address -offset 0x00000000 -range 0x00020000 -with_name SEG_dlmb_bram_if_cntlr_Mem -target_address_space [get_bd_addr_spaces microblaze_riscv_0/Data] [get_bd_addr_segs microblaze_riscv_0_local_memory/dlmb_bram_if_cntlr0/SLMB/Mem] -force
  assign_bd_address -offset 0x40000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_riscv_0/Data] [get_bd_addr_segs peripherals/gpio_LEDs/S_AXI/Reg] -force
  assign_bd_address -offset 0x40010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_riscv_0/Data] [get_bd_addr_segs peripherals/gpio_pushB_DIP/S_AXI/Reg] -force
  assign_bd_address -offset 0x40800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_riscv_0/Data] [get_bd_addr_segs peripherals/iic_acl/S_AXI/Reg] -force
  assign_bd_address -offset 0x40810000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_riscv_0/Data] [get_bd_addr_segs peripherals/iic_eeprom/S_AXI/Reg] -force
  assign_bd_address -offset 0x40820000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_riscv_0/Data] [get_bd_addr_segs peripherals/iic_ina/S_AXI/Reg] -force
  assign_bd_address -offset 0x41200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_riscv_0/Data] [get_bd_addr_segs microblaze_riscv_0_axi_intc/S_AXI/Reg] -force
  assign_bd_address -offset 0x00020000 -range 0x00008000 -target_address_space [get_bd_addr_spaces microblaze_riscv_0/Instruction] [get_bd_addr_segs microblaze_riscv_0_local_memory/ilmb_bram_if_cntlr1/SLMB/Mem] -force
  assign_bd_address -offset 0x00000000 -range 0x00020000 -with_name SEG_ilmb_bram_if_cntlr_Mem -target_address_space [get_bd_addr_spaces microblaze_riscv_0/Instruction] [get_bd_addr_segs microblaze_riscv_0_local_memory/ilmb_bram_if_cntlr0/SLMB/Mem] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
  close_bd_design $design_name 
}
# End of cr_bd_system()
