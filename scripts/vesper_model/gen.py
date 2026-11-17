#!/usr/bin/env python3
"""Generate an original hooded-knight fighter model as an ssb64_model work folder.

Geometry, colors and textures are all made here from scratch. The only things taken from
the base fighter files are the skeleton (joint rest matrices) and the list of model-part
slots the game expects.

    python3 gen.py EXPORT_DIR WORK_DIR
EXPORT_DIR: an `ssb64_model.py export --no-blend` of the base character folder.
"""
import json
import math
import os
import struct
import sys

import numpy as np
from PIL import Image, ImageDraw

EXPORT, WORK = sys.argv[1], sys.argv[2]
os.makedirs(WORK, exist_ok=True)
TEX = os.path.join(WORK, 'tex')
os.makedirs(TEX, exist_ok=True)

# ------------------------------------------------------------------ skeleton (rest pose)
g0 = json.load(open(os.path.join(EXPORT, 'model.gltf')))
buf0 = open(os.path.join(EXPORT, 'model.bin'), 'rb').read()


def acc0(i):
    a = g0['accessors'][i]
    bv = g0['bufferViews'][a['bufferView']]
    n = {'SCALAR': 1, 'VEC2': 2, 'VEC3': 3, 'VEC4': 4, 'MAT4': 16}[a['type']]
    dt = {5126: '<f4', 5123: '<u2', 5125: '<u4', 5121: 'u1'}[a['componentType']]
    st = bv.get('byteOffset', 0) + a.get('byteOffset', 0)
    return np.frombuffer(buf0, dt, a['count'] * n, st).reshape(a['count'], n)


sk = g0['skins'][0]
ib = acc0(sk['inverseBindMatrices']).reshape(-1, 4, 4)
W = {}
for j, m in zip(sk['joints'], ib):
    nm = g0['nodes'][j]['name']
    if nm.startswith('joint_'):
        W[int(nm[6:])] = np.linalg.inv(m.T.astype(float))
NJ = max(W) + 1
JP = {j: W[j][:3, 3] for j in W}                      # joint world positions


def to_world(j, pts):
    pts = np.atleast_2d(np.asarray(pts, float))
    return (W[j] @ np.c_[pts, np.ones(len(pts))].T).T[:, :3]


