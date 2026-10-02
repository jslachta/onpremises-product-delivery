# CI/CD — nastavení a workflow

Workflow je v `.github/workflows/build.yml`. Tento soubor popisuje, co je
třeba nastavit **ručně na GitHubu** (z YAMLu to nevyplyne) a jak se vydává.

## Co dělá workflow

| Spouštěč | Co se stane | Kam |
|----------|-------------|-----|
| Pull request do `main` | Build PDF, ověření kompilace | PDF + JSON jako **artifact** (30 dní), do gitu nic |
| Push do `main` (každý commit) | Build **draftu** + publikace | `onprem-delivery.pdf` (přepisovaný) do větve **`releases`** |
| Git tag `vX.Y.Z` | Build **vydání** + publikace | `onprem-delivery.pdf` (přepisovaný) do větve **`releases`** + **GitHub Release** s assety |

Publikuje se **jeden soubor `onprem-delivery.pdf` (+ `.json`) se statickým
názvem bez verze** — přepisuje ho každý commit do `main` i každý tag, takže
URL na něj je stabilní **permalink** na nejnovější build.

Verze žije *uvnitř* PDF (titulní strana: *Verze X.Y.Z* nebo *Pracovní
verze (draft)*) a v JSON vedle něj (`version`, `draft`, `channel`).
Konkrétní ostrá vydání zůstávají jako assety v GitHub Releases; jejich
přehled drží i `index.md` ve větvi `releases` (drafty se do něj
nezapisují). `index.html` ve větvi `releases` ukazuje aktuální verzi —
lze ji použít jako zdroj GitHub Pages.

Hlavní větev (`main`) je **čistě zdroj** — žádné PDF. Výstupy žijí
v oddělené orphan větvi `releases` (model jako `gh-pages`).

## Verze

Verzi počítá `scripts/version.sh` z gitu (týž skript jako lokální `make`),
checkout v CI proto stahuje celou historii včetně tagů (`fetch-depth: 0`):

- HEAD přesně na tagu `vX.Y.Z` → `X.Y.Z`,
- jinak `draft-<git describe>`, např. `draft-v1.2.0-3-gabc1234`.

Na tagu workflow navíc ověří, že `git describe` vrátil právě tento tag;
jinak publikace selže.

## Ruční nastavení (jednorázově)

### 1. Oprávnění GITHUB_TOKEN

Push do `releases` i vytvoření Release zvládne automatický `GITHUB_TOKEN`
(publish job má `permissions: contents: write`). Žádný PAT není třeba.

- **Settings → Actions → General → Workflow permissions:** ponech
  *Read repository contents* — zápis si job vyžádá sám. Pokud organizace
  zápis tokenu zakazuje úplně, je nutné ho povolit.

### 2. Povinný pull request + squash

- **Settings → General → Pull Requests:**
  - povol jen **Allow squash merging**
- **Settings → Rules → Rulesets** (nebo *Branches → Branch protection*):
  - `main`: **Require a pull request before merging**,
    **Require status checks to pass** (`build`)
  - tagy `v*`: omez vytváření tagů na oprávněné role

### 3. (Volitelně) Ochrana větve `releases`

Větev `releases` je strojová. Doporučeno:
- ruleset zakazující ruční push (s výjimkou pro GitHub Actions),
- nezahrnovat do běžných PR.

### 4. (Volitelně) GitHub Pages

**Settings → Pages → Source:** *Deploy from a branch*, větev `releases`,
složka `/`. Landing `index.html` se přegeneruje při každé publikaci.

## Jak vydat novou verzi

```sh
# 1. změny jsou v main (přes PR, squash)
git checkout main && git pull

# 2. vytvoř SemVer tag
git tag -a v1.2.0 -m "Dodávka on-premises produktu — v1.2.0"
git push origin v1.2.0
```

Tag spustí job `publish`: PDF se zkompiluje s vraženou verzí (`1.2.0`,
commit, datum commitu) na titulní straně a uloží se do větve `releases`
jako `onprem-delivery.pdf` (přepíše předchozí vydání). Vznikne i
`onprem-delivery.json` s metadaty, přibude řádek do `index.md`
a vytvoří se GitHub Release `v1.2.0` s PDF a JSON jako assety.

Stabilní odkaz (permalink) na nejnovější build:

```
https://github.com/<owner>/<repo>/raw/releases/onprem-delivery.pdf
```

Po dalším commitu do `main` se soubor přepíše draftem. Konkrétní vydání
lze vždy stáhnout z GitHub Release daného tagu.

## Náklady

Build běží na PR, na **každý push do `main`** a na tag. Každý draft je
commit s novým PDF ve větvi `releases`, takže její historie roste
(stovky kB na commit). Pokud to bude vadit:

- omezit draft na změny zdroje (`paths: ["*.tex", "scripts/**"]` u
  `push`),
- nebo větev `releases` občas přepsat (squash historie) — permalinky
  zůstanou funkční.
