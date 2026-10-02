# Dodávka on-premises produktu

Model divergence stavu a mechanismy jeho zúžení. Text popisuje dodávku
software provozovaného v prostředí zákazníka jako problém řízení
divergence: rozdílu mezi skutečným stavem instance a představou dodavatele
o tomto stavu.

**[Stáhnout aktuální PDF](https://github.com/jslachta/onpremises-product-delivery/raw/releases/onprem-delivery.pdf)**

Odkaz je stabilní a vede vždy na nejnovější build z `main`. Verze je
na titulní straně: ostré vydání nese *Verze X.Y.Z*, build mimo tag
*Pracovní verze (draft)*. Konkrétní ostrá vydání jsou v GitHub Releases.

## O co jde

Náklad dodávky on-premises produktu neroste s rychlostí vývoje, ale
s počtem živých kombinací, které musí dodavatel obsloužit. Běžně
doporučovaná opatření (pomalá kadence, minimalizace počtu vydání) tento
počet ve skutečnosti zvyšují.

Dokument stojí na několika myšlenkách:

- **Dva stavy** - skutečný stav instance $S$ (co je v databázi) a
  evidovaný stav $E$ (co si o instanci myslí dodavatel). Selhání vzniká,
  když se rozhoduje podle $E$, zatímco operace působí na $S$.
- **Verze schématu není stav systému** - stav je funkcí cesty, nikoli
  cílové verze. Testuje se množina cest, ne množina verzí.
- **Konvergentní vs. divergentní transformace** - hranice nevede mezi
  malými a velkými migracemi, ale mezi těmi, které se dotýkají jen
  struktury, a těmi, které se dotýkají dat.
- **Latence detekce** - cílem není nulová divergence, ale její krátká
  latence: aby se rozpor projevil, dokud je oprava levná.

Z modelu je odvozena číslovaná sada **invariantů** (INV-01, INV-02, …)
a **mechanismů**, které je vynucují.

## Build

Zdroj je v LaTeXu (pdfLaTeX). PDF se needituje ručně, generuje se ze zdroje:

```sh
make           # vytvoří onprem-delivery.pdf (verze z gitu na titulní straně)
make watch     # průběžný build (vyžaduje latexmk)
make clean     # úklid pomocných souborů
```

Detaily sazby a verzování: [README_TEX.md](README_TEX.md).

## Vydávání

PDF se publikuje do větve `releases` vždy pod statickým názvem
`onprem-delivery.pdf` (verze není v názvu souboru, jen uvnitř PDF):

- **Každý commit do `main`** — build jako draft, přepíše
  `onprem-delivery.pdf`.
- **Git tag `vX.Y.Z`** — build jako ostré vydání, přepíše
  `onprem-delivery.pdf` a navíc vytvoří GitHub Release s PDF a JSON
  metadaty.

Verze se počítá z gitu: na tagu `X.Y.Z`, jinak `draft-<git describe>`.
Nastavení CI/CD a release procesu: [README_CI.md](README_CI.md).
