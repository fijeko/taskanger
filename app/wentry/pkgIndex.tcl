if {[namespace exists ::freewrap] && $::freewrap::runMode eq "wrappedExec"} {
  package ifneeded wentry 1.0 [list source [zvfs::list */app/*/wentry.tcl]]
} else {
  package ifneeded wentry 1.0 [list source [file join $dir wentry.tcl]]
}
