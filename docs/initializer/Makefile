# Makefile
#

TEXFILES = ../catppuccin-latte.sty ../catppuccin-mocha.sty ../colorthemes.sty \
		   ../cornercommands.sty ../generalcommands.sty ../generalsubctikz.sty \
		   ../generaltikzset.sty ../abstract.tex ../main.tex ../preamble.tex

INITIALIZER = section.tex tikzset.tex subctikz.tex

section: viewpdf

viewpdf: section.pdf
	viewpdf section.pdf

.SUFFIXES: .tex .pdf

.tex.pdf:
	pdflatex -shell-escape -halt-on-error $<
	touch  $(addsuffix .pdf, $(basename $<))


section.pdf: $(TEXFILES) $(INITIALIZER)

.PHONY: section viewpdf
