cd [file dirname [file normalize [info script]]]

set FILES {
    src/design/mcu.v
	src/design/song_reader.v
	src/design/note_player.v
	src/design/sine_reader.v
	src/design/music_player.v
	src/design/song_rom.v
	src/sim/mcu_tb.v
	src/sim/song_reader_tb.v
	src/sim/note_player_tb.v
	src/sim/sine_reader_tb.v
	src/sim/music_player_tb.v
	lab4.runs/impl_1/lab4_top.bit
	lab4.runs/impl_1/lab4_top_timing_summary_routed.rpt
	lab4.runs/synth_1/lab4_top.vds
}

set archive_name "lab4_submission.tar.gz"

file delete -force $archive_name

set tar_command "tar -czf $archive_name"
set failed_files {}
append failed_files "\n                      "

foreach file $FILES {
        if {[file exists $file]} {
                append tar_command " $file"
        } else {
                puts "Warning: File not found - $file"
                append failed_files "$file\n                      "
        }
}


if {[catch {exec {*}$tar_command} result]} {
    puts "Error creating tar archive: $result"
} else {
    puts "\n \n \n \n \n~~~~~~Generated $archive_name. Please make sure that all of your files are in the .tar.gz zip folder. Congrats on finishing!~~~~~~ \n     List of failed files: $failed_files"
}
