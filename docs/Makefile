# Makefile
#

TEXFILES = catppuccin-latte.sty catppuccin-mocha.sty colorthemes.sty \
		   cornercommands.sty generalcommands.sty generalsubctikz.sty \
		   generaltikzset.sty abstract.tex main.tex preamble.tex

# PDFFILES = onebitalu/section.pdf counter/section.pdf
#

BASICCIRUITS = basiccircuits/section.tex
COUNTER = counter/section.tex
FINALSCHEMATICS = finalschematics/section.tex
INITIALIZER = initializer/section.tex
INTRODUCTION = introduction/section.tex
MEMORYUNIT = memoryunit/section.tex
ONEBITALU = onebitalu/section.tex
TESTBENCH = testbench/section.tex

main: viewpdf

viewpdf: main.pdf
	viewpdf main.pdf

.SUFFIXES: .tex .pdf

.tex.pdf:
	pdflatex -draftmode -shell-escape -halt-on-error $<
	pdflatex -shell-escape -halt-on-error $<
	touch  $(addsuffix .pdf, $(basename $<))


main.pdf: $(TEXFILES) $(COUNTER) $(BASICCIRUITS) $(FINALSCHEMATICS) $(INITIALIZER) $(INTRODUCTION) $(MEMORYUNIT) $(ONEBITALU) $(TESTBENCH)

# onebitalu/section.pdf: $(TEXFILES) $(ONEBITALU)
# counter/section.pdf: $(TEXFILES) $(COUNTER)

.PHONY: main viewpdf
