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
   arr_blocks:array[0..31,0..31] of TSpriteRender ;
   arr_places:array[0..31,0..31] of TPlace ;

   SRGamer:TSpriteRender ;
   G:TGamer ;
   Wt:TWater ;

   LevelText:string ;


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

  LevelText:=Trim(List[3]) ;

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
  SndJump:=mHGE.Effect_Load('sounds\jump.mp3') ;
  SndGun:=mHGE.Effect_Load('sounds\gun.mp3') ;
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

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then begin
    UnloadGameResources() ;
    GoMenu() ;
    Exit ;
  end ;

  if mHGE.Input_KeyDown(HGEK_LEFT) then begin
    G.JumpLeft ;
  end;
  if mHGE.Input_KeyDown(HGEK_RIGHT) then begin
    G.JumpRight ;
  end;

  G.Update(dt);
  Wt.Update(dt);

  if G.IsMovingDown then begin

  // Расчет столкновения и съедания блока

  PointGet.X:=-1 ;
  PointGet.Y:=-1 ;

  for i := BLOCKNX-1 downto 0 do begin

    for j := BLOCKNY - 1 downto 0 do
      if arr_places[i,j]<>pSpace then begin

      if G.IsIntersectVert(GetBlockTop(j)-BLOCKH) then

        if ((G.GetX>GetBlockLeft(i))and(G.GetX<=GetBlockLeft(i)+BLOCKW)) or
           ((G.GetX+BLOCKW>GetBlockLeft(i))and(G.GetX+BLOCKW<=GetBlockLeft(i)+BLOCKW)) then begin
          if PointGet.X=-1 then begin
            PointGet.X:=i ; PointGet.Y:=j ;
          end
          else
          if PointGet.Y<j then begin
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


  if G.GetX<=LEFT_SPACE then G.InvertVX ;
  if G.GetX>=LEFT_SPACE+BLOCKW*(BLOCKNX-1) then G.InvertVX ;


  // Отскок от стены вправо
  for i := 0 to BLOCKNX - 1 - 1 do begin
    for j := 0 to BLOCKNY - 1 do
      if arr_places[i,j]<>pSpace then
        if G.IsIntersectLeft(GetBlockLeft(i)+BLOCKW) then
          if ((G.GetY>GetBlockTop(j))and(G.GetY<=GetBlockTop(j)+BLOCKH)) or
             ((G.GetY+BLOCKH>GetBlockTop(j))and(G.GetY+BLOCKH<=GetBlockTop(j)+BLOCKH)) then begin
             G.JumpRight ;
             GoTo Fin1 ;
             end;
  end;

Fin1:

  // Влево
  for i := 0+1 to BLOCKNX - 1 do begin
    for j := 0 to BLOCKNY - 1 do
      if arr_places[i,j]<>pSpace then
        if G.IsIntersectRight(GetBlockLeft(i)) then
          if ((G.GetY>GetBlockTop(j))and(G.GetY<=GetBlockTop(j)+BLOCKH)) or
             ((G.GetY+BLOCKH>GetBlockTop(j))and(G.GetY+BLOCKH<=GetBlockTop(j)+BLOCKH)) then begin
             G.JumpLeft ;
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

  Result:=False ;
end;

function RenderFuncGame():Boolean ;
var mx,my:Single ;
    i:Integer ;
    color:LongWord ;
    b:Byte ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  mHGE.Gfx_BeginScene;
  mHGE.Gfx_Clear($00000000);

  sprBack.Render(0,0) ;

  SRPool.Render ;

  if G.IsViewRight then SRGamer.mirror:=[mirrHorz] else SRGamer.mirror:=[] ;
  
  fnt2.PrintF(SWindowOptions.GetXCenter,15,HGETEXT_CENTER,'Карта %d',[ActiveLevel]);
  if Trim(LevelText)<>'' then begin
    fnt2.PrintF(100,40,HGETEXT_LEFT,'Советы Дискорда',[]);
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

  sprMouse.Render(mx,my) ;

  mHGE.Gfx_EndScene;

  Result:=False ;
end;

procedure GoGameLevel(Level:Integer) ;
begin
  ActiveLevel:=Level ;
  LoadLevel(Level) ;
  LoadGameResources() ;
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncGame);
  mHGE.System_SetState(HGE_RENDERFUNC,RenderFuncGame);
end;

end.
