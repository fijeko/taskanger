# this is main file without freewrap 
package require Tcl     8.6
package require Tk      8.6

if {[tk appname "taskanger"] ne "taskanger"} {
  send -async taskanger raise .
  exit
}

set ::TSKNGR_APPDIR [file join [pwd] app]
set ::TSKNGR_WORKDIR [pwd]
lappend  auto_path $::TSKNGR_APPDIR

set ::TSKNGR_VERSION "1.0"

proc ::TskngrError {msg opts {title ERROR}} {
  tk_messageBox -message $msg -title $title
  console show
  puts ===========================
  puts $title
  puts [dict get $opts -errorinfo]
  puts ===========================
}
interp bgerror "" ::TskngrBgerror
proc ::TskngrBgerror {msg opts} {
  ::TskngrError $msg $opts "BACKGROUND ERROR"
}

bind . <F2> {catch {console show}} 

try {
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
  
  if {[info commands console] eq "console"} {
    set ::wstatus::error {use [F2] to open console}
    after 3000 {
      puts "HERE -$::wstatus::error-"
      if {{use [F2] to open console} eq $::wstatus::error} {
        set ::wstatus::error {}
      }
    }
  }
} on error {err opt} {
  ::TskngrError $err $opt "taskanger.tcl try block"
}
