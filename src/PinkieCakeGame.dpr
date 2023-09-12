program PinkieCakeGame;

{$APPTYPE GUI}

{$R *.res}

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
  Water in 'Water.pas',
  FFAbout in 'FFAbout.pas';

var i,j:Integer ;
begin
  Randomize() ;

  mHGE := HGECreate(HGE_VERSION);
  TAVHGEUtils.mHGE:=mHGE ;

  SWindowOptions:=TWindowOptionsNoMash.Create(800,600,False) ;

  SetGlobalWindowOptions(SWindowOptions) ;
  SpriteEffects.SetWindowOptions(SWindowOptions) ;

  SetPathForLoader('images\') ;

  mHGE.System_SetState(HGE_USESOUND,True) ;

  mHGE.System_SetState(HGE_WINDOWED,not SWindowOptions.FullScreen);
  mHGE.System_SetState(HGE_SCREENWIDTH,SWindowOptions.Width);
  mHGE.System_SetState(HGE_SCREENHEIGHT,SWindowOptions.Height);
  mHGE.System_SetState(HGE_SCREENBPP,32);
  mHGE.System_SetState(HGE_FPS,HGEFPS_VSYNC);
  mHGE.System_SetState(HGE_ICON,'MAINICON');

  if not mHGE.System_Initiate() then begin
    MessageBox(0,PChar(mHGE.System_GetErrorMessage),'Error',MB_OK or MB_ICONERROR or MB_SYSTEMMODAL);
    mHGE.System_Shutdown;
    mHGE := nil;
    Exit ;
  end ;

    SEPool:=TSpriteEffectPool.Create ;
    SRPool:=TSpriteRenderPool.Create ;

    fnt2:=THGEFont.Create('fonts\Nubers.fnt');

    langsall:=TStringList.Create() ;
    langsall.LoadFromFile('text\languages') ;

    setLang('ru') ;
    if FileExists('text\deflang') then
      with TStringList.Create() do begin
        LoadFromFile('text\deflang') ;
        if Count>0 then
          setLang(Trim(Strings[0])) ;
        Free ;
      end;


    Texts:=TStringList.Create ;
    loadTexts() ;

    mHGE.System_SetState(HGE_TITLE,Texts.Values['GAME_TITLE']);

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

