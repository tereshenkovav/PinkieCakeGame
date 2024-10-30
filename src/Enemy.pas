unit Enemy;

interface
uses Gamer ;

type
  TEnemy = class
  public
    procedure Update(dt:Single) ; virtual ;
    function IsGamerIntersect(G:TGamer):Boolean ; virtual ;
    function getX():Integer ; virtual ;
    function getY():Integer ; virtual ;
  end;

  TEnemyStd = class(TEnemy)
  private
    x,vx,y,x1,x2:Single ;
  public
    constructor Create(Ax1,Ax2,Ay:Integer) ;
    procedure Update(dt:Single) ; override ;
    function IsGamerIntersect(G:TGamer):Boolean ; override ;
    function getX():Integer ; override ;
    function getY():Integer ; override ;
  end;

implementation
uses FFGame, Math ;

const ENEMY_SPEED=2*BLOCKW ;

{ TEnemy }

function TEnemy.IsGamerIntersect(G: TGamer): Boolean;
begin
  Result:=False ;
end;

procedure TEnemy.Update(dt: Single);
begin
end;

function TEnemy.getX: Integer;
begin
  Result:=-100 ;
end;

function TEnemy.getY: Integer;
begin
  Result:=-100 ;
end;

{ TEnemyStd }

constructor TEnemyStd.Create(Ax1, Ax2, Ay: Integer);
begin
  x1:=Ax1 ;
  x2:=Ax2 ;
  x:=x1 ;
  y:=Ay ;
  vx:=ENEMY_SPEED ;
end;

function TEnemyStd.getX: Integer;
begin
  Result:=Round(x) ;
end;

function TEnemyStd.getY: Integer;
begin
  Result:=Round(y) ;
end;

function TEnemyStd.IsGamerIntersect(G: TGamer): Boolean;
begin
  Result:=(Abs(G.GetX()-x)<BLOCKW) and (Abs(G.GetY()-y)<BLOCKH) ;
end;

procedure TEnemyStd.Update(dt: Single);
begin
  x:=x+vx*dt ;
  if (vx>0)and(x>=x2) then begin
    x:=x2 ;
    vx:=-vx ;
  end;
  if (vx<0)and(x<=x1) then begin
    x:=x1 ;
    vx:=-vx ;
  end;
end;

end.
