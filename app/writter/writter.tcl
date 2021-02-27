# draw widget with Text window 
# plus mark underline text and add link to browser
#
#~ $path           wdg(rowid).article(wentry)
#~ $path.tool         
#~ $path.tool.save    button 
#~ $path.tool.mark    button 
#~ $path.tool.undr    button 
#~ $path.tool.link    button 
#~ $path.tool.close   button  
#~ $path.0           text  

package provide writter 1.0

package require Tcl 8.6
package require Tk  8.6
#~ source [file join $::TSKNGR_APPDIR utils.tcl]
package require gi  1.0


namespace eval ::writter {
  variable Status
  variable Browsers {chrome firefox safari}

  bind Writter <Control-S> [namespace code {Save %W}]
  bind Writter <Control-s> [namespace code {Save %W}]
  bind Writter <FocusOut>  [namespace code {Save %W}]
  
  
  bind Writter <Alt-m>  [namespace code {Mark [winfo parent %W]}]
  bind Writter <Alt-M>  [namespace code {Mark [winfo parent %W]}]
  
  bind Writter <Alt-u>  [namespace code {Undrl [winfo parent %W]}]
  bind Writter <Alt-U>  [namespace code {Undrl [winfo parent %W]}]
  
  bind Writter <Alt-n>  [namespace code {None [winfo parent %W]}]
  bind Writter <Alt-N>  [namespace code {None [winfo parent %W]}]
  
  bind Writter <Alt-l>  [namespace code {Link [winfo parent %W]}]
  bind Writter <Alt-L>  [namespace code {Link [winfo parent %W]}]
  
  bind Linkframe <Enter> [namespace code {VisitLinkFrame %W Enter}]
  bind Linkframe <Leave> [namespace code {VisitLinkFrame %W Leave}]
  
  bind Linklabel <Button-1> [namespace code {EditLinklabel %W}]
  bind Linklabel <Button-3> [namespace code {EditLinklabel %W}]
} 

# argument path: $entrywdg.article
# path to Text window $entrywdg.article.txt
proc ::writter::draw {path errvarName} {
  variable Status
  
  set Status($path.url)     {}
  set Status($path.errvar)  $errvarName
  set Status($path.links)   {}
  set Status($path.lastlink) 0
  
  frame $path 
  
  pack [frame $path.tool ]
  pack [button $path.tool.save \
          -command [list [namespace current]::Save $path.txt]]
  pack [button $path.tool.mark \
          -command [list [namespace current]::Mark $path.txt]]
  pack [button $path.tool.undr \
          -command [list [namespace current]::Undrl $path.txt]]
  pack [button $path.tool.none \
          -command [list [namespace current]::None $path.txt]]
  pack [button $path.tool.link \
          -command [list [namespace current]::Link $path]]
  pack [button $path.tool.close \
          -command [list [namespace current]::packWidget $path]]

  pack [frame $path.linktool]
  pack [entry $path.linktool.address -state disabled -width 0 \
    -textvariable "::writter::Status($path.url)"]
  entry $path.linktool.title
  button $path.linktool.ok -command "::writter::OkLink $path"
  button $path.linktool.escape -command "::writter::EscapeLink $path"
  
    
  pack [text $path.txt]

  bindtags $path.txt [concat Writter [bindtags $path.txt]]
  $path.txt tag configure MARKER \
    -background yellow -selectbackground darkgreen
  $path.txt tag configure UNDERL \
    -underline true -underlinefg red
}


proc ::writter::packWidget {path} {
  variable Status
  if {[winfo manager $path] eq ""} {
    pack $path -fill both -expand 1
    focus $path.txt
  } else {
    focus .
    update
    pack forget $path
    set $Status($path.errvar) ""
  }
}


proc ::writter::insert {path article} {
  variable Status
  
  set textWdg $path.txt
  lassign $article context tags marks wins 

  $textWdg delete 0.0 end
  $textWdg insert 0.0 $context
  set Status($path.lastlink) 0
  set Status($path.links) {}
  set Status($path.url) {}
  
  
  foreach {tagName indices} $tags {
    if [llength $indices] {
      $textWdg tag add $tagName {*}$indices
    }
  }
  
  foreach {markName pos} $marks {
    $textWdg mark set $markName $pos
  }
  
  foreach {name pos title url} $wins {
    set ll [lindex [split $name "_"] end]
    if {$ll > $Status($path.lastlink)} {
      set Status($path.lastlink) $ll
    }
    LinkLabel $path $name $title $url $pos
    lappend Status($path.links) $name $url
  }
  
}
proc ::writter::LinkLabel {path name title url pos} {
  variable ::gi::FNT
  variable ::gi::ICO
  variable ::gi::LBL
  set win $path.txt.$name
  frame $win
  pack [label $win.wtitle -text $title]
  pack [button $win.go -command "::writter::GoLink $path $url"]
  
  bindtags $win [concat Linkframe [bindtags $win]]
  bindtags $win.wtitle [concat Linklabel [bindtags $win.wtitle]]
  
  $path.txt window create $pos -window $win -padx 2
}

proc ::writter::getarticle {path} {
  variable Status
  
  set win $path.txt
  set context [$win get 1.0 end-1c]

  set tags {}
  lappend tags \
      MARKER [$win tag ranges MARKER] \
      UNDERL [$win tag ranges UNDERL]
    
  set marks [list insert [$win index insert]]
  
  set wins {}
  foreach link [$win window names] {
    lappend wins \
      [winfo name $link] \
      [$win index $link] \
      [$link.wtitle cget -text] \
      [lindex [split [$link.go cget -command] " "] end]
  }

  return [list $context $tags $marks $wins]
}


