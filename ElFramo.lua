local _,eF=...
local afterDo=C_Timer.After

local function initUnitsFrame()
eF.units=CreateFrame("Frame","eFunits",UIParent)
eF.units:EnableMouse(true)
eF.units:SetPoint("CENTER",UIParent,"BOTTOMLEFT",0,0)
eF.units:SetHeight(50)
eF.units:SetWidth(50)
eF.units:Show()
eF.units:SetMovable(true)

--[[MakeMovable(eF.units)
eF.units.texture=eF.units:CreateTexture()
eF.units.texture:SetAllPoints()
eF.units.texture:SetDrawLayer("BACKGROUND",-6)
eF.units.texture:SetColorTexture(0,0,0,0.5)]]

eF.units.dragger=CreateFrame("Frame","eFunitsDragger",eF.units)
local d=eF.units.dragger
d:SetFrameLevel(eF.units:GetFrameLevel()+10)
d:SetPoint("TOPLEFT",eF.units,"TOPLEFT")
d:SetSize(50,50)
d:RegisterForDrag("LeftButton")
d:SetScript("OnMouseDown",function(self) self:GetParent():StartMoving(); self:GetParent():savePosition() end)
d:SetScript("OnMouseUp",function(self)  self:GetParent():StopMovingOrSizing(); self:GetParent():savePosition()  end)
d:Hide()

local randTexture
d.texture=d:CreateTexture(nil,"BACKGROUND")
d.texture:SetPoint("CENTER")
d.texture:SetTexture("Interface\\CHARACTERFRAME\\TemporaryPortrait-Vehicle-Organic")
d.texture:SetScale(0.7)


eF.units.checkLoad=eF.rep.unitsLoad

eF.units.createUnitFrame=eF.rep.createUnitFrame
eF.units.onUpdate=eF.rep.unitsFrameOnUpdate
eF.units.onEvent=eF.rep.unitsEventHandler
eF.units.onGroupUpdate=eF.rep.unitsOnGroupUpdate
eF.units.updateSize=eF.rep.updateUnitFrameSize
eF.units.updateTextFont=eF.rep.updateUnitFrameTextFont
eF.units.updateHealthVis=eF.rep.updateUnitFrameHealthVisuals
eF.units.updateTextColor=eF.rep.updateUnitFrameTextColor
eF.units.updateTextLim=eF.rep.updateUnitFrameTextLim
eF.units.updateTextPos=eF.rep.updateUnitFrameTextPos
eF.units.updateGrad=eF.rep.updateUnitFrameGrad
eF.units.updateAllParas=eF.rep.updateAllUnitParas
eF.units:SetScript("OnUpdate",eF.units.onUpdate)
eF.units:RegisterEvent("GROUP_ROSTER_UPDATE")
eF.units:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
eF.units:RegisterEvent("PLAYER_ENTERING_WORLD")
eF.units:RegisterEvent("PLAYER_REGEN_DISABLED")
eF.units:RegisterEvent("PLAYER_REGEN_ENABLED")
eF.units:RegisterEvent("UNIT_NAME_UPDATE")
eF.units:RegisterEvent("ENCOUNTER_START")
eF.units:RegisterEvent("ENCOUNTER_END")
eF.units:RegisterEvent("PLAYER_FLAGS_CHANGED")
eF.units:SetScript("OnEvent",eF.units.onEvent)



end
eF.rep.initUnitsFrame=initUnitsFrame

local function unitsEventHandler(self,event,...)
  local ic=InCombatLockdown()
  if event=="GROUP_ROSTER_UPDATE" then
    self:onGroupUpdate()
  elseif event=="PLAYER_ENTERING_WORLD" then  
    self:onGroupUpdate()
  elseif event=="UNIT_NAME_UPDATE" then
    self:onGroupUpdate()
  elseif event=="PLAYER_REGEN_DISABLED" then
    eF.interface:Hide()
  elseif event=="PLAYER_REGEN_ENABLED" then
    if eF.OOCActions.layoutUpdate then eF.layout:update(); eF.OOCActions.layoutUpdate=false end
    if eF.OOCActions.groupUpdate then self:onGroupUpdate(); eF.OOCActions.groupUpdate=false end
    if not UnitExists("boss1") then 
      eF.info.encounterID=nil
      self:checkLoad()  
    end
  elseif event=="ENCOUNTER_START" then
    eF.info.encounterID=...
    self:checkLoad()
  elseif event=="ENCOUNTER_END" then
    eF.info.encounterID=nil
    self:checkLoad()
  elseif event=="ACTIVE_TALENT_GROUP_CHANGED" then
    self:onGroupUpdate()
  elseif event=="PLAYER_FLAGS_CHANGED" then
    local unit=...
    if not self[unit] then return end
    self[unit]:eventHandler("UNIT_FLAGS")
  end

