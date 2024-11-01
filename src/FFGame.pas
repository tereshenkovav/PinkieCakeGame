unit FFGame;

interface

const
   BLOCKNX=11 ;
   BLOCKNY=6 ;
   LEFT_SPACE=20 ;
   BOTTOM_SPACE=10 ;
   BLOCKW=70 ;
   BLOCKH=70 ;

procedure LoadGameResources() ;
procedure GoGameLevel(Level:Integer) ;
procedure UnloadGameResources() ;

implementation
uses TAVHGEUtils, Windows, HGE, HGEAnim, HGEFont, ObjModule, Effects,FFMenu, CommonProc,
  FFWinFail, SpriteEffects, HGESprite, Gamer, Classes,
  SysUtils, Water, Enemy, Math, Generics.Collections ;

type
  TPlace = (pSpace,pCake,pWall,pSpring,pGunRight,pGunLeft,pBlockDown,pBlockTime) ;

var
   sprCakes:TList<IHGESprite> ;
   sprWall:IHGESprite ;
   sprEnemy0,sprEnemy1:IHGESprite ;
   sprBlockDown:IHGESprite ;
   sprBlockTime:IHGESprite ;
   sprSpring:IHGESprite ;
   sprGun:IHGESprite ;
   sprBorder:IHGESprite ;
   sprPanel:IHGESprite ;
   arr_places:array[0..31,0..31] of TPlace ;
   blockt:Single ;
   blocktimeperiod:Single ;

   GamerAnim:IHGEAnimation ;
   fixpos:Integer ;
   SRGamer:TSpriteRender ;
   G:TGamer ;
   Wt:TWater ;
   En:TEnemy ;

   LevelText:string ;
   pause:Boolean ;

function GetBlockTop(j:Integer):Integer ;
begin
  Result:=SWindowOptions.Height-BOTTOM_SPACE-BLOCKH*(j+1) ;
end;

function GetBlockLeft(i:Integer):Integer ;
begin
  Result:=LEFT_SPACE+BLOCKW*i ;
end;

function isNotSpace(i,j:Integer):Boolean ;
begin
  if arr_places[i,j]=pSpace then Exit(False);
  // Это условие везде дублируется
  if arr_places[i,j]=pBlocktime then
    Exit(blockt>=blocktimeperiod/2) ;
  Result:=True ;
end;

procedure LoadLevel(n:Integer) ;
var i,j,k:Integer ;
    List:TStringList ;
begin
  SEPool.DelAllEffects ;

  List:=TStringList.Create ;
  List.LoadFromFile(Format('levels\pinki_level%d',[n])) ;

  G:=TGamer.Create(StrToInt(List.Values['PlayerX']),StrToInt(List.Values['PlayerY']),BLOCKW) ;
  if List.IndexOfName('Water')<>-1 then
    with TStringList.Create() do begin
      CommaText:=List.Values['Water'] ;
      Wt:=TWaterStd.Create(StrToInt(Strings[0]),Strings[1]='up') ;
      Free ;
    end
  else
    Wt:=TWater.Create() ;

  if List.IndexOfName('Enemy')<>-1 then
    with TStringList.Create() do begin
      CommaText:=List.Values['Enemy'] ;
      En:=TEnemyStd.Create(getBlockLeft(StrToInt(Strings[0])),
        getBlockLeft(StrToInt(Strings[1])),
        getBlockTop(StrToInt(Strings[2])),Strings[3]) ;
      Free ;
    end
  else
    En:=TEnemy.Create() ;

  if List.IndexOfName('Hint')<>-1 then
    LevelText:=Texts.Values[List.Values['Hint']]
  else
    LevelText:='' ;

  if List.IndexOfName('BlockTimePeriod')<>-1 then
    blocktimeperiod:=StrToInt(List.Values['BlockTimePeriod'])
  else
    blocktimeperiod:=5.0 ;

  if List.IndexOfName('BlockTimePhase')<>-1 then
    blockt:=StrToInt(List.Values['BlockTimePhase'])
  else
    blockt:=0.0 ;

  k:=List.IndexOf('MAP')+1 ;
  for j := 0 to BLOCKNY - 1 do
    for i := 0 to BLOCKNX - 1 do
      try
        arr_places[i,BLOCKNY-1-j]:=TPlace(StrToInt(List[k+j][i+1])) ;
      except
        arr_places[i,BLOCKNY-1-j]:=pSpace ;
      end;
  List.Free ;

  mHGE.System_Log('Load level %d OK',[n]);
end;

function IsWin():Boolean ;
var i,j:Integer ;
begin
  Result:=True ;
  for i := 0 to BLOCKNX-1 do
    for j := 0 to BLOCKNY - 1 do
      if arr_places[i,j]=pCake then Exit(False) ;
