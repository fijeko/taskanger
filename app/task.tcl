# panel with tasks organized in tree
#
#~ pats
#~ .2                           frames
#~ .2.1                   
#~ .2.1.i              
#~ .2.1.i.insert                button            
#~ .2.0                         
#~ .2.0.scroll                  ::task::Pane, place manager
#~ .2.0.scroll.lst               
#~ .2.0.scroll.lst.n            rowid - wentry
#~ .2.0.scroll.lst.n.lst.n....   tree 
#
# 'public' procs
#  draw path
#  load tasks  
# 
#
# buttons command
#   InsertDatum    calendar callback proc (OK CAncel)
#
# bindings on Todo called from wentry on Todo widget
#   <<Save>>         Save %W %d
#   <<Delete>>       Delete      %W
#   <<Moveup>>       Moveup      %W
#   <<Movedn>>       Movedn      %W 
#   <<Insert>>       Insert      %W
#   <<InsChild>>     InsertChild %W
#   <<LevelDn>>      LevelDn     %W
#   <<LevelUp>>      LevelUp     %W
#
# bindigs on Wentry - specific for Task
#   <Insert>         <<Insert>>
#   <Control-I>      <<InsChild>>
#   <Shift-Right>    <<LevelDn>>;break  # break prevent invoke bindings on Entry
#   <Shift-Left>     <<LevelUp>>;break  # break prevent invoke bindings on Entry

package require Tcl 8.6
package require Tk  8.6
package require domain  1.0
package require wentry  1.0




namespace eval ::task {
  variable Pane     
  variable PaneIns     
  
  bind Wentry <Shift-Up>   { event generate [winfo parent %W] <<MoveUp>> }
  bind Wentry <Shift-Down> { event generate [winfo parent %W] <<MoveDn>> }
  
  bind Wentry <Shift-Delete> { event generate [winfo parent %W] <<Delete>> }

  bind Wentry <Insert> { event generate [winfo parent %W] <<Insert>> }

  bind Wentry <Control-I> { event generate [winfo parent %W] <<InsChild>> }
  bind Wentry <Control-i> { event generate [winfo parent %W] <<InsChild>> }
  
  bind Wentry <Shift-Right> {event generate [winfo parent %W] <<LevelDn>>;break}
  bind Wentry <Shift-Left> {event generate [winfo parent %W] <<LevelUp>>;break}
  
  
  bind Task <<Save>> [namespace code {Save %W %d}]
  bind Task <<Delete>> [namespace code {Delete %W}]
  bind Task <<MoveDn>> [namespace code {MoveDn %W}]
  bind Task <<MoveUp>> [namespace code {MoveUp %W}]
  bind Task <<Insert>> [namespace code {Insert %W}]
  bind Task <<InsChild>> [namespace code {InsertChild %W}]
  bind Task <<LevelDn>> [namespace code {LevelDn %W}]
  bind Task <<LevelUp>> [namespace code {LevelUp %W}]
}

# draw task frames with $Pane.lst -in Scrollertrick $Pane.s
# and insert button for new task in top level 
proc ::task::draw {path pane} {
  variable Pane
  variable PaneIns
  
  set Pane $pane
  set PaneIns $path
  
  pack [frame $PaneIns.insgap]
  pack [button $PaneIns.insert -command [namespace code {InsertMain}]] 
  
  pack [frame $Pane.lst]
}

# read records from database and draw in frames
proc ::task::load {tasks} {
  variable Pane
  
  foreach {ancestorList value} $tasks {
    set wdg $Pane.lst.[join $ancestorList ".lst."]
    DrawItem $wdg $value {}
  }
}





proc ::task::Save {wdg value} {
  ::domain::updateTask [GetRowid $wdg] $value
}

# insert new item as last in top level
proc ::task::InsertMain {} {
  variable Pane
  
  focus .
  update
  
  set parentId 0
  set rang [GetMaxRang $Pane.lst]
  set rowid [::domain::insertTask $parentId $rang {}]

  set item [SetItemWdg {} $rowid]
  
  DrawItem $item {} {}
  ::wentry::inFocus $item
}

# insert new item after wdg
proc ::task::Insert {wdg} {
  variable Pane
  
  focus .
  update
  
  set parentId [GetParentId $wdg]
  set rang [GetRang $wdg]
  set rowids [GetRowids $wdg]
  incr rang 2

  set rowid [::domain::insertTask $parentId $rang $rowids]
  set item [winfo parent $wdg].$rowid

  DrawItem $item {} $wdg
  ::wentry::inFocus $item
}

