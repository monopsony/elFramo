local _,eF=...
--see OptionsPanelTemplates.xml
local font="Fonts\\FRIZQT__.ttf"
local font2="Fonts\\ARIALN.ttf"
local border1="Interface\\Tooltips\\UI-Tooltip-Border"
local fontExtra="OUTLINE"
local smallBreak="Interface\\QUESTFRAME\\UI-HorizontalBreak"
local largeBreak="Interface\\MailFrame\\MailPopup-Divider"
local afterDo=C_Timer.After
local div="Interface\\HELPFRAME\\HelpFrameDivider"
local titleFont="Fonts\\ARIALN.ttf"
local titleFontExtra="OUTLINE"
local titleFontColor={0.9,0.9,0.1}
local titleFontColor2={0.9,0.9,0.6}
local familyListFontSize=15
local titleSpacer="Interface\\OPTIONSFRAME\\UI-OptionsFrame-Spacer"
local bd2={edgeFile ="Interface\\Tooltips\\UI-Tooltip-Border" ,edgeSize = 10, insets ={ left = 0, right = 0, top = 0, bottom = 0 }}
local bd={edgeFile ="Interface\\DialogFrame\\UI-DialogBox-Border",edgeSize = 20, insets ={ left = 0, right = 0, top = 0, bottom = 0 }}
local int,tb,hd1,hd1b1,hd1b2,hd1b3,gf,ff
local ySpacing=25
local initSpacing=15
local familyHeight=30
local ssub,trem=string.sub,table.remove
local plusTexture="Interface\\GuildBankFrame\\UI-GuildBankFrame-NewTab"
local destroyTexture="Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Opaque"
local arrowDownTexture="Interface\\Calendar\\MoreArrow"

eF.familyButtonsList={}
eF.para.familyButtonsIndexList={}
eF.activeConfirmMove=nil
eF.activeParaWindow=nil
--  local sc=eF.interface.familiesFrame.famList.scrollChild
-- local ftabs=eF.interface.familiesFrame.tabs

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function ScrollFrame_OnMouseWheel(self,delta)
  local v=self:GetVerticalScroll() - (delta*familyHeight/2)
  if (v<0) then
    v=0;
  elseif (v>self:GetVerticalScrollRange()) then
    v=self:GetVerticalScrollRange();
  end
  
  self:SetVerticalScroll(v)
end

local function releaseAllFamilies()
  local lst=eF.familyButtonsList
  
  for i=1,#lst do
    --if lst[i]:GetButtonState()=="PUSHED" then lst[i]:SetButtonState("NORMAL") end
    lst[i]:Enable()
  end
  
  eF.interface.familiesFrame.tabs.tab1:Enable()
  eF.interface.familiesFrame.tabs.tab2:Enable()
end

local function header1ReleaseAll()
  hd1.button1:Enable()
  hd1.button2:Enable()
  hd1.button3:Enable()
  if hd1.button1.relatedFrame then hd1.button1.relatedFrame:Hide() end
  if hd1.button2.relatedFrame then hd1.button2.relatedFrame:Hide() end
  if hd1.button3.relatedFrame then hd1.button3.relatedFrame:Hide() end
end

local function makeHeader1Button(self)
  self:SetHeight(39)
  self:SetWidth(100)
  self:SetBackdrop(bd)

  self.text=self:CreateFontString(nil,"OVERLAY")
  self.text:SetPoint("CENTER")
  self.text:SetFont(font2,17,fontExtra)
  self.text:SetText("General")
  self.text:SetTextColor(0.9,0.9,0.1)

  self.nTexture=self:CreateTexture(nil,"BACKGROUND")
  self.nTexture:SetPoint("TOPLEFT",self,"TOPLEFT",6,-6)
  self.nTexture:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",-6,6)
  self.nTexture:SetColorTexture(0.07,0.07,0.07)
  self:SetNormalTexture(self.nTexture)

  self.pTexture=self:CreateTexture(nil,"BACKGROUND")
  self.pTexture:SetPoint("TOPLEFT",self,"TOPLEFT",6,-6)
  self.pTexture:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",-6,0)
  self.pTexture:SetColorTexture(0.1,0.1,0.1)
  self:SetPushedTexture(self.pTexture)

  self:SetScript("OnClick",function(self)
    header1ReleaseAll()
    self:Disable()
    if self.relatedFrame then self.relatedFrame:Show() end
    end)
end

local function createNumberEB(self,name,tab)
  self[name]=CreateFrame("EditBox",nil,tab,"InputBoxTemplate")
  local eb=self[name]
  eb:SetWidth(30)
  eb:SetHeight(20)
  eb:SetAutoFocus(false)

  eb.text=eb:CreateFontString()
  local tx=eb.text
  tx:SetFont(font,12,fontExtra)
  tx:SetTextColor(1,1,1)
  --tx:SetPoint("RIGHT",eb,"LEFT",-12,0)
  
  eb:SetPoint("LEFT",tx,"RIGHT",12,0)
end

local function createListCB(self,name,tab,width)
  local width=width or 200
  self[name]=CreateFrame("ScrollFrame",nil,tab,"UIPanelScrollFrameTemplate")
  local f=self[name]
  f:SetClipsChildren(true)
  f:SetScript("OnMouseWheel",ScrollFrame_OnMouseWheel)
  f:SetWidth(width) 
  f:SetHeight(120)
  f.border=CreateFrame("Frame",nil,tab)
  f.border:SetPoint("TOPLEFT",f,"TOPLEFT",-4,4)
  f.border:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",4,-4)
  f.border:SetBackdrop(bd)
  
  
  f.ScrollBar:ClearAllPoints()
  f.ScrollBar:SetPoint("TOPRIGHT")
  f.ScrollBar:SetPoint("BOTTOMRIGHT")
  f.ScrollBar.bg=f.ScrollBar:CreateTexture(nil,"BACKGROUND")
  f.ScrollBar.bg:SetAllPoints()
  f.ScrollBar.bg:SetColorTexture(0,0,0,0.5)

  f.scrollChild=CreateFrame("Button",nil,f)
  local fsc=f.scrollChild
  f:SetScrollChild(fsc)
  fsc:SetWidth(width)
  fsc:SetHeight(500)
  
  f.eb=CreateFrame("EditBox",nil,fsc)
  f.eb:SetMultiLine(true)
  f.eb:SetWidth(width-10)
  f.eb:SetCursorPosition(0)
  f.eb:SetAutoFocus(false)
  f.eb:SetFont("Fonts\\FRIZQT__.TTF",12)
  f.eb:SetJustifyH("LEFT")
  f.eb:SetJustifyV("CENTER")
  f.eb:SetPoint("TOPLEFT",fsc,"TOPLEFT",6,-5) 
  f.scrollChild:SetScript("OnClick",function() f.eb:SetFocus() end )
  
  f.bg=f:CreateTexture(nil,"BACKGROUND")
  f.bg:SetPoint("TOPLEFT")
  f.bg:SetPoint("BOTTOMRIGHT")
  f.bg:SetColorTexture(0,0,0,0.4)
  
  f.button=CreateFrame("Button",nil,f.border,"UIPanelButtonTemplate")
  f.button:SetSize(80,25)
  f.button:SetText("Okay")
  f.button:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,-30)
  f.button.eb=f.eb
  f.eb:SetScript("OnTextChanged",function(self) 
    f.button:Enable()
    local _,nls=self:GetText():gsub('\n','\n')
    f:adjustHeight(nls+1)
    
  end)
  
  f.eb:HookScript("OnEnterPressed",function(self)
    self:Insert('\n')
    if f:GetVerticalScrollRange()>0 then f:SetVerticalScroll(f:GetVerticalScroll() +13) end
  end)
  
  f.adjustHeight= function(self,ni)
    self.scrollChild:SetHeight(ni*13) 
  end

end

local function createFuncBox(self,name,tab,width,height)
  local width=width or 200
  self[name]=CreateFrame("ScrollFrame",nil,tab,"UIPanelScrollFrameTemplate")
  local f=self[name]
  f:SetClipsChildren(true)
  f:SetScript("OnMouseWheel",ScrollFrame_OnMouseWheel)
  f:SetWidth(width) 
  f:SetHeight(height)
  f.border=CreateFrame("Frame",nil,tab)
  f.border:SetPoint("TOPLEFT",f,"TOPLEFT",-4,4)
  f.border:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",4,-4)
  f.border:SetBackdrop(bd)
  
  f.ScrollBar:ClearAllPoints()
  f.ScrollBar:SetPoint("TOPRIGHT")
  f.ScrollBar:SetPoint("BOTTOMRIGHT")
  f.ScrollBar.bg=f.ScrollBar:CreateTexture(nil,"BACKGROUND")
  f.ScrollBar.bg:SetAllPoints()
  f.ScrollBar.bg:SetColorTexture(0,0,0,0.5)

  f.scrollChild=CreateFrame("Button",nil,f)
  local fsc=f.scrollChild
  f:SetScrollChild(fsc)
  fsc:SetWidth(width)
  fsc:SetHeight(500)
  
  f.eb=CreateFrame("EditBox",nil,fsc)
  f.eb:SetMultiLine(true)
  f.eb:SetWidth(width-10)
  f.eb:SetCursorPosition(0)
  f.eb:SetAutoFocus(false)
  f.eb:SetFont("Fonts\\FRIZQT__.TTF",12)
  f.eb:SetJustifyH("LEFT")
  f.eb:SetJustifyV("CENTER")
  f.eb:SetPoint("TOPLEFT",fsc,"TOPLEFT",6,-5) 
  f.scrollChild:SetScript("OnClick",function() f.eb:SetFocus() end )
  
  f.bg=f:CreateTexture(nil,"BACKGROUND")
  f.bg:SetPoint("TOPLEFT")
  f.bg:SetPoint("BOTTOMRIGHT")
  f.bg:SetColorTexture(0,0,0,0.4)
  
  f.button=CreateFrame("Button",nil,f.border,"UIPanelButtonTemplate")
  f.button:SetSize(80,25)
  f.button:SetText("Okay")
  f.button:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,-30)
  f.button.eb=f.eb
  f.eb:SetScript("OnTextChanged",function(self) 
    f.button:Enable()
    local _,nls=self:GetText():gsub('\n','\n')
    f:adjustHeight(nls+1)
  end)
  
  f.eb:HookScript("OnEnterPressed",function(self)
    self:Insert('\n')
    if f:GetVerticalScrollRange()>0 then f:SetVerticalScroll(f:GetVerticalScroll() +13) end
  end)
  
  f.adjustHeight= function(self,ni)
    self.scrollChild:SetHeight(ni*13) 
  end

end

local function createNewDD(self,name,tab,width)
  local width=width
  if not width then width=70 end
  
  self[name]=CreateFrame("Frame",nil,tab)
  local dd=self[name]
  dd.text=dd:CreateFontString()
  local tx=dd.text
  tx:SetFont(font,12,fontExtra)
  tx:SetTextColor(1,1,1)
  dd:SetPoint("LEFT",tx,"BOTTOMRIGHT",-12,11)
  dd.nButtons=0
  dd:SetHeight(20)
  dd:SetWidth(width)
  
  --visual main button
  do
  dd.backgroundTextureLeft=dd:CreateTexture(nil,"BACKGROUND")
  dd.backgroundTextureLeft:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
  dd.backgroundTextureLeft:SetTexCoord(0,0.1953125,0,1)
  dd.backgroundTextureLeft:SetPoint("TOPLEFT",dd,"TOPLEFT",0,17)
  dd.backgroundTextureLeft:SetSize(25,64)
  
  dd.backgroundTextureMiddle=dd:CreateTexture(nil,"BACKGROUND")
  dd.backgroundTextureMiddle:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
  dd.backgroundTextureMiddle:SetTexCoord(0.1953125,0.8046875,0,1)
  dd.backgroundTextureMiddle:SetPoint("LEFT",dd.backgroundTextureLeft,"RIGHT")
  dd.backgroundTextureMiddle:SetSize(width,64)
  
  dd.backgroundTextureRight=dd:CreateTexture(nil,"BACKGROUND")
  dd.backgroundTextureRight:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
  dd.backgroundTextureRight:SetTexCoord(0.8046875,1,0,1)
  dd.backgroundTextureRight:SetPoint("LEFT",dd.backgroundTextureMiddle,"RIGHT")
  dd.backgroundTextureRight:SetSize(25,64)
  
  dd.expandButton=CreateFrame("Button",nil,dd)
  dd.expandButton:SetSize(24,24)
  dd.expandButton:SetPoint("RIGHT",dd.backgroundTextureRight,"RIGHT",-16,1)
  
  local temp
  temp=dd.expandButton:CreateTexture(nil,"BACKGROUND")
  temp:SetSize(24,24)
  temp:SetPoint("RIGHT")
  temp:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
  dd.expandButton:SetNormalTexture(temp)
  
  temp=nil
  temp=dd.expandButton:CreateTexture(nil,"BACKGROUND")
  temp:SetSize(24,24)
  temp:SetPoint("RIGHT")
  temp:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
  dd.expandButton:SetPushedTexture(temp)
  
  temp=nil
  temp=dd.expandButton:CreateTexture(nil,"BACKGROUND")
  temp:SetSize(24,24)
  temp:SetPoint("RIGHT")
  temp:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
  dd.expandButton:SetHighlightTexture(temp)
  dd.expandButton:SetScript("OnClick",function(self) if self.parentList:IsShown() then self.parentList:Hide() else self.parentList:Show() end end)
  
  
  dd.buttonText=dd:CreateFontString(nil,"OVERLAY")
  dd.buttonText:SetFont("Fonts\\FRIZQT__.ttf",10)
  dd.buttonText:SetPoint("LEFT",dd.backgroundTextureLeft,"LEFT",27,2)
  dd.buttonText:SetPoint("RIGHT",dd.expandButton,"LEFT")
  dd.buttonText:SetText("NA")
  dd.buttonText:SetNonSpaceWrap(true)
  dd.buttonText:SetHeight(10)
  
  
 end--end of visual main button
 
  --dd list visual
  do
  
  dd.dropDownList=CreateFrame("Frame",nil,dd)
  local ddl=dd.dropDownList
  ddl:SetBackdrop( {bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile="true",
                    edgeSize=32,tileSize=32, insets={left=11,right=12,top=12,bottom=9} } )
  ddl:SetSize(100,100)
  ddl:SetPoint("TOPLEFT",dd,"BOTTOMLEFT",8,0)
  ddl:SetFrameLevel(dd:GetFrameLevel()+3)
  ddl:Hide()
  
  dd.expandButton.parentList=ddl

  end
  
  dd.setButtonText=function(self,text)
    self.buttonText:SetText(text)
  end
  
  dd.setListWidth=function(self,width)
    if not width then return end
    self.dropDownList:SetWidth(width) 
  end
  
  dd.buttonList={}
  dd.addButton=function(self,name,func,arg)
    if not name then return end
    local arg=arg
    if not arg then arg=name end
    self.buttonList[arg]=CreateFrame("Button",nil,self.dropDownList)
    local b=self.buttonList[arg]
    
    b.name=name
    local func=func
    if not func then func=function() print("elFramo warning: No function given to DropDownButton "..tostring(name)) end end
    b.func=func
    b.arg=arg
    b.parentList=self.dropDownList
    b.parentButton=self
    
    b:SetHeight(16)
    b:SetPoint("TOPLEFT",self.dropDownList,"TOPLEFT",15,-16-self.nButtons*16)
    b:SetPoint("TOPRIGHT",self.dropDownList,"TOPRIGHT",-15,-16-self.nButtons*16)
    
    
    b.displayText=b:CreateFontString(nil,"OVERLAY")
    local dt=b.displayText
    dt:SetFont("Fonts\\FRIZQT__.ttf",10)
    dt:SetPoint("LEFT",b,"LEFT",8,0)
    dt:SetText(name)
    
    local ht=b:CreateTexture(nil,"BACKGROUND")
    ht:SetAllPoints()
    ht:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    b:SetHighlightTexture(ht)
    
    b:SetScript("OnClick",function(self)
      self:func()
      self.parentList:Hide()
      self.parentButton:setButtonText(self.name)
    end)
    
    self.nButtons=self.nButtons+1
    self.dropDownList:SetHeight(16*self.nButtons+30)
  end
  
  dd:setListWidth(100)
  dd:setButtonText("NA_")
end

local function updateAllFramesFamilyParas(j)
  for i=1,45 do
    local frame
    if i<41 then frame=eF.units[eF.raidLoop[i]] else frame=eF.units[eF.partyLoop[i-40]] end
    frame:applyFamilyParas(j)
    frame:checkLoad()
    frame:eventHandler("UNIT_AURA")
  end--end of for i=1,45
end

local function updateAllFramesChildParas(j,k)
  for i=1,45 do
    local frame
    if i<41 then frame=eF.units[eF.raidLoop[i]] else frame=eF.units[eF.partyLoop[i-40]] end
    frame:applyChildParas(j,k)
    frame:checkLoad()
    frame:eventHandler("UNIT_AURA")  
    
  end--end of for i=1,45
end

local function exterminateChild(j,k)
  
  
  local count=eF.para.families[j].count
  eF.para.families[j].count=count-1
  
  for i=1,45 do
    local frame
    if i<41 then frame=eF.units[eF.raidLoop[i]] else frame=eF.units[eF.partyLoop[i-40]] end
    local c=frame[j][k]
    c.onAuraList={}
    c.onPostAuraList={}
    c.onBuffList={}
    c.onDebuffList={}
    c.onPowerList={}
    c.onUpdateList={}
    c:Hide()
    c=nil
    
    for i=k,count-1 do
      frame[j][i]=nil
      frame[j][i]=frame[j][i+1]      
    end
    frame[j][count]=nil
    
    frame:checkLoad()
    frame:eventHandler("UNIT_AURA")
  end--end of for i=1,45
  
  for i=k,count-1 do
    eF.para.families[j][i]=nil
    eF.para.families[j][i]=eF.para.families[j][i+1]
  end

  
  local n=eF.posInFamilyButtonsList(j,k)
  local bl=eF.familyButtonsList
  local mmax=#bl
  bl[n]:Hide()
  
  for m=n,mmax-1 do
    bl[m]=nil
    bl[m]=bl[m+1]
  end
  bl[mmax]=nil
  
  for m=1,#bl do
    if bl[m].familyIndex==j and (bl[m].childIndex) and (bl[m].childIndex>k) then bl[m].childIndex=bl[m].childIndex-1 end
  end
  
  local sc=eF.interface.familiesFrame.famList.scrollChild
  sc:setFamilyPositions()
  sc:updateFamilyButtonsIndexList()
end

local function exterminateSmartFamily(j)

  local fc=#eF.para.families
  local count=eF.para.families[j].count
  for i=1,count do
    eF.para.families[j][i]=nil
  end
  
  for i=j,fc-1 do
    eF.para.families[i]=nil
    eF.para.families[i]=eF.para.families[i-1]
  end
  eF.para.families[fc]=nil
  
  for i=1,45 do
    local frame
    if i<41 then frame=eF.units[eF.raidLoop[i]] else frame=eF.units[eF.partyLoop[i-40]] end
    local f=frame[j]
    f.onAuraList={}
    f.onPostAuraList={}
    f.onBuffList={}
    f.onDebuffList={}
    f.onPowerList={}
    f.onUpdateList={}
    f:Hide()
    f=nil
    
    for i=j,fc-1 do
      frame[i]=nil
      frame[i]=frame[i+1]      
    end
    frame[fc]=nil
    
    frame:checkLoad()
    frame:eventHandler("UNIT_AURA")
  end--end of for i=1,45
  
 
  
  local n=eF.posInFamilyButtonsList(j)
  local bl=eF.familyButtonsList
  local mmax=#bl
  bl[n]:Hide()
  
  for m=n,mmax-1 do
    bl[m]=nil
    bl[m]=bl[m+1]
  end
  bl[mmax]=nil
  
  for m=1,#bl do
    if bl[m].familyIndex>j then bl[m].familyIndex=bl[m].familyIndex-1 end
  end
  
  local sc=eF.interface.familiesFrame.famList.scrollChild
  sc:setFamilyPositions()
  sc:updateFamilyButtonsIndexList()
end

local function exterminateDumbFamily(j)
 
  local fc=#eF.para.families
  local count=eF.para.families[j].count
  for i=1,count do
    eF.para.families[j][i]=nil
  end
  
  for i=j,fc-1 do
    eF.para.families[i]=nil
    eF.para.families[i]=eF.para.families[i-1]
  end
  eF.para.families[fc]=nil
  
  for i=1,45 do
    local frame
    if i<41 then frame=eF.units[eF.raidLoop[i]] else frame=eF.units[eF.partyLoop[i-40]] end
    local f=frame[j]
    f.onAuraList={}
    f.onPostAuraList={}
    f.onBuffList={}
    f.onDebuffList={}
    f.onPowerList={}
    f.onUpdateList={}
    f:Hide()

    
    for k=1,count do
      local c=frame[j][k]
      c.onAuraList={}
      c.onPostAuraList={}
      c.onBuffList={}
      c.onDebuffList={}
      c.onPowerList={}
      c.onUpdateList={}
      c:Hide()
      c=nil
    end
        
    for i=j,fc-1 do
      frame[i]=nil
      frame[i]=frame[i+1]      
    end
    frame[fc]=nil
    f=nil
    
    frame:checkLoad()
    frame:eventHandler("UNIT_AURA")
  end--end of for i=1,45
  
  
  local n=eF.posInFamilyButtonsList(j)
  local bl=eF.familyButtonsList
  local mmax=#bl
  bl[n]:Hide()
  
  for m=n,mmax-1 do
    bl[m]=nil
    bl[m]=bl[m+1]
  end
  bl[mmax]=nil
  
  for m=1,#bl do
    if bl[m].familyIndex>j then bl[m].familyIndex=bl[m].familyIndex-1 end
  end
  
  local sc=eF.interface.familiesFrame.famList.scrollChild
  sc:setFamilyPositions()
  sc:updateFamilyButtonsIndexList()
end

local function findGroupByName(s)
  local lst=eF.para.families
  local ind=nil
  local tostring=tostring
  
  for i=1,#lst do 
    if lst[i].displayName==s then ind=i; break end
  end
  return ind
end

local function copyChildTo(oj,ok,nj,nk)
  if (not oj) or (not ok) or (not nj) or (not nk) then return nil end
  local paraFam=eF.para.families
  local sc=eF.interface.familiesFrame.famList.scrollChild
  
  if paraFam[nj].smart then return nil end
  if nk>paraFam[nj].count then paraFam[nj].count=nk end
  
  paraFam[nj][nk]=deepcopy(paraFam[oj][ok])
  eF.rep.createAllIconFrame(nj,nk)
  sc:createChild(nj,nk)

  sc:setFamilyPositions()
end

local function moveOrphanToGroup(oj,ok,name)
  local nj=findGroupByName(name)
  if not nj then return nil end
  local paraFam=eF.para.families
  local nk=paraFam[nj].count+1
  paraFam[nj].count=nk

  copyChildTo(oj,ok,nj,nk)
  exterminateChild(oj,ok)
  
  return true
  
end

local function makeOrphan(oj,ok)

  if (not oj) or (not ok) then return nil end
  local paraFam=eF.para.families
  
  if not paraFam[oj][ok] then return nil end
  local nk=paraFam[1].count+1
  paraFam[1].count=nk
  
  copyChildTo(oj,ok,1,nk)
  exterminateChild(oj,ok)

  return true
  
end

local function updateAllFramesFamilyLayout(j)
  for i=1,45 do
    local frame
    if i<41 then frame=eF.units[eF.raidLoop[i]] else frame=eF.units[eF.partyLoop[i-40]] end
    frame:applyFamilyParas(j)
    frame:checkLoad()
  end--end of for i=1,45
end

local function createCB(self,name,tab)
  self[name]=CreateFrame("CheckButton",nil,tab,"ChatConfigCheckButtonTemplate")
  local cb=self[name]
  cb:SetSize(20,20)
  cb:SetHitRectInsets(0,0,0,0)

  cb.text=cb:CreateFontString()
  local tx=cb.text
  tx:SetFont(font,12,fontExtra)
  tx:SetTextColor(1,1,1)

  cb:SetPoint("LEFT",tx,"RIGHT",12,0)
  
end

local function frameToggle(self) 
  if not self then return end
  if InCombatLockdown() then return end
  if self:IsShown() then self:Hide() else self:Show()end
end

local function createHDel(self,name)
  self[name]=CreateFrame("Frame",nil,self)
  local f=self[name]
  f:SetWidth(self:GetWidth()*0.9)
  f:SetHeight(20)
  
  f.t1=f:CreateTexture(nil,"BACKGROUND")
  f.t1:SetPoint("LEFT")
  f.t1:SetTexture(div)
  f.t1:SetTexCoord(0,1,0,1/3)
  f.t1:SetSize(256,21.3)
  
  f.t2=f:CreateTexture(nil,"BACKGROUND")
  f.t2:SetPoint("LEFT",f.t1,"RIGHT")
  f.t2:SetTexture(div)
  f.t2:SetTexCoord(0,1,1/3-0.01,2/3)
  f.t2:SetSize(256,21.3)
  
  f.t4=f:CreateTexture(nil,"BACKGROUND")
  f.t4:SetPoint("RIGHT")
  f.t4:SetTexture(div)
  f.t4:SetTexCoord(0,0.27,2/3-0.04,1)
  f.t4:SetSize(256*0.27,21.3)
  
  f.t3=f:CreateTexture(nil,"BACKGROUND")
  f.t3:SetPoint("RIGHT",f.t4,"LEFT")
  f.t3:SetTexture(div)
  f.t3:SetTexCoord(0,1,1/3-0.01,2/3)
  f.t3:SetSize(256,21.3)
  
end

local function hideAllFamilyParas()
  local ff=eF.interface.familiesFrame
  ff.dumbFamilyScrollFrame:Hide()
  ff.smartFamilyScrollFrame:Hide()
  ff.childIconScrollFrame:Hide()
  ff.childBorderScrollFrame:Hide()
  ff.childBarScrollFrame:Hide()
  ff.elementCreationScrollFrame:Hide()
  
end

local function showSmartFamilyPara()
  local ff=eF.interface.familiesFrame
  ff.smartFamilyFrame:setValues()
  ff.smartFamilyScrollFrame:Show()
end

local function showDumbFamilyPara()
  local ff=eF.interface.familiesFrame
  ff.dumbFamilyFrame:setValues()
  ff.dumbFamilyScrollFrame:Show()
end

local function showChildIconPara()
  local ff=eF.interface.familiesFrame
  ff.childIconScrollFrame:Show()
  ff.childIconFrame:setValues()
end

local function showChildBarPara()
  local cBF=eF.interface.familiesFrame
  ff.childBarScrollFrame:Show()
  ff.childBarFrame:setValues()
end

local function showChildBorderPara()
  local ff=eF.interface.familiesFrame
  ff.childBorderScrollFrame:Show()
  ff.childBorderFrame:setValues()
end

local function createIP(self,name,tab) --icon picker
  self[name]=CreateFrame("EditBox",nil,tab,"InputBoxTemplate")
  local eb=self[name]
  eb:SetWidth(60)
  eb:SetHeight(20)
  eb:SetAutoFocus(false)

  eb.text=eb:CreateFontString()
  local tx=eb.text
  tx:SetFont(font,12,fontExtra)
  tx:SetTextColor(1,1,1)
  --tx:SetPoint("RIGHT",eb,"LEFT",-12,0)
  
  eb:SetPoint("LEFT",tx,"RIGHT",12,0)

  eb.preview=CreateFrame("Frame",nil,tab)
  eb.preview:SetPoint("LEFT",eb,"RIGHT",10,0)
  eb.preview:SetHeight(30)
  eb.preview:SetWidth(30)
  
  eb.pTexture=eb.preview:CreateTexture(nil,"BACKGROUND")
  eb.pTexture:SetAllPoints()
end

local function createCS(self,name,tab)
  self[name]=CreateFrame("Button",nil,tab)
  local cp=self[name]
  cp:SetWidth(35)
  cp:SetHeight(20)
  
  cp.opacityFunc=function()  end
  cp.cancelFunc=function()   end
  cp.func=function()  end
  
  cp.hasOpacity=false
  cp.getOldRGBA=function() return 1,1,1,1 end
  
  cp:SetScript("OnClick",function(self)
    if self.blocked then return end 
    local r,g,b,a=self:getOldRGBA()
    ColorPickerFrame:SetColorRGB(r,g,b)
    if self.hasOpacity then ColorPickerFrame.opacity=a end
    
    ColorPickerFrame.func=self.func; 
    ColorPickerFrame.cancelFunc=self.cancelFunc; 
    ColorPickerFrame.opacityFunc=self.opacityFunc; 
    
    ColorPickerFrame:Show() 
    end)
  
  cp.thumb=cp:CreateTexture(nil,"ARTWORK")
  cp.thumb:SetAllPoints()
  cp.thumb:SetColorTexture(1,1,1)
  
  cp.text=cp:CreateFontString()
  local tx=cp.text
  tx:SetFont(font,12,fontExtra)
  tx:SetTextColor(1,1,1)
  
  cp:SetPoint("LEFT",tx,"RIGHT",8,1)
end

local function intSetInitValues()
  local int=eF.interface
  local gF=int.generalFrame
  local fD=gF.frameDim
  local para=eF.para
  local units=para.units
  local unitsGroup=para.unitsGroup
  local ff=int.familiesFrame
  local fL=ff.famList
  local sc=ff.famList.scrollChild
  local paraFam=eF.para.families
  local bil=eF.para.familyButtonsIndexList
  local fDLazy=fD.fDLazy
  --eF.interface.familiesFrame.famList.scrollChild.families
  --eF.interface.generalFrame.frameDim
  
  --general RAID frame
  do
  fD.ebHeight:SetText(units.height)
  fD.ebWidth:SetText(units.width)
  fD.hDir:setButtonText(units.healthGrow)
  fD.gradStart:SetText( eF.toDecimal(units.hpGrad1R,2) or "nd")
  fD.gradFinal:SetText( eF.toDecimal(units.hpGrad2R,2) or "nd")
  fD.nMax:SetText(units.textLim)
  fD.nSize:SetText(units.textSize)
  
  fD.hClassColor:SetChecked(units.byClassColor)
  fD.hColor.blocked=units.byClassColor
  if units.byClassColor then fD.hColor.blocker:Show() else fD.hColor.blocker:Hide() end
  fD.hColor.thumb:SetVertexColor(units.hpR,units.hpG,units.hpB)
  
  fD.nClassColor:SetChecked(units.textColorByClass)
  fD.nColor.blocked=units.textColorByClass 
  if units.textColorByClass then fD.nColor.blocker:Show() else fD.nColor.blocker:Hide() end
  fD.nColor.thumb:SetVertexColor(units.textR,units.textG,units.textB)
  
  local font=ssub(units.textFont,7,-5)
  fD.nFont:setButtonText(font) 
  
  fD.nAlpha:SetText(eF.toDecimal(units.textA,2) or "nd")
  fD.nPos:setButtonText(units.textPos)
  fD.textXOS:SetText(units.textXOS or 0)
  fD.textYOS:SetText(units.textYOS or 0)

  fD.bColor.thumb:SetVertexColor(units.borderR,units.borderG,units.borderB)
  fD.bWid:SetText(units.borderSize)
  
  fD.grow1:setButtonText(units.grow1 or "down")
  fD.grow2:setButtonText(units.grow2 or "right")
  fD.spacing:SetText(units.spacing or 0)
  fD.maxInLine:SetText(units.maxInLine or 5)
  fD.byGroup:SetChecked(units.byGroup or true)
  fD.xPos:SetText(math.floor(units.xPos or 0))
  fD.yPos:SetText(math.floor(units.yPos or 0))
  end
  
  --general PARTY frame
  do
  fDLazy.groupParas:SetChecked(para.groupParas)
  if not para.groupParas then fDLazy.iconBlocker:Show() else fDLazy.iconBlocker:Hide() end
  
  fDLazy.ebHeight:SetText(unitsGroup.height)
  fDLazy.ebWidth:SetText(unitsGroup.width)
  
  fDLazy.hDir:setButtonText(unitsGroup.healthGrow)  
  fDLazy.gradStart:SetText( eF.toDecimal(unitsGroup.hpGrad1R,2) or "nd")
  fDLazy.gradFinal:SetText( eF.toDecimal(unitsGroup.hpGrad2R,2) or "nd")
  fDLazy.nMax:SetText(unitsGroup.textLim)
  fDLazy.nSize:SetText(unitsGroup.textSize)
  
  fDLazy.hClassColor:SetChecked(unitsGroup.byClassColor)
  fDLazy.hColor.blocked=unitsGroup.byClassColor
  if unitsGroup.byClassColor then fDLazy.hColor.blocker:Show() else fDLazy.hColor.blocker:Hide() end
  fDLazy.hColor.thumb:SetVertexColor(unitsGroup.hpR,unitsGroup.hpG,unitsGroup.hpB)
  
  fDLazy.nClassColor:SetChecked(unitsGroup.textColorByClass)
  fDLazy.nColor.blocked=unitsGroup.textColorByClass
  if unitsGroup.textColorByClass then fDLazy.nColor.blocker:Show() else fDLazy.nColor.blocker:Hide() end
  fDLazy.nColor.thumb:SetVertexColor(unitsGroup.textR,unitsGroup.textG,unitsGroup.textB)
  
  local font=ssub(unitsGroup.textFont,7,-5)
  fDLazy.nFont:setButtonText(font) 
  
  fDLazy.nAlpha:SetText(eF.toDecimal(unitsGroup.textA,2) or "nd")
  fDLazy.nPos:setButtonText(unitsGroup.textPos)
  fDLazy.textXOS:SetText(unitsGroup.textXOS or 0)
  fDLazy.textYOS:SetText(unitsGroup.textYOS or 0)

  fDLazy.bColor.thumb:SetVertexColor(unitsGroup.borderR,unitsGroup.borderG,unitsGroup.borderB)
  fDLazy.bWid:SetText(unitsGroup.borderSize or 1)
  fDLazy.grow1:setButtonText(unitsGroup.grow1 or "down")
  fDLazy.grow2:setButtonText(unitsGroup.grow2 or "right")
  fDLazy.spacing:SetText(unitsGroup.spacing or 0)
  fDLazy.maxInLine:SetText(unitsGroup.maxInLine or 5)
  fDLazy.byGroup:SetChecked(unitsGroup.byGroup or true)
  fDLazy.xPos:SetText(math.floor(unitsGroup.xPos or 0))
  fDLazy.yPos:SetText(math.floor(unitsGroup.yPos or 0))
  end
  
  eF.units:updateAllParas()
 
  --family frame
  do 
  for i=1,#bil do
    local j=bil[i][1]
    local k=bil[i][2]
    if k then sc:createChild(j,k)
    else  
      if paraFam[j].smart then sc:createFamily(j) 
      else
        sc:createGroup(j)
        for l=1,paraFam[j].count do 
          sc:createChild(j,l)
        end--end of for l=1,paraFamj.count
      end
      
    end--end of if
  end
  
  for i=2,#paraFam do
    if not eF.posInFamilyButtonsList(i) then sc:createFamily(i) end
  end

  
  for i=1,paraFam[1].count do
    if not eF.posInFamilyButtonsList(1,i) then sc:createChild(1,i) end
  end
  
  sc:setFamilyPositions()

  hideAllFamilyParas()

  
  end
  
