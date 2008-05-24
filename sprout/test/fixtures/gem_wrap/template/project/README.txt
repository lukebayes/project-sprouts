
########################################
This project was generated using Sprouts
http://code.google.com/p/projectsprouts/

Please report any bugs to:
http://code.google.com/p/projectsprouts/issues/list

Please feel free to ask questions at:
http://groups.google.com/group/projectsprouts

########################################
Using your favorite terminal, cd to this directory have fun!

########################################
To create a new ActionScript class, TestCase and rebuild all project TestSuites:

script/generate class -s utils.MathUtil

########################################
To create a new Interface begin the name with I + Capital letter (eg: ISomeName)
or end the name with 'able'

Name begins with Capital 'I' followed by another capital letter
script/generate class utils.ISomeName 

or

Name ends with 'able'
script/generate class utils.Observable

or

Explicitly identify interface creation
script/generate interface utils.SomeInterface

########################################
To create a new TestCase only, enter the following:

script/generate test utils.SomeTest

########################################
To compile and launch your application:

rake

########################################
To compile and launch your test suites:

rake test

########################################
To see all available rake tasks:

rake -T

