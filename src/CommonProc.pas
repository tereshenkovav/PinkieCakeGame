unit CommonProc;

interface
uses Classes ;

procedure LoadGameResourcesCommon() ;
procedure UnLoadGameResourcesCommon() ;
function GetLevelCountByGame():Integer ;
procedure GoAutoGame(Level:Integer) ;
function AppDataPath():string ;

implementation
uses SysUtils, ObjModule, TAVHGEUtils, SpriteEffects, SoundHelper,
  FFGame ;

var R:Integer=-1 ;

function AppDataPath():string ;
begin
  Result:=ExtractFileDir(ParamStr(0))
end ;

procedure GoAutoGame(Level:Integer) ;
begin
  FFGame.GoGameLevel(Level) ;
end;

function GetLevelCountByGame():Integer ;
begin
  if R=-1 then begin
    R:=0 ;
    while FileExists(Format('pinki_level%d',[R+1])) do Inc(R) ;
  end ;
  Result:=R ;
end;

procedure LoadGameResourcesCommon() ;
var i:Integer ;
begin
  SRStart:=TSpriteRender.Create(LoadSizedSprite(mHGE,'pinki_start.png'));
  SRWin:=TSpriteRender.Create(LoadSizedSprite(mHGE,'pinki_win.png'));
  SRFinalWin:=TSpriteRender.Create(LoadSizedSprite(mHGE,'pinki_finalwin.png'));
  SRFail:=TSpriteRender.Create(LoadSizedSprite(mHGE,'pinki_fail.png'));

  SndWin:=LoadSound('win.mp3') ;

  for i := 1 to GetCurrentLevelCount do
    SRButCmn[i]:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
      'butcmn_pinki.png'));

  SRButBack:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
      'butcmn_pinki.png'));

  SRButMenu:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    'butmenu_pinki.png'));
  SRButReplay:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    'butreplay_pinki.png'));
  SRButNext:=TSpriteRender.Create(LoadSizedSprite(mHGE,
    'butnext_pinki.png'));

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
