package provide gi 1.0

package require Tcl    8.6
package require Tk     8.6


# color
namespace eval ::gi {
  variable CLR 

  set CLR(base)         lavender
  set CLR(light)        ghostwhite
  set CLR(middle)       beige
  set CLR(dark)         black
  
  set CLR(asidelight)   lavender
  set CLR(asidemiddle)  darkseagreen
  set CLR(asidedark)    seagreen
  set CLR(error)        red
  
  set CLR(readonly)     whitesmoke
  set CLR(write)        white
  set CLR(selected)     orange
  set CLR(selected2)    sienna
  set CLR(selected3)    coral
}
# font
namespace eval ::gi {
  variable FNT 
  set FNT(def) [font create -family Arial -size 10]
  set FNT(bold) [font create -family Arial -size 15 -weight bold]
  set FNT(big) [font create -family Arial -size 14]
  set FNT(type) [font create -family Verdana -size 12]
  set FNT(italic) [font create -family Arial -size 12 -weight bold -slant italic]
  set FNT(link) [font create -family Verdana -size 12 -slant italic]
}
# icons
namespace eval ::gi {
  variable ICO 
  
  proc create_icons {} {
    variable ICO

    foreach {iname fname} {
      insert    add_new.png    
      close     close.png      
      ok        check.png      
      update    save.png       
      escape    undo.png       
      delete    delete.png     
      moveup    move_up.png    
      movedn    move_down.png  
      levelup   level_up.png   
      leveldn   level_dn.png   
      inschild  add_child.png  
      article   article.png    
      - -        
      cal       cal_toggle.png 
      today     cal_current.png
      totoday   cal_today.png  
      totomorow cal_tomorow.png
      toever    cal_ever.png   
      todone    cal_done.png   
      pm        cal_prevm.png  
      nm        cal_nextm.png  
      py        cal_prevy.png  
      ny        cal_nexty.png  
      - -
      link      link.png       
      smalllink small_link.png 
      linkedit  linkedit.png   
      undr      text_underl.png
      mark      text_marker.png
      clear     text_clear.png 
      help      help.png
      about     about.png
    } {
      if [string match - $iname] {
        continue
      }
      set fname [file join $::TSKNGR_APPDIR icons $fname]
      set ICO($iname) [image create photo -file $fname]
    }
  }
  

  create_icons
}
# labels
namespace eval ::gi {
  variable LBL
  variable TodoSections
  set TodoSections(1)  "pro\u0161lo"
  set TodoSections(2)  "danas"
  set TodoSections(3)  "sutra"
  set TodoSections(4)  "uvik"
  set TodoSections(5)  "nekad"
  set TodoSections(6)  "gotovo"
  
  set LBL(laddress) "adresa"
  set LBL(ltitle)   "naslov"
  
  
  set LBL(missurl)  "poveznica je nepravilna ili ne postoji"
  set LBL(misswww)  "ne mogu otvorit browser"
  
  set LBL(insert)    "novi"
  set LBL(openclose) "otvori/zatvori"
  set LBL(ok)        "Potvrdi"
  set LBL(cancel)    "Poništi"
  set LBL(close)     "Zatvori"
  set LBL(today)     "danas"
  set LBL(tomorow)   "sutra"
  set LBL(ever)      "uvik"
  set LBL(done)      "gotovo"
  set LBL(prevY)     "prošla godina" 
  set LBL(prevM)     "prošli mjesec" 
  set LBL(nextM)     "sljedeći mjesec" 
  set LBL(nextY)     "sljedeći godina"
  set LBL(escape)    "Poništi"
  set LBL(delete)    "Obriši"
  set LBL(update)    "Spremi"
  set LBL(moveup)    "Makni gore"
  set LBL(movedn)    "Makni dole"
  set LBL(walkup)    "Premjesti se gore"
  set LBL(walkdn)    "Premjesti se dole"
  set LBL(totoday)   "Prebaci u danas"
  set LBL(totomorow) "Prebaci u sutra"
  set LBL(toever)    "Prebaci u uvik"
  set LBL(todone)    "Prebaci u gotovo"
  set LBL(inschild)  "Novo djete"
  set LBL(levelup)   "Level gore"
  set LBL(leveldn)   "Level dole"
  set LBL(article)   "otvori/zavori tekst"
  set LBL(mark)      "marker"
  set LBL(undr)      "potcrtano"
  set LBL(clear)     "čisti text"
  set LBL(link)      "poveznica"
  set LBL(linktext)  "tekst"
  set LBL(linkaddr)  "adresa (url)"
  set LBL(linkedit)  "uredi poveznicu"
  
