# Spiritus de retro

Live electronics per Max/bach e SuperCollider su un corpus di peti registrati, analizzati spettralmente e trasformati.
Titolo di lavoro e finestra SC: *AgentPeto*.

## Struttura

| Cartella | Contenuto |
|---|---|
| `src/max/` | Patch Max: `_mainPP.maxpat` (principale, scena per il pubblico), `bach_vincoli.maxpat` (generazione bach, analisi spettrale, OSC) |
| `src/sc/` | Script SuperCollider. Avvio: `agentGUI.scd` |
| `src/sc/_bozze_chatgpt/` | Versioni `_safe` proposte in precedenza, **non validate** |
| `docs/paper/` | Scheletro e bozze del paper sul pezzo |
| `docs/design/` | Concept visivo: scena del pubblico e regia |
| `docs/fonti/` | Classificazione dei peti, iconografia, bibliografia |
| `docs/sistema/` | Architettura, protocollo OSC, problemi aperti |
| `docs/diario.md` | Diario di lavoro datato (materiale grezzo per il paper) |
| `assets/` | Immagini di riferimento e screenshot dello stato attuale |
| `archivio/` | Handoff da ChatGPT, per tracciabilità |

## Nota sui sorgenti

I file in `src/` sono le copie dell'handoff del 10/11/2026. **Le versioni sul Mac possono essere più recenti**: vanno sostituite con quelle reali prima di modificarle.
