# Makefile
#

default: viewpdf

alu.pdf: alu.tex
	pdflatex alu.tex
	cp alu.pdf ~/src/

viewpdf: alu.pdf
	viewpdf ~/src/alu.pdf

.PHONY: default viewpdf
