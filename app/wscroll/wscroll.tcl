# widget that can scroll when mouse wheell
#
# paths 
# .P.0          frame pack
# .P.0.scroll   frame place
#
# scroll window scroll (change place -y) in its parent when 
#  'MouseWheel' event ocure on its descendant
#
# 'public' procedures
# draw place $path.0.scroll into $path
#
# VerticalCenter w
# re-place scroll window in its parent 
# so that window in argument is verticaly centered in Pane
#

package provide wscroll 1.0

package require Tcl 8.6
package require Tk  8.6
package require gi  1.0


namespace eval wscroll {
  #~ variable Wdg 
  
  # mouse scrolling that re-place Scrollertrick widget in pane
  if {[tk windowingsystem] eq "x11"} {
    bind . <ButtonPress-4> {::wscroll::Scroll %W +1}
    bind . <ButtonPress-5> {::wscroll::Scroll %W -1}
  } elseif {[tk windowingsystem] eq "aqua"} {
    bind . <MouseWheel> {::wscroll::Scroll %W [expr {-(%D)}]}
    bind . <Option-MouseWheel> {::wscroll::Scroll %W [expr {-10 *(%D)}]}
  } else {
    bind . <MouseWheel> {::wscroll::Scroll %W \
                  [expr {%D>=0 ? (-%D/120) : ((119-%D)/120)}]}
  }
  
  bind . <<VCenter>> {::wscroll::VerticalCenter %d}
}

# ::wscroll::draw
# draw scrollable widget, 
#    two frames, child is placed in parent and can scroll
# path new window name 
proc ::wscroll::draw {path} {
  variable ::gi::CLR
  pack [frame $path]
  place [frame $path.scroll] -in $path
}



#~ place frame with class Scrollertrick on new y position  $dir*10
proc ::wscroll::Scroll {w dir} {
  
  set scrollwin [Find $w]
  if {$scrollwin eq ""} {
    return
  }
  
  set paneW [winfo parent $scrollwin]
  set maxY [winfo height $paneW]
  set delta [expr {$dir*10}]
  
  place $scrollwin -y [Position $scrollwin $delta $maxY]
}

# Veriticaly center Wentry that gain focus
proc ::wscroll::VerticalCenter {w} {
  set scrollwin [Find $w]
  if {$scrollwin eq ""} {
    return
  }
  
  set paneW [winfo parent $scrollwin]
  set maxY [winfo height $paneW]
  set delta [Delta $w $paneW $maxY]
  
  place $scrollwin -y [Position $scrollwin $delta $maxY]
}



proc ::wscroll::Find {win} {
  set w [join [lrange [split $win "."] 0 2] "."]
  if [winfo exists $w.scroll] {
    return $w.scroll
  }
  return
}

# ::wscroll::Delta
#  W  is window under mouse
#  paneW is outer frame of scroller widget
#  maxY is half height of paneW
#  return:
#     distance between $W lower left coner y value 
#     and vertical middle point of pane W
proc ::wscroll::Delta {W paneW maxY} {
  set w $W
  while {"$w" ne "$paneW"} {
    incr curPos [winfo y $w]
    set w [winfo parent $w]
  }
  incr curPos [winfo height $W]
  set newPos [expr {($maxY / 2) - $curPos}]
  
  return $newPos
}

# ::wscroll::Position
# SW inner scroll window 
# delta  movement positive - down, negative - up
# maxY  height of outer scroll window
#   return new window position so that 
#    window is all visible and thera are no extra space in scroller visible
proc ::wscroll::Position {SW delta maxY} {
  
  set scrlCurPos [dict get [place info $SW] -y]
  set scrlCurHgh [winfo height $SW]
  
  set scrlNewPos [expr {$scrlCurPos+$delta}]
  set scrlNewPos2 [expr {$scrlNewPos+$scrlCurHgh}]
  
  if {$scrlNewPos2 < $maxY} {
    set scrlNewPos [expr {$maxY-$scrlCurHgh}]
  }
  if {$scrlNewPos > 0} {
    set scrlNewPos 0
  }
  return $scrlNewPos
}




