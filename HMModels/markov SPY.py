# %% Imports 
import pandas as pd
import pandas_datareader.data as web
import sklearn.mixture as mix

import numpy as np
import scipy.stats as scs

import matplotlib as mpl
from matplotlib import cm
import matplotlib.pyplot as plt
from matplotlib.dates import YearLocator, MonthLocator

import seaborn as sns
import missingno as msno
from tqdm import tqdm
p=print


# %% get fed data

f1 = 'TEDRATE' # ted spread
f2 = 'T10Y2Y' # constant maturity ten yer - 2 year
f3 = 'T10Y3M' # constant maturity 10yr - 3m

start = pd.to_datetime('2002-01-05')
end = pd.datetime.today()

mkt = 'SPY'
MKT = (web.DataReader([mkt], 'yahoo', start, end)['Adj Close']
       .rename(columns={mkt:mkt})
       .assign(sret=lambda x: np.log(x[mkt]/x[mkt].shift(1)))
       .dropna())

print(MKT)

data = (web.DataReader([f1, f2, f3], 'fred', start, end)
        .join(MKT, how='inner')
        .dropna()
       )

p(data.head())

# gives us a quick visual inspection of the data


# %% Applying Markov Model
# code adapted from http://hmmlearn.readthedocs.io
# for sklearn 18.1

col = 'sret'
select = data.loc[:].dropna()

ft_cols = [f1, f2, f3, 'sret']
X = select[ft_cols].values

model = mix.GaussianMixture(n_components=3, 
                            covariance_type="full", 
                            n_init=100).fit(X)

model.fit(X)

# Predict the optimal sequence of internal hidden state
hidden_states = model.predict(X)

hidden_states1 = pd.DataFrame({'0':hidden_states[:]})
hidden_states1.rename(index=str, columns={"A": "a", "C": "c"})


#hidden_states1['0'].replace(['1'], 'high volatility')
#hidden_states1['0'].replace(['0'], 'low volatility')
#hidden_states1['0'].replace(['2'], 'medium volatility')


#for i in range(len(hidden_states1)):
#    if(hidden_states1[i] == 1):
#       hidden_states1[i] = "high volatility"
#    elif(hidden_states1[i] == 0):
#        hidden_states1[i] = "low volatility"
#    elif(hidden_states1[i] == 2):
#        hidden_states1[i] = "medium volatility"

volatilities = (model.covariances_[0][3][3],model.covariances_[1][3][3],
                model.covariances_[2][3][3])


propability_matrix = model.predict_proba(X)

high_vol = max(volatilities)
medium_vol = sorted(volatilities)[1]
low_vol = min(volatilities)
order_of_vols = [high_vol, medium_vol, low_vol]
        
print("high volatility: ",high_vol,
      "\nmedium volatility: ", medium_vol,
      "\nlow volatility: ", low_vol)

print("Means and vars of each hidden state")
for i in range(model.n_components):
    print("{0}th hidden state".format(i))
    print("mean = ", model.means_[i])
    print("var = ", np.diag(model.covariances_[i]))
    print("precision = ", model.precisions_[i])
    print()

# %% Printing Graphs
sns.set(font_scale=1.25)
style_kwds = {'xtick.major.size': 3, 'ytick.major.size': 3,
              'font.family':u'courier prime code', 'legend.frameon': True}
sns.set_style('white', style_kwds)

fig, axs = plt.subplots(model.n_components, sharex=True, sharey=True, figsize=(12,9))
colors = {'green', 'gold', 'crimson'}

for i, (ax, color) in enumerate(zip(axs, colors)):
    # Use fancy indexing to plot data in each state.
    mask = hidden_states == i
    ax.plot_date(select.index.values[mask],
                 select[col].values[mask],
                 ".-", c=color)
    ax.set_title("{0}th hidden state".format(i), fontsize=16, fontweight='demi')

    # Format the ticks.
    ax.xaxis.set_major_locator(YearLocator())
    ax.xaxis.set_minor_locator(MonthLocator())
    sns.despine(offset=10)

plt.tight_layout()
fig.savefig('Hidden Markov (Mixture) Model_Regime Subplots.png')

sns.set(font_scale=1.5)
states = (pd.DataFrame(hidden_states, columns=['states'], index=select.index)
          .join(select, how='inner')
          .assign(mkt_cret=select.sret.cumsum())
          .reset_index(drop=False)
          .rename(columns={'index':'Date'}))
p(states.head())

#for i in range(len(states.index)):
#    if(states.iloc[i]['states'] == 1):
#        states.at[states.index[i], 'states'] = "high volatility"
#    elif(states.iloc[i]['states'] == 0):
#        states.at[states.index[i], 'states'] = "low volatility"
#    elif(states.iloc[i]['states'] == 2):
#        states.at[states.index[i], 'states'] = "medium volatility"

sns.set_style('white', style_kwds)
order = [0, 1, 2]
fg = sns.FacetGrid(data=states, hue='states', hue_order=order,
                   palette=colors, aspect=1.31, size=12)
fg.map(plt.scatter, 'Date', mkt, alpha=0.8).add_legend()
sns.despine(offset=10)
fg.fig.suptitle('Historical SPY Regimes', fontsize=24, fontweight='demi')
fg.savefig('Hidden Markov (Mixture) Model_SPY Regimes.png')




