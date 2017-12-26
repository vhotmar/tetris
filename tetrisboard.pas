unit TetrisBoard;
interface

type TIntShape = array [0..4, 0..4] of integer;
type TIntBoard = array of array of integer;

type
  TBoard = class
  private
    FBoard: TIntBoard;
    FWidth, FHeight: integer;
  public
    constructor Create(width, height: integer);

    { Is game over? (is there some block in first row?) }
    function IsOver(): boolean;

    { Are these coordinates on board? (they shouldn't be negative and within range) }
    function IsOnBoard(x, y: integer): boolean; overload;

    { Are these coordinates on board? (they shouldn't be negative and within range), but we ignore blocks on top }
    function IsOnBoard(x, y: integer; checkTop: boolean): boolean; overload;

    { Is line of "y" filled fully with blocks? }
    function IsLineFilled(y: integer): boolean;

    { Check if we can fit matrix where non-negative values are blocks on x, y coordinates on board }
    function CanPlaceShape(x, y: integer; shape: TIntShape): boolean;

    { Get value from board on x, y coordinates }
    function GetValue(x, y: integer): integer;

    { Is empty on x, y coordinates. There is flag to check if it has to be on board }
    function IsEmpty(x, y: integer; hasToBeOnBoard: boolean): boolean;

    { Clear the board with 0s }
    procedure Clear;

    { Fill the borad with "value" }
    procedure FillBoard(value: integer);

    { Fill line with "value" }
    procedure FillLine(y, value: integer);

    { Fill shape represented by matrix (where non negative numbers represents blocks) by "value" on x, y }
    procedure FillShape(x, y, value: integer; shape: TIntShape);

    { Delete line and move all lines above down }
    procedure DeleteLine(y: integer);

    { Go through all lines and delete all possible lines }
    procedure DeletePossibleLines();

    { Print this board to console }
    procedure Print();
  end;

implementation

constructor TBoard.Create(width, height: integer);
begin
  FWidth := width;
  FHeight := height;

  { Dynamic multi-dimensional array }
  SetLength(FBoard, width, height);

  { Start with empty board }
  FillBoard(0);
end;

function TBoard.IsOver(): boolean;
var i: integer;
begin
  for i := 0 to (FWidth - 1) do
    if FBoard[i, 0] <> 0 then exit(true);

  IsOver := false;
end;

function TBoard.IsOnBoard(x, y: integer; checkTop: boolean): boolean;
var tmp: boolean;
begin
  tmp := (x >= 0) and (x < FWidth) and (y < FHeight);

  if checkTop then
    IsOnBoard := (tmp and (y >= 0))
  else
    IsOnBoard := tmp;
end;

function TBoard.IsOnBoard(x, y: integer): boolean;
begin
  IsOnBoard := IsOnBoard(x, y, true);
end;

function TBoard.CanPlaceShape(x, y: integer; shape: TIntShape): boolean;
var i, j, toI, toJ: integer;
begin
  toI := Length(shape) - 1;
  toJ := Length(shape[0]) - 1;

  for i := 0 to toI do
  begin
    for j := 0 to toJ do
    begin
      { If it is out of bounds and there is some block we can not place it }
      if (not IsOnBoard(x + i, y + j, false)) and (shape[i, j] <> 0) then
        exit(false);
      
      { If is shape on board and it collides with another block we can not place it }
      if ((y + j) >= 0) and (shape[i, j] <> 0) and (not IsEmpty(x + i, y + j, false)) then
        exit(false);
    end;
  end;

  CanPlaceShape := true;
end;

function TBoard.GetValue(x, y: integer): integer;
begin
  GetValue := FBoard[x, y];
end;

procedure TBoard.Clear();
begin
  FillBoard(0);
end;

procedure TBoard.FillBoard(value: integer);
var i, j: integer;
begin
  for i := 0 to (FWidth - 1) do
    for j := 0 to (FHeight - 1) do
      FBoard[i, j] := value;
end;

procedure TBoard.FillLine(y, value: integer);
var i: integer;
begin
  for i := 0 to (FWidth - 1) do
    FBoard[i, y] := value;
end;

procedure TBoard.FillShape(x, y, value: integer; shape: TIntShape);
var i, j, toI, toJ: integer;
begin
  toI := Length(shape) - 1;
  toJ := Length(shape[0]) - 1;

  for i := 0 to toI do
    for j := 0 to toJ do
      if IsOnBoard(x + i, y + j) and (shape[i, j] <> 0) then
        FBoard[x + i, y + j] := value;
end;

function TBoard.IsEmpty(x, y: integer; hasToBeOnBoard: boolean): boolean;
begin
  if IsOnBoard(x, y) then
    IsEmpty := (FBoard[x, y] = 0)
  else
    IsEmpty := not hasToBeOnBoard;
end;

procedure TBoard.DeleteLine(y: integer);
var i, j: integer;
begin
  { Move lines up }
  for i := y downto 1 do
    for j := 0 to (FWidth - 1) do
      FBoard[j, i] := FBoard[j, i - 1];
end;

procedure TBoard.DeletePossibleLines();
var i: integer;
begin
  for i := 0 to (FHeight - 1) do
    if IsLineFilled(i) then DeleteLine(i);
end;

procedure TBoard.Print();
var i, j: integer;
begin
  for i := 0 to (FHeight - 1) do
  begin
    for j := 0 to (FWidth - 1) do
      if FBoard[j, i] <> 0 then write('1') else write('0');

    writeln();
  end;
end;

function TBoard.IsLineFilled(y: integer): boolean;
var i: integer;
begin
  for i := 0 to (FWidth - 1) do
    if FBoard[i, y] = 0 then exit(false);

  exit(true);
end;

end.
