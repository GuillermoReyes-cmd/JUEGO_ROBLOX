"""Pruebas de contratos v4 con Luau real y adaptadores de Roblox.
Ejecutar: python docs/03-flujo/probar-v4.py
No reemplazan pruebas visuales, replicación ni DataStore de Studio.
"""
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PRELUDE = r"""
local Deps = {}
local now = 100
local os = { clock = function() return now end, time = function() return now end }
local function advance() now += 10 end
local function event()
	return { Connect = function(self, fn) self.Callback = fn; return { Disconnect = function() end } end }
end
local objects = {}
local vector = {}
vector.__sub = function(a,b) return setmetatable({X=a.X-b.X,Y=a.Y-b.Y,Z=a.Z-b.Z}, vector) end
local Vector3 = {new=function(x,y,z) return setmetatable({X=x,Y=y,Z=z},vector) end}
Vector3.xAxis = Vector3.new(1,0,0)
local Vector2 = {new=function(...) return {...} end}
local Color3 = {fromRGB=function(...) return {...} end,new=function(...) return {...} end}
local UDim2 = {new=function(...) return {...} end,fromScale=function(...) return {...} end}
local CFrame = {lookAt=function(...) return {...} end}
local Enum = setmetatable({}, {__index=function() return setmetatable({}, {__index=function(_,k)return k end}) end})
local Instance = {new=function(class,parent)
	local obj={ClassName=class,Parent=parent,Children={}}
	function obj:IsA(name) return name==class or (name=='BasePart' and class=='Part') end
	function obj:GetFullName() return self.Name or class end
	function obj:FindFirstChild() return nil end
	function obj:GetAttribute() return nil end
	table.insert(objects,obj)
	return obj
end}
local workspace = {}
local task = {spawn=function() end,wait=function() end}
local player = {UserId=101,DisplayName='Prueba',Name='Prueba',Parent=true,Attributes={},CharacterAdded=event()}
local humanoid={WalkSpeed=16}
player.Character={FindFirstChildOfClass=function()return humanoid end}
function player:SetAttribute(k,v) self.Attributes[k]=v end
function player:GetAttribute(k) return self.Attributes[k] end
local Players={PlayerRemoving=event(),GetPlayers=function()return {player}end,GetNameFromUserIdAsync=function()error('sin nombre')end}
local storeCalls=0
local storesFail=false
local stores={}
local DSS={GetOrderedDataStore=function(_,name)
	storeCalls+=1
	if storesFail then error('sin acceso') end
	local store={}
	function store:SetAsync(k,v) stores[name..k]=v end
	function store:UpdateAsync(k,fn) stores[name..k]=fn(stores[name..k]) end
	function store:GetSortedAsync() return {GetCurrentPage=function()return {{key='101',value=42}}end} end
	return store
end}
local game={GameId=0,GetService=function(_,name)
	return ({Players=Players,ReplicatedStorage={Shared={}},DataStoreService=DSS,CollectionService={GetTagged=function()return {}end}})[name]
end}
local remotes={}
Deps.Remotes={Get=function(name)
	if not remotes[name] then remotes[name]={OnServerEvent=event(),FireClient=function()end,FireAllClients=function()end} end
	return remotes[name]
end}
local data={Gold=1000000,PlateGold=99,Rebirths=0,IncubatorCount=2,PenCount=3,Dragons={},Pens={},Incubators={},EggsHatched=2}
Deps.DataService={Get=function(p) if p==player then return data end end,RegisterDefaults=function(fields)
	for k,v in fields do assert(data[k]==nil,'duplicado '..k);data[k]=v end
end}
Deps.StatsService={Refresh=function(p)p:SetAttribute('Gold',data.Gold);p:SetAttribute('Rebirths',data.Rebirths)end}
Deps.BaseService={}
local rendered,refreshed=0,0
Deps.IncubatorService={Render=function()rendered+=1 end}
Deps.StableService={Refresh=function()refreshed+=1 end}
Deps.Format={Number=tostring}
Deps.Config={}
"""

def module(name, path):
    source = (ROOT / path).read_text(encoding='utf-8')
    source = re.sub(r'require\(([\w.]+)\)', lambda m: 'Deps["'+m.group(1).split('.')[-1]+'"]', source)
    return '\nDeps["'+name+'"] = (function()\n'+source+'\nend)()\n'

code=PRELUDE
for name in ['Base','Eggs','Species','Upgrades','Rebirth','Dex','News','Leaderboards']:
    code+=module(name, 'src/shared/Config/'+name+'.luau')
    code+='Deps.Config.'+name+' = Deps.'+name+'\n'
code+=module('EggOdds','src/shared/EggOdds.luau')
code+=module('IncomeService','src/server/Services/IncomeService.luau')
for name in ['UpgradeService','RebirthService','DexService','LeaderboardService','NewsService']:
    code+=module(name,'src/server/Services/'+name+'.luau')
