-- Create the imdb database
DROP DATABASE IF EXISTS imdb;
CREATE DATABASE IF NOT EXISTS imdb;
USE imdb;

-- Create tables
CREATE TABLE film (
    film_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255),
    description TEXT,
    release_year INT
);

CREATE TABLE actor (
    actor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50)
);

CREATE TABLE film_actor (
    actor_id INT,
    film_id INT,
    PRIMARY KEY (actor_id, film_id)
);

-- --------------------------------------------------------------------------------- --

-- Alter table to add last_update column to film
ALTER TABLE film
ADD COLUMN last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Alter table to add last_update column to actor
ALTER TABLE actor
ADD COLUMN last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Add foreign keys to film_actor table
ALTER TABLE film_actor
ADD CONSTRAINT fk_actor
FOREIGN KEY (actor_id) REFERENCES actor(actor_id),
ADD CONSTRAINT fk_film
FOREIGN KEY (film_id) REFERENCES film(film_id);

-- Insert data into the actor table
INSERT INTO actor (first_name, last_name) VALUES
('Tom', 'Hanks'),
('Leonardo', 'DiCaprio'),
('Scarlett', 'Johansson'),
('Brad', 'Pitt');

-- Insert data into the film table
INSERT INTO film (title, description, release_year) VALUES
('Forrest Gump', 'A man with a low IQ has accomplished great things in his life and been present during significant historic events - in each case, far exceeding what anyone imagined he could do.', 1994),
('Inception', 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.', 2010),
('Lost in Translation', 'A faded movie star and a neglected young woman form an unlikely bond after crossing paths in Tokyo.', 2003);

-- Insert data into the film_actor table
INSERT INTO film_actor (actor_id, film_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 1),
(4, 2);

