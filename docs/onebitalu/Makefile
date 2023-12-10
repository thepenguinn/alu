# Makefile
#

TEXFILES = ../main.tex ../generalcommands.sty ../generaltikzset.sty ../cornercommands.sty ../preamble.tex ../generalsubctikz.sty

ONEBITALU = section.tex tikzset.tex subctikz.tex

section: section.pdf

.SUFFIXES: .tex .pdf

.tex.pdf:
	pdflatex -shell-escape -halt-on-error $<
	viewpdf $(addsuffix .pdf, $(basename $<))
	touch  $(addsuffix .pdf, $(basename $<))


section.pdf: $(TEXFILES) $(ONEBITALU)

.PHONY: section
