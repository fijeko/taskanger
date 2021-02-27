if {[namespace exists ::freewrap] && $::freewrap::runMode eq "wrappedExec"} {
  package ifneeded wstatus 1.0 [list source [zvfs::list */app/*/wstatus.tcl]]
} else {
  package ifneeded wstatus 1.0 [list source [file join $dir wstatus.tcl]]
}