# ------------------------------------------------------------------ mesh building
class Mesh:
    """Triangles with flat normals; every triangle belongs to one joint."""

    def __init__(self, name, joint):
        self.name, self.joint, self.tris = name, joint, []

    def tri(self, mat, a, b, c, uv=None, center=None, col=None):
        a, b, c = (np.asarray(p, float) for p in (a, b, c))
        n = np.cross(b - a, c - a)
        ln = np.linalg.norm(n)
        if ln < 1e-9:
            return
        n /= ln
        if center is not None and np.dot(n, (a + b + c) / 3 - np.asarray(center, float)) < 0:
            b, c, n = c, b, -n
            if uv is not None:
                uv = (uv[0], uv[2], uv[1])
        self.tris.append((mat, (a, b, c), n, uv or ((0, 0), (0, 0), (0, 0)), col))

    def quad(self, mat, a, b, c, d, uv=None, center=None, col=None):
        u = uv or ((0, 0),) * 4
        self.tri(mat, a, b, c, (u[0], u[1], u[2]), center, col)
        self.tri(mat, a, c, d, (u[0], u[2], u[3]), center, col)

    def ring(self, c, u, v, ru, rv, n, phase=0.5):
        c, u, v = (np.asarray(x, float) for x in (c, u, v))
        return [c + u * ru * math.cos(2 * math.pi * (k + phase) / n) + v * rv * math.sin(2 * math.pi * (k + phase) / n)
                for k in range(n)]

    def loft(self, mat, rings, cap0=True, cap1=True, mats=None):
        """Rings of equal length joined by quads; mats: {(ring index, side index): material}."""
        mid = np.mean([np.mean(r, 0) for r in rings], 0)
        for i in range(len(rings) - 1):
            r0, r1 = rings[i], rings[i + 1]
            cen = (np.mean(r0, 0) + np.mean(r1, 0)) / 2
            n = len(r0)
            for k in range(n):
                m = (mats or {}).get((i, k), mat)
                if m is None:
                    continue
                self.quad(m, r0[k], r0[(k + 1) % n], r1[(k + 1) % n], r1[k], center=cen)
        for cap, r in ((cap0, rings[0]), (cap1, rings[-1])):
            if cap:
                cc = np.mean(r, 0)
                for k in range(len(r)):
                    self.tri(mat if cap is True else cap, cc, r[k], r[(k + 1) % len(r)], center=mid)

    def prism(self, mat, p0, p1, r0, r1, n=6, up=(0, 1, 0), phase=0.5, cap0=True, cap1=True, mats=None):
        p0, p1 = np.asarray(p0, float), np.asarray(p1, float)
        d = p1 - p0
        d /= np.linalg.norm(d)
        up = np.asarray(up, float)
        if abs(np.dot(up, d)) > 0.95:
            up = np.array([0, 0, 1.0])
        u = np.cross(up, d)
        u /= np.linalg.norm(u)
        v = np.cross(d, u)
        r0 = r0 if isinstance(r0, tuple) else (r0, r0)
        r1 = r1 if isinstance(r1, tuple) else (r1, r1)
        self.loft(mat, [self.ring(p0, u, v, r0[0], r0[1], n, phase), self.ring(p1, u, v, r1[0], r1[1], n, phase)],
                  cap0, cap1, mats)

    def box(self, mat, lo, hi, mats=None):
        (x0, y0, z0), (x1, y1, z1) = lo, hi
        c = ((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2)
        P = lambda x, y, z: (x, y, z)  # noqa: E731
        faces = {'-x': (P(x0, y0, z0), P(x0, y0, z1), P(x0, y1, z1), P(x0, y1, z0)),
                 '+x': (P(x1, y0, z0), P(x1, y1, z0), P(x1, y1, z1), P(x1, y0, z1)),
                 '-y': (P(x0, y0, z0), P(x1, y0, z0), P(x1, y0, z1), P(x0, y0, z1)),
                 '+y': (P(x0, y1, z0), P(x0, y1, z1), P(x1, y1, z1), P(x1, y1, z0)),
                 '-z': (P(x0, y0, z0), P(x0, y1, z0), P(x1, y1, z0), P(x1, y0, z0)),
                 '+z': (P(x0, y0, z1), P(x1, y0, z1), P(x1, y1, z1), P(x0, y1, z1))}
        for k, f in faces.items():
            m = (mats or {}).get(k, mat)
            if m is not None:
                self.quad(m, *f, center=c)

    def add(self, other, xform=None):
        for mat, (a, b, c), n, uv, col in other.tris:
            if xform is not None:
                a, b, c = (xform(p) for p in (a, b, c))
                self.tri(mat, a, b, c, uv, None, col)
            else:
                self.tris.append((mat, (a, b, c), n, uv, col))


# ------------------------------------------------------------------ the knight
def sword_local(detail):
    """A longsword with a crescent guard, in the weapon joint's own space (blade along +X)."""
    m = Mesh('sword', 15)
    n = 4
    m.prism('trim', (-85, 0, 0), (-72, 0, 0), 4, 9, n, up=(0, 0, 1), cap1=True)          # pommel
    m.prism('leather', (-72, 0, 0), (26, 0, 0), 6, 6, n, up=(0, 0, 1), cap0=False, cap1=False)                    # two-handed grip
    # crescent guard: a centre block and two horns sweeping toward the blade
    m.box('trim', (26, -14, -7), (40, 14, 7))
    for sgn in (1, -1):                                                                    # the horns
        base = [np.array(p, float) for p in ((28, sgn * 12, 6), (28, sgn * 12, -6), (42, sgn * 12, 0))]
        tipp = np.array((72.0, sgn * 46, 0))
        mid = [np.array(p, float) for p in ((38, sgn * 32, 4), (38, sgn * 32, -4), (50, sgn * 30, 0))]
        m.loft('trim', [base, mid], cap0=False, cap1=False)
        for k in range(3):
            m.tri('trim', mid[k], mid[(k + 1) % 3], tipp, center=(48, sgn * 36, 0))
    # blade: flat diamond section, tapering to the point
    def sect(x, hw, ht):
        return [np.array(p, float) for p in ((x, hw, 0), (x, 0, ht), (x, -hw, 0), (x, 0, -ht))]
    m.loft('steel', [sect(40, 17, 5.5), sect(350, 12, 3.5)], cap0=False, cap1=False)
    tip = np.array((405.0, 0, 0))
    r = sect(350, 12, 3.5)
    for k in range(4):
        m.tri('steel', r[k], r[(k + 1) % 4], tip, center=(370, 0, 0))
    if detail == 'hi':                                                                    # fuller: a darker inlay
        m.quad('trim', (60, 4, 5.9), (60, -4, 5.9), (250, -3, 5.0), (250, 3, 5.0), center=(150, 0, 0))
        m.quad('trim', (60, 4, -5.9), (250, 3, -5.0), (250, -3, -5.0), (60, -4, -5.9), center=(150, 0, 0))
    return m


def build(detail):
    hi = detail == 'hi'
    n8, n6 = (6, 4) if hi else (4, 4)
    out = {}

    def M(j):
        return out.setdefault(j, Mesh(f'{detail}_j{j:02d}', j))

    # ---- pelvis: hips, belt, front and back cloth panels
    m = M(1)
    m.prism('cloth2', (0, 236, 2), (0, 280, 0), (40, 31), (43, 31), n8, up=(0, 0, 1), cap1=False)
    m.prism('leather', (0, 274, 0), (0, 288, 0), (46, 34), (46, 34), n8, up=(0, 0, 1), cap0=False, cap1=False)
    if hi:
        m.box('trim', (-7, 272, 33), (7, 290, 38), mats={'-z': None})                    # buckle
    m.loft('cloth', [[np.array(p, float) for p in ((-17, 282, 36), (17, 282, 36), (17, 282, 31), (-17, 282, 31))],
                     [np.array(p, float) for p in ((-15, 190, 40), (15, 190, 40), (15, 190, 36), (-15, 190, 36))]])
    m.loft('cloth', [[np.array(p, float) for p in ((-24, 282, -30), (24, 282, -30), (24, 282, -35), (-24, 282, -35))],
                     [np.array(p, float) for p in ((-26, 200, -34), (22, 214, -34), (22, 214, -39), (-26, 200, -39))]])

    # ---- torso: breastplate, tabard, cowl mantle, half-cape off the left shoulder
    m = M(2)
    m.prism('metal', (0, 280, -3), (0, 374, -8), (48, 33), (60, 39), n8, up=(0, 0, 1), cap1=False)
    m.box('cloth', (-15, 286, 28), (15, 362, 36.5))                                       # tabard
    if hi:
        m.quad('trim', (-15, 322, 36.9), (15, 322, 36.9), (15, 328, 36.9), (-15, 328, 36.9), center=(0, 325, 0))                                    # tabard band
    mantle = [m.ring((0, 388, -12), (1, 0, 0), (0, 0, 1), 30, 28, n8),
              m.ring((0, 366, -11), (1, 0, 0), (0, 0, 1), 62, 44, n8),
              m.ring((0, 346, -10), (1, 0, 0), (0, 0, 1), 74, 50, n8)]
    m.loft('cloth', mantle, cap0=False, cap1=True)
    cape_top = [np.array(p, float) for p in ((-6, 372, -44), (74, 368, -40), (74, 368, -47), (-6, 372, -51))]
    cape_mid = [np.array(p, float) for p in ((-12, 300, -50), (80, 296, -44), (80, 296, -51), (-12, 300, -57))]
    cape_low = [np.array(p, float) for p in ((6, 226, -52), (78, 248, -46), (78, 248, -52), (6, 226, -58))]
    m.loft('cloth', [cape_top, cape_mid, cape_low], cap0=False, cap1=True)
    if hi:
        m.prism('trim', (58, 372, -30), (58, 372, -48), 7, 7, 4, up=(0, 1, 0), cap0=False)               # cape clasp

    # ---- neck
    M(18).prism('cloth', (0, 364, -14), (0, 402, -13), 15, 15, n6, up=(0, 0, 1), cap0=False, cap1=False)

    # ---- head: a deep cowl; the face is a shadowed panel with two pale eyes
    m = M(19)
    ux, uz = (1, 0, 0), (0, 0, 1)
    ph = 0.5                                                                              # a flat facet faces +Z
    rings = [m.ring((0, 388, -10), ux, uz, 34, 34, 8, ph), m.ring((0, 412, -6), ux, uz, 52, 54, 8, ph),
             m.ring((0, 452, -6), ux, uz, 58, 60, 8, ph), m.ring((0, 484, -16), ux, uz, 42, 48, 8, ph)]
    front = 1                                                                             # facet index facing +Z
    m.loft('cloth', rings, cap0=False, cap1=False, mats={(0, front): 'shadow', (1, front): None})
    r1, r2 = rings[1], rings[2]
    a, b, c, d = r1[front], r1[(front + 1) % 8], r2[(front + 1) % 8], r2[front]           # the face panel
    inset = np.array((0, 0, -7.0))
    fa, fb, fc, fd = a + inset, b + inset, c + inset, d + inset
    lr = sorted([fa, fb], key=lambda p: -p[0])                                            # viewer's left first
    tp = sorted([fc, fd], key=lambda p: -p[0])
    m.quad('eyes', lr[0], lr[1], tp[1], tp[0], uv=((0, 1), (1, 1), (1, 0), (0, 0)), center=(0, 426, -40))
    for p, q, pi, qi in ((a, d, fa, fd), (b, c, fb, fc), (d, c, fd, fc)):                 # recess walls
        m.quad('shadow', p, q, qi, pi, center=(0, 426, 60))
    apex = np.array((0.0, 504, -46))
    for k in range(8):
        m.tri('cloth', rings[3][k], rings[3][(k + 1) % 8], apex, center=(0, 440, -10))
    if hi:                                                                                # brow peak of the cowl
        m.tri('cloth', c + (0, 0, 0.5), d + (0, 0, 0.5), (0, 462, 76), center=(0, 430, 0))
        m.tri('cloth', d + (0, 0, 0.5), c + (0, 0, 0.5), (0, 462, 76), center=(0, 480, 200))
        m.box('trim', (-4, 470, 50), (4, 478, 57))                                        # brow stud

    # ---- left arm (cloth sleeve, leather bracer and glove)
    M(4).prism('cloth2', JP[4] + (-4, 0, 0), JP[5], 18, 15, n6, cap0=False)
    m = M(5)
    m.prism('leather', JP[5], JP[6] + (-2, 0, 0), 15, 13, n6)
    if hi:
        m.prism('trim', JP[5] + (6, 0, 0), JP[5] + (12, 0, 0), 16.5, 16.5, n6, cap0=False, cap1=False)
    M(6).prism('leather', JP[6] + (-2, 0, 0), JP[6] + (44, 1, -3), (16, 13), (11, 9), n6)

    # ---- right arm (plate: pauldron, rerebrace, vambrace, gauntlet)
    m = M(9)
    m.prism('metal', JP[9] + (4, 0, 0), JP[10], 18, 16, n6, cap0=False)
    m.loft('metal', [m.ring(JP[9] + (16, 6, 0), (0, 1, 0), (0, 0, 1), 20, 24, n6),
                     m.ring(JP[9] + (-8, 8, 0), (0, 1, 0), (0, 0, 1), 28, 30, n6),
                     m.ring(JP[9] + (-34, 4, 0), (0, 1, 0), (0, 0, 1), 22, 24, n6)], cap0=True, cap1=True)
    if hi:
        m.prism('trim', JP[9] + (-34, 4, 0), JP[9] + (-39, 4, 0), 23.5, 23.5, n6, up=(0, 1, 0), cap0=False)
    m = M(10)
    m.prism('metal', JP[10], JP[11] + (2, 0, 0), 17, 14, n6)
    if hi:
        m.prism('trim', JP[10] + (-8, 0, 0), JP[10] + (-14, 0, 0), 18, 18, n6, cap0=False, cap1=False)
    M(11).prism('metal', JP[11] + (2, 0, 0), JP[11] + (-44, 1, -3), (16, 13), (12, 10), n6)

    # ---- legs: trousers, greaves with a knee cop, boots
    for th, sh, ft, sx in ((22, 23, 25, 1), (27, 28, 30, -1)):
        hip, knee, ankle = JP[th], JP[sh], JP[ft]
        M(th).prism('cloth2', hip + (sx * 2, 6, 0), knee + (0, -2, 0), (27, 29), (20, 22), n6, up=(0, 0, 1), cap0=False)
        m = M(sh)
        m.prism('metal', knee + (0, 4, 0), ankle + (0, 10, 0), (20, 22), (14, 15), n6, up=(0, 0, 1))
        m.prism('metal', knee + (0, 12, 14), knee + (0, -14, 20), (12, 6), (9, 5), 4, up=(1, 0, 0))   # knee cop
        m = M(ft)
        heel = ankle + (0, -4, -16)
        m.loft('leather', [[np.array(heel + p, float) for p in ((-16, -17, 0), (16, -17, 0), (15, 16, 0), (-15, 16, 0))],
                           [np.array(ankle + p, float) for p in ((-17, -21, 30), (17, -21, 30), (15, 6, 30), (-15, 6, 30))],
                           [np.array(ankle + p, float) for p in ((-13, -21, 72), (13, -21, 72), (11, -9, 72), (-11, -9, 72))]])
        if hi:
            m.prism('trim', ankle + (0, 12, -2), ankle + (0, 17, -2), (16, 17), (16, 17), n6, up=(0, 0, 1), cap0=False)

    # (the weapon is a model part on its own joint: see the parts below)
    return out


# ------------------------------------------------------------------ colors: six original colorways
def lin(c):
    c = np.asarray(c, float) / 255
    return [float(x) for x in np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)]