end
eF.rep.intSetInitValues=intSetInitValues

local function createAllFamilyFrame(j)
  local units=eF.units
  local insert=table.insert  
  
  for i=1,45 do
    local frame
    if i<41 then frame=eF.units[eF.raidLoop[i]] else frame=eF.units[eF.partyLoop[i-40]] end
    
    eF.units.familyCount=#frame.families

    frame:createFamily(j)
    if eF.para.families[j].smart then frame:applyFamilyParas(j)
    else
      for k=1,eF.para.families[j].count do frame:applyChildParas(j,k) end
    end
 
  end--end of for i=1,45
end

local function createAllIconFrame(j,k)
  local units=eF.units
  local insert=table.insert  
  
  for i=1,45 do
    local frame
    if i<41 then frame=eF.units[eF.raidLoop[i]] else frame=eF.units[eF.partyLoop[i-40]] end
    
    frame[j]:createChild(k)
    frame:applyChildParas(j,k) 
  end--end of for i=1,45
end
eF.rep.createAllIconFrame=createAllIconFrame

local function createNewWhitelistParas(j)
  eF.para.families[j]={displayName="New Whitelist",
     smart=true,
     count=3,
     type="w",
     xPos=0,
     yPos=0,
     spacing=1,
     height=15,
     frameLevel=4,
     width=15,
     anchor="CENTER",
     anchorTo="CENTER",
     trackType="Buffs",
     arg1={},
     smartIcons=true,
     grow="right",
     growAnchor="LEFT",
     growAnchorTo="LEFT",
     cdReverse=false,
     cdWheel=true,
     hasBorder=false,
     borderType="debuffColor",
     hasText=true,
     hasTexture=true,
     ignorePermanents=true,
     ignoreDurationAbove=nil,
     textType="Time left",                                     
     textAnchor="CENTER",
     textAnchorTo="CENTER",
     textXOS=0,
     textYOS=0,
     textSize=15,
     textR=1,
     textG=1,
     textB=1,
     textA=1,
     textDecimals=1,
     ownOnly=false,
     loadAlways=true,
     unitClassLoadAlways=true,
     unitRoleLoadAlways=true,
     instanceLoadAlways=true,
     encounterLoadAlways=true,
     playerClassLoadAlways=true,
     playerRoleLoadAlways=true,
  }
end

local function createNewBlacklistParas(j)
  eF.para.families[j]={displayName="New Blacklist",
     smart=true,
     count=3,
     type="b",
     xPos=0,
     yPos=0,
     spacing=1,
     height=15,
     frameLevel=4,
     width=15,
     anchor="CENTER",
     anchorTo="CENTER",
     trackType="Buffs",
     arg1={},
     smartIcons=true,
     grow="right",
     growAnchor="LEFT",
     growAnchorTo="LEFT",
     cdReverse=false,
     cdWheel=true,
     hasBorder=false,
     borderType="debuffColor",
     hasText=true,
     hasTexture=true,
     ignorePermanents=true,
     ignoreDurationAbove=nil,
     textType="Time left",                                     
     textAnchor="CENTER",
     textAnchorTo="CENTER",
     textXOS=0,
     textYOS=0,
     textSize=15,
     textR=1,
     textG=1,
     textB=1,
     textA=1,
     textDecimals=1,
     ownOnly=false,
     loadAlways=true,
     unitClassLoadAlways=true,
     unitRoleLoadAlways=true,
     instanceLoadAlways=true,
     encounterLoadAlways=true,
     playerClassLoadAlways=true,
     playerRoleLoadAlways=true,
  }
end

local function createNewGroupParas(j)
  eF.para.families[j]={
    displayName="New Group",
    smart=false,
    count=0,
    buttonsIndexList={},
    }
end

local function createNewIconParas(j,k)
  eF.para.families[j][k]={
  displayName="New Icon",
  type="icon",
  trackType="Buffs",
  trackBy="Name",
  arg1="",
  xPos=0,
  yPos=0,
  frameLevel=4,
  height=20,
  width=20,
  anchor="CENTER",
  anchorTo="CENTER",
  textureR=1,
  textureG=1,
  textureB=1,
  cdWheel=true,
  cdReverse=true,
  hasBorder=false,
  smartIcon=true,
  hasText=true,
  hasTexture=true,
  textType="Time left",
  textAnchor="CENTER",
  textAnchorTo="CENTER",
  textXOS=0,
  textYOS=0,
  textFont="Fonts\\FRIZQT__.ttf",
  textExtra="OUTLINE",
  textSize=14,
  textR=0.85,
  textG=0.85,
  textB=0.85,
  textA=1,
  textDecimals=0,
  ownOnly=true,
  loadAlways=true,
  unitClassLoadAlways=true,
  unitRoleLoadAlways=true,
  instanceLoadAlways=true,
  encounterLoadAlways=true,
  playerClassLoadAlways=true,
  playerRoleLoadAlways=true,
  extra1string="",
  extra1checkOn="None",
  }
end

local function createNewBarParas(j,k)
eF.para.families[j][k]={
  displayName="New Bar",
  type="bar",
  trackType="power",
  lFix=10,
  lMax=50,
  xPos=0,
  yPos=0,
  grow="up",
  anchor="CENTER",
  anchorTo="CENTER",
  loadAlways=true,
  unitClassLoadAlways=true,
  unitRoleLoadAlways=true,
  instanceLoadAlways=true,
  encounterLoadAlways=true,
  playerClassLoadAlways=true,
  playerRoleLoadAlways=true,  textureR=1,
  textureG=1,
  textureB=1,
  textureA=1,
  }
end

local function createNewBorderParas(j,k)
eF.para.families[j][k]={
  displayName="New Border",
  type="border",
  trackType="Buffs",
  trackBy="Name",
  arg1="",
  borderSize=2,
  ownOnly=true,
  loadAlways=true,
  unitClassLoadAlways=true,
  unitRoleLoadAlways=true,
  instanceLoadAlways=true,
  encounterLoadAlways=true,
  playerClassLoadAlways=true,
  playerRoleLoadAlways=true,
  borderR=1,
  borderG=1,
  borderB=1,
  borderA=1,
  }
end

local function moveButtonUpList(self)
  local j,k=self.parentButton.familyIndex,self.parentButton.childIndex
  local n=eF.posInFamilyButtonsList(j,k)
  if n==1 then return end
  local m=n-1
  local bl=eF.familyButtonsList
  
  local justInCase=0
  while m>0 and justInCase<1000 do
    justInCase=justInCase+1
    if not bl[m].collapsible then break end
    m=m-1
  end
  
  local save=bl[m]
  bl[m]=bl[n]
  bl[n]=save
  
  
  local sc=eF.interface.familiesFrame.famList.scrollChild
  sc:updateFamilyButtonsIndexList()
  sc:setFamilyPositions()
  
end

local function moveButtonDownList(self)
  local j,k=self.parentButton.familyIndex,self.parentButton.childIndex
  local n=eF.posInFamilyButtonsList(j,k)
  local bl=eF.familyButtonsList
  local mmax=#bl
  
  if n==mmax then return end
  local m=n+1
  
  local justInCase=0
  while m<mmax+1 and justInCase<1000 do
    justInCase=justInCase+1
    if not bl[m].collapsible then break end
    m=m+1
  end
  
  local save=bl[m]
  bl[m]=bl[n]
  bl[n]=save
  

  local sc=eF.interface.familiesFrame.famList.scrollChild
  sc:updateFamilyButtonsIndexList()
  sc:setFamilyPositions()
  
end

local function createFamily(self,n,pos)

  local para=eF.para.families[n]
  if self.families[n] then self.families[n]=nil end
  
  --button creation
  self.families[n]=CreateFrame("Button",nil,self)
  local f=self.families[n]
  f:SetWidth(eF.interface.familiesFrame.famList:GetWidth()-25)
  f:SetHeight(familyHeight)
  f:SetPoint("TOPRIGHT",self,"TOPRIGHT")
  f:SetBackdrop(bd2)
  f.para=para
  f.familyIndex=n
  f.smart=true
  
  if not pos then table.insert(eF.familyButtonsList,f) else table.insert(eF.familyButtonsList,pos,f) end
  
  f:SetScript("OnClick",function(self)
    local tab1=eF.interface.familiesFrame.tabs.tab1
    releaseAllFamilies()
    hideAllFamilyParas()
    eF.activePara=para
    eF.activeButton=self
    eF.activeFamilyIndex=self.familyIndex
    if self.para.smart then showSmartFamilyPara() else showDumbFamilyPara() end
    self:Disable()
    local tabs=eF.interface.familiesFrame.tabs
    if not tabs:IsShown() then tabs:Show() end
    tab1:SetButtonState("PUSHED")
    tab1:Click()
    end)
  
  local sc=eF.interface.familiesFrame.famList.scrollChild
  sc:updateFamilyButtonsIndexList()
  
  -- normal texture
  do
  f.bg=f:CreateTexture(nil,"BACKGROUND")
  f.bg:SetPoint("TOPLEFT",f,"TOPLEFT",3,-3)
  f.bg:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-3,3)
  f.bg:SetColorTexture(0.2,0.25,0.2,1)
  f.bg:SetGradient("vertical",0.5,0.5,0.5,0.8,0.8,0.8)
  f:SetNormalTexture(f.bg)
  end
   
  --pushed texture
  do
  f.bg=f:CreateTexture(nil,"BACKGROUND")
  f.bg:SetPoint("TOPLEFT",f,"TOPLEFT",3,-3)
  f.bg:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-3,3)
  f.bg:SetColorTexture(0.6,0.8,0.4)
  f.bg:SetGradient("vertical",0.4,0.4,0.4,0.7,0.7,0.7)
  f:SetPushedTexture(f.bg)
  end
   
  --Highlight creation
  do
  f.hl=f:CreateTexture(nil,"BACKGROUND")
  f.hl:SetPoint("BOTTOM",f,"BOTTOM",0,-1)
  f.hl:SetHeight(f:GetHeight()*0.3)
  f.hl:SetWidth(f:GetWidth()*0.8)
  f.hl:SetTexture("Interface\\BUTTONS\\UI-SILVER-BUTTON-HIGHLIGHT")
  f:SetHighlightTexture(f.hl)
  end
  
  --text creation
  do
  f.text=f:CreateFontString()
  f.text:SetPoint("CENTER")
  f.text:SetFont("Fonts\\ARIALN.ttf",familyListFontSize,fontExtra)
  f.text:SetTextColor(0.9,0.9,0.9)
  f.text:SetText(para.displayName)
  end
      
  --up and down buttons    
  do
    local text
    f.up=CreateFrame("Button",nil,f)
    f.up:SetPoint("TOPRIGHT",f,"TOPRIGHT",-1,0)
    f.up:SetSize(f:GetHeight()/2,f:GetHeight()/2)
    f.up.parentButton=f

    text=f.up:CreateTexture(nil,"BACKGROUND")
    text:SetAllPoints()
    text:SetTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up")
    text:SetRotation(math.pi/2)
    f.up:SetNormalTexture(text)
    
    text=nil
    text=f.up:CreateTexture(nil,"BACKGROUND")
    text:SetAllPoints()
    text:SetTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Down")
    text:SetRotation(math.pi/2)
    f.up:SetPushedTexture(text)   
    f.up:SetScript("OnClick",moveButtonUpList)
    
    f.down=CreateFrame("Button",nil,f)
    f.down:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-1,2)
    f.down:SetSize(f:GetHeight()/2,f:GetHeight()/2)
    f.down.parentButton=f
    
    text=nil
    text=f.down:CreateTexture(nil,"BACKGROUND")
    text:SetAllPoints()
    text:SetTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up")
    text:SetRotation(math.pi/2)
    f.down:SetNormalTexture(text)
    
    text=nil
    text=f.down:CreateTexture(nil,"BACKGROUND")
    text:SetAllPoints()
    text:SetTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Down")
    text:SetRotation(math.pi/2)
    f.down:SetPushedTexture(text)   
    f.down:SetScript("OnClick",moveButtonDownList)
  end    
  
end

local function createChild(self,j,k,pos)
  local para=eF.para.families[j][k]
  if self.families[j] then if self.families[j][k] then self.families[j][k]=nil end else self.families[j]={} end

  --button creation
  self.families[j][k]=CreateFrame("Button",nil,self)
  local f=self.families[j][k]
  if j==1 then f:SetWidth((eF.interface.familiesFrame.famList:GetWidth()-25)) else f:SetWidth((eF.interface.familiesFrame.famList:GetWidth()-25)*0.92) end
  f:SetHeight(familyHeight)
  --f:SetPoint("TOPRIGHT",self,"TOPRIGHT",-4,-5-(familyHeight+2)*(n-1))
  f:SetPoint("TOPRIGHT",self,"TOPRIGHT")
  f:SetBackdrop(bd2)
  f.para=para
  f.familyIndex=j
  f.childIndex=k
  if not pos then table.insert(eF.familyButtonsList,f)else table.insert(eF.familyButtonsList,pos,f) end

  
  
  f:SetScript("OnClick",function(self)
    local tab1=eF.interface.familiesFrame.tabs.tab1
    releaseAllFamilies()
    hideAllFamilyParas()
    eF.activePara=para
    eF.activeButton=self
    eF.activeFamilyIndex=self.familyIndex
    eF.activeChildIndex=self.childIndex
    if self.para.type=="icon" then showChildIconPara() 
    elseif self.para.type=="bar" then showChildBarPara() 
    elseif self.para.type=="border" then showChildBorderPara()
    end
    local tabs=eF.interface.familiesFrame.tabs
    if not tabs:IsShown() then tabs:Show() end
    tab1:SetButtonState("PUSHED")
    tab1:Click()
    self:Disable()
    end)


  if j==1 then
  


    -- normal texture
    do
    f.bg=f:CreateTexture(nil,"BACKGROUND")
    f.bg:SetPoint("TOPLEFT",f,"TOPLEFT",3,-3)
    f.bg:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-3,3)
    f.bg:SetColorTexture(0.28,0.2,0.2,1)
    f.bg:SetGradient("vertical",0.5,0.5,0.5,0.8,0.8,0.8)
    f:SetNormalTexture(f.bg)
    end
     
    --pushed texture
    do
    f.bg=f:CreateTexture(nil,"BACKGROUND")
    f.bg:SetPoint("TOPLEFT",f,"TOPLEFT",3,-3)
    f.bg:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-3,3)
    f.bg:SetColorTexture(0.8,0.4,0.4)
    f.bg:SetGradient("vertical",0.4,0.4,0.4,0.7,0.7,0.7)
    f:SetPushedTexture(f.bg)
    end
     
    --Highlight creation
    do
    f.hl=f:CreateTexture(nil,"BACKGROUND")
    f.hl:SetPoint("BOTTOM",f,"BOTTOM",0,-1)
    f.hl:SetHeight(f:GetHeight()*0.3)
    f.hl:SetWidth(f:GetWidth()*0.8)
    f.hl:SetTexture("Interface\\BUTTONS\\UI-SILVER-BUTTON-HIGHLIGHT")
    f:SetHighlightTexture(f.hl)
    end

    --text creation
    do
    f.text=f:CreateFontString()
    f.text:SetPoint("CENTER")
    f.text:SetFont("Fonts\\ARIALN.ttf",familyListFontSize,fontExtra)
    f.text:SetTextColor(0.9,0.9,0.9)
    f.text:SetText(para.displayName)
    end

    --up and down buttons
    do
      local text
      f.up=CreateFrame("Button",nil,f)
      f.up:SetPoint("TOPRIGHT",f,"TOPRIGHT",-1,0)
      f.up:SetSize(f:GetHeight()/2,f:GetHeight()/2)
      f.up.parentButton=f

      text=f.up:CreateTexture(nil,"BACKGROUND")
      text:SetAllPoints()
      text:SetTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up")
      text:SetRotation(math.pi/2)
      f.up:SetNormalTexture(text)
      
      text=nil
      text=f.up:CreateTexture(nil,"BACKGROUND")
      text:SetAllPoints()
      text:SetTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Down")
      text:SetRotation(math.pi/2)
      f.up:SetPushedTexture(text)   
      f.up:SetScript("OnClick",moveButtonUpList)
      
      f.down=CreateFrame("Button",nil,f)
      f.down:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-1,2)
      f.down:SetSize(f:GetHeight()/2,f:GetHeight()/2)
      f.down.parentButton=f
      
      text=nil
      text=f.down:CreateTexture(nil,"BACKGROUND")
      text:SetAllPoints()
      text:SetTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up")
      text:SetRotation(math.pi/2)
      f.down:SetNormalTexture(text)
      
      text=nil
      text=f.down:CreateTexture(nil,"BACKGROUND")
      text:SetAllPoints()
      text:SetTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Down")
      text:SetRotation(math.pi/2)
      f.down:SetPushedTexture(text)   
      f.down:SetScript("OnClick",moveButtonDownList)
    end

    --move to group button
    do
    local mb
    f.moveButton=CreateFrame("Button",nil,f)
    mb=f.moveButton
    mb:SetPoint("LEFT",f,"LEFT",1,0)
    mb:SetSize(15,f:GetHeight()*0.5)
    mb.buttonPointer=f

    local ftex

    ftex=mb:CreateTexture(nil,"BACKGROUND")
    ftex:SetPoint("LEFT",mb,"LEFT")
    ftex:SetSize(12,12)
    ftex:SetTexture(arrowDownTexture)
    ftex:SetTexCoord(0,1,0,0.5)
    ftex:SetRotation(-math.pi/2)
    mb:SetNormalTexture(ftex)

    ftex=nil
    ftex=mb:CreateTexture(nil,"BACKGROUND")
    ftex:SetPoint("LEFT",mb,"LEFT")
    ftex:SetSize(12,12)
    ftex:SetTexture("Interface\\BUTTONS\\Arrow-Down-Down")
    ftex:SetTexCoord(0,1,0,0.5)
    ftex:SetRotation(-math.pi/2)
    ftex:SetVertexColor(0.5,0.5,0.5)
    mb:SetPushedTexture(ftex)  


    mb:SetScript("OnClick",function(self)
      local cm=self.buttonPointer.confirmMove
      if cm:IsShown() then cm:Hide() else cm:Show() end   
    end)

    end --end of move to group cutton

    --confirm moving frame
    do
      f.confirmMove=CreateFrame("Frame",nil,eF.interface.familiesFrame)
      local cm=f.confirmMove
      cm:SetSize(f:GetWidth()*1.2,f:GetHeight()*2)
      cm:SetPoint("RIGHT",f,"LEFT",-10)
      cm:Hide()
      cm:SetBackdrop(bd2)
      cm:SetFrameLevel(f:GetFrameLevel()+1)
      cm:SetScript("OnShow",function(self) 
        self.groupNameEB:SetText("") 
        if eF.activeConfirmMove then eF.activeConfirmMove:Hide() ; eF.activeConfirmMove=nil end
        eF.activeConfirmMove=self
        self.groupNameEB:SetFocus()
      end)
      
      cm:SetScript("OnHide",function(self)  
        eF.activeConfirmMove=nil 
      end)
      
      cm.bg=cm:CreateTexture(nil,"BACKGROUND")
      cm.bg:SetAllPoints(true)
      cm.bg:SetColorTexture(0,0,0,0.7)
      
      cm.text=cm:CreateFontString(nil,"OVERLAY")
      cm.text:SetFont(font,12)
      cm.text:SetText("Move element to group:")
      cm.text:SetPoint("TOPLEFT",cm,"TOPLEFT",4,-2)
      
      createNumberEB(cm,"groupNameEB",cm)
      local eb=cm.groupNameEB
      eb:SetPoint("TOPLEFT",cm.text,"BOTTOMLEFT",3,-2)
      eb:SetWidth(cm:GetWidth()*0.8)
      eb:SetScript("OnEnterPressed",function(self) self:ClearFocus() end)
      
      cm.confirmButton=CreateFrame("Button",nil,cm,"UIPanelButtonTemplate")
      local cmcb=cm.confirmButton
      cmcb.ebPointer=eb
      cmcb.parentPointer=cm
      cmcb.buttonPointer=f
      cmcb:SetText("Confirm")
      cmcb:SetPoint("BOTTOMLEFT",cm,"BOTTOMLEFT",2,2)
      cmcb:SetWidth(60)
      cmcb:SetScript("OnClick",function(self)
      local name=self.ebPointer:GetText()
      if moveOrphanToGroup(self.buttonPointer.familyIndex,self.buttonPointer.childIndex,name) then 
        self.parentPointer:Hide() 
      else      
        self.ebPointer:SetText('"'..name..'" not found')
      end   
      
      end)
      
      cm.cancelButton=CreateFrame("Button",nil,cm,"UIPanelButtonTemplate")
      local clb=cm.cancelButton
      clb.parentPointer=cm
      clb:SetText("Cancel")
      clb:SetPoint("LEFT",cmcb,"RIGHT",2,0)
      clb:SetWidth(60)
      clb:SetScript("OnClick",function(self)  self.parentPointer:Hide()   end)
      
    end --end of confirm moving frame

  else --else of if j==1
    f.collapsible=true
    local bPos=eF.posInFamilyButtonsList(j)
    local grpButton=eF.familyButtonsList[bPos]
    if grpButton then f.collapsed=grpButton.elementsCollapsed end
    
    -- normal texture
    do
    f.bg=f:CreateTexture(nil,"BACKGROUND")
    f.bg:SetPoint("TOPLEFT",f,"TOPLEFT",3,-3)
    f.bg:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-3,3)
    f.bg:SetColorTexture(0.15,0.22,0.4,1)
    f.bg:SetGradient("vertical",0.5,0.5,0.5,0.8,0.8,0.8)
    f:SetNormalTexture(f.bg)
    end
     
    --pushed texture
    do
    f.bg=f:CreateTexture(nil,"BACKGROUND")
    f.bg:SetPoint("TOPLEFT",f,"TOPLEFT",3,-3)
    f.bg:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-3,3)
    f.bg:SetColorTexture(0.32,0.51,0.8)
    f.bg:SetGradient("vertical",0.4,0.4,0.4,0.7,0.7,0.7)
    f:SetPushedTexture(f.bg)
    end
     
    --Highlight creation
    do
    f.hl=f:CreateTexture(nil,"BACKGROUND")
    f.hl:SetPoint("BOTTOM",f,"BOTTOM",0,-1)
    f.hl:SetHeight(f:GetHeight()*0.3)
    f.hl:SetWidth(f:GetWidth()*0.8)
    f.hl:SetTexture("Interface\\BUTTONS\\UI-SILVER-BUTTON-HIGHLIGHT")
    f:SetHighlightTexture(f.hl)
    end
    
    --text creation
    do
    f.text=f:CreateFontString()
    f.text:SetPoint("CENTER")
    f.text:SetFont("Fonts\\ARIALN.ttf",familyListFontSize,fontExtra)
    f.text:SetTextColor(0.9,0.9,0.9)
    f.text:SetText(para.displayName)
    end
    
    --sideline
    do
      f.sideline=f:CreateTexture(nil,"BACKGROUND")
      local sl=f.sideline
      sl:SetSize(2,f:GetHeight()+4)
      sl:SetPoint("LEFT",f,"LEFT",-6,10)
      sl:SetColorTexture(0.86,0.83,0.4)     
    end --end of sideline
    
    --up and down buttons
    do
      local text
      f.up=CreateFrame("Button",nil,f)
      f.up:SetPoint("TOPRIGHT",f,"TOPRIGHT",-1,0)
      f.up:SetSize(f:GetHeight()/2,f:GetHeight()/2)
      f.up.parentButton=f

      text=f.up:CreateTexture(nil,"BACKGROUND")
      text:SetAllPoints()
      text:SetTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up")
      text:SetRotation(math.pi/2)
      f.up:SetNormalTexture(text)
      
      text=nil
      text=f.up:CreateTexture(nil,"BACKGROUND")
      text:SetAllPoints()
      text:SetTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Down")
      text:SetRotation(math.pi/2)
      f.up:SetPushedTexture(text)   
      --f.up:SetScript("OnClick",moveButtonUpList) NYI
      
      f.down=CreateFrame("Button",nil,f)
      f.down:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-1,2)
      f.down:SetSize(f:GetHeight()/2,f:GetHeight()/2)
      f.down.parentButton=f
      
      text=nil
      text=f.down:CreateTexture(nil,"BACKGROUND")
      text:SetAllPoints()
      text:SetTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up")
      text:SetRotation(math.pi/2)
      f.down:SetNormalTexture(text)
      
      text=nil
      text=f.down:CreateTexture(nil,"BACKGROUND")
      text:SetAllPoints()
      text:SetTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Down")
      text:SetRotation(math.pi/2)
      f.down:SetPushedTexture(text)   
      --f.down:SetScript("OnClick",moveButtonDownList) NYI
    end
    
    --move to group button
    do
    local mb
    f.moveButton=CreateFrame("Button",nil,f)
    mb=f.moveButton
    mb:SetPoint("LEFT",f,"LEFT",1,0)
    mb:SetSize(15,f:GetHeight()*0.5)
    mb.buttonPointer=f
    
    local ftex
   
    ftex=mb:CreateTexture(nil,"BACKGROUND")
    ftex:SetPoint("LEFT",mb,"LEFT")
    ftex:SetSize(12,12)
    ftex:SetTexture(arrowDownTexture)
    ftex:SetTexCoord(0,1,0,0.5)
    ftex:SetRotation(-math.pi/2)
    mb:SetNormalTexture(ftex)
    
    ftex=nil
    ftex=mb:CreateTexture(nil,"BACKGROUND")
    ftex:SetPoint("LEFT",mb,"LEFT")
    ftex:SetSize(12,12)
    ftex:SetTexture("Interface\\BUTTONS\\Arrow-Down-Down")
    ftex:SetTexCoord(0,1,0,0.5)
    ftex:SetRotation(-math.pi/2)
    ftex:SetVertexColor(0.5,0.5,0.5)
    mb:SetPushedTexture(ftex)  
    
    
    mb:SetScript("OnClick",function(self)
      makeOrphan(self.buttonPointer.familyIndex,self.buttonPointer.childIndex)
    end)
    
    end --end of move to group cutton
      
  end

  local sc=eF.interface.familiesFrame.famList.scrollChild
  sc:updateFamilyButtonsIndexList()  
   
end