code+=r"""
local U,R,D,L,N=Deps.UpgradeService,Deps.RebirthService,Deps.DexService,Deps.LeaderboardService,Deps.NewsService
U.Init();R.Init();D.Init();N.Init();U.OnPlayerLoaded(player)
assert(U.TryBuy(player,'Boots'));assert(data.Gold==999250 and humanoid.WalkSpeed==18)
assert(not U.TryBuy(player,'Boots'),'antispam')
advance();assert(not U.TryBuy(player,{}));advance();assert(not U.TryBuy(player,'falso'))
advance();local before=data.Gold;remotes.Upgrade.OnServerEvent.Callback(player,'Boots',0);assert(data.Gold==before)
for _,item in Deps.Upgrades.Items do
	data.Gold=1e12
	while (data.Upgrades[item.Id] or 0)<item.MaxLevel do advance();assert(U.TryBuy(player,item.Id)) end
	advance();before=data.Gold;assert(not U.TryBuy(player,item.Id));assert(data.Gold==before)
end
assert(data.IncubatorCount==8 and data.PenCount==12 and rendered==6 and refreshed==9)
assert(player.Attributes.Stealth==5 and player.Attributes.Saddle==5 and player.Attributes.Radar==3)
data.Upgrades.Boots=0;data.Gold=0;advance();assert(not U.TryBuy(player,'Boots'));assert(data.Upgrades.Boots==0)
print('T35: compras, limites, saldo, atributos y antispam OK')
data.Gold=1000000;data.PlateGold=200
local dragons={{Id='a',SpeciesId='Draco',Mutation='Normal',Giant=false},{Id='b',SpeciesId='Cuelebre',Mutation='Gold',Giant=true}}
local eggs={['8']={EggId='Prado',StartedAt=0,HatchSeconds=30}}
data.Dragons=dragons;data.Incubators=eggs;data.Pens={'a','b','c','d'}
advance();assert(R.TryRebirth(player,0));assert(data.Rebirths==1 and data.Gold==0 and data.PlateGold==0)
assert(data.Dragons==dragons and data.Incubators==eggs and #data.Pens==3)
assert(data.IncubatorCount==2 and data.PenCount==3 and humanoid.WalkSpeed==16)
assert(Deps.IncomeService.GetMultiplier(player)==1.5)
advance();assert(not R.TryRebirth(player,0));advance();assert(not R.TryRebirth(player,1))
print('T37: reinicio, conservacion, multiplicador y confirmacion antigua OK')
D.Scan(player,true);assert(data.Dex['Draco|Normal|false'] and data.Dex['Cuelebre|Gold|true'])
advance();assert(D.Claim(player,'Draco'));before=data.Gold;advance();assert(not D.Claim(player,'Draco'));assert(data.Gold==before)
advance();assert(not D.Claim(player,'Nidhogg'))
table.insert(data.Dragons,{SpeciesId='Guivernillo',Mutation='Normal',Giant=false})
D.Scan(player,true);assert(player.Attributes.SaddlePrado==true)
assert(math.abs(Deps.IncomeService.GetMultiplier(player)-1.575)<0.00001)
advance();assert(D.Claim(player,'All'));assert(data.DexBiomes.Prado and data.DexClaimed.Guivernillo)
before=data.Gold;advance();assert(not D.Claim(player,'All'));assert(data.Gold==before)
data.Dragons={};D.Scan(player,true);assert(data.Dex['Draco|Normal|false'])
print('T38: variantes, premios unicos, bioma y conservacion tras venta OK')
N.OnPlayerLoaded(player);assert(player.Attributes.NewsSeen==0)
assert(not N.MarkSeen(player,999));advance();assert(N.MarkSeen(player,Deps.News.Version));assert(data.NewsSeen==1)
advance();assert(not N.MarkSeen(player,0));assert(data.NewsSeen==1)
print('T16: version persistente y rechazo de versiones falsas OK')
L.Init();L.Refresh();assert(storeCalls==0,'sin publicar no debe acceder a DataStore')
local noData=0;for _,obj in objects do if obj.Text=='Sin datos' then noData+=1 end end;assert(noData==2)
game.GameId=1;storesFail=true;L.Refresh();assert(storeCalls==2)
storesFail=false;L.Refresh();assert(stores['V4_TopEggsHatched_v1101']==2)
print('T13: Sin datos, fallos protegidos y escritura ordenada OK')
print('TODAS LAS PRUEBAS V4 CORRECTAS')
"""
with tempfile.TemporaryDirectory(prefix='roblox-v4-', dir=ROOT/'docs'/'03-flujo') as folder:
    assert Path(folder).resolve().is_relative_to((ROOT/'docs'/'03-flujo').resolve())
    test=Path(folder)/'contracts.luau'
    test.write_text(code,encoding='utf-8')
    result=subprocess.run(['luau',str(test)],cwd=ROOT,text=True,capture_output=True)
    print(result.stdout,end='')
    print(result.stderr,end='')
    raise SystemExit(result.returncode)
