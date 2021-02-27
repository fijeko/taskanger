package require Tcl 8.6
package require sqlite3
package require wstatus 1.0

package provide domain 1.0

namespace eval ::domain {
  variable appID 77777
  variable version 1
  variable database {}
}

proc ::domain::updateTodo {rowid value} {
  SQLCMD eval {UPDATE todos SET todo=:value WHERE rowid=:rowid}
}
proc ::domain::updateTask {rowid value} {
  SQLCMD eval {UPDATE tasks SET task=:value WHERE id=:rowid}
}
proc ::domain::updateThema {rowid value} {
  SQLCMD eval {UPDATE theme SET thema=:value WHERE rowid=:rowid}
}


proc ::domain::insertTodo {done datum rang rowids} {
  SQLCMD transaction {
    SQLCMD eval {INSERT INTO todos(done,datum,rang,todo)
                        VALUES(:done,:datum,:rang,'') }
    set lastRowid [SQLCMD last_insert_rowid]
    foreach chRowid $rowids {
      SQLCMD eval {UPDATE todos SET rang=rang+1 WHERE rowid=:chRowid}
    }
  }
  return $lastRowid
}
proc ::domain::insertTask {parent rang rowids} {
  SQLCMD transaction {
    SQLCMD eval {INSERT INTO tasks(parent,rang,task)
                    VALUES(:parent,:rang,'') }
    set lastRowid [SQLCMD last_insert_rowid]
    foreach chRowid $rowids {
      SQLCMD eval {UPDATE tasks SET rang=rang+1 WHERE id=:chRowid}
    }
  }
  return $lastRowid
}
proc ::domain::insertThema {rang rowids} {
  SQLCMD transaction {
    SQLCMD eval {INSERT INTO theme(rang,thema)
                    VALUES(:rang,'') }
    set lastRowid [SQLCMD last_insert_rowid]
    foreach chRowid $rowids {
      SQLCMD eval {UPDATE theme SET rang=rang+1 WHERE rowid=:chRowid}
    }
  }
  return $lastRowid
}

proc ::domain::deleteTodo {rowid rowids} {
  SQLCMD transaction {
    SQLCMD eval {DELETE FROM todos WHERE rowid=:rowid}
    foreach chRowid $rowids {
      SQLCMD eval {UPDATE todos SET rang=rang-1 WHERE rowid=:chRowid}
    }
  }
}
proc ::domain::deleteTask {rowid rowids} {
  SQLCMD eval {PRAGMA foreign_keys = ON}
  SQLCMD transaction {
    SQLCMD eval {DELETE FROM tasks WHERE id=:rowid}
    foreach rowid_ $rowids {
      SQLCMD eval {UPDATE tasks SET rang=rang-1 WHERE id=:rowid_}
    }
  }
  SQLCMD eval {PRAGMA foreign_keys = OFF}
}
proc ::domain::deleteThema {rowid rowids} {
  SQLCMD transaction {
    SQLCMD eval {DELETE FROM theme WHERE rowid=:rowid}
    foreach rowid_ $rowids {
      SQLCMD eval {UPDATE theme SET rang=rang-1 WHERE rowid=:rowid_}
    }
  }
}

proc ::domain::updateTodoRangs {rowidUp rowidDn} {
  SQLCMD transaction {
    SQLCMD eval {UPDATE todos SET rang=rang+1 WHERE rowid=:rowidUp}
    SQLCMD eval {UPDATE todos SET rang=rang-1 WHERE rowid=:rowidDn}
  }
}
proc ::domain::updateTaskRangs {rowidUp rowidDn} {
  SQLCMD transaction {
    SQLCMD eval {UPDATE tasks SET rang=rang+1 WHERE id=:rowidUp}
    SQLCMD eval {UPDATE tasks SET rang=rang-1 WHERE id=:rowidDn}
  }
}
proc ::domain::updateThemaRangs {rowidUp rowidDn} {
  SQLCMD transaction {
    SQLCMD eval {UPDATE theme SET rang=rang+1 WHERE rowid=:rowidUp}
    SQLCMD eval {UPDATE theme SET rang=rang-1 WHERE rowid=:rowidDn}
  }
}

# moveto
proc ::domain::updateTodoRecord {rowid done datum rang rowids} {
  SQLCMD transaction {
    SQLCMD eval {UPDATE todos SET
        done=:done, datum=:datum, rang=:rang WHERE rowid=:rowid}
    foreach rowid $rowids {
      SQLCMD eval {UPDATE todos SET rang=rang-1 WHERE rowid=:rowid}
    }
  }
}

# level up dn
proc ::domain::updateTaskLevels {id parent rang oldrowids newrowids} {
  SQLCMD transaction {
    SQLCMD eval {UPDATE tasks SET parent=:parent, rang=:rang WHERE id=:id}

    foreach oldId $oldrowids {
      SQLCMD eval {UPDATE tasks SET rang=rang-1 WHERE id=:oldId}
    }
    set rang 0
    foreach newId $newrowids {
      SQLCMD eval {UPDATE tasks SET rang=rang+1 WHERE id=:newId}
    }
  }
} 


