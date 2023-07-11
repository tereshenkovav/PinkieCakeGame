unit Water;

interface
uses Gamer ;

type
  TWater = class
  public
    procedure Update(dt:Single) ; virtual ;
    function IsGamerIntersect(G:TGamer):Boolean ; virtual ;
    function WaterLevel():Integer ; virtual ;
  end;

  TWaterStd = class(TWater)
  private
    Level:Single ;
    Dir:Integer ;
  public
    procedure Update(dt:Single) ; override ;
    function IsGamerIntersect(G:TGamer):Boolean ; override ;
    function WaterLevel():Integer ; override ;
  end;

function CreateWater(StartLevel:Integer; IsUp:Boolean):TWater ;
function CreateFakeWater():TWater ;

implementation
uses FFGame, simple_oper ;

function CreateWater(StartLevel:Integer; IsUp:Boolean):TWater ;
begin
  Result:=TWaterStd.Create() ;
  TWaterStd(Result).Level:=StartLevel ;
  TWaterStd(Result).Dir:=Alternate(IsUp,-1,1) ;
end;

function CreateFakeWater():TWater ;
begin
  Result:=TWater.Create ;
end;

{ TWater }

function TWater.IsGamerIntersect(G: TGamer): Boolean;
begin
  Result:=False ;
end;

procedure TWater.Update(dt: Single);
begin
  // NOP
end;

function TWater.WaterLevel: Integer;
begin
  Result:=High(Integer) ;
end;

{ TWaterStd }

function TWaterStd.IsGamerIntersect(G: TGamer): Boolean;
begin
  Result:=G.GetY+BLOCKH>=Level ;
end;

procedure TWaterStd.Update(dt: Single);
const WATER_SPEED=10 ;
begin
  Level:=Level+Dir*WATER_SPEED*dt ;
end;

function TWaterStd.WaterLevel: Integer;
begin
  Result:=Round(Level) ;
end;

end.
