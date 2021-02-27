if {[namespace exists ::freewrap] && $::freewrap::runMode eq "wrappedExec"} {
  package ifneeded domain 1.0 [list source [zvfs::list */app/*/domain.tcl]]
} else {
  package ifneeded domain 1.0 [list source [file join $dir domain.tcl]]
}