#            cowl / cape      under-cloth      plate            leather          trim             blade
COLORWAYS = [
    dict(cloth=(72, 76, 88), cloth2=(44, 46, 56), metal=(150, 156, 168), leather=(92, 66, 46), trim=(206, 214, 232), steel=(226, 230, 238)),   # ash
    dict(cloth=(34, 52, 112), cloth2=(26, 30, 60), metal=(136, 148, 176), leather=(60, 50, 60), trim=(232, 206, 120), steel=(222, 228, 240)),  # midnight
    dict(cloth=(150, 64, 36), cloth2=(70, 44, 36), metal=(168, 150, 132), leather=(84, 54, 34), trim=(236, 196, 120), steel=(232, 226, 216)),  # rust
    dict(cloth=(226, 218, 198), cloth2=(150, 134, 110), metal=(190, 188, 180), leather=(120, 90, 62), trim=(120, 70, 60), steel=(236, 236, 232)),  # bone
    dict(cloth=(44, 88, 58), cloth2=(52, 46, 34), metal=(142, 146, 128), leather=(96, 70, 44), trim=(214, 190, 110), steel=(224, 230, 226)),   # forest
    dict(cloth=(26, 24, 30), cloth2=(18, 18, 22), metal=(70, 68, 76), leather=(40, 32, 30), trim=(226, 178, 64), steel=(200, 198, 206)),       # black & gold
]
N = len(COLORWAYS)
FLAT = ['cloth', 'cloth2', 'metal', 'leather', 'trim', 'steel']
table = {name: {str(c): {'color': lin(COLORWAYS[c][name])} for c in range(N)} for name in FLAT}
table['shadow'] = {str(c): {'color': lin((10, 10, 14))} for c in range(N)}
table['bone'] = {str(c): {'color': lin((232, 230, 214))} for c in range(N)}
props = {}

