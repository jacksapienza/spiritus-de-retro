#!/usr/bin/env python3
"""
analisi_parziali.py — semplifica le parziali esportate da SPEAR per Max/bach.

Input:  export SPEAR "Text - Partials" (par-text-partials-format).
Output: stesso formato di manipolazioneDati.py, quindi compatibile con la patch:
        [x0 durata [[freq pos] ...] [[amp pos] ...]] [ ... ]
        freq in Hz, amp lineare, pos normalizzata 0..1 sulla durata della parziale.

Differenze rispetto a manipolazioneDati.py:
  1. Filtra le parziali troppo brevi, troppo deboli o in eccesso (tiene le piu' forti).
  2. Semplifica con Ramer-Douglas-Peucker invece di min/max per segmento:
     tiene i punti dove la curva cambia davvero, non i picchi del rumore.
  3. Lavora in scale percettive: frequenza in cent, ampiezza in dB.
  4. Liscia il jitter con un filtro mediano prima di semplificare (opzionale).
  5. File di input e output da riga di comando; 

Uso:
  python3 analisi_parziali.py prova_peto06.txt -o peto06.txt
  python3 analisi_parziali.py prova_peto06.txt -o peto06.txt --max-partials 30 --tol-cents 80
"""

import argparse
import sys

import numpy as np

EPS = 1e-12
PAVIMENTO_DB = -90.0   # sotto questa soglia l'ampiezza conta come silenzio


# ---------------------------------------------------------------- lettura SPEAR

def leggi_spear(path):
    """Restituisce una lista di parziali: dict(id, t, f, a) con array numpy."""
    with open(path, "r", encoding="utf-8") as fh:
        righe = [r.strip() for r in fh if r.strip()]

    if not righe or righe[0] != "par-text-partials-format":
        sys.exit(f"{path}: non sembra un export SPEAR 'Text - Partials'")
    try:
        inizio = righe.index("partials-data") + 1
    except ValueError:
        sys.exit(f"{path}: manca la riga 'partials-data'")

    parziali = []
    i = inizio
    while i + 1 < len(righe):
        header = righe[i].split()
        dati = np.array(righe[i + 1].split(), dtype=float)
        pid, n = int(header[0]), int(header[1])
        dati = dati[: n * 3].reshape(-1, 3)
        parziali.append({"id": pid, "t": dati[:, 0], "f": dati[:, 1], "a": dati[:, 2]})
        i += 2
    return parziali


# ---------------------------------------------------------------- elaborazione

def mediana_mobile(x, k):
    """Filtro mediano di lunghezza dispari k; i bordi restano invariati."""
    if k < 3 or len(x) < k:
        return x.copy()
    h = k // 2
    out = x.copy()
    finestre = np.lib.stride_tricks.sliding_window_view(x, k)
    out[h:-h] = np.median(finestre, axis=1)
    return out


def rdp_indici(t, y, tol):
    """
    Ramer-Douglas-Peucker con errore verticale (nelle unita' di y).
    Restituisce gli indici dei punti da tenere, sempre inclusi primo e ultimo.
    """
    n = len(t)
    if n <= 2:
        return np.arange(n)
    tenere = np.zeros(n, dtype=bool)
    tenere[0] = tenere[-1] = True
    pila = [(0, n - 1)]
    while pila:
        a, b = pila.pop()
        if b - a < 2:
            continue
        seg_t, seg_y = t[a + 1:b], y[a + 1:b]
        dt = t[b] - t[a]
        if dt <= 0:
            interp = np.full_like(seg_y, y[a])
        else:
            interp = y[a] + (y[b] - y[a]) * (seg_t - t[a]) / dt
        err = np.abs(seg_y - interp)
        k = int(np.argmax(err))
        if err[k] > tol:
            m = a + 1 + k
            tenere[m] = True
            pila.append((a, m))
            pila.append((m, b))
    return np.flatnonzero(tenere)


