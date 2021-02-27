# create widget with 
#  button to open pop calendar
#  entry for enter datum in form %Y-%m-%d
#  ESC button to dismiss any change of datum
#  OK button to confirm select datum
#
# paths
#   $pathName.tool
#   $pathName.tool.tgl
#   $pathName.tool.entry
#   $pathName.tool.ok
#   $pathName.tool.esc
#   $pathName.cwdg.0
#   $pathName.cwdg.0.0   today
#   $pathName.cwdg.0.1   prevY
#   $pathName.cwdg.0.2   prevM
#   $pathName.cwdg.0.3   label
#   $pathName.cwdg.0.4   nextY
#   $pathName.cwdg.0.5   nextM
#   $pathName.cwdg.1
#   $pathName.cwdg.1.n   label daynumber 
#   $pathName.cwdg.2
#   $pathName.cwdg.2.rc  day in calendar mesh from 00 67
#
#   both OK and ESC button 
#     tailcall ::calendar::cmd if set
#     or send <<CalendarSelected>> event to $pathName
#  ::calendar::cmd 
#     should be name of procedure that accept two parameters
#     first is window namePath of calendar widget and second is current datum
#     internaly is invoked with tailcall 
#  <<CalendarSelected>> is generated only if ::calendar::cmd is not set
#     event is generated on calendar window 
#     it set -data parameter to list of two element
#     first is window namePath of calendar widget, second is current datum
#  = about visual elements
#  this package depend on gi package for images, fonts, and colors
#  gi package and gi namespace should have these variable-array
#   ::gi::CLR  define colors
#     CLR(dark) CLR(light) CLR(middle) CLR(dsblf) CLR(selected)
#   ::gi::F  define fonts
#     F(ent) - entry font  F(def) - other fonts
#   ::gi::I  define images
#     I(cal) I(ok) I(escape) I(today) I(py) I(ny) I(pm) I(nm)
#   ::gi::L  define labels
#     L(openclose) L(ok) L(cancel) L(today) L(py) L(ny) L(pm) L(nm)
#  this is mostly so fonts and icons can be created once in application
#  colors can be consistent with application 
#  and labels can be translated

package provide calendar 1.0


package require Tcl 8.6
package require Tk  8.6
package require gi  1.0

namespace eval ::calendar {
  variable config_template {
    -locale system
    -weekStart 1
    -format {
        datum %Y-%m-%d
        monthyear "%B %Y"
        dayName %a
        dayNumber %d
    }
    -pos below
    -cmd  {}
  }
  variable status_template \
    {-month {} -year {} -current {} -selected {} -default {}}
  
  variable status
  variable config
  
  bind CalEntry <Return>   {::calendar::Return [winfo parent [winfo parent %W]]}
  bind CalEntry <KP_Enter> {::calendar::Return [winfo parent [winfo parent %W]]}
  bind CalEntry <Escape>   {::calendar::Escape [winfo parent [winfo parent %W]]}
  bind CalEntry <FocusIn>  {%W config -state normal}
  bind CalEntry <FocusOut> {%W config -state readonly}
}

#::calendar::create pathName
#  pathName is used in other command
#     more calendar can be created in same application
#     should not exists alreday
#  args is dictionary with
#    -datum is default datum for calendar, default {}
#       this datum is current when first create or use when some error occure
#       default empty string
#    -cmd
#       callback or script fragment that will be call when ok btn is klicked
#       default empty string
#    -position  
#       can be bellow or above, where to position widget in widget
#       default below
#
proc ::calendar::create {pathName args} {
  variable status_template
  variable status
  variable config_template
  variable config
  
  DrawFrame $pathName
  
  set status($pathName) $status_template
  set config($pathName) $config_template
  
  if [dict exists $args -datum] {
    set datum [dict get $args -datum]
    set datum [CheckDatumString $datum \
          [dict get $config($pathName) -format datum] \
          [dict get $config($pathName) -locale]]
    if {$datum ne "error"} {
      dict set status($pathName) -current $datum
      dict set status($pathName) -default $datum
    }
  }

  if [dict exists $args -position] {
    dict set config($pathName) -pos [dict get $args -position]
  }  
  if [dict exists $args -cmd] {
    dict set config($pathName) -cmd [dict get $args -cmd]
  }

  DrawWeek   $pathName
  RedrawEntry $pathName
}

