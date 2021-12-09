#!/usr/bin/env python2
# -*- coding: utf-8 -*-

"""
===============================================================================
Script 'colorblind.py'
===============================================================================

This script provides functions for Paul Tol's colorblind-friendly colors for
data.  See:
https://personal.sron.nl/~pault/
https://personal.sron.nl/~pault/colourschemes.pdf
"""
# @author: drmccloy
# Created on Thu Sep  1 17:07:57 2016
# License: MIT License


def sequential_colormap(x):
    from numpy import array
    from scipy.special import erf
    x = array(x)
    if any(x < 0) or any(x > 1):
        raise ValueError('x must be between 0 and 1 inclusive.')
    red = 1.000 - 0.392 * (1 + erf((x - 0.869) / 0.255))
    grn = 1.021 - 0.456 * (1 + erf((x - 0.527) / 0.376))
    blu = 1.000 - 0.493 * (1 + erf((x - 0.272) / 0.309))
    return array([red, grn, blu]).T


def diverging_colormap(x):
    from numpy import array
    x = array(x)
    if any(x < 0) or any(x > 1):
        raise ValueError('x must be between 0 and 1 inclusive.')
    red = (0.237 - 2.13 * x + 26.92 * x ** 2 - 65.5 * x ** 3 +
           63.5 * x ** 4 - 22.36 * x ** 5)
    grn = ((0.572 + 1.524 * x - 1.811 * x ** 2) /
           (1 - 0.291 * x + 0.1574 * x ** 2)) ** 2
    blu = 1. / (1.579 - 4.03 * x + 12.92 * x ** 2 - 31.4 * x ** 3 +
                48.6 * x ** 4 - 23.36 * x ** 5)
    return array([red, grn, blu]).T


def rainbow_colormap(x):
    from numpy import array
    x = array(x)
    if any(x < 0) or any(x > 1):
        raise ValueError('x must be between 0 and 1 inclusive.')
    red = ((0.472 - 0.567 * x + 4.05 * x ** 2) /
           (1 + 8.72 * x - 19.17 * x ** 2 + 14.1 * x ** 3))
    grn = (0.108932 - 1.22635 * x + 27.284 * x ** 2 - 98.577 * x ** 3 +
           163.3 * x ** 4 - 131.395 * x ** 5 + 40.634 * x ** 6)
    blu = 1. / (1.97 + 3.54 * x - 68.5 * x ** 2 + 243 * x ** 3 - 297 * x ** 4 +
                125 * x ** 5)
    return array([red, grn, blu]).T


def qualitative_colors(n):
    if n < 1:
        raise ValueError('Minimum number of qualitative colors is 1.')
    elif n > 12:
        raise ValueError('Maximum number of qualitative colors is 12.')
    cols = ['#4477AA', '#332288', '#6699CC', '#88CCEE', '#44AA99', '#117733',
            '#999933', '#DDCC77', '#661100', '#CC6677', '#AA4466', '#882255',
            '#AA4499']
    indices = [[0],
               [0, 9],
               [0, 7, 9],
               [0, 5, 7, 9],
               [1, 3, 5, 7, 9],
               [1, 3, 5, 7, 9, 12],
               [1, 3, 4, 5, 7, 9, 12],
               [1, 3, 4, 5, 6, 7, 9, 12],
               [1, 3, 4, 5, 6, 7, 9, 11, 12],
               [1, 3, 4, 5, 6, 7, 8, 9, 11, 12],
               [1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12],
               [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]]
    return [cols[ix] for ix in indices[n - 1]]


def graysafe_colors(n):
    if n < 1:
        raise ValueError('Minimum number of graysafe colors is 1.')
    elif n > 4:
        raise ValueError('Maximum number of graysafe colors is 4.')
    cols = ['#88CCEE', '#999933', '#AA4499', '#332288']
    return [cols[ix] for ix in range(n)]