end
eF.rep.unitsEventHandler=unitsEventHandler

local function unitHPUpdate(self)
  local unit=self.id
  self.hp:SetValue( UnitHealth(unit)/UnitHealthMax(unit))
end
eF.rep.unitHPUpdate=unitHPUpdate

local function unitEnable(self)
  if self.enabled then return end
  if InCombatLockdown() then return end
  
  self.enabled=true
  RegisterUnitWatch(self)
  local unit=self.id
  self:Show()
end
eF.rep.unitEnable=unitEnable

local function unitDisable(self)
  if not self.enabled then return end
  if InCombatLockdown() then return end
  self.enabled=false
  UnregisterUnitWatch(self)
  local unit=self.id
  self:Hide()
end
eF.rep.unitDisable=unitDisable

local function unitUpdateText(self)
  local unit=self.id
  local name=UnitName(unit)
  if not name then return end
  local units
  if (not eF.units.raid) and eF.para.groupParas then units=eF.para.unitsGroup else units=eF.para.units end

  if units.textLim then name=strsub(name,1,units.textLim) end
  self.text:SetText(name)
  
  if units.textColorByClass then
    local _,CLASS=UnitClass(unit)
    local r,g,b=GetClassColor(CLASS) 
    local a=units.textA or 1
    self.text:SetTextColor(r,g,b,a) 
  end
  
end
eF.rep.unitUpdateText=unitUpdateText

local function updateUnitBorders(self)
  local para
  if ((self.id=="player") or (self.id=="party1") or (self.id=="party2") or (self.id=="party3") or (self.id=="party4")) and (eF.para.groupParas)
  then para=eF.para.unitsGroup else para=eF.para.units end
  local size=para.borderSize
  local r=para.borderR
  local g=para.borderG
  local b=para.borderB

  if not (size and self.borderRight) then return end 
  
  for k,v in next,{"RIGHT","TOP","LEFT","BOTTOM"} do 
    local loc,p1,p2,w,f11,f12,f21,f22=eF.borderInfo(v)
    self[loc]:ClearAllPoints()
    self[loc]:SetVertexColor(r,g,b)
    self[loc]:SetPoint(p1,self,p1,f11*(size),f12*(size))
    self[loc]:SetPoint(p2,self,p2,f21*(size),f22*(size))
    if w then self[loc]:SetWidth(size);
    else self[loc]:SetHeight(size); end    
  end
end
eF.rep.updateUnitBorders=updateUnitBorders

eF.counter=0
local function unitEventHandler(self,event)
  if event=="UNIT_HEALTH_FREQUENT" or event=="UNIT_MAXHEALTH" or event=="UNIT_CONNECTION" or event=="UNIT_FACTION" then
    self:hpUpdate()
  elseif event=="UNIT_AURA" then 
    --if true then return end --TBA: remove once bmark done
    --eF.counter=eF.counter+1 --TBA
    
    local c=self.onAuraList
    for j=1,#c do
      local v=c[j]
      --eF.counter=eF.counter+1 --TBA
      v[1](v[2])
    end
       
    --BUFFS
    for i=1,40 do
      local name,icon,count,debuffType,duration,expirationTime,unitCaster,canSteal,_,spellId,_,isBoss=UnitAura(self.id,i,"HELPFUL")
      if not name then break end   
      
      local c=self.onBuffList
      for j=1,#c do
        local v=c[j]
        --eF.counter=eF.counter+1 --TBA
        v[1](v[2],name,icon,count,debuffType,duration,expirationTime,unitCaster,canSteal,spellId,isBoss)
      end  
    
    end
    --DEBUFFS
    for i=1,40 do
      local name,icon,count,debuffType,duration,expirationTime,unitCaster,canSteal,_,spellId,_,isBoss=UnitAura(self.id,i,"HARMFUL")
      if not name then break end 
      
      local c=self.onDebuffList
      for j=1,#c do
        local v=c[j]
        --eF.counter=eF.counter+1 --TBA
        v[1](v[2],name,icon,count,debuffType,duration,expirationTime,unitCaster,canSteal,spellId,isBoss)
      end
      
    end 
    
    local c=self.onPostAuraList
    for j=1,#c do
      local v=c[j]
      --eF.counter=eF.counter+1 --TBA
      v[1](v[2])
    end
  
  elseif event=="UNIT_POWER_UPDATE" then

    local c=self.onPowerList
    for j=1,#c do
      local v=c[j]
      v[1](v[2])
    end
    
  elseif event=="UNIT_FLAGS" then
    local id=self.id
    local dead,connected,charmed=UnitIsDeadOrGhost(id),UnitIsConnected(id),UnitIsCharmed(id)
    
    self.offlineFrame:Hide();self.deadFrame:Hide();self.mcFrame:Hide()
    if dead then self.deadFrame:Show()
    elseif not connected then self.offlineFrame:Show()
    elseif charmed then self.mcFrame:Show()
    end
    
  elseif event=="UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
    local c=self.onHAbsorbList
    for j=1,#c do
      local v=c[j]
      v[1](v[2])
    end
  end
  
