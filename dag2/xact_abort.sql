USE tempdb;
GO

DROP TABLE IF EXISTS NatuurlijkeGetallen
GO

CREATE TABLE NatuurlijkeGetallen
(
	kolom1 int PRIMARY KEY
);
GO

INSERT INTO NatuurlijkeGetallen
VALUES
(1),
(2),
(3),
(4),
(5);
GO

INSERT INTO NatuurlijkeGetallen VALUES (1);
INSERT INTO NatuurlijkeGetallen VALUES (99);

SELECT * FROM NatuurlijkeGetallen

BEGIN TRANSACTION
	INSERT INTO NatuurlijkeGetallen VALUES (1);
	INSERT INTO NatuurlijkeGetallen VALUES (100);
COMMIT TRANSACTION

-------------------------------------------------------------

SET XACT_ABORT ON;

BEGIN TRANSACTION
	INSERT INTO NatuurlijkeGetallen VALUES (1);
	INSERT INTO NatuurlijkeGetallen VALUES (101);
COMMIT TRANSACTION
