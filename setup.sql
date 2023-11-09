/*

Kings on the Corner in Postgres Setup

there is no concept of suit in kotc but just for display:
0 hearts
1 spades
2 diamonds
3 clubs

evens: red
odds: black

floor of (num / 4)

0: ace
1-10: ordinal
11: jack
12: queen
13: king

*/

--
-- SCHEMAS
--
CREATE SCHEMA kotc;

--
-- TABLES
--
CREATE TABLE kotc.games (
  id SERIAL PRIMARY KEY,
  deck INTEGER[52] DEFAULT array_shuffle(ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51, 52]),
  player1_id INT NOT NULL,
  player2_id INT NOT NULL,
  draw_idx INT,
  n INT,
  s INT,
  e INT,
  w INT,
  nw INT,
  ne INT,
  sw INT,
  se INT
);

CREATE TABLE kotc.players (
  id SERIAL PRIMARY KEY,
  hand integer[] DEFAULT '{}',
  name varchar(20)
);

--
-- FUNCTIONS
--
CREATE FUNCTION kotc.display_card_name(input INT)
RETURNS INT AS $$
DECLARE
  output VARCHAR(30);
  class INT;
BEGIN
  CASE input % 4 
      WHEN 0 THEN
        output := 'of hearts';
      WHEN 1 THEN
        output := 'of spades';
      WHEN 2 THEN
        output := 'of diamonds';
      WHEN 3 THEN
        output := 'of clubs';
  END CASE;

  CASE input / 4
      WHEN 0 THEN
        output := 'ace ' || output; 
      WHEN 1 THEN
        output := 'two ' || output;
      WHEN 2 THEN
        output := 'three ' || output;
      WHEN 3 THEN
        output := 'four ' || output;
      WHEN 4 THEN
        output := 'five ' || output;
      WHEN 5 THEN
        output := 'six ' || output;
      WHEN 6 THEN
        output := 'seven ' || output;
      WHEN 7 THEN
        output := 'eight ' || output;
      WHEN 8 THEN
        output := 'nine ' || output;
      WHEN 9 THEN
        output := 'ten ' || output;
      WHEN 10 THEN
        output := 'jack ' || output;
      WHEN 11 THEN
        output := 'queen ' || output;
      WHEN 12 THEN
        output := 'king ' || output;
  END CASE;

  RETURN output;
END;
$$  LANGUAGE plpgsql;


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

CREATE OR REPLACE FUNCTION kotc.place_king(new_game kotc.games, drawn_card INT)
RETURNS kotc.games AS $$
BEGIN
  IF new_game.nw IS NULL THEN
    new_game.nw = drawn_card;
  ELSIF new_game.ne IS NULL THEN
    new_game.ne = drawn_card;
  ELSIF new_game.sw IS NULL THEN
    new_game.sw = drawn_card;
  ELSIF new_game.se IS NULL THEN
    new_game.se = drawn_card;
  END IF;

  return new_game;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION kotc.init_draw_card(new_game kotc.games)
RETURNS kotc.games AS $$
DECLARE
  drawn_card INT;
BEGIN
  drawn_card := new_game.deck[new_game.draw_idx];

  LOOP
      EXIT WHEN drawn_card / 4 != 12;

      new_game := kotc.place_king(new_game, drawn_card);
      new_game.draw_idx := new_game.draw_idx + 1;
      drawn_card := new_game.deck[new_game.draw_idx];
  END LOOP;

  return new_game;
END;
$$ LANGUAGE plpgsql;

--
-- TRIGGER FUNCTIONS
--
CREATE OR REPLACE FUNCTION kotc.deal_cards()
RETURNS TRIGGER AS $$
DECLARE
  p1_id INT;
  p2_id INT;
  counter INT; 
  new_deck INTEGER[];
  hand1 INTEGER[]; 
  hand2 INTEGER[]; 
BEGIN
  p1_id = NEW.player1_id;
  p2_id = NEW.player2_id;

  NEW.draw_idx = 15;

  NEW = kotc.init_draw_card(NEW);
  NEW.n := NEW.deck[NEW.draw_idx];
  NEW.draw_idx = NEW.draw_idx + 1;

  NEW = kotc.init_draw_card(NEW);
  NEW.e := NEW.deck[NEW.draw_idx];
  NEW.draw_idx = NEW.draw_idx + 1;

  NEW = kotc.init_draw_card(NEW);
  NEW.w := NEW.deck[NEW.draw_idx];
  NEW.draw_idx = NEW.draw_idx + 1;

  NEW = kotc.init_draw_card(NEW);
  NEW.s := NEW.deck[NEW.draw_idx];
  NEW.draw_idx = NEW.draw_idx + 1;

  counter := 0;
  LOOP
      counter := counter + 1;

      EXIT WHEN counter > 7;

      NEW = kotc.init_draw_card(NEW);
      hand1 := hand1 || NEW.deck[NEW.draw_idx];
      NEW.draw_idx := NEW.draw_idx + 1;
  END LOOP; 

  counter := 0;
  LOOP
      counter := counter + 1;

      EXIT WHEN counter > 7;

      NEW = kotc.init_draw_card(NEW);
      hand2 := hand2 || NEW.deck[NEW.draw_idx];
      NEW.draw_idx := NEW.draw_idx + 1;
  END LOOP; 

  NEW.deck := NEW.deck[NEW.draw_idx:array_upper(NEW.deck, 1)];

  UPDATE kotc.players SET hand = hand1 WHERE id = p1_id;
  UPDATE kotc.players SET hand = hand2 WHERE id = p2_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER deal_cards_trigger 
BEFORE INSERT ON kotc.games
FOR EACH ROW EXECUTE FUNCTION kotc.deal_cards();
