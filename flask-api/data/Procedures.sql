USE CoProManager;

-- Create User
DELIMITER //

Drop Procedure If Exists spCreateUser;

CREATE PROCEDURE spCreateUser (IN p_username varchar(64),IN password varchar(255), IN fname varchar(32), IN lname varchar(32),IN p_email varchar(64), IN usertype INT)
BEGIN
IF(SELECT exists (SELECT * from Users where p_username = username)) THEN
    SELECT 'User already exists';
ELSEIF(SELECT exists (SELECT * from Users where p_email = email)) THEN
    SELECT 'Email already exists';
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
        p_email,
        usertype
    );
END IF;

END //

---- Authentication

DELIMITER //

Drop Procedure If Exists spAuthentication;

CREATE Procedure spAuthentication (IN p_username varchar(64))
BEGIN
    SELECT * from Users where p_username = username;
END //

-- Edit user information

DELIMITER //

Drop Procedure If Exists spEditUser;

CREATE Procedure spEditUser (IN p_curr_username varchar(64), IN p_new_username varchar(64), IN p_fname varchar(32), IN p_lname varchar(32), IN p_email varchar(64), IN p_country INT)
BEGIN
IF(SELECT exists (SELECT username from Users where p_new_username = username) AND p_curr_username != p_new_username) THEN
    SELECT CONCAT(p_new_username, ' already registered');
ELSEIF(p_curr_username != (SELECT username from Users where p_email = email)) THEN
    SELECT CONCAT(p_email, ' already registered');
ELSE
    UPDATE Users
    SET username = p_new_username,
        fname = p_fname,
        lname = p_lname,
        email = p_email,
        country = p_country
    WHERE p_curr_username = username;
END IF;

END //

-- Edit user online judges usernames

DELIMITER //

Drop Procedure If Exists spEditJudgesUsernames;

CREATE Procedure spEditJudgesUsernames (IN p_username varchar(64), IN p_username_uva varchar(64), IN p_username_icpc varchar(64))
BEGIN
IF(p_username != (SELECT username from Users where p_username_uva = iduva)) THEN
    SELECT CONCAT(p_username_uva, ' already registered (UVA)');
ELSEIF(p_username != (SELECT username from Users where p_username_icpc = idicpc)) THEN
    SELECT CONCAT(p_username_icpc, ' already registered (ICPC Live Archive)');
ELSE
    UPDATE Users
    SET iduva = p_username_uva,
        idicpc = p_username_icpc
    WHERE p_username = username;
END IF;

END //

-- Edit password

DELIMITER //

Drop Procedure If Exists spEditPassword;

CREATE PROCEDURE spEditPassword (IN p_username varchar(64), IN p_new_password varchar(255))
BEGIN
UPDATE Users
SET password = p_new_password
WHERE username = p_username;

END //

-- Get Countries

DELIMITER //

Drop Procedure If Exists spGetCountries;

CREATE Procedure spGetCountries ()
BEGIN
    SELECT country_name from Countries;
END //

-- Get owned Contests

DELIMITER //

Drop Procedure If Exists spGetOwnedContests;

CREATE Procedure spGetOwnedContests (IN p_ownerusername varchar(64))
BEGIN
    SELECT contestID, contestName, description, startDate, endDate, status from Contest where (SELECT userID FROM Users WHERE username = p_ownerusername) = ownerID;
END //

---- Get invited Contests

DELIMITER //

Drop Procedure If Exists spGetInvitedContests;

CREATE Procedure spGetInvitedContests (IN p_username varchar(64))
BEGIN
    SELECT contestID, contestName, description, startDate, endDate, status from Contest where contestID in (SELECT contestID from Contestuser where userID = (SELECT userID FROM Users WHERE username = p_username));
END //

-- Get Contest Problems information

DELIMITER //

Drop Procedure If Exists spGetContestProblems;

CREATE PROCEDURE spGetContestProblems (IN p_contestID INT)
BEGIN
	SELECT P.* FROM ContestProblem CP, Problems P WHERE CP.problemID = P.problemID AND CP.contestID = p_contestID;
END //

-- Get User's Submissions in Contest

DELIMITER //

Drop Procedure If Exists spGetUserSubmissionsInContest;

