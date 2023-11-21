--Renaming column error after importing csv file

USE [Project 1]
GO
EXEC sp_rename 'dbo.UBS.CS Total Assets', 'UBS Total Assets', 'COLUMN'
GO

USE [Project 1]
GO
EXEC sp_rename 'dbo.BRK.BRK#B Total Assets', 'BRK Total Assets', 'COLUMN'
GO

--Was testing to see if Distinct made a difference to sorting

SELECT DISTINCT *
FROM dbo.TotalAssets
ORDER BY date asc

SELECT *
FROM dbo.TotalAssets
ORDER BY date asc

--Creating new table that we will use to join all the separate csv files together

CREATE TABLE dbo.TotalAssets (
	"Date" date,
	"BAC Total Assets" int,
	"BK Total Assets" int,
	"BLK Total Assets" int,
	"BRK Total Assets" int,
	"COF Total Assets" int,
	"CS Total Assets" int,
	"GS Total Assets" int,
	"JPM Total Assets" int,
	"MET Total Assets" int,
	"MS Total Assets" int,
	"NTR Total Assets" int,
	"STT Total Assets" int,
	"UBS Total Assets" int,
	"fed Total Assets" int,
	"SP500 Price" int
	);



--Joining all csv files together by date

INSERT INTO dbo.TotalAssets
SELECT BAC.Date, BAC.[BAC Total Assets], BK.[BK Total Assets], BLK.[BLK Total Assets],
				 BRK.[BRK Total Assets], COF.[COF Total Assets], CS.[CS Total Assets],
				 GS.[GS Total Assets], JPM.[JPM Total Assets], MET.[MET Total Assets],
				 MS.[MS Total Assets], NTR.[NTRS Total Assets], STT.[STT Total Assets],
				 UBS.[UBS Total Assets], fed.[Fed Total Assets], SP500.[S&P 500 Price] 
FROM dbo.BAC bac join dbo.BK bk on bac.date = bk.date
				 join dbo.BLK blk on bk.date = blk.date
				 join dbo.BRK brk on blk.date = brk.date
				 join dbo.COF cof on brk.date = cof.date
				 join dbo.CS cs on cof.date = cs.date
				 join dbo.GS gs on cs.date = gs.date
				 join dbo.JPM jpm on gs.date = jpm.date
				 join dbo.MET met on jpm.date = met.date
				 join dbo.MS ms on met.date = ms.date
				 join dbo.NTR ntr on ms.date = ntr.date
				 join dbo.STT stt on ntr.date = stt.date
				 join dbo.UBS ubs on stt.date = ubs.date
				 join dbo.fedAssetsTotal fed on ubs.date = fed.date
				 join dbo.SP500 sp500 on fed.date = sp500.date
ORDER BY date asc


--Adding additional columns that we will use for YoY Change % Calculations with correct input types

SELECT *
FROM dbo.TotalAssets
ORDER BY date asc

ALTER TABLE dbo.TotalAssets
ADD "Companies Total Assets" int

ALTER TABLE dbo.TotalAssets
ADD "Companies + Fed Total Assets" int

ALTER TABLE dbo.TotalAssets
ADD "Companies Total Assets YoY Change %" decimal(3,2)

ALTER TABLE dbo.TotalAssets
ADD "Fed Total Assets YoY Change %" decimal(3,2)

ALTER TABLE dbo.TotalAssets
ADD "Total Assets + Fed Total Assets YoY Change %" decimal(3,2)

SELECT 
	[BAC Total Assets], [BK Total Assets], [BLK Total Assets],
	[BRK Total Assets], [COF Total Assets], [CS Total Assets],
	[GS Total Assets], [JPM Total Assets], [MET Total Assets],
	[MS Total Assets], [NTR Total Assets], [STT Total Assets],
	[UBS Total Assets],
	[BAC Total Assets] + [BK Total Assets] + [BLK Total Assets] +
	[BRK Total Assets] + [COF Total Assets] + [CS Total Assets] +
	[GS Total Assets] + [JPM Total Assets] + [MET Total Assets] +
	[MS Total Assets] + [NTR Total Assets] + [STT Total Assets] + 
	[UBS Total Assets] as "TOTAL"
FROM dbo.TotalAssets



--Changing columns to correct input types


ALTER TABLE TotalAssets
ALTER COLUMN [BAC Total Assets] int

ALTER TABLE TotalAssets
ALTER COLUMN [BK Total Assets] int

ALTER TABLE TotalAssets
ALTER COLUMN [BLK Total Assets] int

ALTER TABLE TotalAssets
ALTER COLUMN [BRK Total Assets] int

ALTER TABLE TotalAssets
ALTER COLUMN [COF Total Assets] int

ALTER TABLE TotalAssets
ALTER COLUMN [CS Total Assets] int

ALTER TABLE TotalAssets
ALTER COLUMN [GS Total Assets] int

ALTER TABLE TotalAssets
ALTER COLUMN [JPM Total Assets] int

