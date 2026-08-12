#!/usr/bin/env python
""" Plot Alpe d'HuZes profile data"""

from datetime import datetime
import matplotlib.pyplot as plt
plt.xkcd()

import pandas as pd


# Read the CSV file.  The exported file has the following columns
# Time	HR[bpm]	Pace[min/mile]	Altitude[m]
data = pd.read_csv('ad6.txt', sep='\t', index_col=0, parse_dates=True)


def to_min_per_km(s):
    return datetime.strptime(s, '%M:%S') - datetime(1900, 1, 1)

data['elevation_gain'] = data['altitude'].diff().clip(0).cumsum() / 1000
data['pace'] = data['pace'].apply(to_min_per_km)

plt.clf()
plt.subplot(211)
plt.title("Alpe d'HuZes 2015 (ascent to Alpe d'Huez 6 times)")
data.plot(y='altitude')
plt.ylabel('altitude [m]')

plt.subplot(212)

data.plot(y='elevation_gain')
plt.ylabel('elevation gain [km]')

plt.tight_layout()
plt.show()

plt.savefig('ad6_elevation.png')
