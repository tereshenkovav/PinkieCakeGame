unit CommonProc;

interface
uses Classes ;

procedure LoadGameResourcesCommon(code:string) ;
procedure UnLoadGameResourcesCommon() ;
function GetLevelCountByGame(Code:string):Integer ;
procedure GoAutoGame(Level:Integer) ;

implementation
uses SysUtils, ObjModule, TAVHGEUtils, SpriteEffects, SoundHelper,
  FFGame, simple_oper ;

var LCList:TStringList ;

procedure GoAutoGame(Level:Integer) ;
begin
  FFGame.GoGameLevel(Level) ;
end;

function GetLevelCountByGame(Code:string):Integer ;
var idx,R:Integer ;
begin
  if LCList=nil then LCList:=TStringList.Create ;

  if LCList.IndexOfName(Code)=-1 then begin
    R:=0 ;
    while FileExists(Format(Code+'_level%d',[R+1])) do Inc(R) ;
    idx:=LCList.Add(Format('%s=%d',[Code,R])) ;
  end ;
  Result:=StrToIntWt0(LCList.Values[Code]) ;


end;

procedure LoadGameResourcesCommon(code:string) ;
var i:Integer ;
begin
  SRStart:=TSpriteRender.Create(LoadSizedSprite(mHGE,code+'_start.png'));
  SRWin:=TSpriteRender.Create(LoadSizedSprite(mHGE,code+'_win.png'));
  SRFinalWin:=TSpriteRender.Create(LoadSizedSprite(mHGE,code+'_finalwin.png'));
  SRFail:=TSpriteRender.Create(LoadSizedSprite(mHGE,code+'_fail.png'));

  SndWin:=LoadSound('win.mp3') ;

  for i := 1 to GetCurrentLevelCount do
    SRButCmn[i]:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
      Format('butcmn_%s.png',[code])));

  SRButBack:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
      Format('butcmn_%s.png',[code])));

  SRButMenu:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    Format('butmenu_%s.png',[code])));
  SRButReplay:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    Format('butreplay_%s.png',[code])));
  SRButNext:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    Format('butnext_%s.png',[code])));

  SRDiscordHelper:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'discord_helper.png')) ;
    
end ;

procedure UnLoadGameResourcesCommon() ;
var i:Integer ;
begin
  SRStart.Free ;
  SRWin.Free ;
  SRFail.Free ;
  SRFinalWin.Free ;
  SRButBack.Free ;
  for i := 1 to GetCurrentLevelCount do
    SRButCmn[i].Free ;
//  SndWin.Free ;
  SRButMenu.Free ;
  SRButReplay.Free ;
  SRButNext.Free ;
  SRDiscordHelper.Free ;
end;


end.
