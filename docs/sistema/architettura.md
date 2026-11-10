# Architettura del sistema

Ricostruita dai file e dall'handoff ChatGPT. Da verificare sul Mac.

## Componenti
- **Max** — `bach_vincoli.maxpat`: generazione con `bach.constraints`, analisi spettrale (`p bufAnalysis`, `ears.essentia~`), OSC.
  `_mainPP.maxpat`: scena (sedere, parziali, carta igienica), matrice 25×4, invio `/matrixEnv`.
- **SuperCollider** — `agentGUI.scd` (avvio e finestra AgentPeto), `agent_BUS.scd`, `agentButtonGUI.scd` (knob e pulsanti),
  `agentSynthsGUI.scd` (SynthDef, buffer, peti), `agentMainRoutine.scd` (OSCdef, `~morphKnobs`, parser).
- **Terminale** — usato dall'esecutore per selezionare il peto; stampa la categoria. **Comando esatto: da documentare.**

## Porte OSC
| Da → A | Porta |
|---|---|
| Max → SC | 57120 |
| SC → Max | 5557 (`~max`) |
| ? → Max | 7412 |
| Max → 192.168.178.58 | 3124 (seconda macchina: Bela?) |

## Problemi aperti
- `~allKnobs` ha 29 elementi, la matrice 25 righe: gendyPulsar e slrolls non sono raggiungibili da `/matrixEnv`.
- `~win.onClose` libera variabili locali mai assegnate: chiudendo la finestra i synth restano attivi.
- Bug di `~morphKnobs` / `/timeStamps` (separatori `sep1`, `sep2`, `-99` dentro gli Env): vedi `archivio/handoff_chatgpt/`.
- `FAILURE IN SERVER /n_free`: probabile doppio `.free`, non verificato.
