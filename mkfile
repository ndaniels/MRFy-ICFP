TGT=mrfy_experience_report

all:V: $TGT.dvi $TGT.pdf
dvi:V: $TGT.dvi

DIAGRAMS=Plan7 alignment mrf_interleave_diagram

$TGT.dvi: ${DIAGRAMS:%=%.eps}
$TGT.pdf: ${DIAGRAMS:%=%.pdf}

&.eps: &.pdf
	convert $prereq $target  # hideous, but workable

$TGT.dvi: $TGT.tex
	mklatex $target

$TGT.pdf: $TGT.tex
	mklatex -pdf $target