  set LBL(helpwtitle) "Help - Kratice na tipkovnici"
  set LBL(helptitle) "Kratice na tipkovnici"
  set LBL(help)      "help" 
  set LBL(about)     "o programu" 
  
}


namespace eval ::gi {
  
  variable OPTIONS
  variable TOP [winfo class .]
  variable top [winfo name .]
  
  lappend OPTIONS *Foreground             $CLR(dark)
  lappend OPTIONS *dl.foreground          $CLR(asidedark)
  lappend OPTIONS $top.status.error.foreground $CLR(error)
  
  lappend OPTIONS *Background            $CLR(light)   
  lappend OPTIONS *Frame.background      $CLR(base)
  lappend OPTIONS *Label.background      $CLR(middle)
  lappend OPTIONS *Button.background     $CLR(middle)
  lappend OPTIONS *Wwdg.Background       $CLR(dark)
  lappend OPTIONS *accordion.background  $CLR(asidemiddle)
  lappend OPTIONS *dl.background         $CLR(asidelight)
  lappend OPTIONS *insgap.background          $CLR(base)
      
  lappend OPTIONS *selectBackground     $CLR(selected2)
  lappend OPTIONS *activeBackground     $CLR(selected3)
  lappend OPTIONS *readonlyBackground   $CLR(readonly)
  lappend OPTIONS *disabledForeground   $CLR(asidemiddle)
  
  
  lappend OPTIONS *BorderWidth                      0
  lappend OPTIONS *Entry.borderWidth                6
  lappend OPTIONS *Button.borderWidth               0
  lappend OPTIONS $top.status.error.borderWidth     2
  lappend OPTIONS $top.status.info.borderWidth      2
  lappend OPTIONS $top.help.title.borderWidth      16
  lappend OPTIONS $top.help.grid.Label.borderWidth  1
  
  lappend OPTIONS *Relief                     flat
  lappend OPTIONS $top.status.error.relief    solid
  lappend OPTIONS $top.status.info.relief     solid
  lappend OPTIONS $top.help.grid.Label.relief solid
  
  
  lappend OPTIONS *Text.Width             50
  lappend OPTIONS *Text.Height            18
  lappend OPTIONS *dl.width               60
  lappend OPTIONS *dl.height               2
  lappend OPTIONS $top.status.info.width  20
  
  
  lappend OPTIONS *Pad             0
  
  lappend OPTIONS *Button.padX     3
  lappend OPTIONS *Text.padX      12
  lappend OPTIONS $top.padX       12
  lappend OPTIONS $top.1.padX      4
  lappend OPTIONS $top.2.padX      4
  lappend OPTIONS $top.3.padX      4
  lappend OPTIONS $top.help.grid.Label.padX      4
  
  lappend OPTIONS *Button.padY     3
  lappend OPTIONS *Text.padY       8
  lappend OPTIONS $top.1.padY      4
  lappend OPTIONS $top.2.padY      4
  lappend OPTIONS $top.3.padY      4
  lappend OPTIONS $top.help.grid.Label.padY      4
  
  
  lappend OPTIONS *HighlightThickness         0
  lappend OPTIONS *Button.highlightThickness  2
  lappend OPTIONS *Entry.highlightThickness   2
  lappend OPTIONS *Text.highlightThickness    2
  
  lappend OPTIONS *HighlightBackground         $CLR(dark)
  lappend OPTIONS *Button.highlightBackground  $CLR(asidemiddle)
  lappend OPTIONS *Entry.highlightBackground   $CLR(light)
  lappend OPTIONS *Text.highlightBackground    $CLR(light)
  
  lappend OPTIONS *HighlightColor       $CLR(selected)
#todo
  for {set id 1} {$id < 7} {incr id} {
    lappend OPTIONS $top.1.0.scroll.$id.highlightThickness  2
  }
  unset id

  
  lappend OPTIONS *Font                   $FNT(def)
  lappend OPTIONS *Entry.font             $FNT(type)
  lappend OPTIONS *Label.font             $FNT(type)
  lappend OPTIONS *Text.font              $FNT(type)
  lappend OPTIONS *accordion.font         $FNT(bold) 
  lappend OPTIONS *dl.font                $FNT(italic)
  lappend OPTIONS $top.status.info.font   $FNT(type)
  lappend OPTIONS $top.status.error.font  $FNT(type) 
  lappend OPTIONS $top.help.title.font    $FNT(bold)
  
