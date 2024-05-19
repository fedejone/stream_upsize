SET PATH=%VIVADO_ROOTDIR_19_2%\bin;%PATH%
hdlmake
make mrproper
@pause
make synthesize
@pause
