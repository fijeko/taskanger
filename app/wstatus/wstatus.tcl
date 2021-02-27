# status bar with two labels
# first label temporary replace tooltip
#   its -textvariable show button -text when mouse hover over button
# second label show errors
# 
# paths 
# .status 
# .status.info
# .status.error
#
# 'public' procedures
# draw 
# draw status bar in .status

package provide wstatus 1.0

package require Tcl 8.6
package require Tk  8.6


namespace eval wstatus {
  variable info ""
  variable error ""
  variable Wdg .status
  
  bind Button <Enter> [namespace code {
    set info [%W cget -text]
    ::tk::ButtonEnter %W
  }]
  bind Button <Leave> [namespace code {
    set info {}
    ::tk::ButtonLeave %W
  }]
}

proc ::wstatus::draw {} {
  variable ::gi::W
  variable ::gi::PM
  
  grid [frame .status]
  pack [label .status.info -textvariable [namespace current]::info]
  pack [label .status.error -textvariable [namespace current]::error]
  pack [button .status.about -command "::wstatus::about"]
  pack [button .status.help -command "::help::open"]
}


proc ::wstatus::about {} {
  tk_messageBox -title "About Taskanger" -icon info -type ok -parent . \
    -message "taskanger $::TSKNGR_VERSION" -detail {
Task manager written in Tcl/Tk.

MIT License

Copyright © Ivana Krivić
<ivanakri@zoho.com>
}
}
