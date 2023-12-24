# Makefile
#

TEXFILES = catppuccin-latte.sty catppuccin-mocha.sty colorthemes.sty \
		   cornercommands.sty generalcommands.sty generalsubctikz.sty \
		   generaltikzset.sty abstract.tex main.tex preamble.tex

# PDFFILES = onebitalu/section.pdf counter/section.pdf
#

BASICCIRUITS = basiccircuits/section.tex basiccircuits/tikzset.tex basiccircuits/subctikz.tex
COUNTER = counter/section.tex counter/tikzset.tex counter/subctikz.tex
FINALSCHEMATICS = finalschematics/section.tex finalschematics/tikzset.tex finalschematics/subctikz.tex
INITIALIZER = initializer/section.tex initializer/tikzset.tex initializer/subctikz.tex
INTRODUCTION = introduction/section.tex introduction/tikzset.tex introduction/subctikz.tex
MEMORYUNIT = memoryunit/section.tex memoryunit/tikzset.tex memoryunit/subctikz.tex
ONEBITALU = onebitalu/section.tex onebitalu/tikzset.tex onebitalu/subctikz.tex
TESTBENCH = testbench/section.tex testbench/tikzset.tex testbench/subctikz.tex

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
