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

    procedure MovePieceIfPossible(x, y, pieceId, pieceRotation: integer);
    procedure CreateNewPiece;
    function EndMove(): boolean;
  public
    constructor Create(config: TConfig; time: integer);

    procedure Move(m: TMove);
    function Update(time: integer): boolean;

    function GetCurrentPiece(): TTetrisBlock;
    function GetCurrentPieceId(): integer;
    function GetCurrentPieceRotation(): integer;
    function GetCurrentX(): integer;
    function GetCurrentY(): integer;

    function IsOnBoard(x, y: integer): boolean;
    function IsEmpty(x, y: integer): boolean;
    
  end;

implementation

constructor TGame.Create(config: TConfig; time: integer);
begin
  randomize;

  FConfig := config;
  FFast := false;
  FLastTime := time;

  CreateNewPiece();

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
  FBoard.FillShape(FCurrentX, FCurrentY, 1, GetCurrentPiece().Blocks);
  FBoard.DeletePossibleLines();

  if FBoard.IsOver() then exit(true);

  CreateNewPiece();

  exit(false);
end;

procedure TGame.Move(m: TMove);
begin
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

  if (time - FLastTime) > waitingTime then
  begin
    FLastTime := time;

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

function TGame.IsOnBoard(x, y: integer): boolean;
begin
  IsOnBoard := FBoard.IsOnBoard(x, y);
end;

function TGame.IsEmpty(x, y: integer): boolean;
begin
  IsEmpty := FBoard.IsEmpty(x, y, true);
end;

function TGame.GetCurrentPiece(): TTetrisBlock;
begin
  GetCurrentPiece := CTetrisBlocks[FCurrentPieceId, FCurrentPieceRotation];
end;

end.
