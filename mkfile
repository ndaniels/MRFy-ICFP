TGT=jfp

all:V: $TGT.dvi $TGT.pdf $TGT.ps
ps:V: $TGT.ps
dvi:V: $TGT.dvi
pdf:V: $TGT.pdf
bibtex:V:
	bibtex $TGT

DIAGRAMS=Plan7 alignment mrf_interleave_diagram

# $TGT.dvi: ${DIAGRAMS:%=%.eps}
$TGT.pdf: ${DIAGRAMS:%=%.pdf}

jfp.dvi: search-figs/search-graph1.eps
jfp.dvi: search-figs/search-graph5.eps

%.pdf: %.eps
  epstopdf $prereq

ICFPCODES=strategy search viterbi scoredecl vscore vfix edge memo gen utility move \
      strat stop history statelabel hmmnode aa score tprob-tprobs

CODES=$ICFPCODES hoviterbi aa model3-mstate model3-node hov4 hov-prevs list-viterbi \
	  v4aux hosigs


$TGT.dvi: $TGT.tex ${CODES:%=%.tex}
	# latexmk $TGT.tex
    latex '\scrollmode \input '"$TGT"
	ltxcount=3
	while egrep -s 'Rerun (LaTeX|to get cross-references right|to get citations correct)' $TGT.log &&
	      [ $ltxcount -gt 0 ]
	do
	  latex '\scrollmode \input '"$TGT"
	  ltxcount=`expr $ltxcount - 1`
	done


$TGT.pdf: $TGT.ps
	ps2pdf14 -sPAPERSIZE=letter -dPDFSETTINGS=/prepress -dEmbedAllFonts=true $TGT.ps $target

$TGT.ps:D: $TGT.dvi
	dvips -t letter -o $target -P pdf $prereq


latex:V: ${CODES:%=%.tex}
	latex $TGT

GRAPHS=speedup efficiency
GRAPHPDFS=${GRAPHS:%=%.pdf}

codes:V: ${CODES:%=%.tex} 

$TGT.dvi: ${CODES:%=%.tex} timestamp.tex
$TGT.pdf: ${CODES:%=%.tex} 
<| case $USER in noah) ;; *) echo "$TGT.pdf: $GRAPHPDFS" ;; esac
<| case $USER in noah) ;; *) echo "source:V: $GRAPHPDFS" ;; esac

source:V: timestamp.tex ${CODES:%=%.tex}

timestamp.tex:DQ: $TGT.tex ${CODES:%=%.tex}
	date=""
	signature=""
	if [ -x $HOME/bin/md5words ]; then
	  words="`cat $prereq | md5words -trim`"
      signature=" [MD5: \\mbox{$words}]"
    else
      words="(could not compute signature words)"
	fi
	case $USER in
      noah) echo "\def\mdfivestamp{\\rlap{\\textbf{`date -u` $signature}}}\def\mdfivewords{$words}" > $target ;;
      *) date -u -d "$date" "+\def\mdfivestamp{\\rlap{\\textbf{%a %e %b %Y, %l:%M %p UCT$signature}}}\def\mdfivewords{$words}" > $target ;;
    esac
	echo "Wrote $target"

strat.tex stop.tex history.tex move.tex gen.tex search.tex utility.tex:D: ./xsource mrfy/LazySearchModel.hs
 	lua $prereq

%.eps:D: %.j
	jgraph $prereq > $target

$TGT.dvi: speedup.eps efficiency.eps

$TGT.dvi: sigplanconf.cls

speedup.j efficiency.j:D: ./data
	lua ./data

vscore.tex score.tex:D: ./xsource mrfy/Score.hs
 	lua $prereq

memo.tex edge.tex viterbi.tex:D: ./xsource mrfy/Viterbi.hs
	lua $prereq

hoviterbi.tex:D: ./xsource mrfy/ViterbiThree.hs
	lua $prereq

statelabel.tex hmmnode.tex tprob.tex tprobs.tex tprob-tprobs.tex:D: ./xsource mrfy/MRFTypes.hs
	lua $prereq

aa.tex:D: ./xsource mrfy/Constants.hs
	lua $prereq

model3-mstate.tex model3-node.tex:D: ./xsource mrfy/Model3.hs
	lua $prereq

hov4.tex:D: ./xsource nr-jfp/V4.hs
	lua $prereq

hov-prevs.tex v4aux.tex hosigs.tex:D: ./xsource mrfy/V4.hs
	lua $prereq

list-viterbi.tex:D: ./xsource mrfy/V2.hs
	lua $prereq

vfix.tex:D: viterbi.tex mkfile
	sed -e "s/vpaper'/viterbi/" \
        -e 's/pathCons Mat/Mat:/' \
        -e 's/DL.minimum/minimum/' \
        -e 's/myminimum/minimum/' \
	  viterbi.tex > $target
