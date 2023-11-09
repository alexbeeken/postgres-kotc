SELECT relname, n_tup_ins FROM pg_stat_user_tables WHERE schemaname = 'kotc';

SELECT deck, array_length(deck, 1) AS deck_count, player1_id, player2_id FROM kotc.games;
SELECT name, hand, array_length(hand, 1) AS hand_count FROM kotc.players;

SELECT n, s, e, w FROM kotc.games;

SELECT nw, ne, sw, se FROM kotc.games;
