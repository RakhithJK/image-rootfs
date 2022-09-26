################################################################################
#
# machine-emulator-tools
#
################################################################################

MACHINE_EMULATOR_TOOLS_VERSION = v0.6.0
MACHINE_EMULATOR_TOOLS_SOURCE = $(MACHINE_EMULATOR_TOOLS_VERSION).tar.gz
MACHINE_EMULATOR_TOOLS_SITE = https://github.com/cartesi/machine-emulator-tools/archive
MACHINE_EMULATOR_TOOLS_LICENSE = Apache-2.0
MACHINE_EMULATOR_TOOLS_LICENSE_FILES = LICENSE
MACHINE_EMULATOR_TOOLS_INSTALL_STAGING = NO

MACHINE_EMULATOR_TOOLS_CARGO_ENV = CC=$(TARGET_CC) CXX=$(TARGET_CXX) CFLAGS="-march=rv64ima -mabi=lp64"
MACHINE_EMULATOR_TOOLS_CARGO_OPTS = -Z build-std=std,core,alloc,panic_abort,proc_macro --release

ifeq ($(BR2_PACKAGE_MACHINE_EMULATOR_TOOLS_YIELD),y)
define BUILD_MACHINE_EMULATOR_TOOLS_YIELD
    $(MAKE) RVCC=$(TARGET_CC) -C $(@D)/linux/htif yield.toolchain
endef
define INSTALL_MACHINE_EMULATOR_TOOLS_YIELD
    $(INSTALL) -D -m 0755 $(@D)/linux/htif/yield $(TARGET_DIR)/opt/cartesi/bin/yield
endef
endif

ifeq ($(BR2_PACKAGE_MACHINE_EMULATOR_TOOLS_IOCTL_ECHO),y)
define BUILD_MACHINE_EMULATOR_TOOLS_IOCTL_ECHO
    $(MAKE) RVCC=$(TARGET_CC) -C $(@D)/linux/rollup/ioctl-echo-loop ioctl-echo-loop.toolchain
endef
define INSTALL_MACHINE_EMULATOR_TOOLS_IOCTL_ECHO
    $(INSTALL) -D -m 0755 $(@D)/linux/rollup/ioctl-echo-loop/ioctl-echo-loop $(TARGET_DIR)/opt/cartesi/bin/ioctl-echo-loop
endef
endif

ifeq ($(BR2_PACKAGE_MACHINE_EMULATOR_TOOLS_ROLLUP),y)
define BUILD_MACHINE_EMULATOR_TOOLS_ROLLUP
    $(MAKE) RVCC=$(TARGET_CC) -C $(@D)/linux/rollup/rollup rollup.toolchain
endef
define INSTALL_MACHINE_EMULATOR_TOOLS_ROLLUP
    $(INSTALL) -D -m 0755 $(@D)/linux/rollup/rollup/rollup $(TARGET_DIR)/opt/cartesi/bin/rollup
endef
endif

ifeq ($(BR2_PACKAGE_MACHINE_EMULATOR_TOOLS_ROLLUP_HTTP_SERVER),y)
define BUILD_MACHINE_EMULATOR_TOOLS_ROLLUP_HTTP_SERVER
    $(MACHINE_EMULATOR_TOOLS_CARGO_ENV) cargo build $(MACHINE_EMULATOR_TOOLS_CARGO_OPTS) --target $(@D)/linux/rollup/http/rollup-http-server/riscv64ima-cartesi-linux-gnu.json --manifest-path $(@D)/linux/rollup/http/rollup-http-server/Cargo.toml
endef
define INSTALL_MACHINE_EMULATOR_TOOLS_ROLLUP_HTTP_SERVER
    $(INSTALL) -D -m 0755 $(@D)/linux/rollup/http/rollup-http-server/target/riscv64ima-cartesi-linux-gnu/release/rollup-http-server $(TARGET_DIR)/opt/cartesi/bin/rollup-http-server
    $(INSTALL) -D -m 0755 $(@D)/linux/utils/rollup-init $(TARGET_DIR)/opt/cartesi/bin/rollup-init
endef
endif

ifeq ($(BR2_PACKAGE_MACHINE_EMULATOR_TOOLS_ECHO_DAPP),y)
define BUILD_MACHINE_EMULATOR_TOOLS_ECHO_DAPP
    $(MACHINE_EMULATOR_TOOLS_CARGO_ENV) cargo build $(MACHINE_EMULATOR_TOOLS_CARGO_OPTS) --target $(@D)/linux/rollup/http/echo-dapp/riscv64ima-cartesi-linux-gnu.json --manifest-path $(@D)/linux/rollup/http/echo-dapp/Cargo.toml
endef
define INSTALL_MACHINE_EMULATOR_TOOLS_ECHO_DAPP
    $(INSTALL) -D -m 0755 $(@D)/linux/rollup/http/echo-dapp/target/riscv64ima-cartesi-linux-gnu/release/echo-dapp $(TARGET_DIR)/opt/cartesi/bin/echo-dapp
endef
endif

MACHINE_EMULATOR_TOOLS_UTILS =

ifeq ($(BR2_PACKAGE_MACHINE_EMULATOR_TOOLS_FLASHDRIVE),y)
MACHINE_EMULATOR_TOOLS_UTILS += flashdrive
endif

ifeq ($(BR2_PACKAGE_MACHINE_EMULATOR_TOOLS_READBE64),y)
MACHINE_EMULATOR_TOOLS_UTILS += readbe64
endif

ifeq ($(BR2_PACKAGE_MACHINE_EMULATOR_TOOLS_WRITEBE64),y)
MACHINE_EMULATOR_TOOLS_UTILS += writebe64
endif

ifneq ($(MACHINE_EMULATOR_TOOLS_UTILS),)
define INSTALL_MACHINE_EMULATOR_UTILS
    for f in $(MACHINE_EMULATOR_TOOLS_UTILS); do \
        $(INSTALL) -D -m 0755 $(@D)/linux/utils/$$f $(TARGET_DIR)/opt/cartesi/bin/$$f ; \
    done
endef
endif

define MACHINE_EMULATOR_TOOLS_BUILD_CMDS
    $(BUILD_MACHINE_EMULATOR_TOOLS_YIELD)
    $(BUILD_MACHINE_EMULATOR_TOOLS_IOCTL_ECHO)
    $(BUILD_MACHINE_EMULATOR_TOOLS_ROLLUP)
    $(BUILD_MACHINE_EMULATOR_TOOLS_ROLLUP_HTTP_SERVER)
    $(BUILD_MACHINE_EMULATOR_TOOLS_ECHO_DAPP)
endef

define MACHINE_EMULATOR_TOOLS_INSTALL_TARGET_CMDS
    $(INSTALL_MACHINE_EMULATOR_TOOLS_YIELD)
    $(INSTALL_MACHINE_EMULATOR_TOOLS_IOCTL_ECHO)
    $(INSTALL_MACHINE_EMULATOR_TOOLS_ROLLUP)
    $(INSTALL_MACHINE_EMULATOR_TOOLS_ROLLUP_HTTP_SERVER)
    $(INSTALL_MACHINE_EMULATOR_TOOLS_ECHO_DAPP)
    $(INSTALL_MACHINE_EMULATOR_UTILS)
endef

$(eval $(generic-package))