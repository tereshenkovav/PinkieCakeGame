unit Player;

interface
uses KeyStrList ;

type
  TPlayer = class
  private
    MaxLevelAvals:TKeyStrList ;
    FIsFirstRun:Boolean ;
  public
    function IsLevelAval(GameCode:string; LevelN:Integer):Boolean ;
    function GetCompletedCount(GameCode:string):Integer ;
    procedure SigLevelCompleted(GameCode:string; LevelN:Integer) ;
    function IsFirstRun():Boolean ;
    procedure SetRunOk() ;
    constructor CreateFromDefaultFile() ;
  end;

implementation
uses Classes, IniFiles, simple_files ;

{ TPlayer }

constructor TPlayer.CreateFromDefaultFile();
var List:TStringList ;
    i:Integer ;
begin
  MaxLevelAvals:=TKeyStrList.Create ;

  List:=TStringList.Create ;
  with TIniFile.Create(AppPath+'\player.ini') do begin
    ReadSections(List) ;
    for i := 0 to List.Count - 1 do
      MaxLevelAvals.Value[List[i]]:=ReadInteger(List[i],'MaxLevelAval',1);
    FIsFirstRun:=not ReadBool('Main','FirstRunOk',False) ;
    Free ;
  end;
  List.Free ;
end;

function TPlayer.GetCompletedCount(GameCode: string): Integer;
begin
  Result:=MaxLevelAvals.Value[GameCode]-1 ;
  if Result<0 then Result:=0 ;  
end;

function TPlayer.IsFirstRun: Boolean;
begin
  Result:=FIsFirstRun ;
end;

function TPlayer.IsLevelAval(GameCode:string; LevelN: Integer): Boolean;
var MLevel:Integer ;
begin
  MLevel:=MaxLevelAvals.Value[GameCode] ;
  if MLevel=0 then MLevel:=1 ;
  Result:=LevelN<=MLevel ;
end;

procedure TPlayer.SetRunOk;
begin
  with TIniFile.Create(AppPath+'\player.ini') do begin
    WriteBool('Main','FirstRunOk',True) ;
    Free ;
  end;
end;

procedure TPlayer.SigLevelCompleted(GameCode:string; LevelN: Integer);
begin
  if MaxLevelAvals.Value[GameCode]<LevelN+1 then begin
    MaxLevelAvals.Value[GameCode]:=LevelN+1 ;

    with TIniFile.Create(AppPath+'\player.ini') do begin
      WriteInteger(GameCode,'MaxLevelAval',MaxLevelAvals.Value[GameCode]);
      Free ;
    end;

  end;
end;

end.
