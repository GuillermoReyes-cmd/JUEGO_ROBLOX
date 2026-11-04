# Dragón de bloques con tachuelas (estilo «Montar un dinosaurio»), versión v5:
# cuello largo y erguido, cabeza fina con cuernos largos, alas enormes, piezas que se estrechan
# (menos cubos gordos), tachuelas también en los costados y manchas de otro tono.
# Cada parte animable es un objeto separado con el nombre del contrato de T18
# (Body, Head, WingL/WingR, Tail1..n, LegFL/FR/BL/BR); los adornos van unidos a su parte.
#
# Uso (sin abrir Blender):
#   blender -b -P tools/blender/draco_bloques.py -- <carpeta_salida>
# Produce Draco.fbx y vistas previas (Draco.png de 3/4, Draco_lado.png).

import math
import os
import sys

import bmesh
import bpy
from mathutils import Vector

out = sys.argv[sys.argv.index("--") + 1] if "--" in sys.argv else os.getcwd()
os.makedirs(out, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)

R = math.radians
STUD_SPACING = 1.0
STUD_RADIUS = 0.3
STUD_HEIGHT = 0.18


def srgb(r, g, b):
	"""Color en 0-255 (sRGB) → lineal, que es lo que usa Blender."""
	def channel(c):
		c /= 255
		return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
	return (channel(r), channel(g), channel(b))


# Paleta «rojo fuego». Para otra especie basta con cambiar estos colores.
COLORS = {
	"Body": srgb(215, 45, 35),
	"Patch": srgb(150, 25, 30),  # manchas
	"Belly": srgb(255, 205, 90),
	"Bone": srgb(250, 238, 205),  # cuernos, garras, dientes
	"Fin": srgb(40, 25, 30),  # aletas del lomo
	"WingBone": srgb(130, 20, 25),
	"Membrane": srgb(255, 145, 35),
	"Eye": srgb(255, 230, 50),
	"Black": srgb(15, 12, 12),
	"Mouth": srgb(110, 15, 20),
	"Grass": srgb(90, 200, 80),
}
GLOW = {"Eye": 2.0, "Membrane": 0.35}  # ojos: material Neon en Roblox; membrana: se ve naranja también a la sombra
materials = {}


def material(name):
	if name not in materials:
		mat = bpy.data.materials.new(name)
		mat.diffuse_color = (*COLORS[name], 1)
		mat.use_nodes = True
		bsdf = mat.node_tree.nodes["Principled BSDF"]
		bsdf.inputs["Base Color"].default_value = (*COLORS[name], 1)
		bsdf.inputs["Roughness"].default_value = 0.45
		if name in GLOW:
			bsdf.inputs["Emission Color"].default_value = (*COLORS[name], 1)
			bsdf.inputs["Emission Strength"].default_value = GLOW[name]
		materials[name] = mat
	return materials[name]


def join(main, items):
	bpy.ops.object.select_all(action="DESELECT")
	for item in items:
		item.select_set(True)
	main.select_set(True)
	bpy.context.view_layer.objects.active = main
	bpy.ops.object.join()
	return main


def studs_on(obj, width, depth, offset, axis, color):
	"""Rejilla de tachuelas sobre una cara. axis: 'top' (+Z) o 'left'/'right' (±X); offset = distancia al centro."""
	nx, ny = int(width // STUD_SPACING), int(depth // STUD_SPACING)
	items = []
	for ix in range(nx):
		for iy in range(ny):
			a = (ix - (nx - 1) / 2) * STUD_SPACING
			b = (iy - (ny - 1) / 2) * STUD_SPACING
			bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=STUD_RADIUS, depth=STUD_HEIGHT)
			stud = bpy.context.active_object
			d = offset + STUD_HEIGHT / 2
			if axis == "top":
				stud.location = (a, b, d)
			else:
				sign = -1 if axis == "left" else 1
				stud.rotation_euler = (0, R(90), 0)
				stud.location = (sign * d, b, a)
			stud.data.materials.append(material(color))
			bpy.context.view_layer.update()
			stud.matrix_world = obj.matrix_world @ stud.matrix_world
			items.append(stud)
	if items:
		join(obj, items)