#~ context tags marks links wins
proc ::domain::selectThemaArticle {rowid} {
  SQLCMD eval {
    SELECT article,tags,marks,wins FROM theme WHERE rowid=:rowid
  }
}
proc ::domain::updateThemaArticle {rowid article tags marks wins} {
  SQLCMD eval {UPDATE theme
    SET article=:article, tags=:tags, marks=:marks, wins=:wins
    WHERE rowid=:rowid
  }
}



# initialy load all data from database
proc ::domain::connect {dbname errvariable} {
  try {
    Connect $dbname
  } on error {e o} {
    ::TskngrError $e $o {DATABASE ERROR}
    if {$errvariable ne {}}  {
      set $errvariable "error in [file tail $dbname]"
    }
    Connect ":memory:"
  }
  return
}


proc ::domain::Connect {dbname} {
  variable appID
  variable version
  
  
  set create [expr {[file exists $dbname] ? false : true}]
  sqlite3 SQLCMD $dbname
  
  if $create {
    Create
  } 
  lassign [Check] uv id 
  if {$id ne $appID} {
    return -code 1 "error in $dbname" 
  }
}

proc ::domain::Create {} {
  variable appID
  variable version
  SQLCMD eval [subst {PRAGMA application_id = $appID}]
  SQLCMD eval [subst {PRAGMA user_version = $version}]
  SQLCMD eval {CREATE TABLE todos
    (done INT, datum TEXT, rang INT, todo TEXT)}
      
  SQLCMD eval {CREATE TABLE tasks
    (id INTEGER, parent INTEGER, rang INTEGER, task TEXT,
    PRIMARY KEY(id),
    FOREIGN KEY(parent) REFERENCES tasks(id)
      ON UPDATE CASCADE
      ON DELETE CASCADE)
  }
  SQLCMD eval {INSERT INTO tasks(id) VALUES(0)}
  
  SQLCMD eval {CREATE TABLE theme
    (rang INT, thema TEXT, article TEXT,
      tags TEXT, marks TEXT, wins TEXT)}
}

proc ::domain::Check {} {
  
  return [list \
    [SQLCMD eval {PRAGMA user_version}] \
    [SQLCMD eval {PRAGMA application_id}]]
}


# todo table
proc ::domain::TodoLista {} {
  lappend todos_tmp_list \
    1 [TodoPastDatums] 0\
    2 [TodoDay 0] 0 \
    3 [TodoDay 1] 0 \
    4 {0000-00-00} 0 \
    5 [TodoDailyDatums] 0\
    6 [TodoDoneDatums] 1
  
  foreach {section datums done} $todos_tmp_list {
    lappend todos $section
    foreach datum $datums {
      set tmp_records [TodoRecords $datum $done]
      if {$tmp_records != {}} {
        lappend tmp_todo_list $datum $tmp_records
      }
    }
    if [info exists tmp_todo_list] {
      lappend todos $tmp_todo_list
      unset tmp_todo_list
    } else {
      lappend todos {}
    }
  }
  return $todos
}
proc ::domain::TodoRecords {datum done} {
  SQLCMD eval {
    SELECT rowid, todo FROM todos
    WHERE datum=:datum AND done=:done
    ORDER BY rang
  }
}
proc ::domain::TodoPastDatums {} {
  set done 0 
  SQLCMD eval {
    SELECT DISTINCT datum FROM todos 
      WHERE done=:done AND datum<date('now') AND datum!='0000-00-00'
      ORDER BY datum
  }
}
proc ::domain::TodoDailyDatums {} {
  set done 0
  SQLCMD eval {
      SELECT DISTINCT datum FROM todos 
          WHERE done=:done AND datum>date('now','+1 day')
          ORDER BY datum
  }
}
proc ::domain::TodoDoneDatums {} {
  set done 1
  SQLCMD eval {
      SELECT DISTINCT datum FROM todos 
          WHERE done=:done ORDER BY datum DESC
  }
}
proc ::domain::TodoDay {span} {
  if {$span=="ever"} {
    return 0000-00-00
  }
  return [clock format \
    [clock add [clock seconds] $span day -timezone :UTC] \
      -format "%Y-%m-%d" -timezone :UTC]
}


# task table
proc ::domain::TaskLista args {

  if ![llength $args] {
    set id 0
    set path ""
    set tree {}
  } else {
    set id [lindex $args 0]
    set path [lindex $args 1]
    lassign [TaskRecord $id] id task
    if {$path!=""} {
      lappend path $id
    } else {
      set path $id
    } 
    set row [list $path $task]
  }
  
  set children [TaskChildrenIds $id]
  foreach child $children {
    lappend row {*}[TaskLista $child $path]
  }
  if [info exist row] {
    return $row
  }
  return
}
proc ::domain::TaskRecord {id} {
  SQLCMD eval {SELECT id, task FROM tasks WHERE id=:id ORDER BY rang}
}
proc ::domain::TaskChildrenIds {id} {
  SQLCMD eval {
    SELECT id FROM tasks WHERE parent=:id ORDER BY rang
  }
}


# thema table
proc ::domain::ThemaLista {} {
  SQLCMD eval {SELECT rowid,thema,article,tags,marks,wins FROM theme ORDER BY rang}
}

