Oxidizer - fractal flames for OSX.

Getting oxidizer from git.

Getting Oxidizer from CVS is easy.

Start Terminal.
Go to or make a folder where you want to put Oxidizer, say ~/Source

cd ~/Source

type the following command then press enter 
git clone git://oxidizer.git.sourceforge.net/gitroot/oxidizer/oxidizer
 
and a few seconds later you should get a folder called oxidizer in the Source folder.

If these instructions do not work check Sourceforge's version at 
https://sourceforge.net/apps/trac/sourceforge/wiki/Git

Open the project in XCode 3.x and compile.

Note that if while building you get an error message :- 
Command /bin/sh failed with exit code 1

You can fix it by following these instructions.
 
In the XCode tree view there's an item called Targets. 
Open that up and there should be a child item for Oxidizer. 
Open that up and double click on the "Run Script" item You should get a window with a CLI script that starts like this....

cd LuaObjCBridge

#xcodebuild -configuration Release

cd ../libpng
echo "Building libpng"

Remove any # characters at the start of any line, like the xcodebuild line above, and build again.

To keep the CVS repository up to date use the following command from the oxidizer folder
created by CVS...

cvs -z3 update -dP 

This will add update the code, add new folders, and remove empty ones.

New commits to CVS are generally announced on the developers blog at

http://www.vargolsoft.net