def sequential_colors(n):
    if n < 3:
        raise ValueError('Minimum number of sequential colors is 3.')
    elif n > 9:
        raise ValueError('Maximum number of sequential colors is 9.')
    cols = ['#FFFFE5', '#FFFBD5', '#FFF7BC', '#FEE391', '#FED98E', '#FEC44F',
            '#FB9A29', '#EC7014', '#D95F0E', '#CC4C02', '#993404', '#8C2D04',
            '#662506']
    indices = [[2, 5, 8],
               [1, 3, 6, 9],
               [1, 3, 6, 8, 10],
               [1, 3, 5, 6, 8, 10],
               [1, 3, 5, 6, 7, 9, 10],
               [0, 2, 3, 5, 6, 7, 9, 10],
               [0, 2, 3, 5, 6, 7, 9, 10, 12]]
    return [cols[ix] for ix in indices[n - 3]]


def diverging_colors(n):
    if n < 3:
        raise ValueError('Minimum number of diverging colors is 3.')
    elif n > 11:
        raise ValueError('Maximum number of diverging colors is 11.')
    cols = ['#3D52A1', '#3A89C9', '#008BCE', '#77B7E5', '#99C7EC', '#B4DDF7',
            '#E6F5FE', '#FFFAD2', '#FFE3AA', '#F9BD7E', '#F5A275', '#ED875E',
            '#D03232', '#D24D3E', '#AE1C3E']
    indices = [[4, 7, 10],
               [2, 5, 9, 12],
               [2, 5, 7, 9, 12],
               [1, 4, 6, 8, 10, 13],
               [1, 4, 6, 7, 8, 10, 13],
               [1, 3, 5, 6, 8, 9, 11, 13],
               [1, 3, 5, 6, 7, 8, 9, 11, 13],
               [0, 1, 3, 5, 6, 8, 9, 11, 13, 14],
               [0, 1, 3, 5, 6, 7, 8, 9, 11, 13, 14]]
    return [cols[ix] for ix in indices[n - 3]]


def rainbow_colors(n):
    if n < 4:
        raise ValueError('Minimum number of rainbow colors is 4.')
    elif n > 12:
        raise ValueError('Maximum number of rainbow colors is 12.')
    c = ['#781C81', '#404096', '#57A3AD', '#529DB7', '#63AD99', '#6DB388',
         '#E39C37', '#D92120']
    cols = [[c[1], c[2], '#DEA73A', c[7]],
            [c[1], c[3], '#7DB874', c[6], c[7]],
            [c[1], '#498CC2', c[4], '#BEBC48', '#E68B33', c[7]],
            [c[0], '#3F60AE', '#539EB6', c[5], '#CAB843', '#E78532', c[7]],
            [c[0], '#3F56A7', '#4B91C0', '#5FAA9F', '#91BD61', '#D8AF3D',
             '#E77C30', c[7]],
            [c[0], '#3F4EA1', '#4683C1', c[2], c[5], '#B1BE4E', '#DFA53A',
             '#E7742F', c[7]],
            [c[0], '#3F479B', '#4277BD', c[3], '#62AC9B', '#86BB6A', '#C7B944',
             c[6], '#E76D2E', c[7]],
            [c[0], c[1], '#416CB7', '#4D95BE', '#5BA7A7', '#6EB387', '#A1BE56',
             '#D3B33F', '#E59435', '#E6682D', c[7]],
            [c[0], '#413B93', '#4065B1', '#488BC2', '#55A1B1', c[4], '#7FB972',
             '#B5BD4C', '#D9AD3C', '#E68E34', '#E6642C', c[7]]
            ]
    return cols[n - 4]


def banded_rainbow_colors(n):
    if n < 4:
        raise ValueError('Minimum number of rainbow color bands is 4.')
    elif n > 7:
        raise ValueError('Maximum number of rainbow color bands is 7.')
    col0 = ['#882E72', '#B178A6', '#D6C1DE', '#1965B0', '#5289C7', '#7BAFDE',
            '#4EB265', '#90C987', '#CAE0AB', '#F7EE55', '#F6C141', '#F1932D',
            '#E8601C', '#DC050C']
    cols = ['#771144', '#AA4477', '#DD77AA', '#771155', '#AA4488', '#CC99BB',
            '#114477', '#4477AA', '#77AADD', '#117777', '#44AAAA', '#77CCCC',
            '#117755', '#44AA88', '#99CCBB', '#117744', '#44AA77', '#88CCAA',
            '#777711', '#AAAA44', '#DDDD77', '#774411', '#AA7744', '#DDAA77',
            '#771111', '#AA4444', '#DD7777', '#771122', '#AA4455', '#DD7788']
    indices = [[0, 1, 2, 6, 7, 8, 12, 13, 14, 18, 19, 20, 24, 25, 26],
               [3, 4, 5, 6, 7, 8, 9, 10, 11, 18, 19, 20, 21, 22, 23, 27, 28,
                29],
               [3, 4, 5, 6, 7, 8, 9, 10, 11, 15, 16, 17, 18, 19, 20, 21, 22,
                23, 27, 28, 29]]
    if n == 4:
        return col0
    else:
        return [cols[ix] for ix in indices[n - 5]]


