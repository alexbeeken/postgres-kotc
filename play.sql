DO $$
DECLARE
    player1_id INT;
    player2_id INT;
    game_id INT;
BEGIN
    player1_id := create_player('Alex');
    player2_id := create_player('Maddy');
    game_id := create_game(player1_id, player2_id);

    -- Optionally, you can add more operations here using game_id
END;
$$ LANGUAGE plpgsql;