def box(name, size, location, color, rotation=(0, 0, 0), top=(1, 1), front=(1, 1), studs=(), bevel=0.05):
	"""Bloque que puede estrecharse: `top` escala la cara de arriba (x, y) y `front` la de delante (-Y) (x, z).
	studs: caras con tachuelas ('top', 'left', 'right')."""
	sx, sy, sz = size
	bpy.ops.mesh.primitive_cube_add(size=1)
	obj = bpy.context.active_object
	obj.name = name
	mesh = obj.data
	bm = bmesh.new()
	bm.from_mesh(mesh)
	for v in bm.verts:
		x, y, z = v.co.x * sx, v.co.y * sy, v.co.z * sz
		if v.co.z > 0:
			x, y = x * top[0], y * top[1]
		if v.co.y < 0:
			x, z = x * front[0], z * front[1]
		v.co = (x, y, z)
	bm.to_mesh(mesh)
	bm.free()
	obj.data.materials.append(material(color))
	if bevel > 0:
		bpy.ops.object.modifier_add(type="BEVEL")
		obj.modifiers["Bevel"].width = bevel
		obj.modifiers["Bevel"].segments = 1
		bpy.ops.object.modifier_apply(modifier="Bevel")
	obj.rotation_euler = rotation
	obj.location = location
	bpy.context.view_layer.update()
	for face in studs:
		if face == "top":
			studs_on(obj, sx * top[0], sy * top[1], sz / 2, "top", color)
		else:
			studs_on(obj, sz * 0.9, sy * 0.85, sx / 2 * (1 + top[0]) / 2, face, color)
	return obj


def spike(name, base, height, location, color, rotation=(0, 0, 0)):
	"""Pirámide de 4 caras (cuerno, diente, garra). La punta mira a +Z local."""
	bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=base, radius2=0, depth=height)
	obj = bpy.context.active_object
	obj.name = name
	obj.rotation_euler = (0, 0, R(45))
	bpy.ops.object.transform_apply(rotation=True)
	obj.data.materials.append(material(color))
	obj.rotation_euler = rotation
	obj.location = location
	return obj


def fin(name, length, height, location, color, rotation=(0, 0, 0)):
	"""Aleta triangular fina (cuña): la base mide `length` a lo largo de Y y sube `height`."""
	return box(name, (0.35, length, height), location, color, rotation, top=(0.5, 0.05), bevel=0.03)


def part(name, main, *extras):
	result = join(main, list(extras)) if extras else main
	result.name = name
	return result


def pivot(obj, point):
	bpy.context.scene.cursor.location = point
	bpy.ops.object.select_all(action="DESELECT")
	obj.select_set(True)
	bpy.context.view_layer.objects.active = obj
	bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
	bpy.context.scene.cursor.location = (0, 0, 0)


# =====================================================================================
# El dragón mira hacia -Y. Medidas en studs de Roblox.
# =====================================================================================

# CUERPO + CUELLO LARGO en curva (el cuello va con el cuerpo)
# Pecho ancho y alto con hombros marcados → cintura más estrecha → ancas grandes
body_pieces = [
	box("Chest", (4.2, 3.0, 3.6), (0, -2.0, 4.8), "Body", top=(0.8, 0.85), studs=("top", "left", "right")),
	box("Pecs", (3.4, 0.6, 2.2), (0, -3.5, 4.3), "Belly", top=(0.85, 1), bevel=0.04),
	box("Hips", (3.8, 2.8, 3.0), (0, 3.0, 4.8), "Body", top=(0.8, 0.85), studs=("top", "left", "right")),
]
for side in (-1, 1):
	body_pieces += [
		box(f"Shoulder{side}", (1.3, 2.0, 1.8), (side * 2.15, -2.0, 5.1), "Body", top=(0.8, 0.8),
			studs=("left",) if side < 0 else ("right",)),
		box(f"Haunch{side}", (1.0, 2.4, 2.2), (side * 2.0, 3.0, 5.0), "Patch", top=(0.8, 0.8), bevel=0.04),
	]
# Placas de la barriga separadas (no una sola tabla)
for i, (y, w) in enumerate(((-2.6, 3.2), (-1.5, 3.0), (-0.4, 2.6), (0.7, 2.4), (1.8, 2.6), (2.9, 2.8))):
	body_pieces.append(box(f"BellyPlate{i}", (w, 0.95, 0.45), (0, y, 3.05 if abs(y) < 1.6 else 2.95), "Belly", bevel=0.03))
