Oxidizer - fractal flames for OSX.

Getting oxidizer from CVS.

Getting Oxidizer from CVS is easy.

Start Terminal.
Go to or make a folder where you want to put Oxidizer, say ~/Source

cd ~/Source

type the follwoing command the press enter 
cvs -d:pserver:anonymous@cvs.sourceforge.net:/cvsroot/oxidizer login 
 
You'll get a prompt for the CVS password, just press enter again. 
Then enter the follwoing command 
cvs -z3 -d:pserver:anonymous@cvs.sourceforge.net:/cvsroot/oxidizer co -P oxidizer

and a few seconsd later you should get a folder call oxidizer in the Source folder.

Open the project in XCode and compile.
