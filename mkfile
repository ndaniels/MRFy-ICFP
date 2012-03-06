TGT=mrfy_experience_report

all:V: $TGT.dvi $TGT.pdf
dvi:V: $TGT.dvi

DIAGRAMS=Plan7 alignment mrf_interleave_diagram

$TGT.dvi: ${DIAGRAMS:%=%.eps}
$TGT.pdf: ${DIAGRAMS:%=%.pdf}

&.eps: &.pdf
	convert $prereq $target  # hideous, but workable

$TGT.dvi: $TGT.tex
	latexmk $TGT.tex

$TGT.pdf: $TGT.tex
	latexmk -pdf $TGT.tex
