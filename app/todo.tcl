# panel with todos separate in sections and datums
#
# pahts
#  .1                            frames
#  .1.0                   
#  .1.0.scroll                   ::todo::Pane, place manager
#  .1.0.scroll.N                 
#  .1.0.scroll.N.tool.accordion
#  .1.0.scroll.N.tool.insert     sections 2(today) 3(tomorow) 4(ever) 5(future)
#  .1.0.scroll.5.calendar        sections 5 calendar widget
#  .1.0.scroll.5.calendar.insert  
#  .1.0.scroll.N.lst             accordion
#  .1.0.scroll.N.lst.YYYYMMDD    datun
#  .1.0.scroll.N.lst.YYYYMMDD.n  rowid - wentry
#
#  .1.0.calinsert     calendar popup widget form insert
#  .1.0.calN          calendar popup widget form wentry
#
# 'public' procs
#  draw path
#  load todos  
#     todos is list {section {datum {rowid todo ...} datum ..} section ..}
# 
# variable today Wtoday tomorow Wtomorow 
#    keeps same datum 'after midnight'
#
# buttons command
#   AccordionCmd   open/close accordion section btn
#   Insert1        insert new item as last in todo or tomorow or ever
#   Insert2        insert new item as last in todo or tomorow or ever
#   Insert3        insert new item as last in todo or tomorow or ever
#   InsertDatum    calendar callback proc (OK CAncel)
# calendar callback
#   CALDatum {path datum}
#
# bindings on Todo called from wentry on Todo widget
#   <<Save>>         Save %W %d
#   <<Delete>>       Delete    %W
#   <<Moveup>>       Moveup    %W
#   <<Movedn>>       Movedn    %W 
#   <<ToToday>>      ToToday   %W
#   <<ToTomorow>>    ToTomorow %W
#   <<ToEver>>       ToEver    %W
#   <<ToDone>>       ToDone    %W
#
# bindigs on Wentry - specific for Todo
#   <Alt-d> <Alt-D>    <<ToToday>>
#   <Alt-s> <Alt-S>    <<ToTomorow>>
#   <Alt-u> <Alt-U>    <<ToEver>>
#   <Alt-g> <Alt-G>    <<ToDone>>
#

package require Tcl 8.6
package require Tk  8.6
package require domain   1.0
package require wentry   1.0


namespace eval ::todo {
  variable Pane     
  variable PaneIns     
  
  variable SecLentgh 6
  
  variable today [clock format [clock seconds] -format %Y-%m-%d]
  variable tomorow \
    [clock format [clock add [clock seconds] 1 day] -format %Y-%m-%d]
  variable ever 0000-00-00
  
  variable Wtoday [clock format [clock seconds] -format %Y%m%d]
  variable Wtomorow \
    [clock format [clock add [clock seconds] 1 day] -format %Y%m%d]
  variable Wever 00000000
  
  
  bind Wentry <Shift-Up>   { event generate [winfo parent %W] <<MoveUp>> }
  bind Wentry <Shift-Down> { event generate [winfo parent %W] <<MoveDn>> }
  
  bind Wentry <Shift-Delete> { event generate [winfo parent %W] <<Delete>> }
  
  bind Wentry <Alt-d>  {event generate [winfo parent %W] <<ToToday>>}  
  bind Wentry <Alt-D>  {event generate [winfo parent %W] <<ToToday>>}
  bind Wentry <Alt-s>  {event generate [winfo parent %W] <<ToTomorow>>} 
  bind Wentry <Alt-S>  {event generate [winfo parent %W] <<ToTomorow>>} 
  bind Wentry <Alt-u>  {event generate [winfo parent %W] <<ToEver>>} 
  bind Wentry <Alt-U>  {event generate [winfo parent %W] <<ToEver>>} 
  bind Wentry <Alt-g>  {event generate [winfo parent %W] <<ToDone>>} 
  bind Wentry <Alt-G>  {event generate [winfo parent %W] <<ToDone>>} 
  
  bind Todo <<Save>>      [namespace code {Save %W %d}]
  bind Todo <<Delete>>    [namespace code {Delete %W}]
  bind Todo <<MoveUp>>    [namespace code {MoveUp %W}]
  bind Todo <<MoveDn>>    [namespace code {MoveDn %W}]
  bind Todo <<ToToday>>   [namespace code {ToToday %W}]
  bind Todo <<ToTomorow>> [namespace code {ToTomorow %W}]
  bind Todo <<ToEver>>    [namespace code {ToEver %W}]
  bind Todo <<ToDone>>    [namespace code {ToDone %W}]
}


