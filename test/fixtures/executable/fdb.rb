
module Sprout

  class FDB
    include Executable
    include Daemon

    ##
    # Print a backtrace of all stack frames
    add_param :backtrace, Boolean
    add_param_alias :bt, :backtrace
    add_param_alias :where, :backtrace

    ##
    # Set a breakpoint at specified line or function
    #
    # @example Sets a breakpoint at line 87 of the current file.
    #   break 87
    #
    # @example Sets a breakpoint at line 56 of myapp.mxml
    #   break myapp.mxml:56
    #     
    # @example Sets a breakpoint at line 29 of file #3
    #   break #3:29
    #     
    # @example Sets a breakpoint at function doThis() in the current file
    #   break doThis
    #     
    # @example Sets a breakpoint at function doThat() in file myapp.mxml
    #   break myapp.mxml:doThat
    #     
    # @example Sets a breakpoint at function doOther() in file #3
    #   break #3:doOther
    #     
    # @example Sets a breakpoint at the current execution address in the
    # current stack frame. This is useful for breaking on return
    # to a stack frame.
    #   break
    #
    #  To see file names and numbers, do 'info sources' or 'info files'.
    #  To see function names, do 'info functions'.
    #  Abbreviated file names and function names are accepted if unambiguous.
    #  If line number is specified, break at start of code for that line.
    #  If function is specified, break at start of code for that function.
    #  See 'commands' and 'condition' for further breakpoint control.
    add_param :break, Strings

    ##
    # Halt when an exception is thrown.  This only affects caught
    # exceptions -- that is, exceptions that are going to be handled
    # by a "catch" block.  Uncaught exceptions always halt in the
    # debugger.
    #
    # Use the "delete" command to delete a catchpoint.
    #
    # Examples:
    #
    #   catch *
    #
    # Halts when any exception is thrown.
    #
    #   catch ReferenceError
    #
    # Halts whenever a ReferenceError is thrown
    #
    add_param :catch, Boolean
    add_param_alias :ca, :catch

    ##
    #
    # Display the name and number of the current file
    # or change the current file.
    # Examples:
    #
    #   cf
    #
    # Displays the name and number of the current file.
    #
    #   cf myapp.mxml
    #
    # Changes the current file to myapp.mxml.
    #
    #   cf #29
    #
    # Changes the current file to file #29.
    # To see file names and numbers, do 'info sources' or 'info files'.
    # Abbreviated file names are accepted if unambiguous.
    # Listing a file with 'list' also makes that file the current file.
    #
    add_param :cf, Boolean

    ##
    # Clear breakpoint at specified line or function.
    # Examples:
    #
    #   clear 87
    #   
    # Clears the breakpoint at line 87 of the current file.
    #
    #   clear myapp.mxml:56
    #
    # Clears the breakpoint at line 56 of myapp.mxml.
    #
    #   clear #3:29
    #
    # Clears the breakpoint at line 29 of file #3.
    #
    #   clear doThis
    # 
    # Clears the breakpoint at function doThis() in the current file.
    #
    #   clear myapp.mxml:doThat
    #
    # Clears the breakpoint at function doThat() in file myapp.mxml.
    #
    #   clear #3:doOther
    #
    # Clears the breakpoint at function doOther() in file #3.
    #
    #   clear
    #
    # Clears breakpoint of the current line in the current file.
    # To see file names and numbers, do 'info sources' or 'info files'.
    # To see function names, do 'info functions'.
    # Abbreviated file names and function names are accepted if unambiguous.
    # If line number is specified, all breakpoints in that line are cleared.
    # If function is specified, breakpoints at beginning of function are cleared.
    add_param :clear, Strings
    add_param_alias :cl, :clear

    ##
    # Continue execution after stopping at a breakpoint
    # Specify breakpoint number N to break only if COND is true.
    # Usage is `condition N COND', where N is an integer and COND is an
    # expression to be evaluated whenever breakpoint N is reached.
    add_param :condition, String

    ##
    # Continue execution after stopping at breakpoint.
    # This command takes no arguments.
    add_param :continue, Boolean
    add_param_alias :c, :continue

    ##
    # Set commands to be executed when a breakpoint is hit.
    # Give breakpoint number as argument after `commands`.
    # With no argument, the targeted breakpoint is the last one set.
    # The commands themselves follow starting on the next line.
    # Type a line containing "end" to indicate the end of them.
    # Give "silent" as the first line to make the breakpoint silent;
    # then no output is printed when it is hit, except what the commands print.
    #
    # Example:
    #
    #   (fdb) commands
    #   Type commands for when breakpoint 1 is hit, one per line.
    #   End with a line saying just 'end'.
    #   >w
    #   >end
    add_param :commands, String

    ##
    # Delete one or more breakpoints.
    #
    # Examples:
    #
    #   delete
    #
    # Deletes all breakpoints.
    #
    #   delete 2 5
    #
    # Deletes breakpoints #2 and #5.
    #
    # To see breakpoint numbers, do 'info breakpoints'.
    add_param :delete, Boolean
    add_param_alias :d, :delete

    ##
    # Modify the list of directories in which fdb searches for source files.
    # 
    # Examples:
    # 
    #   directory
    #
    # Restores list to the default, which is the directory in which the source
    # file was compiled into object code, followed by the current working
    # directory.
    # 
    #   directory C:\MySource        (Windows)
    #   directory /MySource          (Mac)
    #
    # Adds the specified directory to the beginning of the list of directories
    # which will be searched for source.  When looking for the source for class
    # mypackage.MyClass, for example, the debugger would look for both
    # C:\MySource\mypackage\MyClass.as and C:\MySource\MyClass.as.
    # 
    #   directory C:\Dir1;C:\Dir2    (Windows -- use ';' as separator)
    #   directory /Dir1:/Dir2        (Mac -- use ':' as separator)
    #
    # Adds several directories to the beginning of the list of directories
    # which will be searched for source.
    # 
    # To see the current list, do 'show directories'.
    add_param :directory, Path
    add_param_alias :dir, :directory

    ##
    # Disable one or more breakpoints or auto-display expressions.
    #
    # Examples:
    #
    #   disable
    #
    #   disable breakpoints
    #
    # Disables all breakpoints.
    #
    #   disable 2 5
    #
    #   disable breakpoints 2 5
    #
    # Disables breakpoints #2 and #5.
    #
    #   disable display
    #
    # Disables all auto-display expressions.
    #
    #   disable display 1 3
    #
    # Disables auto-display expressions #1 and #3.
    #
    # To see breakpoint numbers, do 'info breakpoints'.
    # To see auto-display expression numbers, do 'info display'.
    add_param :disable, Boolean
    add_param_alias :disab, :disable

    ##
    # (ActionScript 2 only; not supported when debugging ActionScript 3)
    # 
    # Disassemble a specified portion of source code.
    # The default is the current listing line.
    # Arguments supported are the same as with the list command
    #
    # Examples:
    #
    # disassemble 87
    #
    # Disassembles line 87 in the current file.
    # 
    # disassemble 87 102
    # disassembles lines 87 to 102 in current file.
    # disassemble doThis
    # 
    # Disassembles the function doThis() in the current file.
    #
    # In addition to using simple line numbers as above, you can specify lines
    # in additional ways:
    #
    #   myapp.mxml
    #           Line 1 in myapp.mxml.
    #   myapp.mxml:doThat
    #           The first line of function doThat() in myapp.mxml.
    #   myapp.mxml:56
    #           Line 56 in myapp.mxml.
    #   #3
    #           Line 1 in file #3.
    #   #3:doOther
    #           The line in file #3 where the function doOther() begins.
    #   #3:29
    #           Line 29 in file #3.
    add_param :disassemble, Boolean
    add_param_alias :disas, :disassemble

    ##
    # Add an auto-display expression
    # Add an expression to the list of auto-display expressions.
    #
    # Example:
    #
    #   display employee.name
    #
    # Add 'employee.name' to the list of auto-display expressions.
    # Every time fdb stops, the value of employee.name will be displayed.
    # The argument for this command is similar to that for 'print'.
    # To see the list of auto-display expressions and their numbers,
    # do 'info display'.
    #
    # NOTE: Removed because the base class adds this param for some reason.
    # Investigate duplicate add_param calls.
    #add_param :display, Boolean
    #add_param_alias :disp, :display
    
    ##
    # Enable breakpoints or auto-display expressions
    add_param :enable, Boolean
    add_param_alias :e, :enable
    
    ##
    # Specify an application to be debugged, without starting it.
    # 
    # Examples:
    #
    #   file http://www.mysite.com/myapp.mxml
    #
    # Specify an MXML application to be debugged.
    #
    #   file myapp.swf
    #
    # Specify a local SWF file to be debugged, in the current directory.
    # In this case myapp.swd (the file containing the debugging information)
    # must also exist in the current directory.
    #
    # This command does not actually cause the application to start;
    # use the 'run' command with no argument to start debugging the application.
    #
    # Instead of using 'file <target>' and then 'run', you can simply specify the
    # application to be debugged as an argument of 'run':
    #
    #   run http://mysite.com/myapp.mxml
    #   run myapp.swf
    #
    # You can also specify the application to be debugged
    # as a command-line argument when you start fdb:
    #
    #   fdb http://www.mysite.com/myapp.mxml
    #
    #   fdb myapp.swf
    #
    # In this case you do not need to use either 'file' or 'run'.
    # If you 'run' without specifying an application to debug,
    # (fdb)
    #
    # will wait for any application to connect to it.
    add_param :file, File, { :required => true, :hidden_name => true }
    add_param_alias :fil, :file

    ##
    # Execute until current function returns.
    # This command takes no arguments.
    add_param :finish, Boolean
    add_param_alias :f, :finish

    ##
    # Specify how fdb should handle a fault in the Flash Player.
    #
    # Examples:
    #
    #   handle recursion_limit stop
    #
    # When a recursion_limit fault occurs, display message in fdb
    # and stop as if at breakpoint.
    #
    #   handle all print nostop
    #
    # When any kind of fault occurs, display message in fdb but don't stop.
    # First argument is a fault name or 'all'.
    # Additional arguments are actions that apply to that fault.
    # To see fault names, do 'info handle'.
    #
    # Actions are print/noprint and stop/nostop.
    # 'print' means print a message if this fault happens.
    # 'stop' means reenter debugger if this fault happens. Implies 'print'.
    add_param :handle, String
    add_param_alias :han, :handle

    ##
    # Display help on FDB commands
    # New to fdb? Do 'tutorial' for basic info.
    # List of fdb commands:
    # bt (bt)             Print backtrace of all stack frames
    # break (b)           Set breakpoint at specified line or function
    # catch (ca)          Halt when an exception is thrown
    # cf (cf)             Display the name and number of the current file
    # clear (cl)          Clear breakpoint at specified line or function
    # condition (cond)    Apply/remove conditional expression to a breakpoint
    # continue (c)        Continue execution after stopping at breakpoint
    # commands (com)      Sets commands to execute when breakpoint hit
    # delete (d)          Delete breakpoints or auto-display expressions
    # directory (dir)     Add a directory to the search path for source files
    # disable (disab)     Disable breakpoints or auto-display expressions
    # disassemble (disas) Disassemble source lines or functions
    # display (disp)      Add an auto-display expressions
    # enable (e)          Enable breakpoints or auto-display expressions
    # file (fil)          Specify application to be debugged.
    # finish (f)          Execute until current function returns
    # handle (han)        Specify how to handle a fault
    # help (h)            Display help on fdb commands
    # home (ho)           Set listing location to where execution is halted
    # info (i)            Display information about the program being debugged
    # kill (k)            Kill execution of program being debugged
    # list (l)            List specified function or line
    # next (n)            Step program
    # print (p)           Print value of variable EXP
    # pwd (pw)            Print working directory
    # quit (q)            Exit fdb
    # run (r)             Start debugged program
    # set (se)            Set the value of a variable
    # source (so)         Read fdb commands from a file
    # step (s)            Step program until it reaches a different source line
    # tutorial (t)        Display a tutorial on how to use fdb
    # undisplay (u)       Remove an auto-display expression
    # viewswf (v)         Set or clear filter for file listing based on swf
    # watch (wa)          Add a watchpoint on a given variable
    # what (wh)           Displays the context of a variable
    # where (w)           Same as bt
    # Type 'help' followed by command name for full documentation.
    add_param :help, Boolean
    add_param_alias :h, :help

    ##
    # Set listing location to where execution is halted
    add_param :home, Path
    add_param_alias :ho, :home

    ##
    # Generic command for showing things about the program being debugged.
    # List of info subcommands:
    # info arguments (i a)    Argument variables of current stack frame
    # info breakpoints (i b)  Status of user-settable breakpoints
    # info display (i d)      Display list of auto-display expressions
    # info files (i f)        Names of targets and files being debugged
    # info functions (i fu)   All function names
    # info handle (i h)       How to handle a fault
    # info locals (i l)       Local variables of current stack frame
    # info scopechain (i sc)  Scope chain of current stack frame
    # info sources (i so)     Source files in the program
    # info stack (i s)        Backtrace of the stack
    # info swfs (i sw)        List of swfs in this session
    # info targets(i t)       Application being debugged
    # info variables (i v)    All global and static variable names
    # Type 'help info' followed by info subcommand name for full documentation.
    add_param :info, Boolean
    add_param_alias :i, :info

    ##
    # Kill execution of program being debugged
    # This command takes no arguments.
    add_param :kill, Boolean
    add_param_alias :k, :kill

    ##
    # List lines of code in a source file.
    #
    # Examples:
    #
    #   list
    # 
    # Lists ten more lines in current file after or around previous listing.
    # 
    #   list -
    # 
    # Lists the ten lines in current file before a previous listing.
    #
    #   list 87
    #
    # Lists ten lines in current file around line 87.
    #
    #   list 87 102
    #
    # Lists lines 87 to 102 in current file.
    #
    # In addition to using simple line numbers as above, you can specify lines
    # in seven additional ways:
    #
    #   doThis
    #
    # The first line of function doThis() in the current file.
    # 
    #   myapp.mxml
    #
    # Line 1 in myapp.mxml.
    #
    #   myapp.mxml:doThat
    #
    # The first line of function doThat() in myapp.mxml.
    #
    #   myapp.mxml:56
    #
    # Line 56 in myapp.mxml.
    # 
    #   #3
    # 
    # Line 1 in file #3.
    #
    #   #3:doOther
    #
    # The line in file #3 where the function doOther() begins.
    #
    #   #3:29
    #
    # Line 29 in file #3.
    #
    # To see file names and numbers, do 'info sources' or 'info files'.
    # To see function names, do 'info functions'.
    # Abbreviated file names and function names are accepted if unambiguous.
    # Listing a file makes that file the current file. (See 'cf' command.)
    add_param :list, String
    add_param_alias :l, :list

    ##
    # Step program, proceeding through subroutine calls.
    #
    #   next
    #
    # Step once.
    #
    #   next 3
    #
    # Step 3 times, or until the program stops for another reason.
    #
    # Like the 'step' command as long as subroutine calls do not happen;
    # when they do, the call is treated as one instruction.
    add_param :next, Boolean
    add_param_alias :n, :next

    ##
    # Print value of variable or expression.
    #
    # Examples:
    #
    #   print i
    # 
    # Print the value of 'i'.
    # 
    #   print employee.name
    #
    # Print the value of 'employee.name'.
    #
    #   print employee
    #
    # Print the value of the 'employee' Object.
    #
    # This may simplay display something like [Object 10378].
    #
    #   print employee.
    #
    # Print the values of all the properties of the 'employee' Object.
    #
    #   print *employee
    # 
    # Print the values of all the properties of the 'employee' Object.
    # The prefix * operator is the prefix alternative to the postfix . operator.
    #
    #   print #10378.
    #
    # Print the values of all the properties of Object #10378.
    # Variables accessible are those of the lexical environment of the selected
    # stack frame, plus all those whose scope is global or an entire file.
    add_param :print, String
    add_param_alias :p, :print

    ##
    # Print the current working directory.
    # This is the directory from which fdb was launched; it cannot be
    # changed within fdb. The argument for 'run' and 'source' can be
    # specified relative to this directory.
    # This command takes no arguments.
    add_param :pwd, Boolean
    add_param_alias :pw, :pwd

    ##
    # Exit FDB
    add_param :quit, Boolean
    add_param_alias :q, :quit

    ##
    # Start a debugging session.
    #
    # Examples:
    #
    #   run http://www.mysite.com/myapp.mxml
    #
    # Runs the specified MXML application.
    #
    #   run myapp.swf
    #   run mydir\myapp.swf
    #   run c:\mydir\myapp.swf
    #
    # Runs the local SWF file myapp.swf, which can be specified
    # either relative to the current directory (see 'pwd' command)
    # or using an absolute path. In these cases, myapp.swd
    # (the file containing the debugging information) must also
    # exist in the same directory as myapp.swf.
    #
    #   run
    #
    # Run the application previously specified by the 'file' command.
    # If no application has been specified, fdb will wait for one
    # to connect to it, and time out if none does so.
    # 'run' will start the application in a browser or standalone Flash Player.
    # As soon as the application starts, it will break into fdb so that you can
    # set breakpoints, etc.
    # 
    # On the Macintosh, the only supported form of the command is 'run' with no
    # arguments.  You must then manually launch the Flash player.
    add_param :run, Boolean
    add_param_alias :r, :run

    ##
    # Set the value of a variable or a convenience variable.
    # Convenience variables are variables that exist entirely
    # within fdb; they are not part of your program.
    # Convenience variables are prefixed with '$' and can
    # be any name that does not conflict with any existing
    # variable.  For example, $myVar.  Convenience variables
    # are also used to control various aspects of fdb.
    # 
    # The following convenience variables are used by fdb.
    # $listsize          - number of source lines to display for 'list'
    # $columnwrap        - column number on which output will wrap
    # $infostackshowthis - if 0, does not display 'this' in stack backtrace
    # $invokegetters     - if 0, prevents fdb from firing getter functions
    # $bpnum             - the last defined breakpoint number
    # $displayattributes - if 1, 'print var.' displays all attributes of members
    #                      of 'var' (e.g. private, static)
    # 
    # Examples:
    #
    #   set i = 3
    # 
    # Sets the variable 'i' to the number 3.
    #
    #   set employee.name = "Susan"
    #
    # Sets the variable 'employee.name' to the string "Susan".
    #
    #   set $myVar = 20
    #
    # Sets the convenience variable '$myVar' to the number 20
    add_param :set, String
    add_param_alias :se, :set

    ##
    # Read fdb commands from a file and execute them.
    #
    #   source mycommands.txt
    #   source mydir\mycommands.txt
    #   source c:\mydir\mycommands.txt
    #
    # Reads mycommands.txt and executes the fdb commands in it.
    # The file containing the commands can be specified either
    # relative to the current directory (see 'pwd' command)
    # or using an absolute path.
    #
    # The file .fdbinit is read automatically in this way when fdb is started.
    # Only the current directory is searched for .fdbinit. This means that
    # you can have set up multiple .fdbinit files for different projects.
    add_param :source, File
    add_param_alias :so, :source

    ##
    # Step program until it reaches a different source line.
    #
    # Examples:
    #
    #   step
    #
    # Step once.
    #
    #   step 3
    #
    # Step 3 times, or until the program stops for another reason.
    add_param :step, Boolean
    add_param_alias :s, :step

    ##
    # Display a tutorial on how to use fdb.
    # This command takes no arguments.
    add_param :tutorial, Boolean
    add_param_alias :t, :tutorial
    
    ##
    # Remove one or more auto-display expressions.
    #
    # Examples:
    #
    #   undisplay
    #
    # Remove all auto-display expressions.
    #
    #   undisplay 2 7
    #
    # Remove auto-display expressions #2 and #7.
    #
    # To see the list of auto-display expressions and their numbers,
    # do 'info display'.
    add_param :undisplay, Boolean
    add_param_alias :u, :undisplay

    ##
    # Set or clear a filter for file listing based on SWF
    add_param :viewswf, Boolean
    add_param_alias :v, :viewswf

    ##
    # Add a watchpoint on a given variable. The debugger will halt
    # execution when the variable's value changes.
    #
    # Example:
    # 
    #   watch foo
    #
    add_param :watch, String
    add_param_alias :wa, :watch

    ##
    # Displays the context in which a variable is resolved.
    add_param :what, String
    add_param_alias :wh, :what

    set :default_prefix, '-'

    ##
    # The default gem name
    set :pkg_name, 'flex4sdk'

    ##
    # The default gem version
    set :pkg_version, '>= 1.0.0.pre'

    ##
    # The default executable target
    set :executable, :fdb

  end
end

##
# Rake task helper that delegates to
# the FDB executable.
#
#    fdb 'bin/SomeProject.swf' do |t|
#      t.break << 'com/foo/bar/SomeClass.as:23'
#      t.continue
#      t.run
#    end
#
def fdb *args, &block
  fdb_tool = Sprout::FDB.new
  fdb_tool.to_rake *args, &block
  fdb_tool
end

