#  widget with toolbox, entry window and possible window 
#     when entry lose focus its state is readonly 
#     and if context changed 'blink' and generate <<Save>> event on $wdg
#
#  'public' proc
#  draw wdg value afterW
#  toolButton {wdg toolName btnName event}
#  toolWidget {wdg toolNum widgetScript context} {
#  articleWidget {wdg widgetScript context}
#  
#  key bindings
#
#  right click set focus on entry and open tools
#  click set focus on entry
#  Alt-B  toggle tools
#  Alt-T  toggle article (text)
#  Control-S  set focus on .  
#  escape  set focus on . , but reset context of entry
#  Control-Q  generate <<Delete>> event on $wdg
#  Up Down arrow  generate <<WalkUp>> <<WalkDn>> event on $wdg
#  Shift + Up Down arrow  generate <<MoveUp>> <<MoveDn>> event on $wdg
#
#   implementation of widget can also generate other event on Wentry tag
#   
#  widget paths
#  wdg = .pane.path.rowid
#  $wdg.tool.N.(btns)
#  $wdg.tool.n (wdg)
#  $wdg.entry
#  $wdg.article
#  $wdg.article.1 
#  $wdg.article.1.(btns)
#  $wdg.article.0   -class Text

package provide wentry 1.0


package require Tcl 8.6
package require Tk  8.6


package require wscroll  1.0
package require writter  1.0
package require calendar 1.0



# DRAW WIDGETS

namespace eval ::wentry {
  variable EntryValue ""
  variable ItemValue  ""
  
  bind Entry <Insert> {}
  
  bind Wwdg <FocusIn>   [namespace code {FocusInWdg %W}]
  bind Wwdg <FocusOut>  [namespace code {FocusOutWdg %W}]
  
  bind Wentry <Button-3>  [namespace code {ToggleTool %W true}]
  bind Wentry <Alt-B>     [namespace code {ToggleTool %W}]
  bind Wentry <Alt-b>     [namespace code {ToggleTool %W}]
  
  bind Wentry <Alt-T> [namespace code {ToggleArticle %W}]
  bind Wentry <Alt-t> [namespace code {ToggleArticle %W}]
  
  bind Wentry <FocusIn>   [namespace code {FocusIn %W}]
  bind Wentry <FocusOut>  [namespace code {FocusOut %W}]
  
  bind Wentry <Control-S> [namespace code {Update %W}]
  bind Wentry <Control-s> [namespace code {Update %W}]
  bind Wentry <Return>    [namespace code {Update %W}]
  bind Wentry <KP_Enter>  [namespace code {Update %W}]
  
  bind Wentry <Escape>    [namespace code {Escape %W}]
  
  
  bind Writter <Alt-T>     [namespace code {ToggleArticle %W}]
  bind Writter <Alt-t>     [namespace code {ToggleArticle %W}]
}


# ::wentry::draw
#  parameters:
#    wdg: window name for new wentry widget, should not exists
#    value: text in Entry
#    pack: -true  pack wentry last in parent
#          -false dont pack wentry
proc ::wentry::draw {wdg value isPack} {
  
  frame $wdg -class Wwdg
  frame $wdg.tool
  
  pack [entry $wdg.entry]
  $wdg.entry insert 0 $value
  $wdg.entry configure -state readonly
  bindtags $wdg.entry [concat Wentry [bindtags $wdg.entry]]
  
  
  pack [frame $wdg.tool.buttons]
  toolButton $wdg close [list -cmd \
      [list [namespace current]::ToggleTool $wdg.entry]]
  toolButton $wdg escape [list -cmd \
        [list [namespace current]::Escape $wdg.entry]]
  toolButton $wdg update [list -cmd \
      [list [namespace current]::Update $wdg.entry]]
  
  if $isPack {
    packWentry $wdg {} {}
  }
}