# path = .11; pane = .1.0.scroll 
# draw todo frames  with section -in Scrollertrick $Pane.s
# there are 6 section (past, today, tomorow, ever, future, done)
proc ::todo::draw {path pane} {
  variable Pane
  variable PaneIns
  variable SecLentgh
  variable ::gi::TodoSections
  
  set Pane $pane
  set PaneIns $path

  ::calendar::create $PaneIns.calendar -position above -cmd ::todo::CALDatum

  for {set l 0; set b 1} {$l < $SecLentgh} {incr b; incr l} {

    pack [frame $Pane.$b]
      pack [frame $Pane.$b.tool]
        pack [button $Pane.$b.tool.accordion \
          -text $TodoSections($b) \
          -command [list [namespace current]::AccordionCmd $b]]
      if {$b in {2 3 4}} { 
        pack [button $Pane.$b.tool.insert \
          -command [list [namespace current]::Insert$b]]
      }
      frame $Pane.$b.lst
  }
} 


# read records from database and draw in frames
proc ::todo::load {todos} {
  foreach {section datums} $todos {
    foreach {datum records} $datums {
      set dat [GetDatumName $datum]
      DatumInSection $section $dat $datum
      
      foreach {rowid value} $records {
        incr rang
        set itemWdg [SetItemWdg $section $dat $rowid]
        DrawItem $itemWdg $value {} $datum
      }
      
      set rang 0
    }
    
    if {$datums != {} && $section ni {1 6}} {
      DrawSection [SetAccordionPath $section] show
    }
  }
}


# close open section accordion 
proc ::todo::AccordionCmd {sec} {
  set accPath [SetAccordionPath $sec]
  
  focus .
  update
  
  if {[winfo manager $accPath] ne ""} {
    DrawSection $accPath hide
    return
  }
  
  set children_set [pack slaves $accPath]
  if {$children_set == {}} { return }
  DrawSection $accPath show
}

# calendar callback 
# parameter:
#   if called from section 5 insert: path: .1.0.5.calendar.insert
#   if called from item tool calendare widget
proc ::todo::CALDatum {path datum} {
  variable PaneIns
  if {$datum eq ""} {
    return
  }
  if {[winfo parent $path] eq $PaneIns} {
    InsertDatum $datum
  } else {
    set wdg [GetItemWdg $path]
    ToDatum $wdg $datum
  }
}


# save event from wentry
proc ::todo::Save {win value} {
  ::domain::updateTodo [GetRowid $win] $value
}


# [InsertBtn] in sec 2 today
proc ::todo::Insert2 {} {
  variable today
  variable Wtoday
  variable Pane
  
  Insert 2 $Wtoday $today
}
# [InsertBtn] in sec 3 tomorow
proc ::todo::Insert3 {} {
  variable tomorow
  variable Wtomorow
  
  Insert 3 $Wtomorow $tomorow
}
# [InsertBtn] in sec 4 ever
proc ::todo::Insert4 {} {
  variable ever
  variable Wever
  
  Insert 4 $Wever $ever
}

# [CalendarBtn] main calendar
proc ::todo::InsertDatum {datum} {
  lassign [GetSecDatFromDoneDatum 0 $datum] sec dat
  Insert $sec $dat $datum
}

proc ::todo::Insert {sec dat datum} {
  focus .
  update
  
  set rang [GetMaxRang $sec $dat]
  set rowid [::domain::insertTodo 0 $datum $rang {}]
  
  DatumInSection $sec $dat $datum
  
  set itemWdg [SetItemWdg $sec $dat $rowid]
  DrawItem $itemWdg {} {} $datum
  
  DrawSection [SetAccordionPath $sec] "show"
  ::wentry::inFocus $itemWdg
}


# <Key-Delete> [DeleteBtn]
proc ::todo::Delete {wdg} {
  
  set rowid [GetRowid $wdg]
  set rowids [GetRowids $wdg] 
  set newFocus [GetNewFocus $wdg]
  
  ::domain::deleteTodo $rowid $rowids
  
  DestroyItem $wdg
  ::wentry::inFocus $newFocus
}


# <Shift-Up> [MoveUpBtn]
proc ::todo::MoveUp {wdg} {
  focus .
  update
  
  set lst [pack slaves [GetDatumPath $wdg]]
  set sybl [lindex $lst [lsearch -exact $lst $wdg]-1]
  
  if {$sybl eq ""} {
    ::wentry::inFocus $wdg
    return
  } 
  
  set rowidUp [GetRowid $sybl]
  set rowidDn [GetRowid $wdg]
  ::domain::updateTodoRangs $rowidUp $rowidDn
  
  pack $wdg -before $sybl
  ::wentry::inFocus $wdg
}