def semplifica(t, y, tol, max_punti):
    """RDP con tolleranza crescente finche' i punti non sono <= max_punti."""
    idx = rdp_indici(t, y, tol)
    while max_punti and len(idx) > max_punti:
        tol *= 1.25
        idx = rdp_indici(t, y, tol)
    return idx


def elabora(parziali, args):
    picco_db = lambda p: 20 * np.log10(max(p["a"].max(), EPS))

    # 1. filtro: durata e ampiezza di picco
    tenute = [
        p for p in parziali
        if len(p["t"]) >= 2
        and (p["t"][-1] - p["t"][0]) >= args.min_dur
        and picco_db(p) >= args.min_db
    ]
    # 2. tieni le piu' forti (energia ~ somma ampiezze^2), poi riordina per inizio
    if args.max_partials and len(tenute) > args.max_partials:
        tenute.sort(key=lambda p: float(np.sum(p["a"] ** 2)), reverse=True)
        tenute = tenute[: args.max_partials]
    tenute.sort(key=lambda p: (p["t"][0], p["id"]))

    voci, punti_in, punti_out = [], 0, 0
    for p in tenute:
        t, f, a = p["t"], p["f"], p["a"]
        x0, dur = float(t[0]), float(t[-1] - t[0])
        pos = (t - x0) / dur if dur > 0 else np.zeros_like(t)

        cent = 1200 * np.log2(np.maximum(f, EPS) / 440.0)
        db = np.maximum(20 * np.log10(np.maximum(a, EPS)), PAVIMENTO_DB)
        cent_s = mediana_mobile(cent, args.smooth)
        db_s = mediana_mobile(db, args.smooth)

        i_f = semplifica(pos, cent_s, args.tol_cents, args.max_points)
        i_a = semplifica(pos, db_s, args.tol_db, args.max_points)

        # i valori in uscita sono quelli lisciati, riconvertiti in Hz e lineare
        freq = 440.0 * 2 ** (cent_s[i_f] / 1200)
        amp = 10 ** (db_s[i_a] / 20)

        voci.append([
            round(x0, 6), round(dur, 6),
            [[round(float(v), 6), round(float(q), 6)] for v, q in zip(freq, pos[i_f])],
            [[round(float(v), 6), round(float(q), 6)] for v, q in zip(amp, pos[i_a])],
        ])
        punti_in += 2 * len(t)
        punti_out += len(i_f) + len(i_a)

    resoconto = (f"parziali: {len(parziali)} -> {len(voci)}   "
                 f"punti (freq+amp): {punti_in} -> {punti_out}")
    return voci, resoconto


# ---------------------------------------------------------------- main

def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("input", help="export SPEAR 'Text - Partials'")
    ap.add_argument("-o", "--output", help="file di uscita per Max (default: stampa a schermo)")
    ap.add_argument("--min-dur", type=float, default=0.05,
                    help="durata minima della parziale in secondi (default 0.05)")
    ap.add_argument("--min-db", type=float, default=-60.0,
                    help="ampiezza di picco minima in dBFS (default -60)")
    ap.add_argument("--max-partials", type=int, default=40,
                    help="numero massimo di parziali, tiene le piu' forti (0 = tutte; default 40)")
    ap.add_argument("--tol-cents", type=float, default=50.0,
                    help="tolleranza frequenza in cent (default 50 = un quarto di tono)")
    ap.add_argument("--tol-db", type=float, default=3.0,
                    help="tolleranza ampiezza in dB (default 3)")
    ap.add_argument("--max-points", type=int, default=12,
                    help="punti massimi per curva (0 = nessun limite; default 12)")
    ap.add_argument("--smooth", type=int, default=5,
                    help="lunghezza del filtro mediano, dispari (0 = spento; default 5)")
    args = ap.parse_args()

    voci, resoconto = elabora(leggi_spear(args.input), args)
    testo = str(voci).replace(",", "")

    if args.output:
        with open(args.output, "w", encoding="utf-8") as fh:
            fh.write(testo + "\n")
    else:
        print(testo)
    print(resoconto, file=sys.stderr)


if __name__ == "__main__":
    main()
