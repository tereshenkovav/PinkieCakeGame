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
   SRButBack:TSpriteRender ;
   SRDiscordHelper:TSpriteRender ;
   SndJump,SndGun,SndSpring,SndWin:IEffect ;

   SRSound,SRNoSound:TSpriteRender ;

   fnt2:IHGEFont ;

   Texts:TStringList ;

   ActiveLevel:Integer ;

   PL:TPlayer ;

implementation

end.
