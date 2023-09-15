unit FFExitMenu;

interface

function procConfirmExit():Boolean ;

implementation

uses
  TAVHGEUtils, HGE, SpriteEffects, ObjModule,
  HGEFont, Math ;

var pframe,prender:THGECallback ;
    isatexitmenu:Boolean = False ;

const
  BUT_Y = 320 ;
  BUT_X_YES = 330 ;
  BUT_X_NO = 470 ;

function FrameFuncExitMenu():Boolean ;
var mx,my:Single ;
    dt:Single ;
begin
  Result:=False ;

  mHGE.Input_GetMousePos(mx,my);

  if mHGE.Input_KeyDown(HGEK_ESCAPE) then begin
    isatexitmenu:=False ;
    mHGE.System_SetState(HGE_FRAMEFUNC,pframe);
    mHGE.System_SetState(HGE_RENDERFUNC,prender);
    Exit ;
  end ;

  if mHGE.Input_KeyDown(HGEK_LBUTTON) then begin
    SRButBack.SetXY(BUT_X_YES,BUT_Y) ;
    if SRButBack.IsMouseOver(mx,my) then begin
      Result:=True ;
      Exit ;
    end ;
    SRButBack.SetXY(BUT_X_NO,BUT_Y) ;
    if SRButBack.IsMouseOver(mx,my) then begin
      isatexitmenu:=False ;
      mHGE.System_SetState(HGE_FRAMEFUNC,pframe);
      mHGE.System_SetState(HGE_RENDERFUNC,prender);
      Exit ;
    end ;
  end ;

end ;

function RenderFuncExitMenu():Boolean ;
var mx,my:Single ;
    HIB:Single ;
    XC:Single ;
begin
  mHGE.Input_GetMousePos(mx,my);

  mHGE.Gfx_BeginScene;
  mHGE.Gfx_Clear($00000000);

  sprBack.Render(0,0) ;

  fnt2.SetColor($FFFFFFFF) ;
  SRButBack.SetXY(BUT_X_YES,BUT_Y) ;
  SRButBack.bright:=IfThen(SRButBack.IsMouseOver(mx,my),140,100) ;
  SRButBack.Render() ;
  fnt2.PrintF(BUT_X_YES,BUT_Y-10,HGETEXT_CENTER,Texts.Values['BUT_YES'],[]);

  SRButBack.SetXY(BUT_X_NO,BUT_Y) ;
  SRButBack.bright:=IfThen(SRButBack.IsMouseOver(mx,my),140,100) ;
  SRButBack.Render() ;
  fnt2.PrintF(BUT_X_NO,BUT_Y-10,HGETEXT_CENTER,Texts.Values['BUT_NO'],[]);

  fnt2.SetColor($FF404040);
  fnt2.PrintF(SWindowOptions.GetXCenter(),250,HGETEXT_CENTER,Texts.Values['TEXT_CONFIRM_EXIT'],[]) ;

  sprMouse.Render(mx,my) ;

  mHGE.Gfx_EndScene;
end ;

function procConfirmExit():Boolean ;
begin
  Result:=False ;

  if isatexitmenu then Exit ;

  isatexitmenu:=True ;

  pframe:=mHGE.System_GetState(HGE_FRAMEFUNC);
  prender:=mHGE.System_GetState(HGE_RENDERFUNC);
  mHGE.System_SetState(HGE_FRAMEFUNC,FrameFuncExitMenu);
  mHGE.System_SetState(HGE_RENDERFUNC,RenderFuncExitMenu);
end;

end.