neck = [((0, -3.8, 6.2), (2.2, 2.0, 2.3), 35), ((0, -4.6, 7.8), (1.9, 1.8, 2.1), 15), ((0, -5.0, 9.4), (1.7, 1.6, 1.9), -5)]
for i, (loc, size, tilt) in enumerate(neck):
	body_pieces.append(box(f"Neck{i}", size, loc, "Body", rotation=(R(tilt), 0, 0), top=(0.85, 0.85), studs=("top",)))
	body_pieces.append(box(f"NeckBelly{i}", (size[0] * 0.6, 0.35, size[2] * 0.9), (loc[0], loc[1] - size[1] / 2, loc[2]),
		"Belly", rotation=(R(tilt), 0, 0), bevel=0.02))
# Manchas con tachuelas en los costados
for side in (-1, 1):
	body_pieces.append(box(f"Patch{side}", (0.25, 1.8, 1.2), (side * 1.42, 0.6, 4.8), "Patch", bevel=0.02))
# Aletas del lomo: del cuello a la cadera, más grandes en el centro
for i, (y, z, length, height) in enumerate(((-4.9, 10.6, 0.8, 0.8), (-4.5, 8.9, 0.9, 0.9), (-3.6, 7.3, 1.0, 1.0),
		(-2.2, 6.9, 1.3, 1.4), (-0.6, 6.3, 1.5, 1.7), (1.0, 6.3, 1.5, 1.6), (2.6, 6.6, 1.3, 1.4), (4.0, 6.5, 1.0, 1.1))):
	body_pieces.append(fin(f"Fin{i}", length, height, (0, y, z), "Fin"))
# Cintura: la pieza principal (Body) une pecho y ancas
part("Body", box("Body", (2.9, 3.4, 2.7), (0, 0.6, 4.75), "Body", top=(0.85, 0.95), studs=("top",)), *body_pieces)

# CABEZA fina y alargada: cráneo, hocico que se estrecha, mandíbula, cuernos largos hacia atrás
hy, hz = -6.0, 10.6
head_pieces = [
	box("Snout", (1.9, 3.0, 1.3), (0, hy - 2.5, hz - 0.3), "Body", top=(0.8, 0.85), front=(0.75, 0.8), studs=("top",)),
	box("Jaw", (1.7, 2.8, 0.6), (0, hy - 2.2, hz - 1.25), "Body", rotation=(R(-14), 0, 0), front=(0.7, 0.8)),
	box("JawBelly", (1.3, 2.4, 0.2), (0, hy - 2.1, hz - 1.6), "Belly", rotation=(R(-14), 0, 0), bevel=0),
	box("MouthInside", (1.5, 2.4, 0.5), (0, hy - 2.2, hz - 0.95), "Mouth", bevel=0),
	box("Brow", (2.4, 0.8, 0.5), (0, hy - 0.8, hz + 1.05), "Patch", top=(0.9, 0.6)),
	box("NoseRidge", (0.6, 2.4, 0.35), (0, hy - 2.3, hz + 0.45), "Patch", front=(0.6, 0.6)),
	spike("NoseHorn", 0.25, 0.8, (0, hy - 3.4, hz + 0.6), "Bone", rotation=(R(30), 0, 0)),
	fin("HeadFin", 1.4, 0.9, (0, hy + 0.3, hz + 1.2), "Fin"),
]
for side in (-1, 1):
	head_pieces += [
		box(f"Eye{side}", (0.2, 0.8, 0.55), (side * 1.13, hy - 0.9, hz + 0.45), "Eye", bevel=0),
		box(f"Pupil{side}", (0.12, 0.2, 0.5), (side * 1.2, hy - 0.95, hz + 0.45), "Black", bevel=0),
		box(f"Nostril{side}", (0.25, 0.3, 0.12), (side * 0.45, hy - 3.85, hz + 0.25), "Black", bevel=0),
		# Cuerno largo hacia atrás en 3 tramos que se estrechan
		box(f"HornA{side}", (0.55, 0.55, 1.4), (side * 0.75, hy + 0.7, hz + 1.35), "Bone",
			rotation=(R(-50), side * R(12), 0), top=(0.75, 0.75)),
		box(f"HornB{side}", (0.4, 0.4, 1.3), (side * 0.95, hy + 1.6, hz + 1.95), "Bone",
			rotation=(R(-70), side * R(15), 0), top=(0.7, 0.7)),
		spike(f"HornC{side}", 0.2, 1.0, (side * 1.1, hy + 2.6, hz + 2.25), "Bone", rotation=(R(-85), side * R(15), 0)),
		# Aletas de la mejilla (gola) y colmillos
		fin(f"Cheek{side}", 1.2, 0.9, (side * 1.15, hy + 0.5, hz - 0.3), "Fin", rotation=(0, side * R(70), 0)),
		spike(f"Fang{side}", 0.18, 0.75, (side * 0.6, hy - 3.2, hz - 1.15), "Bone", rotation=(R(180), 0, 0)),
	]
	for i in range(3):
		head_pieces.append(spike(f"Tooth{side}{i}", 0.13, 0.4, (side * 0.62, hy - 2.4 + i * 0.6, hz - 1.1), "Bone",
			rotation=(R(180), 0, 0)))
		head_pieces.append(spike(f"ToothLow{side}{i}", 0.12, 0.35, (side * 0.55, hy - 2.9 + i * 0.6, hz - 1.45), "Bone"))