local function createGroup(self,n,pos)

  local para=eF.para.families[n]
  if self.families[n] then self.families[n]=nil end
  
  --button creationchr
  self.families[n]=CreateFrame("Button",nil,self)
  local f=self.families[n]
  f:SetWidth(eF.interface.familiesFrame.famList:GetWidth()-25)
  f:SetHeight(familyHeight)
  f:SetPoint("TOPRIGHT",self,"TOPRIGHT")
  f:SetBackdrop(bd2)
  f.para=para
  f.familyIndex=n
  f.group=true
  f.elementsCollapsed=true
  
  if not pos then table.insert(eF.familyButtonsList,f) else table.insert(eF.familyButtonsList,pos,f) end
  
  f:SetScript("OnClick",function(self)
    local tab1=eF.interface.familiesFrame.tabs.tab1
    releaseAllFamilies()
    hideAllFamilyParas()
    eF.activePara=para
    eF.activeButton=self
    eF.activeFamilyIndex=self.familyIndex
    if self.para.smart then showSmartFamilyPara() else showDumbFamilyPara() end
    self:Disable()
    
    local tabs=eF.interface.familiesFrame.tabs
    if not tabs:IsShown() then tabs:Show() end
    tab1:SetButtonState("PUSHED")
    tab1:Click()
    end)
  
  f.collapse=function(self) 
    local j=self.familyIndex
    local lst=eF.familyButtonsList
    self.elementsCollapsed= not self.elementsCollapsed
    
    
    local sc=eF.interface.familiesFrame.famList.scrollChild
    sc:setFamilyPositions()
    
  end
  
  local sc=eF.interface.familiesFrame.famList.scrollChild
  sc:updateFamilyButtonsIndexList()
  
  -- normal texture
  do
  f.bg=f:CreateTexture(nil,"BACKGROUND")
  f.bg:SetPoint("TOPLEFT",f,"TOPLEFT",3,-3)
  f.bg:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-3,3)
  f.bg:SetColorTexture(0.15,0.22,0.4,1)
  f.bg:SetGradient("vertical",0.5,0.5,0.5,0.8,0.8,0.8)
  f:SetNormalTexture(f.bg)
  end
   
  --pushed texture
  do
  f.bg=f:CreateTexture(nil,"BACKGROUND")
  f.bg:SetPoint("TOPLEFT",f,"TOPLEFT",3,-3)
  f.bg:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-3,3)
  f.bg:SetColorTexture(0.32,0.51,0.8)
  f.bg:SetGradient("vertical",0.4,0.4,0.4,0.7,0.7,0.7)
  f:SetPushedTexture(f.bg)
  end
   
  --Highlight creation
  do
  f.hl=f:CreateTexture(nil,"BACKGROUND")
  f.hl:SetPoint("BOTTOM",f,"BOTTOM",0,-1)
  f.hl:SetHeight(f:GetHeight()*0.3)
  f.hl:SetWidth(f:GetWidth()*0.8)
  f.hl:SetTexture("Interface\\BUTTONS\\UI-SILVER-BUTTON-HIGHLIGHT")
  f:SetHighlightTexture(f.hl)
  end
  
  --text creation
  do
  f.text=f:CreateFontString()
  f.text:SetPoint("CENTER")
  f.text:SetFont("Fonts\\ARIALN.ttf",familyListFontSize,fontExtra)
  f.text:SetTextColor(0.9,0.9,0.9)
  f.text:SetText(para.displayName)
  end
      
  --up and down buttons    
  do
    local text
    f.up=CreateFrame("Button",nil,f)
    f.up:SetPoint("TOPRIGHT",f,"TOPRIGHT",-1,0)
    f.up:SetSize(f:GetHeight()/2,f:GetHeight()/2)
    f.up.parentButton=f

    text=f.up:CreateTexture(nil,"BACKGROUND")
    text:SetAllPoints()
    text:SetTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up")
    text:SetRotation(math.pi/2)
    f.up:SetNormalTexture(text)
    
    text=nil
    text=f.up:CreateTexture(nil,"BACKGROUND")
    text:SetAllPoints()
    text:SetTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Down")
    text:SetRotation(math.pi/2)
    f.up:SetPushedTexture(text)   
    f.up:SetScript("OnClick",moveButtonUpList)

    
    f.down=CreateFrame("Button",nil,f)
    f.down:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-1,2)
    f.down:SetSize(f:GetHeight()/2,f:GetHeight()/2)
    f.down.parentButton=f
    
    text=nil
    text=f.down:CreateTexture(nil,"BACKGROUND")
    text:SetAllPoints()
    text:SetTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up")
    text:SetRotation(math.pi/2)
    f.down:SetNormalTexture(text)
    
    text=nil
    text=f.down:CreateTexture(nil,"BACKGROUND")
    text:SetAllPoints()
    text:SetTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Down")
    text:SetRotation(math.pi/2)
    f.down:SetPushedTexture(text)   
    f.down:SetScript("OnClick",moveButtonDownList) 
  end    
  
  --collapsoid
  do
  local cpd
  f.collapsoid=CreateFrame("Button",nil,f)
  cpd=f.collapsoid
  cpd:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",-1,-1)
  cpd:SetSize(15,f:GetHeight()*0.5)
  cpd.buttonIndex=f
  
  local ftex
 
  ftex=cpd:CreateTexture(nil,"BACKGROUND")
  ftex:SetPoint("BOTTOMLEFT",cpd,"BOTTOMLEFT",2,2)
  ftex:SetTexture(arrowDownTexture)
  ftex:SetTexCoord(0,1,0,0.5)
  ftex:SetSize(12,12)
  cpd:SetNormalTexture(ftex)
  
  ftex=nil
  ftex=cpd:CreateTexture(nil,"BACKGROUND")
  ftex:SetPoint("BOTTOMLEFT",cpd,"BOTTOMLEFT",2,2)
  ftex:SetTexture(arrowDownTexture)
  ftex:SetVertexColor(0.5,0.5,0.5)
  ftex:SetTexCoord(0,1,0,0.5)
  ftex:SetSize(12,12)
  cpd:SetPushedTexture(ftex)  
  
  
  cpd:SetScript("OnClick",function()
    cpd.buttonIndex:collapse()
  end)
  
  
  end --end of collapsoid
  
  
end

local function updateFamilyButtonsIndexList()
  local bl=eF.familyButtonsList
  eF.para.familyButtonsIndexList={}
  local bil=eF.para.familyButtonsIndexList
  
  for i=1,#bl do
    if not bl[i].collapsible then table.insert(bil,{bl[i].familyIndex,bl[i].childIndex}) end
  end
  
end

local function setFamilyPositions(self)
  --f:SetPoint("TOPRIGHT",self,"TOPRIGHT",-4,-5-(familyHeight+2)*(n-1))
  local h=0
  local lst=eF.familyButtonsList
  local insert=table.insert
  local rem=table.remove
  local l={}
  local lc={}
  --make sure gorups and children are in line
  for i=1,#lst do
    if lst[i].collapsible then insert(lc,lst[i]) else insert(l,lst[i]) end
  end
  
  local i=1
  while i<#l+1 do
    if l[i].group then 
      local j=l[i].familyIndex
      local cl=l[i].elementsCollapsed
      for k=#lc,1,-1 do
        local ce=lc[k]
        if (ce) and (ce.familyIndex==j) then insert(l,i+1,ce); rem(lc,k); ce.collapsed=cl end  
      end   
    end
    i=i+1
  end
  
  --hide remaining bastards that were deleted
  for i=1,#lc do lc[i]:Hide() end
  
  --render
  for i=1,#l do
  
    if not l[i].collapsed then
      l[i]:SetPoint("TOPRIGHT",self,"TOPRIGHT",-4,-5-h)
      h=h+l[i]:GetHeight()+2
      if not l[i]:IsShown() then l[i]:Show() end
      
    else
    
      if l[i]:IsShown() then l[i]:Hide() end
      
    end   
  end
  self:SetHeight(h)
  
  eF.familyButtonsList=l
  
end

local function setSFFActiveValues(self)
  local para=eF.activePara
  eF.activeParaWindow=self

  --general
  do
  self.name:SetText(para.displayName)
  local typ=para.type
  if typ=="b" then typ="Blacklist" elseif typ=="w" then typ="Whitelist" end
  self.type:setButtonText(typ)
  
  self.trackType:setButtonText(para.trackType)

  self.ignorePermanents:SetChecked(para.ignorePermanents)
  if para.ignoreDurationAbove then self.ignoreDurationAbove:SetText(para.ignoreDurationAbove) else self.ignoreDurationAbove:SetText("nil") end
  self.ownOnly:SetChecked(para.ownOnly)
  
  end

  --layout
  do 
  self.count:SetText(para.count)
  self.grow:setButtonText(para.grow)
  self.width:SetText(para.width)
  self.height:SetText(para.height)
  self.spacing:SetText(para.spacing)
  end

  --position
  do
  self.xPos:SetText(para.xPos)
  self.yPos:SetText(para.yPos)
  self.anchor:setButtonText(para.anchor)
  end
  
  --icon
  do
  self.iconCB:SetChecked(para.hasTexture)
  if not para.hasTexture then self.iconBlocker1:Show(); self.iconBlocker2:Show() else self.iconBlocker1:Hide(); self.iconBlocker2:Hide() end

  self.smartIcon:SetChecked(para.smartIcon)
  if para.hasTexture then if para.smartIcon then self.iconBlocker2:Show() else self.iconBlocker2:Hide() end end
  
  if para.texture then self.icon:SetText(para.texture);self.icon.pTexture:SetTexture(para.texture) end
  
  
  end

  --list
  do
  if para.arg1 and #para.arg1>0 then
    local temps=para.arg1[1]
    for i=2,#para.arg1 do
      temps=temps.."\n"..para.arg1[i]
    end--end of for i=1,#para.arg1 
    self.list.eb:SetText(temps)
  else
    self.list.eb:SetText("")
  end--end of if#para.arg1>0 else
  
  C_Timer.After(0.05,function() self.list.button:Disable()end );

  end--end of list

  --cdWheel
  do
  self.cdWheel:SetChecked(para.cdWheel)
  if not para.cdWheel then self.iconBlocker3:Show() else self.iconBlocker3:Hide() end
  self.cdReverse:SetChecked(para.cdReverse)
  end --end of cdWheel

  --border
  do
  self.hasBorder:SetChecked(para.hasBorder)
  if not para.hasBorder then self.iconBlocker4:Show() else self.iconBlocker4:Hide() end
  self.borderType:setButtonText(para.borderType)
  end --end of border

  --text1
  do
  self.hasText1:SetChecked(para.hasText)
  if not para.hasText then self.iconBlocker5:Show() else self.iconBlocker5:Hide() end
  self.textType1:setButtonText(self.textType)
  
  self.textColor1.thumb:SetVertexColor(para.textR,para.textG,para.textB)
  self.textDecimals1:SetText(para.textDecimals or 0)

  self.fontSize1:SetText(para.textSize or 12)
  self.textA1:SetText(para.textA or 1)
  
  local font=ssub(para.textFont or "Fonts\\FRIZQT__.ttf",7,-5)
  self.textFont1:setButtonText(font)
  self.textAnchor1:setButtonText(para.textAnchor)
  
  self.textXOS1:SetText(para.textXOS or 0)
  self.textYOS1:SetText(para.textYOS or 0)
  
  end --end of text1
  
  --text2
  do
  self.hasText2:SetChecked(para.hasText2)
  if not para.hasText2 then self.iconBlocker6:Show() else self.iconBlocker6:Hide() end
  self.text2Type:setButtonText(para.text2Type)

  
  self.text2Color.thumb:SetVertexColor(para.text2R or 1,para.text2G or 1,para.text2B or 1)
  self.text2Decimals:SetText(para.text2Decimals or 0)

  self.fontSize2:SetText(para.text2Size or 12)
  self.text2A:SetText(para.text2A or 1)
  
  local font=ssub(para.text2Font or "Fonts\\FRIZQT__.ttf",7,-5)
  self.text2Font:setButtonText(font)
  self.text2Anchor:setButtonText(para.text2Anchor)
  
  self.text2XOS:SetText(para.text2XOS or 0)
  self.text2YOS:SetText(para.text2YOS or 0)
  
  
  end --end of text2
  
  
end --end of setSFFActiveValues func  

local function setCIFActiveValues(self)
  local para=eF.activePara
  eF.activeParaWindow=self
  --general
  do
  self.name:SetText(para.displayName)
  self.trackType:setButtonText(para.trackType)

  if para.trackType=="Static" then self.iconBlocker6:Show() else self.iconBlocker6:Hide() end

  self.trackBy:setButtonText(para.trackBy)
  
  if para.arg1 then self.spell:SetText(para.arg1) else self.spell:SetText("") end
  
  self.ownOnly:SetChecked(para.ownOnly)
  
  end

  --layout
  do 
  self.width:SetText(para.width)
  self.height:SetText(para.height)
  self.xPos:SetText(para.xPos)
  self.yPos:SetText(para.yPos)
  self.anchor:setButtonText(para.anchor)
  
  end
  
  --icon
  do
  self.iconCB:SetChecked(para.hasTexture)
  if not para.hasTexture then self.iconBlocker1:Show(); self.iconBlocker2:Show() else self.iconBlocker1:Hide(); self.iconBlocker2:Hide() end

  self.smartIcon:SetChecked(para.smartIcon)
  if para.hasTexture then if para.smartIcon then self.iconBlocker2:Show() else self.iconBlocker2:Hide() end end
  
  if para.texture then self.icon:SetText(para.texture);self.icon.pTexture:SetTexture(para.texture) end
  self.textureColor.thumb:SetVertexColor(para.textureR,para.textureG,para.textureB)
  

  
  end

  --cdWheel
  do
  self.cdWheel:SetChecked(para.cdWheel)
  if not para.cdWheel then self.iconBlocker3:Show() else self.iconBlocker3:Hide() end
  self.cdReverse:SetChecked(para.cdReverse)
  end --end of cdWheel

  --border
  do
  self.hasBorder:SetChecked(para.hasBorder)
  if not para.hasBorder then self.iconBlocker4:Show() else self.iconBlocker4:Hide() end
  self.borderType:setButtonText(para.borderType)
  end --end of border

  --text1
  do
  self.hasText1:SetChecked(para.hasText)
  if not para.hasText then self.iconBlocker5:Show() else self.iconBlocker5:Hide()  end
  self.textType1:setButtonText(para.textType)
  
  self.textColor1.thumb:SetVertexColor(para.textR,para.textG,para.textB)
  self.textDecimals1:SetText(para.textDecimals or 0)

  self.fontSize1:SetText(para.textSize or 12)
  self.textA1:SetText(para.textA or 1)
  
  local font=ssub(para.textFont or "Fonts\\FRIZQT__.ttf",7,-5)
  self.textFont1:setButtonText(font)
  self.textAnchor1:setButtonText(para.textAnchor)
  
  self.textXOS1:SetText(para.textXOS or 0)
  self.textYOS1:SetText(para.textYOS or 0)
  
  
  end --end of text1
  
  --text2
  do
  self.hasText2:SetChecked(para.hasText2)
  if not para.hasText2 then self.iconBlocker7:Show() else self.iconBlocker7:Hide()  end
  self.text2Type:setButtonText(para.text2Type)
  
  self.text2Color.thumb:SetVertexColor(para.text2R or 1,para.text2G or 1,para.text2B or 1)
  self.text2Decimals:SetText(para.text2Decimals or 0)

  self.fontSize2:SetText(para.text2Size or 12)
  self.text2A:SetText(para.text2A or 1)
  
  local font=ssub(para.text2Font or "Fonts\\FRIZQT__.ttf",7,-5)
  self.text2Font:setButtonText(font)
  self.text2Anchor:setButtonText(para.text2Anchor)
  
  self.text2XOS:SetText(para.text2XOS or 0)
  self.text2YOS:SetText(para.text2YOS or 0)

  end --end of text2
  
  --extra
  do
  self.checkOn:setButtonText(para.extra1checkOn or "")
  self.funcbox.eb:SetText(para.extra1string or "")
  C_Timer.After(0.05,function() self.funcbox.button:Disable()end );
  end
  
end --end of setCIFActiveValues func 

local function setCBOFActiveValues(self)
  local para=eF.activePara
  eF.activeParaWindow=self
  
  --general
  do
  self.name:SetText(para.displayName)
  
  self.trackType:setButtonText(para.trackType)
  
  if para.trackType=="Static" then self.iconBlocker1:Show() else self.iconBlocker1:Hide() end

  self.trackBy:setButtonText(para.trackBy)
  
  if para.arg1 then self.spell:SetText(para.arg1) else self.spell:SetText("") end
  
  self.ownOnly:SetChecked(para.ownOnly)
  
  self.borderSize:SetText(para.borderSize or 2)
  self.borderAlpha:SetText(para.borderA or 1)

  self.borderColor.thumb:SetVertexColor(para.borderR,para.borderG,para.borderB)
  
  end
  
end --end of setCIFActiveValues func 

local function setLoadActiveValues(self)
  local para=eF.activePara
  local isInList=eF.isInList
  local Classes=eF.Classes
  local ROLES=eF.ROLES
  
  --loadAlways
  self.loadAlways:SetChecked(para.loadAlways)
  if para.loadAlways then self.iconBlocker1:Show() else self.iconBlocker1:Hide() end
  
  --load unit classes + player classes
  self.unitClassLoadAlways:SetChecked(para.unitClassLoadAlways)
  if para.unitClassLoadAlways then self.iconBlocker2:Show() else self.iconBlocker2:Hide() end
  self.playerClassLoadAlways:SetChecked(para.playerClassLoadAlways)
  if para.playerClassLoadAlways then self.iconBlocker3:Show() else self.iconBlocker3:Hide() end
  
  for i=1,#Classes do
    local class=Classes[i]
    local unitClass="unit"..class
    local playerClass="player"..class
    self[unitClass]:SetChecked(isInList(class,para.loadUnitClassList))
    self[playerClass]:SetChecked(isInList(class,para.loadPlayerClassList)) 
  end
  
  --load unit roles + player roles
  self.unitRoleLoadAlways:SetChecked(para.unitRoleLoadAlways)
  if para.unitRoleLoadAlways then self.iconBlocker5:Show() else self.iconBlocker5:Hide() end
  self.playerRoleLoadAlways:SetChecked(para.playerRoleLoadAlways)
  if para.playerRoleLoadAlways then self.iconBlocker4:Show() else self.iconBlocker4:Hide() end
  
  for i=1,#ROLES do
    local role=ROLES[i]
    local unitRole="unit"..role
    local playerRole="player"..role
    
    self[unitRole]:SetChecked(isInList(role,para.loadUnitRoleList))
    self[playerRole]:SetChecked(isInList(role,para.loadPlayerRoleList)) 
  end
  
  --instance loadInstanceList
  self.instanceLoadAlways:SetChecked(para.instanceLoadAlways)
  if para.instanceLoadAlways then self.iconBlocker6:Show() else self.iconBlocker6:Hide() end
  
  if para.loadInstanceList and #para.loadInstanceList>0 then
    local temps=para.loadInstanceList[1]
    for i=2,#para.loadInstanceList do
      temps=temps.."\n"..para.loadInstanceList[i]
    end--end of for i=1,#para.loadInstanceList 
    self.loadInstanceList.eb:SetText(temps)
  else
    self.loadInstanceList.eb:SetText("")
  end--end of if#para.loadInstanceList>0 else
  
  C_Timer.After(0.05,function() self.loadInstanceList.button:Disable() end);
  
  
  --encounter loadInstanceList
  self.encounterLoadAlways:SetChecked(para.encounterLoadAlways)
  if para.encounterLoadAlways then self.iconBlocker7:Show() else self.iconBlocker7:Hide() end
  
  if para.loadEncounterList and #para.loadEncounterList>0 then
    local temps=para.loadEncounterList[1]
    for i=2,#para.loadEncounterList do
      temps=temps.."\n"..para.loadEncounterList[i]
    end--end of for i=1,#para.loadEncounterList 
    self.loadEncounterList.eb:SetText(temps)
  else
    self.loadEncounterList.eb:SetText("")
  end--end of if#para.loadEncounterList>0 else
  
  C_Timer.After(0.05,function() self.loadEncounterList.button:Disable() end);
  
end

local function setCBFActiveValues(self)
  local para=eF.activePara
  eF.activeParaWindow=self
  
  --general
  do
  self.name:SetText(para.displayName)
  self.trackType:setButtonText(para.trackType)
  
    
  self.lFix:SetText(para.lFix or 10)
  self.lMax:SetText(para.lMax or 50)

  self.textureColor.thumb:SetVertexColor(para.textureR,para.textureG,para.textureB)
  self.textureAlpha:SetText(para.textureA or 1)
  self.xPos:SetText(para.xPos)
  self.yPos:SetText(para.yPos)
  self.anchor:setButtonText(para.anchor)
  self.grow:setButtonText(para.grow)

  end
  
  
end

local function setDFFActiveValues(self)
  local para=eF.activePara
  eF.activeParaWindow=self
  
  self.name:SetText(para.displayName)
  
end

local function unitsSaveRaidPosition(self)
  local x,y=self:GetCenter()
  local para=eF.para.units
  local fD=eF.interface.generalFrame.frameDim
  para.xPos=x
  para.yPos=y
  fD.xPos:SetText(math.floor(x))
  fD.yPos:SetText(math.floor(y))
end

local function unitsSavePartyPosition(self)
  local x,y=self:GetCenter()
  local para=eF.para.unitsGroup
  local f=eF.interface.generalFrame.frameDim.fDLazy
  para.xPos=x
  para.yPos=y
  f.xPos:SetText(math.floor(x))
  f.yPos:SetText(math.floor(y))
end

--create main frame
do
eF.interface=CreateFrame("Frame","eFInterface",UIParent)
int=eF.interface
int:SetPoint("LEFT",UIParent,"LEFT",200,0)
int:SetHeight(600)
int:SetWidth(850)
int:SetBackdrop(bd)
int:EnableMouse(true)
int:SetAlpha(1)

int.bg=int:CreateTexture(nil,"BACKGROUND")
int.bg:SetPoint("TOPLEFT",int,"TOPLEFT",5,-5)
int.bg:SetPoint("BOTTOMRIGHT",int,"BOTTOMRIGHT",-5,5)
int.bg:SetColorTexture(0.05,0.05,0.05)

MakeMovable(int)
int:Hide()
int.tgl=frameToggle
int:SetFrameLevel(15)
SLASH_ELFRAMO1="/eF"
SlashCmdList["ELFRAMO"]= function(arg)
  if InCombatLockdown() then return end
  int:tgl()
end

end

--create titleframe + hide button
do
int.titleBox=CreateFrame("Frame","eFTitle",int)
tb=int.titleBox
tb:SetPoint("RIGHT",int,"TOPRIGHT",9,-8)
tb:SetHeight(35)
tb:SetWidth(100)
tb:SetBackdrop(bd)

tb.text=tb:CreateFontString(nil,"OVERLAY")
tb.text:SetPoint("CENTER",tb,"CENTER",2,0)
tb.text:SetFont(font,17,fontExtra)
tb.text:SetTextColor(0.8,0.8,0.1,1)
tb.text:SetText("elFramo")

tb.bg=tb:CreateTexture(nil,"BACKGROUND")
tb.bg:SetPoint("TOPLEFT",tb,"TOPLEFT",5,-5)
tb.bg:SetPoint("BOTTOMRIGHT",tb,"BOTTOMRIGHT",-5,5)
tb.bg:SetColorTexture(218/250*(1/3),165/250*(1/3),32/250*(1/3))

tb.x=CreateFrame("Button","eFxbutton",int)
tb.x:SetPoint("RIGHT",tb,"LEFT",-5,0)
tb.x:SetSize(35,35)
tb.x:SetBackdrop(bd)

local t=tb.x:CreateTexture(nil,"BACKGROUND")
t:SetPoint("CENTER")
t:SetSize(40,40)
t:SetTexture("Interface\\BUTTONS\\UI-Panel-MinimizeButton-Up")
tb.x:SetNormalTexture(t)

t=nil
t=tb.x:CreateTexture(nil,"BACKGROUND")
t:SetPoint("CENTER")
t:SetSize(40,40)
t:SetTexture("Interface\\BUTTONS\\UI-Panel-MinimizeButton-Down")
tb.x:SetPushedTexture(t)

tb.x:SetScript("OnClick",function() eF.interface:Hide()  end)
end

--create header1
do 
int.header1=CreateFrame("Frame","eFHeader",int)
hd1=int.header1
hd1:SetPoint("TOPLEFT",int,"TOPLEFT",15,-25)
hd1:SetPoint("BOTTOMRIGHT",int,"BOTTOMRIGHT",-15,10)
hd1:SetBackdrop(bd)
hd1:SetBackdropColor(0,0,0,0)

hd1.bg=hd1:CreateTexture(nil,"BACKGROUND")
hd1.bg:SetPoint("TOPLEFT",hd1,"TOPLEFT",5,-5)
hd1.bg:SetPoint("BOTTOMRIGHT",hd1,"BOTTOMRIGHT",-5,5)
hd1.bg:SetColorTexture(0.1,0.1,0.1)
end

--create header 1 buttons
do
hd1.button1=CreateFrame("Button","eFHeader1Button1",hd1)
hd1b1=hd1.button1
hd1b1:SetPoint("BOTTOMLEFT",hd1,"TOPLEFT",35,-9)
makeHeader1Button(hd1b1)


hd1.button2=CreateFrame("Button","eFHeader1Button2",hd1)
hd1b2=hd1.button2
hd1b2:SetPoint("BOTTOMLEFT",hd1,"TOPLEFT",140,-9)
makeHeader1Button(hd1b2)
hd1b2.text:SetText("Other stuff")

hd1.button3=CreateFrame("Button","eFHeader1Button3",hd1)
hd1b3=hd1.button3
hd1b3:SetPoint("BOTTOMLEFT",hd1,"TOPLEFT",245,-9)
makeHeader1Button(hd1b3)
hd1b3.text:SetText("Families")
end

--create general settings frame
do
int.generalFrame=CreateFrame("Frame","eFGeneral",hd1)
gf=int.generalFrame
gf:Hide()
hd1b1.relatedFrame=gf
gf:SetAllPoints()

gf.test=gf:CreateFontString(nil,"OVERLAY")
gf.test:SetFont(font,15)
gf.test:SetText("????")
gf.test:SetPoint("CENTER")
end

--UNIT FRAME
do
  gf.frameDimScrollFrame=CreateFrame("ScrollFrame","egframeDimScrollFrame",gf,"UIPanelScrollFrameTemplate")
  local fdsf=gf.frameDimScrollFrame
  fdsf:SetPoint("TOPLEFT",gf,"TOPLEFT",gf:GetWidth()*0.03,-30)
  fdsf:SetPoint("BOTTOMRIGHT",gf,"BOTTOMRIGHT",-gf:GetWidth()*0.03,30)
  fdsf:SetClipsChildren(true)
  fdsf:SetScript("OnMouseWheel",ScrollFrame_OnMouseWheel)
  
  fdsf.border=CreateFrame("Frame",nil,gf)
  fdsf.border:SetPoint("TOPLEFT",fdsf,"TOPLEFT",-5,5)
  fdsf.border:SetPoint("BOTTOMRIGHT",fdsf,"BOTTOMRIGHT",5,-5)
  fdsf.border:SetBackdrop(bd2)
  gf.frameDim=CreateFrame("Frame","eFframeDimChild",gf)
  local fD=gf.frameDim
  fD:SetPoint("TOP",fdsf,"TOP",0,-20)
  fD:SetWidth(fdsf:GetWidth()*0.8)
  fD:SetHeight(fdsf:GetHeight()*1.5)
 
  fdsf.ScrollBar:ClearAllPoints()
  fdsf.ScrollBar:SetPoint("TOPRIGHT",fdsf,"TOPRIGHT",-6,-18)
  fdsf.ScrollBar:SetPoint("BOTTOMLEFT",fdsf,"BOTTOMRIGHT",-16,18)
  fdsf.ScrollBar.bg=fdsf.ScrollBar:CreateTexture(nil,"BACKGROUND")
  fdsf.ScrollBar.bg:SetAllPoints()
  fdsf.ScrollBar.bg:SetColorTexture(0,0,0,0.5)
  
  fdsf:SetScrollChild(fD)
  
  fdsf.bg=fdsf:CreateTexture(nil,"BACKGROUND")
  fdsf.bg:SetAllPoints()
  fdsf.bg:SetColorTexture(0.07,0.07,0.07,1)
  
-------------------RAID FRAME
--header/title
do
fD.mainTitle=fD:CreateFontString(nil,"OVERLAY")
local t=fD.mainTitle
t:SetFont(titleFont,15,titleFontExtra)
t:SetTextColor(titleFontColor2[1],titleFontColor2[2],titleFontColor2[3])
t:SetText("RAID FRAME")
t:SetPoint("TOPLEFT",fD,"TOPLEFT",8,-8)

fD.mainTitleSpacer=fD:CreateTexture(nil,"BACKGROUND")
local tS=fD.mainTitleSpacer
tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
tS:SetHeight(9)
tS:SetTexture(titleSpacer)
tS:SetWidth(fD:GetWidth()*0.95)
tS:SetVertexColor(titleFontColor2[1],titleFontColor2[2],titleFontColor2[3])
end 

--Dimensions
do 
fD.title=fD:CreateFontString(nil,"OVERLAY")
local t=fD.title
t:SetFont(titleFont,15,titleFontExtra)
t:SetTextColor(1,1,1)
t:SetText("Dimensions")
t:SetPoint("TOPLEFT",fD,"TOPLEFT",8,-48)

fD.titleSpacer=fD:CreateTexture(nil,"BACKGROUND")
local tS=fD.titleSpacer
tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
tS:SetHeight(8)
tS:SetTexture(titleSpacer)
tS:SetWidth(110)

createNumberEB(fD,"ebHeight",fD)
fD.ebHeight.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
fD.ebHeight.text:SetText("Height:")
fD.ebHeight:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
h=self:GetNumber()
if h==0 then h=eF.para.units.height; self:SetText(h)
else eF.para.units.height=h; eF.units:updateAllParas(); eF.layout:update() end
end)

createNumberEB(fD,"ebWidth",fD)
fD.ebWidth.text:SetPoint("RIGHT",fD.ebHeight.text,"RIGHT",0,-ySpacing)
--fD.ebWidth:SetText(eF.para.units.width) ebWidth:SetText(eF.para.units.width)
fD.ebWidth.text:SetText("Width:")
fD.ebWidth:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
w=self:GetNumber()
if w==0 then w=eF.para.units.width; self:SetText(w)
else eF.para.units.width=w; eF.units:updateAllParas(); eF.layout:update() end
end)

end

--Health Frame
do
fD.title2=fD:CreateFontString(nil,"OVERLAY")
local t=fD.title2
t:SetFont(titleFont,15,titleFontExtra)
t:SetTextColor(1,1,1)
t:SetText("Health Frame")
t:SetPoint("LEFT",fD.title,"LEFT",145,0)

fD.titleSpacer2=fD:CreateTexture(nil,"BACKGROUND")
local tS=fD.titleSpacer2
tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
tS:SetHeight(8)
tS:SetTexture(titleSpacer)
tS:SetWidth(130)

createCB(fD,"hClassColor",fD)
fD.hClassColor.text:SetPoint("TOPLEFT",tS,"TOPLEFT",30,-initSpacing)
--fD.hColor:SetText("byClass")
fD.hClassColor.text:SetText("Class color:")
fD.hClassColor:SetScript("OnClick",function(self)
  local ch=self:GetChecked()
  self:SetChecked(ch)
  fD.hColor.blocked=ch
  eF.para.units.byClassColor=ch
  if ch then fD.hColor.blocker:Show() else fD.hColor.blocker:Hide() end 
  eF.units.byClassColor=ch
  eF.units:updateAllParas()
end)

createCS(fD,"hColor",fD)
fD.hColor.text:SetPoint("RIGHT",fD.hClassColor.text,"RIGHT",0,-ySpacing)
fD.hColor.text:SetText("Color:")
fD.hColor.getOldRGBA=function(self)
  local r=eF.para.units.hpR
  local g=eF.para.units.hpG
  local b=eF.para.units.hpB
  return r,g,b
end

fD.hColor.opacityFunc=function()
  local r,g,b=ColorPickerFrame:GetColorRGB()
  local a=OpacitySliderFrame:GetValue()
  fD.hColor.thumb:SetVertexColor(r,g,b)
  eF.para.units.hpR=r
  eF.para.units.hpG=g
  eF.para.units.hpB=b
  eF.units.hpR=r
  eF.units.hpG=g
  eF.units.hpB=b
  eF.units:updateAllParas()
end

fD.hColor.blocker=CreateFrame("Frame",nil,fD)
local hCB=fD.hColor.blocker
hCB:SetFrameLevel(fD.hColor:GetFrameLevel()+1)
hCB:SetPoint("TOPRIGHT",fD.hColor,"TOPRIGHT",2,2)
hCB:SetHeight(22)
hCB:SetWidth(120)
hCB.texture=hCB:CreateTexture(nil,"OVERLAY")
hCB.texture:SetAllPoints()
hCB.texture:SetColorTexture(0.07,0.07,0.07,0.4)


createNewDD(fD,"hDir",fD,50)
fD.hDir.text:SetPoint("RIGHT",fD.hColor.text,"RIGHT",0,-ySpacing)
fD.hDir.text:SetText("Orientation:")
fD.hDir:SetPoint("LEFT",fD.hDir.text,"BOTTOMRIGHT",-12,10) --no clue why but this one was shifted

local lf=function(self)
     eF.para.units.healthGrow=self.arg
     eF.units:updateAllParas()
end

for i=1,#eF.orientations do
  local v=eF.orientations[i]
  fD.hDir:addButton(v,lf,v)
end

createNumberEB(fD,"gradStart",fD)
fD.gradStart.text:SetPoint("RIGHT",fD.hDir.text,"RIGHT",0,-ySpacing)
fD.gradStart.text:SetText("Start grad.:")
fD.gradStart:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
n=self:GetNumber()
eF.para.units.hpGrad1R=n;
eF.para.units.hpGrad1G=n;
eF.para.units.hpGrad1B=n;
eF.units.hpGrad1R=n;
eF.units.hpGrad1G=n;
eF.units.hpGrad1B=n;
eF.units:updateAllParas()
end)

createNumberEB(fD,"gradFinal",fD)
fD.gradFinal.text:SetPoint("RIGHT",fD.gradStart.text,"RIGHT",0,-ySpacing)
fD.gradFinal.text:SetText("Final grad.:")
fD.gradFinal:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
n=self:GetNumber()
eF.para.units.hpGrad2R=n;
eF.para.units.hpGrad2G=n;
eF.para.units.hpGrad2B=n;
eF.units.hpGrad2R=n;
eF.units.hpGrad2G=n;
eF.units.hpGrad2B=n;
eF.units:updateAllParas()
end)

end--end of Health Frame

--Name
do
fD.title3=fD:CreateFontString(nil,"OVERLAY")
local t=fD.title3
t:SetFont(titleFont,15,titleFontExtra)
t:SetTextColor(1,1,1)
t:SetText("Name")
t:SetPoint("LEFT",fD.title2,"LEFT",180,0)