# wentry::toolButton
#  draw button in toolbox 
#  parameters:
#  wdg: existing wentry widget
#  btnName:  name of button window use also for image, text
#  detail: dictionary with zero or some of this keys
#    -tool  child window of tool one row of buttons - toolbox
#      default buttons
#    -side: -side options for packing button
#      default left
#    -cmd: script for -command options of button
#    -event: event to invoke on $wdg with button press
#   if -cmd and -event are set than use -cmd
proc ::wentry::toolButton {wdg btnName detail} {
  
  if [dict exists $detail -tool] {
    set toolName [dict get $detail -tool]
  } else {
    set toolName buttons
  }
  if [dict exists $detail -cmd] {
    set cmd [dict get $detail -cmd]
  } elseif [dict exists $detail -event] {
    set cmd [list event generate $wdg <<[dict get $detail -event]>>]
  } else {
    set cmd {}
  }
  
  if ![winfo exists $wdg.tool.$toolName] {
    pack [frame $wdg.tool.$toolName]
  }
  
  pack [button $wdg.tool.$toolName.$btnName -command $cmd]
}


# wentry::toolWidget
#  draw any widget in toolNum so to eval widgetScript and add contex
#  parameters:
#  wdg: existsing wentry widget
#  toolName: number of row in tool where button  will be placed
#  widgetScript: evaluate widget script and add path and context 
#      path is $wdg.tool.toolNum
#      context is any context 
proc ::wentry::calendarWidget {wdg datum cmd} {
  ::calendar::create $wdg.tool.calendar -datum $datum -cmd $cmd
  $wdg.tool.calendar.ctool.tgl configure \
    -command "[$wdg.tool.calendar.ctool.tgl cget -command]
      focus $wdg.entry"
  return
}

# ::wentry::articleWidget
#   construct widget with text - writter package
#    evaluate widgetScript and add path and context
#    path is $wdg.pop
proc ::wentry::articleWidget {wdg article} {
  ::writter::draw $wdg.article ::wstatus::error
  ::writter::insert $wdg.article $article
  
  toolButton $wdg article [list \
    -cmd [list [namespace current]::ToggleArticle $wdg.entry] \
  ]
}

# ::wentry::articleWidget
# add frame lst into wentry after entry
proc ::wentry::listWidget {wdg} {
  frame $wdg.lst
}
proc ::wentry::packList {wdg} {
  pack $wdg.lst
}

# ::wentry::padWidget
# add pad before entry for tree view
proc ::wentry::padWidget {wdg size {width 10}} {
  set size [expr {$width * $size}]
  pack configure $wdg.entry -padx [list $size 0] 
}


# set focus on entry window of widget from script
proc ::wentry::inFocus {wdg} {
  if {$wdg eq ""} {
    focus .
  } else {
    focus $wdg.entry
  }
  update
}

proc ::wentry::walk {wdg} {
  set walkSet {} 
  if {[winfo manager $wdg.tool] eq "pack"} {
    foreach tool [winfo children $wdg.tool] {
      if {[winfo name $tool] eq "calendar"} {
        foreach calwdg [winfo children $tool.ctool] {
          lappend walkSet $calwdg
        }
      } else {
        foreach toolwdg [winfo children $tool] {
          lappend walkSet $toolwdg
        }
      }
    }
  }
  lappend walkSet $wdg.entry
  if {[winfo exists $wdg.article] && ([winfo manager $wdg.article] eq "pack")} {
    foreach artwdg [winfo children $wdg.article.tool] {
      lappend walkSet $artwdg
    }
    lappend walkSet $wdg.article.txt
  }
  return $walkSet
}



# ::wentry::packWentry
# parameters:
#   option expect -before or -after
#   value  expect window name for -before or -after option
proc ::wentry::packWentry {wdg option value} {
  if {$option eq ""} {
    pack $wdg
  } else {
    pack $wdg $option $value
  }
}

