# Makefile
#

TEXFILES = main.tex generalcommands.sty generaltikzset.sty cornercommands.sty preamble.tex generalsubctikz.sty

PDFFILES = onebitalu/section.pdf counter/section.pdf

ONEBITALU = onebitalu/section.tex onebitalu/tikzset.tex onebitalu/subctikz.tex

COUNTER = counter/section.tex

main: main.pdf

section: $(PDFFILES)

.SUFFIXES: .tex .pdf

.tex.pdf:
	pdflatex --shell-escape --halt-on-error $<
	viewpdf $(addsuffix .pdf, $(basename $<))
	touch  $(addsuffix .pdf, $(basename $<))


main.pdf: $(TEXFILES) $(ONEBITALU) $(COUNTER)
onebitalu/section.pdf: $(TEXFILES) $(ONEBITALU)
counter/section.pdf: $(TEXFILES) $(COUNTER)

.PHONY: main section current
