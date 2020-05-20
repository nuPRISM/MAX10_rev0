quartus_cpf -c $1\.pof $1\.hexout
nios2-elf-objcopy --verbose -I ihex -O binary $1\.hexout $1\.rbf