end
eF.rep.unitEventHandler=unitEventHandler

local function createUnitFrame(self,unit)
  
  --if this unit frame exists already or unit is nil, fuck it
  if self[unit] or not unit then return end  
  local para=eF.para.units

  local s="elFramoUnit"..unit
  self[unit]=CreateFrame("Button",s,UIParent,"SecureUnitButtonTemplate")
  self[unit].id=unit
  
  
  self[unit]:SetAttribute("unit",unit)
  self[unit]:SetAttribute("type1","target")
  self[unit]:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)

  self[unit]:SetAttribute("allowVehicleTarget",false)
  self[unit]:SetAttribute("toggleForVehicle",false)

  if unit=="player" or unit=="party1" or unit=="party2" or unit=="party3" or unit=="party4" then
    self[unit].updateTextColor=eF.rep.updateTextColorGroupFrame; self.group=true else self[unit].updateTextColor=eF.rep.updateTextColorRaidFrame; self.group=false 
  end
  
  self[unit]:SetSize(para.width,para.height)
  self[unit]:SetFrameLevel(15)
  RegisterUnitWatch(self[unit])
  self[unit].enabled=true
  
  self[unit].oor=false
  self[unit].oorA=eF.para.units.oorA
  self[unit].nA=eF.para.units.nA
  
  if eF.para.units.checkOOR then self[unit].updateRange=eF.rep.unitUpdateRange end
  
  
  
  --status bar health: https://us.battle.net/forums/en/wow/topic/8796680765
  
  do --create HP bar
  self[unit].hp=CreateFrame("StatusBar",s.."Health",self[unit],"TextStatusBar") 
  if para.healthGrow=="up" then 
    self[unit].hp:SetPoint("BOTTOMLEFT"); self[unit].hp:SetPoint("BOTTOMRIGHT");  self[unit].hp:SetHeight(para.height); self[unit].hp:SetOrientation("VERTICAL"); self[unit].hp:SetReverseFill(false)
  elseif para.healthGrow=="right" then
    self[unit].hp:SetPoint("BOTTOMLEFT"); self[unit].hp:SetPoint("TOPLEFT"); self[unit].hp:SetWidth(para.width); self[unit].hp:SetOrientation("HORIZONTAL"); self[unit].hp:SetReverseFill(false)  
  elseif para.healthGrow=="down" then
    self[unit].hp:SetPoint("TOPRIGHT"); self[unit].hp:SetPoint("TOPLEFT"); self[unit].hp:SetHeight(para.height); self[unit].hp:SetOrientation("VERTICAL"); self[unit].hp:SetReverseFill(true)
  elseif para.healthGrow=="left" then
    self[unit].hp:SetPoint("TOPRIGHT"); self[unit].hp:SetPoint("BOTTOMRIGHT"); self[unit].hp:SetWidth(para.width); self[unit].hp:SetOrientation("HORIZONTAL"); self[unit].hp:SetReverseFill(true)
  end
  
  if para.bg then 
    self[unit].bg=self[unit].hp:CreateTexture()
    self[unit].bg:SetAllPoints()
    if para.bgR then self[unit].bg:SetColorTexture(para.bgR,para.bgG,para.bgB)
    else self[unit].bg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background") end 
    
    self[unit].bg:SetDrawLayer("BACKGROUND",-4)
  end --end of if para.bg
  
  if not eF.para.units.byClassColor then
    local r,g,b,alpha=eF.para.units.hpR,eF.para.units.hpG,eF.para.units.hpB,eF.para.units.hpA
    self[unit].hp:SetStatusBarTexture(r,g,b,alpha)
  end
  
  if para.hpTexture then 
    self[unit].hp:SetStatusBarTexture(para.hpTexture,0,0.8,0)
   
    if para.hpR then 
      local alpha=para.hpA or 1 
      self[unit].hp:SetStatusBarColor(para.hpR,para.hpG,para.hpB,alpha)    
    end   
  
  else 
    local alpha=para.hpA or 1
    self[unit].hp:SetStatusBarTexture(para.hpR,para.hpG,para.hpB,alpha)  
  end
  
  self[unit].hp:SetMinMaxValues(0,1) 
  self[unit].hp:SetFrameLevel(5)
  
  local hpTexture=self[unit].hp:GetStatusBarTexture()
  
  if para.hpGrad then 
    hpTexture:SetGradientAlpha(para.hpGradOrientation,para.hpGrad1R,para.hpGrad1G,para.hpGrad1B,para.hpGrad1A,para.hpGrad2R,para.hpGrad2G,para.hpGrad2B,para.hpGrad2A)
  end
  
  self[unit].hpUpdate=eF.rep.unitHPUpdate
  end  
  
  do --create name string
  self[unit].text=self[unit].hp:CreateFontString(nil,"OVERLAY",-1)
  self[unit].text:SetFont(para.textFont,para.textSize,para.textExtra)
  self[unit].text:SetPoint(para.textPos,self[unit],para.textPos,para.textXOS,para.textYOS)
  local r=para.textR or 1
  local g=para.textG or 1
  local b=para.textB or 1
  local a=para.textA or 1
  self[unit].text:SetTextColor(r,g,b,a)
  self[unit].updateText=eF.rep.unitUpdateText
  end
  
  --create border
  self[unit].updateBorders=eF.rep.updateUnitBorders
  if para.borderSize then 
    local r=para.borderR or 0
    local g=para.borderG or 0
    local b=para.borderB or 0
    for k,v in next,{"RIGHT","TOP","LEFT","BOTTOM"} do
      local bn=eF.borderInfo(v)      
      self[unit][bn]=self[unit]:CreateTexture("BACKGROUND",-4)
      self[unit][bn]:SetColorTexture(1,1,1)
      --self[unit][bn]:SetVertexColor(r,g,b)
    end
  self[unit]:updateBorders()
  end

  
  --create dead frame
  self[unit].deadFrame=CreateFrame("Frame",s.."deadFrame",self[unit].hp)
  self[unit].deadFrame:SetAllPoints(true)
  self[unit].deadFrame:SetFrameLevel(self[unit]:GetFrameLevel()+1)
  self[unit].deadFrame.texture=self[unit].deadFrame:CreateTexture(nil,"BACKGROUND")
  self[unit].deadFrame.texture:SetAllPoints(true)
  self[unit].deadFrame.texture:SetColorTexture(0.5,0.5,0.5,0.2)
  self[unit].deadFrame.text=self[unit].deadFrame:CreateFontString(nil,"OVERLAY")
  self[unit].deadFrame.text:SetFont(para.textFont,para.textSize,para.textExtra)
  self[unit].deadFrame.text:SetText("DEAD")
  self[unit].deadFrame.text:SetPoint("CENTER")
  self[unit].deadFrame:Hide()
  
  --create offline frame
  self[unit].offlineFrame=CreateFrame("Frame",s.."offlineFrame",self[unit].hp)
  self[unit].offlineFrame:SetAllPoints(true)
  self[unit].offlineFrame:SetFrameLevel(self[unit]:GetFrameLevel()+1)
  self[unit].offlineFrame.texture=self[unit].offlineFrame:CreateTexture(nil,"BACKGROUND")
  self[unit].offlineFrame.texture:SetAllPoints(true)
  self[unit].offlineFrame.texture:SetColorTexture(0.3,0.3,0.3,0.3)
  self[unit].offlineFrame.text=self[unit].offlineFrame:CreateFontString(nil,"OVERLAY")
  self[unit].offlineFrame.text:SetFont(para.textFont,para.textSize,para.textExtra)
  self[unit].offlineFrame.text:SetText("OFFLINE")
  self[unit].offlineFrame.text:SetPoint("CENTER")
  self[unit].offlineFrame:Hide()
  
  --create MC frame
  self[unit].mcFrame=CreateFrame("Frame",s.."mcFrame",self[unit].hp)
  self[unit].mcFrame:SetAllPoints(true)
  self[unit].mcFrame:SetFrameLevel(self[unit]:GetFrameLevel()+1)
  self[unit].mcFrame.texture=self[unit].mcFrame:CreateTexture(nil,"BACKGROUND")
  self[unit].mcFrame.texture:SetAllPoints(true)
  self[unit].mcFrame.texture:SetColorTexture(0.3,0.3,0.3,0.3)
  self[unit].mcFrame.text=self[unit].mcFrame:CreateFontString(nil,"OVERLAY")
  self[unit].mcFrame.text:SetFont(para.textFont,para.textSize,para.textExtra)
  self[unit].mcFrame.text:SetText("MC")
  self[unit].mcFrame.text:SetPoint("CENTER")
  self[unit].mcFrame:Hide()
  
  self[unit].enable=eF.rep.unitEnable
  self[unit].disable=eF.rep.unitDisable
  self[unit].eventHandler=eF.rep.unitEventHandler
  self[unit].checkLoad=eF.rep.unitLoad
  self[unit].updateHPbyClass=eF.rep.updateHPbyClass
  
  self[unit].onAuraList={}
  self[unit].onBuffList={}
  self[unit].onDebuffList={}
  self[unit].onPowerList={}
  self[unit].onPostAuraList={}
  self[unit].onHAbsorbList={}
  
  self[unit].events={"UNIT_HEALTH_FREQUENT","UNIT_MAXHEALTH","UNIT_CONNECTION","UNIT_FACTION","UNIT_AURA","UNIT_POWER_UPDATE","UNIT_FLAGS","UNIT_HEAL_ABSORB_AMOUNT_CHANGED"}
  for i=1,#self[unit].events do self[unit]:RegisterUnitEvent(self[unit].events[i],unit) end
  self[unit]:SetScript("OnEvent",self[unit].eventHandler)
  
  
