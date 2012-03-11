TGT=mrfy_experience_report

all:V: $TGT.dvi $TGT.pdf
dvi:V: $TGT.dvi
pdf:V: $TGT.pdf
bibtex:V:
	bibtex $TGT

DIAGRAMS=Plan7 alignment mrf_interleave_diagram

# $TGT.dvi: ${DIAGRAMS:%=%.eps}
$TGT.pdf: ${DIAGRAMS:%=%.pdf}

# &.eps: &.pdf
#	convert $prereq $target  # hideous, but workable

$TGT.dvi: $TGT.tex
	latexmk $TGT.tex

$TGT.pdf: $TGT.tex
	latexmk -pdf $TGT.tex

CODES=strategy search viterbi scoredecl vscore vfix

latex:V: ${CODES:%=%.tex}
	latex $TGT


$TGT.dvi: ${CODES:%=%.tex}
$TGT.pdf: ${CODES:%=%.tex}

strategy.tex search.tex scoredecl.tex:D: ./xsource Smurf2/SearchModel.hs
	lua $prereq

viterbi.tex vscore.tex:D: ./xsource Smurf2/Viterbi.hs
	lua ./xsource Smurf2/Viterbi.hs

vfix.tex:D: viterbi.tex mkfile
	sed "s/vpaper'/viterbi/;s/pathCons Mat/Mat:/" viterbi.tex > $target
