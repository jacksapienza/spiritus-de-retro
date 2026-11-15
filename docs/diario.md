# Diario di lavoro

## 2026-11-10
- Ripreso il progetto: raccolti patch Max e script SC, ricostruiti funzionamento e bug aperti.
- Decisione: **il pubblico vede solo Max**; l'esecutore vede SuperCollider e il terminale.
- Le categorie di *Anthropophyteia* IX vanno mostrate al pubblico.
- Direzione estetica: sapore medievale. Riferimenti: Codex Manesse, xilografia del diavolo nella latrina, Lepautre.
- Gag da sviluppare: bagno occupato/libero.
- Per ora **nessun nuovo descrittore** nella scena.
- Proposta in discussione: scena come folio miniato (parziali = rigatura, carta igienica = cartiglio, matrice = cornice a losanghe).

## 2026-11-15
- Nuovo script `analisi_parziali.py` (filtro su durata, ampiezza e numero di parziali; semplificazione Ramer-Douglas-Peucker in cent e dB), affiancato all'originale `manipolazioneDati.py`.
- Primo peto analizzato con il nuovo script: `prova_peto07.txt` (export SPEAR, 1739 parziali) → `peto07.txt` (40 parziali).
- Errore `bach.constraints: variable index 65 out of range` con peto07: risolto.
- Durante l'analisi Max si è bloccato una volta: da indagare più avanti.
