unit CommonProc;

interface
uses Classes, HGE ;

procedure LoadGameResourcesCommon() ;
procedure UnLoadGameResourcesCommon() ;
function GetLevelCountByGame():Integer ;
procedure GoAutoGame(Level:Integer) ;
function AppDataPath():string ;
procedure PlaySound(snd:IEffect) ;
procedure setLang(Alang:string) ;
procedure loadTexts() ;

implementation
uses SysUtils, ObjModule, TAVHGEUtils, SpriteEffects,
  FFGame, System.JSON, IOUtils, Generics.Collections, Generics.Defaults ;

var R:Integer=-1 ;

procedure loadTexts() ;
var i:Integer ;
begin
  Texts.LoadFromFile('text\texts.'+lang);
  for i := 0 to Texts.Count - 1 do
    Texts.ValueFromIndex[i]:=StringReplace(Texts.ValueFromIndex[i],'\n',#13,[rfReplaceAll]) ;
end;

procedure setLang(Alang:string) ;
begin
  if lang=Alang then Exit ;
  if langsall.IndexOf(Alang)<>-1 then lang:=Alang ;
end;

function AppDataPath():string ;
begin
  Result:=GetEnvironmentVariable('LOCALAPPDATA')+'\PinkieCakeGame'; ;
  if not DirectoryExists(Result) then ForceDirectories(Result) ;
end ;

procedure GoAutoGame(Level:Integer) ;
begin
  FFGame.GoGameLevel(Level) ;
end;

function GetLevelCountByGame():Integer ;
begin
  if R=-1 then begin
    R:=0 ;
    while FileExists(Format('levels\pinki_level%d',[R+1])) do Inc(R) ;
  end ;
  Result:=R ;
end;

procedure LoadGameResourcesCommon() ;
var i:Integer ;
    json:TJSonValue;
    arr:TJsonArray ;
    s:string ;
begin
  SRStart:=TSpriteRender.Create(LoadSizedSprite(mHGE,'pinki_start.png'));
  SRWin:=TSpriteRender.Create(LoadSizedSprite(mHGE,'pinki_win.png'));
  SRFinalWin:=TSpriteRender.Create(LoadSizedSprite(mHGE,'pinki_finalwin.png'));
  SRFail:=TSpriteRender.Create(LoadSizedSprite(mHGE,'pinki_fail.png'));

  SndWin:=mHGE.Effect_Load('sounds\win.wav') ;

  SRButBack:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
      'butcmn_pinki.png'));

  SRDiscordHelper:=TSpriteRender.Create(LoadAndCenteredSizedSprite(mHGE,
    'discord_helper.png')) ;

  credits_str:='' ;
  if FileExists('text\credits.json') then begin
    json := TJSONObject.ParseJSONValue(TFile.ReadAllText('text\credits.json'));
    arr:=json as TJsonArray ;
    for i:=0 to arr.Count-1 do
      credits_str:=credits_str+UTF8ToAnsi(arr.Items[i].Value)+#13 ;
  end;

  icons:=TDictionary<string,TSpriteRender>.Create() ;
  for s in langsall do
    icons.Add(s,TSpriteRender.Create(LoadSizedSprite(mHGE,
      'lang.'+s+'.png'))) ;

end ;

procedure PlaySound(snd:IEffect) ;
begin
  if PL.IsSoundOn() then Snd.Play ;
end ;

procedure UnLoadGameResourcesCommon() ;
begin
  SRStart.Free ;
  SRWin.Free ;
  SRFail.Free ;
  SRFinalWin.Free ;
  SRButBack.Free ;
  SRDiscordHelper.Free ;
end;


end.
