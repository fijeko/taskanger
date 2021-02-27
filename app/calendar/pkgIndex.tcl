if {[namespace exists ::freewrap] && $::freewrap::runMode eq "wrappedExec"} {
  package ifneeded calendar 1.0 [list source [zvfs::list */app/*/calendar.tcl]]
} else {
  package ifneeded calendar 1.0 [list source [file join $dir calendar.tcl]]
}
