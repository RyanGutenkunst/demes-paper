DEPS=\
	paper.tex \
	paper.bib \
	software-table.tex \
	models/IM.yaml \
	models/IM-resolved.yaml \
	models/tennessen.yaml \
	fig/IM.pdf \
	fig/showcase.pdf

paper.pdf: $(DEPS)
	latexmk -shell-escape paper.tex

paper.ps: paper.dvi
	dvips paper

paper.dvi: $(DEPS)
	latex paper.tex
	bibtex paper
	latex paper.tex
	latex paper.tex

fig/IM.pdf: drawfig.py models/IM.yaml
	python3 drawfig.py

fig/showcase.pdf: fig/showcase.py fig/minted-snippet.tex
	cd fig && $(MAKE) showcase.pdf

resolve: models/IM.yaml
	#python -c \
	#	"import sys, demes; print(demes.dumps(demes.load(sys.argv[1]), simplified=False))" \
	#	models/IM.yaml > models/IM-resolved.yaml
	# Use demes-c resolver. Omit the yaml leader/footer with sed.
	../demes-c/resolve models/IM.yaml \
		| sed -e '/^---$$/d' -e '/^\.\.\.$$/d' \
		> models/IM-resolved.yaml

.PHONY: spellcheck
spellcheck: aspell.conf
	aspell --conf ./aspell.conf --check paper.tex

clean:
	rm -f *.log *.dvi *.aux
	rm -f *.blg *.bbl
	rm -f *.eps *.[1-9]
	rm -f src/*.mpx *.mpx
	rm -fr _minted-paper
	cd fig && $(MAKE) clean

mrproper:
	rm -f *.ps *.pdf
	cd fig && $(MAKE) mrproper