  lappend OPTIONS *Text.wrap    word 
  
  lappend OPTIONS $top.help.title.text  $LBL(helptitle) 


#buttons
  lappend OPTIONS *insert.image     $ICO(insert)
  lappend OPTIONS *ok.image         $ICO(ok) 
  lappend OPTIONS *escape.image     $ICO(escape) 
  lappend OPTIONS *update.image     $ICO(update)
  lappend OPTIONS *save.image       $ICO(update)
  lappend OPTIONS *delete.image     $ICO(delete)
  lappend OPTIONS *moveup.image     $ICO(moveup) 
  lappend OPTIONS *movedn.image     $ICO(movedn) 
  lappend OPTIONS *inschild.image   $ICO(inschild)
  lappend OPTIONS *levelup.image    $ICO(levelup)
  lappend OPTIONS *leveldn.image    $ICO(leveldn)
  lappend OPTIONS *mark.image       $ICO(mark)
  lappend OPTIONS *undr.image       $ICO(undr)
  lappend OPTIONS *none.image       $ICO(clear)
  lappend OPTIONS *link.image       $ICO(linkedit)
  lappend OPTIONS *close.image      $ICO(close)
  lappend OPTIONS *go.image         $ICO(smalllink) 
  lappend OPTIONS *article.image    $ICO(article) 
  lappend OPTIONS *totoday.image    $ICO(totoday)
  lappend OPTIONS *totomorow.image  $ICO(totomorow)
  lappend OPTIONS *toever.image     $ICO(toever)
  lappend OPTIONS *todone.image     $ICO(todone)
  lappend OPTIONS *help.image       $ICO(help)
  lappend OPTIONS *about.image      $ICO(about)
       
  lappend OPTIONS *insert.text    $LBL(insert)
  lappend OPTIONS *ok.text        $LBL(ok)
  lappend OPTIONS *escape.text    $LBL(escape)
  lappend OPTIONS *update.text    $LBL(update)
  lappend OPTIONS *save.text      $LBL(update)
  lappend OPTIONS *delete.text    $LBL(delete)
  lappend OPTIONS *moveup.text    $LBL(moveup) 
  lappend OPTIONS *movedn.text    $LBL(movedn) 
  lappend OPTIONS *inschild.text  $LBL(inschild)
  lappend OPTIONS *levelup.text   $LBL(levelup)
  lappend OPTIONS *leveldn.text   $LBL(leveldn)
  lappend OPTIONS *mark.text      $LBL(mark)
  lappend OPTIONS *undr.text      $LBL(undr)
  lappend OPTIONS *none.text      $LBL(clear)
  lappend OPTIONS *link.text      $LBL(linkedit)
  lappend OPTIONS *close.text     $LBL(close)
  lappend OPTIONS *go.text        $LBL(link)
  lappend OPTIONS *article.text   $LBL(article)
  lappend OPTIONS *totoday.text   $LBL(totoday)
  lappend OPTIONS *totomorow.text $LBL(totomorow)
  lappend OPTIONS *toever.text    $LBL(toever)
  lappend OPTIONS *todone.text    $LBL(todone)
  lappend OPTIONS *help.text      $LBL(help)
  lappend OPTIONS *about.text     $LBL(about)

#writter
  lappend OPTIONS *wtitle.background lightblue
  lappend OPTIONS *wtitle.font       $FNT(link)
  
  
  
####calendar
  lappend OPTIONS *centry.justify     center

  lappend OPTIONS *cwdg.borderWidth      2
  lappend OPTIONS *cwdg.background      $CLR(asidedark)
  lappend OPTIONS *cwdg.relief      ridge
                                        
  lappend OPTIONS *clbl.anchor      center
  
  lappend OPTIONS *cbtdy.image  $ICO(today) 
  lappend OPTIONS *cbtdy.text   $LBL(today)
  lappend OPTIONS *cbtpy.image  $ICO(py)    
  lappend OPTIONS *cbtpy.text   $LBL(prevY)
  lappend OPTIONS *cbtpm.image  $ICO(pm)    
  lappend OPTIONS *cbtpm.text   $LBL(prevM)
  lappend OPTIONS *cbtnm.image  $ICO(nm)    
  lappend OPTIONS *cbtnm.text   $LBL(nextM)
  lappend OPTIONS *cbtny.image  $ICO(ny)    
  lappend OPTIONS *cbtny.text   $LBL(nextY)


  foreach {pattern value} $OPTIONS {
    option add $pattern $value
  }
}



