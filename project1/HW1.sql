-- Isabelle (YeonJoo) Chung 
-- Data Wrangling: HW 1 
-- Professor Yapalparvi
-- October 9th, 2019

-- Make copies of tables --  
select * into [qbs181].[ychung].Demographics from [qbs181].dbo.Demographics

select * into [qbs181].[ychung].Dx from [qbs181].dbo.Dx

select * into [qbs181].[ychung].Flowsheets from [qbs181].dbo.Flowsheets

select * into [qbs181].[ychung].Inpatient from [qbs181].dbo.Inpatient

select * into [qbs181].[ychung].Outpatient from [qbs181].dbo.Outpatient

select * into [qbs181].[ychung].PhoneCall from [qbs181].dbo.PhoneCall

select * into [qbs181].[ychung].PhoneCall_Encounter from [qbs181].dbo.PhoneCall_Encounter

select * into [qbs181].[ychung].[procedure] from [qbs181].dbo.[procedure]

-- 1. Rename columns. -- 
exec sp_rename 'ychung.Demographics.tri_age', 'Age', 'COLUMN'

exec sp_rename 'ychung.Demographics.gendercode', 'Gender', 'COLUMN' -- already is a gender column?

exec sp_rename 'ychung.Demographics.contactid', 'ID', 'COLUMN'

exec sp_rename 'ychung.Demographics.address1_stateorprovince', 'State', 'COLUMN'

exec sp_rename 'ychung.Demographics.tri_imaginecareenrollmentemailsentdate', 'EmailSentDate', 'COLUMN'

exec sp_rename 'ychung.Demographics.tri_enrollmentcompletedate', 'CompleteDate', 'COLUMN'

[qbs181].[ychung].Demographics.tri

-- Create new column “Enrollment Status”.
ALTER TABLE [qbs181].[ychung].Demographics
ADD Enrollment_Status nvarchar(255)

UPDATE [qbs181].[ychung].Demographics
SET Enrollment_Status = NULL

UPDATE [qbs181].[ychung].demographics 
SET Enrollment_Status = 'Complete'
WHERE tri_imaginecareenrollmentstatus = 167410011

UPDATE [qbs181].[ychung].demographics 
SET Enrollment_Status = 'Email sent'
WHERE EmailSentDate = 167410001

UPDATE [qbs181].[ychung].demographics 
SET Enrollment_Status = 'Non responder'
WHERE EmailSentDate = 167410004

UPDATE [qbs181].[ychung].demographics 
SET Enrollment_Status = 'Incomplete Enrollments'
WHERE EmailSentDate = 167410002

UPDATE [qbs181].[ychung].demographics 
SET Enrollment_Status = 'Opted out'
WHERE EmailSentDate = 167410003

UPDATE [qbs181].[ychung].demographics 
SET Enrollment_Status = 'Facilitated Enrollment'
WHERE CompleteDate = 167410004

UPDATE [qbs181].[ychung].demographics 
SET Enrollment_Status = 'Unprocessed'
WHERE tri_imaginecareenrollmentstatus = 167410000

UPDATE [qbs181].[ychung].demographics 
SET Enrollment_Status = 'Second email sent'
WHERE EmailSentDate = 167410006

-- 3. Create new column “Sex”.
ALTER TABLE [qbs181].[ychung].Demographics
ADD Sex nvarchar(255)

UPDATE [qbs181].[ychung].demographics 
SET Sex = 'FEMALE'
WHERE TRY_CONVERT(int, gendercode) = 2

UPDATE [qbs181].[ychung].demographics 
SET Sex = 'MALE'
WHERE TRY_CONVERT(int, gendercode) = 1

UPDATE [qbs181].[ychung].demographics 
SET Sex = 'OTHER'
WHERE tri_imaginecareenrollmentstatus = 167410000

UPDATE [qbs181].[ychung].demographics 
SET Sex = 'UNKNOWN'
WHERE gendercode = NULL

-- 4. Create age groups with intervals of 25 years.
ALTER TABLE [qbs181].[ychung].Demographics
ADD Age_Group nvarchar(255)

UPDATE [qbs181].[ychung].demographics 
SET Age_Group = '0-25'
WHERE Age BETWEEN 0 AND 25

UPDATE [qbs181].[ychung].demographics 
SET Age_Group = '26-50'
WHERE Age BETWEEN 26 AND 50

UPDATE [qbs181].[ychung].demographics 
SET Age_Group = '51-75'
WHERE Age BETWEEN 51 AND 75

UPDATE [qbs181].[ychung].demographics 
SET Age_Group = '76-100'
WHERE Age BETWEEN 76 AND 100

UPDATE [qbs181].[ychung].demographics 
SET Age_Group = '101-125'
WHERE Age BETWEEN 101 AND 125


select * from [qbs181].[ychung].Demographics

