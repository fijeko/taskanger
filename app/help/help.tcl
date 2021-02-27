# help toplevel widget
# invoke with F1 from aplication

package provide help 1.0


package require Tcl 8.6
package require Tk  8.6
package require gi  1.0


namespace eval help {
  
  bind . <F1> ::help::open
  
  variable Body {
    01  {RightClick}       {pop tools menu for item}
    02  {Alt-b [x button]} {open/close tools menu}
    03  {Alt-t [x button]} {open/close text}
    04  {[+ button]}       {insert new item}
    05  {Ins}              {tasks,theme: insert new item after selected one}
    06  {Enter or Ctrl-s}  {save changes in current item}
    07  {Esc}              {dismiss changes in current item}
    08  {shift-del}        {delete selected item}
    09 {ArrowUp}           {go to previous item is same pane}
    10 {ArrowDown}         {go to next item is same pane}
    11  {Shift-ArrowUp}     {move item up in same range (like same datum)}
    12  {Shift-ArrowDown}   {move item down in same range}
    13  {Ctrl-I}            {insert task child}
    14 {Shift-Right}       {move task item level down}
    15  {Shift-Left}        {move task item level down}
    16  {Alt-d}            {move todo item to today section}
    17  {Alt-s}            {move todo item to tomorow section}
    18  {Alt-u}            {move todo item to 'no datum' section}
    19  {Alt-g}            {move todo item to done section}
    20  {Alt-l}            {in text add link in text}
    21  {Alt-m}            {in text mark text with yellow}
    22  {Alt-u}            {in text underline text}
    23  {atl-n}            {in text remove underline and yellow mark}
    24  {Ctrl-Q}           {quit app}
  }
  
}




proc ::help::open {} {
  variable WMtitle
  variable Title
  variable Body 
  variable ::gi::LBL 
  
  if [winfo exists .help] return
  
  toplevel .help
  wm title .help $LBL(helpwtitle)
  
  pack [label .help.title -text $LBL(helptitle)]
  pack [frame .help.grid] 
  grid columnconfigure .help.grid 0 -weight 0
  grid columnconfigure .help.grid 1 -weight 1
  grid rowconfigure .help.grid all -uniform x
  
  foreach {n c1 c2} $Body {
    label .help.grid.c1$n -text $c1
    label .help.grid.c2$n -text $c2
    grid  .help.grid.c1$n  .help.grid.c2$n
  }
}


