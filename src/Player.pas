unit Player;

interface

type
  TPlayer = class
  private
    FIsFirstRun:Boolean ;
    MaxLevelAval:Integer ;
    UserNoSound:Boolean ;
  public
    function IsLevelAval(LevelN:Integer):Boolean ;
    function GetCompletedCount():Integer ;
    procedure SigLevelCompleted(LevelN:Integer) ;
    function IsSoundOn():Boolean ;
    procedure SwitchSound() ;
    constructor CreateFromDefaultFile() ;
  end;

implementation
uses Classes, IniFiles, Math, SysUtils, CommonProc ;

{ TPlayer }

constructor TPlayer.CreateFromDefaultFile();
begin
  with TIniFile.Create(AppDataPath+'\player.ini') do begin
    MaxLevelAval:=ReadInteger('Main','MaxLevelAval',1);
    UserNoSound:=ReadBool('Main','NoSound',False) ;
    Free ;
  end;
end;

function TPlayer.GetCompletedCount(): Integer;
begin
  Result:=MaxLevelAval-1 ;
  if Result<0 then Result:=0 ;  
end;

function TPlayer.IsLevelAval(LevelN: Integer): Boolean;
begin
  Result:=LevelN<=IfThen(MaxLevelAval=0,1,MaxLevelAval) ;
end;

function TPlayer.IsSoundOn: Boolean;
begin
  Result:=not UserNoSound ;
end;

procedure TPlayer.SwitchSound() ;
begin
  UserNoSound:=not UserNoSound ;
  with TIniFile.Create(AppDataPath+'\player.ini') do begin
    WriteBool('Main','NoSound',UserNoSound) ;
    Free ;
  end;
end;

procedure TPlayer.SigLevelCompleted(LevelN: Integer);
begin
  if MaxLevelAval<LevelN+1 then begin
    MaxLevelAval:=LevelN+1 ;
    with TIniFile.Create(AppDataPath+'\player.ini') do begin
      WriteInteger('Main','MaxLevelAval',MaxLevelAval);
      Free ;
    end;

  end;
end;

end.