# ------------------------------------------------------------------ textures drawn here
def eyes_frame(open_amt):
    im = Image.new('RGBA', (32, 32), (10, 10, 14, 255))
    d = ImageDraw.Draw(im)
    for cx in (9, 22):
        if open_amt >= 1:
            d.polygon([(cx - 4, 15), (cx, 12), (cx + 4, 15), (cx, 17)], fill=(150, 190, 235, 255))
            d.rectangle([cx - 1, 14, cx + 1, 15], fill=(236, 244, 255, 255))
        elif open_amt > 0:
            d.rectangle([cx - 4, 14, cx + 4, 15], fill=(150, 190, 235, 255))
            d.rectangle([cx - 1, 14, cx + 1, 15], fill=(236, 244, 255, 255))
        else:
            d.line([(cx - 4, 15), (cx + 4, 15)], fill=(52, 66, 96, 255))
    return im


frames = []
for i, amt in enumerate((1, 0.5, 0, 1, 1, 1)):
    p = os.path.join(TEX, f'eyes_{i}.png')
    eyes_frame(amt).save(p)
    frames.append(p)
table['eyes'] = {str(c): {'image': frames[0]} for c in range(N)}
props['eyes'] = {'n64_state': 'D9FDF9FF 00020400; E3001001 00008000; FA000000 FFFFFFFF; FC127E05 FF17F3FF'}  # texel x shade


