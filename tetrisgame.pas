unit TetrisGame;
interface

uses TetrisConfig, TetrisBlocks, TetrisBoard;

type TMove = (Rotate, Drop, Left, Right, FastStart, FastEnd);

type
  TGame = class
  private
    FConfig: TConfig;
    FLastTime: integer;
    FFast: boolean;
    FBoard: TBoard;
    FCurrentPieceId, FCurrentPieceRotation, FCurrentX, FCurrentY: integer;
    { When game ends use these variables to reset the board }
    FEndLine, FEndType: integer;

    { Check if there is place for the piece and if it is move it there }
    procedure MovePieceIfPossible(x, y, pieceId, pieceRotation: integer);

    { Create new piece }
    procedure CreateNewPiece;

    { Store the moving piece to board and generate new }
    function EndMove(): boolean;
  public
    constructor Create(config: TConfig; time: integer);

    { Updating functions }
    procedure Move(m: TMove);

    { Ticking function }
    function Update(time: integer): boolean;

    function GetCurrentPiece(): TTetrisBlock;
    function GetCurrentPieceId(): integer;
    function GetCurrentPieceRotation(): integer;
    function GetCurrentX(): integer;
    function GetCurrentY(): integer;
    function GetBoard(): TBoard;
    
  end;

implementation

constructor TGame.Create(config: TConfig; time: integer);
begin
  { Randomize so we get random values everytime }
  randomize;

  FConfig := config;
  FFast := false;
  FLastTime := time;
  FEndLine := FConfig.Height - 1;
  FEndType := 1;

  { On the beginning create new piece }
  CreateNewPiece();

  { And clear board }
  FBoard := TBoard.Create(FConfig.Width, FConfig.Height);
  FBoard.Clear();
end;

procedure TGame.MovePieceIfPossible(x, y, pieceId, pieceRotation: integer);
begin
  if FBoard.CanPlaceShape(x, y, CTetrisBlocks[pieceId, pieceRotation].Blocks) then
  begin
    FCurrentX := x;
    FCurrentY := y;
    FCurrentPieceId := pieceId;
    FCurrentPieceRotation := pieceRotation;
  end;
end;

procedure TGame.CreateNewPiece();
begin
  FCurrentPieceId := random(7);
  FCurrentPieceRotation := random(4);
  FCurrentX := (FConfig.Width div 2) + GetCurrentPiece().InitialOffset[0];
  FCurrentY := GetCurrentPiece().InitialOffset[1];
end;

function TGame.EndMove(): boolean;
begin
  { On the end we store the block }
  FBoard.FillShape(FCurrentX, FCurrentY, 1, GetCurrentPiece().Blocks);
  { Check if it completes some lines }
  FBoard.DeletePossibleLines();

  { Or the game can be over }
  if FBoard.IsOver() then exit(true);

  { If not create new piece }
  CreateNewPiece();

  exit(false);
end;

procedure TGame.Move(m: TMove);
begin
  if FBoard.IsOver then exit;

  { If is not over handle different moves }
  case m of
    Rotate: MovePieceIfPossible(FCurrentX, FCurrentY, FCurrentPieceId, (FCurrentPieceRotation + 1) mod 4);
    Left: MovePieceIfPossible(FCurrentX - 1, FCurrentY, FCurrentPieceId, FCurrentPieceRotation);
    Right: MovePieceIfPossible(FCurrentX + 1, FCurrentY, FCurrentPieceId, FCurrentPieceRotation);
    FastStart:
      FFast := true;
    FastEnd:
      FFast := false;
    Drop:
    begin
      { On drop we move the block on the lowest possible position and store it there }
      while FBoard.CanPlaceShape(FCurrentX, FCurrentY, GetCurrentPiece().Blocks) do
        FCurrentY := FCurrentY + 1;

      FCurrentY := FCurrentY - 1;

      EndMove();
    end;
  end;  
end;

function TGame.Update(time: integer): boolean;
var waitingTime: integer;
begin
  if FFast then waitingTime := FConfig.WaitingTime div 2 else waitingTime := FConfig.WaitingTime;

  { If is game over clear board with "animation" and start over }
  if FBoard.IsOver() then
  begin
    FBoard.FillLine(FEndLine, FEndType);

    FEndLine := FEndLine - 1;

    if FEndLine < 0 then
    begin
      FEndLine := FConfig.Height - 1;
      FEndType := (FEndType + 1) mod 2;
    end;

    exit(true);
  end;

  { We wait for specified loop time (if we would not the game would be too fast) }
  if (time - FLastTime) > waitingTime then
  begin
    FLastTime := time;

    { In this tick we move block downwards if we can / if we can not we store it and create new }
    if FBoard.CanPlaceShape(FCurrentX, FCurrentY + 1, GetCurrentPiece().Blocks) then
      FCurrentY := FCurrentY + 1
    else
      exit(EndMove());
  end;

  exit(false);
end;

function TGame.GetCurrentPieceId(): integer;
begin
  GetCurrentPieceId := FCurrentPieceId;
end;

function TGame.GetCurrentPieceRotation(): integer;
begin
  GetCurrentPieceRotation := FCurrentPieceRotation;
end;

function TGame.GetCurrentX(): integer;
begin
  GetCurrentX := FCurrentX;
end;

function TGame.GetCurrentY(): integer;
begin
  GetCurrentY := FCurrentY;
end;

function TGame.GetBoard(): TBoard;
begin
  GetBoard := FBoard;
end;

function TGame.GetCurrentPiece(): TTetrisBlock;
begin
  GetCurrentPiece := CTetrisBlocks[FCurrentPieceId, FCurrentPieceRotation];
end;

end.
