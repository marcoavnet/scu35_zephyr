<!--
Copyright (c) 2026 Marco Höfle, Avnet-Silica

Permission is hereby granted, free of charge, to any person obtaining a copy
of this documentation and associated files, to use, copy, modify, and distribute
it, subject to the inclusion of this copyright notice.

THE DOCUMENTATION IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
-->

# Avnet Silica Zephyr Technical Reference Design

Build the Vivado hardware project, generate a system device tree, and build and run Zephyr applications on MicroBlaze V (RISC-V).

The workshop uses Vivado/Vitis 2026.1, the AMD Zephyr branch `xlnx_rel_v2026.1`, and Zephyr SDK 0.16.8. The Zephyr board target is `mbv32`, and the hardware processor instance is `microblaze_riscv_0`.

## Prerequisites

- A Linux x86-64 host with Bash.
- Vivado and Vitis 2026.1, with XSDB available.
- Git, Make, Python 3 with virtual environment support, `wget`, `pv`, and `tar` with XZ support.
- `tio` for the serial console and VS Code for the optional editor workflow.
- The workshop project sources and the target board connected for programming and serial access.

Run the following steps in order. Unless a block is explicitly marked as an XSDB or Zephyr shell command, run it in your host terminal.

## 1. Set up the environment

From the **project root directory**, set the environment variables:

```bash
export TRD_HOME="$PWD"
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_SDK_INSTALL_DIR="$TRD_HOME/sw/dow/zephyr-sdk-0.16.8"
export ZEPHYR_BASE="$TRD_HOME/sw/dow/zephyr"
```

Load the Vivado environment. Adjust the installation path if necessary:

```bash
source /opt/Xilinx/2026.1/Vivado/settings64.sh
```


## 2. Build the hardware

### Create the Vivado project and export the hardware

Generate the project, build the bitstream, and export the XSA file:

```bash
cd "$TRD_HOME/vivado"
make
```

### Generate the system device tree

```bash
cd "$TRD_HOME/vivado/build"
vitis -s "$TRD_HOME/vivado/tools/create_sdt.py" \
    --xsa ./prj/scu35_zephyr.xsa \
    --cpu microblaze_riscv_0 \
    --outdir sdt
```

The generated device tree is used to configure the Zephyr hardware description in the next step.

## 3. Set up Zephyr

### Download the SDK and clone the Zephyr sources

Download the minimal SDK and its RISC-V toolchain, then clone the AMD Zephyr sources:

```bash
mkdir -p "$TRD_HOME/sw/dow"
cd "$TRD_HOME/sw/dow"

wget -qO- https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.8/zephyr-sdk-0.16.8_linux-x86_64_minimal.tar.xz \
    | pv | tar -xJ

wget -qO- https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.8/toolchain_linux-x86_64_riscv64-zephyr-elf.tar.xz \
    | pv | tar -xJ -C zephyr-sdk-0.16.8/

git clone https://github.com/Xilinx/zephyr-amd.git \
    -b xlnx_rel_v2026.1 zephyr
```

### Create the Python virtual environment

```bash
mkdir -p "$TRD_HOME/sw/bld"
cd "$TRD_HOME/sw/bld"

python3 -m venv zephyr-venv
source zephyr-venv/bin/activate
python -m pip install ninja
python -m pip install -r "$ZEPHYR_BASE/scripts/requirements.txt"
```

To reactivate this environment later:

```bash
source "$TRD_HOME/sw/bld/zephyr-venv/bin/activate"
```

### Fetch the Zephyr modules and process the device tree

Initialize the west workspace, download its modules, and install Lopper:

```bash
cd "$ZEPHYR_BASE"
west init -l .
west update
west lopper-install
```

Process the generated system device tree for `microblaze_riscv_0`:

```bash
LOPPER_DTC_FLAGS="-b 0 -@" west lopper-command \
    -p microblaze_riscv_0 \
    -s "$TRD_HOME/vivado/build/sdt/sdt_platform/export/sdt_platform/hw/sdt/system-top.dts" \
    -w .
```
cd $ZEPHYR_BASE
west build -p always -b mbv32 samples/hello_world --build-dir $TRD_HOME/sw/bld/hello
west build -t ram_report --build-dir $TRD_HOME/sw/bld/hello

