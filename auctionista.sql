SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS account;
CREATE TABLE account (
    id int NOT NULL AUTO_INCREMENT KEY,
    email varchar(50) NOT NULL,
    password varchar(50) NOT NULL
);

DROP TABLE IF EXISTS auction_object;
CREATE TABLE auction_object (
    id int NOT NULL AUTO_INCREMENT KEY,
    owner int NOT NULL,
    title varchar(50) NOT NULL,
    description varchar(1000),
    date_start datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_end datetime NOT NULL,

    FOREIGN KEY (owner) REFERENCES account(id)
);

DROP TABLE IF EXISTS bid;
CREATE TABLE bid (
    id int NOT NULL AUTO_INCREMENT KEY,
    bidder int NOT NULL,
    auction_object int NOT NULL,
    amount int NOT NULL,
    date datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,


    FOREIGN KEY (bidder) REFERENCES account(id),
    FOREIGN KEY (auction_object) REFERENCES auction_object(id)
);

SET FOREIGN_KEY_CHECKS=1;