# ::calendar::select pathName datum
#    expect datum in  %Y-%m-%d format
#    set current datum for:
#      display in entry window
#      and in popup when/if open (place)
proc ::calendar::select {pathName datum} {
  variable status
  variable config
  variable popPath

  set datum [CheckDatumString $datum \
          [dict get $config($pathName) -format datum] \
          [dict get $config($pathName) -locale]]
          
  if {$datum eq "error"} {
    set datum [dict get $status($pathName) -default]
    return -code error \
      "Invalid datum. Current datum is $datum"
  }
  dict set status($pathName) -current $datum
  
  RedrawEntry $pathName
  RedrawCal $pathName
}

# ::calendar::Return
# called when 'ok' button is invoked or <Return> event in entry
# parameter path: is window pathName of calendar widget
#   set current datum to Entry context 
#   if datum string is not correct (user enter smt) set datum to -current
#   close popupWidget
#   call ::calendar::cmd if set
#   or send <<CalendarSelected>> event to $pathName
#   with path and current datum
proc ::calendar::Return {path} {
  variable config
  variable status

  set datum [CheckDatumString [$path.ctool.centry get] \
          [dict get $config($path) -format datum] \
          [dict get $config($path) -locale]]
  
  if {$datum eq "error"} {
    set datum [dict get $status($path) -default]
    dict set status($path) -current $datum
    if [info exists ::status::error] {
      set ::status::error "invalid datum"
    }
    RedrawEntry $path 
    RedrawCal $path
    return
  }
  
  dict set status($path) -current $datum
  CloseCal $path
  
  if [info exists ::status::error] {
    set ::status::error ""
  }
  set cmd [dict get $config($path) -cmd]
  if {$cmd eq ""} {
    event generate $path <<CalendarSelected>> -data [list $path $datum]
  } else {
    tailcall {*}$cmd $path $datum
  }
}

# ::calendar::Escape
# called when 'esc' button is invoked or <Escape> event in entry
# parameter path: is window pathName of calendar widget
#   set current datum to -default
#   close popupWidget
proc ::calendar::Escape {path} {
  variable status
  
  dict set status($path) -current [dict get $status($path) -default]
  
  RedrawEntry $path
  CloseCal $path
  
  if [info exists ::status::error] {
    set ::status::error ""
  }
}

# ::calendar::Toggle  toggle popup widget 
#   when open display month and year of -current datum
#   or today (current month year)
#   when close - close
proc ::calendar::Toggle {path} {
  variable status
  variable popPath
  variable popPos
  
  if [CloseCal $path] {
    return
  }
  
  PackCal $path
  RedrawCal $path
}

# close (pack forget) cwdg if open (packed) and return true 
# or false if cwdg wasnt packed 
proc ::calendar::CloseCal {path} {
  variable popPath
  variable status
  
  if {[winfo manager $path.cwdg] eq "pack"} {
    dict set status($path) -month {}
    dict set status($path) -year {}
    dict set status($path) -selected {}
  
    pack forget $path.cwdg
    return true
  }
  return false
}
proc ::calendar::RedrawCal {path} {
  variable popPath
  variable status

  if {[winfo manager $path.cwdg] eq "pack"} {
    set datum [dict get $status($path) -current]
    if {$datum eq ""} {
      set datum [Today]
    }
    lassign [MonthYearInteger $datum] month year
    dict set status($path) -month $month
    dict set status($path) -year $year
    DrawMY $path
    DrawDays $path
    DrawMark $path
  }
}
proc ::calendar::RedrawEntry {path} {
    variable config
    variable status
    
    set locale [dict get $config($path) -locale]
    set format [dict get $config($path) -format datum]
    set current [dict get $status($path) -current]
    
    set oldState [$path.ctool.centry cget -state]
    if {$oldState ne "normal"} {
      $path.ctool.centry configure -state normal
    }
    $path.ctool.centry delete 0 end
    if {$current ne ""} {
      $path.ctool.centry insert 0 [DayString $current $format $locale]
    }
    $path.ctool.centry configure -state $oldState 
    return
}


