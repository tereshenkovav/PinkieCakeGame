unit SoundHelper;

interface
uses HGE ;
var
  NoSound:Boolean=False ;
  UserNoSound:Boolean=False ;

function LoadSound(FileName:string):IEffect ;
procedure PlaySound(snd:IEffect) ;

procedure InitLib() ;
procedure SaveSoundOpt() ;
procedure LoadSoundOpt() ;

implementation
uses TAVHGEUtils, IniFiles, CommonProc ;


procedure InitLib() ;
begin
end;

procedure SaveSoundOpt() ;
begin
  with TIniFile.Create(AppDataPath+'/sound.ini') do begin
    WriteBool('Main','NoSound',UserNoSound) ;
    Free ;
  end;
end;

procedure LoadSoundOpt() ;
begin
  with TIniFile.Create(AppDataPath+'/sound.ini') do begin
    UserNoSound:=ReadBool('Main','NoSound',False) ;
    Free ;
  end;
end;

procedure PlaySound(snd:IEffect) ;
begin
  if NoSound or UserNoSound then Exit ;
  Snd.Play ;
end ;

function LoadSound(FileName:string):IEffect ;
begin
  Result := nil;
  if NoSound then Exit ;

  Result:=mHGE.Effect_Load(FileName) ;
end ;

end.