fD.titleSpacer3=fD:CreateTexture(nil,"BACKGROUND")
local tS=fD.titleSpacer3
tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
tS:SetHeight(8)
tS:SetTexture(titleSpacer)
tS:SetWidth(90)


createCB(fD,"nClassColor",fD)
fD.nClassColor.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
--fD.nColor:SetText("byClass")
fD.nClassColor.text:SetText("Class color:")
fD.nClassColor:SetScript("OnClick",function(self)
  local ch=self:GetChecked()
  self:SetChecked(ch)
  fD.nColor.blocked=ch
  eF.para.units.textColorByClass=ch
  eF.units.textColorByClass=ch
  if ch then fD.nColor.blocker:Show() else fD.nColor.blocker:Hide() end 
  eF.units:updateAllParas()
end)


createCS(fD,"nColor",fD)
fD.nColor.text:SetPoint("RIGHT",fD.nClassColor.text,"RIGHT",0,-ySpacing)
fD.nColor.text:SetText("Color:")
fD.nColor.getOldRGBA=function(self)
  local r=eF.para.units.textR
  local g=eF.para.units.textG
  local b=eF.para.units.textB
  return r,g,b
end

fD.nColor.opacityFunc=function()
  local r,g,b=ColorPickerFrame:GetColorRGB()
  local a=OpacitySliderFrame:GetValue()
  fD.nColor.thumb:SetVertexColor(r,g,b)
  eF.para.units.textR=r
  eF.para.units.textG=g
  eF.para.units.textB=b
  eF.units.textR=r
  eF.units.textG=g
  eF.units.textB=b
  eF.units:updateAllParas()
end

fD.nColor.blocker=CreateFrame("Frame",nil,fD)
local nCB=fD.nColor.blocker
nCB:SetFrameLevel(fD.nColor:GetFrameLevel()+1)
nCB:SetPoint("TOPRIGHT",fD.nColor,"TOPRIGHT",2,2)
nCB:SetHeight(22)
nCB:SetWidth(120)
nCB.texture=nCB:CreateTexture(nil,"OVERLAY")
nCB.texture:SetAllPoints()
nCB.texture:SetColorTexture(0.07,0.07,0.07,0.4)

createNumberEB(fD,"nMax",fD)
fD.nMax.text:SetPoint("RIGHT",fD.nColor.text,"RIGHT",0,-ySpacing)
fD.nMax.text:SetText("Characters:")
fD.nMax:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
n=self:GetNumber()
if n==0 then n=eF.para.units.textLim; self:SetText(n)
else eF.para.units.textLim=n; eF.units.textLim=n; eF.units:updateAllParas() end
end)

createNumberEB(fD,"nSize",fD)
fD.nSize.text:SetPoint("RIGHT",fD.nMax.text,"RIGHT",0,-ySpacing)
fD.nSize.text:SetText("Font size:")
fD.nSize:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
n=self:GetNumber()
if n==0 then n=eF.para.units.textSize; self:SetText(n)
else eF.para.units.textSize=n; eF.units.textSize=n; eF.units:updateAllParas() end
end)


createNumberEB(fD,"nAlpha",fD)
fD.nAlpha.text:SetPoint("RIGHT",fD.nSize.text,"RIGHT",0,-ySpacing)
fD.nAlpha.text:SetText("Alpha:")
fD.nAlpha:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
a=self:GetNumber()
eF.para.units.textA=a; eF.units.textA=a; eF.units:updateAllParas()
end)


createNewDD(fD,"nFont",fD)
fD.nFont.text:SetPoint("RIGHT",fD.nAlpha.text,"RIGHT",0,-ySpacing)
fD.nFont.text:SetText("Font:")

local lf=function(self)
     eF.para.units.textFont=self.arg
     eF.units:updateAllParas()
end

for i=1,#eF.fonts do
  local v=eF.fonts[i]
  local font="Fonts\\"..v..".ttf"
  fD.nFont:addButton(v,lf,font)
end


createNewDD(fD,"nPos",fD)
fD.nPos.text:SetPoint("RIGHT",fD.nFont.text,0,-ySpacing)
fD.nPos.text:SetText("Position:")
local lf=function(self)
     eF.para.units.textPos=self.arg
     eF.units:updateAllParas()
end

for i=1,#eF.positions do
  local v=eF.positions[i]
  fD.nPos:addButton(v,lf,v)
end


createNumberEB(fD,"textXOS",fD)
fD.textXOS.text:SetPoint("RIGHT",fD.nPos.text,"RIGHT",0,-ySpacing)
fD.textXOS.text:SetText("X Offset:")
fD.textXOS:SetWidth(30)
fD.textXOS:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
x=self:GetText()
x=tonumber(x)
if not x then x=eF.activePara.textXOS; self:SetText(x); 
else 
  eF.para.units.textXOS=x;
end
  eF.units:updateAllParas()
end)

createNumberEB(fD,"textYOS",fD)
fD.textYOS.text:SetPoint("RIGHT",fD.textXOS.text,"RIGHT",0,-ySpacing)
fD.textYOS.text:SetText("Y Offset:")
fD.textYOS:SetWidth(30)
fD.textYOS:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
x=self:GetText()
x=tonumber(x)
if not x  then x=eF.activePara.textYOS; self:SetText(x)
else 
  eF.para.units.textYOS=x;
end
  eF.units:updateAllParas()
end)

end--end of Name

--Border
do
fD.title4=fD:CreateFontString(nil,"OVERLAY")
local t=fD.title4
t:SetFont(titleFont,15,titleFontExtra)
t:SetTextColor(1,1,1)
t:SetText("Border")
t:SetPoint("LEFT",fD.title,"LEFT",0,-85)

fD.titleSpacer4=fD:CreateTexture(nil,"BACKGROUND")
local tS=fD.titleSpacer4
tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
tS:SetHeight(8)
tS:SetTexture(titleSpacer)
tS:SetWidth(fD.titleSpacer:GetWidth())

createCS(fD,"bColor",fD)
fD.bColor.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
fD.bColor.text:SetText("Color:")
fD.bColor.getOldRGBA=function(self)
  local r=eF.para.units.borderR
  local g=eF.para.units.borderG
  local b=eF.para.units.borderB
  return r,g,b
end

fD.bColor.opacityFunc=function()
  local r,g,b=ColorPickerFrame:GetColorRGB()
  local a=OpacitySliderFrame:GetValue()
  fD.bColor.thumb:SetVertexColor(r,g,b)
  eF.para.units.borderR=r
  eF.para.units.borderG=g
  eF.para.units.borderB=b
  for i=1,45 do
    local id
    if i<6 then id=eF.partyLoop[i] else id=eF.raidLoop[i-5] end
    eF.units[id]:updateBorders();
  end
end


createNumberEB(fD,"bWid",fD)
fD.bWid.text:SetPoint("RIGHT",fD.bColor.text,"RIGHT",0,-ySpacing)
fD.bWid.text:SetText("Width:")
fD.bWid:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
w=self:GetNumber()
eF.para.units.borderSize=w
eF.units.borderSize=w
for i=1,45 do
  local id
  if i<6 then id=eF.partyLoop[i] else id=eF.raidLoop[i-5] end
  eF.units[id]:updateBorders();
end
end)

end--end of border

--layout
do 
fD.title5=fD:CreateFontString(nil,"OVERLAY")
local t=fD.title5
t:SetFont(titleFont,15,titleFontExtra)
t:SetTextColor(1,1,1)
t:SetText("Layout")
t:SetPoint("TOPLEFT",fD.title3,"TOPLEFT",200,0)

fD.titleSpacer5=fD:CreateTexture(nil,"BACKGROUND")
local tS=fD.titleSpacer5
tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
tS:SetHeight(8)
tS:SetTexture(titleSpacer)
tS:SetWidth(110)

createNewDD(fD,"grow1",fD,50)
fD.grow1.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
fD.grow1.text:SetText("Grows:")
local lf=function(self)
     eF.para.units.grow1=self.arg
     eF.units:updateAllParas()
end

for i=1,#eF.orientations do
  local v=eF.orientations[i]
  fD.grow1:addButton(v,lf,v)
end


createNewDD(fD,"grow2",fD,50)
fD.grow2.text:SetPoint("RIGHT",fD.grow1.text,"RIGHT",0,-ySpacing)
fD.grow2.text:SetText("then:")
local lf=function(self)
     eF.para.units.grow2=self.arg
     eF.units:updateAllParas()
end
for i=1,#eF.orientations do
  local v=eF.orientations[i]
  fD.grow2:addButton(v,lf,v)
end

createNumberEB(fD,"spacing",fD)
fD.spacing.text:SetPoint("RIGHT",fD.grow2.text,"RIGHT",0,-ySpacing)
fD.spacing.text:SetText("Width:")
fD.spacing:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
w=self:GetText()
if (not w) or w=="" or not (tonumber(w)) then w=eF.para.units.spacing; self:SetText(w)
else eF.para.units.spacing=w; eF.units:updateAllParas(); eF.layout:update() end
end)


createNumberEB(fD,"maxInLine",fD)
fD.maxInLine.text:SetPoint("RIGHT",fD.spacing.text,"RIGHT",0,-ySpacing)
fD.maxInLine.text:SetText("Max in line:")
fD.maxInLine:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
w=self:GetNumber()
if (not w) or w==0 then w=eF.para.units.maxInLine; self:SetText(w)
else eF.para.units.maxInLine=math.floor(w); eF.units:updateAllParas(); eF.layout:update() end
end)


createCB(fD,"byGroup",fD)
fD.byGroup.text:SetPoint("RIGHT",fD.maxInLine.text,"RIGHT",0,-ySpacing)
fD.byGroup.text:SetText("Sort by group:")
fD.byGroup:SetScript("OnClick",function(self)
  local ch=self:GetChecked()
  self:SetChecked(ch)
  eF.para.units.byGroup=ch
  eF.layout:update()
  eF.units:updateAllParas()
end)

createNumberEB(fD,"xPos",fD)
fD.xPos.text:SetPoint("RIGHT",fD.byGroup.text,"RIGHT",0,-ySpacing)
fD.xPos.text:SetText("X Offset:")
fD.xPos:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
w=self:GetNumber()
if (not w) then w=eF.para.units.xPos; self:SetText(w)
else eF.para.units.xPos=w; eF.units:updateAllParas(); eF.layout:update() end
end)

createNumberEB(fD,"yPos",fD)
fD.yPos.text:SetPoint("RIGHT",fD.xPos.text,"RIGHT",0,-ySpacing)
fD.yPos.text:SetText("Y Offset:")
fD.yPos:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
w=self:GetNumber()
if (not w) then w=eF.para.units.yPos; self:SetText(w)
else eF.para.units.yPos=w; eF.units:updateAllParas(); eF.layout:update() end
end)


fD.unlockUnitsButton=CreateFrame("Button",nil,fD,"UIPanelButtonTemplate")
local uub=fD.unlockUnitsButton
uub:SetText("(Un)lock")
uub:SetPoint("LEFT",fD.yPos,"RIGHT",10,10)
uub:SetWidth(80)
uub:SetScript("OnClick",function() 
  local u=eF.units
  local x,y=eF.para.units.xPos or 0, eF.para.units.yPos or 0
  u.savePosition=unitsSaveRaidPosition
  if u.dragger:IsShown() then u.dragger:Hide(); eF.layout:update() else 
    local rand=math.random()
    local tx=eF.characterframes[1+math.floor(rand*#eF.characterframes)]
    u.dragger.texture:SetTexture(tx)
    u.dragger:Show() 
    u:ClearAllPoints() 
    u:SetPoint("CENTER",UIParent,"BOTTOMLEFT",x,y) 
  end
  end)

end--end of layout


---------------NOW GROUP FRAME
  
--header/title
local fDLazy
do
--I know it's gross and lazy but hey, bite me
fD.fDLazy=CreateFrame("Frame",nil,fD)
fDLazy=fD.fDLazy
fDLazy:SetPoint("TOPLEFT",fD,"TOPLEFT",0,-300)
fDLazy:SetPoint("BOTTOMRIGHT")

fDLazy.mainTitle2=fDLazy:CreateFontString(nil,"OVERLAY")
local t=fDLazy.mainTitle2
t:SetFont(titleFont,15,titleFontExtra)
t:SetTextColor(titleFontColor2[1],titleFontColor2[2],titleFontColor2[3])
t:SetText("PARTY FRAME")
t:SetPoint("TOPLEFT",fDLazy,"TOPLEFT",8,-8)

fDLazy.mainTitleSpacer2=fDLazy:CreateTexture(nil,"BACKGROUND")
local tS=fDLazy.mainTitleSpacer2
tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
tS:SetHeight(9)
tS:SetTexture(titleSpacer)
tS:SetWidth(fDLazy:GetWidth()*0.95)
tS:SetVertexColor(titleFontColor2[1],titleFontColor2[2],titleFontColor2[3])


createCB(fDLazy,"groupParas",fDLazy)
fDLazy.groupParas.text:SetPoint("TOPLEFT",tS,"TOPLEFT",0,-initSpacing*1.5)
fDLazy.groupParas.text:SetText("Active:")
fDLazy.groupParas:SetScript("OnClick",function(self)
  local ch=self:GetChecked()
  self:SetChecked(ch)
  eF.para.groupParas=ch
  if not ch then fDLazy.iconBlocker:Show() else fDLazy.iconBlocker:Hide() end 
  eF.units:updateAllParas()
  eF.layout:update() 
end)

fDLazy.groupParas.description=fDLazy.groupParas:CreateFontString(nil,"OVERLAY")
local dp=fDLazy.groupParas.description
dp:SetPoint("LEFT",fDLazy.groupParas,"RIGHT",-30,0)
dp:SetSize(500,20)
dp:SetFont(font,11)
dp:SetText("When disabled, party frames will use the same parameters as the raid frames.")

fDLazy.iconBlocker=CreateFrame("Button",nil,fDLazy)
fDLazy.iconBlocker:SetPoint("TOPLEFT",fDLazy,"TOPLEFT",0,-initSpacing*4.5)
fDLazy.iconBlocker:SetPoint("BOTTOMRIGHT",fDLazy,"BOTTOMRIGHT",110,0)
fDLazy.iconBlocker.bg=fDLazy.iconBlocker:CreateTexture(nil,"BACKGROUDND")
fDLazy.iconBlocker.bg:SetAllPoints()
fDLazy.iconBlocker.bg:SetColorTexture(0.07,0.07,0.07,0.4)
fDLazy.iconBlocker:SetFrameLevel(fDLazy:GetFrameLevel()+3)


end 

--Dimensions
do 
fDLazy.title=fDLazy:CreateFontString(nil,"OVERLAY")
local t=fDLazy.title
t:SetFont(titleFont,15,titleFontExtra)
t:SetTextColor(1,1,1)
t:SetText("Dimensions")
t:SetPoint("TOPLEFT",fDLazy,"TOPLEFT",8,-70)

fDLazy.titleSpacer=fDLazy:CreateTexture(nil,"BACKGROUND")
local tS=fDLazy.titleSpacer
tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
tS:SetHeight(8)
tS:SetTexture(titleSpacer)
tS:SetWidth(110)

createNumberEB(fDLazy,"ebHeight",fDLazy)
fDLazy.ebHeight.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
fDLazy.ebHeight.text:SetText("Height:")
fDLazy.ebHeight:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
h=self:GetNumber()
if h==0 then h=eF.para.unitsGroup.height; self:SetText(h)
else eF.para.unitsGroup.height=h; eF.units:updateAllParas(); eF.layout:update() end
end)

createNumberEB(fDLazy,"ebWidth",fDLazy)
fDLazy.ebWidth.text:SetPoint("RIGHT",fDLazy.ebHeight.text,"RIGHT",0,-ySpacing)
--fDLazy.ebWidth:SetText(eF.para.unitsGroup.width) ebWidth:SetText(eF.para.unitsGroup.width)
fDLazy.ebWidth.text:SetText("Width:")
fDLazy.ebWidth:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
w=self:GetNumber()
if w==0 then w=eF.para.unitsGroup.width; self:SetText(w)
else eF.para.unitsGroup.width=w; eF.units:updateAllParas(); eF.layout:update() end
end)

end

--Health Frame
do
fDLazy.title2=fDLazy:CreateFontString(nil,"OVERLAY")
local t=fDLazy.title2
t:SetFont(titleFont,15,titleFontExtra)
t:SetTextColor(1,1,1)
t:SetText("Health Frame")
t:SetPoint("LEFT",fDLazy.title,"LEFT",145,0)

fDLazy.titleSpacer2=fDLazy:CreateTexture(nil,"BACKGROUND")
local tS=fDLazy.titleSpacer2
tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
tS:SetHeight(8)
tS:SetTexture(titleSpacer)
tS:SetWidth(130)

createCB(fDLazy,"hClassColor",fDLazy)
fDLazy.hClassColor.text:SetPoint("TOPLEFT",tS,"TOPLEFT",30,-initSpacing)
--fDLazy.hColor:SetText("byClass")
fDLazy.hClassColor.text:SetText("Class color:")
fDLazy.hClassColor:SetScript("OnClick",function(self)
  local ch=self:GetChecked()
  self:SetChecked(ch)
  fDLazy.hColor.blocked=ch
  eF.para.unitsGroup.byClassColor=ch
  if ch then fDLazy.hColor.blocker:Show() else fDLazy.hColor.blocker:Hide() end 
  eF.units.byClassColor=ch
  eF.units:updateAllParas()
end)

createCS(fDLazy,"hColor",fDLazy)
fDLazy.hColor.text:SetPoint("RIGHT",fDLazy.hClassColor.text,"RIGHT",0,-ySpacing)
fDLazy.hColor.text:SetText("Color:")
fDLazy.hColor.getOldRGBA=function(self)
  local r=eF.para.unitsGroup.hpR
  local g=eF.para.unitsGroup.hpG
  local b=eF.para.unitsGroup.hpB
  return r,g,b
end

fDLazy.hColor.opacityFunc=function()
  local r,g,b=ColorPickerFrame:GetColorRGB()
  local a=OpacitySliderFrame:GetValue()
  fDLazy.hColor.thumb:SetVertexColor(r,g,b)
  eF.para.unitsGroup.hpR=r
  eF.para.unitsGroup.hpG=g
  eF.para.unitsGroup.hpB=b
  eF.units.hpR=r
  eF.units.hpG=g
  eF.units.hpB=b
  eF.units:updateAllParas()
end

fDLazy.hColor.blocker=CreateFrame("Frame",nil,fDLazy)
local hCB=fDLazy.hColor.blocker
hCB:SetFrameLevel(fDLazy.hColor:GetFrameLevel()+1)
hCB:SetPoint("TOPRIGHT",fDLazy.hColor,"TOPRIGHT",2,2)
hCB:SetHeight(22)
hCB:SetWidth(120)
hCB.texture=hCB:CreateTexture(nil,"OVERLAY")
hCB.texture:SetAllPoints()
hCB.texture:SetColorTexture(0.07,0.07,0.07,0.4)


createNewDD(fDLazy,"hDir",fDLazy,50)
fDLazy.hDir.text:SetPoint("RIGHT",fDLazy.hColor.text,"RIGHT",0,-ySpacing)
fDLazy.hDir.text:SetText("Orientation:")
local lf=function(self)
  eF.para.unitsGroup.healthGrow=self.arg
  eF.units:updateAllParas()
end
for i=1,#eF.orientations do
  local v=eF.orientations[i]
  fDLazy.hDir:addButton(v,lf,v)
end

createNumberEB(fDLazy,"gradStart",fDLazy)
fDLazy.gradStart.text:SetPoint("RIGHT",fDLazy.hDir.text,"RIGHT",0,-ySpacing)
fDLazy.gradStart.text:SetText("Start grad.:")
fDLazy.gradStart:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
n=self:GetNumber()
eF.para.unitsGroup.hpGrad1R=n;
eF.para.unitsGroup.hpGrad1G=n;
eF.para.unitsGroup.hpGrad1B=n;
eF.units.hpGrad1R=n;
eF.units.hpGrad1G=n;
eF.units.hpGrad1B=n;
eF.units:updateAllParas()
end)

createNumberEB(fDLazy,"gradFinal",fDLazy)
fDLazy.gradFinal.text:SetPoint("RIGHT",fDLazy.gradStart.text,"RIGHT",0,-ySpacing)
fDLazy.gradFinal.text:SetText("Final grad.:")
fDLazy.gradFinal:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
n=self:GetNumber()
eF.para.unitsGroup.hpGrad2R=n;
eF.para.unitsGroup.hpGrad2G=n;
eF.para.unitsGroup.hpGrad2B=n;
eF.units.hpGrad2R=n;
eF.units.hpGrad2G=n;
eF.units.hpGrad2B=n;
eF.units:updateAllParas()
end)

end--end of Health Frame

--Name
do
fDLazy.title3=fDLazy:CreateFontString(nil,"OVERLAY")
local t=fDLazy.title3
t:SetFont(titleFont,15,titleFontExtra)
t:SetTextColor(1,1,1)
t:SetText("Name")
t:SetPoint("LEFT",fDLazy.title2,"LEFT",180,0)

fDLazy.titleSpacer3=fDLazy:CreateTexture(nil,"BACKGROUND")
local tS=fDLazy.titleSpacer3
tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
tS:SetHeight(8)
tS:SetTexture(titleSpacer)
tS:SetWidth(90)


createCB(fDLazy,"nClassColor",fDLazy)
fDLazy.nClassColor.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
--fDLazy.nColor:SetText("byClass")
fDLazy.nClassColor.text:SetText("Class color:")
fDLazy.nClassColor:SetScript("OnClick",function(self)
  local ch=self:GetChecked()
  self:SetChecked(ch)
  fDLazy.nColor.blocked=ch
  eF.para.unitsGroup.textColorByClass=ch
  eF.units.textColorByClass=ch
  if ch then fDLazy.nColor.blocker:Show() else fDLazy.nColor.blocker:Hide() end 
  eF.units:updateAllParas()
end)


createCS(fDLazy,"nColor",fDLazy)
fDLazy.nColor.text:SetPoint("RIGHT",fDLazy.nClassColor.text,"RIGHT",0,-ySpacing)
fDLazy.nColor.text:SetText("Color:")
fDLazy.nColor.getOldRGBA=function(self)
  local r=eF.para.unitsGroup.textR
  local g=eF.para.unitsGroup.textG
  local b=eF.para.unitsGroup.textB
  return r,g,b
end

fDLazy.nColor.opacityFunc=function()
  local r,g,b=ColorPickerFrame:GetColorRGB()
  local a=OpacitySliderFrame:GetValue()
  fDLazy.nColor.thumb:SetVertexColor(r,g,b)
  eF.para.unitsGroup.textR=r
  eF.para.unitsGroup.textG=g
  eF.para.unitsGroup.textB=b
  eF.units.textR=r
  eF.units.textG=g
  eF.units.textB=b
  eF.units:updateAllParas()
end

fDLazy.nColor.blocker=CreateFrame("Frame",nil,fDLazy)
local nCB=fDLazy.nColor.blocker
nCB:SetFrameLevel(fDLazy.nColor:GetFrameLevel()+1)
nCB:SetPoint("TOPRIGHT",fDLazy.nColor,"TOPRIGHT",2,2)
nCB:SetHeight(22)
nCB:SetWidth(120)
nCB.texture=nCB:CreateTexture(nil,"OVERLAY")
nCB.texture:SetAllPoints()
nCB.texture:SetColorTexture(0.07,0.07,0.07,0.4)

createNumberEB(fDLazy,"nMax",fDLazy)
fDLazy.nMax.text:SetPoint("RIGHT",fDLazy.nColor.text,"RIGHT",0,-ySpacing)
fDLazy.nMax.text:SetText("Characters:")
fDLazy.nMax:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
n=self:GetNumber()
if n==0 then n=eF.para.unitsGroup.textLim; self:SetText(n)
else eF.para.unitsGroup.textLim=n; eF.units.textLim=n; eF.units:updateAllParas() end
end)

createNumberEB(fDLazy,"nSize",fDLazy)
fDLazy.nSize.text:SetPoint("RIGHT",fDLazy.nMax.text,"RIGHT",0,-ySpacing)
fDLazy.nSize.text:SetText("Font size:")
fDLazy.nSize:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
n=self:GetNumber()
if n==0 then n=eF.para.unitsGroup.textSize; self:SetText(n)
else eF.para.unitsGroup.textSize=n; eF.units.textSize=n; eF.units:updateAllParas() end
end)


createNumberEB(fDLazy,"nAlpha",fDLazy)
fDLazy.nAlpha.text:SetPoint("RIGHT",fDLazy.nSize.text,"RIGHT",0,-ySpacing)
fDLazy.nAlpha.text:SetText("Alpha:")
fDLazy.nAlpha:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
a=self:GetNumber()
eF.para.unitsGroup.textA=a; eF.units.textA=a; eF.units:updateAllParas()
end)


createNewDD(fDLazy,"nFont",fDLazy)
fDLazy.nFont.text:SetPoint("RIGHT",fDLazy.nAlpha.text,"RIGHT",0,-ySpacing)
fDLazy.nFont.text:SetText("Font:")
local lf=function(self)
  eF.para.unitsGroup.textFont=self.arg
  eF.units:updateAllParas()
end
for i=1,#eF.fonts do
  local v=eF.fonts[i]
  local font="Fonts\\"..v..".ttf"
  fDLazy.nFont:addButton(v,lf,font)
end


createNewDD(fDLazy,"nPos",fDLazy)
fDLazy.nPos.text:SetPoint("RIGHT",fDLazy.nFont.text,0,-ySpacing)
fDLazy.nPos.text:SetText("Position:")
local lf=function(self)
  eF.para.unitsGroup.textPos=self.arg
  eF.units:updateAllParas()
end
for i=1,#eF.positions do
  local v=eF.positions[i]
  fDLazy.nPos:addButton(v,lf,v)
end

createNumberEB(fDLazy,"textXOS",fDLazy)
fDLazy.textXOS.text:SetPoint("RIGHT",fDLazy.nPos.text,"RIGHT",0,-ySpacing)
fDLazy.textXOS.text:SetText("X Offset:")
fDLazy.textXOS:SetWidth(30)
fDLazy.textXOS:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
x=self:GetText()
x=tonumber(x)
if not x then x=eF.activePara.textXOS; self:SetText(x); 
else 
  eF.para.unitsGroup.textXOS=x;
end
  eF.units:updateAllParas()
end)

createNumberEB(fDLazy,"textYOS",fDLazy)
fDLazy.textYOS.text:SetPoint("RIGHT",fDLazy.textXOS.text,"RIGHT",0,-ySpacing)
fDLazy.textYOS.text:SetText("Y Offset:")
fDLazy.textYOS:SetWidth(30)
fDLazy.textYOS:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
x=self:GetText()
x=tonumber(x)
if not x  then x=eF.activePara.textYOS; self:SetText(x)
else 
  eF.para.unitsGroup.textYOS=x;
end
  eF.units:updateAllParas()
end)

end--end of Name

--Border
do
fDLazy.title4=fDLazy:CreateFontString(nil,"OVERLAY")
local t=fDLazy.title4
t:SetFont(titleFont,15,titleFontExtra)
t:SetTextColor(1,1,1)
t:SetText("Border")
t:SetPoint("LEFT",fDLazy.title,"LEFT",0,-85)

fDLazy.titleSpacer4=fDLazy:CreateTexture(nil,"BACKGROUND")
local tS=fDLazy.titleSpacer4
tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
tS:SetHeight(8)
tS:SetTexture(titleSpacer)
tS:SetWidth(fDLazy.titleSpacer:GetWidth())

createCS(fDLazy,"bColor",fDLazy)
fDLazy.bColor.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
fDLazy.bColor.text:SetText("Color:")
fDLazy.bColor.getOldRGBA=function(self)
  local r=eF.para.unitsGroup.borderR
  local g=eF.para.unitsGroup.borderG
  local b=eF.para.unitsGroup.borderB
  return r,g,b
end

fDLazy.bColor.opacityFunc=function()
  local r,g,b=ColorPickerFrame:GetColorRGB()
  local a=OpacitySliderFrame:GetValue()
  fDLazy.bColor.thumb:SetVertexColor(r,g,b)
  eF.para.unitsGroup.borderR=r
  eF.para.unitsGroup.borderG=g
  eF.para.unitsGroup.borderB=b
  for i=1,45 do
    local id
    if i<6 then id=eF.partyLoop[i] else id=eF.raidLoop[i-5] end
    eF.units[id]:updateBorders();
  end
end


createNumberEB(fDLazy,"bWid",fDLazy)
fDLazy.bWid.text:SetPoint("RIGHT",fDLazy.bColor.text,"RIGHT",0,-ySpacing)
fDLazy.bWid.text:SetText("Width:")
fDLazy.bWid:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
w=self:GetNumber()
eF.para.unitsGroup.borderSize=w
eF.units.borderSize=w
for i=1,45 do
  local id
  if i<6 then id=eF.partyLoop[i] else id=eF.raidLoop[i-5] end
  eF.units[id]:updateBorders();
end
end)

end--end of border

--layout
do 
fDLazy.title5=fDLazy:CreateFontString(nil,"OVERLAY")
local t=fDLazy.title5
t:SetFont(titleFont,15,titleFontExtra)
t:SetTextColor(1,1,1)
t:SetText("Layout")
t:SetPoint("TOPLEFT",fDLazy.title3,"TOPLEFT",200,0)

fDLazy.titleSpacer5=fDLazy:CreateTexture(nil,"BACKGROUND")
local tS=fDLazy.titleSpacer5
tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
tS:SetHeight(8)
tS:SetTexture(titleSpacer)
tS:SetWidth(110)

createNewDD(fDLazy,"grow1",fDLazy,50)
fDLazy.grow1.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
fDLazy.grow1.text:SetText("Grows:")
local lf=function(self)
  eF.para.unitsGroup.grow1=self.arg
  eF.units:updateAllParas()
end
for i=1,#eF.orientations do
  local v=eF.orientations[i]
  fDLazy.grow1:addButton(v,lf,v)
end


createNewDD(fDLazy,"grow2",fDLazy,50)
fDLazy.grow2.text:SetPoint("RIGHT",fDLazy.grow1.text,"RIGHT",0,-ySpacing)
fDLazy.grow2.text:SetText("then:")
local lf=function(self)
  eF.para.unitsGroup.grow2=self.arg
  eF.units:updateAllParas()
end
for i=1,#eF.orientations do
  local v=eF.orientations[i]
  fDLazy.grow2:addButton(v,lf,v)
end

createNumberEB(fDLazy,"spacing",fDLazy)
fDLazy.spacing.text:SetPoint("RIGHT",fDLazy.grow2.text,"RIGHT",0,-ySpacing)
fDLazy.spacing.text:SetText("Spacing:")
fDLazy.spacing:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
w=self:GetText()
if (not w) or w=="" or not (tonumber(w)) then w=eF.para.unitsGroup.spacing; self:SetText(w)
else eF.para.unitsGroup.spacing=w; eF.units:updateAllParas(); eF.layout:update() end
end)


createNumberEB(fDLazy,"maxInLine",fDLazy)
fDLazy.maxInLine.text:SetPoint("RIGHT",fDLazy.spacing.text,"RIGHT",0,-ySpacing)
fDLazy.maxInLine.text:SetText("Max in line:")
fDLazy.maxInLine:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
w=self:GetNumber()
if (not w) or w==0 then w=eF.para.unitsGroup.maxInLine; self:SetText(w)
else eF.para.unitsGroup.maxInLine=math.floor(w); eF.units:updateAllParas(); eF.layout:update() end
end)


createCB(fDLazy,"byGroup",fDLazy)
fDLazy.byGroup.text:SetPoint("RIGHT",fDLazy.maxInLine.text,"RIGHT",0,-ySpacing)
fDLazy.byGroup.text:SetText("Sort by group:")
fDLazy.byGroup:SetScript("OnClick",function(self)
  local ch=self:GetChecked()
  self:SetChecked(ch)
  eF.para.unitsGroup.byGroup=ch
  eF.layout:update()
  eF.units:updateAllParas()
end)

createNumberEB(fDLazy,"xPos",fDLazy)
fDLazy.xPos.text:SetPoint("RIGHT",fDLazy.byGroup.text,"RIGHT",0,-ySpacing)
fDLazy.xPos.text:SetText("X Offset:")
fDLazy.xPos:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
w=self:GetNumber()
if (not w) then w=eF.para.unitsGroup.xPos; self:SetText(w)
else eF.para.unitsGroup.xPos=w; eF.units:updateAllParas(); eF.layout:update() end
end)

