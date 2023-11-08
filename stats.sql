SELECT relname, n_tup_ins FROM pg_stat_user_tables WHERE schemaname = 'kotc';

SELECT deck, array_length(deck, 1) AS deck_count, player1_id, player2_id FROM kotc.games;
SELECT * FROM kotc.players;