def crescent(d, box, start, thick, col):
    """A crescent stroke: an arc that is thickest in the middle."""
    x0, y0, x1, y1 = box
    for t in range(thick, 0, -1):
        k = (thick - t) * 14
        d.arc([x0 + (thick - t), y0 + (thick - t) * 0.4, x1 - (thick - t), y1 - (thick - t) * 0.4],
              start + k, start + 150 - k, fill=col, width=1)


def fx_flurry(step):
    """Frame `step` (0-4) of the flurry effect: crossing crescent strokes building up."""
    im = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    strokes = [((2, 3, 24, 30), 200), ((8, 2, 30, 29), 310), ((3, 8, 29, 30), 20), ((2, 2, 26, 22), 150), ((6, 6, 30, 30), 255)]
    for i in range(step + 1):
        box, st = strokes[i]
        col = (236, 244, 255, 255) if i == step else (150, 190, 235, 255)
        crescent(d, box, st, 3, (70, 96, 150, 255))
        crescent(d, box, st, 2, col)
    return im


def fx_small():
    im = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    crescent(d, (6, 4, 28, 26), 120, 4, (70, 96, 150, 255))
    crescent(d, (6, 4, 28, 26), 120, 3, (236, 244, 255, 255))
    return im


def fx_streak():
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    px = im.load()
    for y in range(16):
        k = 1 - abs(y - 7.5) / 8
        for x in range(16):
            if k > 0.25:
                px[x, y] = (236, 244, 255, 255) if k > 0.7 else (150, 190, 235, 255)
    return im


