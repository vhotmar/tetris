unit TetrisWindow;
interface

uses TetrisConfig, TetrisGame, TetrisBlocks, SDL2, SDL2_gfx;

type
  TBaseWindow = class
  protected
    Initialized: boolean;
    Config: TConfig;
    Game: TGame;
    Running: boolean;
  public
    procedure Init(c: TConfig); virtual; abstract;
    procedure Run(); virtual; abstract;
    function IsInitialized: boolean;
  end;


type
  TSDLWindow = class(TBaseWindow)
  private
    SDLWindow: PSDL_Window;
    SDLRenderer: PSDL_Renderer;
    SDLEvent: PSDL_Event;

    procedure ProcessSDLError(m: string);
    procedure Draw();
  public
    destructor Destroy; override;

    procedure Init(c: TConfig);
    procedure Run();
  end;

implementation

function TBaseWindow.IsInitialized(): boolean;
begin
  exit(Initialized);
end;

procedure TSDLWindow.Init(c: TConfig);
begin
  Config := c;
  Initialized := true;

  if SDL_Init(SDL_INIT_VIDEO) < 0 then ProcessSDLError('SDL_Init');

  Game := TGame.Create(c, SDL_GetTicks());

  SDLWindow := SDL_CreateWindow('Tetris', 50, 50, Config.WindowWidth, Config.WindowHeight, SDL_WINDOW_SHOWN);
  if SDLWindow = nil then ProcessSDLError('SDL_CreateWindow');

  SDLRenderer := SDL_CreateRenderer(SDLWindow, -1, SDL_RENDERER_ACCELERATED);
  if SDLRenderer = nil then ProcessSDLError('SDL_CreateRenderer');

  new(SDLEvent);
end;

procedure TSDLWindow.ProcessSDLError(m: string);
begin
  writeln('Error while: ', m, ' ', SDL_GetError());
  halt;
end;


procedure TSDLWindow.Draw();
var boxSize, totalWidth, totalHeight, xPosition, yPosition, borderLeft, borderRight, borderBottom, borderTop, borderWidth, i, j: integer;

procedure DrawBox(x, y, r1, g1, b1, r2, g2, b2: integer);
begin
  boxRGBA(SDLRenderer, xPosition + x * boxSize, yPosition + y * boxSize, xPosition + (x + 1) * boxSize, yPosition + (y + 1) * boxSize, r1, g1, b1, 255);
  boxRGBA(SDLRenderer, 2 + xPosition + x * boxSize, 2 + yPosition + y * boxSize, xPosition - 2 + (x + 1) * boxSize, yPosition - 2 + (y + 1) * boxSize, r2, g2, b2, 255);
end;

begin
  SDL_SetRenderDrawColor(SDLRenderer, 0, 0, 0, 255);
  SDL_RenderClear(SDLRenderer);

  borderWidth := 5;

  boxSize := (Config.WindowHeight - 40) div Config.Height;
  totalWidth := boxSize * Config.Width;
  totalHeight := boxSize * Config.Height;
  xPosition := (Config.WindowWidth - totalWidth) div 2;
  yPosition := 10;

  borderLeft := xPosition - borderWidth;
  borderRight := xPosition + totalWidth + borderWidth;
  borderBottom := yPosition + totalHeight + borderWidth;
  borderTop := yPosition - borderWidth; 

  // Left
  boxRGBA(SDLRenderer, borderLeft, borderTop, borderLeft + borderWidth, borderBottom, 0, 255, 0, 255);
  // Top
  boxRGBA(SDLRenderer, borderLeft, borderTop, borderRight, borderTop + 5, 0, 255, 0, 255);
  // Bottom
  boxRGBA(SDLRenderer, borderLeft, borderBottom - borderWidth, borderRight, borderBottom, 0, 255, 0, 255);
  // Right
  boxRGBA(SDLRenderer, borderRight - borderWidth, borderTop, borderRight, borderBottom, 0, 255, 0, 255);

  for i := 0 to (Config.Width - 1) do
  begin
    for j := 0 to (Config.Height - 1) do
    begin
      DrawBox(i, j, 30, 30, 30, 0, 0, 0);
      if Game.Board[i, j] then
      begin
        DrawBox(i, j, 0, 0, 0, 255, 0, 0);
      end;
    end;
  end;

  for i := 0 to 4 do
  begin
    for j := 0 to 4 do
    begin
      if CTetrisBlocks[Game.CurrentPieceId, Game.CurrentPieceRotation].Blocks[i, j] <> 0 then
      begin
        DrawBox(i + Game.CurrentX, j + Game.CurrentY, 0, 0, 0, 0, 255, 0);
      end;
    end;
  end;

  SDL_RenderPresent(SDLRenderer);
end;

destructor TSDLWindow.Destroy;
begin
  if not Initialized then exit;

  dispose(SDLEvent);
  SDL_DestroyWindow(SDLWindow);
  SDL_DestroyRenderer(SDLRenderer);
  SDL_Quit;
end;

procedure TSDLWindow.Run;
begin
  Running := true;

  while Running do
  begin
    while SDL_PollEvent(SDLEvent) = 1 do
    begin
      case sdlEvent^.type_ of
        SDL_KEYDOWN:
        begin
          case sdlEvent^.key.keysym.sym of
            SDLK_ESCAPE: Running := false;
            SDLK_a: Running := not Game.Update(Left, SDL_GetTicks());
            SDLK_d: Running := not Game.Update(Right, SDL_GetTicks());
            SDLK_s: Running := not Game.Update(FastStart, SDL_GetTicks());
            SDLK_z: Running := not Game.Update(Rotate, SDL_GetTicks());
            SDLK_x: Running := not Game.Update(Drop, SDL_GetTicks());
          end;
        end;
        SDL_KEYUP:
        begin
          case sdlEvent^.key.keysym.sym of
            SDLK_s: Running := not Game.Update(FastEnd, SDL_GetTicks());
          end;
        end;
      end;
    end;

    Running := not Game.Update(GameTick, SDL_GetTicks());

    Draw();
  end;
end;

end.
