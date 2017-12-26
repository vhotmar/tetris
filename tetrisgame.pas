unit TetrisGame;
interface

uses TetrisConfig, TetrisBlocks;

type TMove = (Rotate, Drop, Left, Right, FastStart, FastEnd, GameTick);

type
  TGame = class
  private
    Config: TConfig;
    LastTime: integer;
    Fast: boolean;

    procedure FillBlock(x, y, pieceId, pieceRotation: integer);
    procedure DeleteLine(y: integer);
    procedure ClearBoard;
    procedure DeletePossible;

    function IsOver: boolean;
    function IsLineFilled(y: integer): boolean;
    function CanMove(x, y, pieceId, pieceRotation: integer): boolean;
    procedure MoveIfPossible(x, y, pieceId, pieceRotation: integer);
    procedure Print;
    procedure CreateNew;
  public
    Board: array of array of boolean;
    CurrentPieceId, CurrentPieceRotation, CurrentX, CurrentY: integer;
    
    constructor Create(c: TConfig; time: integer);

    function Update(m: TMove; time: integer): boolean;
  end;

implementation

constructor TGame.Create(c: TConfig; time: integer);
begin
  randomize;

  Config := c;
  Fast := false;
  LastTime := time;

  CreateNew;

  setlength(Board, Config.Width, Config.Height);
  ClearBoard;
end;

procedure TGame.ClearBoard;
var i, j: integer;
begin
  for i := 0 to (Config.Width - 1) do
  begin
    for j := 0 to (Config.Height - 1) do
    begin
      Board[i, j] := false;
    end;
  end;
end;

procedure TGame.FillBlock(x, y, pieceId, pieceRotation: integer);
var i, j: integer;
begin
  for i := 0 to 4 do
  begin
    for j := 0 to 4 do
    begin
      if ((x + i) < Config.Width) and ((y + j) < Config.Height) and (CTetrisBlocks[pieceId, pieceRotation].Blocks[i, j] <> 0) then
        Board[x + i, y + j] := true;
    end;
  end;
end;

procedure TGame.Print();
var i, j: integer;
begin
  for j := 0 to (Config.Height - 1) do
  begin
    for i := 0 to (Config.Width - 1) do
    begin
      if Board[i, j] then write('1') else write('0');
    end;

    writeln();
  end;
end;

function TGame.IsOver(): boolean;
begin
  exit(IsLineFilled(0));
end;

procedure TGame.DeleteLine(y: integer);
var i, j: integer;
begin
  for i := y downto 1 do
  begin
    for j := 0 to (Config.Width - 1) do
    begin
      Board[j, i] := Board[j, i - 1];
    end;
  end;
end;

function TGame.IsLineFilled(y: integer): boolean;
var i: integer;
begin
  for i := 0 to (Config.Width - 1) do
  begin
    if not Board[i, y] then exit(false);
  end;

  exit(true);
end;

procedure TGame.DeletePossible;
var i: integer;
begin
  for i := 0 to (Config.Height - 1) do
  begin
    if IsLineFilled(i) then DeleteLine(i);
  end;
end;

function TGame.CanMove(x, y, pieceId, pieceRotation: integer): boolean;
var i, j: integer;
begin
  for i := 0 to 4 do
  begin
    for j := 0 to 4 do
    begin
      if ((x + i) < 0) or ((x + i) > (Config.Width - 1)) or ((y + j) > (Config.Height - 1)) then
      begin
        if CTetrisBlocks[pieceId, pieceRotation].Blocks[i, j] <> 0 then
        begin
          exit(false);
        end;
      end;

      if (y + j) >= 0 then
      begin
        if (CTetrisBlocks[pieceId, pieceRotation].Blocks[i, j] <> 0) and Board[x + i, y + j] then
        begin
          exit(false);
        end;
      end;
    end;
  end;

  exit(true);
end;

procedure TGame.MoveIfPossible(x, y, pieceId, pieceRotation: integer);
begin
  if CanMove(x, y, pieceId, pieceRotation) then
  begin
    CurrentX := x;
    CurrentY := y;
    CurrentPieceId := pieceId;
    CurrentPieceRotation := pieceRotation;
  end;
end;

procedure TGame.CreateNew();
begin
  CurrentPieceId := random(7);
  CurrentPieceRotation := random(4);
  CurrentX := (Config.Width div 2) + CTetrisBlocks[CurrentPieceId, CurrentPieceRotation].InitialOffset[0];
  CurrentY := CTetrisBlocks[CurrentPieceId, CurrentPieceRotation].InitialOffset[1];
end;

function TGame.Update(m: TMove; time: integer): boolean;
var loopTime: integer;
begin
  case m of
    Rotate: MoveIfPossible(CurrentX, CurrentY, CurrentPieceId, (CurrentPieceRotation + 1) mod 4);
    Left: MoveIfPossible(CurrentX - 1, CurrentY, CurrentPieceId, CurrentPieceRotation);
    Right: MoveIfPossible(CurrentX + 1, CurrentY, CurrentPieceId, CurrentPieceRotation);
    FastStart:
      Fast := true;
    FastEnd:
      Fast := false;
    Drop:
    begin
      while CanMove(CurrentX, CurrentY, CurrentPieceId, CurrentPieceRotation) do
      begin
        CurrentY := CurrentY + 1;
      end;

      FillBlock(CurrentX, CurrentY - 1, CurrentPieceId, CurrentPieceRotation);

      DeletePossible();

      if IsOver() then exit(true);

      CreateNew();
    end;
  end;

  if Fast then loopTime := Config.WaitingTime div 2 else loopTime := Config.WaitingTime;


  if (time - LastTime) > loopTime then
  begin
    LastTime := time;

    if CanMove(CurrentX, CurrentY + 1, CurrentPieceId, CurrentPieceRotation) then
    begin
      CurrentY := CurrentY + 1;
    end
    else
    begin
      FillBlock(CurrentX, CurrentY, CurrentPieceId, CurrentPieceRotation);
      DeletePossible();

      if IsOver() then exit(true);

      CreateNew();
    end;
  end;

  exit(false);
end;

end.
