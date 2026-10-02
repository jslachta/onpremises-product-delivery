# Makefile — Dodávka on-premises produktu
# Vyžaduje: pdflatex (TeX Live / MiKTeX), git, POSIX sh.
# Dvojí běh kvůli TOC.
# Verzi počítá scripts/version.sh z gitu do version.tex:
#   HEAD na tagu vX.Y.Z (čistý strom) → vydání, jinak draft.

ENGINE = pdflatex
FLAGS  = -interaction=nonstopmode -halt-on-error
DOC    = onprem-delivery

.PHONY: all clean distclean watch FORCE

all: $(DOC).pdf

# version.tex se přepočítá při každém make; skript soubor přepíše jen při
# změně verze, takže PDF se nepřestavuje zbytečně.
version.tex: FORCE
	@sh scripts/version.sh $@ >/dev/null

$(DOC).pdf: $(DOC).tex version.tex
	$(ENGINE) $(FLAGS) $(DOC).tex
	$(ENGINE) $(FLAGS) $(DOC).tex

# Průběžný build (vyžaduje latexmk). Verze se spočítá jednou při startu.
watch: version.tex
	latexmk -pdf -pdflatex="$(ENGINE) $(FLAGS) %O %S" -pvc $(DOC).tex

clean:
	rm -f $(addprefix $(DOC),.aux .log .out .toc .fls .fdb_latexmk .synctex.gz) version.tex

distclean: clean
	rm -f $(DOC).pdf

FORCE:
