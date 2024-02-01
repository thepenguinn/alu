default: testing.pdf
	viewpdf testing.pdf

testing.pdf: testing.tex ../../generalsubctikz.sty
	pdflatex -shell-escape --halt-on-error testing.tex

.PHONY: default
