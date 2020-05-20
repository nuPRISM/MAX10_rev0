source do_get_project_settings.cmd
cygstart -v $QUARTUS_ROOTDIR/sopc_builder/bin/qsys-edit ${quartus_project_location_directory}/${main_qsys_filename} --jvm-max-heap-size=${java_heap_size_for_qsys} --project-directory=${quartus_project_location_directory} "$@" &

