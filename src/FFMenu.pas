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
  BUT_EXIT_X = 640 ;
  BUT_ABOUT_X = 500 ;

function PosLeft(i:Integer):Integer ;
begin
  Result:=450+((i-1) mod LEVEL_BY_ROW)*120 ;
end ;

function PosTop(i:Integer):Integer ;
begin
  Result:=140+((i-1) div LEVEL_BY_ROW)*50 ;
end ;

function FrameFuncMenu():Boolean ;
var mx,my:Single ;
    i,idx:Integer ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then begin
    UnloadGameResourcesCommon() ;
    Result:=True ;
    Exit ;
  end ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin
    SRButBack.scalex:=110 ;
    for i := 1 to GetCurrentLevelCount() do
      if PL.IsLevelAval(i) then begin
        SRButBack.SetXY(PosLeft(i),PosTop(i)) ;
        if SRButBack.IsMouseOver(mx,my) then begin
          GoAutoGame(i) ;
          Exit ;
        end ;
      end;
    SRButBack.scalex:=100 ;

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

    if (icons[lang].IsMouseOver(mx,my)) then begin
      idx:=langsall.IndexOf(lang) ;
      Inc(idx) ;
      if idx>=langsall.Count then idx:=0 ;
      setLang(langsall[idx]) ;
      loadTexts() ;
      mHGE.System_SetState(HGE_TITLE,Texts.Values['GAME_TITLE']);
    end;

  end;

  Result:=False ;
end;

function RenderFuncMenu():Boolean ;
var mx,my:Single ;
    i:Integer ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  mHGE.Gfx_BeginScene;
  mHGE.Gfx_Clear($00000000);

  sprBack.Render(0,0) ;

  SRStart.RenderAt(70,300);

  fnt2.SetColor($FFFFFFFF) ;
  SRButBack.scalex:=110 ;
  for i := 1 to GetCurrentLevelCount() do
    if PL.IsLevelAval(i) then begin
      SRButBack.SetXY(PosLeft(i),PosTop(i)) ;
      SRButBack.bright:=IfThen(SRButBack.IsMouseOver(mx,my),140,100) ;
      SRButBack.Render() ;
      fnt2.PrintF(PosLeft(i),PosTop(i)-10,HGETEXT_CENTER,Texts.Values['LEVEL_N'],[i]);
    end;
  SRButBack.scalex:=100 ;

  SRButBack.setXY(BUT_EXIT_X,BUT_Y) ;
  SRButBack.bright:=IfThen(SRButBack.IsMouseOver(mx,my),140,100) ;
  SRButBack.Render() ;
  fnt2.PrintF(BUT_EXIT_X,BUT_Y-10,HGETEXT_CENTER,Texts.Values['BUT_EXIT'],[]);

  SRButBack.setXY(BUT_ABOUT_X,BUT_Y) ;
  SRButBack.bright:=IfThen(SRButBack.IsMouseOver(mx,my),140,100) ;
  SRButBack.Render() ;
  fnt2.PrintF(BUT_ABOUT_X,BUT_Y-10,HGETEXT_CENTER,Texts.Values['BUT_ABOUT'],[]);

  fnt2.SetColor($FF404040);
  fnt2.PrintF(40,120,HGETEXT_LEFT,Texts.Values['HISTORY'],[]);
  fnt2.PrintF(560,60,HGETEXT_CENTER,Texts.Values['LEVELSELECT'],[]);

  if not PL.IsSoundOn() then begin
    SRNoSound.bright:=IfThen(SRNoSound.IsMouseOver(mx,my),140,100) ;
    SRNoSound.RenderAt(20,20);
  end
  else begin
    SRSound.bright:=IfThen(SRSound.IsMouseOver(mx,my),140,100) ;
    SRSound.RenderAt(20,20);
  end ;

  icons[lang].bright:=IfThen(icons[lang].IsMouseOver(mx,my),140,100) ;
  icons[lang].RenderAt(130,28) ;
  fnt2.PrintF(110,32,HGETEXT_CENTER,lang.ToUpper(),[]);

  sprMouse.Render(mx,my) ;

  mHGE.Gfx_EndScene;
end;


procedure GoMenu() ;
begin
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncMenu);
  mHGE.System_SetState(HGE_RENDERFUNC,RenderFuncMenu);
end;


end.