proc ::calendar::BtnT {path} {
    variable status
    lassign [YearMonthDayInteger [Today]] year month d
    dict set status($path) -month $month
    dict set status($path) -year $year
    
    DrawMY $path
    DrawDays $path
}
proc ::calendar::BtnPY {path} {
    variable status
    set year [dict get $status($path) -year]
    incr year -1
    dict set status($path) -year $year
    
    DrawMY $path
    DrawDays $path
}
proc ::calendar::BtnNY {path} {
    variable status
    set year [dict get $status($path) -year]
    incr year
    dict set status($path) -year $year
    
    DrawMY $path
    DrawDays $path
}
proc ::calendar::BtnPM {path} {
  variable status
  set month [dict get $status($path) -month]
  set year [dict get $status($path) -year]
  incr month -1
  if {$month==0} {
      set month 12
      incr year -1
  }
  dict set status($path) -year $year
  dict set status($path) -month $month
  
  DrawMY $path
  DrawDays $path
}
proc ::calendar::BtnNM {path} {
  variable status
  set month [dict get $status($path) -month]
  set year [dict get $status($path) -year]
  incr month 
  if {$month>12} {
      set month 1
      incr year
  }
  dict set status($path) -year $year
  dict set status($path) -month $month
  
  DrawMY $path
  DrawDays $path
}


proc ::calendar::BtnDay {path datum} {
    variable status
    
    dict set status($path) -current $datum

    RedrawEntry $path
    DrawMark $path
}



proc ::calendar::DrawFrame {path} {
  variable ::gi::ICO
  variable ::gi::LBL

  pack [frame $path]
    pack [frame $path.ctool]
      pack [button $path.ctool.tgl -image $ICO(cal) -text $LBL(openclose) \
        -command "[namespace current]::Toggle $path"]
      pack [entry $path.ctool.centry -state readonly]
      pack [button $path.ctool.ok -image $ICO(ok) -text $LBL(ok) \
        -command "[namespace current]::Return $path"]
      pack [button $path.ctool.esc -image $ICO(escape) -text $LBL(cancel) \
        -command "[namespace current]::Escape $path"]
  bind $path <Destroy> {
    array unset ::calendar::status %W
    array unset ::calendar::config %W
  }
  bindtags $path.ctool.centry [concat CalEntry [bindtags $path.ctool.centry]]
  
  frame $path.cwdg 
  pack [frame $path.cwdg.ctool] -fill x -expand 1
  pack [frame $path.cwdg.days]  -fill x -expand 1
  pack [frame $path.cwdg.cdays] -fill both -expand 1
  
  pack [button $path.cwdg.ctool.cbtdy -command "[namespace current]::BtnT $path"]
  pack [button $path.cwdg.ctool.cbtpy -command "[namespace current]::BtnPY $path"]
  pack [button $path.cwdg.ctool.cbtpm -command "[namespace current]::BtnPM $path"]
  pack [label $path.cwdg.ctool.clbl]
  pack [button $path.cwdg.ctool.cbtnm -command "[namespace current]::BtnNM $path"]
  pack [button $path.cwdg.ctool.cbtny -command "[namespace current]::BtnNY $path"]
  
  
  for {set c 0} {$c<7} {incr c} {
    grid [label $path.cwdg.days.$c] \
        -row 0 -column $c 
  }
  
  for {set r 0} {$r<6} {incr r} {
    for {set c 0} {$c<7} {incr c} { 
      grid [button $path.cwdg.cdays.$r$c] -row $r -column $c 
    }
  }
  
  grid columnconfigure $path.cwdg.days  all -weight 1 -uniform dys
  grid rowconfigure    $path.cwdg.cdays all -weight 1
  grid columnconfigure $path.cwdg.cdays all -weight 1
}

proc ::calendar::PackCal {path} {
  variable config
  
  set pos [dict get $config($path) -pos]

  if {$pos eq "above"} {
    pack $path.cwdg -before $path.ctool
  } elseif {$pos eq "below"} {
    pack $path.cwdg -after $path.ctool
  }
}

