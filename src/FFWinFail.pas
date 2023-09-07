unit FFWinFail;

interface

procedure GoWin ;
procedure GoFail ;

implementation
uses ObjModule, TAVHGEUtils, HGE, HGEFont, FFMenu, FFGame, Math,
  CommonProc ;

type
  TWinFailMode = (mWin,mFail) ;

function FrameFuncWinOrFail():Boolean ;
var mx,my:Single ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then begin
    Result:=True ;
    Exit ;
  end ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin
    if SRButMenu.IsMouseOver(mx,my) then GoMenu() ;
    if SRButReplay.IsMouseOver(mx,my) then
      GoAutoGame(ActiveLevel) ;
    if SRButNext.IsMouseOver(mx,my) and (SRButNext.transp<100) then
      GoAutoGame(ActiveLevel+1) ;
  end;

end ;

function intRenderFunc(Mode:TWinFailMode):Boolean ;
var mx,my:Single ;
    str:string ;
begin
  mHGE.Input_GetMousePos(mx,my);

  mHGE.Gfx_BeginScene;
  mHGE.Gfx_Clear($00000000);

  sprBack.Render(0,0) ;

  if Mode=mWin then begin
    if ActiveLevel<GetCurrentLevelCount then
      SRWin.RenderAt(300,250)
    else
      SRFinalWin.RenderAt(150,150)
  end
  else SRFail.RenderAt(300,250) ;

  SRButMenu.bright:=IfThen(SRButMenu.IsMouseOver(mx,my),200,100) ;
  SRButMenu.RenderAt(350,500) ;

  SRButNext.bright:=IfThen(SRButNext.IsMouseOver(mx,my),200,100) ;
  SRButNext.transp:=IfThen(
    (Mode=mWin)and(ActiveLevel<GetCurrentLevelCount),0,100) ;
  SRButNext.RenderAt(500,500) ;

  SRButReplay.bright:=IfThen(SRButReplay.IsMouseOver(mx,my),200,100) ;
  SRButReplay.RenderAt(200,500) ;

  sprMouse.Render(mx,my) ;

  fnt2.SetColor($FF404040);
  if Mode=mWin then begin
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

function RenderFuncWin():Boolean ;
begin
  intRenderFunc(mWin) ;
end;

procedure GoWin() ;
begin
  setFuncsNoRun(mHGE,FrameFuncWinOrFail,RenderFuncWin);
end;

function RenderFuncFail():Boolean ;
begin
  intRenderFunc(mFail) ;
end;

procedure GoFail() ;
begin
  setFuncsNoRun(mHGE,FrameFuncWinOrFail,RenderFuncFail);
end;

end.
