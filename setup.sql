--
-- SCHEMAS
--
CREATE SCHEMA kotc;
--
-- TABLES
--
CREATE TABLE kotc.games (
  id SERIAL PRIMARY KEY,
  deck INTEGER[52] DEFAULT array_shuffle(ARRAY[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51]),
  player1_id INT NOT NULL,
  player2_id INT NOT NULL
);

CREATE TABLE kotc.players (
  id SERIAL PRIMARY KEY,
  hand integer[] DEFAULT '{}',
  name varchar(20)
);

--
-- FUNCTIONS
--
CREATE FUNCTION kotc.create_player(input_name VARCHAR(20))
RETURNS INT AS $$
DECLARE
  player_id INT;
BEGIN
  INSERT INTO kotc.players (name) VALUES (input_name)
  RETURNING id INTO player_id;

  return player_id;
END;
$$  LANGUAGE plpgsql;

CREATE FUNCTION kotc.create_game(input_player1_id INT, input_player2_id INT)
RETURNS INT AS $$
DECLARE
  game_id INT;
BEGIN
  INSERT INTO kotc.games (player1_id, player2_id) VALUES (input_player1_id, input_player2_id)
  RETURNING id INTO game_id;

  return game_id;
END;
$$  LANGUAGE plpgsql;

--
-- TRIGGER FUNCTIONS
--
CREATE OR REPLACE FUNCTION kotc.deal_cards()
RETURNS TRIGGER AS $$
DECLARE
  p1_id INT;
  p2_id INT;
  new_deck INTEGER[];
  existing_deck INTEGER[]; 
  hand1 INTEGER[]; 
  hand2 INTEGER[]; 
BEGIN
  p1_id = NEW.player1_id;
  p2_id = NEW.player2_id;
  existing_deck = NEW.deck;

  new_deck := existing_deck[15:array_upper(existing_deck, 1)];
  NEW.deck := new_deck;

  hand1 := existing_deck[1:7];
  hand2 := existing_deck[8:14];

  UPDATE kotc.players SET hand = hand1 WHERE id = p1_id;
  UPDATE kotc.players SET hand = hand2 WHERE id = p2_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER deal_cards_trigger 
BEFORE INSERT ON kotc.games
FOR EACH ROW EXECUTE FUNCTION kotc.deal_cards();
