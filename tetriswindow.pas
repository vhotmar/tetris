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

    { Get Error from SDL and print it to console }
    procedure ProcessSDLError(m: string);

    { Draw the state }
    procedure Draw();

  public
    destructor Destroy; override;

    { Initialize window and SDL context }
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

  { Init SDL and Game }
  if SDL_Init(SDL_INIT_VIDEO) < 0 then ProcessSDLError('SDL_Init');

  FGame := TGame.Create(c, SDL_GetTicks());

  { Create SDL window }
  FSDLWindow := SDL_CreateWindow('Tetris', 50, 50, FConfig.WindowWidth, FConfig.WindowHeight, SDL_WINDOW_SHOWN);
  if FSDLWindow = nil then ProcessSDLError('SDL_CreateWindow');

  { Create SDL renderer }
  FSDLRenderer := SDL_CreateRenderer(FSDLWindow, -1, SDL_RENDERER_ACCELERATED);
  if FSDLRenderer = nil then ProcessSDLError('SDL_CreateRenderer');

  { Init pointer to SDL event (usde in Update) }
  new(FSDLEvent);

  FInitialized := true;
end;

procedure TSDLWindow.ProcessSDLError(m: string);
begin
  writeln('Error while: ', m, ' ', SDL_GetError());
  halt;
end;


procedure TSDLWindow.Draw();
var
  boxSize, totalWidth, totalHeight, xPosition, yPosition, borderLeft, borderRight, borderBottom, borderTop, borderWidth, i, j: integer;
  sdlRectangle: PSDL_Rect;

procedure DrawRectangle(x1, y1, x2, y2, r, g, b: integer);
begin
  sdlRectangle^.x := x1;
  sdlRectangle^.y := y1;
  sdlRectangle^.w := x2 - x1;
  sdlRectangle^.h := y2 - y1;

  SDL_SetRenderDrawColor(FSDLRenderer, r, g, b, 255);
  SDL_RenderFillRect(FSDLRenderer, sdlRectangle);
end;

{ Function to draw box with border rgb1 is for border, rgb2 is for background }
procedure DrawBox(x, y, r1, g1, b1, r2, g2, b2: integer);
var sdlRectangle: PSDL_Rect;
begin
  DrawRectangle(xPosition + x * boxSize, yPosition + y * boxSize, xPosition + (x + 1) * boxSize, yPosition + (y + 1) * boxSize, r1, g1, b1);
  DrawRectangle(2 + xPosition + x * boxSize, 2 + yPosition + y * boxSize, xPosition - 2 + (x + 1) * boxSize, yPosition - 2 + (y + 1) * boxSize, r2, g2, b2);
end;

begin
  new(sdlRectangle);

  SDL_SetRenderDrawColor(FSDLRenderer, 0, 0, 0, 255);
  SDL_RenderClear(FSDLRenderer);

  { Helper values for borders etc. }
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

  { Draw borders }
  { Left }
  DrawRectangle(borderLeft, borderTop, borderLeft + borderWidth, borderBottom, 0, 190, 0);
  { Top }
  DrawRectangle(borderLeft, borderTop, borderRight, borderTop + 5, 0, 190, 0);
  { Bottom }
  DrawRectangle(borderLeft, borderBottom - borderWidth, borderRight, borderBottom, 0, 190, 0);
  {  }
  DrawRectangle(borderRight - borderWidth, borderTop, borderRight, borderBottom, 0, 190, 0);

  { Draw grid and filled blocks }
  for i := 0 to (FConfig.Width - 1) do
    for j := 0 to (FConfig.Height - 1) do
      if FGame.GetBoard().IsEmpty(i, j, true) then
        DrawBox(i, j, 0, 0, 0, 170, 40, 40)
      else
        DrawBox(i, j, 30, 30, 30, 0, 0, 0);

  { Draw moving boxes }
  for i := 0 to 4 do
    for j := 0 to 4 do
      if (FGame.GetCurrentPiece().Blocks[i, j] <> 0) and FGame.GetBoard().IsOnBoard(i + FGame.GetCurrentX(), j + FGame.GetCurrentY()) then
        DrawBox(i + FGame.GetCurrentX(), j + FGame.GetCurrentY(), 0, 0, 0, 0, 255, 0);

  { Render it to window! }
  SDL_RenderPresent(FSDLRenderer);

  dispose(sdlRectangle);
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
    { While running check for events (key downs, ups) and send them to Game }
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
        SDL_QUITEV:
          FRunning := false;
      end;
    end;

    { Say the game that it should update }
    FGame.Update(SDL_GetTicks());

    { Draw the game (separated from the game logic) }
    Draw();

    { Wait for 32 ms... should achieve around 30 fpx }
    SDL_Delay(32);
  end;
end;

end.