ALTER TABLE TotalAssets
ALTER COLUMN [MET Total Assets] int

ALTER TABLE TotalAssets
ALTER COLUMN [MS Total Assets] int

ALTER TABLE TotalAssets
ALTER COLUMN [NTR Total Assets] int

ALTER TABLE TotalAssets
ALTER COLUMN [STT Total Assets] int

ALTER TABLE TotalAssets
ALTER COLUMN [UBS Total Assets] int

ALTER TABLE TotalAssets
ALTER COLUMN [fed Total Assets] int

ALTER TABLE TotalAssets
ALTER COLUMN [SP500 Price] int

ALTER TABLE TotalAssets
ALTER COLUMN [Date] date

--Updating TotalAssets table with additional columns

UPDATE TotalAssets
SET [Companies Total Assets] = [BAC Total Assets] + [BK Total Assets] + [BLK Total Assets] +
	[BRK Total Assets] + [COF Total Assets] + [CS Total Assets] +
	[GS Total Assets] + [JPM Total Assets] + [MET Total Assets] +
	[MS Total Assets] + [NTR Total Assets] + [STT Total Assets] + 
	[UBS Total Assets]

SELECT *
FROM dbo.TotalAssets
ORDER BY date asc

UPDATE TotalAssets
SET [Companies + Fed Total Assets] = [BAC Total Assets] + [BK Total Assets] + [BLK Total Assets] +
	[BRK Total Assets] + [COF Total Assets] + [CS Total Assets] +
	[GS Total Assets] + [JPM Total Assets] + [MET Total Assets] +
	[MS Total Assets] + [NTR Total Assets] + [STT Total Assets] + 
	[UBS Total Assets] + [fed Total Assets]

--Changing columns to float due to getting 0 values from int

ALTER TABLE TotalAssets
ALTER COLUMN [Companies Total Assets] float

ALTER TABLE TotalAssets
ALTER COLUMN [Companies + Fed Total Assets] float

ALTER TABLE TotalAssets
ALTER COLUMN [fed Total Assets] float

ALTER TABLE TotalAssets
ALTER COLUMN [SP500 Price] float


--Calculating YoY Change % using LAG OVER

UPDATE TotalAssets
SET [Companies Total Assets YoY Change %] = ([Companies Total Assets]-(LAG([Companies Total Assets], 4) OVER (ORDER BY date asc)))/(LAG([Companies Total Assets], 4) OVER (ORDER BY date asc))

SELECT ([Companies Total Assets]-(LAG([Companies Total Assets], 4) OVER (ORDER BY date asc)))/(LAG([Companies Total Assets], 4) OVER (ORDER BY date asc))
FROM TotalAssets


--Creating temp table because cannot update using windows functions
--Companies Total Assets YoY Change %

WITH YoYChange1 AS 
	(
	SELECT Date, ([Companies Total Assets]-(LAG([Companies Total Assets], 4) OVER (ORDER BY date asc)))/(LAG([Companies Total Assets], 4) OVER (ORDER BY date asc))*100 as populate1
	FROM TotalAssets 
	)
--SELECT * from YoYChange1
UPDATE TotalAssets
SET TotalAssets.[Companies Total Assets YoY Change %] = YoYChange1.populate1
FROM TotalAssets
JOIN YoYChange1 ON TotalAssets.date = YoYChange1.date;


--Fed Total Assets YoY Change %


WITH YoYChange2 AS 
	(
	SELECT Date, ([fed Total Assets]-(LAG([fed Total Assets], 4) OVER (ORDER BY date asc)))/(LAG([fed Total Assets], 4) OVER (ORDER BY date asc))*100 as populate2
	FROM TotalAssets 
	)
--Select * from YoYChange1
UPDATE TotalAssets
SET TotalAssets.[Fed Total Assets YoY Change %] = YoYChange2.populate2
FROM TotalAssets
JOIN YoYChange2 ON TotalAssets.date = YoYChange2.date;

--Companies + Fed Total Assets YoY Change %


WITH YoYChange3 AS 
	(
	SELECT Date, ([Companies + Fed Total Assets]-(LAG([Companies + Fed Total Assets], 4) OVER (ORDER BY date asc)))/(LAG([Companies + Fed Total Assets], 4) OVER (ORDER BY date asc))*100 as populate3
	FROM TotalAssets 
	)
--Select * from YoYChange1
UPDATE TotalAssets
SET TotalAssets.[Total Assets + Fed Total Assets YoY Change %] = YoYChange3.populate3
FROM TotalAssets
JOIN YoYChange3 ON TotalAssets.date = YoYChange3.date;

--Changing columns to ###.# format

SELECT * 
FROM TotalAssets

ALTER TABLE TotalAssets
ALTER COLUMN [Companies Total Assets YoY Change %] decimal(4,1)

ALTER TABLE TotalAssets
Alter Column [Fed Total Assets YoY Change %] decimal(4,1)

ALTER TABLE TotalAssets
Alter Column [Total Assets + Fed Total Assets YoY Change %] decimal(4,1)