end --end of CreateUnitFrame()
eF.rep.createUnitFrame=createUnitFrame

local function updateTextColorRaidFrame(self)
  local a
  local para=eF.para.units
  a=para.textA or 1
  
  if para.textColorByClass then
    local r,g,b = 1,1,1
    local _,CLASS=UnitClass(self.id)
    if CLASS then r,g,b=GetClassColor(CLASS) end
    self.text:SetTextColor(r,g,b,a)
  else
    local r,g,b = para.textR or 1, para.textG or 1, para.textB or 1
    self.text:SetTextColor(r,g,b,a)
  end
  
end
eF.rep.updateTextColorRaidFrame=updateTextColorRaidFrame

local function updateTextColorGroupFrame(self)
  local a
  local groupParas=eF.para.groupParas
  local para
  if groupParas then para= eF.para.unitsGroup;  else para=eF.para.units end
  
  a=para.textA or 1
  
  if para.textColorByClass then
  
    local r,g,b = 1,1,1
    local _,CLASS=UnitClass(self.id)
    if CLASS then r,g,b=GetClassColor(CLASS) end
    self.text:SetTextColor(r,g,b,a)
  else
    local r,g,b = para.textR or 1, para.textG or 1, para.textB or 1
    self.text:SetTextColor(r,g,b,a)
  end
  