def test_colormaps():
    import numpy as np
    import matplotlib.pyplot as plt
    from matplotlib.colors import ListedColormap
    from matplotlib.cm import register_cmap
    plt.ioff()
    funcs = [rainbow_colors, sequential_colors, diverging_colors,
             qualitative_colors]
    cmaps = [rainbow_colormap, sequential_colormap, diverging_colormap, None]
    titles = ['(banded) rainbow', 'sequential', 'diverging', 'qualitative']
    offsets = [4, 3, 3, 1]
    nums = [9, 7, 9, 12]
    band_dict = {4: 14, 5: 15, 6: 18, 7: 21}
    subplot_dims = (7, len(funcs))
    fig, axs = plt.subplots(*subplot_dims, figsize=(14, 7))
    kwargs = dict(marker='s', s=70)
    for ix, (func, offset, num, cmap, title
             ) in enumerate(zip(funcs, offsets, nums, cmaps, titles)):
        ax = plt.subplot2grid(subplot_dims, (0, ix), fig=fig,
                              rowspan=subplot_dims[0] - 2)
        ticks = []
        for n in range(num):
            x = np.arange(0, n + offset)
            y = np.tile(n + offset, n + offset)
            ax.scatter(x, y, c=func(n + offset), **kwargs)
            ticks.append(n + offset)
        if not ix:  # plot banded
            for n in range(4):
                bands = band_dict[n + 4]
                x = np.arange(0, bands)
                y = np.tile(bands, bands)
                ax.scatter(x, y, c=banded_rainbow_colors(n + 4), **kwargs)
                ticks.append(bands)
        # continuous colormaps
        if cmap is not None:
            x = np.linspace(0, 20, 256)
            y = np.tile(0, 256)
            z = np.linspace(0, 1, 256)
            ax.scatter(x, y, c=cmap(z), marker='s', s=20)
        ax.set_xbound(-1, 22)
        ax.set_ybound(-1, 22)
        ax.set_yticks(ticks)
        ax.xaxis.set_visible(False)
        ax.yaxis.tick_left()
        ax.set_title(title)
        for side in ax.spines.keys():
            ax.spines[side].set_visible(False)
    # test matplotlib-registered cmaps
    lsp = np.linspace(0, 1, 256)
    gradient = np.vstack((lsp, lsp))
    names = ['colorblind_rainbow', 'colorblind_sequential',
             'colorblind_diverging', None]
    datas = [rainbow_colormap(lsp), sequential_colormap(lsp),
             diverging_colormap(lsp), None]
    for ix, (name, data) in enumerate(zip(names, datas)):
        if name is not None:
            register_cmap(cmap=ListedColormap(data, name=name))
            ax = plt.subplot2grid(subplot_dims, (subplot_dims[0] - 2, ix),
                                  fig=fig)
            ax.imshow(gradient, aspect='auto', cmap=plt.get_cmap(name))
            ax.set_title(name)
            ax.set_axis_off()
            # reversed
            name = name + '_r'
            data = list(reversed(data))
            register_cmap(cmap=ListedColormap(data, name=name))
            ax = plt.subplot2grid(subplot_dims, (subplot_dims[0] - 1, ix),
                                  fig=fig)
            ax.imshow(gradient, aspect='auto', cmap=plt.get_cmap(name))
            ax.set_title(name)
            ax.set_axis_off()
        else:
            ax = plt.subplot2grid(subplot_dims, (subplot_dims[0] - 2, ix),
                                  fig=fig, rowspan=2)
            ax.set_axis_off()

    # finish
    plt.tight_layout()
    plt.savefig('test_colormaps.pdf')


if __name__ == '__main__':
    test_colormaps()