# Geometry
namespace eval ::gi {
  variable Geometry
  variable Gridcols
  variable Gridrows
  
  dict set Geometry Sticky wens
  dict set Geometry Anchor center
  dict set Geometry Fill   both
  
  dict set Geometry -side   Button  left 
  dict set Geometry -fill   Button   y
  dict set Geometry -ipadx  Button   4
  dict set Geometry -ipady  Button   4
  dict set Geometry -side   Label   left 
  dict set Geometry -fill   Label   both 
  dict set Geometry -expand Label   1
  dict set Geometry -fill   Entry   x 
  dict set Geometry -expand Entry   1
  #~ dict set Geometry -padx   Entry   {0 1}
  dict set Geometry -pady   Entry   {0 1}
  dict set Geometry -expand Text    1
  
  dict set Geometry -fill     tool       x
  dict set Geometry -expand   tool       1
  dict set Geometry -fill     buttons    x
  dict set Geometry -expand   buttons    1
  dict set Geometry -side     close    right
  
  dict set Geometry -fill     Wwdg       x
  dict set Geometry -expand   Wwdg       1
  dict set Geometry -fill     lst      both
  dict set Geometry -expand   lst        1
  dict set Geometry -side     lst        top
  
  dict set Geometry -fill    insgap   both
  dict set Geometry -expand  insgap    1
  dict set Geometry -side    insgap   left
  
  
  
  dict set Geometry -padx     .1     {0 4}
  dict set Geometry -padx     .2     {0 4}
  dict set Geometry -padx     .3       0
  dict set Geometry -padx     .11    {0 4}
  dict set Geometry -padx     .21    {0 4}
  dict set Geometry -padx     .31      0
  dict set Geometry -pady     .1     {12 0}
  dict set Geometry -pady     .2     {12 0}
  dict set Geometry -pady     .3     {12 0}
  dict set Geometry -row      .1       0
  dict set Geometry -row      .2       0
  dict set Geometry -row      .3       0
  dict set Geometry -row      .11      1
  dict set Geometry -row      .21      1
  dict set Geometry -row      .31      1
  dict set Geometry -column   .1       0
  dict set Geometry -column   .2       1
  dict set Geometry -column   .3       2
  dict set Geometry -column   .11      0
  dict set Geometry -column   .21      1
  dict set Geometry -column   .31      2
  
  dict set Geometry -fill     .1.0     both 
  dict set Geometry -expand   .1.0      1
  dict set Geometry -fill     .2.0     both 
  dict set Geometry -expand   .2.0      1
  dict set Geometry -fill     .3.0     both 
  dict set Geometry -expand   .3.0      1
  dict set Geometry -y        scroll    0
  dict set Geometry -x        scroll    0
  dict set Geometry -relwidth scroll   1.0
  dict set Geometry -anchor   scroll   nw
  
  
  dict set Geometry -columnspan  .status    3
  dict set Geometry -side   .status.info   left    
  dict set Geometry -fill   .status.info   both    
  dict set Geometry -expand .status.info    0
  dict set Geometry -padx   .status.info    1   
  dict set Geometry -pady   .status.info   {6 4}
  dict set Geometry -side   .status.error  left
  dict set Geometry -fill   .status.error  both
  dict set Geometry -expand .status.error   1
  dict set Geometry -padx   .status.error   1
  dict set Geometry -pady   .status.error  {6 4}
  
  dict set Geometry -width  .help         500
  dict set Geometry -height .help         500
  dict set Geometry -side   .help.title   top
  dict set Geometry -fill   .help.grid    x
  dict set Geometry -expand .help.grid    1
  
  dict set Gridcols .1         { -weight 1 -minsize 350 -uniform panes }
  dict set Gridcols .2         { -weight 1 -minsize 350 -uniform panes }
  dict set Gridcols .3         { -weight 1 -minsize 400 -uniform panes }
  dict set Gridrows .1         {-weight 1 -minsize 600} 
  dict set Gridrows .11        {-weight 0 -minsize 40}
  dict set Gridrows .status    {-weight 0 -minsize 48}
  
# todo 
 
  dict set Geometry -fill    accordion  x
  dict set Geometry -expand  accordion  1
  
