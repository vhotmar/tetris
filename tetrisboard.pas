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

    function IsOver(): boolean;
    function IsOnBoard(x, y: integer): boolean; overload;
    function IsOnBoard(x, y: integer; checkTop: boolean): boolean; overload;
    function IsLineFilled(y: integer): boolean;
    function CanPlaceShape(x, y: integer; shape: TIntShape): boolean;
    function GetValue(x, y: integer): integer;
    function IsEmpty(x, y: integer; hasToBeOnBoard: boolean): boolean;

    procedure Clear;
    procedure FillBoard(value: integer);
    procedure FillShape(x, y, value: integer; shape: TIntShape);
    procedure DeleteLine(y: integer);
    procedure DeletePossibleLines();

    procedure Print();
  end;

implementation

constructor TBoard.Create(width, height: integer);
begin
  FWidth := width;
  FHeight := height;

  SetLength(FBoard, width, height);

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
      if (not IsOnBoard(x + i, y + j, false)) and (shape[i, j] <> 0) then
        exit(false);
      
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
