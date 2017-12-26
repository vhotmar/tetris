program Tetris;
uses TetrisWindow, TetrisConfig, SysUtils;

{ Helper for debugging exceptions }
procedure DumpExceptionCallStack(E: Exception);
var
  I: Integer;
  Frames: PPointer;
  Report: string;
begin
  Report := 'Program exception! ' + LineEnding +
    'Stacktrace:' + LineEnding + LineEnding;
  if E <> nil then begin
    Report := Report + 'Exception class: ' + E.ClassName + LineEnding +
    'Message: ' + E.Message + LineEnding;
  end;
  Report := Report + BackTraceStrFunc(ExceptAddr);
  Frames := ExceptFrames;
  for I := 0 to ExceptFrameCount - 1 do
    Report := Report + LineEnding + BackTraceStrFunc(Frames[I]);
  writeln(Report);
  Halt;
end;

var
  win: TSDLWindow;
  con: TConfig;

begin
  { Initialize window and config }
  win := TSDLWindow.Create;
  con := TConfig.Create(25, 50, 500, 800, 200);

  win.Init(con);
  
  try
    { Run application }
    win.Run;
  except
    on E: Exception do 
      DumpExceptionCallStack(E);
  end;
end.