# <Shift-Down> [MoveDnBtn]
proc ::todo::MoveDn {wdg} {
  focus .
  update
  
  set lst [pack slaves [GetDatumPath $wdg]]
  set sybl [lindex $lst [lsearch -exact $lst $wdg]+1]
  
  if {$sybl eq ""} {
    ::wentry::inFocus $wdg
    return
  } 
  
  set rowidUp [GetRowid $wdg]
  set rowidDn [GetRowid $sybl]
  ::domain::updateTodoRangs $rowidUp $rowidDn
  
  pack $wdg -after $sybl
  ::wentry::inFocus $wdg
}


# <Alt-d> [movetoBtn]
proc ::todo::ToToday {wdg} {
  variable Wtoday
  variable today
  
  MoveTo $wdg 0 $today 2 $Wtoday
}
# <Alt-s> [movetoBtn]
proc ::todo::ToTomorow {wdg} {
  variable Wtomorow
  variable tomorow
  
  MoveTo $wdg 0 $tomorow 3 $Wtomorow
}
# <Alt-u> [movetoBtn]
proc ::todo::ToEver {wdg} {
  variable Wever
  variable ever
  
  MoveTo $wdg 0 $ever 4 $Wever
}
# <Alt-g> [moveToBtn]
proc ::todo::ToDone {wdg} {
  variable Wtoday
  variable today
  
  MoveTo $wdg 1 $today 6 $Wtoday
}
# calendar ok btn
proc ::todo::ToDatum {wdg datum} {
  lassign [GetSecDatFromDoneDatum 0 $datum] secNew datNew
  MoveTo $wdg 0 $datum $secNew $datNew
}

proc ::todo::MoveTo {wdg done datum secNew datNew} {
  lassign [GetSecDatFromWdg $wdg] secOld datOld
  
  if {$secNew eq $secOld && $datNew eq $datOld} {
    return
  }
  
  focus .
  update
  
  set value [$wdg.entry get]
  set rowid [GetRowid $wdg]
  set rowids [GetRowids $wdg]
  set rang [GetMaxRang $secNew $datNew]
  ::domain::updateTodoRecord $rowid $done $datum $rang $rowids
  
  DestroyItem $wdg
  
  DatumInSection $secNew $datNew $datum
  set itemWdg [SetItemWdg $secNew $datNew $rowid]
  DrawItem $itemWdg $value {} $datum
  DrawSection [SetAccordionPath $secNew] "show"
  ::wentry::inFocus $itemWdg
}




# draw todo item with wentry buttons bindigs
proc ::todo::DrawItem {wdg value sybl datum} {  
  variable Pane
  
  if {$sybl eq ""} {
    ::wentry::draw $wdg $value true
  } else {
    ::wentry::draw $wdg $value false
    pack $wdg {*}$PM(wentry) -before $sybl
  }
  
  bindtags $wdg [concat Todo [bindtags $wdg]]
  
  ::wentry::toolButton $wdg delete    {-event Delete}
  ::wentry::toolButton $wdg moveup    {-event MoveUp}
  ::wentry::toolButton $wdg movedn    {-event MoveDn}
                                       
  ::wentry::toolButton $wdg totoday   {-tool todos -event ToToday}
  ::wentry::toolButton $wdg totomorow {-tool todos -event ToTomorow}
  ::wentry::toolButton $wdg toever    {-tool todos -event ToEver}
  ::wentry::toolButton $wdg todone    {-tool todos -event ToDone}
  
  ::wentry::calendarWidget $wdg $datum ::todo::CALDatum
}


# draw frame for items with same datum 
# if there are more datum in section (past, done, future)
# show datum in label
proc ::todo::DrawDatum {wdg lbl sybl} {
  
  labelframe $wdg
  
  if {$lbl ne ""} {
    label $wdg.dl -text $lbl
    $wdg configure -labelwidget $wdg.dl
  }
    
  if {$sybl ne ""} {
    pack $wdg -side top -fill x -before $sybl
  } else {
    pack $wdg -side top -fill x
  }

}


# pack or unpack accordion frame
proc ::todo::DrawSection {path mode} {
  switch $mode "show" {
      pack $path -fill both -expand 1
  } "hide" {
      pack forget $path
  }
}

proc ::todo::DestroyItem {wdg} {
  destroy $wdg
  
  set datWdg [GetDatumPath $wdg]
  set secWdg [winfo parent $datWdg]
  if ![llength [pack slaves $datWdg]] {
    destroy $datWdg
  }
  if ![llength [pack slaves $secWdg]] {
    DrawSection $secWdg hide
  }
}

