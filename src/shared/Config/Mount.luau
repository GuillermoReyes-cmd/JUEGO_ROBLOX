-- Montar dragones. Diseño: docs/00-vision/Vision-v4.md §5.5 · Tarea: docs/02-tareas/T32-montar.md

local Mount = {}

-- Velocidad (studs/s) y tamaño (studs) de la montura según la rareza (índice de Config.Eggs.Rarities)
Mount.RaritySpeed = { 24, 27, 30, 34, 38, 43, 48 }
Mount.RaritySize = { 8, 8.5, 9, 10, 11, 12, 13 }
Mount.GiantSpeedBonus = 0.1 -- los gigantes corren un 10 % más
Mount.SaddlePerLevel = 0.04 -- cada nivel de Silla (Mejoras) suma un 4 %
Mount.BiomeSaddleBonus = 0.03 -- cada bioma completo del Dragonario (atributo Saddle<Bioma>) suma un 3 %
Mount.JumpPower = 60

Mount.RiderLift = 1.6 -- altura de la cadera del jinete sobre la silla
Mount.ToggleCooldown = 0.6
Mount.Key = Enum.KeyCode.R

-- Animación de estar sentado (R15) que usa el jinete
Mount.SitAnimation = "rbxassetid://2506281703"

-- Efectos en el cliente
Mount.DustFromSpeed = 10 -- más rápido que esto, salen nubes de polvo
Mount.FieldOfView = 70
Mount.FieldOfViewFast = 82 -- la cámara se abre al correr

Mount.SaddleColor = Color3.fromRGB(120, 70, 35)

return Mount