end
eF.rep.updateTextColorGroupFrame=updateTextColorGroupFrame

local function updateAllUnitParas(self)
  local u,l
  local groupParas=eF.para.groupParas
  for i=1,45 do
    local unit
    
    if i<6 then 
      unit=eF.partyLoop[i]
      if groupParas then u=eF.para.unitsGroup else u=eF.para.units end
    else 
      unit=eF.raidLoop[i-5] 
      u=eF.para.units 
    end
    local f=self[unit]
    
    ---HP
    f:SetSize(u.width or 50,u.height or 70)
    f.hp:ClearAllPoints()
    if u.healthGrow=="up" then 
      f.hp:SetPoint("BOTTOMLEFT"); f.hp:SetPoint("BOTTOMRIGHT");  f.hp:SetHeight(u.height); f.hp:SetOrientation("VERTICAL"); f.hp:SetReverseFill(false)
    elseif u.healthGrow=="right" then
      f.hp:SetPoint("BOTTOMLEFT"); f.hp:SetPoint("TOPLEFT"); f.hp:SetWidth(u.width); f.hp:SetOrientation("HORIZONTAL"); f.hp:SetReverseFill(false)  
    elseif u.healthGrow=="down" then
      f.hp:SetPoint("TOPRIGHT"); f.hp:SetPoint("TOPLEFT"); f.hp:SetHeight(u.height); f.hp:SetOrientation("VERTICAL"); f.hp:SetReverseFill(true)
    elseif u.healthGrow=="left" then
      f.hp:SetPoint("TOPRIGHT"); f.hp:SetPoint("BOTTOMRIGHT"); f.hp:SetWidth(u.width); f.hp:SetOrientation("HORIZONTAL"); f.hp:SetReverseFill(true)
    end
  
    if u.hpTexture then
      f.hp:SetStatusBarTexture(f.hpTexture,0,0.8,0)
    end
  
    if not u.byClassColor then
      local r,g,b,a=u.hpR,u.hpG,u.hpB,u.hpA
      f.hp:SetStatusBarTexture(r,g,b,a)
    else
      f:updateHPbyClass()
    end
    
    local hpTexture=f.hp:GetStatusBarTexture()
    
    if u.hpGrad then
      hpTexture:SetGradientAlpha(u.hpGradOrientation,u.hpGrad1R,u.hpGrad1G,u.hpGrad1B,u.hpGrad1A,u.hpGrad2R,u.hpGrad2G,u.hpGrad2B,u.hpGrad2A)
    end
    
    ---TEXT
    f.text:SetFont(u.textFont,u.textSize,u.textExtra)
    f.text:ClearAllPoints()
    f.text:SetPoint(u.textPos,f,u.textPos,u.textXOS,u.textYOS)
    
    f.deadFrame.text:SetFont(u.textFont,u.textSize,u.textExtra)
    f.offlineFrame.text:SetFont(u.textFont,u.textSize,u.textExtra)
    f.mcFrame.text:SetFont(u.textFont,u.textSize,u.textExtra)
    
    if u.textColorByClass then
      local r,g,b = 1,1,1
      local _,CLASS=UnitClass(f.id)
      if CLASS then r,g,b=GetClassColor(CLASS) end
      f.text:SetTextColor(r,g,b,a)
    else
      local r,g,b = u.textR or 1, u.textG or 1, u.textB or 1
      f.text:SetTextColor(r,g,b,a)
    end
    f.text:SetAlpha(u.textA or 1)
    
    f:updateText()
    
    
    if u.borderSize then
      local r=u.borderR or 0
      local g=u.borderG or 0
      local b=u.borderB or 0
      local size=u.borderSize
      
      for k,v in next,{"RIGHT","TOP","LEFT","BOTTOM"} do 
        local loc,p1,p2,w,f11,f12,f21,f22=eF.borderInfo(v)
        f[loc]:ClearAllPoints()
        f[loc]:SetVertexColor(r,g,b)
        f[loc]:SetPoint(p1,f,p1,f11*(size),f12*(size))
        f[loc]:SetPoint(p2,f,p2,f21*(size),f22*(size))
        if w then f[loc]:SetWidth(size);
        else f[loc]:SetHeight(size); end    
      end
    end

  end --end of for i=1,45
