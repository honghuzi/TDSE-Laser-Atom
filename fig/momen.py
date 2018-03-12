import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
from matplotlib import rc
from matplotlib.colors import LogNorm
from mpl_toolkits.axes_grid1 import make_axes_locatable, axes_size
#from matplotlib.ticker import MaxNLocator
import matplotlib.ticker as ticker
#plt.style.use('seaborn-white')
#print(plt.style.available)

#rc('font',**{'family':'sans-serif','sans-serif':['Helvetica'], 'size':'20'})
# rc('font',**{'family':'sans-serif', 'size':'20'})
rc('font',**{'sans-serif':['Helvetica LT'], 'size':'20'})
data = np.fromfile('../data2/momentum.bin')

x, y, p = data[::3], data[1::3], data[2::3]
p = abs(p)**2
p = p/p.max()
print('p=,', p)
fig, ax = plt.subplots(figsize=(7, 6))

n = np.int(np.sqrt(len(p)))
n2 = np.int(n/2)
X = x.reshape(n, n)
Y = y.reshape(n, n)
P = p.reshape(n, n)
# P = np.roll(P, (n2, n2))
########################################
##### configure the plotting style #####
########################################
#ax.spines['top'].set_visible(False)
#ax.spines['right'].set_visible(False)

ax.xaxis.set_tick_params(width=1, length=3, direction='out', which='both')
ax.yaxis.set_tick_params(width=1, length=3, direction='out', which='both')

ax.xaxis.set_major_formatter(ticker.FormatStrFormatter('%0.2g'))
ax.yaxis.set_major_formatter(ticker.FormatStrFormatter('%0.2g'))

L = 2.5
ntick = 5
Ltick = 2.0
ax.xaxis.set_ticks(np.linspace(-Ltick, Ltick, ntick))
ax.yaxis.set_ticks(np.linspace(-Ltick, Ltick, ntick))
ax.set_xlabel(r'$\mathrm{P}_1$(a.u.)')
ax.set_ylabel(r'$\mathrm{P}_2$(a.u.)')
########################################

h0 = 1e-5
h1 = 1#e-3
P = h1*(P>h1) + P*(P<=h1)*(P>h0) + h0*(P<h0)

P = P/float(P.max())

v1 = 1e-6
v2 = 1

# im = ax.imshow(P, origin = 'lower', interpolation="None", cmap='RdBu_r', alpha=0.5, extent=[x.min(),x.max(), y.min(), y.max()])
im = ax.imshow(P, origin = 'lower', interpolation="None", cmap='RdBu_r', alpha=1, norm=LogNorm(), extent=[x.min(),x.max(), y.min(), y.max()])#, vmin=v1, vmax=v2) 

aspect = 20
pad_fraction = 1

divider = make_axes_locatable(ax)
width = axes_size.AxesY(ax, aspect=1/aspect)
pad = axes_size.Fraction(pad_fraction, width)
cax = divider.append_axes("right", size=width, pad=pad)

cbar = fig.colorbar(im, cax=cax, ticks = np.logspace(-6, 0, 7))

# cbar.set_clim(v1, v2)
# cbar.set_range(1e-10, 1.0)



# ax.axis([-L, 0, 0, L])
# ax.axis([0, L, 0, L])

ax.axis([-L, L, -L, L])
fig.tight_layout()
plt.show()
fig.savefig('p.eps')
