import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
import numpy as np

ns = 2**12
dx = 0.4
x = np.linspace(-ns/2, ns/2, ns)*dx

z = np.fromfile('../data/fs.bin', dtype=complex)

total = np.sum(np.abs(z)**2) * dx**2
print('total', total)

p = z
p = abs(p)**2
p = p/p.max()
P = p.reshape(ns, ns)
plt.imshow(P, norm=LogNorm(), extent=[x.min(), x.max(), x.min(), x.max()])
# plt.imshow(P, extent=[x.min(), x.max(), x.min(), x.max()])
plt.colorbar()
plt.show()