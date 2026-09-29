#!/usr/bin/env python3
"""Summarize measured CSV output; never generate example measurements."""
import csv
import statistics
import sys
from collections import defaultdict
from pathlib import Path

folder = Path(sys.argv[1])
times = defaultdict(list)
intervals = set()
for path in sorted(folder.glob("p*-r*.csv")):
    with path.open(newline="") as source:
        rows = list(csv.DictReader(source))
    if len(rows) != 1:
        raise SystemExit(f"Expected one result row in {path}")
    row = rows[0]
    seconds = float(row["seconds"])
    if seconds <= 0 or float(row["abs_error"]) > 1e-6:
        raise SystemExit(f"Invalid timing or pi result in {path}")
    intervals.add(int(row["intervals"]))
    times[int(row["ranks"])].append(seconds)
if 1 not in times or len(intervals) != 1:
    raise SystemExit("Need a one-rank baseline and one fixed problem size")
baseline = statistics.median(times[1])
with (folder / "summary.csv").open("w", newline="") as output:
    writer = csv.writer(output)
    writer.writerow(["ranks", "repeats", "median_seconds", "speedup",
                     "efficiency"])
    for ranks, samples in sorted(times.items()):
        median = statistics.median(samples)
        speedup = baseline / median
        row = [ranks, len(samples), f"{median:.6f}",
               f"{speedup:.3f}", f"{speedup / ranks:.3f}"]
        writer.writerow(row)
        print(",".join(map(str, row)))
