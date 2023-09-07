unit FFWinFail;

interface

procedure GoWin ;
procedure GoFail ;

implementation
uses ObjModule, TAVHGEUtils, HGE, HGEFont, FFMenu, FFGame, Math,
  CommonProc ;

type
  TWinFailMode = (mWin,mFail) ;

var tekmode:TWinFailMode ;

const
  BUT_Y = 500 ;
  BUT_REPLAY_X = 212 ;
  BUT_MENU_X = 402 ;
  BUT_NEXT_X = 592 ;

function FrameFuncWinOrFail():Boolean ;
var mx,my:Single ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then GoMenu() ;
  if mHGE.Input_KeyDown(HGEK_F5) then GoAutoGame(ActiveLevel) ;
  if mHGE.Input_KeyDown(HGEK_ENTER) then
    if (tekmode=mWin)and(ActiveLevel<GetCurrentLevelCount) then
      GoAutoGame(ActiveLevel+1) ;

  SRButBack.scalex:=145 ;
  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin
    SRButBack.SetXY(BUT_MENU_X,BUT_Y) ;
    if SRButBack.IsMouseOver(mx,my) then GoMenu() ;
    SRButBack.SetXY(BUT_REPLAY_X,BUT_Y) ;
    if SRButBack.IsMouseOver(mx,my) then GoAutoGame(ActiveLevel) ;
    SRButBack.SetXY(BUT_NEXT_X,BUT_Y) ;
    if (tekmode=mWin)and(ActiveLevel<GetCurrentLevelCount) then
      if SRButBack.IsMouseOver(mx,my) then GoAutoGame(ActiveLevel+1) ;
  end;

  SRButBack.scalex:=100 ;
end ;

function RenderFuncWinOrFail():Boolean ;
var mx,my:Single ;
    str:string ;
begin
  mHGE.Input_GetMousePos(mx,my);

  mHGE.Gfx_BeginScene;
  mHGE.Gfx_Clear($00000000);

  sprBack.Render(0,0) ;

  if tekmode=mWin then begin
    if ActiveLevel<GetCurrentLevelCount then
      SRWin.RenderAt(300,250)
    else
      SRFinalWin.RenderAt(150,150)
  end
  else SRFail.RenderAt(300,250) ;

  fnt2.SetColor($FFFFFFFF) ;

  SRButBack.scalex:=145 ;
  SRButBack.SetXY(BUT_MENU_X,BUT_Y) ;
  SRButBack.bright:=IfThen(SRButBack.IsMouseOver(mx,my),140,100) ;
  SRButBack.Render() ;
  fnt2.PrintF(BUT_MENU_X,BUT_Y-10,HGETEXT_CENTER,Texts.Values['BUT_MENU'],[]);

  if (tekmode=mWin)and(ActiveLevel<GetCurrentLevelCount) then begin
    SRButBack.SetXY(BUT_NEXT_X,BUT_Y) ;
    SRButBack.bright:=IfThen(SRButBack.IsMouseOver(mx,my),140,100) ;
    SRButBack.Render() ;
    fnt2.PrintF(BUT_NEXT_X,BUT_Y-10,HGETEXT_CENTER,Texts.Values['BUT_NEXT'],[]);
  end;

  SRButBack.SetXY(BUT_REPLAY_X,BUT_Y) ;
  SRButBack.bright:=IfThen(SRButBack.IsMouseOver(mx,my),140,100) ;
  SRButBack.Render() ;
  fnt2.PrintF(BUT_REPLAY_X,BUT_Y-10,HGETEXT_CENTER,Texts.Values['BUT_REPLAY'],[]);

  SRButBack.scalex:=100 ;

  sprMouse.Render(mx,my) ;

  fnt2.SetColor($FF404040);
  if tekmode=mWin then begin
    if ActiveLevel<GetCurrentLevelCount then
      str:=Texts.Values['WINTEXT']
    else
      str:=Texts.Values['FINALWINTEXT'] ;
  end
  else
    str:=Texts.Values['FAILTEXT'] ;

  fnt2.PrintF(SWindowOptions.GetXCenter(),100,HGETEXT_CENTER,str,[]) ;

  mHGE.Gfx_EndScene;
end;

procedure GoWin() ;
begin
  tekmode:=mWin ;
  setFuncsNoRun(mHGE,FrameFuncWinOrFail,RenderFuncWinOrFail);
end;

procedure GoFail() ;
begin
  tekmode:=mFail ;
  setFuncsNoRun(mHGE,FrameFuncWinOrFail,RenderFuncWinOrFail);
end;

end.
