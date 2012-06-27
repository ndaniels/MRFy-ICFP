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

CODES=strategy search viterbi scoredecl vscore vfix edge memo gen utility move \
      strat stop history statelabel hmmnode

$TGT.dvi: $TGT.tex ${CODES:%=%.tex}
	# latexmk $TGT.tex
    latex '\scrollmode \input '"$TGT"
	ltxcount=3
	while egrep -s 'Rerun (LaTeX|to get cross-references right|to get citations correct)' $stem.log &&
	      [ $ltxcount -gt 0 ]
	do
	  latex '\scrollmode \input '"$TGT"
	  ltxcount=`expr $ltxcount - 1`
	done


$TGT.pdf: $TGT.tex
	latexmk -pdf $TGT.tex


latex:V: ${CODES:%=%.tex}
	latex $TGT


$TGT.dvi: ${CODES:%=%.tex}
$TGT.pdf: ${CODES:%=%.tex}

strat.tex stop.tex history.tex move.tex gen.tex search.tex utility.tex:D: ./xsource Smurf2/LazySearchModel.hs
 	lua $prereq

vscore.tex:D: ./xsource Smurf2/Score.hs
 	lua $prereq

memo.tex edge.tex viterbi.tex:D: ./xsource Smurf2/Viterbi.hs
	lua $prereq

statelabel.tex hmmnode.tex:D: ./xsource Smurf2/MRFTypes.hs
	lua $prereq

vfix.tex:D: viterbi.tex mkfile
	sed -e "s/vpaper'/viterbi/" \
        -e 's/pathCons Mat/Mat:/' \
        -e 's/DL.minimum/minimum/' \
        -e 's/myminimum/minimum/' \
	  viterbi.tex > $target
