if {[namespace exists ::freewrap] && $::freewrap::runMode eq "wrappedExec"} {
  package ifneeded wscroll 1.0 [list source [zvfs::list */app/*/wscroll.tcl]]
} else {
  package ifneeded wscroll 1.0 [list source [file join $dir wscroll.tcl]]
}