end;

function IsGameFail():Boolean ;
begin
  Result:=False ;
  if Wt.IsGamerIntersect(G) then Exit(True) ;
  if G.GetY+BLOCKH>=SWindowOptions.Height then Exit(True) ;
  if En.IsGamerIntersect(G) then Exit(True) ;
end;

function calcTag(i,j:Integer):Integer ; overload ;
begin
  Result:=i*1024+j ;
end;

function calcTag(p:TPoint):Integer ; overload ;
begin
  Result:=calcTag(p.X,p.Y) ;
end;

procedure LoadGameResources() ;
var i,j:Integer ;
    Tex:ITexture ;
begin
  SndJump:=mHGE.Effect_Load('sounds\jump.wav') ;
  SndGun:=mHGE.Effect_Load('sounds\gun.wav') ;
  SndSpring:=mHGE.Effect_Load('sounds\spring.wav') ;

  sprCakes:=TList<IHGESprite>.Create() ;
  i:=1 ;
  while FileExists(Format('images\cake%d.png',[i])) do begin
    sprCakes.Add(LoadSizedSprite(mHGE,Format('cake%d.png',[i]))) ;
    Inc(i) ;
  end;
  mHGE.System_Log('CakeCount=%d',[sprCakes.Count]) ;

  sprWall:=LoadSizedSprite(mHGE,'wall.png') ;
  sprBlockdown:=LoadSizedSprite(mHGE,'blockdown.png') ;
  sprBlockTime:=LoadSizedSprite(mHGE,'blocktime.png') ;
  sprEnemy0:=LoadSizedSprite(mHGE,'enemy0.png') ;
  sprEnemy1:=LoadSizedSprite(mHGE,'enemy1.png') ;
  sprSpring:=LoadSizedSprite(mHGE,'spring.png') ;
  sprGun:=LoadSizedSprite(mHGE,'gun.png') ;
  sprBorder:=LoadSizedSprite(mHGE,'border.png') ;
  sprPanel:=LoadAndCenteredSizedSprite(mHGE,'panel.png') ;

  Randomize ;
  for i := 0 to BLOCKNX - 1 do
    for j := 0 to BLOCKNY - 1 do begin
      if arr_places[i,j]=pWall then
        SRPool.AddRenderTagged(TSpriteRender.Create(
          sprWall, GetBlockLeft(i),GetBlockTop(j)),calcTag(i,j))
      else
      if arr_places[i,j]=pBlockdown then
        SRPool.AddRenderTagged(TSpriteRender.Create(
          sprBlockdown, GetBlockLeft(i),GetBlockTop(j)),calcTag(i,j))
      else
      if arr_places[i,j]=pBlocktime then
        SRPool.AddRenderTagged(TSpriteRender.Create(
          sprBlocktime, GetBlockLeft(i),GetBlockTop(j)),calcTag(i,j))
      else
      if arr_places[i,j]=pSpring then
        SRPool.AddRenderTagged(TSpriteRender.Create(
          sprSpring, GetBlockLeft(i),GetBlockTop(j)),calcTag(i,j))
      else
      if arr_places[i,j]=pGunRight then
        SRPool.AddRenderTagged(TSpriteRender.Create(
          sprGun, GetBlockLeft(i),GetBlockTop(j)),calcTag(i,j))
      else
      if arr_places[i,j]=pGunLeft then begin
        SRPool.AddRenderTagged(TSpriteRender.Create(
          sprGun, GetBlockLeft(i),GetBlockTop(j)),calcTag(i,j)) ;
        SRPool.GetRenderByTag(calcTag(i,j)).mirror:=[mirrHorz];
      end
      else
      if arr_places[i,j]=pCake then
        SRPool.AddRenderTagged(TSpriteRender.Create(
          sprCakes[Round(Random(sprCakes.Count))],
          GetBlockLeft(i),GetBlockTop(j)),calcTag(i,j));
    end;

  Tex:=mHGE.Texture_Load(PathLoader+'pinki_gamer.png') ;
  GamerAnim:=THGEAnimation.Create(Tex,10,15,0,0,85,97) ;
  GamerAnim.SetHotSpot(7,20) ;
  GamerAnim.Play() ;
  GamerAnim.Stop() ;
  GamerAnim.SetFrame(3) ;

  SRGamer:=TSpriteRender.Create(GamerAnim);
end ;

procedure UnloadGameResources() ;
begin
  SRPool.DelAllRenders ;
  sprCakes.Free ;
  SRGamer.Free ;
end;

