unit ObjModule;

interface
uses HGE, WindowOptions, SpriteEffects, HGESprite, Gamer, HGEFont,
  Player, Classes, Generics.Collections, Generics.Defaults ;

var
  mHGE:IHGE ;
  SWindowOptions:TWindowOptions ;
  SRPool:TSpriteRenderPool ;
  SEPool:TSpriteEffectPool ;

   sprMouse,sprBack,sprWater:IHGESprite ;

   SRStart:TSpriteRender ;
   SRWin,SRFail,SRFinalWin:TSpriteRender ;
   SRButBack:TSpriteRender ;
   SRDiscordHelper:TSpriteRender ;
   SndJump,SndGun,SndSpring,SndWin:IEffect ;

   SRSound,SRNoSound:TSpriteRender ;

   fnt2:IHGEFont ;

   Texts:TStringList ;
   langsall:TStringList ;
   lang:string ;
   icons:TDictionary<string,TSpriteRender> ;

   ActiveLevel:Integer ;

   PL:TPlayer ;

   credits_str:string ;

implementation

end.
