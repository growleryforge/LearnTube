#!/usr/bin/env python3
# Generates a 1024x1024 app icon with no third-party deps.
import zlib, struct, math

S = 1024
buf = bytearray(S * S * 3)

def setpx(x, y, r, g, b):
    i = (y * S + x) * 3
    buf[i] = r; buf[i+1] = g; buf[i+2] = b

def lerp(a, b, t):
    return int(a + (b - a) * t)

# Background: diagonal red gradient (LearnTube brand red)
top = (255, 45, 45)      # bright red
bot = (190, 0, 0)        # deep red
for y in range(S):
    t = y / (S - 1)
    r = lerp(top[0], bot[0], t)
    g = lerp(top[1], bot[1], t)
    b = lerp(top[2], bot[2], t)
    for x in range(S):
        setpx(x, y, r, g, b)

cx, cy = S / 2, S / 2

# Soft white circle behind the play button
cr = 300
for y in range(S):
    for x in range(S):
        dx, dy = x - cx, y - cy
        d = math.sqrt(dx*dx + dy*dy)
        if d <= cr:
            # subtle radial shade
            shade = 1.0 - (d / cr) * 0.06
            setpx(x, y, int(255*shade), int(255*shade), int(255*shade))

# Play triangle (rounded-ish), pointing right, in brand green
def in_triangle(px, py):
    # triangle vertices
    ax, ay = cx - 90, cy - 150
    bx, by = cx - 90, cy + 150
    cxx, cyy = cx + 170, cy
    def sign(x1,y1,x2,y2,x3,y3):
        return (x1-x3)*(y2-y3)-(x2-x3)*(y1-y3)
    d1 = sign(px,py, ax,ay, bx,by)
    d2 = sign(px,py, bx,by, cxx,cyy)
    d3 = sign(px,py, cxx,cyy, ax,ay)
    neg = (d1<0) or (d2<0) or (d3<0)
    pos = (d1>0) or (d2>0) or (d3>0)
    return not (neg and pos)

tri = (210, 20, 20)
for y in range(int(cy-170), int(cy+170)):
    for x in range(int(cx-110), int(cx+190)):
        if in_triangle(x, y):
            setpx(x, y, *tri)

# A little yellow star, top-right of the circle, for "learning/reward"
star_cx, star_cy, R, r = cx + 250, cy - 250, 90, 38
def in_star(px, py):
    ang = math.atan2(py - star_cy, px - star_cx)
    dist = math.sqrt((px-star_cx)**2 + (py-star_cy)**2)
    # 5-point star radius by angle
    a = (ang + math.pi/2) % (2*math.pi)
    seg = (a % (2*math.pi/5)) / (2*math.pi/5)
    edge = R if seg < 0.5 else r
    # smooth between points
    tt = abs(seg - 0.5) * 2
    rad = lerp(r, R, tt)
    return dist <= rad

for y in range(int(star_cy-R), int(star_cy+R)):
    for x in range(int(star_cx-R), int(star_cx+R)):
        if 0 <= x < S and 0 <= y < S and in_star(x, y):
            setpx(x, y, 255, 209, 71)

# Encode PNG
def png(width, height, rgb):
    def chunk(typ, data):
        c = struct.pack(">I", len(data)) + typ + data
        c += struct.pack(">I", zlib.crc32(typ + data) & 0xffffffff)
        return c
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        raw.extend(rgb[y*width*3:(y+1)*width*3])
    sig = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    comp = zlib.compress(bytes(raw), 9)
    return sig + chunk(b"IHDR", ihdr) + chunk(b"IDAT", comp) + chunk(b"IEND", b"")

with open("/Users/ginaturley/Developer/LearnTube/LearnTube/Assets.xcassets/AppIcon.appiconset/AppIcon.png", "wb") as f:
    f.write(png(S, S, buf))
print("icon written")
