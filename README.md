# Voc

A physical model of the vocal tract.

Things you'll need:

- CWEB (this often comes with TeX)
- [Soundpipe (dev branch)](http://www.github.com/paulbatchelor/soundpipe.git)
- [Sporth](http://www.github.com/paulbatchelor/sporth.git) (somewhat optional)
- sporth_tex (can be installed with Sporth by running "make sporth_tex" in the
sporth codebase)
- GNUplot (needed to generate visuals)

Running "make" with no arguments will run cweave and compile voc.pdf. Because
the program needs to compile programs needed by the tex file, ctangle is
implicitely called yield all the C code. The core C files generated are 
*voc.c* and *voc.h*. These can more or less be dropped into a working project
and it will behave like any other soundpipe module. The exception to this is
that you will need to use setter and getter functions to set and retrieve
parameters in Voc. 
