source do_get_project_settings.cmd
readelf -s ../exe/${bootloader_elf_base}.elf  |perl -ne 'if(/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) { print $3 . " " . $8. "\n";}'|sort -n