// Расчет столкновения и съедания блока
function isBlockHit(dt:Single; var p:TPoint):Boolean ;
var i,j:Integer ;
begin
  Result:=False ;
  for i := BLOCKNX-1 downto 0 do
    for j := BLOCKNY - 1 downto 0 do
      if arr_places[i,j]<>pSpace then
        if G.IsIntersectVert(GetBlockTop(j)-BLOCKH,dt) then
          if Abs(G.GetX()-GetBlockLeft(i))<BLOCKW then begin
            if not Result then begin
              p:=Point(i,j) ;
              Result:=True ;
            end
            else begin
              if G.GetDistFromXCenter(GetBlockLeft(i)+(BLOCKW div 2))<
                G.GetDistFromXCenter(GetBlockLeft(p.X)+(BLOCKW div 2)) then
                  p:=Point(i,j) ;
            end;
          end;
end;

procedure ExecJump() ;
begin
  PlaySound(SndJump) ;
  G.JumpVert() ;
  GamerAnim.SetFrame(4) ;
  GamerAnim.Resume() ;
  fixpos:=G.GetY() ;
end;

function FrameFuncGame():Boolean ;
var i,j:Integer ;
    dt:Single ;
    PointGet:TPoint ;
    label fin ;
begin
  Result:=False ;
  
  dt:=mHGE.Timer_GetDelta() ;

  if pause then begin
    if mHGE.Input_KeyDown(HGEK_ESCAPE) then pause:=False ;
    if mHGE.Input_KeyDown(HGEK_F10) then begin
      UnloadGameResources() ;
      GoMenu() ;
      Exit ;
    end ;
    Exit ;
  end;

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then pause:=True ;

  if mHGE.Input_KeyDown(HGEK_LEFT) or mHGE.Input_KeyDown(HGEK_A) then G.JumpLeft ;
  if mHGE.Input_KeyDown(HGEK_RIGHT) or mHGE.Input_KeyDown(HGEK_D) then G.JumpRight ;

  if G.IsMovingDown then
    if isBlockHit(dt,PointGet) then begin
      if arr_places[PointGet.X,PointGet.Y]=pBlockdown then begin
        arr_places[PointGet.X,PointGet.Y]:=pSpace ;
        SEPool.AddEffect(TSEMovementLinear.Create(
          SRPool.GetRenderByTag(calcTag(PointGet)),
          GetBlockLeft(PointGet.X),GetBlockTop(PointGet.Y),
          GetBlockLeft(PointGet.X),GetBlockTop(PointGet.Y-IfThen(PointGet.Y=0,2,1)),250));
        SRPool.GetRenderByTag(calcTag(PointGet)).Tag:=IntToStr(calcTag(PointGet.X,PointGet.Y-1)) ;
        if PointGet.Y>0 then arr_places[PointGet.X,PointGet.Y-1]:=pBlockdown ;
        ExecJump() ;
      end
      else
      if arr_places[PointGet.X,PointGet.Y]=pBlocktime then begin
        if blockt>blocktimeperiod/2 then ExecJump() ;
      end
      else
      if arr_places[PointGet.X,PointGet.Y]=pCake then begin
        arr_places[PointGet.X,PointGet.Y]:=pSpace ;
        SEPool.AddEffect(TSETransparentLinear.Create(
          SRPool.GetRenderByTag(calcTag(PointGet)),0,100,500));

        ExecJump() ;
      end
      else
      if arr_places[PointGet.X,PointGet.Y]=pSpring then begin
        PlaySound(SndSpring) ;

        G.SuperJump
      end
      else
      if arr_places[PointGet.X,PointGet.Y]=pGunRight then begin
        PlaySound(SndGun) ;

        G.RocketFlight(GetBlockLeft(PointGet.X)+BLOCKW+BLOCKW div 2,
          GetBlockTop(PointGet.Y),+1) ;
        arr_places[PointGet.X,PointGet.Y]:=pSpace ;
        SEPool.AddEffect(TSETransparentLinear.Create(
          SRPool.GetRenderByTag(calcTag(PointGet)),0,100,500));
      end
      else
      if arr_places[PointGet.X,PointGet.Y]=pGunLeft then begin
        PlaySound(SndGun) ;

        G.RocketFlight(GetBlockLeft(PointGet.X)-BLOCKW div 2,
          GetBlockTop(PointGet.Y),-1) ;
        arr_places[PointGet.X,PointGet.Y]:=pSpace ;
        SEPool.AddEffect(TSETransparentLinear.Create(
          SRPool.GetRenderByTag(calcTag(PointGet)),0,100,500));
      end
      else
        ExecJump() ;
    end ;

  if G.IsIntersectLeft(LEFT_SPACE,dt) then G.StopAndFix(LEFT_SPACE) ;
  if G.IsIntersectRight(LEFT_SPACE+BLOCKW*BLOCKNX,dt) then G.StopAndFix(LEFT_SPACE+BLOCKW*(BLOCKNX-1)) ;

  // Отскок от стен
  for j := 0 to BLOCKNY - 1 do
    if G.IsVertCoverWall(GetBlockTop(j),BLOCKH) then begin
      for i := 0 to BLOCKNX - 1 - 1 do
        if isNotSpace(i,j) then
          if G.IsIntersectLeft(GetBlockLeft(i)+BLOCKW,dt) then begin
            G.StopAndFix(GetBlockLeft(i)+BLOCKW) ;
            GoTo Fin ;
          end;
      for i := 0+1 to BLOCKNX - 1 do
        if isNotSpace(i,j) then
          if G.IsIntersectRight(GetBlockLeft(i),dt) then begin
            G.StopAndFix(GetBlockLeft(i)-BLOCKW) ;
            GoTo Fin ;
          end ;
    end;

