program test;
uses Crt, Unix; 

const WIDTH = 10; HEIGHT = 12;

type matrix = array[1..10, 1..12] of integer;

type tetramino = record
		piece_type, middle_x, middle_y : integer;
		block_positions : matrix; {	FIRST ROW IS ALWAYS THE MIDDLE BLOCK }
		end;

var ch: char;
timer: integer;
canPress : boolean;
positions : matrix;
current_block : tetramino;

{	TETRAMINO CREATION	}

procedure create_i_block(var player : tetramino);
var i : integer;
begin
	player.block_positions[1, 1] := 5;
	player.block_positions[2, 1] := 4;
	player.block_positions[3, 1] := 6;
	player.block_positions[4, 1] := 7;
	for i:=1 to 4 do
		player.block_positions[i, 2] := 1;
end;

procedure create_t_block(var player : tetramino);
begin
	player.block_positions[1, 1] := 5;
	player.block_positions[1, 2] := 1;
	player.block_positions[2, 1] := 4;
	player.block_positions[2, 2] := 1;
	player.block_positions[3, 1] := 6;
	player.block_positions[3, 2] := 1;
	player.block_positions[4, 1] := 5;
	player.block_positions[4, 2] := 2;
end;

procedure create_l_block(var player : tetramino);
begin
	player.block_positions[1, 1] := 5;
	player.block_positions[1, 2] := 1;
	player.block_positions[2, 1] := 4;
	player.block_positions[2, 2] := 1;
	player.block_positions[3, 1] := 6;
	player.block_positions[3, 2] := 1;
	player.block_positions[4, 1] := 6;
	player.block_positions[4, 2] := 2;
end;

procedure create_j_block(var player : tetramino);
begin
	player.block_positions[1, 1] := 5;
	player.block_positions[1, 2] := 1;
	player.block_positions[2, 1] := 4;
	player.block_positions[2, 2] := 1;
	player.block_positions[3, 1] := 6;
	player.block_positions[3, 2] := 1;
	player.block_positions[4, 1] := 4;
	player.block_positions[4, 2] := 2;
end;

procedure create_o_block(var player : tetramino);
begin
	player.block_positions[1, 1] := 4;
	player.block_positions[1, 2] := 1;
	player.block_positions[2, 1] := 5;
	player.block_positions[2, 2] := 1;
	player.block_positions[3, 1] := 4;
	player.block_positions[3, 2] := 2;
	player.block_positions[4, 1] := 5;
	player.block_positions[4, 2] := 2;
end;

procedure create_s_block(var player : tetramino);
begin
	player.block_positions[1, 1] := 5;
	player.block_positions[1, 2] := 1;
	player.block_positions[2, 1] := 6;
	player.block_positions[2, 2] := 1;
	player.block_positions[3, 1] := 5;
	player.block_positions[3, 2] := 2;
	player.block_positions[4, 1] := 4;
	player.block_positions[4, 2] := 2;
end;

procedure create_z_block(var player : tetramino);
begin
	player.block_positions[1, 1] := 5;
	player.block_positions[1, 2] := 1;
	player.block_positions[2, 1] := 4;
	player.block_positions[2, 2] := 1;
	player.block_positions[3, 1] := 5;
	player.block_positions[3, 2] := 2;
	player.block_positions[4, 1] := 6;
	player.block_positions[4, 2] := 2;
end;

procedure spawn_tetramino(var player : tetramino; piece_type : integer);
begin
	case (piece_type) of
		0 : create_i_block(player);
		1 : create_j_block(player);
		2 : create_l_block(player);
		3 : create_o_block(player);
		4 : create_s_block(player);
		5 : create_t_block(player);
		6 : create_z_block(player);
	end;
end;

{	END OF TETRAMINO CREATION	}

procedure insert_block(var positions : matrix; player : tetramino; offset : integer);
var i : integer;
begin
	for i:=1 to 4 do
		positions[player.block_positions[i, 1], player.block_positions[i, 2] + offset] := 1;
	fpSystem('spd-say boop');
end;

procedure check_collision(var positions: matrix; var player : tetramino);
var x, y, i: integer;
begin
	for i:=1 to 4 do
	begin
		x := player.block_positions[i, 1];
		y := player.block_positions[i, 2];

		if positions[x, y + 2] = 1 then
		begin
			insert_block(positions, player, 1);
			spawn_tetramino(player, round(Random) mod 7);
		end;
	end;
end;

procedure player_fall(var player : tetramino; var positions : matrix);
var i : integer; found : boolean;
begin

	found := false;

	for i:=1 to 4 do
	begin
		if player.block_positions[i, 2] >= HEIGHT - 2 then
		begin
			insert_block(positions, player, 2);
			spawn_tetramino(player, round(Random) mod 7);
			found := true;
		end;
	end;

	if found = false then
		for i:=1 to 4 do
			player.block_positions[i, 2] := player.block_positions[i, 2] + 1;
end;

function check_wall_left(var player : tetramino; var positions) : boolean;
var i : integer;
begin
	check_wall_left := true;
	for i:=1 to 4 do
	begin
		if player.block_positions[i, 1] <= 1 then
			check_wall_left := false;
	end;
end;

function check_wall_right(var player : tetramino; var positions) : boolean;
var i : integer;
begin
	check_wall_right := true;
	for i:=1 to 4 do
	begin
		if player.block_positions[i, 1] >= WIDTH then
			check_wall_right := false;
	end;
end;

procedure move_player(positions: matrix; var blocks: matrix; ch : char; var player : tetramino);
var i, x, y : integer;
begin

	if (ch = 'a') and check_wall_left(player, positions) then
	begin
		for i:=1 to 4 do
		begin
			x := player.block_positions[i, 1];
			y := player.block_positions[i, 2];
			if (positions[x - 1, y] = 0) and (positions[x - 1, y +1] = 0) and (positions[x - 1, y + 2] = 0) then
				player.block_positions[i, 1] := x - 1;
		end;
	end
	else if (ch = 'd') and check_wall_right(player, positions) then
	begin
		for i:=1 to 4 do
		begin
			x := player.block_positions[i, 1];
			y := player.block_positions[i, 2];
			if (positions[x + 1, y] = 0) and (positions[x + 1, y + 1] = 0) and (positions[x + 1, y + 2] = 0) then
				player.block_positions[i, 1] := x + 1;
		end;
	end;
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

procedure render_player(player : tetramino);
var i : integer;
begin
	for i:=1 to 4 do
	begin
		GotoXY(player.block_positions[i,1], player.block_positions[i,2]);
		write('#');
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
	Randomize;

	spawn_tetramino(current_block, round(Random) mod 7);

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
			check_collision(positions, current_block);
			move_player(positions, current_block.block_positions, ch, current_block);
		end;	
		
		if timer = 20 then
		begin
			player_fall(current_block, positions);
			check_collision(positions, current_block);
			timer := 0;
		end
		else
			timer := timer + 1;
			
		clrscr;
		erase_line(positions);
		render_blocks(positions);
		render_player(current_block);
		GotoXY(1, 12);
		write('By Isoo');
	end;

	TextBackground(BLACK);
	TextColor(WHITE);
	ClrScr;
	fpSystem('tput cnorm');
end.
