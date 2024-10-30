unit Gamer;

interface

type
  TGamer = class
  private
    X:Single ;
    Y:Single ;
    VX:Single ;
    VY:Single ;
    W:Integer ;
    viewright:Boolean ;
  public
    function GetX():Integer ;
    function GetY():Integer ;
    constructor Create(AX,AY,AW:Integer) ;
    procedure Update(dt:Single) ;
    procedure JumpVert() ;
    procedure JumpLeft() ;
    procedure JumpRight() ;
    procedure StopAndFix(newx:Single) ;
    procedure SuperJump() ;
    procedure RocketFlight(FromX,FromY:Integer; Dir:Integer) ;
    function IsIntersectVert(Ay:Integer; dt:Single):Boolean ;
    function IsIntersectLeft(Ax:Integer; dt:Single):Boolean ;
    function IsIntersectRight(Ax:Integer; dt:Single):Boolean ;
    function IsMovingDown():Boolean ;
    function IsViewRight():Boolean ;
    function GetDistFromXCenter(AX:Integer):Integer ;
    function IsVertCoverWall(wally,wallh:Integer):Boolean ;
  end;

implementation

const G = 1000 ;
      MAX_JUMP_VEL = 200 ;

{ TGamer }

constructor TGamer.Create(AX,AY,AW:Integer);
begin
  X:=AX ;
  y:=AY ;
  VX:=0 ;
  VY:=0 ;
  W:=AW ;
  viewright:=True ;
end;

function TGamer.GetDistFromXCenter(AX:Integer): Integer;
begin
  Result:=Abs(Round(X+(W div 2)-AX)) ;
end;

function TGamer.GetX: Integer;
begin
  Result:=Round(X) ;
end;

function TGamer.GetY: Integer;
begin
  Result:=Round(Y) ;
end;

procedure TGamer.StopAndFix(newx:Single);
begin
  VX:=0 ;
  x:=newx ;
end;

procedure TGamer.JumpVert;
begin
  VY:=-400 ;
end;

function TGamer.IsIntersectLeft(Ax: Integer; dt:Single): Boolean;
begin
  Result:=(Ax<=x)and(x+VX*dt<=Ax)and(VX<0) ;
end;

function TGamer.IsIntersectRight(Ax: Integer; dt:Single): Boolean;
begin
  Result:=(x+W<=Ax)and(x+W+VX*dt>=Ax)and(VX>0) ;
end;

function TGamer.IsIntersectVert(Ay: Integer; dt:Single): Boolean;
begin
  Result:=(y<=Ay)and(y+VY*dt>=Ay)and(VY>0) ;
end;

function TGamer.IsMovingDown: Boolean;
begin
  Result:=VY>0 ;
end;

function TGamer.IsVertCoverWall(wally,wallh: Integer): Boolean;
begin
  Result:=Abs(y-wally)<wallh ;
end;

function TGamer.IsViewRight: Boolean;
begin
  Result:=viewright ;
end;

procedure TGamer.JumpLeft;
begin
  VX:=-MAX_JUMP_VEL ;
  viewright:=false ;
end;

procedure TGamer.JumpRight;
begin
  VX:=MAX_JUMP_VEL ;
  viewright:=true ;
end;

procedure TGamer.RocketFlight(FromX, FromY, Dir: Integer);
begin
  X:=FromX ;
  Y:=FromY ;
  VX:=Dir*900 ;
  viewright:=dir>0 ;
  VY:=-200 ;
end;

procedure TGamer.SuperJump;
begin
  VY:=-900 ;
end;

procedure TGamer.Update(dt: Single);
var K:Single ;
begin
  X:=X+VX*dt ;
  Y:=Y+VY*dt ;
  VY:=VY+G*dt ;
  VX:=VX-VX*dt ;
  if ABS(VX)<100 then VX:=0 ;
end;

end.
