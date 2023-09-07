unit FFMenu;

interface

procedure GoMenu() ;

implementation
uses
   FFGame,FFAbout,
   TAVHGEUtils, HGE, HGEFont, ObjModule, Classes, SysUtils, Gamer,
   CommonProc, Math ;

const
  LEVEL_BY_ROW=3 ;
  BUT_Y = 550 ;
  BUT_EXIT_X = 120 ;
  BUT_ABOUT_X = 280 ;

function PosLeft(i:Integer):Integer ;
begin
  Result:=450+((i-1) mod LEVEL_BY_ROW)*110 ;
end ;

function PosTop(i:Integer):Integer ;
begin
  Result:=250+((i-1) div LEVEL_BY_ROW)*50 ;
end ;

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
      if PL.IsLevelAval(i) then begin
        SRButBack.SetXY(PosLeft(i),PosTop(i)) ;
        if SRButBack.IsMouseOver(mx,my) then begin
          GoAutoGame(i) ;
          Exit ;
        end ;
      end;

    SRButBack.setXY(BUT_EXIT_X,BUT_Y) ;
    if SRButBack.IsMouseOver(mx,my) then begin
      UnloadGameResourcesCommon() ;
      Result:=True ;
      Exit ;
    end ;

    SRButBack.setXY(BUT_ABOUT_X,BUT_Y) ;
    if SRButBack.IsMouseOver(mx,my) then begin
      GoAbout() ;
      Exit ;
    end ;

    if SRSound.IsMouseOver(mx,my) or SRNoSound.IsMouseOver(mx,my) then PL.SwitchSound() ;

  end;

  Result:=False ;
end;

function RenderFuncMenu():Boolean ;
var mx,my:Single ;
    i:Integer ;
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
      SRButBack.SetXY(PosLeft(i),PosTop(i)) ;
      SRButBack.bright:=IfThen(SRButBack.IsMouseOver(mx,my),140,100) ;
      SRButBack.Render() ;
      fnt2.PrintF(PosLeft(i),PosTop(i)-10,HGETEXT_CENTER,Texts.Values['LEVEL_N'],[i]);
    end;

  SRButBack.setXY(BUT_EXIT_X,BUT_Y) ;
  SRButBack.bright:=IfThen(SRButBack.IsMouseOver(mx,my),140,100) ;
  SRButBack.Render() ;
  fnt2.PrintF(BUT_EXIT_X,BUT_Y-10,HGETEXT_CENTER,Texts.Values['BUT_EXIT'],[]);

  SRButBack.setXY(BUT_ABOUT_X,BUT_Y) ;
  SRButBack.bright:=IfThen(SRButBack.IsMouseOver(mx,my),140,100) ;
  SRButBack.Render() ;
  fnt2.PrintF(BUT_ABOUT_X,BUT_Y-10,HGETEXT_CENTER,Texts.Values['BUT_ABOUT'],[]);

  sprMouse.Render(mx,my) ;

  fnt2.SetColor($FF404040);
  fnt2.PrintF(400,40,HGETEXT_LEFT,Texts.Values['HISTORY'],[]);
  fnt2.PrintF(560,190,HGETEXT_CENTER,Texts.Values['LEVELSELECT'],[]);

  if not PL.IsSoundOn() then begin
    SRNoSound.bright:=IfThen(SRNoSound.IsMouseOver(mx,my),140,100) ;
    SRNoSound.RenderAt(30,30)
  end
  else begin
    SRSound.bright:=IfThen(SRSound.IsMouseOver(mx,my),140,100) ;
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
