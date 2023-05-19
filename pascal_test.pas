program test;
uses Crt, Unix; 

const WIDTH = 10; HEIGHT = 12;

type matrix = array[1..10, 1..12] of integer;

type tetramino = record
		piece_type, middle_x, middle_y : integer;
		block_positions : matrix; {	FIRST ROW IS ALWAYS THE MIDDLE BLOCK }
		end;

var ch: char;
x, y, timer: integer;
canPress : boolean;
positions : matrix;

procedure insert_block(var positions : matrix; x, y : integer);
begin
	positions[x, y] := 1;
	fpSystem('spd-say boop');
end;

procedure check_collision(var positions: matrix; var x, y: integer);
begin
	if positions[x, y + 2] = 1 then
	begin
		insert_block(positions, x, y + 1);
		y := 1;
		x := 5;
	end;	
end;

procedure player_fall(var x, y: integer; var positions : matrix);
begin
	if y + 2 >= HEIGHT then
	begin
		insert_block(positions, x, y + 2);
		y := 1;
		x := 5;
	end
	else
	begin
		y := y + 1;
	end;
end;

procedure move_player(positions: matrix; var x, y: integer; ch : char);
begin
	if (ch = 'a') and (x > 1) and (positions[x - 1, y] = 0) and (positions[x - 1, y +1] = 0) and (positions[x - 1, y + 2] = 0) then
		x := x - 1
	else if (ch = 'd') and (x < WIDTH) and (positions[x + 1, y] = 0) and (positions[x + 1, y + 1] = 0) and (positions[x + 1, y + 2] = 0) then
		x := x + 1;	
end;

procedure render_blocks(posits : matrix);
var i, j : integer;
begin

	for i:=0 to HEIGHT do
	begin
	for j:=0 to WIDTH do
	begin
		gotoxy(j, i);

		if posits[j, i] = 1 then
			write('#')
		else
			write('.');
	end;
	end;

	for i:=1 to WIDTH do
	begin
		gotoxy(i, HEIGHT); 
		write('T');
	end;	
end;	

procedure empty_matrix(var positions : matrix);
var i, j : integer;
begin
	for i:=0 to HEIGHT do
	begin
	for j:=0 to WIDTH do
	begin
		positions[j, i] := 0;
	end;
	end;
end;

function line_full(positions : matrix) : boolean;
var i : integer;
begin
	line_full := true;

	for i:=1 to WIDTH do
	begin
		if positions[i, 12] = 0 then
			line_full := false;
	end;

	if line_full = true then
	begin
		for i:=1 to WIDTH do
			positions[i, 12] := 0;

		render_blocks(positions);
		fpSystem('spd-say BOP');
		{fpSystem('notify-send "Line Complete"');}
		delay(400);
	end;
end;

procedure erase_line(var positions: matrix);
var i, j : integer;
begin
	if line_full(positions) then
	begin
		j:=HEIGHT;
		while j > 1 do
		begin
			i:=WIDTH;
			while i > 0 do
			begin
				positions[i, j] := positions[i, j - 1];
				i := i - 1;
			end;
			j := j - 1;
		end;
	end;
end;

{ MAIN FUNCTION }

begin
	x := 3;
	y := 4;
	timer := 0;

	empty_matrix(positions);

	canPress := true;

	ClrScr;
	fpSystem('tput civis');
	Window(1, 1, WIDTH, HEIGHT);
	TextBackground(WHITE);
	TextColor(BLACK);

	writeln('Welcome!');

	repeat
	until KeyPressed;

	ch := ' ';

	while ch <> #27 do
	begin	
		delay(10);
		canPress := true;
		
		if KeyPressed and (canPress = true) then
		begin
			canPress := false;
			ch := ReadKey;
			check_collision(positions, x, y);
			move_player(positions, x, y, ch);
		end;	
		
		if timer = 10 then
		begin
			player_fall(x, y, positions);
			check_collision(positions, x, y);
			timer := 0;
		end
		else
			timer := timer + 1;
			
		clrscr;
		erase_line(positions);
		render_blocks(positions);
		GotoXY(x, y);
		write('#');
		GotoXY(1, 12);
		write('By Isoo');
	end;

	TextBackground(BLACK);
	TextColor(WHITE);
	ClrScr;
	fpSystem('tput cnorm');
end.
