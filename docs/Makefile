# Makefile
#

TEXFILES = catppuccin-latte.sty catppuccin-mocha.sty colorscheme.sty \
		   cornercommands.sty generalcommands.sty generalsubctikz.sty \
		   generaltikzset.sty abstract.tex main.tex preamble.tex

# PDFFILES = onebitalu/chapter.pdf counter/chapter.pdf
#

BASICCIRUITS = basiccircuits/chapter.tex
COUNTER = counter/chapter.tex
FINALSCHEMATICS = finalschematics/chapter.tex
INITIALIZER = initializer/chapter.tex
INTRODUCTION = introduction/chapter.tex
MEMORYUNIT = memoryunit/chapter.tex
ONEBITALU = onebitalu/chapter.tex
TESTBENCH = testbench/chapter.tex

main: _viewpdf

_viewpdf: runlunatikz main.pdf
	viewpdf main.pdf

viewpdf:
	[ -e main.pdf ] && viewpdf main.pdf || printf "main.pdf doesn't exist, run make\n"

.SUFFIXES: .tex .pdf

runlunatikz:
	lunatikz build

.tex.pdf:
	pdflatex -draftmode -shell-escape -halt-on-error $<
	pdflatex -shell-escape -halt-on-error $<
	touch  $(addsuffix .pdf, $(basename $<))


main.pdf: $(TEXFILES) $(COUNTER) $(BASICCIRUITS) $(FINALSCHEMATICS) $(INITIALIZER) $(INTRODUCTION) $(MEMORYUNIT) $(ONEBITALU) $(TESTBENCH) tikzpics/need_to_build

# onebitalu/chapter.pdf: $(TEXFILES) $(ONEBITALU)
# counter/chapter.pdf: $(TEXFILES) $(COUNTER)

.PHONY: main viewpdf runlunatikz _viewpdf
