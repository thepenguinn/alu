# Makefile
#

TEXFILES = ../main.tex ../generalcommands.sty ../generaltikzset.sty ../cornercommands.sty ../preamble.tex ../generalsubctikz.sty

COUNTER = section.tex

section: section.pdf

.SUFFIXES: .tex .pdf

.tex.pdf:
	pdflatex -shell-escape -halt-on-error $<
	viewpdf $(addsuffix .pdf, $(basename $<))
	touch  $(addsuffix .pdf, $(basename $<))


counter/section.pdf: $(TEXFILES) $(COUNTER)

.PHONY: section