# draw new datum frame if not exists in order
proc ::todo::DatumInSection {sec dat datum} {
  set datWdg [SetDatumPath $sec $dat]
  if [winfo exists $datWdg] {
    return
  }
  
  set lst [SetAccordionPath $sec]
  set datSybl {}
  if {[llength $lst] && $sec in {1 5}} {
    foreach datwdg [pack slaves $lst] {
      if {[winfo name $datwdg] > $dat} {
        set datSybl $datwdg
        break
      }
    }
  } elseif {[llength $lst] && $sec == 6} {
    foreach datwdg [pack slaves $lst] {
      if {[winfo name $datwdg] < $dat} {
        set datSybl $datwdg
        break
      }
    }
  }
  
  if {$sec == 4} {
    set datum ""
  }
  DrawDatum $datWdg $datum $datSybl
  return
}










# WINDOW HIERARCHY

# return list sectionNr datumWindowName
proc ::todo::GetSecDatFromDoneDatum {done datum} {
  variable today
  variable tomorow
  variable ever
  variable Wtoday
  variable Wtomorow
  variable Wever
  
  if $done {
    set sec 6
  } elseif {$datum eq $today} {
    set sec 2 
  } elseif {$datum eq $tomorow} {
    set sec 3
  } elseif {$datum eq $ever} {
    set sec 4
  } elseif {$datum < $today} {
    set sec 1
  } elseif {$datum > $tomorow} {
    set sec 5
  }
  
  set dat [GetDatumName $datum]
  
  return [list $sec $dat]
}

# return list sectionNr datumWindowName
proc ::todo::GetSecDatFromWdg {wdg} {
  set lst [split $wdg "."]
  set sec [lindex $lst 4] 
  set dat [lindex $lst 6]  
  return [list $sec $dat]
}

# return rowid
proc ::todo::GetRowid {w} {
  return [lindex [split $w "."] 7]
}

# return item rang in list
proc ::todo::GetMaxRang {sec dat} {
  variable Pane
  
  set lst $Pane.$sec.lst.$dat
  if [winfo exists $lst] {
    set rang [llength [pack slaves $lst]]
  }
  incr rang
  return $rang
}

# return list with rowid-s of widgets packed after wdg
proc ::todo::GetRowids {wdg} {
  set rangSet [pack slaves [winfo parent $wdg]]
  set rang [lsearch $rangSet $wdg]
  
  set rowids {}
  foreach r [lrange $rangSet $rang+1 end] {
    lappend rowids [winfo name $r]
  }
  
  return $rowids
}

# return wdgName that can take focus after delete of wdg
proc ::todo::GetNewFocus {wdg} {
  set rangSet [pack slaves [winfo parent $wdg]]
  set rang [lsearch $rangSet $wdg]
  
  set focusW [lindex $rangSet $rang+1]
  if {$focusW eq ""} {
    set focusW [lindex $rangSet $rang-1]
  }
  
  return $focusW
}

# return window name of datum frame in section number sec
proc ::todo::SetDatumPath {sec dat} {
  variable Pane
  return [join [list $Pane $sec lst $dat] "."]
}

# return window name of datum section
proc ::todo::GetDatumPath {w} {
  return [join [lrange [split $w "."] 0 6] "."]
}

# return window name of accordion frame in section number sec
proc ::todo::SetAccordionPath {sec} {
  variable Pane
  return [join [list $Pane $sec lst] "."]
}

# return window name of item
proc ::todo::SetItemWdg {sec dat rowid} {
  variable Pane
  return [join [list $Pane $sec lst $dat $rowid] "."]
}
# return window name of item from any children widget
proc ::todo::GetItemWdg {w} {
  return [join [lrange [split $w "."] 0 7] "."]
}


proc ::todo::GetDatumName {datum} {
  return [format %s%s%s {*}[scan $datum %4s-%2s-%2s]]
}
proc ::todo::GetDatumValue {datumName} {
  return [format %s-%s-%s {*}[scan $datumName %4s%2s%2s]]
}


# return list of widgets for tab / shift-tab
proc ::todo::Walk {} {
  variable Pane
  variable PaneIns
  foreach section [pack slaves $Pane] {
    lappend walkSet $section.tool.accordion 
    if [winfo exists $section.tool.insert] {
      lappend walkSet $section.tool.insert
    }
    if {[winfo manager $section.lst] eq ""} { continue }
    foreach datum [pack slaves $section.lst] {
      foreach item [pack slaves $datum] {
        lappend walkSet {*}[::wentry::walk $item]
      }
    }
  }
  lappend walkSet {*}[winfo children $PaneIns.calendar.ctool]
  return $walkSet
}
