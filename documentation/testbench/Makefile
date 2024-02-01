# Makefile
#

TEXFILES = ../catppuccin-latte.sty ../catppuccin-mocha.sty ../colorscheme.sty \
		   ../cornercommands.sty ../generalcommands.sty ../generalsubctikz.sty \
		   ../generaltikzset.sty ../abstract.tex ../main.tex ../preamble.tex

TESTBENCH = chapter.tex

chapter: _viewpdf

viewpdf:
	[ -e chapter.pdf ] && viewpdf chapter.pdf || printf "chapter.pdf doesn't exist, run make\n"

_viewpdf: runlunatikz chapter.pdf
	viewpdf chapter.pdf

runlunatikz:
	lunatikz --style-root-path --style-file colorscheme.sty --style-macro usepackage \
		--touch-file need_to_build chapter.tex

.SUFFIXES: .tex .pdf

.tex.pdf:
	pdflatex -shell-escape -halt-on-error $<
	touch  $(addsuffix .pdf, $(basename $<))


chapter.pdf: $(TEXFILES) $(TESTBENCH) tikzpics/need_to_build

.PHONY: chapter viewpdf _viewpdf runlunatikz