head = part("Head", box("Skull", (2.3, 2.6, 2.0), (0, hy, hz), "Body", top=(0.85, 0.85), studs=("top",)), *head_pieces)
pivot(head, (0, hy + 1.0, hz - 0.6))
head.rotation_euler = (R(8), 0, 0)

# ALAS ENORMES: brazo + antebrazo, 4 dedos desde la muñeca hasta el borde, membrana naranja
SPAN = 10.0


WRIST = (SPAN - 0.4, 0.2)
FINGER_ENDS = ((SPAN * 0.78, 4.8), (SPAN * 0.58, 6.2), (SPAN * 0.36, 6.6), (SPAN * 0.14, 5.6))


def membrane_reach(y):
	"""La membrana llega, a la altura y, hasta el dedo más exterior que pasa por ahí."""
	wx, wy = WRIST
	reach = 0.0
	for fx, fy in FINGER_ENDS:
		if wy <= y <= fy:
			reach = max(reach, wx + (fx - wx) * (y - wy) / (fy - wy))
	return reach
for side, name in ((-1, "WingL"), (1, "WingR")):
	s = side
	arm = box(name, (SPAN, 0.7, 0.65), (s * SPAN / 2, 0, 0.15), "WingBone", top=(1, 0.8))
	pieces = [spike(name + "Claw", 0.3, 1.2, (s * (SPAN + 0.3), -0.2, 0.2), "Bone", rotation=(0, s * R(80), 0))]
	wx, wy = WRIST
	for i, (fx, fy) in enumerate(FINGER_ENDS):
		length = math.hypot(fx - wx, fy - wy)
		angle = math.atan2(fx - wx, fy - wy)
		pieces.append(box(f"{name}Finger{i}", (0.3, length, 0.3), (s * (wx + fx) / 2, (wy + fy) / 2, 0.22), "WingBone",
			rotation=(0, 0, -s * angle), bevel=0.03))
	for row in range(7):
		y = 0.7 + row * 0.9
		inner = 0.5 + row * 0.12
		width = membrane_reach(y) - inner
		if width > 0.8:
			pieces.append(box(f"{name}Membrane{row}", (width, 0.9, 0.2), (s * (inner + width / 2), y, 0), "Membrane",
				studs=("top",), bevel=0.03))
	wing = part(name, arm, *pieces)
	pivot(wing, (0, 0, 0))
	wing.rotation_euler = (R(-18), -s * R(40), s * R(8))
	wing.location = (s * 1.6, -1.2, 5.9)

