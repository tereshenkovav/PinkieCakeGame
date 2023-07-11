unit FFWinFail;

interface

procedure GoWin ;
procedure GoFail ;

implementation
uses ObjModule, TAVHGEUtils, HGE, HGEFont, simple_oper, FFMenu, FFGame,
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

  SRButMenu.bright:=Alternate(SRButMenu.IsMouseOver(mx,my),200,100) ;
  SRButMenu.RenderAt(350,500) ;

  SRButNext.bright:=Alternate(SRButNext.IsMouseOver(mx,my),200,100) ;
  SRButNext.transp:=Alternate(
    (Mode=mWin)and(ActiveLevel<GetCurrentLevelCount),0,100) ;
  SRButNext.RenderAt(500,500) ;

  SRButReplay.bright:=Alternate(SRButReplay.IsMouseOver(mx,my),200,100) ;
  SRButReplay.RenderAt(200,500) ;

  sprMouse.Render(mx,my) ;

  fnt2.SetColor($FF404040);
  if Mode=mWin then begin
    if ActiveLevel<GetCurrentLevelCount then
      str:=Texts.Values[CurrentGameCode+'_WINTEXT']
    else
      str:=Texts.Values[CurrentGameCode+'_FINALWINTEXT'] ;
  end
  else
    str:=Texts.Values[CurrentGameCode+'_FAILTEXT'] ;

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