createNumberEB(fDLazy,"yPos",fDLazy)
fDLazy.yPos.text:SetPoint("RIGHT",fDLazy.xPos.text,"RIGHT",0,-ySpacing)
fDLazy.yPos.text:SetText("Y Offset:")
fDLazy.yPos:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
w=self:GetNumber()
if (not w) then w=eF.para.unitsGroup.yPos; self:SetText(w)
else eF.para.unitsGroup.yPos=w; eF.units:updateAllParas(); eF.layout:update() end
end)
end--end of layout

fDLazy.unlockUnitsButton=CreateFrame("Button",nil,fDLazy,"UIPanelButtonTemplate")
local uub=fDLazy.unlockUnitsButton
uub:SetText("(Un)lock")
uub:SetPoint("LEFT",fDLazy.yPos,"RIGHT",10,10)
uub:SetWidth(80)
uub:SetScript("OnClick",function() 
  local u=eF.units
  local x,y=eF.para.unitsGroup.xPos or 0, eF.para.unitsGroup.yPos or 0

  u.savePosition=unitsSavePartyPosition
  if u.dragger:IsShown() then u.dragger:Hide(); eF.layout:update() else 
    local rand=math.random()
    local tx=eF.characterframes[1+math.floor(rand*#eF.characterframes)]
    u.dragger.texture:SetTexture(tx)
    u.dragger:Show() 
    u:ClearAllPoints() 
    u:SetPoint("CENTER",UIParent,"BOTTOMLEFT",x,y) 
  end
  end)


end


--[[
--OTHER STUFF
do

  gf.frameDimScrollFrame=CreateFrame("ScrollFrame","egframeDimScrollFrame",gf,"UIPanelScrollFrameTemplate")
  local fdsf=gf.frameDimScrollFrame
  fdsf:SetPoint("TOPLEFT",gf,"TOPLEFT",gf:GetWidth()*0.03,-30)
  fdsf:SetPoint("BOTTOMRIGHT",gf,"BOTTOMRIGHT",-gf:GetWidth()*0.03,30)
  fdsf:SetClipsChildren(true)
  fdsf:SetScript("OnMouseWheel",ScrollFrame_OnMouseWheel)
  
  fdsf.border=CreateFrame("Frame",nil,gf)
  fdsf.border:SetPoint("TOPLEFT",fdsf,"TOPLEFT",-5,5)
  fdsf.border:SetPoint("BOTTOMRIGHT",fdsf,"BOTTOMRIGHT",5,-5)
  fdsf.border:SetBackdrop(bd2)
  gf.frameDim=CreateFrame("Frame","eFframeDimChild",gf)
  local fD=gf.frameDim
  fD:SetPoint("TOP",fdsf,"TOP",0,-20)
  fD:SetWidth(fdsf:GetWidth()*0.8)
  fD:SetHeight(fdsf:GetHeight()*1.2)
 
  fdsf.ScrollBar:ClearAllPoints()
  fdsf.ScrollBar:SetPoint("TOPRIGHT",fdsf,"TOPRIGHT",-6,-18)
  fdsf.ScrollBar:SetPoint("BOTTOMLEFT",fdsf,"BOTTOMRIGHT",-16,18)
  fdsf.ScrollBar.bg=fdsf.ScrollBar:CreateTexture(nil,"BACKGROUND")
  fdsf.ScrollBar.bg:SetAllPoints()
  fdsf.ScrollBar.bg:SetColorTexture(0,0,0,0.5)
  
  fdsf:SetScrollChild(fD)
  
  fdsf.bg=fdsf:CreateTexture(nil,"BACKGROUND")
  fdsf.bg:SetAllPoints()
  fdsf.bg:SetColorTexture(0.07,0.07,0.07,1)
  
--header/title
do
fD.mainTitle=fD:CreateFontString(nil,"OVERLAY")
local t=fD.mainTitle
t:SetFont(titleFont,15,titleFontExtra)
t:SetTextColor(titleFontColor2[1],titleFontColor2[2],titleFontColor2[3])
t:SetText("RAID FRAME")
t:SetPoint("TOPLEFT",fD,"TOPLEFT",8,-8)

fD.mainTitleSpacer=fD:CreateTexture(nil,"BACKGROUND")
local tS=fD.mainTitleSpacer
tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
tS:SetHeight(9)
tS:SetTexture(titleSpacer)
tS:SetWidth(fD:GetWidth()*0.95)
tS:SetVertexColor(titleFontColor2[1],titleFontColor2[2],titleFontColor2[3])
end 

--Misc
do 
fD.title=fD:CreateFontString(nil,"OVERLAY")
local t=fD.title
t:SetFont(titleFont,15,titleFontExtra)
t:SetTextColor(1,1,1)
t:SetText("Dimensions")
t:SetPoint("TOPLEFT",fD,"TOPLEFT",8,-48)

fD.titleSpacer=fD:CreateTexture(nil,"BACKGROUND")
local tS=fD.titleSpacer
tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
tS:SetHeight(8)
tS:SetTexture(titleSpacer)
tS:SetWidth(110)

createNumberEB(fD,"ebHeight",fD)
fD.ebHeight.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
fD.ebHeight.text:SetText("Height:")
fD.ebHeight:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
h=self:GetNumber()
if h==0 then h=eF.para.units.height; self:SetText(h)
else eF.para.units.height=h; eF.units:updateAllParas(); eF.layout:update() end
end)

createNumberEB(fD,"ebWidth",fD)
fD.ebWidth.text:SetPoint("RIGHT",fD.ebHeight.text,"RIGHT",0,-ySpacing)
--fD.ebWidth:SetText(eF.para.units.width) ebWidth:SetText(eF.para.units.width)
fD.ebWidth.text:SetText("Width:")
fD.ebWidth:SetScript("OnEnterPressed", function(self)
self:ClearFocus()
w=self:GetNumber()
if w==0 then w=eF.para.units.width; self:SetText(w)
else eF.para.units.width=w; eF.units:updateAllParas(); eF.layout:update() end
end)

end

end
]]


--FAMILIES FRAME
do
int.familiesFrame=CreateFrame("Frame","eFFamilies",hd1)
ff=int.familiesFrame
ff:Hide()
hd1b3.relatedFrame=ff
ff:SetAllPoints()

local fL,sc

--create Scroll Frame 
do
ff.famList=CreateFrame("ScrollFrame","eFFamScroll",ff,"UIPanelScrollFrameTemplate")
fL=ff.famList
fL:SetPoint("TOPLEFT",ff,"TOPLEFT",ff:GetWidth()*0.02,-60)
fL:SetPoint("BOTTOMRIGHT",ff,"BOTTOMLEFT",ff:GetWidth()*0.22,20)
fL:SetClipsChildren(true)
fL:SetScript("OnMouseWheel",ScrollFrame_OnMouseWheel)

--create Border
fL.border=CreateFrame("Frame",nil,ff)
fL.border:SetPoint("TOPLEFT",fL,"TOPLEFT",-5,5)
fL.border:SetPoint("BOTTOMRIGHT",fL,"BOTTOMRIGHT",5,-5)
fL.border:SetBackdrop(bd)


--reposition scrollbar and craete its texture
fL.ScrollBar:ClearAllPoints()
fL.ScrollBar:SetPoint("TOPLEFT",fL,"TOPLEFT",6,-18)
fL.ScrollBar:SetPoint("BOTTOMRIGHT",fL,"BOTTOMLEFT",16,18)
fL.ScrollBar.bg=fL.ScrollBar:CreateTexture(nil,"BACKGROUND")
fL.ScrollBar.bg:SetAllPoints()
fL.ScrollBar.bg:SetColorTexture(0,0,0,0.5) 

--make background
fL.bg=fL:CreateTexture(nil,"BACKGROUND")
fL.bg:SetAllPoints()
fL.bg:SetColorTexture(0,0,0,0.3)

--create scrollchild
fL.scrollChild=CreateFrame("Frame","eFFamScrollChild",fL)
sc=fL.scrollChild
fL:SetScrollChild(sc)
sc.createFamily=createFamily
sc.createChild=createChild
sc.createGroup=createGroup
sc.updateFamilyButtonsIndexList=updateFamilyButtonsIndexList
sc.setFamilyPositions=setFamilyPositions
sc:SetWidth(fL:GetWidth())
sc:SetHeight(600)
sc:SetPoint("TOP",fL,"TOP")
sc.families={}
end

--create smart Family Frame
do
  
  local sff,sfsf
  --create scroll frame + box etc
  do
  ff.smartFamilyScrollFrame=CreateFrame("ScrollFrame","eFSmartFamilyScrollFrame",ff,"UIPanelScrollFrameTemplate")
  sfsf=ff.smartFamilyScrollFrame
  sfsf:SetPoint("TOPLEFT",ff.famList,"TOPRIGHT",20,-22)
  sfsf:SetPoint("BOTTOMRIGHT",ff.famList,"BOTTOMRIGHT",20+ff:GetWidth()*0.72,0)
  sfsf:SetClipsChildren(true)
  sfsf:SetScript("OnMouseWheel",ScrollFrame_OnMouseWheel)
  
  sfsf.border=CreateFrame("Frame",nil,ff)
  sfsf.border:SetPoint("TOPLEFT",sfsf,"TOPLEFT",-5,5)
  sfsf.border:SetPoint("BOTTOMRIGHT",sfsf,"BOTTOMRIGHT",5,-5)
  sfsf.border:SetBackdrop(bd)
  
  ff.smartFamilyFrame=CreateFrame("Frame","eFsff",ff)
  sff=ff.smartFamilyFrame
  sff:SetPoint("TOP",sfsf,"TOP",0,-20)
  sff:SetWidth(sfsf:GetWidth()*0.8)
  sff:SetHeight(sfsf:GetHeight()*2)
 
  sfsf.ScrollBar:ClearAllPoints()
  sfsf.ScrollBar:SetPoint("TOPRIGHT",sfsf,"TOPRIGHT",-6,-18)
  sfsf.ScrollBar:SetPoint("BOTTOMLEFT",sfsf,"BOTTOMRIGHT",-16,18)
  sfsf.ScrollBar.bg=sfsf.ScrollBar:CreateTexture(nil,"BACKGROUND")
  sfsf.ScrollBar.bg:SetAllPoints()
  sfsf.ScrollBar.bg:SetColorTexture(0,0,0,0.5)
  
  sfsf:SetScrollChild(sff)
  
  sfsf.bg=sfsf:CreateTexture(nil,"BACKGROUND")
  sfsf.bg:SetAllPoints()
  sfsf.bg:SetColorTexture(0.07,0.07,0.07,1)

  sff.setValues=setSFFActiveValues
  end --end of scroll frame + box etc

  --create general settings stuff
  do
  sff.title1=sff:CreateFontString(nil,"OVERLAY")
  local t=sff.title1
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("General")
  t:SetPoint("TOPLEFT",sff,"TOPLEFT",50,-25)

  sff.title1Spacer=sff:CreateTexture(nil,"OVERLAY")
  local tS=sff.title1Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createNumberEB(sff,"name",sff)
  sff.name.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  sff.name.text:SetText("Name:")
  sff.name:SetWidth(80)
  sff.name:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  name=self:GetText()
  if not name or name=="" then name=eF.activePara.displayName; self:SetText(name)
  else 
    eF.activePara.displayName=name; 
    eF.activeButton.text:SetText(name)
  end
  end)

  createNewDD(sff,"type",sff,75)
  sff.type.text:SetPoint("RIGHT",sff.name.text,"RIGHT",0,-ySpacing)
  sff.type.text:SetText("Type:")
  local lf=function(self)
    eF.activePara.type=self.arg
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end
  local lst={"Blacklist","Whitelist"}
  for i=1,#lst do
    local v=lst[i]
    local rv
    if v=="Blacklist" then rv="b" elseif v=="Whitelist" then rv="w" end
    sff.type:addButton(v,lf,rv)
  end
  

  createNewDD(sff,"trackType",sff,75)
  sff.trackType.text:SetPoint("RIGHT",sff.type.text,"RIGHT",0,-ySpacing)
  sff.trackType.text:SetText("Tracks:")
  local lf=function(self)
    eF.activePara.trackType=self.arg
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end
  local lst={"Buffs","Debuffs","Casts"}
  for i=1,#lst do
    local v=lst[i]
    sff.trackType:addButton(v,lf,v)
  end
 
  createCB(sff,"ignorePermanents",sff)
  sff.ignorePermanents.text:SetPoint("RIGHT",sff.trackType.text,"RIGHT",0,-ySpacing)
  sff.ignorePermanents.text:SetText("Ignore permanents:")
  sff.ignorePermanents:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.ignorePermanents=ch
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end)

  createNumberEB(sff,"ignoreDurationAbove",sff)
  sff.ignoreDurationAbove.text:SetPoint("RIGHT",sff.ignorePermanents.text,"RIGHT",0,-ySpacing)
  sff.ignoreDurationAbove.text:SetText("Max duration:")
  sff.ignoreDurationAbove:SetWidth(30)
  sff.ignoreDurationAbove:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  count=self:GetText()
  if not count or count=="nil" or count=="" then eF.activePara.ignoreDurationAbove=nil; self:SetText("nil")
  else 
    eF.activePara.ignoreDurationAbove=tonumber(count);
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end
  end)

  createCB(sff,"ownOnly",sff)
  sff.ownOnly.text:SetPoint("RIGHT",sff.ignoreDurationAbove.text,"RIGHT",0,-ySpacing)
  sff.ownOnly.text:SetText("Own only:")
  sff.ownOnly:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.ownOnly=ch
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end)
  
  end--end of general settings

  --create layout settings
  do
  sff.title2=sff:CreateFontString(nil,"OVERLAY")
  local t=sff.title2
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Layout")
  t:SetPoint("TOPLEFT",sff.title1,"TOPLEFT",220,0)

  sff.title2Spacer=sff:CreateTexture(nil,"OVERLAY")
  local tS=sff.title2Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createNumberEB(sff,"count",sff)
  sff.count.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  sff.count.text:SetText("Count:")
  sff.count:SetWidth(30)
  sff.count:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  count=self:GetNumber()
  if not count or count==0 then count=eF.activePara.count; self:SetText(count)
  else 
    eF.activePara.count=count;
  end
  updateAllFramesFamilyLayout(eF.activeFamilyIndex)

  end)
  --NYI: update without reload

  createNewDD(sff,"grow",sff,50)
  sff.grow.text:SetPoint("RIGHT",sff.count.text,"RIGHT",0,-ySpacing)
  sff.grow.text:SetText("Grows:")
  local lf=function(self)
    local v=self.arg
    eF.activePara.grow=v    
    if v=="right" then eF.activePara.growAnchor="LEFT"
    elseif v=="left" then eF.activePara.growAnchor="RIGHT"
    elseif v=="up" then eF.activePara.growAnchor="BOTTOM"
    elseif v=="down" then eF.activePara.growAnchor="TOP" end
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end
  local lst=eF.orientations
  for i=1,#lst do
    local v=lst[i]
    sff.grow:addButton(v,lf,v)
  end


  createNumberEB(sff,"width",sff)
  sff.width.text:SetPoint("RIGHT",sff.grow.text,"RIGHT",0,-ySpacing)
  sff.width.text:SetText("Width:")
  sff.width:SetWidth(30)
  sff.width:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  w=self:GetNumber()
  if not w or w==0 then w=eF.activePara.width; self:SetText(w)
  else 
    eF.activePara.width=w;
  end
  updateAllFramesFamilyLayout(eF.activeFamilyIndex)
  end)

  createNumberEB(sff,"height",sff)
  sff.height.text:SetPoint("RIGHT",sff.width.text,"RIGHT",0,-ySpacing)
  sff.height.text:SetText("Height:")
  sff.height:SetWidth(30)
  sff.height:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  h=self:GetNumber()
  if not h or h==0 then h=eF.activePara.height; self:SetText(h)
  else 
    eF.activePara.height=h;
  end
  updateAllFramesFamilyLayout(eF.activeFamilyIndex)
  end)

  createNumberEB(sff,"spacing",sff)
  sff.spacing.text:SetPoint("RIGHT",sff.height.text,"RIGHT",0,-ySpacing)
  sff.spacing.text:SetText("Spacing:")
  sff.spacing:SetWidth(30)
  sff.spacing:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  s=self:GetNumber()
  if not s or s==0 then s=eF.activePara.spacing; self:SetText(s)
  else 
    eF.activePara.spacing=s;
  end
  updateAllFramesFamilyLayout(eF.activeFamilyIndex)
  end)

  end--end of layout settings

  --create position settings
  do
  sff.title3=sff:CreateFontString(nil,"OVERLAY")
  local t=sff.title3
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Position")
  t:SetPoint("TOPLEFT",sff.title1,"TOPLEFT",25,-185)

  sff.title3Spacer=sff:CreateTexture(nil,"OVERLAY")
  local tS=sff.title3Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createNumberEB(sff,"xPos",sff)
  sff.xPos.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  sff.xPos.text:SetText("X Offset:")
  sff.xPos:SetWidth(30)
  sff.xPos:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  x=self:GetText()
  x=tonumber(x)
  if not x then x=eF.activePara.xPos; self:SetText(x); 
  else 
    eF.activePara.xPos=x;
  end
  updateAllFramesFamilyLayout(eF.activeFamilyIndex)
  end)

  createNumberEB(sff,"yPos",sff)
  sff.yPos.text:SetPoint("RIGHT",sff.xPos.text,"RIGHT",0,-ySpacing)
  sff.yPos.text:SetText("Y Offset:")
  sff.yPos:SetWidth(30)
  sff.yPos:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  x=self:GetText()
  x=tonumber(x)
  if not x  then x=eF.activePara.yPos; self:SetText(x)
  else 
    eF.activePara.yPos=x;
  end
  updateAllFramesFamilyLayout(eF.activeFamilyIndex)
  end)

  createNewDD(sff,"anchor",sff,85)
  sff.anchor.text:SetPoint("RIGHT",sff.yPos.text,"RIGHT",0,-ySpacing)
  sff.anchor.text:SetText("Position:")
  local lf=function(self)
    eF.activePara.anchor=self.arg    
    eF.activePara.anchorTo=self.arg    
    updateAllFramesFamilyLayout(eF.activeFamilyIndex)
  end
  local lst=eF.positions
  for i=1,#lst do
    local v=lst[i]
    sff.anchor:addButton(v,lf,v)
  end

  end--end of position settings

  --create icon settings
  do
  sff.title4=sff:CreateFontString(nil,"OVERLAY")
  local t=sff.title4
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Icon")
  t:SetPoint("TOPLEFT",sff.title3,"TOPLEFT",250,-15)

  sff.title4Spacer=sff:CreateTexture(nil,"OVERLAY")
  local tS=sff.title4Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createCB(sff,"iconCB",sff)
  sff.iconCB.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  sff.iconCB.text:SetText("Has Icon:")
  sff.iconCB:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.hasTexture=ch
    if not ch then sff.iconBlocker1:Show();sff.iconBlocker2:Show() else sff.iconBlocker1:Hide();sff.iconBlocker2:Hide() end
    if eF.activePara.smartIcon then sff.iconBlocker2:Show() end
    eF.activePara.hasTexture=ch
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end)


  createCB(sff,"smartIcon",sff)
  sff.smartIcon.text:SetPoint("RIGHT",sff.iconCB.text,"RIGHT",0,-ySpacing)
  sff.smartIcon.text:SetText("Smart Icon:")
  sff.smartIcon:SetScript("OnClick",function(self)
    if sff.iconBlocked1 then self.SetChecked(not self:GetChecked());return end
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.smartIcon=ch
    if ch then sff.iconBlocker2:Show() else sff.iconBlocker2:Hide() end
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end)


  sff.iconBlocker1=CreateFrame("Button",nil,sff)
  local iB1=sff.iconBlocker1
  iB1:SetFrameLevel(sff:GetFrameLevel()+3)
  iB1:SetPoint("TOPRIGHT",sff.smartIcon,"TOPRIGHT",2,2)
  iB1:SetPoint("BOTTOMLEFT",sff.smartIcon.text,"BOTTOMLEFT",-2,-2)
  iB1.texture=iB1:CreateTexture(nil,"OVERLAY")
  iB1.texture:SetAllPoints()
  iB1.texture:SetColorTexture(0.07,0.07,0.07,0.4)


  createIP(sff,"icon",sff)
  sff.icon.text:SetPoint("RIGHT",sff.smartIcon.text,"RIGHT",0,-ySpacing)
  sff.icon.text:SetText("Texture:")
  sff.icon:SetWidth(60)
  sff.icon:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  x=self:GetText()
  if not x  then x=eF.activePara.texture; self:SetText(x)
  else 
    eF.activePara.texture=x;
    self.pTexture:SetTexture(x)
  end
  end)
  --NYI: update without reload

  sff.iconBlocker2=CreateFrame("Button",nil,sff)
  local iB2=sff.iconBlocker2
  iB2:SetFrameLevel(sff:GetFrameLevel()+3)
  iB2:SetPoint("TOPLEFT",sff.icon.text,"TOPLEFT",-2,12)
  iB2:SetHeight(50)
  iB2:SetWidth(200)
  iB2.texture=iB2:CreateTexture(nil,"OVERLAY")
  iB2.texture:SetAllPoints()
  iB2.texture:SetColorTexture(0.07,0.07,0.07,0.4)



  end --end of icon settings

  --create list EB
  do
  sff.title5=sff:CreateFontString(nil,"OVERLAY")
  local t=sff.title5
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("List")
  t:SetPoint("TOPLEFT",sff.title3,"TOPLEFT",-10,-125)

  sff.title5Spacer=sff:CreateTexture(nil,"OVERLAY")
  local tS=sff.title5Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createListCB(sff,"list",sff)
  sff.list:SetPoint("TOPLEFT",tS,"TOPLEFT",0,-initSpacing)
  sff.list.button:SetScript("OnClick", function(self)
  local sfind,ssub,insert=strfind,strsub,table.insert
  local x=self.eb:GetText()
  self:Disable()
  self.eb:ClearFocus()
  local old=0
  local new=0
  local antiCrash=0
  local rtbl={}
  while new do
    new=sfind(x,"\n",old+1)
    local ss=ssub(x,old,new)
    insert(rtbl,ss:match("^%s*(.-)%s*$"))
    old=new
    antiCrash=antiCrash+1
    if antiCrash>500 then break end
  end
  eF.activePara.arg1=rtbl
  updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end) 


  end --end of list EB

  --create CDwheel settings
  do
  sff.title6=sff:CreateFontString(nil,"OVERLAY")
  local t=sff.title6
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("CD Wheel")
  t:SetPoint("TOPLEFT",sff.title5,"TOPLEFT",225,0)

  sff.title6Spacer=sff:CreateTexture(nil,"OVERLAY")
  local tS=sff.title6Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createCB(sff,"cdWheel",sff)
  sff.cdWheel.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  sff.cdWheel.text:SetText("Has CD wheel:")
  sff.cdWheel:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.cdWheel=ch
    if not ch then sff.iconBlocker3:Show() else sff.iconBlocker3:Hide() end
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end)


  createCB(sff,"cdReverse",sff)
  sff.cdReverse.text:SetPoint("RIGHT",sff.cdWheel.text,"RIGHT",0,-ySpacing)
  sff.cdReverse.text:SetText("Reverse spin:")
  sff.cdReverse:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.cdReverse=ch
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end)


  sff.iconBlocker3=CreateFrame("Button",nil,sff)
  local iB3=sff.iconBlocker3
  iB3:SetFrameLevel(sff:GetFrameLevel()+3)
  iB3:SetPoint("TOPLEFT",sff.cdReverse.text,"TOPLEFT",-2,12)
  iB3:SetHeight(50)
  iB3:SetWidth(200)
  iB3.texture=iB3:CreateTexture(nil,"OVERLAY")
  iB3.texture:SetAllPoints()
  iB3.texture:SetColorTexture(0.07,0.07,0.07,0.4)
  end --end of CDwheel settings

  --create border settings
  do
  sff.title7=sff:CreateFontString(nil,"OVERLAY")
  local t=sff.title7
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Border")
  t:SetPoint("TOPLEFT",sff.title6,"TOPLEFT",0,-80)

  sff.title7Spacer=sff:CreateTexture(nil,"OVERLAY")
  local tS=sff.title7Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createCB(sff,"hasBorder",sff)
  sff.hasBorder.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  sff.hasBorder.text:SetText("Has Border:")
  sff.hasBorder:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.hasBorder=ch
    if not ch then sff.iconBlocker4:Show() else sff.iconBlocker4:Hide() end
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end)
  --NYI not hiding border
  
  createNewDD(sff,"borderType",sff,70)
  sff.borderType.text:SetPoint("RIGHT",sff.hasBorder.text,"RIGHT",0,-ySpacing)
  sff.borderType.text:SetText("Border type:")
  local lf=function(self)
    eF.activePara.borderType=self.arg    
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end
  local lst={"debuffColor"}
  for i=1,#lst do
    local v=lst[i]
    sff.borderType:addButton(v,lf,v)
  end
  

  sff.iconBlocker4=CreateFrame("Button",nil,sff)
  local iB4=sff.iconBlocker4
  iB4:SetFrameLevel(sff:GetFrameLevel()+3)
  iB4:SetPoint("TOPLEFT",sff.borderType.text,"TOPLEFT",-2,12)
  iB4:SetHeight(50)
  iB4:SetWidth(200)
  iB4.texture=iB4:CreateTexture(nil,"OVERLAY")
  iB4.texture:SetAllPoints()
  iB4.texture:SetColorTexture(0.07,0.07,0.07,0.4)

  end --end of border settings

  --create text1 settings
  do
  sff.title8=sff:CreateFontString(nil,"OVERLAY")
  local t=sff.title8
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Text 1")
  t:SetPoint("TOPLEFT",sff.title5,"TOPLEFT",0,-200)

  sff.title8Spacer=sff:CreateTexture(nil,"OVERLAY")
  local tS=sff.title8Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createCB(sff,"hasText1",sff)
  sff.hasText1.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  sff.hasText1.text:SetText("Text 1:")
  sff.hasText1:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.hasText=ch
    if not ch then sff.iconBlocker5:Show() else sff.iconBlocker5:Hide() end
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end)
  
  createNewDD(sff,"textType1",sff)
  sff.textType1.text:SetPoint("RIGHT",sff.hasText1.text,"RIGHT",0,-ySpacing)
  sff.textType1.text:SetText("Text type:")
  local lf=function(self)
    eF.activePara.textType=self.arg    
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end
  local lst={"Time left","Stacks"}
  for i=1,#lst do
    local v=lst[i]
    sff.textType1:addButton(v,lf,v)
  end
  
  createCS(sff,"textColor1",sff)
  sff.textColor1.text:SetPoint("RIGHT",sff.textType1.text,"RIGHT",0,-ySpacing)
  sff.textColor1.text:SetText("Color:")
  sff.textColor1.getOldRGBA=function(self)
    local r=eF.activePara.textR
    local g=eF.activePara.textG
    local b=eF.activePara.textB
    return r,g,b
  end

  sff.textColor1.opacityFunc=function()
    local r,g,b=ColorPickerFrame:GetColorRGB()
    local a=OpacitySliderFrame:GetValue()
    sff.textColor1.thumb:SetVertexColor(r,g,b)
    eF.activePara.textR=r
    eF.activePara.textG=g
    eF.activePara.textB=b
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end


  createNumberEB(sff,"textDecimals1",sff)
  sff.textDecimals1.text:SetPoint("RIGHT",sff.textColor1.text,"RIGHT",0,-ySpacing)
  sff.textDecimals1.text:SetText("Decimals:")
  sff.textDecimals1:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  n=self:GetNumber()
  if not n then n=eF.activePara.textDecimals; self:SetText(n)
  else eF.activePara.textDecimals=n end
  end)

  createNumberEB(sff,"fontSize1",sff)
  sff.fontSize1.text:SetPoint("RIGHT",sff.textDecimals1.text,"RIGHT",0,-ySpacing)
  sff.fontSize1.text:SetText("Font size:")
  sff.fontSize1:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  n=self:GetNumber()
  if n==0 then n=eF.activePara.textSize; self:SetText(n)
  else eF.activePara.textSize=n; updateAllFramesFamilyParas(eF.activeFamilyIndex) end
  end)


  createNumberEB(sff,"textA1",sff)
  sff.textA1.text:SetPoint("RIGHT",sff.fontSize1.text,"RIGHT",0,-ySpacing)
  sff.textA1.text:SetText("Alpha:")
  sff.textA1:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  a=self:GetNumber()
  eF.activePara.textA=a
  updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end)


  createNewDD(sff,"textFont1",sff)
  sff.textFont1.text:SetPoint("RIGHT",sff.textA1.text,"RIGHT",0,-ySpacing)
  sff.textFont1.text:SetText("Font:")
  local lf=function(self)
    eF.activePara.textFont=self.arg    
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end
  local lst=eF.fonts
  for i=1,#lst do
    local v=lst[i]
    local font="Fonts\\"..v..".ttf"
    sff.textFont1:addButton(v,lf,font)
  end

  createNewDD(sff,"textAnchor1",sff)
  sff.textAnchor1.text:SetPoint("RIGHT",sff.textFont1.text,"RIGHT",0,-ySpacing)
  sff.textAnchor1.text:SetText("Position:")
  local lf=function(self)
    eF.activePara.textAnchor=self.arg    
    eF.activePara.textAnchorTo=self.arg    
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end
  local lst=eF.positions
  for i=1,#lst do
    local v=lst[i]
    sff.textAnchor1:addButton(v,lf,v)
  end
  
  createNumberEB(sff,"textXOS1",sff)
  sff.textXOS1.text:SetPoint("RIGHT",sff.textAnchor1.text,"RIGHT",0,-ySpacing)
  sff.textXOS1.text:SetText("X Offset:")
  sff.textXOS1:SetWidth(30)
  sff.textXOS1:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  x=self:GetText()
  x=tonumber(x)
  if not x then x=eF.activePara.textXOS; self:SetText(x); 
  else 
    eF.activePara.textXOS=x;
  end
  updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end)

  createNumberEB(sff,"textYOS1",sff)
  sff.textYOS1.text:SetPoint("RIGHT",sff.textXOS1.text,"RIGHT",0,-ySpacing)
  sff.textYOS1.text:SetText("Y Offset:")
  sff.textYOS1:SetWidth(30)
  sff.textYOS1:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  x=self:GetText()
  x=tonumber(x)
  if not x  then x=eF.activePara.textYOS; self:SetText(x)
  else 
    eF.activePara.textYOS=x;
  end
  updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end)

  
  sff.iconBlocker5=CreateFrame("Button",nil,sff)
  local iB5=sff.iconBlocker5
  iB5:SetFrameLevel(sff:GetFrameLevel()+3)
  iB5:SetPoint("TOPLEFT",sff.textType1.text,"TOPLEFT",-2,12)
  iB5:SetPoint("BOTTOMRIGHT",sff.textYOS1,"BOTTOMRIGHT",58,-3)
  iB5:SetWidth(200)
  iB5.texture=iB5:CreateTexture(nil,"OVERLAY")
  iB5.texture:SetAllPoints()
  iB5.texture:SetColorTexture(0.07,0.07,0.07,0.4)

  end --end of text settings
  
  --create text2 settings
  do
  sff.title9=sff:CreateFontString(nil,"OVERLAY")
  local t=sff.title9
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Text 2")
  t:SetPoint("TOPLEFT",sff.title8,"TOPLEFT",250,0)

  sff.title9Spacer=sff:CreateTexture(nil,"OVERLAY")
  local tS=sff.title9Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createCB(sff,"hasText2",sff)
  sff.hasText2.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  sff.hasText2.text:SetText("Text 2:")
  sff.hasText2:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.hasText2=ch
    if not ch then sff.iconBlocker6:Show() else sff.iconBlocker6:Hide() end
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end)
  
  createNewDD(sff,"text2Type",sff)
  sff.text2Type.text:SetPoint("RIGHT",sff.hasText2.text,"RIGHT",0,-ySpacing)
  sff.text2Type.text:SetText("Text type:")
  local lf=function(self)
    eF.activePara.text2Type=self.arg    
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end
  local lst={"Time left","Stacks"}
  for i=1,#lst do
    local v=lst[i]
    sff.text2Type:addButton(v,lf,v)
  end


  
  createCS(sff,"text2Color",sff)
  sff.text2Color.text:SetPoint("RIGHT",sff.text2Type.text,"RIGHT",0,-ySpacing)
  sff.text2Color.text:SetText("Color:")
  sff.text2Color.getOldRGBA=function(self)
    local r=eF.activePara.textR
    local g=eF.activePara.textG
    local b=eF.activePara.textB
    return r,g,b
  end

  sff.text2Color.opacityFunc=function()
    local r,g,b=ColorPickerFrame:GetColorRGB()
    local a=OpacitySliderFrame:GetValue()
    sff.text2Color.thumb:SetVertexColor(r,g,b)
    eF.activePara.text2R=r
    eF.activePara.text2G=g
    eF.activePara.text2B=b
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end


  createNumberEB(sff,"text2Decimals",sff)
  sff.text2Decimals.text:SetPoint("RIGHT",sff.text2Color.text,"RIGHT",0,-ySpacing)
  sff.text2Decimals.text:SetText("Decimals:")
  sff.text2Decimals:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  n=self:GetNumber()
  if not n then n=eF.activePara.text2Decimals; self:SetText(n)
  else eF.activePara.text2Decimals=n end
  end)

  createNumberEB(sff,"fontSize2",sff)
  sff.fontSize2.text:SetPoint("RIGHT",sff.text2Decimals.text,"RIGHT",0,-ySpacing)
  sff.fontSize2.text:SetText("Font size:")
  sff.fontSize2:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  n=self:GetNumber()
  if n==0 then n=eF.activePara.text2Size; self:SetText(n)
  else eF.activePara.text2Size=n; updateAllFramesFamilyParas(eF.activeFamilyIndex) end
  end)


  createNumberEB(sff,"text2A",sff)
  sff.text2A.text:SetPoint("RIGHT",sff.fontSize2.text,"RIGHT",0,-ySpacing)
  sff.text2A.text:SetText("Alpha:")
  sff.text2A:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  a=self:GetNumber()
  eF.activePara.text2A=a
  updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end)


  createNewDD(sff,"text2Font",sff)
  sff.text2Font.text:SetPoint("RIGHT",sff.text2A.text,"RIGHT",0,-ySpacing)
  sff.text2Font.text:SetText("Font:")
  local lf=function(self)
    eF.activePara.text2Font=self.arg    
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end
  local lst=eF.fonts
  for i=1,#lst do
    local v=lst[i]
    local font="Fonts\\"..v..".ttf"
    sff.text2Font:addButton(v,lf,font)
  end
 
  
  createNewDD(sff,"text2Anchor",sff)
  sff.text2Anchor.text:SetPoint("RIGHT",sff.text2Font.text,"RIGHT",0,-ySpacing)
  sff.text2Anchor.text:SetText("Position:")
  
  local lf=function(self)
    eF.activePara.text2Anchor=self.arg   
    eF.activePara.text2AnchorTo=self.arg    
    updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end
  local lst=eF.positions
  for i=1,#lst do
    local v=lst[i]
    sff.text2Anchor:addButton(v,lf,v)
  end

  
  createNumberEB(sff,"text2XOS",sff)
  sff.text2XOS.text:SetPoint("RIGHT",sff.text2Anchor.text,"RIGHT",0,-ySpacing)
  sff.text2XOS.text:SetText("X Offset:")
  sff.text2XOS:SetWidth(30)
  sff.text2XOS:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  x=self:GetText()
  x=tonumber(x)
  if not x then x=eF.activePara.text2XOS; self:SetText(x); 
  else 
    eF.activePara.text2XOS=x;
  end
  updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end)

  createNumberEB(sff,"text2YOS",sff)
  sff.text2YOS.text:SetPoint("RIGHT",sff.text2XOS.text,"RIGHT",0,-ySpacing)
  sff.text2YOS.text:SetText("Y Offset:")
  sff.text2YOS:SetWidth(30)
  sff.text2YOS:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  x=self:GetText()
  x=tonumber(x)
  if not x  then x=eF.activePara.text2YOS; self:SetText(x)
  else 
    eF.activePara.text2YOS=x;
  end
  updateAllFramesFamilyParas(eF.activeFamilyIndex)
  end)

  
  sff.iconBlocker6=CreateFrame("Button",nil,sff)
  local iB6=sff.iconBlocker6
  iB6:SetFrameLevel(sff:GetFrameLevel()+3)
  iB6:SetPoint("TOPLEFT",sff.text2Type.text,"TOPLEFT",-2,12)
  iB6:SetPoint("BOTTOMRIGHT",sff.text2YOS,"BOTTOMRIGHT",58,-3)
  iB6:SetWidth(200)
  iB6.texture=iB6:CreateTexture(nil,"OVERLAY")
  iB6.texture:SetAllPoints()
  iB6.texture:SetColorTexture(0.07,0.07,0.07,0.4)

  end --end of text settings
  
