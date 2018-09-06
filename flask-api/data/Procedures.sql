---- Create User
DELIMITER //

Drop Procedure spCreateUser;

USE CoProManager;

CREATE PROCEDURE spCreateUser (IN p_username varchar(64),IN password varchar(255), IN fname varchar(32), IN lname varchar(32),IN email varchar(64), IN usertype INT)
BEGIN
IF(SELECT exists (SELECT 1 from Users where p_username = username)) THEN
    SELECT 'User already exists';
ELSE
INSERT into Users
(
    username,
    password,
    fname,
    lname,
    email,
    usertype
)
VALUES
(
    p_username,
    password,
    fname,
    lname,
    email,
    usertype
);
END IF;

END //

---- Authentication

DELIMITER //

Drop Procedure spAuthentication;

CREATE Procedure spAuthentication (IN p_username varchar(64),IN p_password varchar(255))
BEGIN
    SELECT * from Users where p_username = username and p_password = password;
END //

DELIMITER //
