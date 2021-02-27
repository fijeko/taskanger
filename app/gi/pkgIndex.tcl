if {[namespace exists ::freewrap] && $::freewrap::runMode eq "wrappedExec"} {
  package ifneeded gi 1.0 [list source [zvfs::list */app/*/gi.tcl]]
} else {
  package ifneeded gi 1.0 [list source [file join $dir gi.tcl]]
}
