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
uses TAVHGEUtils, Windows, HGE, HGEFont, ObjModule, Effects,FFMenu, CommonProc,
  FFWinFail, SpriteEffects, HGESprite, Gamer, Classes,
  SysUtils, Water, Math, Generics.Collections ;

type
  TPlace = (pSpace,pCake,pWall,pSpring,pGunRight,pGunLeft,pBlockDown) ;

var
   sprCakes:TList<IHGESprite> ;
   sprWall:IHGESprite ;
   sprBlockDown:IHGESprite ;
   sprSpring:IHGESprite ;
   sprGun:IHGESprite ;
   sprBorder:IHGESprite ;
   sprPanel:IHGESprite ;
   arr_places:array[0..31,0..31] of TPlace ;

   SRGamer:TSpriteRender ;
   G:TGamer ;
   Wt:TWater ;

   LevelText:string ;
   pause:Boolean ;

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
      Wt:=CreateWater(StrToInt(Strings[0]),Strings[1]='up') ;
      Free ;
    end
  else
    Wt:=CreateFakeWater() ;

  if List.IndexOfName('Hint')<>-1 then
    LevelText:=Texts.Values[List.Values['Hint']]
  else
    LevelText:='' ;

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

function GetBlockTop(j:Integer):Integer ;
begin
  Result:=SWindowOptions.Height-BOTTOM_SPACE-BLOCKH*(j+1) ;
end;

function GetBlockLeft(i:Integer):Integer ;
begin
  Result:=LEFT_SPACE+BLOCKW*i ;
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
  if G.GetY+BLOCKH>=Wt.WaterLevel then Exit(True) ;
  if G.GetY+BLOCKH>=SWindowOptions.Height then Exit(True) ;
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

  SRGamer:=TSpriteRender.Create(LoadSizedSprite(mHGE,'pinki_gamer.png'));
end ;

procedure UnloadGameResources() ;
begin
  SRPool.DelAllRenders ;
  sprCakes.Free ;
  SRGamer.Free ;
end;

function FrameFuncGame():Boolean ;
var i,j:Integer ;
    dt:Single ;
    PointGet:TPoint ;
    label fin, fin1 ;
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

  if G.IsMovingDown then begin

  // Расчет столкновения и съедания блока

  PointGet.X:=-1 ;
  PointGet.Y:=-1 ;

  for i := BLOCKNX-1 downto 0 do begin

    for j := BLOCKNY - 1 downto 0 do
      if arr_places[i,j]<>pSpace then begin

      if G.IsIntersectVert(GetBlockTop(j)-BLOCKH,dt) then

        if Abs(G.GetX()-GetBlockLeft(i))<BLOCKW then begin
          if PointGet.X=-1 then begin
            PointGet.X:=i ; PointGet.Y:=j ;
          end
          else begin
            if G.GetDistFromXCenter(GetBlockLeft(i)+(BLOCKW div 2))<
              G.GetDistFromXCenter(GetBlockLeft(PointGet.X)+(BLOCKW div 2)) then begin
                PointGet.X:=i ; PointGet.Y:=j ;
              end;
          end;
       end;

    end ; // j
  end ;

    if PointGet.X<>-1 then begin
      if arr_places[PointGet.X,PointGet.Y]=pBlockdown then begin
        arr_places[PointGet.X,PointGet.Y]:=pSpace ;
        SRPool.DelRenderByTag(calcTag(PointGet)) ;
        if PointGet.Y>0 then begin
          arr_places[PointGet.X,PointGet.Y-1]:=pBlockdown ;
          SRPool.AddRenderTagged(TSpriteRender.Create(
            sprBlockdown, GetBlockLeft(PointGet.X),GetBlockTop(PointGet.Y-1)),
            calcTag(PointGet.X,PointGet.Y-1)) ;
        end;

        PlaySound(SndJump) ;
        G.JumpVert() ;
      end
      else
      if arr_places[PointGet.X,PointGet.Y]=pCake then begin
        arr_places[PointGet.X,PointGet.Y]:=pSpace ;
        SEPool.AddEffect(TSETransparentLinear.Create(
          SRPool.GetRenderByTag(calcTag(PointGet)),0,100,500));

        PlaySound(SndJump) ;
        G.JumpVert() ;
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
      else begin
        PlaySound(SndJump) ;

        G.JumpVert() ;
      end;
    end ;

  end;


  if G.IsIntersectLeft(LEFT_SPACE,dt) then G.StopAndFix(LEFT_SPACE) ;
  if G.IsIntersectRight(LEFT_SPACE+BLOCKW*BLOCKNX,dt) then G.StopAndFix(LEFT_SPACE+BLOCKW*(BLOCKNX-1)) ;

  // Отскок от стены вправо
  for i := 0 to BLOCKNX - 1 - 1 do begin
    for j := 0 to BLOCKNY - 1 do
      if arr_places[i,j]<>pSpace then
        if G.IsIntersectLeft(GetBlockLeft(i)+BLOCKW,dt) then
          if ((G.GetY>GetBlockTop(j))and(G.GetY<=GetBlockTop(j)+BLOCKH)) or
             ((G.GetY+BLOCKH>GetBlockTop(j))and(G.GetY+BLOCKH<=GetBlockTop(j)+BLOCKH)) then begin
             G.StopAndFix(GetBlockLeft(i)+BLOCKW) ;
             GoTo Fin1 ;
             end;
  end;

Fin1:

  // Влево
  for i := 0+1 to BLOCKNX - 1 do begin
    for j := 0 to BLOCKNY - 1 do
      if arr_places[i,j]<>pSpace then
        if G.IsIntersectRight(GetBlockLeft(i),dt) then
          if ((G.GetY>GetBlockTop(j))and(G.GetY<=GetBlockTop(j)+BLOCKH)) or
             ((G.GetY+BLOCKH>GetBlockTop(j))and(G.GetY+BLOCKH<=GetBlockTop(j)+BLOCKH)) then begin
             G.StopAndFix(GetBlockLeft(i)-BLOCKW) ;
             Goto fin ;
             end;
  end;

  Fin:

  
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
end;

function RenderFuncGame():Boolean ;
var mx,my:Single ;
    i,j:Integer ;
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

  SRGamer.RenderAt(G.getX,G.getY);

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
