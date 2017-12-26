unit TetrisWindow;
interface

uses TetrisConfig, TetrisGame, TetrisBlocks, SDL2, SDL2_gfx;

type
  TBaseWindow = class
  protected
    FInitialized: boolean;
    FConfig: TConfig;
    FGame: TGame;
    FRunning: boolean;

  public
    procedure Init(c: TConfig); virtual; abstract;
    procedure Run(); virtual; abstract;
    function IsInitialized: boolean;

  end;

type
  TSDLWindow = class(TBaseWindow)
  private
    FSDLWindow: PSDL_Window;
    FSDLRenderer: PSDL_Renderer;
    FSDLEvent: PSDL_Event;

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
  IsInitialized := FInitialized;
end;

procedure TSDLWindow.Init(c: TConfig);
begin
  FConfig := c;

  if SDL_Init(SDL_INIT_VIDEO) < 0 then ProcessSDLError('SDL_Init');

  FGame := TGame.Create(c, SDL_GetTicks());

  FSDLWindow := SDL_CreateWindow('Tetris', 50, 50, FConfig.WindowWidth, FConfig.WindowHeight, SDL_WINDOW_SHOWN);
  if FSDLWindow = nil then ProcessSDLError('SDL_CreateWindow');

  FSDLRenderer := SDL_CreateRenderer(FSDLWindow, -1, SDL_RENDERER_ACCELERATED);
  if FSDLRenderer = nil then ProcessSDLError('SDL_CreateRenderer');

  new(FSDLEvent);

  FInitialized := true;
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
  boxRGBA(FSDLRenderer, xPosition + x * boxSize, yPosition + y * boxSize, xPosition + (x + 1) * boxSize, yPosition + (y + 1) * boxSize, r1, g1, b1, 255);
  boxRGBA(FSDLRenderer, 2 + xPosition + x * boxSize, 2 + yPosition + y * boxSize, xPosition - 2 + (x + 1) * boxSize, yPosition - 2 + (y + 1) * boxSize, r2, g2, b2, 255);
end;

begin
  SDL_SetRenderDrawColor(FSDLRenderer, 0, 0, 0, 255);
  SDL_RenderClear(FSDLRenderer);

  borderWidth := 5;

  boxSize := (FConfig.WindowHeight - 40) div FConfig.Height;
  totalWidth := boxSize * FConfig.Width;
  totalHeight := boxSize * FConfig.Height;
  xPosition := (FConfig.WindowWidth - totalWidth) div 2;
  yPosition := 10;

  borderLeft := xPosition - borderWidth;
  borderRight := xPosition + totalWidth + borderWidth;
  borderBottom := yPosition + totalHeight + borderWidth;
  borderTop := yPosition - borderWidth; 

  // Left
  boxRGBA(FSDLRenderer, borderLeft, borderTop, borderLeft + borderWidth, borderBottom, 0, 190, 0, 255);
  // Top
  boxRGBA(FSDLRenderer, borderLeft, borderTop, borderRight, borderTop + 5, 0, 190, 0, 255);
  // Bottom
  boxRGBA(FSDLRenderer, borderLeft, borderBottom - borderWidth, borderRight, borderBottom, 0, 190, 0, 255);
  // Right
  boxRGBA(FSDLRenderer, borderRight - borderWidth, borderTop, borderRight, borderBottom, 0, 190, 0, 255);

  for i := 0 to (FConfig.Width - 1) do
  begin
    for j := 0 to (FConfig.Height - 1) do
    begin
      DrawBox(i, j, 30, 30, 30, 0, 0, 0);
      if FGame.GetBoard().IsEmpty(i, j, true) then
      begin
        DrawBox(i, j, 0, 0, 0, 170, 40, 40);
      end;
    end;
  end;

  for i := 0 to 4 do
  begin
    for j := 0 to 4 do
    begin
      if (FGame.GetCurrentPiece().Blocks[i, j] <> 0) and FGame.GetBoard().IsOnBoard(i + FGame.GetCurrentX(), j + FGame.GetCurrentY()) then
      begin
        DrawBox(i + FGame.GetCurrentX(), j + FGame.GetCurrentY(), 0, 0, 0, 0, 255, 0);
      end;
    end;
  end;

  SDL_RenderPresent(FSDLRenderer);
end;

destructor TSDLWindow.Destroy;
begin
  if not FInitialized then exit;

  dispose(FSDLEvent);
  SDL_DestroyWindow(FSDLWindow);
  SDL_DestroyRenderer(FSDLRenderer);
  SDL_Quit;
end;

procedure TSDLWindow.Run;
begin
  FRunning := true;

  while FRunning do
  begin
    while SDL_PollEvent(FSDLEvent) = 1 do
    begin
      case FSDLEvent^.type_ of
        SDL_KEYDOWN:
        begin
          case FSDLEvent^.key.keysym.sym of
            SDLK_ESCAPE:
            begin
              FRunning := false;
              exit;
            end;
            SDLK_a: FGame.Move(Left);
            SDLK_d: FGame.Move(Right);
            SDLK_s: FGame.Move(FastStart);
            SDLK_z: FGame.Move(Rotate);
            SDLK_x: FGame.Move(Drop);
          end;
        end;
        SDL_KEYUP:
        begin
          case FSDLEvent^.key.keysym.sym of
            SDLK_s: FGame.Move(FastEnd);
          end;
        end;
      end;
    end;

    FGame.Update(SDL_GetTicks());

    Draw();

    SDL_Delay(32);
  end;
end;

end.
