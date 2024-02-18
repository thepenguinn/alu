# Makefile
#

TEXFILES = ../catppuccin-latte.sty ../catppuccin-mocha.sty ../colorscheme.sty \
		   ../cornercommands.sty ../generalcommands.sty ../generalsubctikz.sty \
		   ../generaltikzset.sty ../abstract.tex ../main.tex ../preamble.tex

FINALSCHEMATICS = chapter.tex
ONEBITALU = ../onebitalu/chapter.tex
COUNTER = ../counter/chapter.tex
INITIALIZER = ../initializer/chapter.tex
MEMORYUNIT = ../memoryunit/chapter.tex

chapter: _viewpdf

viewpdf:
	[ -e chapter.pdf ] && viewpdf chapter.pdf || printf "chapter.pdf doesn't exist, run make\n"

_viewpdf: runlunatikz chapter.pdf
	viewpdf chapter.pdf

runlunatikz:
	lunatikz build

.SUFFIXES: .tex .pdf

.tex.pdf:
	pdflatex -shell-escape -halt-on-error $<
	touch  $(addsuffix .pdf, $(basename $<))


chapter.pdf: $(TEXFILES) $(FINALSCHEMATICS) $(ONEBITALU) $(COUNTER) $(INITIALIZER) $(MEMORYUNIT) tikzpics/need_to_build

.PHONY: chapter viewpdf _viewpdf runlunatikz
