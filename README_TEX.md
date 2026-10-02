# Dodávka on-premises produktu — sazba a struktura

Odborný text o dodávce software provozovaného u zákazníka: model divergence
stavu, invarianty a mechanismy jeho zúžení.

> **Stav: DRAFT.** Kapitoly Rámec, Mechanismy, Rozhodnutí, Antipatterny
> a zdůvodnění invariantů jsou zatím stuby (`\emph{[Stub. …]}`).

## Obsah

- **Rámec** — on-prem jako provozní režim, nákladový driver
- **Model** — skutečný vs. evidovaný stav, cestová závislost, konvergentní
  a divergentní transformace, latence detekce
- **Invarianty** — číslovaná, citovatelná sada (INV-01, INV-02, …)
- **Mechanismy**, **Rozhodnutí, která zůstávají úsudkem**, **Antipatterny**
- **Zdroje**

## Build

Vyžaduje TeX Live nebo MiKTeX s `pdflatex`, dále `git` a POSIX `sh`
(na Windows např. Git Bash).

```sh
make          # vytvoří onprem-delivery.pdf (dvojí běh kvůli TOC)
make clean    # smaže pomocné soubory včetně version.tex
make watch    # průběžný build (vyžaduje latexmk)
```

## Verze v PDF

Verzi počítá `scripts/version.sh` z gitu a zapisuje ji do `version.tex`
(makra `\docversion`, `\doccommit`, `\docdate` a přepínač `\ifdocdraft`).
Titulní strana ji zobrazuje pod jménem autora.

| Stav repozitáře | Verze | Titulní strana |
|-----------------|-------|----------------|
| HEAD přesně na tagu `vX.Y.Z`, čistý strom | `X.Y.Z` | *Verze X.Y.Z* |
| commity po tagu | `draft-vX.Y.Z-N-g<sha>` | *Pracovní verze (draft)* |
| zatím žádný tag | `draft-<sha>` | *Pracovní verze (draft)* |
| neuložené změny | `draft-…-dirty` | *Pracovní verze (draft)* |
| bez `version.tex` (přímý `pdflatex`) | `draft-local` | *Pracovní verze (draft)* |

- **Lokálně** (`make`): `version.tex` se přepočítá při každém buildu.
- **V CI:** týž skript, výstup jde navíc do proměnných prostředí jobu.
- `version.tex` je v `.gitignore` — nikdy se necommituje.

## Konvence

- **Číslo invariantu je stabilní** — nemění se při přeuspořádání textu,
  invarianty jsou citovatelné zvenčí.
- **One-sentence-per-line** je cílový stav pro nový text: změna věty =
  jeden řádek v diffu.
- PDF se needituje ručně ani neverzuje (viz `.gitignore`); buduje se z `.tex`.
