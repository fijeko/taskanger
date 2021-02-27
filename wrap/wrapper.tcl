package require Tcl     8.6

namespace eval ::wrapper { }

proc ::wrapper::wrapper {} {
  if [lassign [Setup] exe1 exe2 output1 output2 flist mscript msg] {
    exec $exe1 $mscript -f $flist -o $output1
    exec $exe1 $mscript -f $flist -w $exe2 -o $output2
    #~ puts "$exe1 $mscript -f $flist -o $output1"
    #~ puts "$exe1 $mscript -f $flist -w $exe2 -o $output2"
    puts "created: $output1 and $output2"
  } else {
    puts "ERROR: $msg"
  }
}

proc ::wrapper::Setup {} {
  set dir     wrap
  set wrap    freewrap
  set appdir  app
  set appname taskanger
  set flist   fileslist
  set mainscript wrap_taskanger.tcl
  set exclscript taskanger.tcl
  
  if [catch {CheckFreewrap $dir $wrap $appname} wrap] {
    return [list - - - - - - $wrap false] 
  }
  
  lassign $wrap exe1 exe2 output1 output2
  
  if [catch {CreateList $appdir $mainscript $exclscript $dir $flist} alist] {
    return [list - - - - - - $alist false] 
  }
  
  return [list {*}$wrap {*}$alist - true]
}

proc ::wrapper::CheckFreewrap {dir wrap appname} {
  
  set file1 [file join $dir $wrap]
  set file2 [file join $dir $wrap.exe]
  
  if {![file exists $file1] || ![file exists $file1]} {
    return -code 1 "missing freewrap
download from http://freewrap.sourceforge.net/freeWrapDocs.pdf"
  }
  
  set output [file join $dir $appname]
  
  if {$::tcl_platform(platform) eq "unix"} {
    set exe1 $file1
    set exe2 $file2
    set output1 $output
    set output2 $output.exe
  } else {
    set exe1 $file2
    set exe2 $file1
    set output1 $output.exe
    set output2 $output
  }
  return  [list $exe1 $exe2 $output1 $output2]
}

  
proc ::wrapper::CreateList {appdir mscript escript dir flist} {
  set mscript [file join $appdir $mscript]
  set escript [file join $appdir $escript]
  set exclude [list $mscript $escript]
  set flist [file join $dir $flist]
  
  foreach fn [glob -directory $appdir -type f *] {
    if {$fn in $exclude} {
      continue
    }
    lappend new_list $fn
  }
  foreach dn [glob -directory $appdir -type d *] {
    lappend new_list {*}[glob $dn/*]
  }
  
  try {
    set fl [open $flist {WRONLY CREAT TRUNC}]
    foreach line $new_list {
      puts $fl $line
    }
    close $fl
  } on error {e o} {
    close $fl
    return -code 1 $e
  }
  
  return [list $flist $mscript]
}


     
::wrapper::wrapper
