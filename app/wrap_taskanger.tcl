# this is main file for create freewrap executable
package require Tcl     8.6
package require Tk      8.6

# force only one application at time
if {[tk appname "taskanger"] ne "taskanger"} {
  send -async taskanger raise .
  exit
}

set ::TSKNGR_APPDIR [file dirname [zvfs::list */wrap_taskanger.tcl]]
set ::TSKNGR_WORKDIR [file dirname [info nameofexecutable]]
foreach apfn [zvfs::list */app/*/pkgIndex.tcl] {
  lappend auto_path [file dirname $apfn]      
}
unset apfn

set ::TSKNGR_VERSION "1.0"


proc ::TskngrError {msg opts {title ERROR}} {
  set log [open [file join $::TSKNGR_WORKDIR shelf.log] {CREAT WRONLY APPEND}]
  puts $log "--$title-------[clock format [clock seconds]]------"
  puts $log [dict get $opts -errorinfo]
  puts $log ----------------------------------------------------
  close $log
}
interp bgerror "" ::TskngrBgerror
proc ::TskngrBgerror {msg opts} {
    ::TskngrError $msg $opts "BACKGROUND ERROR"
}

proc __oldver {} {
  set oldf [file join $::TSKNGR_WORKDIR default.myshelf]
  set newf [file join $::TSKNGR_WORKDIR taskanger.base]
  set rnmf [file join $::TSKNGR_WORKDIR default.myshelf.old]
  if ![file exists $newf] {
    if [file exists $oldf] {
      file copy $oldf $newf
      file rename $oldf $rnmf
    }
  }
}
__oldver

source [file join $::TSKNGR_APPDIR frames.tcl]
::frames::run [file join $::TSKNGR_WORKDIR taskanger.base]