# insert new item as last child of wdg
proc ::task::InsertChild {wdg} {
  focus .
  update
  
  set parentId [GetRowid $wdg]
  set rang [GetMaxRang $wdg.lst]
  set rowid [::domain::insertTask $parentId $rang {}]
  set item $wdg.lst.$rowid

  DrawItem $item {} {}
  ::wentry::inFocus $item
}

# delete wdg item 
proc ::task::Delete {wdg} {
  
  focus .
  update
  
  set rowid [winfo name $wdg]
  set rowids [GetRowids $wdg]
  set newFocus [GetNewFocus $wdg]

  ::domain::deleteTask $rowid $rowids 
  
  RemoveItem $wdg 
  ::wentry::inFocus $newFocus
}


proc ::task::MoveDn {wdg} {
  focus .
  update
  
  set rangSet [GetRangSet $wdg]
  set rang [GetRang $wdg]
  
  set sybl [lindex $rangSet $rang+1]
  if {$sybl eq ""} {
    ::wentry::inFocus $wdg
    return
  }
  
  set uprowid [winfo name $wdg]
  set dnrowid [winfo name $sybl]
  ::domain::updateTaskRangs $uprowid $dnrowid
  
  pack $wdg -after $sybl
  ::wentry::inFocus $wdg
}

proc ::task::MoveUp {wdg} {
  focus .
  update
  
  set rangSet [GetRangSet $wdg]
  set rang [GetRang $wdg]
  
  set sybl [lindex $rangSet $rang-1]
  
  if {$sybl eq ""} {
    ::wentry::inFocus $wdg
    return
  }
  
  set uprowid [winfo name $sybl]
  set dnrowid [winfo name $wdg]
  ::domain::updateTaskRangs $uprowid $dnrowid
  
  pack $wdg -before $sybl
  ::wentry::inFocus $wdg
}



# move widget and all its children one level dn
# as child of its previous sybling
# if widget is first in parent do nothing
proc ::task::LevelDn {wdg} {
  focus .
  update
  
  set rang [GetRang $wdg]
  
  if {$rang == 0} {
    # if no previous sybling 
    ::wentry::inFocus $wdg
    return 
  }
  
  set rowid [winfo name $wdg]
  set parent [lindex [GetRangSet $wdg] $rang-1]
  set parentId [winfo name $parent]
  set rang [expr {[llength [pack slaves $parent.lst]] + 1}]
  set rowids [GetRowids $wdg]
  
  ::domain::updateTaskLevels $rowid $parentId $rang $rowids {}
  
  set oldPath [winfo parent $wdg]
  set newPath $parent.lst
  
  foreach {w v} [WdgTree $wdg] {
    DrawItem [string map [list $oldPath $newPath] $w] $v {}
  }
  RemoveItem $wdg
  ::wentry::inFocus $newPath.$rowid
}

# move widget and all its children one level up
# as next sybling of its parent
# if widget is in top level do nothing
proc ::task::LevelUp {wdg} {
  variable Pane
  
  focus .
  update
  
  set sybling [GetParentWdg $wdg]
  if {"$sybling" eq ""} {
    # this is top level
    ::wentry::inFocus $wdg
    return
  }

  set rowid [winfo name $wdg]
  set parentId [GetParentId $sybling]
  set rang [expr {[GetRang $sybling] + 2}]
  set oldRowids [GetRowids $wdg]
  set newRowids [GetRowids $sybling]

  ::domain::updateTaskLevels $rowid $parentId $rang $oldRowids $newRowids

  set oldPath [winfo parent $wdg]
  set newPath [winfo parent $sybling]
#~ puts "$oldPath $newPath"
  set wdgTree [lassign [WdgTree $wdg] newWdg itsValue]

  DrawItem [string map [list $oldPath $newPath] $newWdg] $itsValue $sybling
  foreach {w v} $wdgTree {
    DrawItem [string map [list $oldPath $newPath] $w] $v {}
  }
  RemoveItem $wdg
  ::wentry::inFocus $newPath.$rowid
}

# return list of all descendant of wdg
# to draw in place when wdg change level
proc ::task::WdgTree {wdg} {
  set value [$wdg.entry get]
  
  set parent $wdg
  set index 0
  set children {}
  while true {
    set item [lindex [pack slaves $parent.lst] $index]
    if {$item eq ""} {
      if {$parent eq $wdg} { break }
      set item $parent
      set parent [winfo parent [winfo parent $item]]
      set index [lsearch [pack slaves $parent.lst] $item]
      incr index
    } else {
      lappend children $item [$item.entry get]
      set parent $item
      set index 0
    }
  }
  
  return [linsert $children 0 $wdg $value]
}