end --end of create smart FF

--create tabs
do
ff.tabs=CreateFrame("Frame",nil,ff)
ff.tabs:SetPoint("BOTTOMLEFT",ff.smartFamilyScrollFrame.border,"TOPLEFT",0,-10)
ff.tabs:SetPoint("BOTTOMRIGHT",ff.smartFamilyScrollFrame.border,"TOPRIGHT",0,-10)
ff.tabs:SetHeight(32)

ff.tabs.tab1=CreateFrame("Button",nil,ff.tabs)
local tab1=ff.tabs.tab1
tab1:SetPoint("TOPLEFT")
tab1:SetPoint("BOTTOMRIGHT",ff.tabs,"BOTTOM",-15,0)
tab1:SetBackdrop(bd)

tab1.text=tab1:CreateFontString(nil,"OVERLAY")
tab1.text:SetPoint("CENTER")
tab1.text:SetFont(font2,17,fontExtra)
tab1.text:SetText("Parameters")
tab1.text:SetTextColor(0.9,0.9,0.1)

tab1.nTexture=tab1:CreateTexture(nil,"BACKGROUND")
tab1.nTexture:SetPoint("TOPLEFT",tab1,"TOPLEFT",6,-6)
tab1.nTexture:SetPoint("BOTTOMRIGHT",tab1,"BOTTOMRIGHT",-6,6)
tab1.nTexture:SetColorTexture(0.1,0.1,0.1)
tab1:SetNormalTexture(tab1.nTexture)

tab1.pTexture=tab1:CreateTexture(nil,"BACKGROUND")
tab1.pTexture:SetPoint("TOPLEFT",tab1,"TOPLEFT",6,-6)
tab1.pTexture:SetPoint("BOTTOMRIGHT",tab1,"BOTTOMRIGHT",-6,0)
tab1.pTexture:SetColorTexture(0.07,0.07,0.07)
tab1:SetPushedTexture(tab1.pTexture)

tab1:SetScript("OnClick",function(self)
  self:Disable()
  ff.tabs.tab2:Enable()
  eF.interface.familiesFrame.loadingParaScrollFrame:Hide()
  eF.activeParaWindow:Show()
  end)
  
ff.tabs.tab2=CreateFrame("Button",nil,ff.tabs)
local tab2=ff.tabs.tab2
tab2:SetPoint("LEFT",tab1,"RIGHT",0,0)
tab2:SetHeight(tab1:GetHeight())
tab2:SetWidth(tab1:GetWidth())
tab2:SetBackdrop(bd)

tab2.text=tab2:CreateFontString(nil,"OVERLAY")
tab2.text:SetPoint("CENTER")
tab2.text:SetFont(font2,17,fontExtra)
tab2.text:SetText("Loading Conditions")
tab2.text:SetTextColor(0.9,0.9,0.1)

tab2.nTexture=tab2:CreateTexture(nil,"BACKGROUND")
tab2.nTexture:SetPoint("TOPLEFT",tab2,"TOPLEFT",6,-6)
tab2.nTexture:SetPoint("BOTTOMRIGHT",tab2,"BOTTOMRIGHT",-6,6)
tab2.nTexture:SetColorTexture(0.1,0.1,0.1)
tab2:SetNormalTexture(tab2.nTexture)

tab2.pTexture=tab2:CreateTexture(nil,"BACKGROUND")
tab2.pTexture:SetPoint("TOPLEFT",tab2,"TOPLEFT",6,-6)
tab2.pTexture:SetPoint("BOTTOMRIGHT",tab2,"BOTTOMRIGHT",-6,0)
tab2.pTexture:SetColorTexture(0.07,0.07,0.07)
tab2:SetPushedTexture(tab2.pTexture)

tab2:SetScript("OnClick",function(self) 
  self:Disable()
  ff.tabs.tab1:Enable()
  eF.activeParaWindow:Hide()
  eF.interface.familiesFrame.loadingParaScrollFrame:Show()
  eF.interface.familiesFrame.loadingParaFrame:setLoadActiveValues()
  end)

ff.tabs:Hide()
end

--create loading conditions frame
do
  local function loadAllFrames() 
    eF.units:checkLoad()
  end
  
  local lpsf,lpf
  --frame creation
  do
  ff.loadingParaScrollFrame=CreateFrame("ScrollFrame","eFLoadParaScrollFrame",ff,"UIPanelScrollFrameTemplate")
  lpsf=ff.loadingParaScrollFrame
  lpsf:Hide()
  lpsf:SetFrameLevel(ff:GetFrameLevel()+2)
  lpsf:SetPoint("TOPLEFT",ff.famList,"TOPRIGHT",20,-22)
  lpsf:SetPoint("BOTTOMRIGHT",ff.famList,"BOTTOMRIGHT",20+ff:GetWidth()*0.72,0)
  lpsf:SetClipsChildren(true)
  lpsf:SetScript("OnMouseWheel",ScrollFrame_OnMouseWheel)
  
  lpsf.border=CreateFrame("Frame",nil,ff)
  lpsf.border:SetPoint("TOPLEFT",lpsf,"TOPLEFT",-5,5)
  lpsf.border:SetPoint("BOTTOMRIGHT",lpsf,"BOTTOMRIGHT",5,-5)
  lpsf.border:SetBackdrop(bd)
  
  ff.loadingParaFrame=CreateFrame("Frame","eFlpf",ff)
  lpf=ff.loadingParaFrame
  lpf:SetPoint("TOP",lpsf,"TOP",0,-20)
  lpf:SetWidth(lpsf:GetWidth()*0.8)
  lpf:SetHeight(700)
  lpf.setLoadActiveValues=setLoadActiveValues
  
  lpsf.ScrollBar:ClearAllPoints()
  lpsf.ScrollBar:SetPoint("TOPRIGHT",lpsf,"TOPRIGHT",-6,-18)
  lpsf.ScrollBar:SetPoint("BOTTOMLEFT",lpsf,"BOTTOMRIGHT",-16,18)
  lpsf.ScrollBar.bg=lpsf.ScrollBar:CreateTexture(nil,"BACKGROUND")
  lpsf.ScrollBar.bg:SetAllPoints()
  lpsf.ScrollBar.bg:SetColorTexture(0,0,0,0.5)
  
  lpsf:SetScrollChild(lpf)
  
  lpsf.bg=lpsf:CreateTexture(nil,"BACKGROUND")
  lpsf.bg:SetAllPoints()
  lpsf.bg:SetColorTexture(0.07,0.07,0.07,1)

  end
  
  --[[]]
  --load always
  do
  createCB(lpf,"loadAlways",lpf)
  lpf.loadAlways.text:SetPoint("TOPLEFT",lpf,"TOPLEFT",25,-initSpacing*1.5)
  lpf.loadAlways.text:SetText("Load Always:")
  lpf.loadAlways:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.loadAlways=ch
    if ch then lpf.iconBlocker1:Show() else lpf.iconBlocker1:Hide() end
    loadAllFrames()
  end)
  
  lpf.iconBlocker1=CreateFrame("Button",nil,lpf)
  local iB1=lpf.iconBlocker1
  iB1:SetFrameLevel(lpf:GetFrameLevel()+3)
  iB1:SetPoint("TOPLEFT",lpf.loadAlways.text,"TOPLEFT",-10,-20)
  iB1:SetPoint("BOTTOMRIGHT",lpf,"BOTTOMRIGHT",50,0)
  iB1.texture=iB1:CreateTexture(nil,"OVERLAY")
  iB1.texture:SetAllPoints()
  iB1.texture:SetColorTexture(0.07,0.07,0.07,0.4)
  iB1:Hide()
  
  end

  --unit classes
  do
  local function applyClassParas()
    local insert=table.insert
    local Classes=eF.Classes
    local lst={}
    for i=1,#Classes do
      if lpf["unit"..Classes[i]]:GetChecked() then insert(lst,Classes[i]) end
    end
    eF.activePara.loadUnitClassList=lst
    eF.units:checkLoad()
  end
  
  lpf.title1=lpf:CreateFontString(nil,"OVERLAY")
  local t=lpf.title1
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Load if unit is class:")
  t:SetPoint("TOPLEFT",lpf.loadAlways.text,"TOPLEFT",0,-40)

  lpf.title1Spacer=lpf:CreateTexture(nil,"OVERLAY")
  local tS=lpf.title1Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createCB(lpf,"unitClassLoadAlways",lpf)
  lpf.unitClassLoadAlways.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  lpf.unitClassLoadAlways.text:SetText("Load always:")
  lpf.unitClassLoadAlways:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.unitClassLoadAlways= ch
    if ch then lpf.iconBlocker2:Show() else lpf.iconBlocker2:Hide() end
    loadAllFrames()
  end)
  
  for i=1,#eF.Classes do
  local class=eF.Classes[i]
  local unitClass="unit"..class
  createCB(lpf,unitClass,lpf)
  if i==1 then lpf[unitClass].text:SetPoint("RIGHT",lpf.unitClassLoadAlways.text,"RIGHT",0,-ySpacing*1.5)
  else lpf[unitClass].text:SetPoint("RIGHT",lpf["unit"..eF.Classes[i-1]].text,"RIGHT",0,-ySpacing) end
  lpf[unitClass].text:SetText(class..":")
  lpf[unitClass]:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    applyClassParas()
    loadAllFrames()
  end)
  end--end of for i=1,#eF.Classes
  
  
  lpf.iconBlocker2=CreateFrame("Button",nil,lpf)
  local iB2=lpf.iconBlocker2
  iB2:SetFrameLevel(lpf:GetFrameLevel()+3)
  iB2:SetPoint("TOPLEFT",lpf["unit"..eF.Classes[1]].text,"TOPLEFT",-10,5)
  iB2:SetSize(150,300)
  iB2.texture=iB2:CreateTexture(nil,"OVERLAY")
  iB2.texture:SetAllPoints()
  iB2.texture:SetColorTexture(0.07,0.07,0.07,0.4)  
  iB2:Hide()

  end--end of unit classes
  
  --player classes
  do
  local function applyClassParas()
    local insert=table.insert
    local Classes=eF.Classes
    local lst={}
    for i=1,#Classes do
      if lpf["player"..Classes[i]]:GetChecked() then insert(lst,Classes[i]) end
    end
    eF.activePara.loadPlayerClassList=lst
    eF.units:checkLoad()
  end
  
  lpf.title2=lpf:CreateFontString(nil,"OVERLAY")
  local t=lpf.title2
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Load if player is class:")
  t:SetPoint("LEFT",lpf.title1,"LEFT",160,0)

  lpf.title2Spacer=lpf:CreateTexture(nil,"OVERLAY")
  local tS=lpf.title2Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createCB(lpf,"playerClassLoadAlways",lpf)
  lpf.playerClassLoadAlways.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  lpf.playerClassLoadAlways.text:SetText("Load always:")
  lpf.playerClassLoadAlways:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.playerClassLoadAlways=ch
    if ch then lpf.iconBlocker3:Show() else lpf.iconBlocker3:Hide() end
    loadAllFrames()
  end)
  
  for i=1,#eF.Classes do
  local class=eF.Classes[i]
  local playerClass="player"..class
  createCB(lpf,playerClass,lpf)
  if i==1 then lpf[playerClass].text:SetPoint("RIGHT",lpf.playerClassLoadAlways.text,"RIGHT",0,-ySpacing*1.5)
  else lpf[playerClass].text:SetPoint("RIGHT",lpf["player"..eF.Classes[i-1]].text,"RIGHT",0,-ySpacing) end
  lpf[playerClass].text:SetText(class..":")
  lpf[playerClass]:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    applyClassParas()
    loadAllFrames()
  end)
  end--end of for i=1,#eF.Classes
  
  
  lpf.iconBlocker3=CreateFrame("Button",nil,lpf)
  local iB3=lpf.iconBlocker3
  iB3:SetFrameLevel(lpf:GetFrameLevel()+3)
  iB3:SetPoint("TOPLEFT",lpf["player"..eF.Classes[1]].text,"TOPLEFT",-10,5)
  iB3:SetSize(150,300)
  iB3.texture=iB3:CreateTexture(nil,"OVERLAY")
  iB3.texture:SetAllPoints()
  iB3.texture:SetColorTexture(0.07,0.07,0.07,0.4)  
  iB3:Hide()

  end--end of palyer classes
  
  --player roles
  do
  local function applyRoleParas()
    local insert=table.insert
    local ROLES=eF.ROLES
    local lst={}
    for i=1,#ROLES do
      if lpf["player"..ROLES[i]]:GetChecked() then insert(lst,ROLES[i]) end
    end
    eF.activePara.loadPlayerRoleList=lst
    eF.units:checkLoad()
  end
  
  lpf.title3=lpf:CreateFontString(nil,"OVERLAY")
  local t=lpf.title3
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Load if player is role:")
  t:SetPoint("LEFT",lpf.title2,"LEFT",160,0)

  lpf.title3Spacer=lpf:CreateTexture(nil,"OVERLAY")
  local tS=lpf.title3Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createCB(lpf,"playerRoleLoadAlways",lpf)
  lpf.playerRoleLoadAlways.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  lpf.playerRoleLoadAlways.text:SetText("Load always:")
  lpf.playerRoleLoadAlways:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.playerRoleLoadAlways=ch
    if ch then lpf.iconBlocker4:Show() else lpf.iconBlocker4:Hide() end
    loadAllFrames()
  end)
  
  for i=1,#eF.ROLES do
  local ROLE=eF.ROLES[i]
  local playerROLE="player"..ROLE
  createCB(lpf,playerROLE,lpf)
  if i==1 then lpf[playerROLE].text:SetPoint("RIGHT",lpf.playerRoleLoadAlways.text,"RIGHT",0,-ySpacing*1.5)
  else lpf[playerROLE].text:SetPoint("RIGHT",lpf["player"..eF.ROLES[i-1]].text,"RIGHT",0,-ySpacing) end
  lpf[playerROLE].text:SetText(ROLE..":")
  lpf[playerROLE]:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    applyRoleParas()
    loadAllFrames()
  end)
  end--end of for i=1,#eF.ROLES
  
  
  lpf.iconBlocker4=CreateFrame("Button",nil,lpf)
  local iB4=lpf.iconBlocker4
  iB4:SetFrameLevel(lpf:GetFrameLevel()+3)
  iB4:SetPoint("TOPLEFT",lpf["player"..eF.ROLES[1]].text,"TOPLEFT",-10,5)
  iB4:SetSize(150,100)
  iB4.texture=iB4:CreateTexture(nil,"OVERLAY")
  iB4.texture:SetAllPoints()
  iB4.texture:SetColorTexture(0.07,0.07,0.07,0.4)  
  iB4:Hide()

  end--end of palyer roles
  
  --unit roles
  do
  local function applyRoleParas()
    local insert=table.insert
    local ROLES=eF.ROLES
    local lst={}
    for i=1,#ROLES do
      if lpf["unit"..ROLES[i]]:GetChecked() then insert(lst,ROLES[i]) end
    end
    eF.activePara.loadUnitRoleList=lst
    eF.units:checkLoad()
  end
  
  lpf.title4=lpf:CreateFontString(nil,"OVERLAY")
  local t=lpf.title4
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Load if unit is role:")
  t:SetPoint("LEFT",lpf.title3,"LEFT",0,-180)

  lpf.title4Spacer=lpf:CreateTexture(nil,"OVERLAY")
  local tS=lpf.title4Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createCB(lpf,"unitRoleLoadAlways",lpf)
  lpf.unitRoleLoadAlways.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  lpf.unitRoleLoadAlways.text:SetText("Load always:")
  lpf.unitRoleLoadAlways:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.unitRoleLoadAlways=ch
    if ch then lpf.iconBlocker5:Show() else lpf.iconBlocker5:Hide() end
    loadAllFrames()
  end)
  
  for i=1,#eF.ROLES do
  local ROLE=eF.ROLES[i]
  local unitROLE="unit"..ROLE
  createCB(lpf,unitROLE,lpf)
  if i==1 then lpf[unitROLE].text:SetPoint("RIGHT",lpf.unitRoleLoadAlways.text,"RIGHT",0,-ySpacing*1.5)
  else lpf[unitROLE].text:SetPoint("RIGHT",lpf["unit"..eF.ROLES[i-1]].text,"RIGHT",0,-ySpacing) end
  lpf[unitROLE].text:SetText(ROLE..":")
  lpf[unitROLE]:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    applyRoleParas()
    loadAllFrames()
  end)
  end--end of for i=1,#eF.ROLES
  
  
  lpf.iconBlocker5=CreateFrame("Button",nil,lpf)
  local iB5=lpf.iconBlocker5
  iB5:SetFrameLevel(lpf:GetFrameLevel()+3)
  iB5:SetPoint("TOPLEFT",lpf["unit"..eF.ROLES[1]].text,"TOPLEFT",-10,5)
  iB5:SetSize(150,100)
  iB5.texture=iB5:CreateTexture(nil,"OVERLAY")
  iB5.texture:SetAllPoints()
  iB5.texture:SetColorTexture(0.07,0.07,0.07,0.4)  
  iB5:Hide()

  end--end of unit roles
  
 
  --GetInstanceInfo()
  --instance IDs
  do
  lpf.title5=lpf:CreateFontString(nil,"OVERLAY")
  local t=lpf.title5
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Load in instances:")
  t:SetPoint("LEFT",lpf.title1,"LEFT",0,-400)

  lpf.title5Spacer=lpf:CreateTexture(nil,"OVERLAY")
  local tS=lpf.title5Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)
  
  createCB(lpf,"instanceLoadAlways",lpf)
  lpf.instanceLoadAlways.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  lpf.instanceLoadAlways.text:SetText("Load always:")
  lpf.instanceLoadAlways:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.instanceLoadAlways=ch
    if ch then lpf.iconBlocker6:Show() else lpf.iconBlocker6:Hide() end
    loadAllFrames()
  end)
  
  createListCB(lpf,"loadInstanceList",lpf)
  lpf.loadInstanceList:SetPoint("TOPLEFT",lpf.instanceLoadAlways.text,"TOPLEFT",0,-ySpacing)
  lpf.loadInstanceList.button:SetScript("OnClick", function(self)
  local sfind,ssub,insert=strfind,strsub,table.insert
  local x=self.eb:GetText()
  self:Disable()
  self.eb:ClearFocus()
  local old=0
  local new=0
  local antiCrash=0
  local rtbl={}
  while new do
    new=sfind(x,"\n",old+1)
    local ss=ssub(x,old,new)
    insert(rtbl,ss:match("^%s*(.-)%s*$"))
    old=new
    antiCrash=antiCrash+1
    if antiCrash>500 then break end
  end
  eF.activePara.loadInstanceList=rtbl
  loadAllFrames()
  end) 
  
  lpf.iconBlocker6=CreateFrame("Button",nil,lpf)
  local iB6=lpf.iconBlocker6
  iB6:SetFrameLevel(lpf:GetFrameLevel()+3)
  iB6:SetPoint("TOPLEFT",lpf.loadInstanceList,"TOPLEFT",-10,5)
  iB6:SetPoint("BOTTOMRIGHT",lpf.loadInstanceList,"BOTTOMRIGHT",20,-30)
  iB6.texture=iB6:CreateTexture(nil,"OVERLAY")
  iB6.texture:SetAllPoints()
  iB6.texture:SetColorTexture(0.07,0.07,0.07,0.4)  
  iB6:Hide()
  end
  
  --http://www.wowinterface.com/forums/showthread.php?t=48377
  --https://wow.gamepedia.com/ENCOUNTER_START
  --encounters
  do
  lpf.title6=lpf:CreateFontString(nil,"OVERLAY")
  local t=lpf.title6
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Load in encounters:")
  t:SetPoint("LEFT",lpf.title5,"LEFT",270,0)

  lpf.title6Spacer=lpf:CreateTexture(nil,"OVERLAY")
  local tS=lpf.title6Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)
  
  createCB(lpf,"encounterLoadAlways",lpf)
  lpf.encounterLoadAlways.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  lpf.encounterLoadAlways.text:SetText("Load always:")
  lpf.encounterLoadAlways:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.encounterLoadAlways=ch
    if ch then lpf.iconBlocker7:Show() else lpf.iconBlocker7:Hide() end
    loadAllFrames()
  end)
  
  createListCB(lpf,"loadEncounterList",lpf)
  lpf.loadEncounterList:SetPoint("TOPLEFT",lpf.encounterLoadAlways.text,"TOPLEFT",0,-ySpacing)
  lpf.loadEncounterList.button:SetScript("OnClick", function(self)
  local sfind,ssub,insert=strfind,strsub,table.insert
  local x=self.eb:GetText()
  self:Disable()
  self.eb:ClearFocus()
  local old=0
  local new=0
  local antiCrash=0
  local rtbl={}
  while new do
    new=sfind(x,"\n",old+1)
    local ss=ssub(x,old,new)
    insert(rtbl,ss:match("^%s*(.-)%s*$"))
    old=new
    antiCrash=antiCrash+1
    if antiCrash>500 then break end
  end
  eF.activePara.loadEncounterList=rtbl
  loadAllFrames()
  end) 
  
  lpf.iconBlocker7=CreateFrame("Button",nil,lpf)
  local iB7=lpf.iconBlocker7
  iB7:SetFrameLevel(lpf:GetFrameLevel()+3)
  iB7:SetPoint("TOPLEFT",lpf.loadEncounterList,"TOPLEFT",-10,5)
  iB7:SetPoint("BOTTOMRIGHT",lpf.loadEncounterList,"BOTTOMRIGHT",20,-30)
  iB7.texture=iB7:CreateTexture(nil,"OVERLAY")
  iB7.texture:SetAllPoints()
  iB7.texture:SetColorTexture(0.07,0.07,0.07,0.4)  
  iB7:Hide()
  end
  
end

--create dumb family frame 
do
  local dff,dfsf
  --create scroll frame + box etc
  do
  ff.dumbFamilyScrollFrame=CreateFrame("ScrollFrame","eFdumbFamilyScrollFrame",ff,"UIPanelScrollFrameTemplate")
  dfsf=ff.dumbFamilyScrollFrame
  dfsf:SetPoint("TOPLEFT",ff.famList,"TOPRIGHT",20,-22)
  dfsf:SetPoint("BOTTOMRIGHT",ff.famList,"BOTTOMRIGHT",20+ff:GetWidth()*0.72,0)
  dfsf:SetClipsChildren(true)
  dfsf:SetScript("OnMouseWheel",ScrollFrame_OnMouseWheel)
  
  dfsf.border=CreateFrame("Frame",nil,ff)
  dfsf.border:SetPoint("TOPLEFT",dfsf,"TOPLEFT",-5,5)
  dfsf.border:SetPoint("BOTTOMRIGHT",dfsf,"BOTTOMRIGHT",5,-5)
  dfsf.border:SetBackdrop(bd)
  
  ff.dumbFamilyFrame=CreateFrame("Frame","eFdff",ff)
  dff=ff.dumbFamilyFrame
  dff:SetPoint("TOP",dfsf,"TOP",0,-20)
  dff:SetWidth(dfsf:GetWidth()*0.8)
  dff:SetHeight(dfsf:GetHeight()*1.2)
 
  dfsf.ScrollBar:ClearAllPoints()
  dfsf.ScrollBar:SetPoint("TOPRIGHT",dfsf,"TOPRIGHT",-6,-18)
  dfsf.ScrollBar:SetPoint("BOTTOMLEFT",dfsf,"BOTTOMRIGHT",-16,18)
  dfsf.ScrollBar.bg=dfsf.ScrollBar:CreateTexture(nil,"BACKGROUND")
  dfsf.ScrollBar.bg:SetAllPoints()
  dfsf.ScrollBar.bg:SetColorTexture(0,0,0,0.5)
  
  dfsf:SetScrollChild(dff)
  
  dfsf.bg=dfsf:CreateTexture(nil,"BACKGROUND")
  dfsf.bg:SetAllPoints()
  dfsf.bg:SetColorTexture(0.07,0.07,0.07,1)

  dff.setValues=setDFFActiveValues
  end --end of scroll frame + box etc
  
  
  --general stuff
  do
  dff.title1=dff:CreateFontString(nil,"OVERLAY")
  local t=dff.title1
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("General")
  t:SetPoint("TOPLEFT",dff,"TOPLEFT",50,-25)

  dff.title1Spacer=dff:CreateTexture(nil,"OVERLAY")
  local tS=dff.title1Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createNumberEB(dff,"name",dff)
  dff.name.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  dff.name.text:SetText("Name:")
  dff.name:SetWidth(80)
  dff.name:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  name=self:GetText()
  if not name or name=="" then name=eF.activePara.displayName; self:SetText(name)
  else 
    eF.activePara.displayName=name; 
    eF.activeButton.text:SetText(name)
  end
  end)
  
  
  end --end of general
  
end --end of create dumb FF