CREATE PROCEDURE spGetUserSubmissionsInContest (IN p_userID INT, IN p_contestID INT)
BEGIN
	SELECT U.username, P.problemName, P.judge, P.url, S.result, S.language, S.submissionTime
	FROM Submission S, Problems P, Users U
	WHERE S.contestID = p_contestID AND S.submitter = p_userID AND S.submitter = U.userID AND S.problemID = P.problemID
	ORDER BY S.submissionTime DESC;
	
END //

-- Get All Submissions in Contest

DELIMITER //

Drop Procedure If Exists spGetSubmissionsInContest;

CREATE PROCEDURE spGetSubmissionsInContest (IN p_contestID INT)
BEGIN
	SELECT U.username, P.problemName, P.judge, P.url, S.result, S.language, S.submissionTime
	FROM Submission S, Problems P, Users U
	WHERE S.contestID = p_contestID AND S.submitter = U.userID AND S.problemID = P.problemID
	ORDER BY S.submissionTime DESC;

END //

-- Get Contest Standings

DELIMITER //

Drop Procedure If Exists spGetContestStandings;

CREATE PROCEDURE spGetContestStandings (IN p_contestID INT)
BEGIN
	SELECT CU.userID, CU.standing, U.username, C.country_name, CU.score
	FROM ContestUser CU, Users U
  LEFT OUTER JOIN Countries C ON U.country = C.id
	WHERE CU.contestID = p_contestID AND CU.userID = U.userID
	ORDER BY CU.standing;
	
END //

-- Get Contest Owner

DELIMITER //

Drop Procedure If Exists spGetContestOwner;

CREATE PROCEDURE spGetContestOwner (IN p_contestID INT)
BEGIN
	SELECT U.username
	FROM Contest C, Users U
	WHERE C.contestID = p_contestID AND C.ownerID = U.userID;

END //

-- Get User ID

DELIMITER //

Drop Procedure If Exists spGetUserID;

CREATE procedure spGetUserID (IN p_username varchar(64))
BEGIN
	SELECT userID FROM users WHERE username = p_username;
END //


-- Create Contest
DELIMITER //

Drop Procedure If Exists spCreateContest;

CREATE PROCEDURE spCreateContest (IN contestName varchar(255), IN description varchar(255), IN startDate DATETIME, IN endDate DATETIME, IN status INT, in p_username varchar(64))
BEGIN
    INSERT into contest
    (
        contestName,
        description,
        startDate,
        endDate,
        status,
        ownerID
    )
    VALUES
    (
        contestName,
        description,
        startDate,
        endDate,
        status,
        (SELECT userID FROM Users WHERE username = p_username)
    );
END //

-- Get Contest Information

DELIMITER //

Drop Procedure If Exists spGetContestInformation;

CREATE PROCEDURE spGetContestInformation (IN p_contestID INT)
BEGIN
	SELECT *
  FROM Contest
  WHERE contestID = p_contestID;

END //

-- Get Contest User's Username

DELIMITER //

Drop Procedure If Exists spGetContestUserUsername;

CREATE PROCEDURE spGetContestUserUsername (IN p_userID INT, IN p_contestID INT)
BEGIN
	SELECT U.username
  FROM ContestUser CU, Users U
  WHERE CU.contestID = p_contestID AND CU.userID = p_userID AND CU.userID = U.userID;

END //

-- Get Contest Scores Per Problem

DELIMITER //

Drop Procedure If Exists spGetContestScoresPerProblem;

