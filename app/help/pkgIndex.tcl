if {[namespace exists ::freewrap] && $::freewrap::runMode eq "wrappedExec"} {
  package ifneeded help 1.0 [list source [zvfs::list */app/*/help.tcl]]
} else {
  package ifneeded help 1.0 [list source [file join $dir help.tcl]]
}