# buttons
proc ::writter::Save {win} {
  variable Status
  set path [winfo parent $win]
  set wdg [winfo parent $path]
  
  set $Status($path.errvar) ""
  set article [getarticle $path]
  
  event generate $wdg <<SaveArticle>> -data $article
  Blink $win
}
proc ::writter::Blink {win} {
  variable ::gi::CLR
  set clr [$win cget -background]
  $win configure -background $CLR(selected)
  update idletask
  after 100
  $win configure -background $clr
  update idletask
  after 100
}

proc ::writter::Mark {win} {
  if {[$win tag ranges sel] == {}} {
    return
  }
  $win tag add MARKER sel.first sel.last
  $win tag remove sel sel.first sel.last
}

proc ::writter::Undrl {win} {
  if {[$win tag ranges sel] == {}} {
    return
  }
  $win tag add UNDERL sel.first sel.last
  $win tag remove sel sel.first sel.last
}

proc ::writter::None {win} {
  if {[$win tag ranges sel] == {}} {
    return
  }
  foreach tagName {MARKER UNDERL} {
    if {$tagName eq "sel"} { continue }
    $win tag remove $tagName sel.first sel.last
  }
  $win tag remove sel sel.first sel.last
}


proc ::writter::Link {path} {
  set win $path.txt
  
  if {[$win tag ranges sel] ne {}} {
    set title [$win get sel.first sel.last]
  }  else {
    set title {}
  }

  EnableLink $path $title new
}

proc ::writter::EditLinklabel {w} {
  set link [winfo parent $w]
  set path [winfo parent [winfo parent $link]]
  
  EnableLink $path [$w cget -text] [winfo name $link]
}

proc ::writter::EnableLink {path title source} {
  variable Status
  if {$source eq "new"} {
    set url ""
  } else {
    set url [dict get $Status($path.links) $source]
    if {$url eq "{}"} {
      set url ""
    }
  }
  
  grab set $path.linktool
  set $Status($path.url) ""
  $path.linktool.address configure -textvariable "" -state normal
  $path.linktool.address delete 0 end
  $path.linktool.address insert 0 $url
  $path.linktool.title insert 0 $title
  $path.linktool.ok configure -command \
    [concat [$path.linktool.ok cget -command] $source]
  pack $path.linktool.title
  pack $path.linktool.ok
  pack $path.linktool.escape
  
  focus $path.linktool.title
  update
}


  
proc ::writter::OkLink {path source} {
  variable Status
  
  set title [$path.linktool.title get]
  if {$title eq ""} {set title "---"}
  set url [lindex [$path.linktool.address get] 0]
    
  if {$source eq "new"} {
    lassign [$path.txt tag ranges sel] first last
    if {$first ne ""} {
      $path.txt delete sel.first sel.last
    }
    incr Status($path.lastlink)
    set name link_$Status($path.lastlink)
    set pos [$path.txt index insert]
    LinkLabel $path $name $title $url $pos
    lappend Status($path.links) $name $url
  } else {
    set name $source
    $path.txt.$name.wtitle configure -text $title
    $path.txt.$name.go configure -command [list ::writter::GoLink $path $url]
    dict set Status($path.links) $name $url
  }
  
  EscapeLink $path
}


proc ::writter::EscapeLink {path} {
  variable Status
  
  set Status($path.url) ""
  $path.linktool.address configure -textvariable "::writter::Status($path.url)"
  $path.linktool.address configure -state disabled
  $path.linktool.title delete 0 end
  $path.linktool.ok configure -command \
    [lreplace [$path.linktool.ok cget -command] end end]
  pack forget $path.linktool.title
  pack forget $path.linktool.ok
  pack forget $path.linktool.escape
  grab release $path.linktool
  focus $path.txt
  $path.txt tag remove sel 1.0 end
  update
}


proc ::writter::VisitLinkFrame {w e} {
  variable Status
  if {$e eq "Enter"} {
    $w configure -cursor hand2
    set path [winfo parent [winfo parent $w]]
    set link [winfo name $w]
    set url [dict get $Status($path.links) $link]
    if {$url eq "{}"} {
      set url ""
    }
    set ::writter::Status($path.url) $url
  } elseif {$e eq "Leave"} {
    $w configure -cursor none
    set path [winfo parent [winfo parent $w]]
    set ::writter::Status($path.url) ""
  }
}

proc ::writter::GoLink {path {url {}}} {
  variable ::gi::LBL
  variable Status
  variable Browsers
  set errvar $Status($path.errvar)
  
  if {$url eq ""} {
    set $errvar $LBL(missurl)
    return
  }
  
  set testUrl [expr {
        [string match -nocase "https://*" $url] ||
        [string match -nocase "http://*" $url] || 
        [string match -nocase "file:///*" $url]
      }]
      
  if !$testUrl {
    set $errvar $LBL(missurl)
    return
  }
  
  set browser ""
  if {$::tcl_platform(platform) eq "windows"} {
    set browser [list {*}[auto_execok start] {}]
  } else {
    foreach www $Browsers {
      set browser [auto_execok $www]
      if {$browser ne ""} { 
        break
      }
    }
  }
  if {$browser eq ""} {
    set $errvar $LBL(misswww)
    return
  }
  
  set $errvar ""
  close [open "| $browser $url"]
}