def fx_head():
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    crescent(d, (-6, 1, 14, 15), 290, 4, (150, 190, 235, 255))
    crescent(d, (-6, 1, 14, 15), 290, 2, (236, 244, 255, 255))
    return im


FX = {'mat_018': fx_flurry(0), 'mat_019': fx_flurry(1), 'mat_020': fx_flurry(2), 'mat_021': fx_flurry(3),
      'mat_022': fx_flurry(4), 'mat_023': fx_small(), 'mat_024': fx_streak(), 'mat_025': fx_head()}
for name, im in FX.items():
    p = os.path.join(TEX, f'{name}.png')
    im.save(p)
    table[name] = {str(c): {'image': p} for c in range(N)}

# ------------------------------------------------------------------ glTF writer
def write_gltf(path, meshes):
    bin_ = bytearray()
    gl = dict(asset={'version': '2.0', 'generator': 'knight gen.py'}, scene=0, scenes=[{'nodes': []}], nodes=[],
              meshes=[], materials=[], accessors=[], bufferViews=[], skins=[], buffers=[])
    for j in range(NJ):
        gl['nodes'].append({'name': f'joint_{j:02d}'})
    mat_ix = {}

    def view(arr, target=None):
        while len(bin_) % 4:
            bin_.append(0)
        off = len(bin_)
        bin_.extend(arr.tobytes())
        bv = {'buffer': 0, 'byteOffset': off, 'byteLength': arr.nbytes}
        if target:
            bv['target'] = target
        gl['bufferViews'].append(bv)
        return len(gl['bufferViews']) - 1

    def accessor(arr, ctype, typ, minmax=False):
        a = {'bufferView': view(arr), 'componentType': ctype, 'count': len(arr), 'type': typ}
        if minmax:
            a['min'], a['max'] = arr.min(0).tolist(), arr.max(0).tolist()
        gl['accessors'].append(a)
        return len(gl['accessors']) - 1

    ibm = np.tile(np.eye(4, dtype='<f4').reshape(1, 16), (NJ, 1))
    gl['skins'].append({'joints': list(range(NJ)), 'inverseBindMatrices': accessor(ibm, 5126, 'MAT4')})
    for m in meshes:
        by_mat = {}
        for mat, pts, n, uv, col in m.tris:
            by_mat.setdefault(mat, []).append((pts, n, uv, col))
        prims = []
        for mat, tris in by_mat.items():
            P = np.array([p for t in tris for p in t[0]], '<f4')
            Nn = np.array([t[1] for t in tris for _ in range(3)], '<f4')
            UV = np.array([u for t in tris for u in t[2]], '<f4')
            C = np.array([(t[3] or (1, 1, 1, 1)) for t in tris for _ in range(3)], '<f4')
            RG = np.stack([C[:, 0], 1 - C[:, 1]], 1).astype('<f4')
            BA = np.stack([C[:, 2], 1 - C[:, 3]], 1).astype('<f4')
            J = np.zeros((len(P), 4), '<u2')
            J[:, 0] = m.joint
            Wt = np.zeros((len(P), 4), '<f4')
            Wt[:, 0] = 1
            if mat not in mat_ix:
                mat_ix[mat] = len(gl['materials'])
                gl['materials'].append({'name': mat})
            prims.append({'attributes': {'POSITION': accessor(P, 5126, 'VEC3', True), 'NORMAL': accessor(Nn, 5126, 'VEC3'),
                                         'TEXCOORD_0': accessor(UV, 5126, 'VEC2'), 'TEXCOORD_1': accessor(RG, 5126, 'VEC2'),
                                         'TEXCOORD_2': accessor(BA, 5126, 'VEC2'), 'JOINTS_0': accessor(J, 5123, 'VEC4'),
                                         'WEIGHTS_0': accessor(Wt, 5126, 'VEC4')},
                          'material': mat_ix[mat]})
        gl['meshes'].append({'primitives': prims})
        gl['nodes'].append({'name': m.name, 'mesh': len(gl['meshes']) - 1, 'skin': 0})
        gl['scenes'][0]['nodes'].append(len(gl['nodes']) - 1)
    name = os.path.basename(path).replace('.gltf', '.bin')
    gl['buffers'].append({'uri': name, 'byteLength': len(bin_)})
    open(os.path.join(os.path.dirname(path), name), 'wb').write(bin_)
    json.dump(gl, open(path, 'w'))


