# Makefile
#

TEXFILES = ../catppuccin-latte.sty ../catppuccin-mocha.sty ../colorthemes.sty \
		   ../cornercommands.sty ../generalcommands.sty ../generalsubctikz.sty \
		   ../generaltikzset.sty ../abstract.tex ../main.tex ../preamble.tex

FINALSCHEMATICS = section.tex
ONEBITALU = ../onebitalu/section.tex
COUNTER = ../counter/section.tex
INITIALIZER = ../initializer/section.tex
MEMORYUNIT = ../memoryunit/section.tex

section: viewpdf

viewpdf: section.pdf
	viewpdf section.pdf

.SUFFIXES: .tex .pdf

.tex.pdf:
	pdflatex -shell-escape -halt-on-error $<
	touch  $(addsuffix .pdf, $(basename $<))


section.pdf: $(TEXFILES) $(FINALSCHEMATICS) $(ONEBITALU) $(COUNTER) $(INITIALIZER) $(MEMORYUNIT)

.PHONY: section viewpdf
