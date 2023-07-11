unit CommonClasses;

interface
uses IniFiles, Windows ;

type
  TPointSingle = record
    X:Single ;
    Y:Single ;
  end ;

  TIniFileEx=class(TIniFile)
  public
    function ReadPoint(Section,Name:string):TPoint ;
    function ReadColor(Section,Name:string):Cardinal ;
  end;

function PointSingle(x,y:Single):TPointSingle ;

implementation
uses simple_oper ;

function PointSingle(x,y:Single):TPointSingle ;
begin
  Result.X:=x ;
  Result.Y:=y ;
end;

{ TIniFileEx }

function TIniFileEx.ReadColor(Section, Name: string): Cardinal;
var s:string ;
    i:Integer ;
begin
  s:=HexToStr(ReadString(Section,Name,'FFFFFFF')) ;

  if Length(s)=3 then
    Result:=$FF000000+(ord(s[1]) shl 16) + (ord(s[2]) shl 8) + ord(s[3])
  else
    Result:=(ord(s[1]) shl 32)+(ord(s[2]) shl 16) + (ord(s[3]) shl 8) + ord(s[4]) ;
end;

function TIniFileEx.ReadPoint(Section, Name: string): TPoint;
begin
  Result.X:=ReadInteger(Section,Name+'_X',0) ;
  Result.Y:=ReadInteger(Section,Name+'_Y',0) ;  
end;

end.