CREATE PROCEDURE spGetContestScoresPerProblem (IN p_problemID INT, IN p_contestID INT)
BEGIN
  SELECT SU.username, SU.result, SU.submissionCount, (TIMESTAMPDIFF(SECOND, C.startDate, SU.submissionTime) + SU.penalty) as TimeDifference
  FROM (
      SELECT C.contestID, C.startDate
      FROM Contest C
      WHERE C.contestID = p_contestID
  ) C, (
      SELECT U.userID, S.contestID, U.username, COUNT(S.submissionID) AS submissionCount, MAX(S.result) AS result, MAX(S.submissionTime) AS submissionTime, P.penalty
      FROM (
          SELECT CU.userID, U.username
          FROM ContestUser CU, Users U
          WHERE CU.contestID = p_contestID AND CU.userID = U.userID
      ) U, (
          SELECT S.contestID, S.submissionID, S.result, S.submissionTime, S.submitter
          FROM submission S
          WHERE S.contestID = p_contestID AND S.problemID = p_problemID
      ) S, (
          SELECT submitter, COUNT(submissionID) * 1200 AS penalty
          FROM submission
          WHERE contestID = 3 AND problemID = 3 AND result < 90
          GROUP BY submitter
      ) P
      WHERE U.userID = S.submitter AND S.submitter = P.submitter
      GROUP BY U.userID
  ) SU
  WHERE SU.contestID = C.contestID
  ORDER BY SU.userID, TimeDifference DESC;
END //

-- Edit contest information

DELIMITER //

Drop Procedure If Exists spEditContest;

CREATE Procedure spEditContest (IN p_contestID INT, IN p_new_contestName varchar(255), IN p_new_description varchar(255), IN p_new_startDate DATETIME, IN p_new_endDate DATETIME, IN p_new_status INT)
BEGIN
    UPDATE contest
    SET contestName = p_new_contestName,
        description = p_new_description,
        startDate = p_new_startDate,
        endDate = p_new_endDate,
        status = p_new_status
    WHERE p_contestID = contestID;
END //

-- Get Ongoing Contest Info

DELIMITER //

CREATE PROCEDURE spGetOngoingContestInfo()
BEGIN
	SELECT contestID, startDate, endDate
	FROM Contest
	WHERE status = 1;
END //

-- Get Ongoing Contest Users Info

DELIMITER //

Drop Procedure If Exists spGetOngoingContestUsersInfo;

CREATE PROCEDURE spGetOngoingContestUsersInfo (IN p_contestID INT)
BEGIN
	SELECT CU.userID, U.username, U.iduva, U.idicpc, C.country_name
	FROM ContestUser CU, Users U
	LEFT OUTER JOIN Countries C ON U.country = C.id
	WHERE CU.contestID = p_contestID AND CU.userID = U.userID
	ORDER BY CU.userID;

END //

-- Contest Update Upcoming to Ongoing

DELIMITER //

Drop Procedure If Exists spUpdateContestUpcomingToOngoing;

CREATE PROCEDURE spUpdateContestUpcomingToOngoing()
BEGIN
	UPDATE Contest
	SET status = 1
	WHERE status = 0 AND startDate < CURRENT_TIMESTAMP AND endDate > CURRENT_TIMESTAMP;

END //

-- Get Almost Finished Contest Info

DELIMITER //

CREATE PROCEDURE spGetAlmostFinishedContestInfo()
BEGIN
	SELECT contestID, startDate, endDate, CURRENT_TIMESTAMP AS currentDate
	FROM Contest
	WHERE status = 1 AND endDate <= CURRENT_TIMESTAMP;
END //

-- Contest Update Ongoing to Finished

DELIMITER //

Drop Procedure If Exists spUpdateContestOngoingToFinished;

CREATE PROCEDURE spUpdateContestOngoingToFinished(IN p_updateDate DATETIME)
BEGIN
	UPDATE Contest
	SET status = 2
	WHERE status = 1 AND endDate <= p_updateDate;

END //

-- Insert Finished Contest Submission

DELIMITER //

DROP PROCEDURE IF EXISTS spInsertSubmission;

CREATE PROCEDURE spInsertSubmission(IN p_subDate DATETIME, IN p_result INT, IN p_language VARCHAR(64), IN p_problemID INT, IN p_submitter INT, IN p_contestID INT)
BEGIN
  INSERT INTO Submission VALUES
	(NULL, p_subDate, p_result, p_language, 0, p_problemID, p_submitter, p_contestID);
END //

-- Update Contest User Info

DELIMITER //

DROP PROCEDURE IF EXISTS spUpdateContestUser;

CREATE PROCEDURE spUpdateContestUser(IN p_score INT, IN p_standing INT, IN p_contestID INT, IN p_userID INT)
BEGIN
  UPDATE ContestUser
  SET score = p_score, standing = p_standing
  WHERE contestID = p_contestID AND userID = p_userID;

END //