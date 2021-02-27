package require tcltest 2

::tcltest::configure \
  -testdir [file dirname [file normalize [info script]]] \
  -verbose error


if {$argv ne {}} {
  set tests_filelist [lsort [glob \
    -nocomplain -tails -directory [file join [pwd] test] -- \
    "*{[join $argv ,]}*.test"]]

  ::tcltest::configure -file $tests_filelist
  
}

#~ ::tcltest::configure -file 10.domain.test
  #~ 10.domain.test
  #~ 20.gi.test
  #~ 22.calendar.test 
  #~ 24.writter.test
  #~ 26.wentry.test 
  #~ 30.todo.test 
  #~ 40.task.test 
  #~ 50.thema.test
  #~ 61.wscroll.test 
  #~ 62.help.test 
  #~ 70.frames.test 
  #~ 90.utils.test
  #~ 91.wrapper.test


::tcltest::configure -load {
  ::tcltest::testConstraint showFrames true
  
  set ::TSKNGR_APPDIR [file join [pwd] app]
  set ::TSKNGR_WORKDIR [pwd]
  set ::CONTINUE_AFTER_ 0
  
  lappend  auto_path [file join $::TSKNGR_APPDIR]
  
  interp bgerror "" ::TskngrBgerror
  proc ::TskngrBgerror {msg opts} {
      ::TskngrError $msg $opts "BACKGROUND ERROR"
  }
  proc ::TskngrError {msg opts {title ERROR}} {
    # only for test not complain
  }
  
  proc ::tcltest::wait_until_ {{duration 300000} args} {
    after $duration {set ::endthistest true} 
    set ::endthistest false
    wm protocol . WM_DELETE_WINDOW { 
      set ::endthistest true 
    }
    tkwait variable ::endthistest
    
    catch {destroy .}
    return
  }
  
  #~ proc ::tcltest::destroy_after_ {{duration 300000} args} {
    #~ after $duration {destroy .} 
    #~ return
  #~ }
}


proc tcltest::cleanupTestsHook {} {
  variable numTests
  upvar 2 testFileFailures crashed 
  incr ::AllTestTotal(Failed)  $numTests(Failed) 
  incr ::AllTestTotal(Passed)  $numTests(Passed) 
  incr ::AllTestTotal(Skipped) $numTests(Skipped)
  incr ::AllTestTotal(Total)   $numTests(Total)
  if [info exists crashed] {
    incr ::AllTestTotal(Crashed)
  }
}
array set ::AllTestTotal {
  Failed   0
  Passed   0
  Skipped  0
  Total    0
  Crashed  0
}


::tcltest::runAllTests

puts "TOTAL:\t\t\t$::AllTestTotal(Total) 
    FAILED:\t\t$::AllTestTotal(Failed) 
    CRASHED:\t$::AllTestTotal(Crashed)"