# ------------------------------------------------------------------ effect quads: shapes from the base, new pictures
sys.path.insert(0, os.environ['SSB64_MODEL'])
import import_fighter as IF  # noqa: E402

base_objs = {o['name']: o for o in IF.load_gltf(os.path.join(EXPORT, 'model.gltf'))}


def copy_quads(name, joint):
    o = base_objs[name]
    m = Mesh(name, joint)
    for mat, t in o['tris']:
        a, b, c = (o['pos'][v] for v in t)
        col = tuple(float(x) for x in o['col'][t[0]])
        m.tris.append((IF.base_mat(mat), (a, b, c), o['nrm'][t[0]], tuple(tuple(o['uv'][v]) for v in t), col))
    return m


def tiny(name, joint):
    m = Mesh(name, joint)
    p = JP[2] + (0, 40, -4)                       # a speck inside the chest: the slot stays valid but unseen
    m.tri('shadow', p, p + (0.5, 0, 0), p + (0, 0.5, 0))
    return m


# ------------------------------------------------------------------ assemble the work folder
body = {d: build(d) for d in ('hi', 'lo')}
for d in ('hi', 'lo'):
    write_gltf(os.path.join(WORK, 'body.gltf' if d == 'hi' else 'lo.gltf'), list(body[d].values()))

