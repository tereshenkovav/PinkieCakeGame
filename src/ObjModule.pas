unit ObjModule;

interface
uses HGE, WindowOptions, SpriteEffects, HGESprite, Gamer, HGEFont,
  Player, Classes ;

var
  mHGE:IHGE ;
  SWindowOptions:TWindowOptions ;
  SRPool:TSpriteRenderPool ;
  SEPool:TSpriteEffectPool ;

   sprMouse,sprBack,sprWater:IHGESprite ;

   SRStart:TSpriteRender ;
   SRWin,SRFail,SRFinalWin:TSpriteRender ;
   SRButMenu,SRButReplay,SRButNext:TSpriteRender ;
   SRButCmn:array[1..32] of TSpriteRender ;
   SRButBack:TSpriteRender ;
   SRDiscordHelper:TSpriteRender ;
   SndJump,SndGun,SndSpring,SndWin:IEffect ;

   SRSound,SRNoSound:TSpriteRender ;

   fnt,fnt2:IHGEFont ;

   Texts:TStringList ;

   CurrentGameCode:string='pinki' ;
   ActiveLevel:Integer ;

   PL:TPlayer ;

implementation

end.
