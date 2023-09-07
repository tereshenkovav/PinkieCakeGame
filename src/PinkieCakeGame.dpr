program PinkieCakeGame;

{$APPTYPE GUI}

uses
  Windows,
  SysUtils,
  Classes,
  HGE,
  HGEFont,
  TAVHGEUtils,
  SpriteEffects,
  WindowOptions,
  CommonProc in 'CommonProc.pas',
  FFGame in 'FFGame.pas',
  FFMenu in 'FFMenu.pas',
  FFWinFail in 'FFWinFail.pas',
  Gamer in 'Gamer.pas',
  ObjModule in 'ObjModule.pas',
  Player in 'Player.pas',
  Water in 'Water.pas';

var i,j:Integer ;
begin
  Randomize() ;

  mHGE := HGECreate(HGE_VERSION);
  TAVHGEUtils.mHGE:=mHGE ;

  SWindowOptions:=TWindowOptionsNoMash.Create(800,600,False) ;

  SetGlobalWindowOptions(SWindowOptions) ;
  SpriteEffects.SetWindowOptions(SWindowOptions) ;

  mHGE.System_SetState(HGE_USESOUND,True) ;
  mHGE.System_SetState(HGE_TITLE,'PGame');

  mHGE.System_SetState(HGE_WINDOWED,not SWindowOptions.FullScreen);
  mHGE.System_SetState(HGE_SCREENWIDTH,SWindowOptions.Width);
  mHGE.System_SetState(HGE_SCREENHEIGHT,SWindowOptions.Height);
  mHGE.System_SetState(HGE_SCREENBPP,32);

  if not mHGE.System_Initiate() then begin
    MessageBox(0,PChar(mHGE.System_GetErrorMessage),'Error',MB_OK or MB_ICONERROR or MB_SYSTEMMODAL);
    mHGE.System_Shutdown;
    mHGE := nil;
    Exit ;
  end ;

    SEPool:=TSpriteEffectPool.Create ;
    SRPool:=TSpriteRenderPool.Create ;

    fnt:=THGEFont.Create('fontsys.fnt');
    fnt2:=THGEFont.Create('Nubers.fnt');

    Texts:=TStringList.Create ;
    Texts.LoadFromFile('texts');
    for i := 0 to Texts.Count - 1 do
      Texts.ValueFromIndex[i]:=StringReplace(Texts.ValueFromIndex[i],'\n',#13,[rfReplaceAll]) ;

    // Common player
    PL:=TPlayer.CreateFromDefaultFile() ;

  // Load game

  sprMouse:=LoadSizedSprite(mHGE,'cursorSys.png') ;
  sprBack:=LoadSizedSprite(mHGE,'back.png') ;

  sprWater:=LoadSizedSprite(mHGE,'water.png') ;

  SRSound:=TSpriteRender.Create(LoadSizedSprite(mHGE,'sound.png'));
  SRNoSound:=TSpriteRender.Create(LoadSizedSprite(mHGE,'sound_no.png'));

  LoadGameResourcesCommon() ;
  GoMenu() ;
  mHGE.System_Start ;

  PL.Free ;

  SRPool.Free ;
  SEPool.Free ;

  mHGE.System_Shutdown;
  mHGE := nil;

end.

