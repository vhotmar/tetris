program Tetris;

uses SDL2;

begin
	if SDL_Init(SDL_INIT_VIDEO) < 0 then Halt;

	writeln('nice');

	SDL_Quit;
end.