# COLA larga (6 tramos que se estrechan) en S suave, con aletas y punta de lanza
x, y, z = 0.0, 4.8, 4.6
TAIL_PIVOTS = []
for i in range(6):
	TAIL_PIVOTS.append((x, y, z))  # cada tramo gira desde el final del anterior
	w = 2.6 - i * 0.36
	length = 2.1
	pitch = R((8, 0, -8, -10, -6, -2)[i])
	yaw = R(18) * math.sin(i * 1.1 + 0.6)
	x += math.sin(yaw) * length * 0.92
	y += math.cos(yaw) * length * 0.92
	z += math.sin(pitch) * length
	seg = box(f"Seg{i}", (w, length, w * 0.85), (x, y, z), "Body", rotation=(pitch, 0, -yaw), top=(0.8, 0.9),
		front=(1, 1), studs=("top",))
	extras = [
		fin(f"TailFin{i}", length * 0.6, 1.1 - i * 0.12, (x, y, z + w * 0.42 + 0.4), "Fin", rotation=(pitch, 0, -yaw)),
		box(f"TailBelly{i}", (w * 0.6, length * 0.85, 0.2), (x, y, z - w * 0.43), "Belly", rotation=(pitch, 0, -yaw), bevel=0),
	]
	if i == 5:
		tip = Vector((x, y, z)) + Vector((math.sin(yaw), math.cos(yaw), 0)) * 1.4
		extras += [
			box("SpadeL", (1.4, 1.6, 0.25), tuple(tip + Vector((-0.45, 0.3, 0))), "Fin", rotation=(0, 0, R(40) - yaw),
				top=(0.4, 1)),
			box("SpadeR", (1.4, 1.6, 0.25), tuple(tip + Vector((0.45, 0.3, 0))), "Fin", rotation=(0, 0, R(-40) - yaw),
				top=(0.4, 1)),
			spike("SpadeTip", 0.45, 1.4, tuple(tip + Vector((0, 1.0, 0))), "Fin", rotation=(R(-90), 0, -yaw)),
		]
	part(f"Tail{i + 1}", seg, *extras)

def claws(name, x, y, z, size, count=3, spread=0.5):
	"""Garras grandes hacia delante y un poco hacia abajo."""
	return [spike(f"{name}Claw{c}", size * 0.25, size, (x + (c - (count - 1) / 2) * spread, y, z), "Bone",
		rotation=(R(-110), 0, 0)) for c in range(count)]


# PATAS DELANTERAS: brazo hacia atrás, codo marcado, antebrazo hacia delante y mano con garras
for name, side in (("LegFL", -1), ("LegFR", 1)):
	x = side * 2.3
	arm = box(name, (1.3, 1.2, 2.3), (x, -1.6, 3.6), "Body", rotation=(R(22), 0, 0), top=(1.1, 1.1),
		studs=("left",) if side < 0 else ("right",))
	part(name, arm,
		box(name + "Elbow", (1.15, 1.1, 1.0), (x, -1.15, 2.5), "Patch", bevel=0.05),
		spike(name + "ElbowSpike", 0.25, 0.8, (x, -0.55, 2.6), "Fin", rotation=(R(-100), 0, 0)),
		box(name + "Forearm", (1.05, 1.0, 2.0), (x, -1.55, 1.55), "Body", rotation=(R(-22), 0, 0), top=(1.1, 1.1)),
		box(name + "Hand", (1.4, 1.7, 0.55), (x, -2.25, 0.3), "Patch", front=(0.9, 0.7), studs=("top",)),
		*claws(name, x, -3.25, 0.3, 1.0),
	)

# PATAS TRASERAS en zigzag: anca y muslo hacia delante, rodilla, pierna hacia atrás, tobillo y pie
for name, side in (("LegBL", -1), ("LegBR", 1)):
	x = side * 2.1
	thigh = box(name, (1.8, 2.4, 2.8), (x, 2.4, 3.6), "Body", rotation=(R(-25), 0, 0), top=(1.1, 1.05),
		studs=("left",) if side < 0 else ("right",))
	part(name, thigh,
		box(name + "Knee", (1.3, 1.2, 1.1), (x, 1.5, 2.35), "Patch", bevel=0.05),
		box(name + "Shin", (1.1, 1.0, 2.1), (x, 2.2, 1.55), "Body", rotation=(R(38), 0, 0), top=(1.15, 1.1)),
		box(name + "Ankle", (0.9, 0.9, 0.9), (x, 2.9, 0.75), "Patch", bevel=0.05),
		box(name + "Foot", (1.6, 2.3, 0.55), (x, 2.2, 0.28), "Patch", front=(0.9, 0.7), studs=("top",)),
		spike(name + "Dewclaw", 0.2, 0.8, (x, 3.4, 0.6), "Bone", rotation=(R(110), 0, 0)),
		*claws(name, x, 0.95, 0.3, 1.15, spread=0.55),
	)

