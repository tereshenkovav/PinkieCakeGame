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
function GetCurrentLevelCount():Integer ;

implementation
uses TAVHGEUtils, Windows, HGE, HGEFont, ObjModule, Effects,FFMenu, CommonProc,
  FFWinFail, SpriteEffects, HGESprite, Gamer, Classes,
  SysUtils, Water, Math ;

type
  TPlace = (pSpace,pCake,pWall,pSpring,pGunRight,pGunLeft) ;

var
   sprCake:array[0..31] of IHGESprite ;
   sprWall:IHGESprite ;
   sprSpring:IHGESprite ;
   sprGun:IHGESprite ;
   sprBorder:IHGESprite ;
   sprPanel:IHGESprite ;
   arr_blocks:array[0..31,0..31] of TSpriteRender ;
   arr_places:array[0..31,0..31] of TPlace ;

   SRGamer:TSpriteRender ;
   G:TGamer ;
   Wt:TWater ;

   LevelText:string ;
   pause:Boolean ;


function GetCurrentLevelCount():Integer ;
begin
  Result:=GetLevelCountByGame() ;
end;

procedure LoadLevel(n:Integer) ;
var i,j:Integer ;
    List:TStringList ;
    ise:Boolean ;
begin
  SEPool.DelAllEffects ;

  List:=TStringList.Create ;
  List.LoadFromFile(Format('levels\pinki_level%d',[n])) ;

  G:=TGamer.Create(StrToInt(List[0]),StrToInt(List[1]),BLOCKW) ;
  with TStringList.Create() do begin
    CommaText:=List[2] ;
    if Count>0 then begin

      if Strings[0]='water' then
        Wt:=CreateWater(StrToInt(Strings[1]),Strings[2]='up')
      else
        Wt:=CreateFakeWater() ;

    end
    else
      Wt:=CreateFakeWater() ;
    Free ;
  end;

  LevelText:=Texts.Values[Trim(List[3])] ;

  List.Delete(0) ; List.Delete(0) ; List.Delete(0) ; List.Delete(0) ;

  for j := BLOCKNY - 1 downto 0 do begin
    for i := 0 to BLOCKNX - 1 do begin
    try
      arr_places[i,j]:=TPlace(StrToInt(List[List.Count-1-j][i+1])) ;
    except
      arr_places[i,j]:=pSpace ;
    end;
    end;
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
var i,j,cnt:Integer ;
begin

  cnt:=0 ;
  for i := 0 to BLOCKNX-1 do
    for j := 0 to BLOCKNY - 1 do
      if arr_places[i,j]=pCake then Inc(cnt) ;

  Result:=(cnt=0) ;
end;

function IsGameFail():Boolean ;
begin
  Result:=False ;
  if not Result then
    Result:=G.GetY+BLOCKH>=Wt.WaterLevel ;
  
  if not Result then
    Result:=G.GetY+BLOCKH>=SWindowOptions.Height ;
      
end;

procedure LoadGameResources() ;
var i,j:Integer ;
    CakeCount:Integer ;