end
eF.rep.updateAllUnitParas=updateAllUnitParas

local function initUnitsUnits()

  for i=1,5 do
    eF.units:createUnitFrame(eF.partyLoop[i])
  end
  
  for i=1,40 do
    eF.units:createUnitFrame(eF.raidLoop[i])
  end
  
end
eF.rep.initUnitsUnits=initUnitsUnits

local function unitUpdateRange(self)
   local r=UnitInRange(self.id)  
   if not r and not self.oor then 
    self:SetAlpha(self.oorA)
    self.oor=true
   elseif self.oor and r then
    self:SetAlpha(self.nA)
    self.oor=false
   end
end
eF.rep.unitUpdateRange=unitUpdateRange

local throttle=eF.para.throttle or 0.1
local eT=0
local function unitsFrameOnUpdate(self,elapsed)
  if eT<throttle then eT=eT+elapsed; return end
  eT=0
  local tbl
  if self.raid then tbl=eF.raidLoop else tbl=eF.partyLoop end
  
  if not (self.num>1) then return end --if youre alone in the group it's fucked  
  for i=1,self.num do
    local frame=self[tbl[i]]
    frame:updateRange()  
    
  end--end of for i=1,self.num
end
eF.rep.unitsFrameOnUpdate=unitsFrameOnUpdate

