DO $$
DECLARE
    player1_id INT;
    player2_id INT;
    game_id INT;
BEGIN
    player1_id := create_player('Alex');
    player2_id := create_player('Maddy');
    game_id := create_game(player1_id, player2_id);

    -- whose turn is it?
    -- what functions should they use to decide what to do on their turn?
END;
$$ LANGUAGE plpgsql;
