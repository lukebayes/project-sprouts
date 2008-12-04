=begin
Copyright (c) 2007 Pattern Park

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

TODO: Investigate jruby support, especially:
    http://livedocs.adobe.com/flex/201/html/wwhelp/wwhimpl/common/html/wwhelp.htm?context=LiveDocs_Book_Parts&file=compilers_123_09.html
=end

module Sprout
  class FCSHError < StandardError #:nodoc:
  end

  # Look for $USER_TMP_DIR/fcsh.pid
  #   If found, look in the file for current project directory as hash key
  #   If found, grab the port number for this project directory and connect
  # If no pid file or no existing service indexed for this project directory:
  #   Fork a new process with FCSHService at some available port
  #   add project directory and port number to $USER_TMP_DIR/fcsh.pid
  # Once FCSH has been started remind the user that they'll need to run
  # rake fcsh:stop to kill the process associated with this project.
  #
  # If this system cannot fork (Windoze), prompt the user to run rake fcsh:start
  
  class FCSHClient
  end
end
