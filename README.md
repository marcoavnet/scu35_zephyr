<!--
Copyright (c) 2026 Marco Höfle, Avnet-Silica

Permission is hereby granted, free of charge, to any person obtaining a copy
of this documentation and associated files, to use, copy, modify, and distribute
it, subject to the inclusion of this copyright notice.

THE DOCUMENTATION IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
-->


# AVS Zephyr example


# Initial

**1) Set TRD_HOME, ensure that the current working directory is at the project root folder**
```
export TRD_HOME=$PWD
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export ZEPHYR_SDK_INSTALL_DIR=$TRD_HOME/sw/tools/zephyr-sdk-0.16.8
```

**2) Source tools:**
```
source /opt/Xilinx/2025.2/Vivado/settings64.sh
```


# Building the Vivado Project

**1) change the directory**
```
cd $TRD_HOME/vivado
```

**2) generate the project, build the bitstream and export the XSA file for petalinux**
```
make
```

**3) generate the system device tree**
```
cd $TRD_HOME/vivado/build
vitis -s $TRD_HOME/vivado/tools/create_sdt.py --xsa ./prj/scu35_zephyr.xsa --cpu microblaze_riscv_0 --outdir sdt
```


# Zephyr Build

**1) Clone Zephyr sources and the SDK**
```
mkdir $TRD_HOME/sw/tools && cd $TRD_HOME/sw/tools
wget -qO- https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.8/zephyr-sdk-0.16.8_linux-x86_64_minimal.tar.xz | pv | tar -xJ
wget -qO- https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.8/toolchain_linux-x86_64_riscv64-zephyr-elf.tar.xz | pv | tar -xJ -C zephyr-sdk-0.16.8/

cd $TRD_HOME/sw/src/
mkdir kernel && cd kernel
git clone https://github.com/Xilinx/zephyr-amd.git -b xlnx_rel_v2026.1 zephyr
```

**2) Install python virtual environment and tools**
```
mkdir $TRD_HOME/sw/bld && cd $TRD_HOME/sw/bld
python3 -m venv zephyr-venv
source zephyr-venv/bin/activate
pip install west
pip install ninja
pip install -r $TRD_HOME/sw/src/kernel/zephyr/scripts/requirements.txt
```


**3) Get Zephyr module sources**
```
cd $TRD_HOME/sw/src/kernel
west init -l zephyr
west update
cd zephyr
west lopper-install
LOPPER_DTC_FLAGS="-b 0 -@" west lopper-command -p microblaze_riscv_0 -s $TRD_HOME/vivado/build/sdt/sdt_platform/export/sdt_platform/hw/sdt/system-top.dts -w .
```

**4) Build examples**
```
west build -p always -b mbv32 samples/hello_world --build-dir $TRD_HOME/sw/bld/hello
west build -t ram_report --build-dir $TRD_HOME/sw/bld/hello

west build -p always -b mbv32 samples/subsys/shell/shell_module/ --build-dir $TRD_HOME/sw/bld/shell_example
west build -t ram_report --build-dir $TRD_HOME/sw/bld/shell_example
```

**5) build own application**
```
west build -p always -b mbv32 $TRD_HOME/sw/src/myapp --build-dir $TRD_HOME/sw/bld/my_app
west build -t ram_report --build-dir $TRD_HOME/sw/bld/my_app

west build -p always -b mbv32 $TRD_HOME/sw/src/myapp_shell --build-dir $TRD_HOME/sw/bld/myapp_shell
west build -t ram_report --build-dir $TRD_HOME/sw/bld/myapp_shell
```

**6) Download using xsdb**
```
xsdb
connect
dev -p $TRD_HOME/vivado/build/prj/scu35_zephyr.runs/impl_1/system_wrapper.pdi
targets
target 4
dow $TRD_HOME/sw/bld/myapp_shell/zephyr/zephyr.elf
con
```

# Custom Shell Example Use
```
help
device list
kernel version
kernel thread list
flash test flash@0 0 0x1000 10
led on
led off
```

# VS Code Integration
In VS Code select "File->Open Folder..." and point to the $TRD_HOME/sw folder.
Build the application:
Terminal->Run Task...->Zephyr: clean rebuild
Terminal->Run Task...->Zephyr: ram report


# openocd (not working yet)
export OPENOCD_HOME=$TRD_HOME/tools/openocd
mkdir -p "$OPENOCD_HOME"/{src,bld,install}
git clone https://github.com/openocd-org/openocd.git "$OPENOCD_HOME/src"
cd "$OPENOCD_HOME/src"
./bootstrap
./configure --prefix="$OPENOCD_HOME/install" --enable-ftdi
make -j16
make install

export OPENOCD_BIN=$TRD_HOME/tools/openocd/install/bin/openocd
