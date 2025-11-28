import matplotlib.pyplot as plt
import numpy as np

from matplotlib import cm
from matplotlib.ticker import LinearLocator
import netCDF4 as nc
import numpy as np
import os
filename='wout_pwO_nfp2_A6.nc'
filepath=os.path.join(os.path.dirname(__file__), filename)
f=nc.Dataset(filepath, 'r')
nfp=f.variables['nfp'][0]

ns=f.variables['ns'][:].data
xn_nyq=f.variables['xn_nyq'][:].data
xm_nyq=f.variables['xm_nyq'][:].data
xn=f.variables['xn'][:].data
xm=f.variables['xm'][:].data
max_mnnyq=f.variables['mnmax_nyq'][:].data
max_mn=f.variables['mnmax'][:].data
def getsum_cos(coeff, m,n, s, theta, zeta):
    result = 0.0
    for idx in range(coeff.shape[1]):
        result+=coeff[s,idx]*np.cos(m[idx]*theta - n[idx]*zeta/nfp)
        
    return result
def getsum_sin(coeff, m,n, s, theta, zeta):
    result = 0.0
    for idx in range(coeff.shape[1]):
        result+=coeff[s,idx]*np.sin(m[idx]*theta - n[idx]*zeta/nfp)
        
    return result


def get_b(s, theta, zeta):
    b_coeff=f.variables['bmnc'][:].data
    return getsum_cos(b_coeff, xm_nyq, xn_nyq, s, theta, zeta)

def get_r(s, theta, zeta):
    r_coeff=f.variables['rmnc'][:].data
    return getsum_cos(r_coeff, xm, xn, s, theta, zeta)

def get_z(s, theta, zeta):
    z_coeff=f.variables['zmns'][:].data
    return getsum_sin(z_coeff, xm, xn, s, theta, zeta)
fig, ax = plt.subplots(subplot_kw={"projection": "3d"})


# Make data.
zeta=np.arange(0,4*np.pi,np.pi/50)
theta=np.arange(0,2*np.pi,np.pi/50)
ZETA, THETA = np.meshgrid(zeta, theta)
R=get_r(ns-1, THETA, ZETA)
Z=get_z(ns-1, THETA, ZETA)
X=R*np.cos(ZETA/2)
Y=R*np.sin(ZETA/2)
B=get_b(ns-1, THETA, ZETA)

# 🔥 색 기준: X + Z
C = B
norm = plt.Normalize(C.min(), C.max())
colors = cm.coolwarm(norm(C))

# Plot the surface.
surf = ax.plot_surface(
    X, Y, Z,
    facecolors=colors,
    linewidth=0,
    antialiased=False
)

# z axis formatting
ax.set_zlabel('Z axis')
ax.set_xlabel('X axis')
ax.set_ylabel('Y axis')
ax.set_zlim(-1.01, 1.01)
ax.zaxis.set_major_locator(LinearLocator(10))
ax.zaxis.set_major_formatter('{x:.02f}')

# Color bar
mappable = cm.ScalarMappable(norm=norm, cmap=cm.coolwarm)
mappable.set_array(C)
fig.colorbar(mappable, ax=ax, shrink=0.5, aspect=5)

plt.show()
