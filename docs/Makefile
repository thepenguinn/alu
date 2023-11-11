# Makefile
#

default: viewpdf

alu.pdf: alu.tex
	pdflatex alu.tex

viewpdf: alu.pdf
	cp alu.pdf ~/src/
	viewpdf ~/src/alu.pdf

.PHONY: default viewpdf