Fin:

  for i := 0 to BLOCKNX - 1 do
    for j := 0 to BLOCKNY - 1 do
      if arr_places[i,j]=pBlocktime then
        SRPool.GetRenderByTag(calcTag(i,j)).transp:=IfThen(blockt>blocktimeperiod/2,0,100) ;

  SEPool.Update(dt) ;

  if IsWin() then begin
    PlaySound(SndWin) ;
    UnloadGameResources() ;
    PL.SigLevelCompleted(ActiveLevel);
    GoWin() ;
  end;

  if IsGameFail() then begin
    UnloadGameResources() ;
    GoFail() ;
  end;

  G.Update(dt);
  Wt.Update(dt);
  En.Update(dt);
  GamerAnim.Update(dt) ;
  if GamerAnim.GetFrame=9 then begin
    GamerAnim.Stop() ;
    GamerAnim.SetFrame(3) ;
  end ;

  blockt:=blockt+dt ;
  if blockt>blocktimeperiod then blockt:=blockt-blocktimeperiod ;
end;

function RenderFuncGame():Boolean ;
var mx,my:Single ;
    i,j:Integer ;
    delta:Integer ;
begin
  Result:=True ;
  mHGE.Input_GetMousePos(mx,my);

  mHGE.Gfx_BeginScene;
  mHGE.Gfx_Clear($00000000);

  sprBack.Render(0,0) ;

  SRPool.Render ;

  for i := 0 to BLOCKNX - 1 do
    for j := 0 to BLOCKNY - 1 do
      if arr_places[i,j]=pCake then
        sprBorder.Render(GetBlockLeft(i),GetBlockTop(j)) ;

  if G.IsViewRight then SRGamer.mirror:=[mirrHorz] else SRGamer.mirror:=[] ;
  
  fnt2.PrintF(SWindowOptions.GetXCenter,15,HGETEXT_CENTER,Texts.Values['LEVEL_N'],[ActiveLevel]);
  if Trim(LevelText)<>'' then begin
    fnt2.PrintF(100,40,HGETEXT_LEFT,Texts.Values['DISCORD_ADVICE'],[]);
    fnt2.PrintF(100,60,HGETEXT_LEFT,LevelText,[]);
    SRDiscordHelper.RenderAt(50,50);
  end; 

  delta:=0 ;
  if (GamerAnim.GetFrame>=4) and (GamerAnim.GetFrame<=6) then
    delta:=fixpos-G.GetY() ;
  if (GamerAnim.GetFrame=7) then delta:=20 ;
  if (GamerAnim.GetFrame=8) then delta:=10 ;

  SRGamer.RenderAt(G.getX,G.getY+delta);

  if En.getCode()=TYPE_MUSH then sprEnemy0.Render(En.getX(),En.getY()) ;
  if En.getCode()=TYPE_BAT then sprEnemy1.Render(En.getX(),En.getY()) ;

  if Wt.WaterLevel<SWindowOptions.Height then
    sprWater.RenderStretch(0,Wt.WaterLevel,SWindowOptions.Width,SWindowOptions.Height);

  if pause then begin
    sprPanel.Render(SWindowOptions.GetXCenter,120) ;
    fnt2.PrintF(SWindowOptions.GetXCenter,80,HGETEXT_CENTER,Texts.Values['TEXT_PAUSE'],[]);
  end;

  mHGE.Gfx_EndScene;
end;

procedure GoGameLevel(Level:Integer) ;
begin
  pause:=False ;
  ActiveLevel:=Level ;
  LoadLevel(Level) ;
  LoadGameResources() ;
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
  mHGE.System_SetState(HGE_RENDERFUNC,RenderFuncGame);
end;

end.
