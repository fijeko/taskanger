# draw pane with theme and text widget
# pats
# .3                     frames
# .3.1                   
# .3.1.i         
# .3.1.i.insert          button            
# .3.0                   
# .3.0.scroll            ::thema::Pane, place manager
# .3.0.scroll.lst                -in Scrollertrick
# .3.0.scroll.lst.n             rowid - wentry
# .3.0.scroll.lst.n.entry 
#
# .3.0.scroll.lst.n.tool 
# .3.0.scroll.lst.n.tool.1
# .3.0.scroll.lst.n.tool.1.close 
# .3.0.scroll.lst.n.tool.1.escape 
# .3.0.scroll.lst.n.tool.1.update 
# .3.0.scroll.lst.n.tool.1.insert 
# .3.0.scroll.lst.n.tool.1.delete 
# .3.0.scroll.lst.n.tool.1.moveup 
# .3.0.scroll.lst.n.tool.1.movedn 
# .3.0.scroll.lst.n.tool.1.openacl
#
# .3.0.scroll.lst.n.article
# .3.0.scroll.lst.n.article.1 
# .3.0.scroll.lst.n.article.1.save
# .3.0.scroll.lst.n.article.1.mark
# .3.0.scroll.lst.n.article.1.undr
# .3.0.scroll.lst.n.article.1.link
# .3.0.scroll.lst.n.article.1.close
# .3.0.scroll.lst.n.article.0          Text class


package require Tcl 8.6
package require Tk  8.6
package require domain  1.0
package require wentry  1.0

namespace eval ::thema {
  variable Pane
  
  bind Wentry <Shift-Up>   { event generate [winfo parent %W] <<MoveUp>> }
  bind Wentry <Shift-Down> { event generate [winfo parent %W] <<MoveDn>> }
  
  bind Wentry <Shift-Delete> { event generate [winfo parent %W] <<Delete>> }

  bind Wentry <Insert> { event generate [winfo parent %W] <<Insert>> }
  
  bind Thema <<Save>> [namespace code {Save %W %d}]
  bind Thema <<Delete>> [namespace code {Delete %W}]
  bind Thema <<MoveUp>> [namespace code {MoveUp %W}]
  bind Thema <<MoveDn>> [namespace code {MoveDn %W}]
  bind Thema <<Insert>> [namespace code {Insert %W}]
  
  bind Thema <<SaveArticle>> [namespace code {SaveArticle %W %d}]
}


proc ::thema::draw {path pane} {
  variable Pane
  variable PaneIns
  
  set Pane $pane
  set PaneIns $path

  pack [frame $PaneIns.insgap]
  pack [button $PaneIns.insert -command [namespace code {InsertMain}]]
  
  pack [frame $Pane.lst]
}


proc ::thema::load {theme} {
  variable Pane
  foreach {rowid value article tags marks wins} $theme {
    set article [list $article $tags $marks $wins]
    DrawItem $Pane.lst.$rowid $value $article {}
  }
}





proc ::thema::Save {wdg value} {
  set rowid [lindex [split $wdg "."] end]
  ::domain::updateThema $rowid $value  
}


# insert new item as last in top level
proc ::thema::InsertMain {} {
  variable Pane
  
  set parent 0
  set rang [expr [llength [pack slaves $Pane.lst]] + 1]
  set rowid [::domain::insertThema $rang {}]

  set item $Pane.lst.$rowid
  
  DrawItem $item {} {} {}
  ::wentry::inFocus $item
}

# insert new item after wdg
proc ::thema::Insert {wdg} {
  variable Pane

  set rangSet [pack slaves $Pane.lst]
  set rang [lsearch -exact $rangSet $wdg]
  set rowids [GetRowids $rangSet $rang]
  incr rang 2
  set rowid [::domain::insertThema $rang $rowids]
  set item $Pane.lst.$rowid
  
  DrawItem $item {} {} $wdg
  ::wentry::inFocus $item
}


# delete wdg item 
proc ::thema::Delete {wdg} {
  variable Pane

  focus .
  update
  
  set rowid [lindex [split $wdg "."] end]
  
  set rangSet [pack slaves $Pane.lst]
  set rang [lsearch -exact $rangSet $wdg]
  
  set rowids [GetRowids $rangSet $rang]
  set newFocus [GetNewFocus $wdg $rangSet $rang]

  ::domain::deleteThema $rowid $rowids 
  
  destroy $wdg
  ::wentry::inFocus $newFocus
}


proc ::thema::MoveDn {wdg} {
  variable Pane
  focus .
  update
  
  set rangSet [pack slaves $Pane.lst]
  
  set sybl [lindex $rangSet [lsearch -exact $rangSet $wdg]+1]
  if {$sybl eq ""} {
    ::wentry::inFocus $wdg
    return
  }
  
  set uprowid [winfo name $wdg]
  set dnrowid [winfo name $sybl]
  ::domain::updateThemaRangs $uprowid $dnrowid
  
  pack $wdg -after $sybl
  ::wentry::inFocus $wdg
}

proc ::thema::MoveUp {wdg} {
  variable Pane
  focus .
  update
  
  set rangSet [pack slaves $Pane.lst]
  
  set sybl [lindex $rangSet [lsearch -exact $rangSet $wdg]-1]
  if {$sybl eq ""} {
    ::wentry::inFocus $wdg
    return
  }
  
  set uprowid [winfo name $sybl]
  set dnrowid [winfo name $wdg]
  ::domain::updateThemaRangs $uprowid $dnrowid
  
  pack $wdg -before $sybl
  ::wentry::inFocus $wdg
}


proc ::thema::SaveArticle {wdg article} {
  set rowid [lindex [split $wdg "."] end]
  ::domain::updateThemaArticle $rowid {*}$article
}


proc ::thema::DrawItem {wdg value article sybl} {  
  variable ::gi::PM
  
  if {$sybl eq ""} {
    ::wentry::draw $wdg $value true
  } else {
    ::wentry::draw $wdg $value false
    ::wentry::packWentry $wdg -after $sybl
  }
  bindtags $wdg [concat Thema [bindtags $wdg]]

  ::wentry::toolButton $wdg delete  {-event Delete}
  ::wentry::toolButton $wdg moveup  {-event MoveUp}
  ::wentry::toolButton $wdg movedn  {-event MoveDn}
  ::wentry::toolButton $wdg insert  {-event Insert}
  
  ::wentry::articleWidget $wdg $article
}



# WINDOWS TREE HIERARCHY 


# return list of window names - rowids after wdg
proc ::thema::GetRowids {lst rang} {
  
  set rowids {}
  foreach r [lrange $lst $rang+1 end] {
    lappend rowids [winfo name $r]
  }
  return $rowids
}
# return wdgName that can take focus after delete of wdg
proc ::thema::GetNewFocus {wdg lst rang} {
  variable Pane
  
  set focusW [lindex $lst $rang+1]
  if {$focusW eq ""} {
    set focusW [lindex $lst $rang-1]
  }
  if {$focusW eq ""} {
    set focusW [join [lrange [split $wdg "."] 0 end-2] "."]
  }
  if {$focusW eq $Pane} {
    set focusW {}
  }
  return $focusW
}


# return list of widgets for tab / shift-tab
proc ::thema::Walk {} {
  variable Pane
  variable PaneIns
  foreach item [pack slaves $Pane.lst] {
    lappend walkSet {*}[::wentry::walk $item]
  }
  
  lappend walkSet $PaneIns.insert
  return $walkSet
}



