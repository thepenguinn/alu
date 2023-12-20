# Makefile
#

TEXFILES = ../main.tex ../generalcommands.sty ../generaltikzset.sty ../cornercommands.sty ../preamble.tex ../generalsubctikz.sty

FINALSCHEMATICS = section.tex tikzset.tex subctikz.tex
ONEBITALU = ../onebitalu/section.tex ../onebitalu/tikzset.tex ../onebitalu/subctikz.tex
COUNTER = ../counter/section.tex ../counter/tikzset.tex ../counter/subctikz.tex
INITIALIZER = ../initializer/section.tex ../initializer/tikzset.tex ../initializer/subctikz.tex
MEMORYUNIT = ../memoryunit/section.tex ../memoryunit/tikzset.tex ../memoryunit/subctikz.tex

section: viewpdf

viewpdf: section.pdf
	viewpdf section.pdf

.SUFFIXES: .tex .pdf

.tex.pdf:
	pdflatex -shell-escape -halt-on-error $<
	touch  $(addsuffix .pdf, $(basename $<))


section.pdf: $(TEXFILES) $(FINALSCHEMATICS) $(ONEBITALU) $(COUNTER) $(INITIALIZER) $(MEMORYUNIT)

.PHONY: section viewpdf