--create child icon frame
do
  
  local cisf,cif
  
  --create scroll frame + box etc
  do
  
  ff.childIconScrollFrame=CreateFrame("ScrollFrame","eFChildIconScrollFrame",ff,"UIPanelScrollFrameTemplate")
  cisf=ff.childIconScrollFrame
  cisf:SetPoint("TOPLEFT",ff.famList,"TOPRIGHT",20,-22)
  cisf:SetPoint("BOTTOMRIGHT",ff.famList,"BOTTOMRIGHT",20+ff:GetWidth()*0.72,0)
  cisf:SetClipsChildren(true)
  cisf:SetScript("OnMouseWheel",ScrollFrame_OnMouseWheel)
  
  cisf.border=CreateFrame("Frame",nil,ff)
  cisf.border:SetPoint("TOPLEFT",cisf,"TOPLEFT",-5,5)
  cisf.border:SetPoint("BOTTOMRIGHT",cisf,"BOTTOMRIGHT",5,-5)
  cisf.border:SetBackdrop(bd)
  
  ff.childIconFrame=CreateFrame("Frame","eFcif",ff)
  cif=ff.childIconFrame
  cif:SetPoint("TOP",cisf,"TOP",0,-20)
  cif:SetWidth(cisf:GetWidth()*0.8)
  cif:SetHeight(cisf:GetHeight()*1.65)
 
  cisf.ScrollBar:ClearAllPoints()
  cisf.ScrollBar:SetPoint("TOPRIGHT",cisf,"TOPRIGHT",-6,-18)
  cisf.ScrollBar:SetPoint("BOTTOMLEFT",cisf,"BOTTOMRIGHT",-16,18)
  cisf.ScrollBar.bg=cisf.ScrollBar:CreateTexture(nil,"BACKGROUND")
  cisf.ScrollBar.bg:SetAllPoints()
  cisf.ScrollBar.bg:SetColorTexture(0,0,0,0.5)
  
  cisf:SetScrollChild(cif)
  
  cisf.bg=cisf:CreateTexture(nil,"BACKGROUND")
  cisf.bg:SetAllPoints()
  cisf.bg:SetColorTexture(0.07,0.07,0.07,1)

  cif.setValues=setCIFActiveValues
  end --end of scroll frame + box etc
  
  --create general settings stuff
  do
  cif.title1=cif:CreateFontString(nil,"OVERLAY")
  local t=cif.title1
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("General")
  t:SetPoint("TOPLEFT",cif,"TOPLEFT",50,-25)

  cif.title1Spacer=cif:CreateTexture(nil,"OVERLAY")
  local tS=cif.title1Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createNumberEB(cif,"name",cif)
  cif.name.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  cif.name.text:SetText("Name:")
  cif.name:SetWidth(80)
  cif.name:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  name=self:GetText()
  if not name or name=="" then name=eF.activePara.displayName; self:SetText(name)
  else 
    eF.activePara.displayName=name; 
    eF.activeButton.text:SetText(name)
  end
  end)

  createNewDD(cif,"trackType",cif,75)
  cif.trackType.text:SetPoint("RIGHT",cif.name.text,"RIGHT",0,-ySpacing)
  cif.trackType.text:SetText("Tracks:")
  
  local lf=function(self)
    eF.activePara.trackType=self.arg   
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
    if self.arg=="Static" then cif.iconBlocker6:Show() else cif.iconBlocker6:Hide() end
  end
  local lst={"Buffs","Debuffs","Static"}
  for i=1,#lst do
    local v=lst[i]
    cif.trackType:addButton(v,lf,v)
  end
  

  
  createNewDD(cif,"trackBy",cif,75)
  cif.trackBy.text:SetPoint("RIGHT",cif.trackType.text,"RIGHT",0,-ySpacing)
  cif.trackBy.text:SetText("Track by:")
  local lf=function(self)
    eF.activePara.trackBy=self.arg   
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  local lst={"Name","Spell ID"}
  for i=1,#lst do
    local v=lst[i]
    cif.trackBy:addButton(v,lf,v)
  end

  
  createNumberEB(cif,"spell",cif)
  cif.spell.text:SetPoint("RIGHT",cif.trackBy.text,"RIGHT",0,-ySpacing)
  cif.spell.text:SetText("Spell:")
  cif.spell:SetWidth(80)
  cif.spell:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  spell=self:GetText()
  if (tonumber(spell)) then spell=tonumber(spell) end
  if not spell or spell=="" then spell=eF.activePara.arg1; self:SetText(spell)
  else 
    eF.activePara.arg1=spell;
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  end)

  
  createCB(cif,"ownOnly",cif)
  cif.ownOnly.text:SetPoint("RIGHT",cif.spell.text,"RIGHT",0,-ySpacing)
  cif.ownOnly.text:SetText("Own only:")
  cif.ownOnly:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.ownOnly=ch
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)
  
  cif.iconBlocker6=CreateFrame("Button",nil,cif)
  local iB1=cif.iconBlocker6
  iB1:SetFrameLevel(cif:GetFrameLevel()+3)
  iB1:SetPoint("TOPRIGHT",cif.trackBy,"TOPRIGHT",35,2)
  iB1:SetPoint("BOTTOMLEFT",cif.ownOnly.text,"BOTTOMLEFT",-2,-2)
  iB1.texture=iB1:CreateTexture(nil,"OVERLAY")
  iB1.texture:SetAllPoints()
  iB1.texture:SetColorTexture(0.07,0.07,0.07,0.4)
  
  end--end of general settings

  --create layout settings
  do
  cif.title2=cif:CreateFontString(nil,"OVERLAY")
  local t=cif.title2
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Layout")
  t:SetPoint("TOPLEFT",cif.title1,"TOPLEFT",220,0)

  cif.title2Spacer=cif:CreateTexture(nil,"OVERLAY")
  local tS=cif.title2Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createNumberEB(cif,"width",cif)
  cif.width.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  cif.width.text:SetText("Width:")
  cif.width:SetWidth(30)
  cif.width:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  w=self:GetNumber()
  if not w or w==0 then w=eF.activePara.width; self:SetText(w)
  else 
    eF.activePara.width=w;
  end
  updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)

  createNumberEB(cif,"height",cif)
  cif.height.text:SetPoint("RIGHT",cif.width.text,"RIGHT",0,-ySpacing)
  cif.height.text:SetText("Height:")
  cif.height:SetWidth(30)
  cif.height:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  h=self:GetNumber()
  if not h or h==0 then h=eF.activePara.height; self:SetText(h)
  else 
    eF.activePara.height=h;
  end
  updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)
  
  createNumberEB(cif,"xPos",cif)
  cif.xPos.text:SetPoint("RIGHT",cif.height.text,"RIGHT",0,-ySpacing)
  cif.xPos.text:SetText("X Offset:")
  cif.xPos:SetWidth(30)
  cif.xPos:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  x=self:GetText()
  x=tonumber(x)
  if not x then x=eF.activePara.xPos; self:SetText(x); 
  else 
    eF.activePara.xPos=x;
  end
  updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)

  createNumberEB(cif,"yPos",cif)
  cif.yPos.text:SetPoint("RIGHT",cif.xPos.text,"RIGHT",0,-ySpacing)
  cif.yPos.text:SetText("Y Offset:")
  cif.yPos:SetWidth(30)
  cif.yPos:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  x=self:GetText()
  x=tonumber(x)
  if not x  then x=eF.activePara.yPos; self:SetText(x)
  else 
    eF.activePara.yPos=x;
  end
  updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)

  createNewDD(cif,"anchor",cif,85)
  cif.anchor.text:SetPoint("RIGHT",cif.yPos.text,"RIGHT",0,-ySpacing)
  cif.anchor.text:SetText("Position:")
  
  local lf=function(self)
    eF.activePara.anchor=self.arg   
    eF.activePara.anchorTo=self.arg   
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  local lst=eF.positions
  for i=1,#lst do
    local v=lst[i]
    cif.anchor:addButton(v,lf,v)
  end


  end--end of layout settings

  --create icon settings
  do
  cif.title3=cif:CreateFontString(nil,"OVERLAY")
  local t=cif.title3
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Icon")
  t:SetPoint("TOPLEFT",cif.title1,"TOPLEFT",0,-170)

  cif.title3Spacer=cif:CreateTexture(nil,"OVERLAY")
  local tS=cif.title3Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createCB(cif,"iconCB",cif)
  cif.iconCB.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  cif.iconCB.text:SetText("Has Icon:")
  cif.iconCB:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.hasTexture=ch
    if not ch then cif.iconBlocker1:Show();cif.iconBlocker2:Show() else cif.iconBlocker1:Hide();cif.iconBlocker2:Hide() end
    if eF.activePara.smartIcon then cif.iconBlocker2:Show() end
    eF.activePara.hasTexture=ch
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)


  createCB(cif,"smartIcon",cif)
  cif.smartIcon.text:SetPoint("RIGHT",cif.iconCB.text,"RIGHT",0,-ySpacing)
  cif.smartIcon.text:SetText("Smart Icon:")
  cif.smartIcon:SetScript("OnClick",function(self)
    if cif.iconBlocked1 then self.SetChecked(not self:GetChecked());return end
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.smartIcon=ch
    if ch then cif.iconBlocker2:Show() else cif.iconBlocker2:Hide() end
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)


  cif.iconBlocker1=CreateFrame("Button",nil,cif)
  local iB1=cif.iconBlocker1
  iB1:SetFrameLevel(cif:GetFrameLevel()+3)
  iB1:SetPoint("TOPRIGHT",cif.smartIcon,"TOPRIGHT",2,2)
  iB1:SetPoint("BOTTOMLEFT",cif.smartIcon.text,"BOTTOMLEFT",-2,-2)
  iB1.texture=iB1:CreateTexture(nil,"OVERLAY")
  iB1.texture:SetAllPoints()
  iB1.texture:SetColorTexture(0.07,0.07,0.07,0.4)


  createIP(cif,"icon",cif)
  cif.icon.text:SetPoint("RIGHT",cif.smartIcon.text,"RIGHT",0,-ySpacing)
  cif.icon.text:SetText("Texture:")
  cif.icon:SetWidth(60)
  cif.icon:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  x=self:GetText()
  if not x  then x=eF.activePara.texture; self:SetText(x)
  else 
    eF.activePara.texture=x;
    self.pTexture:SetTexture(x)
  end
  updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)
  --NYI: update without reload



  createCS(cif,"textureColor",cif)
  local tC=cif.textureColor
  tC.text:SetPoint("RIGHT",cif.icon.text,"RIGHT",0,-ySpacing)
  tC.text:SetText("Color:")
  tC.getOldRGBA=function()
    local r=eF.activePara.textureR
    local g=eF.activePara.textureG
    local b=eF.activePara.textureB
  return r,g,b
  end
  
  tC.opacityFunc=function()
    local r,g,b=ColorPickerFrame:GetColorRGB()
    local a=OpacitySliderFrame:GetValue()
    tC.thumb:SetVertexColor(r,g,b)
    eF.activePara.textureR=r
    eF.activePara.textureG=g
    eF.activePara.textureB=b
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex) 
  end

  cif.iconBlocker2=CreateFrame("Button",nil,cif)
  local iB2=cif.iconBlocker2
  iB2:SetFrameLevel(cif:GetFrameLevel()+3)
  iB2:SetPoint("TOPLEFT",cif.icon.text,"TOPLEFT",-2,12)
  iB2:SetHeight(25)
  iB2:SetWidth(175)
  iB2.texture=iB2:CreateTexture(nil,"OVERLAY")
  iB2.texture:SetAllPoints()
  iB2.texture:SetColorTexture(0.07,0.07,0.07,0.4)
  
  end --end of icon settings

  --create CDwheel settings
  do
  cif.title4=cif:CreateFontString(nil,"OVERLAY")
  local t=cif.title4
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("CD Wheel")
  t:SetPoint("TOPLEFT",cif.title3,"TOPLEFT",225,0)

  cif.title4Spacer=cif:CreateTexture(nil,"OVERLAY")
  local tS=cif.title4Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createCB(cif,"cdWheel",cif)
  cif.cdWheel.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  cif.cdWheel.text:SetText("Has CD wheel:")
  cif.cdWheel:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.cdWheel=ch
    if not ch then cif.iconBlocker3:Show() else cif.iconBlocker3:Hide() end
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)


  createCB(cif,"cdReverse",cif)
  cif.cdReverse.text:SetPoint("RIGHT",cif.cdWheel.text,"RIGHT",0,-ySpacing)
  cif.cdReverse.text:SetText("Reverse spin:")
  cif.cdReverse:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.cdReverse=ch
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)


  cif.iconBlocker3=CreateFrame("Button",nil,cif)
  local iB3=cif.iconBlocker3
  iB3:SetFrameLevel(cif:GetFrameLevel()+3)
  iB3:SetPoint("TOPLEFT",cif.cdReverse.text,"TOPLEFT",-2,12)
  iB3:SetHeight(50)
  iB3:SetWidth(200)
  iB3.texture=iB3:CreateTexture(nil,"OVERLAY")
  iB3.texture:SetAllPoints()
  iB3.texture:SetColorTexture(0.07,0.07,0.07,0.4)
  end --end of CDwheel settings

  --create border settings
  do
  cif.title5=cif:CreateFontString(nil,"OVERLAY")
  local t=cif.title5
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Border")
  t:SetPoint("TOPLEFT",cif.title4,"TOPLEFT",0,-80)

  cif.title5Spacer=cif:CreateTexture(nil,"OVERLAY")
  local tS=cif.title5Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createCB(cif,"hasBorder",cif)
  cif.hasBorder.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  cif.hasBorder.text:SetText("Has Border:")
  cif.hasBorder:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.hasBorder=ch
    if not ch then cif.iconBlocker4:Show() else cif.iconBlocker4:Hide() end
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)
  --NYI not hiding border
  
  createNewDD(cif,"borderType",cif,75)
  cif.borderType.text:SetPoint("RIGHT",cif.hasBorder.text,"RIGHT",0,-ySpacing)
  cif.borderType.text:SetText("Border type:")
  
  local lf=function(self)
    eF.activePara.borderType=self.arg   
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  local lst={"debuffColor"}
  for i=1,#lst do
    local v=lst[i]
    cif.borderType:addButton(v,lf,v)
  end

  cif.iconBlocker4=CreateFrame("Button",nil,cif)
  local iB4=cif.iconBlocker4
  iB4:SetFrameLevel(cif:GetFrameLevel()+3)
  iB4:SetPoint("TOPLEFT",cif.borderType.text,"TOPLEFT",-2,12)
  iB4:SetHeight(50)
  iB4:SetWidth(200)
  iB4.texture=iB4:CreateTexture(nil,"OVERLAY")
  iB4.texture:SetAllPoints()
  iB4.texture:SetColorTexture(0.07,0.07,0.07,0.4)

  end --end of border settings

  --create text1 settings
  do
  cif.title6=cif:CreateFontString(nil,"OVERLAY")
  local t=cif.title6
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Text 1")
  t:SetPoint("TOPLEFT",cif.title3,"TOPLEFT",0,-115)

  cif.title6Spacer=cif:CreateTexture(nil,"OVERLAY")
  local tS=cif.title6Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createCB(cif,"hasText1",cif)
  cif.hasText1.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  cif.hasText1.text:SetText("Text 1:")
  cif.hasText1:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.hasText=ch
    if not ch then cif.iconBlocker5:Show() else cif.iconBlocker5:Hide() end
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)
  --NYI not hiding border
  
  createNewDD(cif,"textType1",cif)
  cif.textType1.text:SetPoint("RIGHT",cif.hasText1.text,"RIGHT",0,-ySpacing)
  cif.textType1.text:SetText("Text type:")
  
  local lf=function(self)
    eF.activePara.textType=self.arg   
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  local lst={"Time left","Stacks"}
  for i=1,#lst do
    local v=lst[i]
    cif.textType1:addButton(v,lf,v)
  end

  createCS(cif,"textColor1",cif)
  cif.textColor1.text:SetPoint("RIGHT",cif.textType1.text,"RIGHT",0,-ySpacing)
  cif.textColor1.text:SetText("Color:")
  cif.textColor1.getOldRGBA=function(self)
    local r=eF.activePara.textR
    local g=eF.activePara.textG
    local b=eF.activePara.textB
    return r,g,b
  end

  cif.textColor1.opacityFunc=function()
    local r,g,b=ColorPickerFrame:GetColorRGB()
    local a=OpacitySliderFrame:GetValue()
    cif.textColor1.thumb:SetVertexColor(r,g,b)
    eF.activePara.textR=r
    eF.activePara.textG=g
    eF.activePara.textB=b
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end


  createNumberEB(cif,"textDecimals1",cif)
  cif.textDecimals1.text:SetPoint("RIGHT",cif.textColor1.text,"RIGHT",0,-ySpacing)
  cif.textDecimals1.text:SetText("Decimals:")
  cif.textDecimals1:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  n=self:GetNumber()
  if not n then n=eF.activePara.textDecimals; self:SetText(n)
  else eF.activePara.textDecimals=n end
  end)

  createNumberEB(cif,"fontSize1",cif)
  cif.fontSize1.text:SetPoint("RIGHT",cif.textDecimals1.text,"RIGHT",0,-ySpacing)
  cif.fontSize1.text:SetText("Font size:")
  cif.fontSize1:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  n=self:GetNumber()
  if n==0 then n=eF.activePara.textSize; self:SetText(n)
  else eF.activePara.textSize=n; updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex) end
  end)


  createNumberEB(cif,"textA1",cif)
  cif.textA1.text:SetPoint("RIGHT",cif.fontSize1.text,"RIGHT",0,-ySpacing)
  cif.textA1.text:SetText("Alpha:")
  cif.textA1:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  a=self:GetNumber()
  eF.activePara.textA=a
  updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)


  createNewDD(cif,"textFont1",cif)
  cif.textFont1.text:SetPoint("RIGHT",cif.textA1.text,"RIGHT",0,-ySpacing)
  cif.textFont1.text:SetText("Font:")
  local lf=function(self)
    eF.activePara.textFont=self.arg   
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  local lst=eF.fonts
  for i=1,#lst do
    local v=lst[i]
    local font="Fonts\\"..v..".ttf"
    cif.textFont1:addButton(v,lf,font)
  end

  createNewDD(cif,"textAnchor1",cif)
  cif.textAnchor1.text:SetPoint("RIGHT",cif.textFont1.text,"RIGHT",0,-ySpacing)
  cif.textAnchor1.text:SetText("Position:")
  
  local lf=function(self)
    eF.activePara.textAnchor=self.arg
    eF.activePara.textAnchorTo=self.arg
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  local lst=eF.positions
  for i=1,#lst do
    local v=lst[i]
    cif.textAnchor1:addButton(v,lf,v)
  end

  
  createNumberEB(cif,"textXOS1",cif)
  cif.textXOS1.text:SetPoint("RIGHT",cif.textAnchor1.text,"RIGHT",0,-ySpacing)
  cif.textXOS1.text:SetText("X Offset:")
  cif.textXOS1:SetWidth(30)
  cif.textXOS1:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  x=self:GetText()
  x=tonumber(x)
  if not x then x=eF.activePara.textXOS; self:SetText(x); 
  else 
    eF.activePara.textXOS=x;
  end
  updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)

  createNumberEB(cif,"textYOS1",cif)
  cif.textYOS1.text:SetPoint("RIGHT",cif.textXOS1.text,"RIGHT",0,-ySpacing)
  cif.textYOS1.text:SetText("Y Offset:")
  cif.textYOS1:SetWidth(30)
  cif.textYOS1:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  x=self:GetText()
  x=tonumber(x)
  if not x  then x=eF.activePara.textYOS; self:SetText(x)
  else 
    eF.activePara.textYOS=x;
  end
  updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)

  
  cif.iconBlocker5=CreateFrame("Button",nil,cif)
  local iB5=cif.iconBlocker5
  iB5:SetFrameLevel(cif:GetFrameLevel()+3)
  iB5:SetPoint("TOPLEFT",cif.textType1.text,"TOPLEFT",-2,12)
  iB5:SetPoint("BOTTOMRIGHT",cif.textYOS1,"BOTTOMRIGHT",58,-3)
  iB5:SetWidth(200)
  iB5.texture=iB5:CreateTexture(nil,"OVERLAY")
  iB5.texture:SetAllPoints()
  iB5.texture:SetColorTexture(0.07,0.07,0.07,0.4)

  end --end of text settings

  --create text2 settings
  do
  cif.title7=cif:CreateFontString(nil,"OVERLAY")
  local t=cif.title7
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Text 2")
  t:SetPoint("TOPLEFT",cif.title6,"TOPLEFT",250,-50)

  cif.title7Spacer=cif:CreateTexture(nil,"OVERLAY")
  local tS=cif.title7Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createCB(cif,"hasText2",cif)
  cif.hasText2.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  cif.hasText2.text:SetText("Text2:")
  cif.hasText2:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.hasText2=ch
    if not ch then cif.iconBlocker7:Show() else cif.iconBlocker7:Hide() end
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)
  --NYI not hiding border
  
  createNewDD(cif,"text2Type",cif)
  cif.text2Type.text:SetPoint("RIGHT",cif.hasText2.text,"RIGHT",0,-ySpacing)
  cif.text2Type.text:SetText("Text type:")
  
  local lf=function(self)
    eF.activePara.text2Type=self.arg   
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  local lst={"Time left","Stacks"}
  for i=1,#lst do
    local v=lst[i]
    cif.text2Type:addButton(v,lf,v)
  end

  
  createCS(cif,"text2Color",cif)
  cif.text2Color.text:SetPoint("RIGHT",cif.text2Type.text,"RIGHT",0,-ySpacing)
  cif.text2Color.text:SetText("Color:")
  cif.text2Color.getOldRGBA=function(self)
    local r=eF.activePara.text2R
    local g=eF.activePara.text2G
    local b=eF.activePara.text2B
    return r,g,b
  end

  cif.text2Color.opacityFunc=function()
    local r,g,b=ColorPickerFrame:GetColorRGB()
    local a=OpacitySliderFrame:GetValue()
    cif.text2Color.thumb:SetVertexColor(r,g,b)
    eF.activePara.text2R=r
    eF.activePara.text2G=g
    eF.activePara.text2B=b
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end


  createNumberEB(cif,"text2Decimals",cif)
  cif.text2Decimals.text:SetPoint("RIGHT",cif.text2Color.text,"RIGHT",0,-ySpacing)
  cif.text2Decimals.text:SetText("Decimals:")
  cif.text2Decimals:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  n=self:GetNumber()
  if not n then n=eF.activePara.text2Decimals; self:SetText(n)
  else eF.activePara.text2Decimals=n end
  end)

  createNumberEB(cif,"fontSize2",cif)
  cif.fontSize2.text:SetPoint("RIGHT",cif.text2Decimals.text,"RIGHT",0,-ySpacing)
  cif.fontSize2.text:SetText("Font size:")
  cif.fontSize2:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  n=self:GetNumber()
  if n==0 then n=eF.activePara.text2Size; self:SetText(n)
  else eF.activePara.text2Size=n; updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex) end
  end)


  createNumberEB(cif,"text2A",cif)
  cif.text2A.text:SetPoint("RIGHT",cif.fontSize2.text,"RIGHT",0,-ySpacing)
  cif.text2A.text:SetText("Alpha:")
  cif.text2A:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  a=self:GetNumber()
  eF.activePara.text2A=a
  updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)


  createNewDD(cif,"text2Font",cif)
  cif.text2Font.text:SetPoint("RIGHT",cif.text2A.text,"RIGHT",0,-ySpacing)
  cif.text2Font.text:SetText("Font:")
  
  local lf=function(self)
    eF.activePara.text2Font=self.arg   
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  local lst=eF.fonts
  for i=1,#lst do
    local v=lst[i]
    local font="Fonts\\"..v..".ttf"
    cif.text2Font:addButton(v,lf,font)
  end
  
  createNewDD(cif,"text2Anchor",cif)
  cif.text2Anchor.text:SetPoint("RIGHT",cif.text2Font.text,"RIGHT",0,-ySpacing)
  cif.text2Anchor.text:SetText("Position:")
  
  local lf=function(self)
    eF.activePara.text2Anchor=self.arg   
    eF.activePara.text2AnchorTo=self.arg   
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  local lst=eF.positions
  for i=1,#lst do
    local v=lst[i]
    cif.text2Anchor:addButton(v,lf,v)
  end 
  
  createNumberEB(cif,"text2XOS",cif)
  cif.text2XOS.text:SetPoint("RIGHT",cif.text2Anchor.text,"RIGHT",0,-ySpacing)
  cif.text2XOS.text:SetText("X Offset:")
  cif.text2XOS:SetWidth(30)
  cif.text2XOS:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  x=self:GetText()
  x=tonumber(x)
  if not x then x=eF.activePara.text2XOS; self:SetText(x); 
  else 
    eF.activePara.text2XOS=x;
  end
  updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)

  createNumberEB(cif,"text2YOS",cif)
  cif.text2YOS.text:SetPoint("RIGHT",cif.text2XOS.text,"RIGHT",0,-ySpacing)
  cif.text2YOS.text:SetText("Y Offset:")
  cif.text2YOS:SetWidth(30)
  cif.text2YOS:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  x=self:GetText()
  x=tonumber(x)
  if not x  then x=eF.activePara.text2YOS; self:SetText(x)
  else 
    eF.activePara.text2YOS=x;
  end
  updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)

  
  cif.iconBlocker7=CreateFrame("Button",nil,cif)
  local iB7=cif.iconBlocker7
  iB7:SetFrameLevel(cif:GetFrameLevel()+3)
  iB7:SetPoint("TOPLEFT",cif.text2Type.text,"TOPLEFT",-2,12)
  iB7:SetPoint("BOTTOMRIGHT",cif.text2YOS,"BOTTOMRIGHT",58,-3)
  iB7:SetWidth(200)
  iB7.texture=iB7:CreateTexture(nil,"OVERLAY")
  iB7.texture:SetAllPoints()
  iB7.texture:SetColorTexture(0.07,0.07,0.07,0.4)

  end --end of text2 settings
  
  --create extra settings
  do
  cif.title8=cif:CreateFontString(nil,"OVERLAY")
  local t=cif.title8
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("Extra")
  t:SetPoint("TOPLEFT",cif.title6,"TOPLEFT",0,-330)

  cif.title8Spacer=cif:CreateTexture(nil,"OVERLAY")
  local tS=cif.title8Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)
  
  createNewDD(cif,"checkOn",cif,75)
  cif.checkOn.text:SetPoint("LEFT",tS,"Left",0,-initSpacing)
  cif.checkOn.text:SetText("Trigger on:")
  
  local lf=function(self)
    eF.activePara.extra1checkOn=self.arg   
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  local lst={"None","OnPostAura"}
  for i=1,#lst do
    local v=lst[i]
    cif.checkOn:addButton(v,lf,v)
  end
  
  createFuncBox(cif,"funcbox",cif,500,300)
  cif.funcbox:SetPoint("TOPLEFT",cif.checkOn.text,"TOPLEFT",0,-ySpacing)
  cif.funcbox.button:SetScript("OnClick", function(self) 
    local s=self.eb:GetText()
    self:Disable()
    self.eb:ClearFocus()
    eF.activePara.extra1string=s
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end) 
  cif.funcbox.button:ClearAllPoints()
  cif.funcbox.button:SetPoint("LEFT",cif.checkOn,"RIGHT",ySpacing+10,-3)
  --[[
  function()
    print("teststst")
    return 3
  end
  ]]--
  
  end --end of extra settings
  
end --end of create child icon frame

--create child bar frame
do
  
  local cbsf,cbf
  
  --create scroll frame + box etc
  do
  ff.childBarScrollFrame=CreateFrame("ScrollFrame","eFChildBarScrollFrame",ff,"UIPanelScrollFrameTemplate")
  cbsf=ff.childBarScrollFrame
  cbsf:SetPoint("TOPLEFT",ff.famList,"TOPRIGHT",20,-22)
  cbsf:SetPoint("BOTTOMRIGHT",ff.famList,"BOTTOMRIGHT",20+ff:GetWidth()*0.72,0)
  cbsf:SetClipsChildren(true)
  cbsf:SetScript("OnMouseWheel",ScrollFrame_OnMouseWheel)
  

  cbsf.border=CreateFrame("Frame",nil,ff)
  cbsf.border:SetPoint("TOPLEFT",cbsf,"TOPLEFT",-5,5)
  cbsf.border:SetPoint("BOTTOMRIGHT",cbsf,"BOTTOMRIGHT",5,-5)
  cbsf.border:SetBackdrop(bd)
  
  ff.childBarFrame=CreateFrame("Frame","eFcbf",ff)
  cbf=ff.childBarFrame
  cbf:SetPoint("TOP",cbsf,"TOP",0,-20)
  cbf:SetWidth(cbsf:GetWidth()*0.8)
  cbf:SetHeight(cbsf:GetHeight()*1.2)
 
  cbsf.ScrollBar:ClearAllPoints()
  cbsf.ScrollBar:SetPoint("TOPRIGHT",cbsf,"TOPRIGHT",-6,-18)
  cbsf.ScrollBar:SetPoint("BOTTOMLEFT",cbsf,"BOTTOMRIGHT",-16,18)
  cbsf.ScrollBar.bg=cbsf.ScrollBar:CreateTexture(nil,"BACKGROUND")
  cbsf.ScrollBar.bg:SetAllPoints()
  cbsf.ScrollBar.bg:SetColorTexture(0,0,0,0.5)
  
  cbsf:SetScrollChild(cbf)
  
  cbsf.bg=cbsf:CreateTexture(nil,"BACKGROUND")
  cbsf.bg:SetAllPoints()
  cbsf.bg:SetColorTexture(0.07,0.07,0.07,1)

  cbf.setValues=setCBFActiveValues


  end --end of scroll frame + box etc
  
  --create general settings stuff
  do
  cbf.title1=cbf:CreateFontString(nil,"OVERLAY")
  local t=cbf.title1
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("General")
  t:SetPoint("TOPLEFT",cbf,"TOPLEFT",50,-25)

  cbf.title1Spacer=cbf:CreateTexture(nil,"OVERLAY")
  local tS=cbf.title1Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createNumberEB(cbf,"name",cbf)
  cbf.name.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  cbf.name.text:SetText("Name:")
  cbf.name:SetWidth(80)
  cbf.name:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  name=self:GetText()
  if not name or name=="" then name=eF.activePara.displayName; self:SetText(name)
  else 
    eF.activePara.displayName=name; 
    eF.activeButton.text:SetText(name)
  end
  end)

  createNewDD(cbf,"trackType",cbf,75)
  cbf.trackType.text:SetPoint("RIGHT",cbf.name.text,"RIGHT",0,-ySpacing)
  cbf.trackType.text:SetText("Tracks:")
  local lf=function(self)
    eF.activePara.trackType=self.arg   
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  local lst={"power","heal absorb"}
  for i=1,#lst do
    local v=lst[i]
    cbf.trackType:addButton(v,lf,v)
  end
  
  createNumberEB(cbf,"lFix",cbf)
  cbf.lFix.text:SetPoint("RIGHT",cbf.trackType.text,"RIGHT",0,-ySpacing)
  cbf.lFix.text:SetText("Fixed length:")
  cbf.lFix:SetWidth(80)
  cbf.lFix:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  lFix=self:GetNumber()
  if not lFix or lFix=="" then lFix=(eF.activePara.lFix or 10); self:SetText(lFix or 10)
  else 
    eF.activePara.lFix=lFix;
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  end)  
  
  createNumberEB(cbf,"lMax",cbf)
  cbf.lMax.text:SetPoint("RIGHT",cbf.lFix.text,"RIGHT",0,-ySpacing)
  cbf.lMax.text:SetText("Growing length:")
  cbf.lMax:SetWidth(80)
  cbf.lMax:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  lMax=self:GetNumber()
  if not lMax or lMax=="" then lMax=(eF.activePara.lMax or 10); self:SetText(lMax or 10)
  else 
    eF.activePara.lMax=lMax;
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  end)
  
  createCS(cbf,"textureColor",cbf)
  cbf.textureColor.text:SetPoint("RIGHT",cbf.lMax.text,"RIGHT",0,-ySpacing)
  cbf.textureColor.text:SetText("Color:")
  cbf.textureColor.getOldRGBA=function()
    local r=eF.activePara.textureR
    local g=eF.activePara.textureG
    local b=eF.activePara.textureB
  return r,g,b
  end
  
  cbf.textureColor.opacityFunc=function()
    local r,g,b=ColorPickerFrame:GetColorRGB()
    local a=OpacitySliderFrame:GetValue()
    cbf.textureColor.thumb:SetVertexColor(r,g,b)
    eF.activePara.textureR=r
    eF.activePara.textureG=g
    eF.activePara.textureB=b
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex) 
  end
  
  createNumberEB(cbf,"textureAlpha",cbf)
  cbf.textureAlpha.text:SetPoint("RIGHT",cbf.textureColor.text,"RIGHT",0,-ySpacing)
  cbf.textureAlpha.text:SetText("Alpha:")
  cbf.textureAlpha:SetWidth(80)
  cbf.textureAlpha:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  textureAlpha=self:GetNumber()
  if not textureAlpha or textureAlpha=="" then textureAlpha=(eF.activePara.textureA or 1); self:SetText(textureAlpha or 1)
  else 
    eF.activePara.textureA=textureAlpha;
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  end)
  
  
 createNumberEB(cbf,"xPos",cbf)
  cbf.xPos.text:SetPoint("RIGHT",cbf.textureAlpha.text,"RIGHT",0,-ySpacing)
  cbf.xPos.text:SetText("X Offset:")
  cbf.xPos:SetWidth(30)
  cbf.xPos:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  x=self:GetText()
  x=tonumber(x)
  if not x then x=eF.activePara.xPos; self:SetText(x); 
  else 
    eF.activePara.xPos=x;
  end
  updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)

  createNumberEB(cbf,"yPos",cbf)
  cbf.yPos.text:SetPoint("RIGHT",cbf.xPos.text,"RIGHT",0,-ySpacing)
  cbf.yPos.text:SetText("Y Offset:")
  cbf.yPos:SetWidth(30)
  cbf.yPos:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  x=self:GetText()
  x=tonumber(x)
  if not x  then x=eF.activePara.yPos; self:SetText(x)
  else 
    eF.activePara.yPos=x;
  end
  updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)

  createNewDD(cbf,"anchor",cbf,75)
  cbf.anchor.text:SetPoint("RIGHT",cbf.yPos.text,"RIGHT",0,-ySpacing)
  cbf.anchor.text:SetText("Position:")
  
  local lf=function(self)
    eF.activePara.anchor=self.arg   
    eF.activePara.anchorTo=self.arg   
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  local lst=eF.positions
  for i=1,#lst do
    local v=lst[i]
    cbf.anchor:addButton(v,lf,v)
  end

  
  createNewDD(cbf,"grow",cbf,75)
  cbf.grow.text:SetPoint("RIGHT",cbf.anchor.text,"RIGHT",0,-ySpacing)
  cbf.grow.text:SetText("Grows:")
  
  local lf=function(self)
    eF.activePara.grow=self.arg   
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  local lst=eF.orientations
  for i=1,#lst do
    local v=lst[i]
    cbf.grow:addButton(v,lf,v)
  end

  
  end--end of general settings
  
  