## 4. Build the applications

Run the builds from the Zephyr source directory with the Python virtual environment active:

```bash
cd "$ZEPHYR_BASE"
```

Each example uses a separate build directory. The `-p always` option performs a pristine build, and `ram_report` displays RAM usage.

### Hello World

```bash
west build -p always -b mbv32 samples/hello_world \
    --build-dir "$TRD_HOME/sw/bld/hello"
west build -t ram_report --build-dir "$TRD_HOME/sw/bld/hello"
```
west build -p always -b mbv32 $TRD_HOME/sw/src/myapp --build-dir $TRD_HOME/sw/bld/my_app
west build -t ram_report --build-dir $TRD_HOME/sw/bld/my_app

### Zephyr shell sample

```bash
west build -p always -b mbv32 samples/subsys/shell/shell_module/ \
    --build-dir "$TRD_HOME/sw/bld/shell_example"
west build -t ram_report --build-dir "$TRD_HOME/sw/bld/shell_example"
```

### Workshop application: `myapp`

```bash
west build -p always -b mbv32 "$TRD_HOME/sw/src/myapp" \
    --build-dir "$TRD_HOME/sw/bld/my_app"
west build -t ram_report --build-dir "$TRD_HOME/sw/bld/my_app"
```

### Workshop shell application: `myapp_shell`

```bash
west build -p always -b mbv32 "$TRD_HOME/sw/src/myapp_shell" \
    --build-dir "$TRD_HOME/sw/bld/myapp_shell"
west build -t ram_report --build-dir "$TRD_HOME/sw/bld/myapp_shell"
```

## 5. Program the board and run the application

Start XSDB from the terminal where `TRD_HOME` is exported:

```bash
xsdb
```

At the **XSDB prompt**, import the project path from the host environment, connect, program the device, and list the available targets:

```tcl
set TRD_HOME $::env(TRD_HOME)
connect
device program "$TRD_HOME/vivado/build/prj/scu35_zephyr.runs/impl_1/system_wrapper.pdi"
targets
```

Select the MicroBlaze V processor. The example below uses target `4`; replace it with the processor target ID shown by `targets`. Then reset the processor, download the shell application, and start execution:

```tcl
target 4
rst
dow "$TRD_HOME/sw/bld/myapp_shell/zephyr/zephyr.elf"
con
```

To run another application, use the `zephyr/zephyr.elf` file from its build directory.

### Open the serial console

In a separate host terminal, connect to the board's first UART at 115200 baud. Adjust `/dev/ttyUSB1` to match your system:

```bash
tio /dev/ttyUSB1 -b 115200
```

### Try the workshop shell commands

Enter these commands at the **Zephyr shell prompt** when running `myapp_shell`.

Show available commands, devices, and kernel information:

```text
help
device list
kernel version
kernel thread list
```

Control the LED and read the EEPROM:

```text
led on
led off
eeprom read eeprom0 0 0x100
```

Access the flash. The `flash test` and `flash write` commands modify flash contents:

```text
flash read flash@0 0 100
flash test flash@0 0 0x1000 10
flash write flash@0 0 0x00000000 0x00000000 0x00000000 0x00000000
```

## 6. Build from VS Code

1. Select **File → Open Folder…** and open `$TRD_HOME/sw`.
2. Select **Terminal → Run Task… → Zephyr: clean rebuild** to build the application.
3. Select **Terminal → Run Task… → Zephyr: ram report** to inspect RAM usage.

## Appendix: OpenOCD setup — not working yet

The OpenOCD setup below is retained for experimentation. Use XSDB for the workshop programming flow.

```bash
export OPENOCD_HOME="$TRD_HOME/tools/openocd"
mkdir -p "$OPENOCD_HOME"/{src,bld,install}

git clone https://github.com/openocd-org/openocd.git "$OPENOCD_HOME/src"
cd "$OPENOCD_HOME/src"

./bootstrap
./configure --prefix="$OPENOCD_HOME/install" --enable-ftdi
make -j16
make install

export OPENOCD_BIN="$TRD_HOME/tools/openocd/install/bin/openocd"
```
