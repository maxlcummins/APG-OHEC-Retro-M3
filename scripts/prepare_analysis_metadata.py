#!/usr/bin/env python3
"""Extract the columns required by the active manuscript analysis.

Run from the repository root. The output retains sample identifiers.
"""
import csv
import gzip
import io
import re
import sys
from pathlib import Path

source = Path('delims/genometa_n5471.txt')
target = Path('delims/genometa_analysis.tsv.gz')
base = ['name', 'ST_new', 'Consensus_phylogroup', 'Revised_Source_Niche',
        'State', 'Collection_Year', 'ectyper..Serotype', 'ColV']
markers = ['fyuA/psn', 'irp1', 'irp2', 'ybtA', 'ybtE', 'ybtP', 'ybtQ',
           'ybtS', 'ybtT', 'ybtU', 'ybtX', 'senB', 'stx1A', 'stx1B',
           'stx2A', 'stx2B', 'stxA']
required = base + ['ABRICATE..vfdb_' + marker for marker in markers] + [
    'ABRICATE..EC_custom_intI1_HQ730118.1']
# These match the selectors used in the notebook's ExPEC summary.
patterns = [r'EC_custom_afaE-[13]|vfdb_dra[BC]$',
            r'colV_zoetis_iutA$|EC_custom_iutA_|vfdb_iutA$',
            r'EC_custom_kpsMT.*II', r'EC_custom_pap[ACH]_|vfdb_pap[ACH]$',
            r'vfdb_(sfa[DE]|focD)$']

csv.field_size_limit(sys.maxsize)
with source.open(newline='', encoding='utf-8') as f:
    reader = csv.reader(f, delimiter='\t')
    header = next(reader)
    missing = sorted(set(required) - set(header))
    if missing:
        raise SystemExit('Missing required metadata columns: ' + ', '.join(missing))
    selected = [i for i, name in enumerate(header) if name in required or
                any(re.search(pattern, name, re.IGNORECASE) for pattern in patterns)]
    with target.open('wb') as raw:
        with gzip.GzipFile(filename='', mode='wb', fileobj=raw, mtime=0) as compressed:
            with io.TextIOWrapper(compressed, encoding='utf-8', newline='') as text:
                writer = csv.writer(text, delimiter='\t', lineterminator='\n')
                writer.writerow([header[i] for i in selected])
                count = 0
                for row in reader:
                    if len(row) != len(header):
                        raise ValueError(f'Row {reader.line_num} has {len(row)} fields; expected {len(header)}')
                    writer.writerow([row[i] for i in selected])
                    count += 1
print(f'Wrote {count} rows and {len(selected)} columns to {target}')
