unit FFAbout;

interface

procedure GoAbout ;

implementation
uses ObjModule, TAVHGEUtils, HGE, HGEFont, FFMenu, Math,
  CommonProc, SysUtils ;

const
  BUT_Y = 540 ;
  BUT_X = 402 ;

function FrameFuncAbout():Boolean ;
var mx,my:Single ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then GoMenu() ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin
    SRButBack.SetXY(BUT_X,BUT_Y) ;
    if SRButBack.IsMouseOver(mx,my) then GoMenu() ;
  end;

end ;

function RenderFuncAbout():Boolean ;
var mx,my:Single ;
    str:string ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  mHGE.Gfx_BeginScene;
  mHGE.Gfx_Clear($00000000);

  sprBack.Render(0,0) ;

  fnt2.SetColor($FFFFFFFF) ;
  SRButBack.SetXY(BUT_X,BUT_Y) ;
  SRButBack.bright:=IfThen(SRButBack.IsMouseOver(mx,my),140,100) ;
  SRButBack.Render() ;
  fnt2.PrintF(BUT_X,BUT_Y-10,HGETEXT_CENTER,'OK',[]);

  fnt2.SetColor($FF404040);
  fnt2.PrintF(SWindowOptions.GetXCenter(),60,HGETEXT_CENTER,AnsiUpperCase(Texts.Values['GAME_TITLE']),[]) ;
  fnt2.PrintF(SWindowOptions.GetXCenter(),80,HGETEXT_CENTER,Texts.Values['VERSION'],[]) ;
  fnt2.PrintF(SWindowOptions.GetXCenter(),130,HGETEXT_CENTER,Texts.Values['ABOUTTEXT'],[]) ;
  fnt2.PrintF(SWindowOptions.GetXCenter(),240,HGETEXT_CENTER,AnsiUpperCase(Texts.Values['CREDITS']),[]) ;
  fnt2.PrintF(SWindowOptions.GetXCenter(),290,HGETEXT_CENTER,credits_str,[]) ;

  sprMouse.Render(mx,my) ;

  mHGE.Gfx_EndScene;
end;

procedure GoAbout() ;
begin
  setFuncsNoRun(mHGE,FrameFuncAbout,RenderFuncAbout);
end;

end.
