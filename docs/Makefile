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

main: _viewpdf

_viewpdf: runlunatikz main.pdf
	viewpdf main.pdf

viewpdf:
	[ -e main.pdf ] && vewpdf main.pdf || printf "main.pdf doesn't exist, run make\n"

.SUFFIXES: .tex .pdf

runlunatikz:
	lunatikz --style-root-path --style-file colorthemes.sty --style-macro usepackage \
		--touch-file need_to_build main.tex

.tex.pdf:
	pdflatex -draftmode -shell-escape -halt-on-error $<
	pdflatex -shell-escape -halt-on-error $<
	touch  $(addsuffix .pdf, $(basename $<))


main.pdf: $(TEXFILES) $(COUNTER) $(BASICCIRUITS) $(FINALSCHEMATICS) $(INITIALIZER) $(INTRODUCTION) $(MEMORYUNIT) $(ONEBITALU) $(TESTBENCH) tikzpics/need_to_build

# onebitalu/section.pdf: $(TEXFILES) $(ONEBITALU)
# counter/section.pdf: $(TEXFILES) $(COUNTER)

.PHONY: main viewpdf runlunatikz _viewpdf