parts = []
man = json.load(open(os.path.join(EXPORT, 'manifest.json')))
slot_names = {p['object'] for p in man['model_parts']}
for d in ('hi', 'lo'):
    for v in range(5):
        parts.append(copy_quads(f'part{v}_{d}_j00', 0))
    for j in (12, 13, 14):
        parts.append(copy_quads(f'part0_{d}_j{j}', j))
    sw = sword_local(d)
    for j in (15, 17):                             # in hand, and carried on the back
        m = Mesh(f'part0_{d}_j{j}', j)
        m.add(sw, lambda p, j=j: to_world(j, p)[0])
        parts.append(m)
    for j in (18, 19):
        m = Mesh(f'part0_{d}_j{j}', j)
        m.add(body[d][j])
        parts.append(m)
    parts.append(tiny(f'part0_{d}_j16', 16))
    parts.append(tiny(f'part1_{d}_j20', 20))
assert all(p.name in slot_names for p in parts), [p.name for p in parts if p.name not in slot_names]
write_gltf(os.path.join(WORK, 'parts.gltf'), parts)

skel = []
for e in man['skeletons']:
    j = e['joint']
    m = Mesh(e['object'], j)
    kids = [k for k in W if k != j and np.linalg.norm(JP[k] - JP[j]) > 20 and
            g0['nodes'][sk['joints'][0]] is not None]
    src = body['lo'].get(j) or next((p for p in parts if p.name == f'part0_lo_j{j:02d}'), None)
    if src is None:
        continue
    P = np.array([p for t in src.tris for p in t[1]])
    lo_, hi_ = P.min(0), P.max(0)
    ax = int(np.argmax(hi_ - lo_))
    c = (lo_ + hi_) / 2
    p0, p1 = c.copy(), c.copy()
    p0[ax], p1[ax] = lo_[ax] + 4, hi_[ax] - 4
    m.prism('bone', p0, p1, 5, 5, 4)
    skel.append(m)
write_gltf(os.path.join(WORK, 'skeleton.gltf'), skel)

# manifest: the base's slots and effect-material render states, none of its pictures
keep = {}
for name in FX:
    e = dict(man['materials'][name])
    e['siz'] = -1                                  # forces a rebuild from the images given here
    e['image_addrs'], e['palette_addrs'] = [], []
    keep[name] = e
man['materials'] = keep
man['costumes'] = N
order = {}
for j, mesh in body['hi'].items():
    names = list(dict.fromkeys(t[0] for t in mesh.tris))
    order[str(j)] = (['eyes', 'cloth'] + [n for n in names if n not in ('eyes', 'cloth')]) if j == 19 else names
man['mobj_order'] = {'hi': order, 'lo': order}
for p in man['model_parts']:
    p['mobj_order'] = order.get(str(p['joint']), []) if p['joint'] in (15, 17, 18, 19) else []
    if p['joint'] in (15, 17):
        p['mobj_order'] = ['trim', 'leather', 'steel']
for e in man['skeletons']:
    e['mobj_slots'] = {}
man['lights'] = {'light': 'FFFFFF', 'shadow': '565662'}
os.makedirs(os.path.join(WORK, 'export'), exist_ok=True)
json.dump(man, open(os.path.join(WORK, 'export', 'manifest.json'), 'w'), indent=1)
json.dump({'materials': table, 'props': props, 'export_dir': os.path.join(WORK, 'export'), 'lights': man['lights']},
          open(os.path.join(WORK, 'costumes.json'), 'w'), indent=1)
for d in ('hi', 'lo'):
    print(d, 'triangles:', sum(len(m.tris) for m in body[d].values()), {j: len(m.tris) for j, m in sorted(body[d].items())})
print('parts:', len(parts), 'triangles', sum(len(m.tris) for m in parts), '| skeleton pieces:', len(skel))
