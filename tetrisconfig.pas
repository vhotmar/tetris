unit TetrisConfig;
interface

type
  TConfig = class
  public
    Width, Height, WaitingTime, WindowWidth, WindowHeight: integer;

    constructor Create(w, h, ww, wh, wt: integer);
  end;

implementation

constructor TConfig.Create(w, h, ww, wh, wt: integer);
begin
  Width := w;
  Height := h;
  WaitingTime := wt;
  WindowWidth := ww;
  WindowHeight := wh;
end;

end.