  dict set Geometry -fill   .1.0.scroll.1  x
  dict set Geometry -fill   .1.0.scroll.2  x
  dict set Geometry -fill   .1.0.scroll.3  x
  dict set Geometry -fill   .1.0.scroll.4  x
  dict set Geometry -fill   .1.0.scroll.5  x
  dict set Geometry -fill   .1.0.scroll.6  x
  dict set Geometry -padx   .1.0.scroll.1  1
  dict set Geometry -padx   .1.0.scroll.2  1
  dict set Geometry -padx   .1.0.scroll.3  1
  dict set Geometry -padx   .1.0.scroll.4  1
  dict set Geometry -padx   .1.0.scroll.5  1
  dict set Geometry -padx   .1.0.scroll.6  1
  dict set Geometry -pady   .1.0.scroll.1  3
  dict set Geometry -pady   .1.0.scroll.2  3
  dict set Geometry -pady   .1.0.scroll.3  3
  dict set Geometry -pady   .1.0.scroll.4  3
  dict set Geometry -pady   .1.0.scroll.5  3
  dict set Geometry -pady   .1.0.scroll.6  3
  

# calendar

  dict set Geometry -fill   calendar  x 
  dict set Geometry -expand calendar  1 
  
  dict set Geometry -fill   ctool     x 
  dict set Geometry -expand ctool     1 
  dict set Geometry -padx   ctool     1 
  dict set Geometry -pady   ctool     1 
  
  dict set Geometry -side   centry    left
  dict set Geometry -expand centry    1
  dict set Geometry -fill   centry    both

  dict set Geometry -fill   cwdg      both
  dict set Geometry -expand cwdg      1
  
  dict set Gridcols -weight cdays 1
  dict set Gridrows -weight cdays 1
  
  dict set Geometry -padx   cbtn   2
  dict set Geometry -pady   cbtn   2
  dict set Geometry -padx   clbl   2
  dict set Geometry -pady   clbl   2
  dict set Geometry -padx   cbtdy  2
  dict set Geometry -pady   cbtdy  2
  dict set Geometry -padx   cbtpy  2
  dict set Geometry -pady   cbtpy  2
  dict set Geometry -padx   cbtpm  2
  dict set Geometry -pady   cbtpm  2
  dict set Geometry -padx   cbtnm  2
  dict set Geometry -pady   cbtnm  2
  dict set Geometry -padx   cbtny  2
  dict set Geometry -pady   cbtny  2
  
  dict set Geometry -side cbtdy left
  dict set Geometry -side cbtpy left
  dict set Geometry -side cbtpm left
  dict set Geometry -side clbl  left
  dict set Geometry -side cbtnm left
  dict set Geometry -side cbtny left
  dict set Geometry -fill cbtdy y
  dict set Geometry -fill cbtpy y
  dict set Geometry -fill cbtpm y
  dict set Geometry -fill clbl  both
  dict set Geometry -fill cbtnm y
  dict set Geometry -fill cbtny y
  dict set Geometry -expand clbl  1
  
# writter
  dict set Geometry -fill   linktool x 
  dict set Geometry -expand linktool 1 
  dict set Geometry -padx   linktool 6 
  dict set Geometry -pady   linktool 1 
  
  dict set Geometry -side   address  top
  
  dict set Geometry -side title left 
}


proc ::gi::geometry {wdg} {
  variable Geometry
  variable Gridrows
  variable Gridcols
  set mng [winfo manager $wdg]
  
  if {$mng eq "wm"} {
    return
  }
  if {$mng ni {pack grid place}} {
    return
  }
    
  set wClass [winfo class $wdg]
  set wName [winfo name $wdg]

  foreach {opt value} [$mng info $wdg] {
    set optName [string totitle [string range $opt 1 end]]
    if       [dict exists $Geometry $opt $wdg] {
      set value [dict get $Geometry $opt $wdg]
    } elseif [dict exists $Geometry $opt $wName] {
      set value [dict get $Geometry $opt $wName]
    } elseif [dict exists $Geometry $opt $wClass] {
      set value [dict get $Geometry $opt $wClass]
    } elseif [dict exists $Geometry $optName] {
      set value [dict get $Geometry $optName] 
    } else {
      set value NOTHING
    }
    
    if {$value ne "NOTHING"} {
      lappend conflist $opt $value
    }
  }

  if {$mng eq "grid"} {
    set pwdg [winfo parent $wdg]
    if [dict exists $Gridcols $wdg] {
      set gridlist [dict get $Gridcols $wdg]
      grid columnconfigure $pwdg $wdg {*}$gridlist
    }
    if [dict exists $Gridrows $wdg] {
      set gridlist [dict get $Gridrows $wdg]
      grid rowconfigure $pwdg $wdg {*}$gridlist
    }
  }

  if [info exists conflist] {
    $mng configure $wdg {*}$conflist
  }
}



