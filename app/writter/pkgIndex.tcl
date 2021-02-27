if {[namespace exists ::freewrap] && $::freewrap::runMode eq "wrappedExec"} {
  package ifneeded writter 1.0 [list source [zvfs::list */app/*/writter.tcl]]
} else {
  package ifneeded writter 1.0 [list source [file join $dir writter.tcl]]
}