begin
  SndJump:=mHGE.Effect_Load('sounds\jump.wav') ;
  SndGun:=mHGE.Effect_Load('sounds\gun.wav') ;
  SndSpring:=mHGE.Effect_Load('sounds\spring.wav') ;

  CakeCount:=0 ;
  while FileExists(Format('images\cake%d.png',[CakeCount+1])) do
    Inc(CakeCount) ;
  mHGE.System_Log('CakeCount=%d',[CakeCount]) ;

  for i := 0 to CakeCount-1 do
    sprCake[i]:=LoadSizedSprite(mHGE,Format('cake%d.png',[i+1])) ;

  sprWall:=LoadSizedSprite(mHGE,'wall.png') ;
  sprSpring:=LoadSizedSprite(mHGE,'spring.png') ;
  sprGun:=LoadSizedSprite(mHGE,'gun.png') ;
  sprBorder:=LoadSizedSprite(mHGE,'border.png') ;
  sprPanel:=LoadAndCenteredSizedSprite(mHGE,'panel.png') ;

  Randomize ;
  for i := 0 to BLOCKNX - 1 do
    for j := 0 to BLOCKNY - 1 do begin
      if arr_places[i,j]=pWall then
      arr_blocks[i,j]:=TSpriteRender.Create(
        sprWall, GetBlockLeft(i),GetBlockTop(j))
      else
      if arr_places[i,j]=pSpring then
      arr_blocks[i,j]:=TSpriteRender.Create(
        sprSpring, GetBlockLeft(i),GetBlockTop(j))
      else
      if arr_places[i,j]=pGunRight then
      arr_blocks[i,j]:=TSpriteRender.Create(
        sprGun, GetBlockLeft(i),GetBlockTop(j))
      else
      if arr_places[i,j]=pGunLeft then begin
        arr_blocks[i,j]:=TSpriteRender.Create(
          sprGun, GetBlockLeft(i),GetBlockTop(j)) ;
        arr_blocks[i,j].mirror:=[mirrHorz];  
      end
      else
      arr_blocks[i,j]:=TSpriteRender.Create(
        sprCake[Round(Random(CakeCount))],
        GetBlockLeft(i),GetBlockTop(j));

      arr_blocks[i,j].transp:=IfThen(arr_places[i,j]=pSpace,100,0) ;

      SRPool.AddRender(arr_blocks[i,j]);
    end;

  SRGamer:=TSpriteRender.Create(LoadSizedSprite(mHGE,'pinki_gamer.png'));
end ;

procedure UnloadGameResources() ;
begin
  SRPool.DelAllRenders ;
  SRGamer.Free ;
end;

function FrameFuncGame():Boolean ;
var mx,my:Single ;
    i,j,k:Integer ;
    isfail:Boolean ;
    C1,C2:Cardinal ;
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

  // ������ ������������ � �������� �����

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
      if arr_places[PointGet.X,PointGet.Y]=pCake then begin
        arr_places[PointGet.X,PointGet.Y]:=pSpace ;
        SEPool.AddEffect(TSETransparentLinear.Create(
          arr_blocks[PointGet.X,PointGet.Y],0,100,500));
      end ;
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
          arr_blocks[PointGet.X,PointGet.Y],0,100,500));
      end
      else
      if arr_places[PointGet.X,PointGet.Y]=pGunLeft then begin
        PlaySound(SndGun) ;

        G.RocketFlight(GetBlockLeft(PointGet.X)-BLOCKW div 2,
          GetBlockTop(PointGet.Y),-1) ;
        arr_places[PointGet.X,PointGet.Y]:=pSpace ;
        SEPool.AddEffect(TSETransparentLinear.Create(
          arr_blocks[PointGet.X,PointGet.Y],0,100,500));
      end
      else begin
        PlaySound(SndJump) ;

        G.InvertVY ;
      end;
    end ;

  end;


  if G.IsIntersectLeft(LEFT_SPACE,dt) then G.StopAndFix(LEFT_SPACE) ;
  if G.IsIntersectRight(LEFT_SPACE+BLOCKW*BLOCKNX,dt) then G.StopAndFix(LEFT_SPACE+BLOCKW*(BLOCKNX-1)) ;

  // ������ �� ����� ������
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

  // �����
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

  Result:=False ;
end;

function RenderFuncGame():Boolean ;
var mx,my:Single ;
    i,j:Integer ;
    color:LongWord ;
    b:Byte ;
begin
  Result:=False ;

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

  if Wt.WaterLevel<SWindowOptions.Height then begin
    b:=128 ;
    Color:=$00FFFFFF ;
    sprWater.SetColor(b shl 24 +(color and $FFFFFF)) ;
    sprWater.RenderStretch(0,Wt.WaterLevel,SWindowOptions.Width,SWindowOptions.Height);
  end;

  if pause then begin
    sprPanel.Render(SWindowOptions.GetXCenter,120) ;
    fnt2.PrintF(SWindowOptions.GetXCenter,80,HGETEXT_CENTER,Texts.Values['TEXT_PAUSE'],[]);
  end;

  mHGE.Gfx_EndScene;

  Result:=False ;
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
