-- Robo entre jugadores. Diseño: docs/00-vision/Vision-v4.md §5.2–5.3 · Tarea: docs/02-tareas/T33-robo.md

local Raid = {}

-- Empujón (tecla F)
Raid.PushKey = Enum.KeyCode.F
Raid.PushRange = 8 -- distancia máxima al otro jugador
Raid.PushAngle = 70 -- grados a cada lado de hacia dónde miras
Raid.PushCooldown = 3
Raid.PushForce = 55
Raid.PushUp = 22

-- Huevo en el suelo
Raid.GroundEggSeconds = 30 -- si nadie lo recoge, vuelve a su nido
Raid.PickupHoldSeconds = 0.4

-- Robar de la incubadora de otro jugador
Raid.StealHoldSeconds = 2
Raid.StealDistance = 10
Raid.StealCooldown = 2

-- Puerta de la guarida
Raid.DoorSeconds = 60 -- cerrada, nadie puede robar en tu guarida
Raid.DoorCooldown = 30 -- espera antes de poder cerrarla otra vez
Raid.DoorColor = Color3.fromRGB(255, 70, 60)

return Raid
