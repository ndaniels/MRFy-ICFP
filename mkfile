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
      strat stop history statelabel hmmnode aa score tprob-tprobs

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


$TGT.dvi: ${CODES:%=%.tex} timestamp.tex
$TGT.pdf: ${CODES:%=%.tex}

timestamp.tex:DQ: $TGT.tex ${CODES:%=%.tex}
	date=today
	signature=""
	if [ -x $HOME/bin/md5words ]; then
	  words="`cat $prereq | md5words -trim`"
      signature=" [MD5: \\mbox{$words}]"
    else
      words="(could not compute signature words)"
	fi
	date -u -d "$date" "+\def\mdfivestamp{\\rlap{\\textbf{%a %e %b %Y, %l:%M %p UCT$signature}}}\def\mdfivewords{$words}" > $target
	echo "Wrote $target"

strat.tex stop.tex history.tex move.tex gen.tex search.tex utility.tex:D: ./xsource Smurf2/LazySearchModel.hs
 	lua $prereq

vscore.tex score.tex:D: ./xsource Smurf2/Score.hs
 	lua $prereq

memo.tex edge.tex viterbi.tex:D: ./xsource Smurf2/Viterbi.hs
	lua $prereq

statelabel.tex hmmnode.tex tprob.tex tprobs.tex tprob-tprobs.tex:D: ./xsource Smurf2/MRFTypes.hs
	lua $prereq

aa.tex:D: ./xsource Smurf2/Constants.hs
	lua $prereq

vfix.tex:D: viterbi.tex mkfile
	sed -e "s/vpaper'/viterbi/" \
        -e 's/pathCons Mat/Mat:/' \
        -e 's/DL.minimum/minimum/' \
        -e 's/myminimum/minimum/' \
	  viterbi.tex > $target
