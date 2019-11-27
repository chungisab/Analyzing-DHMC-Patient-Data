/* Make copies of tables*/
select * into [qbs181].[ychung].Demographics from [qbs181].dbo.Demographics

select * into [qbs181].[ychung].PhoneCall from [qbs181].dbo.PhoneCall

select * into [qbs181].[ychung].PhoneCall_Encounter from [qbs181].dbo.PhoneCall_Encounter

select * into [qbs181].[ychung].TextMessages from [qbs181].dbo.TextMessages

/*Create new table Phonecall1 by merging PhoneCall_Encounter with PhoneCall*/
select A.*, B.* 
into [qbs181].[ychung].Phonecall1
from [qbs181].[ychung].Phonecall A
left join [qbs181].[ychung].Phonecall_Encounter B
on A.tri_CustomerIDEntityReference = B.CustomerId

/* Create new column EnrollmentGroup  */
ALTER TABLE [qbs181].[ychung].Phonecall1
ADD EnrollmentGroup nvarchar(255)

/* Insert values into newly created column EnrollmentGroup.*/
UPDATE [qbs181].[ychung].Phonecall1 
SET EnrollmentGroup = 
CASE 
	WHEN EncounterCode = 125060000 THEN 'Clinical Alert'
	WHEN EncounterCode = 125060001 THEN 'Health Coaching'
	WHEN EncounterCode = 125060002 THEN 'Technical Question'
	WHEN EncounterCode = 125060003 THEN 'Administrative'
	WHEN EncounterCode = 125060004 THEN 'Other'
	WHEN EncounterCode = 125060005 THEN 'Lack of engagement'
END

/* Obtain the number of records for each enrollment group.*/
select EnrollmentGroup, count(*) as Count
from [qbs181].[ychung].Phonecall1 
group by EnrollmentGroup

drop table [qbs181].[ychung].JointCall

select A.*, B.* 
into [qbs181].[ychung].JointCall
from [qbs181].[ychung].Phonecall A
inner join [qbs181].[ychung].Phonecall_Encounter B
on A.tri_CustomerIDEntityReference = B.CustomerId

/*Find out the # of records for different call outcomes and call type.*/
select CallOutcome, count(*) as Count
into [qbs181].[ychung].CallCount
from [qbs181].[ychung].JointCall 
group by CallOutcome

alter table [qbs181].[ychung].CallCount 
add Call_Outcome varchar(255)

update [qbs181].[ychung].CallCount  
SET Call_Outcome = 
CASE 
	WHEN TRY_CONVERT(int,CallOutcome)= 1 THEN 'No response'
	WHEN TRY_CONVERT(int,CallOutcome)= 2 THEN 'Left voice mail'
	WHEN TRY_CONVERT(int,CallOutcome)= 3 THEN 'Successful'
END

drop table [qbs181].[ychung].CallCount

select * from [qbs181].[ychung].JointCall 

select CallType, count(*) as Count
into [qbs181].[ychung].TypeCount
from [qbs181].[ychung].JointCall 
group by CallType

alter table [qbs181].[ychung].TypeCount 
add Call_Type varchar(255)

update [qbs181].[ychung].TypeCount  
SET Call_Type = 
CASE 
	WHEN TRY_CONVERT(int,CallType)= 1 THEN 'Inbound'
	WHEN TRY_CONVERT(int,CallType)= 2 THEN 'Outbound'
END

DROP table [qbs181].[ychung].TypeCount  

select * from [qbs181].[ychung].TypeCount

/*Find the call duration for each of the enrollment groups.*/
ALTER TABLE [qbs181].[ychung].JointCall
ADD EnrollmentGroup nvarchar(255)

UPDATE [qbs181].[ychung].JointCall
SET EnrollmentGroup = 
CASE 
	WHEN EncounterCode = 125060000 THEN 'Clinical Alert'
	WHEN EncounterCode = 125060001 THEN 'Health Coaching'
	WHEN EncounterCode = 125060002 THEN 'Technical Question'
	WHEN EncounterCode = 125060003 THEN 'Administrative'
	WHEN EncounterCode = 125060004 THEN 'Other'
	WHEN EncounterCode = 125060005 THEN 'Lack of engagement'
END

select EnrollmentGroup, SUM(CAST(CallDuration AS INT)) AS TotalCallDuration
from [qbs181].[ychung].JointCall
group by EnrollmentGroup

select * from [qbs181].[ychung].JointCall

select * from [qbs181].[ychung].DemCondText

drop table [qbs181].[ychung].Demographics 

select * from [qbs181].[ychung].Demographics

drop table [qbs181].[ychung].DemCondText

/* Merge the tables Demographics, Conditions and TextMessages.*/
SELECT A.*, B.*, C.*
INTO [qbs181].[ychung].DemCondText
FROM [qbs181].[ychung].TextMessages A
LEFT JOIN [qbs181].[ychung].Conditions B ON A.tri_contactId = B.tri_patientid 
LEFT JOIN [qbs181].[ychung].Demographics C ON A.tri_contactid = C.contactId


ALTER TABLE [qbs181].[ychung].DemCondText
ADD weeks nvarchar(255) 

UPDATE [qbs181].[ychung].DemCondText
SET weeks = datepart(wk, TextSentDate)

/*Find the # of texts/per week, by the type of sender.*/
SELECT Sendername, count(weeks) AS NumberOfTexts, weeks
FROM [qbs181].[ychung].DemCondText
GROUP BY Sendername, weeks

/*Obtain the count of texts/week based on the chronic condition. */
SELECT tri_name, count(weeks) AS NumberOfTexts, weeks
FROM [qbs181].[ychung].DemCondText
GROUP BY tri_name, weeks