local function unitsOnGroupUpdate(self)
    local icl=InCombatLockdown()
    if icl then eF.OOCActions.groupUpdate=true end
    local byCC
    local raid=IsInRaid()
    self.raid=IsInRaid() --is used for the updatefunction
    local num=GetNumGroupMembers() --for some reason gives 0 when solo
    if num==0 then num=1 end
    self.num=num
    
    if num==1 then 
      local spec=GetSpecialization()
      local role=select(5,GetSpecializationInfo(spec))
      eF.info.playerRole=role
    else 
      eF.info.playerRole=UnitGroupRolesAssigned("player")
    end
    
    local instanceName,_,_,_,_,_,_,instanceID=GetInstanceInfo()
    eF.info.instanceName=instanceName
    eF.info.instanceID=instanceID
    
    local lst
    if raid then lst=eF.raidLoop
    else lst=eF.partyLoop end  
     
    if (not raid) and eF.para.groupParas then byCC=eF.para.unitsGroup.byClassColor else byCC=eF.para.units.byClassColor end
     
    for n=1,num do
      local unit=lst[n]  
      local class,CLASS=UnitClass(unit)
      if byCC then  
        self[unit]:updateHPbyClass()
      end--end of byClassColor
        
      self[unit]:updateText()
      self[unit]:eventHandler("UNIT_FLAGS")
      
      
      local role=UnitGroupRolesAssigned(unit)
      if role=="NONE" and unit=="player" then self[unit].role=eF.info.playerRole 
      else self[unit].role=role end
      self[unit].class=class
      self:checkLoad()
      
    end --end of for n=1,num
      
    --Hide all others
    
    if icl then return end
    if raid then     
      for i=1,5 do
        local unit=eF.partyLoop[i]; self[unit]:disable(); 
      end        
    else
      for i=1,5 do
        local unit=eF.partyLoop[i]; self[unit]:enable(); 
      end  
    end

end
eF.rep.unitsOnGroupUpdate=unitsOnGroupUpdate

local function unitsLoad(self) ---self here is eF.units !!!
  
  local tbl
  if self.raid then tbl=eF.raidLoop else tbl=eF.partyLoop end
  for i=1,self.num do 
    local unit=tbl[i]
    self[unit]:checkLoad()    
  end 
end
eF.rep.unitsLoad=unitsLoad

