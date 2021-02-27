package require Tcl     8.6
package require Tk      8.6
package require gi      1.0
package require wscroll 1.0
package require help    1.0

source [file join $::TSKNGR_APPDIR todo.tcl]
source [file join $::TSKNGR_APPDIR task.tcl]
source [file join $::TSKNGR_APPDIR thema.tcl]

namespace eval ::frames {
  bind . <Control-Q> [namespace code {ExitApp}]
  bind . <Control-q> [namespace code {ExitApp}]
  bind all <<PrevWindow>> [namespace code { ::frames::Walk %W prev }]
  bind all <<NextWindow>> [namespace code { ::frames::Walk %W next }]
  
  wm protocol . WM_DELETE_WINDOW [namespace code {ExitApp}]
  wm iconphoto . -default $::gi::ICO(placeholder)
}

proc ::frames::run {dbname} {
  wm minsize . 1192 628
  ::frames::draw
  ::todo::draw .1.1 .1.0.scroll
  ::task::draw .2.1 .2.0.scroll
  ::thema::draw .3.1 .3.0.scroll
  
  ::domain::connect $dbname ::wstatus::error
  ::todo::load  [::domain::TodoLista]
  ::task::load  [::domain::TaskLista]
  ::thema::load [::domain::ThemaLista]
}

proc ::frames::draw {} {
  grid [frame .1] [frame .2] [frame .3]
  ::wstatus::draw
  ::wscroll::draw .1.0
  ::wscroll::draw .2.0
  ::wscroll::draw .3.0
  
  pack [frame .1.1 -height 40] -side bottom
  pack [frame .2.1 -height 40] -side bottom
  pack [frame .3.1 -height 40] -side bottom
}

# called from tab shift-tab event <<NextWindow>> <<PrevWindow>>
# change focus to next / previous focusable window
proc ::frames::Walk {wdg direction} {
  
  set walkSet {}
  if [namespace exists ::todo] {
    lappend walkSet {*}[::todo::Walk]
  }
  if [namespace exists ::task] {
    lappend walkSet {*}[::task::Walk]
  }
  if [namespace exists ::thema] {
    lappend walkSet {*}[::thema::Walk]
  }
  lappend walkSet .status.help
  
  set index [lsearch -exact $walkSet $wdg]
#~ puts "$index $walkSet"
  if {$direction eq "prev"} {
    if {$index <= 0} {
      set index [llength $walkSet]
    }
    incr index -1
  } elseif {$direction eq "next"} {
    incr index
    if {$index == [llength $walkSet]} {
      set index 0
    }
  }
#~ puts "$index [lindex $walkSet $index]"
  focus [lindex $walkSet $index]
}


# on window manager frame x button or menu exit
# or control-q event
proc ::frames::ExitApp {} {
  focus .
  update
  destroy .
}




