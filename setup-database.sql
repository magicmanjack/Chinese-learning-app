CREATE TABLE test_table (
    row_num int,
    sentence varchar(255),
    PRIMARY KEY (row_num)
);

INSERT INTO test_table (row_num, sentence) VALUES (1, "hello world");
INSERT INTO test_table (row_num, sentence) VALUES (2, "I am Jack");