local function unitLoad(self)
  local insert=table.insert
  local nj=#self.families or 0
  local unitRole=self.role
  local unitClass=self.class
  local checkElementLoad=eF.rep.checkElementLoad

  
  self.onAuraList={}
  self.onBuffList={}
  self.onDebuffList={}
  self.onPowerList={}
  self.onPostAuraList={}
  self.onHAbsorbList={}
  self.onCastList={}
  self.onPostCastList={}
  
  for j=1,nj do 
    if self[j].smart then 
      if checkElementLoad(self[j],unitRole,unitClass) then
        local onAura=self[j].onAuraList
        local onBuff=self[j].onBuffList
        local onDebuff=self[j].onDebuffList
        local onPower=self[j].onPowerList
        local onUpdate=self[j].onUpdateList
        local onPostAura=self[j].onPostAuraList
        local onHAbsorb=self[j].onHAbsorbList
        local onCast=self[j].onCastList
        local onPostCast=self[j].onPostCastList
        
        for l=1,#onAura do
          insert(self.onAuraList,onAura[l])
        end
        
        for l=1,#onBuff do
          insert(self.onBuffList,onBuff[l])
        end
        
        for l=1,#onDebuff do
          insert(self.onDebuffList,onDebuff[l])
        end
        
        for l=1,#onPower do
          insert(self.onPowerList,onPower[l])
        end

        for l=1,#onPostAura do
          insert(self.onPostAuraList,onPostAura[l])
        end
        
        for l=1,#onHAbsorb do
          insert(self.onHAbsorbList,onHAbsorb[l])
        end
        
        for l=1,#onCast do
          insert(self.onCastList,onCast[l])
        end
        
        for l=1,#onPostCast do
          insert(self.onPostCastList,onPostCast[l])
        end
        
      end --end of if self[j]:checkLoad
      
    else --else of if selfj.smart
      local nk=self[j].para.count
      for k=1,nk do   
        if checkElementLoad(self[j][k],unitRole,unitClass) then
          local onAura=self[j][k].onAuraList
          local onBuff=self[j][k].onBuffList
          local onDebuff=self[j][k].onDebuffList
          local onPower=self[j][k].onPowerList
          local onUpdate=self[j][k].onUpdateList
          local onPostAura=self[j][k].onPostAuraList
          local onHAbsorb=self[j][k].onHAbsorbList
          
          if self[j][k].static then self[j][k]:enable() end
          
          for l=1,#onAura do
            insert(self.onAuraList,onAura[l])
          end
          
          for l=1,#onBuff do
            insert(self.onBuffList,onBuff[l])
          end
          
          for l=1,#onDebuff do
            insert(self.onDebuffList,onDebuff[l])
          end
          
          for l=1,#onPower do
            insert(self.onPowerList,onPower[l])
          end
          
          for l=1,#onPostAura do
            insert(self.onPostAuraList,onPostAura[l])
          end
              
          for l=1,#onHAbsorb do
            insert(self.onHAbsorbList,onHAbsorb[l])
          end
              
        else--else of if selfjk.checkLoad
          if self[j][k].static then self[j][k]:disable() end
        end
        
      end --end of for k=1,nk
      
    end--end of if smart else 
    
  end--end of for j=1,nj
      
  self:eventHandler("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
  self:eventHandler("UNIT_POWER_UPDATE")
end
eF.rep.unitLoad=unitLoad

local function checkElementLoad(self,unitRole,unitClass)
  if not self then return end 
  
  local para=self.para
  
  if para.loadAlways then 
    if not self.loaded then 
      self.loaded=true; 
      if self.static then self:enable() end
    end
    return true 
  end 
  
  
  local inList=eF.isInList
  local b=true
  local info=eF.info
  local playerRole,playerClass,instanceName,instanceID,encounterID=info.playerRole,info.playerClass,info.instanceName,info.instanceID,info.encounterID
  
  if b and (not para.instanceLoadAlways) and not (inList(instanceID,para.loadInstanceList) or inList(instanceName,para.loadInstanceList)) then b=false end

  if b and (not para.encounterLoadAlways) and not (inList(encounterID,para.loadEncounterList)) then b=false end

  if b and (not para.unitRoleLoadAlways) and not inList(unitRole,para.loadUnitRoleList) then b=false end

  if b and (not para.unitClassLoadAlways) and not inList(unitClass,para.loadUnitClassList) then b=false end

  if b and (not para.playerRoleLoadAlways) and not inList(playerRole,para.loadPlayerRoleList) then b=false end

  if b and (not para.playerClassLoadAlways) and not inList(playerClass,para.loadPlayerClassList) then b=false end

  
  if not b and self.loaded then self.loaded=false; self:disable() end
  if b and not self.loaded then 
    if self.static then self:enable() end
    self.loaded=true
  end
  
  return b
end
eF.rep.checkElementLoad=checkElementLoad

local function updateUnitFrameHealthVisuals(self)
  local para=eF.para.units
  local hG=para.healthGrow
  local byCC=eF.para.units.byClassColor
 
 --update orientation
  for i=1,45 do
    local unit
    if i<6 then unit=eF.partyLoop[i] else unit=eF.raidLoop[i-5] end
    
    if self.healthGrow=="up" then 
      self[unit].hp:SetPoint("BOTTOMLEFT"); self[unit].hp:SetPoint("BOTTOMRIGHT");  self[unit].hp:SetHeight(self.height); self[unit].hp:SetOrientation("VERTICAL"); self[unit].hp:SetReverseFill(false)
    elseif self.healthGrow=="right" then
      self[unit].hp:SetPoint("BOTTOMLEFT"); self[unit].hp:SetPoint("TOPLEFT"); self[unit].hp:SetWidth(self.width); self[unit].hp:SetOrientation("HORIZONTAL"); self[unit].hp:SetReverseFill(false)
    elseif self.healthGrow=="down" then
      self[unit].hp:SetPoint("TOPRIGHT"); self[unit].hp:SetPoint("TOPLEFT"); self[unit].hp:SetHeight(self.height); self[unit].hp:SetOrientation("VERTICAL"); self[unit].hp:SetReverseFill(true)
    elseif self.healthGrow=="left" then
      self[unit].hp:SetPoint("TOPRIGHT"); self[unit].hp:SetPoint("BOTTOMRIGHT"); self[unit].hp:SetWidth(self.width); self[unit].hp:SetOrientation("HORIZONTAL"); self[unit].hp:SetReverseFill(true)
    end 
  end
  
  --update color if byCC else
  local a=self.hpA or 1
  if byCC then
    local lst
    if raid then lst=eF.raidLoop
    else lst=eF.partyLoop end  
    
    for i=1,self.num do
      local unit=lst[i]
      unit:updateHPbyClass()
    end
  
  else
    local r,g,b=self.hpR,self.hpG,self.hpB
    for i=1,45 do
      local unit
      if i<6 then unit=eF.partyLoop[i] else unit=eF.raidLoop[i-5] end
      self[unit].hp:SetStatusBarTexture(r,g,b,a)
    end
  
  end
end
eF.rep.updateUnitFrameHealthVisuals=updateUnitFrameHealthVisuals

local function updateHPbyClass(self)
  local unit=self.id
  local _,CLASS=UnitClass(unit)
  local r,g,b=0,0,0
  if self.group and eF.para.groupParas then para=eF.unitsGroup else para=eF.units end
  if CLASS then r,g,b=GetClassColor(CLASS) end
  self.hp:SetStatusBarTexture(r,g,b)
end
eF.rep.updateHPbyClass=updateHPbyClass

--initUnitsFrame()
--initUnitsUnits()







