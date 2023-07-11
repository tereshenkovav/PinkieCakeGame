unit Gamer;

interface

type
  TGamer = class
  private
    X:Single ;
    Y:Single ;
    VX:Single ;
    VY:Single ;
    oldY:Single ;
    oldX:Single ;
    W:Integer ;
    LastNotNolVX:Single ;
  public
    function GetX():Integer ;
    function GetY():Integer ;
    constructor Create(AX,AY,AW:Integer) ;
    procedure Update(dt:Single) ;
    procedure InvertVY() ;
    procedure JumpLeft() ;
    procedure JumpRight() ;
    procedure InvertVX() ;
    procedure SuperJump() ;
    procedure RocketFlight(FromX,FromY:Integer; Dir:Integer) ;
    function IsIntersectVert(Ay:Integer):Boolean ;
    function IsIntersectLeft(Ax:Integer):Boolean ;
    function IsIntersectRight(Ax:Integer):Boolean ;
    function IsMovingDown():Boolean ;
    function IsViewRight():Boolean ;
    function GetDistFromXCenter(AX:Integer):Integer ;
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
  oldY:=y ;
  oldX:=x ;
  W:=AW ;
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

procedure TGamer.InvertVX;
begin
  VX:=-VX ;
end;

procedure TGamer.InvertVY;
begin
  VY:=-400 ;
end;

function TGamer.IsIntersectLeft(Ax: Integer): Boolean;
begin
  Result:=((x-Ax)*(oldX-Ax)<=0) ;
end;

function TGamer.IsIntersectRight(Ax: Integer): Boolean;
begin
  Result:=((x+W-Ax)*(oldX+W-Ax)<=0) ;
end;

function TGamer.IsIntersectVert(Ay: Integer): Boolean;
begin
  Result:=((y-Ay)*(oldY-Ay)<=0) ;
end;

function TGamer.IsMovingDown: Boolean;
begin
  Result:=VY>0 ;
end;

function TGamer.IsViewRight: Boolean;
begin
  if VX=0 then Result:=LastNotNolVX>0 else Result:=VX>0 ;
end;

procedure TGamer.JumpLeft;
begin
  VX:=-MAX_JUMP_VEL ;
end;

procedure TGamer.JumpRight;
begin
  VX:=MAX_JUMP_VEL ;
end;

procedure TGamer.RocketFlight(FromX, FromY, Dir: Integer);
begin
  X:=FromX ;
  Y:=FromY ;
  VX:=Dir*900 ;
  VY:=-200 ;
end;

procedure TGamer.SuperJump;
begin
  VY:=-900 ;
end;

procedure TGamer.Update(dt: Single);
var K:Single ;
begin
  oldY:=y ;
  oldX:=x ;

  X:=X+VX*dt ;
  Y:=Y+VY*dt ;
  VY:=VY+G*dt ;
  VX:=VX-VX*dt ;
  if ABS(VX)<100 then VX:=0 ;

  if VX<>0 then LastNotNolVX:=VX ;
  
end;

end.