proc ::calendar::DrawMY {path} {
  variable config
  variable status

  set locale [dict get $config($path) -locale]
  set format [dict get $config($path) -format monthyear]
  set month  [dict get $status($path) -month]
  set year  [dict get $status($path) -year]
  
  set txt [MonthYearString $month $year $format $locale]
  $path.cwdg.ctool.clbl configure -text $txt
  return
}
proc ::calendar::DrawWeek {path} {
  variable config
  
  set ws [dict get $config($path) -weekStart]
  set format [dict get $config($path) -format dayName]
  set locale [dict get $config($path) -locale]

  foreach wdg [winfo children $path.cwdg.days] {
      set daynumber [expr [winfo name $wdg] + $ws]
      set txt [WeekDayName $daynumber $format $locale]
      $wdg configure -text $txt
  }
  return 
}
proc ::calendar::DrawDays {path} {
  variable status
  variable config
  variable ::gi::CLR
 
  set ws     [dict get $config($path) -weekStart]
  set locale [dict get $config($path) -locale]
  set format [dict get $config($path) -format dayNumber]
  
  set month [dict get $status($path) -month]
  set year  [dict get $status($path) -year]
  set current [dict get $status($path) -current]

  set context [Context $ws $month $year $current]
  dict set status($path) -selected {}
  foreach item $context {
    if {[lassign $item wdg datum state]=="C"} {
      set background $CLR(selected)
      dict set status($path) -selected $wdg
    } else {
      set background $CLR(light)
    }
    $path.cwdg.cdays.$wdg configure \
      -text [DayString $datum $format $locale] \
      -command "::calendar::BtnDay $path $datum" \
      -state [expr {$state ? "normal" : "disabled"}] \
      -background $background
  }
  return
}

proc ::calendar::DrawMark {path} {
  variable status
  variable config
  variable ::gi::CLR

  set current [dict get $status($path) -current]
  
  dict set status($path) -selected ""
  foreach wdg [winfo children $path.cwdg.cdays] {
      set datum [lindex [split [$wdg cget -command] " "] end]
      if {$current eq $datum} {
          $wdg configure -background $CLR(selected)
          dict set status($path) -selected [winfo name $wdg]
      } else {
          $wdg configure -background $CLR(light)
      }
  }
  return
}



# clock
proc ::calendar::CheckDatumString {datumString format locale} {
  if {$datumString eq ""} {
    return
  }
  if {$datumString eq "0000-00-00"} {
    return
  }
  try {
    return [clock format \
      [clock scan $datumString -format $format -locale $locale] \
            -format %Y-%m-%d]
  } on error {} {
    return "error"
  }
}

proc ::calendar::WeekStartStamp {ws year month} {
    set day [clock scan "$year-$month-1" -format "%Y-%m-%d"]
    set day [clock scan 1 -format {%u} -base $day]
    if {$ws==0} {
        set day [clock add $day -1 day]
    }
    return $day
}
proc ::calendar::Context {weekStart month year current} {
    set c_format "%Y-%m-%d %N"

    set day [WeekStartStamp $weekStart $year $month]

    for {set r 0} {$r<6} {incr r} {
        for {set c 0} {$c<7} {incr c} {
            lassign [clock format $day -format $c_format] \
                c_day c_month
                
            set c_isc [expr {$month eq $c_month ? 1 : 0}]
            if {$c_day eq $current} {
                lappend calendar [list $r$c $c_day $c_isc C]
            } else {
                lappend calendar [list $r$c $c_day $c_isc]
            }
            set day [clock add $day 1 day]
        }
    }
    return $calendar
}
proc ::calendar::Today {} {
    clock format [clock seconds] -format %Y-%m-%d
}

proc ::calendar::WeekDayName {daynumber format locale} {
    return [clock format [clock scan $daynumber -format %u] \
                -format $format -locale $locale]
}
proc ::calendar::MonthYearString {month year format locale} {
    clock format \
        [clock scan "$year-$month-1" -format "%Y-%m-%d"] \
        -format $format -locale $locale
}
proc ::calendar::DayString {day format locale} {
    clock format [clock scan $day -format %Y-%m-%d] \
        -format $format -locale $locale
}

proc ::calendar::MonthYearInteger {datum} {
  clock format [clock scan $datum -format %Y-%m-%d] -format {%N %Y}
}
proc ::calendar::YearMonthDayInteger {datum} {
  clock format [clock scan $datum -format %Y-%m-%d] -format {%Y %N %e}
}