# RIG: de qué parte cuelga cada pieza animable y desde qué punto gira (coordenadas de Blender).
# Lo lee el montaje en Studio para crear los Motor6D con los nombres del contrato de T18.
JOINTS = {
	"Body": ("Root", (0, 0.6, 4.75)),
	"Head": ("Body", (0, hy + 1.0, hz - 0.6)),
	"WingL": ("Body", (-1.6, -1.2, 5.9)),
	"WingR": ("Body", (1.6, -1.2, 5.9)),
	"LegFL": ("Body", (-2.3, -1.9, 4.7)),
	"LegFR": ("Body", (2.3, -1.9, 4.7)),
	"LegBL": ("Body", (-2.1, 2.7, 4.9)),
	"LegBR": ("Body", (2.1, 2.7, 4.9)),
}
for i, point in enumerate(TAIL_PIVOTS):
	JOINTS[f"Tail{i + 1}"] = ("Body" if i == 0 else f"Tail{i}", point)


def to_srgb(c):
	return round(255 * (c * 12.92 if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055))


# Cada parte se separa por color: «Head__Bone», «Head__Body»… En Studio cada trozo se colorea
# por su sufijo y se suelda a la pieza principal de su parte.
for joint in JOINTS:
	obj = bpy.data.objects[joint]
	bpy.ops.object.select_all(action="DESELECT")
	obj.select_set(True)
	bpy.context.view_layer.objects.active = obj
	bpy.ops.object.mode_set(mode="EDIT")
	bpy.ops.mesh.select_all(action="SELECT")
	bpy.ops.mesh.separate(type="MATERIAL")
	bpy.ops.object.mode_set(mode="OBJECT")
	for piece in bpy.context.selected_objects:
		piece.name = f"{joint}__{piece.active_material.name}"

import json
with open(os.path.join(out, "Draco_rig.json"), "w", encoding="utf-8") as f:
	json.dump({
		"joints": {name: {"parent": parent, "pivot": list(point)} for name, (parent, point) in JOINTS.items()},
		"colors": {name: [to_srgb(c) for c in value] for name, value in COLORS.items()},
		"neon": sorted(GLOW),
	}, f, indent=1)

# EXPORTAR a FBX (Roblox: Y arriba)
bpy.ops.export_scene.fbx(filepath=os.path.join(out, "Draco.fbx"), apply_scale_options="FBX_SCALE_ALL",
	axis_forward="-Z", axis_up="Y", use_mesh_modifiers=True)

# VISTAS PREVIAS
scene = bpy.context.scene
scene.render.engine = "BLENDER_EEVEE_NEXT"
scene.render.resolution_x, scene.render.resolution_y = 1200, 850
scene.view_settings.view_transform = "Standard"
world = bpy.data.worlds.new("World")
world.use_nodes = True
world.node_tree.nodes["Background"].inputs["Color"].default_value = (*srgb(120, 190, 255), 1)
scene.world = world
bpy.ops.object.light_add(type="SUN", rotation=(R(40), R(-10), R(-40)))
bpy.context.active_object.data.energy = 4
bpy.ops.mesh.primitive_plane_add(size=100)
bpy.context.active_object.data.materials.append(material("Grass"))
bpy.ops.object.camera_add()
camera = bpy.context.active_object
camera.data.lens = 35
scene.camera = camera


def shot(filename, location, target):
	camera.location = location
	camera.rotation_euler = (Vector(target) - Vector(location)).to_track_quat("-Z", "Y").to_euler()
	scene.render.filepath = os.path.join(out, filename)
	bpy.ops.render.render(write_still=True)


shot("Draco.png", (-20, -23, 15), (0, -1.0, 5.5))
shot("Draco_lado.png", (-32, -1, 9), (0, 0, 5.5))
print("LISTO", out)
