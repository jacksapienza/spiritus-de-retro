# Handoff progetto Max / SuperCollider — AgentPeto / Spiritus de retro

## Scopo
L'utente sta riprendendo un vecchio progetto di live electronics con Max/bach e SuperCollider. Richiede ricostruzione del funzionamento e sistemazione robusta di `applyEnv`, che applica inviluppi estratti da analisi spettrali a 25 potenziometri della GUI SuperCollider.

**Importante:** questo documento e `CRONOLOGIA_CHAT.md` sono una ricostruzione fedele per contenuti, **non un export verbatim automatico** del transcript ChatGPT. I file `.scd` e `.maxpat` sono copie dei file disponibili nella conversazione. Le versioni `_safe` sono bozze di modifica non validate in esecuzione.

## File
- `originali/_mainPP.maxpat`: patch Max principale, matrice 25x4, smistamento, invio `/matrixEnv`.
- `originali/bach_vincoli.maxpat`: patch Max incorporata; generazione con bach, analisi spettrale e messaggi OSC.
- `originali/agentGUI.scd`: punto d'avvio SuperCollider. Carica gli altri script con nomi originali.
- `originali/agent_BUS.scd`: bus/comunicazione e funzioni comuni.
- `originali/agentButtonGUI.scd`: interfaccia, pulsanti, EZKnob e `~allKnobs`.
- `originali/agentSynthsGUI.scd`: SynthDef, buffer, lettura peti, clicks e granulazione.
- `originali/agentMainRoutine.scd`: OSCdef, scheduling, parser `/timeStamps`, funzione `~morphKnobs`, parser `/matrixEnv`.
- `originali/_main.scd`: prototipo separato di granulazione dei campioni dalla cartella `peti`.
- `versioni_modificate/agentMainRoutine_safe.scd`: versione proposta in chat: filtri OSC e `~morphKnobs`, **ancora con possibile bug `env.duration` prima della validazione**.
- `versioni_modificate/agentSynthsGUI_safe.scd`: versione proposta in chat con cartella `file` relativa; l'utente ha poi deciso di usare una singola cartella dei campioni nel progetto Max e un percorso assoluto nel codice SC locale.

## Flusso essenziale
Max `bach_vincoli.maxpat` / `p bufAnalysis` produce dati analisi per `/timeStamps`; il parser SC divide `centroidValues`, `rmsValues`, sequenza interlacciata tempo/valore, e flatness, usando `sep1` / `sep2`. Crea tre `Env` normalizzati (`~potArray`). La patch Max `_mainPP.maxpat` contiene una matrice 25x4; invia `/matrixEnv` con record da 5 elementi [indice_pot, active, inviluppo1, inviluppo2, inviluppo3]. `OSCdef(\matrixFromMax)` chiama `~morphKnobs.(~allKnobs[pot - 1], ~potArray[envIndex])`, che crea un valore target casuale e aggiorna l'`EZKnob` in 200 step per la durata dell'inviluppo.

Altri messaggi Max→SC: `/voices`, `/voices2`, `/breakpoints`, `/voiceLens`, `/otsuJenks`, `/timeStamps`, `/matrixEnv`, `/petoNum`, `/synthLens`, `/petoClick`, `/stop`. SC→Max: `/bang`, `/bangMulti`, `/bangLens`, `/bangJenks` e altri trigger. Porta SC comune 57120. Max riceve anche a 7412 e 5557 (verificare rispetto alle patch prima di dare per certe tutte le direzioni).

## Errori realmente riportati dall'utente
1. `ERROR: Primitive '_ArrayEnvAt' failed`, receiver `[ sep1, 0, -99, -99 ]`, durante `env.at(phase)` in `~morphKnobs` dopo `applyEnv`. Indizio: inviluppo contiene separatori/sentinelle non numeriche.
2. `file .../prova_peto02.wav could not be opened: System error: No such file or directory`. Percorsi storici non più validi.
3. `ERROR: binary operator '+' failed`, receiver `nil`, call stack `Collection:sum`, dalla funzione `~morphKnobs`, invocata durante `/matrixEnv`; spiegazione probabile: `env.duration` somma tempi di `Env` contenenti `nil`. Non è dimostrato che `knob.value` fosse la causa: il call stack `Collection:sum` indica piuttosto `env.duration`.
4. `ERROR: syntax error, unexpected end of file ... expecting ... ')'` (riga 549). In chat è stata suggerita una parentesi finale per chiudere un blocco aperto, ma non è stata validata sul file locale successivo.
5. `WARNING: Campione assente, caricamento ignorato: .../agent_based-liveElectronics/file/prova_peto03.wav`. L'utente ha scoperto che i WAV originali erano dentro il progetto Max, non quello SC. Decisione: mantenere una sola copia in Max, impostando `~petoSampleDir` sul path esistente in Max.
6. `FAILURE IN SERVER /n_free Node 1160 not found`. Richiesta di liberare un nodo non più esistente, **nessuna prova che `applyEnv` lo causi direttamente**. Potrebbe essere una doppia liberazione o altro meccanismo di lifecycle.
7. Ancora `ERROR: binary operator '+' failed ... Collection:sum`, `~morphKnobs`, `spec=nil`, `duration=nil`, durante `/matrixEnv`, indice iterazione 6. Suggerita nuova versione di `~morphKnobs` che valida `env.times` **prima** di chiamare `.sum` / `.duration`. Quella versione è nel testo cronologico, **non** nel file `_safe.scd` disponibile.

## Stato e criticità / next steps
- Controllare `p bufAnalysis` in `bach_vincoli.maxpat`: output `bach.join 4 @out m` → `prepend /timeStamps` → `udpsend localhost 57120`. Nell'analisi ci sono oggetti `append sep1`, `append sep2`, `ears.essentia~` e costruzione delle coppie tempo/valore via bach.
- Verificare la serializzazione Max: il receiver `[ sep1, 0, -99, -99 ]` non è un Env valido; i marker e -99 vanno rimossi o interpretati correttamente, ma non assumere che siano semplicemente da eliminare senza conoscere il protocollo.
- Validare dati numerici e tempi monotoni **prima** di costruire Env; verificare numero di livelli e numero di durate, e `~forceStartEnd` con valori degeneri.
- In `~morphKnobs` validare `env.levels` e `env.times` prima di accedere a `env.duration`, che internamente somma `env.times`.
- `env.at(phase)` usa secondi, non fase normalizzata; usare `env.at(phase * duration)`.
- Esaminare `~allKnobs` e `EZKnob.controlSpec`, dato che l'utente ha anche sperimentato problemi con `nil`.
- Verificare le condizioni di completamento e `doneAction` dei synth e il doppio `.free` per `/n_free`.
- Non assumere che i `.scd` caricati rappresentino l'ultimo file locale modificato: l'utente ha copiato/modificato codice direttamente nell'editor ed esistono differenze rispetto ai file allegati.
- Non sono inclusi i campioni audio `prova_petoXX.wav` o i file nella cartella `clicks`: non sono mai stati caricati in chat.

## Preferenze utente
- Vuole modifiche di codice **incollate direttamente in chat**, non file scaricabili, quando lavora alla correzione.
- Preferisce interventi mirati senza diagnostica prolissa, pur volendo capire il progetto e il significato compositivo.
- Vuole ricostruire la logica, non riscrivere arbitrariamente il sistema.