# redraw/restyle wentry when gain focus
proc ::wentry::Active {win} {
  $win configure -state normal \
      -textvariable [namespace current]::EntryValue
  pack configure $win -pady 6
  $win icursor end
}
# redraw/restyle wentry when lose focus
proc ::wentry::Readonly {win} {
  $win selection clear
  $win configure -state readonly -textvariable ""
  pack configure $win -pady {0 1} 
}
proc ::wentry::FocusInWdg {wdg} {
  $wdg configure -highlightthicknes 1
}
proc ::wentry::FocusOutWdg {wdg} {
  $wdg configure -highlightthicknes 0
}

proc ::wentry::PackTool {wdg} {
  if {[winfo manager $wdg.tool] eq "pack"} {
    return
  }
  pack $wdg.tool -before $wdg.entry
}
proc ::wentry::ForgetTool {wdg} {
  pack forget $wdg.tool
}



# ::wentry::FocusIn
# parameter: win: entry window of wentry widget
# set ItemValue and EntryValue from Entry context to use when Escape
#  call Active for redraw/restayl widget
#  scroll - verticaly center windget in pane
proc ::wentry::FocusIn {win} {
  variable ItemValue
  variable EntryValue

  set ItemValue [$win get]
  set EntryValue $ItemValue
  
  Active $win
  event generate . <<VCenter>> -data $win
  update
}
# ::wentry::FocusInWentry
# set again highligh zone after entry lose focus

# ::wentry::Escape 
# parameter: win: entry window of wentry widget
# reset EntryValue to ItemValue 
# so that focusOut doesnt send <<Save>> event
proc ::wentry::Escape {win} {
  variable ItemValue
  variable EntryValue

  set EntryValue $ItemValue
  
  focus .
}

# ::wentry::Update 
# parameter: win: entry window of wentry widget
# fire FocusOut so that change can be saved
proc ::wentry::Update {win} {
  focus .
}

# ::wentry::FocusOut
# parameter: win: entry window of wentry widget
#  call Readonly for redraw/restayl widget
# generate <<Save>> event if EntryValue != ItemValue
# set ItemValue and EntryValue to empty string
proc ::wentry::FocusOut {win} {
  variable ItemValue
  variable EntryValue
  
  set wdg [winfo parent $win]
  
  if {$ItemValue ne $EntryValue} {
    event generate $wdg <<Save>> -data $EntryValue
    ::wentry::Blink $win
  }
  
  Readonly $win
  
  set EntryValue ""
  set ItemValue ""
  
}
proc ::wentry::Blink {win} {
  variable ::gi::CLR
  set clr [$win cget -background]
  $win configure -background $CLR(selected)
  update idletask
  after 100
  $win configure -background $clr
  update idletask
  after 100
}


# ::wentry::ToggleTool open/close window with buttons and calendar
# parameters 
#  win: Entry window or wentry
#  withfocus: boolean 
#   true only from right click 
#   set focus on Entry and open tools but never close tools
proc ::wentry::ToggleTool {win {withfocus false}} {
  set wdg [winfo parent $win]
  
  if {$withfocus} {
    if {[focus -lastfor .] ne $win} {
      focus $win
    }
    if {[winfo manager $wdg.tool] eq ""} {
      PackTool $wdg
    }
  } elseif {[winfo manager $wdg.tool] eq ""} {
    PackTool $wdg
  } else {
    ForgetTool $wdg
  }
}


proc ::wentry::ToggleArticle {win} {
  
  set wdg [winfo parent $win]
  if {[winfo name $wdg] eq "article"} {
    set wdg [winfo parent $wdg]
  }
  if ![winfo exists $wdg.article] {
    return
  }

  if {[winfo manager $wdg.article] eq ""} {
    PackTool $wdg
    ::writter::packWidget $wdg.article
    update
    
  } else {
    ::writter::packWidget $wdg.article
    focus $wdg.entry
    update
    if [info exists ::wstatus::error] {
      set ::wstatus::error ""
    }
  }
}