end --end of create child bar frame

--create child border frame
do
  
  local cbosf,cbof
  
  --create scroll frame + box etc
  do
  
  ff.childBorderScrollFrame=CreateFrame("ScrollFrame","eFChildBorderScrollFrame",ff,"UIPanelScrollFrameTemplate")
  cbosf=ff.childBorderScrollFrame
  cbosf:SetPoint("TOPLEFT",ff.famList,"TOPRIGHT",20,-22)
  cbosf:SetPoint("BOTTOMRIGHT",ff.famList,"BOTTOMRIGHT",20+ff:GetWidth()*0.72,0)
  cbosf:SetClipsChildren(true)
  cbosf:SetScript("OnMouseWheel",ScrollFrame_OnMouseWheel)
  

  cbosf.border=CreateFrame("Frame",nil,ff)
  cbosf.border:SetPoint("TOPLEFT",cbosf,"TOPLEFT",-5,5)
  cbosf.border:SetPoint("BOTTOMRIGHT",cbosf,"BOTTOMRIGHT",5,-5)
  cbosf.border:SetBackdrop(bd)
  
  ff.childBorderFrame=CreateFrame("Frame","eFcbof",ff)
  cbof=ff.childBorderFrame
  cbof:SetPoint("TOP",cbosf,"TOP",0,-20)
  cbof:SetWidth(cbosf:GetWidth()*0.8)
  cbof:SetHeight(cbosf:GetHeight()*1.2)
 
  cbosf.ScrollBar:ClearAllPoints()
  cbosf.ScrollBar:SetPoint("TOPRIGHT",cbosf,"TOPRIGHT",-6,-18)
  cbosf.ScrollBar:SetPoint("BOTTOMLEFT",cbosf,"BOTTOMRIGHT",-16,18)
  cbosf.ScrollBar.bg=cbosf.ScrollBar:CreateTexture(nil,"BACKGROUND")
  cbosf.ScrollBar.bg:SetAllPoints()
  cbosf.ScrollBar.bg:SetColorTexture(0,0,0,0.5)
  
  cbosf:SetScrollChild(cbof)
  
  cbosf.bg=cbosf:CreateTexture(nil,"BACKGROUND")
  cbosf.bg:SetAllPoints()
  cbosf.bg:SetColorTexture(0.07,0.07,0.07,1)

  cbof.setValues=setCBOFActiveValues

  
  end --end of scroll frame + box etc
  
  --create general settings stuff
  do
  cbof.title1=cbof:CreateFontString(nil,"OVERLAY")
  local t=cbof.title1
  t:SetFont(titleFont,15,titleFontExtra)
  t:SetTextColor(1,1,1)
  t:SetText("General")
  t:SetPoint("TOPLEFT",cbof,"TOPLEFT",50,-25)

  cbof.title1Spacer=cbof:CreateTexture(nil,"OVERLAY")
  local tS=cbof.title1Spacer
  tS:SetPoint("TOPLEFT",t,"BOTTOMLEFT",1,5)
  tS:SetHeight(8)
  tS:SetTexture(titleSpacer)
  tS:SetWidth(110)

  createNumberEB(cbof,"name",cbof)
  cbof.name.text:SetPoint("TOPLEFT",tS,"TOPLEFT",25,-initSpacing)
  cbof.name.text:SetText("Name:")
  cbof.name:SetWidth(80)
  cbof.name:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  name=self:GetText()
  if not name or name=="" then name=eF.activePara.displayName; self:SetText(name)
  else 
    eF.activePara.displayName=name; 
    eF.activeButton.text:SetText(name)
  end
  end)

  createNewDD(cbof,"trackType",cbof,75)
  cbof.trackType.text:SetPoint("RIGHT",cbof.name.text,"RIGHT",0,-ySpacing)
  cbof.trackType.text:SetText("Tracks:")
  
  local lf=function(self)
    eF.activePara.trackType=self.arg   
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
    if self.arg=="Static" then cbof.iconBlocker1:Show() else cbof.iconBlocker1:Hide() end

  end
  local lst={"Buffs","Debuffs","Static"}
  for i=1,#lst do
    local v=lst[i]
    cbof.trackType:addButton(v,lf,v)
  end

  
  createNewDD(cbof,"trackBy",cbof,75)
  cbof.trackBy.text:SetPoint("RIGHT",cbof.trackType.text,"RIGHT",0,-ySpacing)
  cbof.trackBy.text:SetText("Track by:")
  
  local lf=function(self)
    eF.activePara.trackBy=self.arg   
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  local lst={"Name","Spell ID"}
  for i=1,#lst do
    local v=lst[i]
    cbof.trackBy:addButton(v,lf,v)
  end

  
  createNumberEB(cbof,"spell",cbof)
  cbof.spell.text:SetPoint("RIGHT",cbof.trackBy.text,"RIGHT",0,-ySpacing)
  cbof.spell.text:SetText("Spell:")
  cbof.spell:SetWidth(80)
  cbof.spell:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  spell=self:GetText()
  if (tonumber(spell)) then spell=tonumber(spell) end
  if not spell or spell=="" then spell=eF.activePara.arg1; self:SetText(spell)
  else 
    eF.activePara.arg1=spell;
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  end)

  createCB(cbof,"ownOnly",cbof)
  cbof.ownOnly.text:SetPoint("RIGHT",cbof.spell.text,"RIGHT",0,-ySpacing)
  cbof.ownOnly.text:SetText("Own only:")
  cbof.ownOnly:SetScript("OnClick",function(self)
    local ch=self:GetChecked()
    self:SetChecked(ch)
    eF.activePara.ownOnly=ch
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end)
  
  cbof.iconBlocker1=CreateFrame("Button",nil,cbof)
  local iB1=cbof.iconBlocker1
  iB1:SetFrameLevel(cbof:GetFrameLevel()+3)
  iB1:SetPoint("TOPRIGHT",cbof.trackBy,"TOPRIGHT",2,2)
  iB1:SetPoint("BOTTOMLEFT",cbof.ownOnly.text,"BOTTOMLEFT",-15,-2)
  iB1.texture=iB1:CreateTexture(nil,"OVERLAY")
  iB1.texture:SetAllPoints()
  iB1.texture:SetColorTexture(0.07,0.07,0.07,0.4)
  
  
  createNumberEB(cbof,"borderSize",cbof)
  cbof.borderSize.text:SetPoint("RIGHT",cbof.ownOnly.text,"RIGHT",0,-ySpacing)
  cbof.borderSize.text:SetText("Size:")
  cbof.borderSize:SetWidth(80)
  cbof.borderSize:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  borderSize=self:GetNumber()
  if not borderSize or borderSize=="" then borderSize=(eF.activePara.borderSize or 2); self:SetText(borderSize or 2)
  else 
    eF.activePara.borderSize=borderSize;
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  end)
  
  createCS(cbof,"borderColor",cbof)
  cbof.borderColor.text:SetPoint("RIGHT",cbof.borderSize.text,"RIGHT",0,-ySpacing)
  cbof.borderColor.text:SetText("Color:")
  cbof.borderColor.getOldRGBA=function()
    local r=eF.activePara.borderR
    local g=eF.activePara.borderG
    local b=eF.activePara.borderB
  return r,g,b
  end
  
  cbof.borderColor.opacityFunc=function()
    local r,g,b=ColorPickerFrame:GetColorRGB()
    local a=OpacitySliderFrame:GetValue()
    cbof.borderColor.thumb:SetVertexColor(r,g,b)
    eF.activePara.borderR=r
    eF.activePara.borderG=g
    eF.activePara.borderB=b
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex) 
  end
  
  createNumberEB(cbof,"borderAlpha",cbof)
  cbof.borderAlpha.text:SetPoint("RIGHT",cbof.borderColor.text,"RIGHT",0,-ySpacing)
  cbof.borderAlpha.text:SetText("Alpha:")
  cbof.borderAlpha:SetWidth(80)
  cbof.borderAlpha:SetScript("OnEnterPressed", function(self)
  self:ClearFocus()
  borderAlpha=self:GetNumber()
  if not borderAlpha or borderAlpha=="" then borderAlpha=(eF.activePara.borderA or 1); self:SetText(borderAlpha or 1)
  else 
    eF.activePara.borderA=borderAlpha;
    updateAllFramesChildParas(eF.activeFamilyIndex,eF.activeChildIndex)
  end
  end)
  
  end--end of general settings
  
  
end --end of create child border frame

--family + child creation
do

local ecf
--Plus button and select screen
do
ff.elementCreationButton=CreateFrame("Button",nil,ff)
local ecb=ff.elementCreationButton
ecb:SetPoint("BOTTOMLEFT",fL,"TOPLEFT",0,5)
ecb:SetSize(40,40)
ecb:SetBackdrop(bd2)

ecb.plus=ecb:CreateTexture(nil,"BACKGROUND")
ecb.plus:SetAllPoints(true)
ecb.plus:SetTexture(plusTexture)
ecb:SetNormalTexture(ecb.plus)

ecb.hl=ecb:CreateTexture(nil,"BACKGROUND")
ecb.hl:SetPoint("TOPRIGHT",ecb,"TOPRIGHT",3,3)
ecb.hl:SetPoint("BOTTOMLEFT",ecb,"BOTTOMLEFT",-3,-4)
ecb.hl:SetTexture("Interface\\BUTTONS\\ButtonHilight-SquareQuickslot")
ecb:SetHighlightTexture(ecb.hl)

ecb.plus=ecb:CreateTexture(nil,"BACKGROUND")
ecb.plus:SetAllPoints(true)
ecb.plus:SetTexture(plusTexture)
ecb.plus:SetVertexColor(0.5,0.5,0.5)
ecb:SetPushedTexture(ecb.plus)


ff.elementExterminationButton=CreateFrame("Button",nil,ff)
local eeb=ff.elementExterminationButton
eeb:SetPoint("BOTTOMRIGHT",fL,"TOPRIGHT",0,5)
eeb:SetSize(40,40)
eeb:SetBackdrop(bd2)

eeb.plus=eeb:CreateTexture(nil,"BACKGROUND")
eeb.plus:SetAllPoints(true)
eeb.plus:SetTexture(destroyTexture)
eeb:SetNormalTexture(eeb.plus)

eeb.hl=eeb:CreateTexture(nil,"BACKGROUND")
eeb.hl:SetPoint("TOPRIGHT",eeb,"TOPRIGHT",3,3)
eeb.hl:SetPoint("BOTTOMLEFT",eeb,"BOTTOMLEFT",-3,-4)
eeb.hl:SetTexture("Interface\\BUTTONS\\ButtonHilight-SquareQuickslot")
eeb:SetHighlightTexture(eeb.hl)

eeb.plus=eeb:CreateTexture(nil,"BACKGROUND")
eeb.plus:SetAllPoints(true)
eeb.plus:SetTexture(destroyTexture)
eeb.plus:SetVertexColor(0.5,0.5,0.5)
eeb:SetPushedTexture(eeb.plus)

eeb.text=eeb:CreateFontString(nil,"OVERLAY")
eeb.text:SetPoint("LEFT",eeb,"RIGHT",15,0)
eeb.text:SetFont("Fonts\\FRIZQT__.TTF",15,"OUTLINE")
--eeb.text:SetTextColor(titleFontColor)
eeb.text:SetTextColor(1,1,1)

eeb.confirmButton=CreateFrame("Button",nil,eeb,"UIPanelButtonTemplate")
eeb.confirmButton:SetPoint("LEFT",eeb.text,"RIGHT",5,0)
eeb.confirmButton:SetText("Yes")
eeb.confirmButton:SetSize(40,20)
eeb.confirmButton.deleteJ=nil
eeb.confirmButton.deleteK=nil
eeb.confirmButton.textPointer=eeb.text
eeb.confirmButton:Hide()

ff.elementCreationScrollFrame=CreateFrame("ScrollFrame","eFelementCreationScrollFrame",ff,"UIPanelScrollFrameTemplate")
local ecsf=ff.elementCreationScrollFrame
ecsf:SetPoint("TOPLEFT",ff.famList,"TOPRIGHT",20,-22)
ecsf:SetPoint("BOTTOMRIGHT",ff.famList,"BOTTOMRIGHT",20+ff:GetWidth()*0.72,0)
ecsf:SetClipsChildren(true)
ecsf:SetScript("OnMouseWheel",ScrollFrame_OnMouseWheel)

ecsf.border=CreateFrame("Frame",nil,ff)
ecsf.border:SetPoint("TOPLEFT",ecsf,"TOPLEFT",-5,5)
ecsf.border:SetPoint("BOTTOMRIGHT",ecsf,"BOTTOMRIGHT",5,-5)
ecsf.border:SetBackdrop(bd)

ff.elementCreationFrame=CreateFrame("Frame","eFecf",ff)
ecf=ff.elementCreationFrame
ecf:SetPoint("TOP",ecsf,"TOP",0,-20)
ecf:SetWidth(ecsf:GetWidth()*0.8)
ecf:SetHeight(ecsf:GetHeight()*0.6)


ecsf.ScrollBar:ClearAllPoints()
ecsf.ScrollBar:SetPoint("TOPRIGHT",ecsf,"TOPRIGHT",-6,-18)
ecsf.ScrollBar:SetPoint("BOTTOMLEFT",ecsf,"BOTTOMRIGHT",-16,18)
ecsf.ScrollBar.bg=ecsf.ScrollBar:CreateTexture(nil,"BACKGROUND")
ecsf.ScrollBar.bg:SetAllPoints()
ecsf.ScrollBar.bg:SetColorTexture(0,0,0,0.5)

ecsf:SetScrollChild(ecf)


ecsf.bg=ecsf:CreateTexture(nil,"BACKGROUND")
ecsf.bg:SetAllPoints()
ecsf.bg:SetColorTexture(0.07,0.07,0.07,1)

ecb:SetScript("OnClick",function()
  local tabs=eF.interface.familiesFrame.tabs
  if tabs:IsShown() then 
    tabs.tab1:SetButtonState("PUSHED")
    tabs.tab1:Click()
    tabs:Hide()
  end

  releaseAllFamilies()
  hideAllFamilyParas()
  ecsf:Show()
end)

eeb:SetScript("OnClick",function(self)
  local text=eeb.text:GetText()
  if not ( (text=="") or (text==nil) ) then 
    eeb.text:SetText(""); 
    self.confirmButton.deleteJ=nil
    self.confirmButton.deleteK=nil
    self.confirmButton:Hide()
    return
  end
  
  self.confirmButton.deleteJ=eF.activeButton.familyIndex
  self.confirmButton.deleteK=eF.activeButton.childIndex
  local j,k=eF.activeButton.familyIndex,eF.activeButton.childIndex
  local name
  if k then name=eF.para.families[j][k].displayName else name=eF.para.families[j].displayName end
  eeb.text:SetText('Are you sure you want to delete "'..name..'" ')
  eeb.confirmButton:Show()
end)

eeb.confirmButton:SetScript("OnClick",function(self)
  local j,k=self.deleteJ,self.deleteK
  if j==1 and not k then return end
  if k then exterminateChild(j,k)
  else
    if eF.activeButton.smart then exterminateSmartFamily(j) else exterminateDumbFamily(j) end
  end
  releaseAllFamilies()
  hideAllFamilyParas()
  self.textPointer:SetText("")
  self:Hide()
end)


end --end of plus button + select

--Populate select screen (ecb)
do
local cwlb,cblb,cib,cbb,cgb

--create whitelist button (cwlb)
do
ecf.createWhitelistButton=CreateFrame("Button",nil,ecf)
cwlb=ecf.createWhitelistButton
cwlb:SetPoint("TOPLEFT",ecf,"TOPLEFT",80,-40)
cwlb:SetSize(150,80)

cwlb.border=CreateFrame("Frame",nil,cwlb)
cwlb.border:SetPoint("TOPRIGHT",cwlb,"TOPRIGHT",3,3)
cwlb.border:SetPoint("BOTTOMLEFT",cwlb,"BOTTOMLEFT",-3,-3)
cwlb.border:SetBackdrop(bd2)

cwlb.nT=cwlb:CreateTexture(nil,"BACKGROUND")
cwlb.nT:SetAllPoints(true)
cwlb.nT:SetColorTexture(0.2,0.25,0.2,1)
cwlb.nT:SetGradient("vertical",0.5,0.5,0.5,0.8,0.8,0.8)
cwlb:SetNormalTexture(cwlb.nT)

cwlb.hl=cwlb:CreateTexture(nil,"BACKGROUND")
cwlb.hl:SetAllPoints(true)
cwlb.hl:SetColorTexture(0.6,0.8,0.4)
cwlb.hl:SetGradient("vertical",0.1,0.1,0.1,0.4,0.4,0.4)
cwlb.hl:SetAlpha(0.4)
cwlb:SetHighlightTexture(cwlb.hl)

cwlb.pT=cwlb:CreateTexture(nil,"BACKGROUND")
cwlb.pT:SetAllPoints(true)
cwlb.pT:SetColorTexture(0.6,0.8,0.4)
cwlb.pT:SetGradient("vertical",0.1,0.1,0.1,0.4,0.4,0.4)
cwlb:SetPushedTexture(cwlb.pT)

cwlb.text=cwlb:CreateFontString(nil,"OVERLAY")
cwlb.text:SetFont("Fonts\\FRIZQT__.TTF",19,"OUTLINE")
cwlb.text:SetText("Create Whitelist")
cwlb.text:SetTextColor(1,1,1) 
cwlb.text:SetPoint("CENTER")

cwlb.descripton=cwlb:CreateFontString(nil,"OVERLAY")
cwlb.descripton:SetFont("Fonts\\FRIZQT__.TTF",12,"OUTLINE")
cwlb.descripton:SetText("")
cwlb.descripton:SetPoint("TOP",cwlb,"BOTTOM",0,-8)

cwlb:SetScript("OnClick",function()
local j=#eF.para.families+1
createNewWhitelistParas(j)
createAllFamilyFrame(j)
sc:createFamily(j)
sc:setFamilyPositions()
eF.familyButtonsList[#eF.familyButtonsList]:SetButtonState("PUSHED")
eF.familyButtonsList[#eF.familyButtonsList]:Click()
afterDo(0, function() fL:SetVerticalScroll(fL:GetVerticalScrollRange()) end)
updateAllFramesFamilyLayout(j)
end)

end --end of create whitelist button

--create blacklist button (cblb)
do
ecf.createBlacklistButton=CreateFrame("Button",nil,ecf)
cblb=ecf.createBlacklistButton
cblb:SetPoint("TOP",cwlb,"BOTTOM",0,-40)
cblb:SetSize(150,80)

cblb.border=CreateFrame("Frame",nil,cblb)
cblb.border:SetPoint("TOPRIGHT",cblb,"TOPRIGHT",3,3)
cblb.border:SetPoint("BOTTOMLEFT",cblb,"BOTTOMLEFT",-3,-3)
cblb.border:SetBackdrop(bd2)

cblb.nT=cblb:CreateTexture(nil,"BACKGROUND")
cblb.nT:SetAllPoints(true)
cblb.nT:SetColorTexture(0.2,0.25,0.2,1)
cblb.nT:SetGradient("vertical",0.5,0.5,0.5,0.8,0.8,0.8)
cblb:SetNormalTexture(cblb.nT)

cblb.hl=cblb:CreateTexture(nil,"BACKGROUND")
cblb.hl:SetAllPoints(true)
cblb.hl:SetColorTexture(0.6,0.8,0.4)
cblb.hl:SetGradient("vertical",0.1,0.1,0.1,0.4,0.4,0.4)
cblb.hl:SetAlpha(0.4)
cblb:SetHighlightTexture(cblb.hl)

cblb.pT=cblb:CreateTexture(nil,"BACKGROUND")
cblb.pT:SetAllPoints(true)
cblb.pT:SetColorTexture(0.6,0.8,0.4)
cblb.pT:SetGradient("vertical",0.1,0.1,0.1,0.4,0.4,0.4)
cblb:SetPushedTexture(cblb.pT)

cblb.text=cblb:CreateFontString(nil,"OVERLAY")
cblb.text:SetFont("Fonts\\FRIZQT__.TTF",19,"OUTLINE")
cblb.text:SetText("Create Blacklist")
cblb.text:SetTextColor(1,1,1) 
cblb.text:SetPoint("CENTER")

cblb.descripton=cblb:CreateFontString(nil,"OVERLAY")
cblb.descripton:SetFont("Fonts\\FRIZQT__.TTF",12,"OUTLINE")
cblb.descripton:SetText("")
cblb.descripton:SetPoint("TOP",cblb,"BOTTOM",0,-8)

cblb:SetScript("OnClick",function()
local j=#eF.para.families+1
createNewBlacklistParas(j)
createAllFamilyFrame(j)
sc:createFamily(j)
sc:setFamilyPositions()
eF.familyButtonsList[#eF.familyButtonsList]:SetButtonState("PUSHED")
eF.familyButtonsList[#eF.familyButtonsList]:Click()
afterDo(0, function() fL:SetVerticalScroll(fL:GetVerticalScrollRange()) end)
updateAllFramesFamilyLayout(j)
end)
end --end of create blacklist button

--create group button (cgb)
do
ecf.createGroupButton=CreateFrame("Button",nil,ecf)
cgb=ecf.createGroupButton
cgb:SetPoint("TOP",cblb,"BOTTOM",0,-40)
cgb:SetSize(150,80)

cgb.border=CreateFrame("Frame",nil,cgb)
cgb.border:SetPoint("TOPRIGHT",cgb,"TOPRIGHT",3,3)
cgb.border:SetPoint("BOTTOMLEFT",cgb,"BOTTOMLEFT",-3,-3)
cgb.border:SetBackdrop(bd2)

cgb.nT=cgb:CreateTexture(nil,"BACKGROUND")
cgb.nT:SetAllPoints(true)
cgb.nT:SetColorTexture(0.15,0.22,0.4,1)
cgb.nT:SetGradient("vertical",0.5,0.5,0.5,0.8,0.8,0.8)
cgb:SetNormalTexture(cgb.nT)
  
cgb.hl=cgb:CreateTexture(nil,"BACKGROUND")
cgb.hl:SetAllPoints(true)
cgb.hl:SetColorTexture(0.32,0.51,0.8)
cgb.hl:SetGradient("vertical",0.1,0.1,0.1,0.4,0.4,0.4)
cgb.hl:SetAlpha(0.4)
cgb:SetHighlightTexture(cgb.hl)

cgb.pT=cgb:CreateTexture(nil,"BACKGROUND")
cgb.pT:SetAllPoints(true)
cgb.pT:SetColorTexture(0.32,0.51,0.8)
cgb.pT:SetGradient("vertical",0.1,0.1,0.1,0.4,0.4,0.4)
cgb:SetPushedTexture(cgb.pT)

cgb.text=cgb:CreateFontString(nil,"OVERLAY")
cgb.text:SetFont("Fonts\\FRIZQT__.TTF",19,"OUTLINE")
cgb.text:SetText("Create Group")
cgb.text:SetTextColor(1,1,1) 
cgb.text:SetPoint("CENTER")

cgb.descripton=cgb:CreateFontString(nil,"OVERLAY")
cgb.descripton:SetFont("Fonts\\FRIZQT__.TTF",12,"OUTLINE")
cgb.descripton:SetText("")
cgb.descripton:SetPoint("TOP",cgb,"BOTTOM",0,-8)

cgb:SetScript("OnClick",function()
local j=#eF.para.families+1
createNewGroupParas(j)
createAllFamilyFrame(j)
sc:createGroup(j)
sc:setFamilyPositions()
eF.familyButtonsList[#eF.familyButtonsList]:SetButtonState("PUSHED")
eF.familyButtonsList[#eF.familyButtonsList]:Click()
afterDo(0, function() fL:SetVerticalScroll(fL:GetVerticalScrollRange()) end)
updateAllFramesFamilyLayout(j)
end)
end --end of create blacklist button

--create icon button (cib)
do
ecf.createIconButton=CreateFrame("Button",nil,ecf)
cib=ecf.createIconButton
cib:SetPoint("TOPRIGHT",ecf,"TOPRIGHT",0,-40)
cib:SetSize(150,80)

cib.border=CreateFrame("Frame",nil,cib)
cib.border:SetPoint("TOPRIGHT",cib,"TOPRIGHT",3,3)
cib.border:SetPoint("BOTTOMLEFT",cib,"BOTTOMLEFT",-3,-3)
cib.border:SetBackdrop(bd2)

cib.nT=cib:CreateTexture(nil,"BACKGROUND")
cib.nT:SetAllPoints(true)
cib.nT:SetColorTexture(0.28,0.2,0.2,1)
cib.nT:SetGradient("vertical",0.5,0.5,0.5,0.8,0.8,0.8)
cib:SetNormalTexture(cib.nT)

cib.hl=cib:CreateTexture(nil,"BACKGROUND")
cib.hl:SetAllPoints(true)
cib.hl:SetColorTexture(0.8,0.4,0.4)
cib.hl:SetGradient("vertical",0.1,0.1,0.1,0.4,0.4,0.4)
cib.hl:SetAlpha(0.4)
cib:SetHighlightTexture(cib.hl)

cib.pT=cib:CreateTexture(nil,"BACKGROUND")
cib.pT:SetAllPoints(true)
cib.pT:SetColorTexture(0.8,0.4,0.4)
cib.pT:SetGradient("vertical",0.1,0.1,0.1,0.4,0.4,0.4)
cib:SetPushedTexture(cib.pT)

cib.text=cib:CreateFontString(nil,"OVERLAY")
cib.text:SetFont("Fonts\\FRIZQT__.TTF",19,"OUTLINE")
cib.text:SetText("Create Icon")
cib.text:SetTextColor(1,1,1) 
cib.text:SetPoint("CENTER")

cib.descripton=cib:CreateFontString(nil,"OVERLAY")
cib.descripton:SetFont("Fonts\\FRIZQT__.TTF",12,"OUTLINE")
cib.descripton:SetText("")
cib.descripton:SetPoint("TOP",cib,"BOTTOM",0,-8)

cib:SetScript("OnClick",function()
local j=1
local k=eF.para.families[j].count+1
eF.para.families[j].count=k

createNewIconParas(j,k)
createAllIconFrame(j,k)
sc:createChild(j,k)
sc:setFamilyPositions()
eF.familyButtonsList[#eF.familyButtonsList]:SetButtonState("PUSHED")
eF.familyButtonsList[#eF.familyButtonsList]:Click()
afterDo(0, function() fL:SetVerticalScroll(fL:GetVerticalScrollRange()) end)
end)

end --end of icon creation button 

--create bar button (cbb)
do
ecf.createBarButton=CreateFrame("Button",nil,ecf)
cbb=ecf.createBarButton
cbb:SetPoint("TOP",cib,"BOTTOM",0,-40)
cbb:SetSize(150,80)

cbb.border=CreateFrame("Frame",nil,cbb)
cbb.border:SetPoint("TOPRIGHT",cbb,"TOPRIGHT",3,3)
cbb.border:SetPoint("BOTTOMLEFT",cbb,"BOTTOMLEFT",-3,-3)
cbb.border:SetBackdrop(bd2)

cbb.nT=cbb:CreateTexture(nil,"BACKGROUND")
cbb.nT:SetAllPoints(true)
cbb.nT:SetColorTexture(0.28,0.2,0.2,1)
cbb.nT:SetGradient("vertical",0.5,0.5,0.5,0.8,0.8,0.8)
cbb:SetNormalTexture(cbb.nT)

cbb.hl=cbb:CreateTexture(nil,"BACKGROUND")
cbb.hl:SetAllPoints(true)
cbb.hl:SetColorTexture(0.8,0.4,0.4)
cbb.hl:SetGradient("vertical",0.1,0.1,0.1,0.4,0.4,0.4)
cbb.hl:SetAlpha(0.4)
cbb:SetHighlightTexture(cbb.hl)

cbb.pT=cbb:CreateTexture(nil,"BACKGROUND")
cbb.pT:SetAllPoints(true)
cbb.pT:SetColorTexture(0.8,0.4,0.4)
cbb.pT:SetGradient("vertical",0.1,0.1,0.1,0.4,0.4,0.4)
cbb:SetPushedTexture(cbb.pT)

cbb.text=cbb:CreateFontString(nil,"OVERLAY")
cbb.text:SetFont("Fonts\\FRIZQT__.TTF",19,"OUTLINE")
cbb.text:SetText("Create Bar")
cbb.text:SetTextColor(1,1,1) 
cbb.text:SetPoint("CENTER")

cbb.descripton=cbb:CreateFontString(nil,"OVERLAY")
cbb.descripton:SetFont("Fonts\\FRIZQT__.TTF",12,"OUTLINE")
cbb.descripton:SetText("")
cbb.descripton:SetPoint("TOP",cbb,"BOTTOM",0,-8)

cbb:SetScript("OnClick",function()
local j=1
local k=eF.para.families[j].count+1
eF.para.families[j].count=k

createNewBarParas(j,k)
createAllIconFrame(j,k)
sc:createChild(j,k)
sc:setFamilyPositions()
eF.familyButtonsList[#eF.familyButtonsList]:SetButtonState("PUSHED")
eF.familyButtonsList[#eF.familyButtonsList]:Click()
afterDo(0, function() fL:SetVerticalScroll(fL:GetVerticalScrollRange()) end)
end)
end --end of create bar button

--create border button (cbob)
do
ecf.createBorderButton=CreateFrame("Button",nil,ecf)
cbob=ecf.createBorderButton
cbob:SetPoint("TOP",cbb,"BOTTOM",0,-40)
cbob:SetSize(150,80)

cbob.border=CreateFrame("Frame",nil,cbob)
cbob.border:SetPoint("TOPRIGHT",cbob,"TOPRIGHT",3,3)
cbob.border:SetPoint("BOTTOMLEFT",cbob,"BOTTOMLEFT",-3,-3)
cbob.border:SetBackdrop(bd2)

cbob.nT=cbob:CreateTexture(nil,"BACKGROUND")
cbob.nT:SetAllPoints(true)
cbob.nT:SetColorTexture(0.28,0.2,0.2,1)
cbob.nT:SetGradient("vertical",0.5,0.5,0.5,0.8,0.8,0.8)
cbob:SetNormalTexture(cbob.nT)

cbob.hl=cbob:CreateTexture(nil,"BACKGROUND")
cbob.hl:SetAllPoints(true)
cbob.hl:SetColorTexture(0.8,0.4,0.4)
cbob.hl:SetGradient("vertical",0.1,0.1,0.1,0.4,0.4,0.4)
cbob.hl:SetAlpha(0.4)
cbob:SetHighlightTexture(cbob.hl)

cbob.pT=cbob:CreateTexture(nil,"BACKGROUND")
cbob.pT:SetAllPoints(true)
cbob.pT:SetColorTexture(0.8,0.4,0.4)
cbob.pT:SetGradient("vertical",0.1,0.1,0.1,0.4,0.4,0.4)
cbob:SetPushedTexture(cbob.pT)

cbob.text=cbob:CreateFontString(nil,"OVERLAY")
cbob.text:SetFont("Fonts\\FRIZQT__.TTF",19,"OUTLINE")
cbob.text:SetText("Create Border")
cbob.text:SetTextColor(1,1,1) 
cbob.text:SetPoint("CENTER")

cbob.descripton=cbob:CreateFontString(nil,"OVERLAY")
cbob.descripton:SetFont("Fonts\\FRIZQT__.TTF",12,"OUTLINE")
cbob.descripton:SetText("")
cbob.descripton:SetPoint("TOP",cbob,"BOTTOM",0,-8)

cbob:SetScript("OnClick",function()
local j=1
local k=eF.para.families[j].count+1
eF.para.families[j].count=k

createNewBorderParas(j,k)
createAllIconFrame(j,k)
sc:createChild(j,k)
sc:setFamilyPositions()
eF.familyButtonsList[#eF.familyButtonsList]:SetButtonState("PUSHED")
eF.familyButtonsList[#eF.familyButtonsList]:Click()
afterDo(0, function() fL:SetVerticalScroll(fL:GetVerticalScrollRange()) end)
end)

end --end of border creation button 

end 

end --end of creation

end--end of family frames










