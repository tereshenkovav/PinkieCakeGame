unit FFMenu;

interface

procedure GoMenu() ;

implementation
uses
   FFGame,
   TAVHGEUtils, HGE, HGEFont, ObjModule, Classes, SysUtils, Gamer,
   SoundHelper, CommonProc, Math ;


function FrameFuncMenu():Boolean ;
var mx,my:Single ;
    i:Integer ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then begin
    UnloadGameResourcesCommon() ;
    Result:=True ;
    Exit ;
  end ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin
    for i := 1 to GetCurrentLevelCount() do
      if PL.IsLevelAval(i) then
        if SRButCmn[i].IsMouseOver(mx,my) then begin
          GoAutoGame(i) ;
          Exit ;
        end ;

    if SRButBack.IsMouseOver(mx,my) then begin
      UnloadGameResourcesCommon() ;
      Result:=True ;
      Exit ;
    end ;

    if SRSound.IsMouseOver(mx,my) or SRNoSound.IsMouseOver(mx,my) then begin
      UserNoSound:=not UserNoSound ;
      SaveSoundOpt() ;
    end;
       
  end;

  Result:=False ;
end;

function RenderFuncMenu():Boolean ;
var mx,my:Single ;
    i:Integer ;
const
  LEVEL_BY_ROW=3 ;

function PosLeft(i:Integer):Integer ;
begin
  Result:=450+((i-1) mod LEVEL_BY_ROW)*110 ;
end ;

function PosTop(i:Integer):Integer ;
begin
  Result:=250+((i-1) div LEVEL_BY_ROW)*50 ;
end ;

begin
  mHGE.Input_GetMousePos(mx,my);

  mHGE.Gfx_BeginScene;
  mHGE.Gfx_Clear($00000000);

  sprBack.Render(0,0) ;

  SRStart.SetScaleBoth(75);
  SRStart.RenderAt(10,100);

  fnt2.SetColor($FFFFFFFF) ;
  for i := 1 to GetCurrentLevelCount() do
    if PL.IsLevelAval(i) then begin
      SRButCmn[i].bright:=IfThen(SRButCmn[i].IsMouseOver(mx,my),200,100) ;
      SRButCmn[i].RenderAt(PosLeft(i),PosTop(i)) ;
      fnt2.PrintF(PosLeft(i),PosTop(i)-10,HGETEXT_CENTER,' ‡Ú‡ %d',[i]);
    end;

  SRButBack.bright:=IfThen(SRButBack.IsMouseOver(mx,my),200,100) ;
  SRButBack.scalex:=150 ;
  SRButBack.RenderAt(200,550) ;
  fnt2.PrintF(200,550-10,HGETEXT_CENTER,'¬˚ıÓ‰',[]);

  sprMouse.Render(mx,my) ;

  fnt2.SetColor($FF404040);
  fnt2.PrintF(400,40,HGETEXT_LEFT,Texts.Values['HISTORY'],[]);
  fnt2.PrintF(560,190,HGETEXT_CENTER,'¬€¡Œ– ”–Œ¬Õﬂ',[]);

  if UserNoSound then begin
    SRNoSound.bright:=IfThen(SRNoSound.IsMouseOver(mx,my),200,100) ;
    SRNoSound.RenderAt(30,30)
  end
  else begin
    SRSound.bright:=IfThen(SRSound.IsMouseOver(mx,my),200,100) ;
    SRSound.RenderAt(30,30);
  end ;

  mHGE.Gfx_EndScene;
end;


procedure GoMenu() ;
begin
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncMenu);
  mHGE.System_SetState(HGE_RENDERFUNC,RenderFuncMenu);
end;


end.
