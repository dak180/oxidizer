Oxidizer - fractal flames for OSX.

Getting oxidizer from CVS.

Getting Oxidizer from CVS is easy.

Start Terminal.
Go to or make a folder where you want to put Oxidizer, say ~/Source

cd ~/Source

type the follwoing command the press enter 
cvs -d:pserver:anonymous@oxidizer.cvs.sourceforge.net:/cvsroot/oxidizer login 

 
You'll get a prompt for the CVS password, just press enter again. 
Then enter the follwoing command 

cvs -z3 -d:pserver:anonymous@oxidizer.cvs.sourceforge.net:/cvsroot/oxidizer co -P oxidizer

and a few seconds later you should get a folder call oxidizer in the Source folder.
If these instructions do not work check Sourceforge's version at 
http://sourceforge.net/cvs/?group_id=159210

Open the project in XCode 2.4 and compile. Note that attempting to open the project
in older version of XCode may or may not work. It definitely does not work in 2.0.

To keep the CVS repository up to date use the following command from the oxidizer folder
created by CVS...

cvs -z3 update -dP 

This will add update the code, add new folders, and remove empty ones.

New commits to CVS are generally announced on the developers blog at

http://www.vargolsoft.net