# draw task item with wentry buttons bindigs
proc ::task::DrawItem {wdg value sybl} {
  
  if {$sybl eq ""} {
    ::wentry::draw $wdg $value true
  } else {
    ::wentry::draw $wdg $value false
    ::wentry::packWentry $wdg -after $sybl
  }
  bindtags $wdg [concat Task [bindtags $wdg]]
  
  ::wentry::toolButton $wdg delete  {-event Delete}
  ::wentry::toolButton $wdg moveup  {-event MoveUp}
  ::wentry::toolButton $wdg movedn  {-event MoveDn}
  
  ::wentry::toolButton $wdg insert   {-tool tasks -event Insert}
  ::wentry::toolButton $wdg inschild {-tool tasks -event InsChild}
  ::wentry::toolButton $wdg levelup  {-tool tasks -event LevelUp}
  ::wentry::toolButton $wdg leveldn  {-tool tasks -event LevelDn}
  
  ::wentry::listWidget $wdg
  
  set parentWdg [GetParentWdg $wdg]
  if {$parentWdg ne ""} {
    ::wentry::packList $parentWdg
    update
    ::wentry::padWidget $wdg [GetDepth $parentWdg]
  }
}

proc ::task::RemoveItem {wdg} {
  set parent [winfo parent $wdg]
  destroy $wdg
  if ![llength [winfo children $parent]] {
    pack forget $parent
  }
}

# WINDOWS TREE HIERARCHY 

# return integer window name that is rowid or record
proc ::task::GetRowid {wdg} {
  return [winfo name $wdg]
}
# return list of wdg sybling widgets
proc ::task::GetRangSet {wdg} {
  return [pack slaves [winfo parent $wdg]]
}
# return rang of wdg among syblings starting from 0
proc ::task::GetRang {wdg} {
  return  [lsearch -exact [GetRangSet $wdg] $wdg]
}
# return number of children + 1 - rang for new item
proc ::task::GetMaxRang {path} {
  set mr [llength [winfo children $path]]
  incr mr
  return $mr
}
# return wdg pathName from list of ancestors and rowid of item
proc ::task::SetItemWdg {rowids rowid} {
  variable Pane
  
  return [join [list $Pane {*}$rowids $rowid] ".lst."]
}
# return path of list with wentries
proc ::task::GetParentId {wdg} {
  set id [lindex [split $wdg "."] end-2]
  if {$id eq "scroll"} {
    return 0
  } else {
    return $id
  }
}
# return parent wentry or empty string if wdg is top level
proc ::task::GetParentWdg {wdg} {
  variable Pane
  set pw [join [lrange [split $wdg "."] 0 end-2] "."]
  if {"$pw" eq "$Pane"} {
    return {}
  } else {
    return $pw
  }
}
# return list of window names - rowids after wdg
proc ::task::GetRowids {wdg} {
  set rangSet [GetRangSet $wdg] 
  set rang [GetRang $wdg]
   
  set rowids {}
  foreach r [lrange $rangSet $rang+1 end] {
    lappend rowids [winfo name $r]
  }
  return $rowids
}
# return wdgName that can take focus after delete of wdg
proc ::task::GetNewFocus {wdg} {
  variable Pane
  set rangSet [GetRangSet $wdg]
  set rang [GetRang $wdg]
  set focusW [lindex $rangSet $rang+1]
  if {$focusW eq ""} {
    set focusW [lindex $rangSet $rang-1]
  }
  if {$focusW eq ""} {
    set focusW [join [lrange [split $wdg "."] 0 end-2] "."]
  }
  if {$focusW eq $Pane} {
    set focusW {}
  }
  return $focusW
}
# return width of wdg divided by $::gi::TaskPadsize(10) 
# that corespond to depth in tree
proc ::task::GetDepth {wdg} {
  return [llength [lsearch -all [split $wdg "."] "lst"]]
}

# return list of widgets for tab / shift-tab
proc ::task::Walk {} {
  variable Pane
  variable PaneIns
# list all Entries in task pane
  set walkSet {}
  set parent $Pane
  set index 0
  while true {
    set children_list [pack slaves $parent.lst]
    set item [lindex $children_list $index]
    if {$item eq ""} {
      if {$parent eq $Pane} { break }
      set item $parent
      set parent [winfo parent [winfo parent $item]]
      set index [lsearch [pack slaves $parent.lst] $item]
      incr index
    } else {
      #~ lappend walkSet $item
      lappend walkSet {*}[::wentry::walk $item]
      set parent $item
      set index 0
    }
  }
  
  lappend walkSet $PaneIns.insert
  return $walkSet
}
