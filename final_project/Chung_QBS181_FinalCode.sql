SELECT * FROM [qbs181].[ychung].Demographics
SELECT * FROM [qbs181].[ychung].Conditions
SELECT * FROM [qbs181].[ychung].TextMessages

/* Merge the tables Demographics, Conditions and TextMessages.*/
SELECT A.*, B.*, C.*
INTO [qbs181].[ychung].DemCondText1 
FROM [qbs181].[ychung].TextMessages A
LEFT JOIN [qbs181].[ychung].Conditions B ON A.tri_contactId = B.tri_patientid 
LEFT JOIN [qbs181].[ychung].Demographics C ON A.tri_contactid = C.ID

SELECT * FROM [qbs181].[ychung].DemCondText1 

SELECT ID, MAX(TRY_CONVERT(Date,TextSentDate)) as MaxDate
INTO [qbs181].[ychung].LastTexts
FROM [qbs181].[ychung].DemCondText1 
GROUP BY ID
