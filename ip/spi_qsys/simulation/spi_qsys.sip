set_global_assignment -entity "spi_qsys" -library "lib_spi_qsys" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "spi_qsys" -library "lib_spi_qsys" -name IP_TOOL_VERSION "23.1"
set_global_assignment -entity "spi_qsys" -library "lib_spi_qsys" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_spi_qsys" -name SPD_FILE [file join $::quartus(sip_path) "../spi_qsys.spd"]
set_global_assignment -library "lib_spi_qsys" -name MISC_FILE [file join $::quartus(sip_path) "../../spi_qsys.qsys"]

set_global_assignment -library "lib_spi_qsys" -name MISC_FILE [file join $::quartus(sip_path) "spi_qsys.v"]
set_global_assignment -library "lib_spi_qsys" -name MISC_FILE [file join $::quartus(sip_path) "submodules/spiphyslave.v"]
