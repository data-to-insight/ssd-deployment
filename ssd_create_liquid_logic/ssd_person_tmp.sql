

/* ********************************************************************************************************** */
/* Development set up */

USE HDM;
GO

-- Query run time vars
DECLARE @StartTime DATETIME, @EndTime DATETIME;
SET @StartTime = GETDATE(); -- Record the start time
/* ********************************************************************************************************** */





-- ssd time-frame (YRS)
DECLARE @YearsBack INT = 6;

/*
=============================================================================
Object Name: ssd_person
Description: person/child details
Author: D2I
Last Modified Date: 2023-10-20
Version: 0.1
Status: [Dev, *Testing, Release, Blocked, AwaitingReview, Backlog]
Remarks: Need to confirm FACT_903_DATA as source of mother related data
Dependencies: 
- Child_Social.DIM_PERSON
- Child_Social.FACT_REFERRALS
- Child_Social.FACT_CONTACTS
- Child_Social.FACT_EHCP_EPISODE
- Child_Social.FACT_903_DATA
=============================================================================
*/
-- Check if exists, & drop
IF OBJECT_ID('tempdb..#ssd_person') IS NOT NULL DROP TABLE #ssd_person;

-- Create the temporary table
SELECT 
    p.[EXTERNAL_ID] AS pers_la_person_id,
    p.[DIM_LOOKUP_VARIATION_OF_SEX_CODE] AS pers_sex,
    p.[GENDER_MAIN_CODE] AS pers_gender, -- might need placholder, not available in every LA
    p.[ETHNICITY_MAIN_CODE] AS pers_ethnicity,
    p.[BIRTH_DTTM] AS pers_dob,
    NULL AS pers_common_child_id, -- Set to NULL
    p.[UPN] AS pers_upn,

    (SELECT TOP 1 f.NO_UPN_CODE
    FROM Child_Social.FACT_903_DATA f
    WHERE f.EXTERNAL_ID = p.EXTERNAL_ID
    AND f.NO_UPN_CODE IS NOT NULL
    ORDER BY f.NO_UPN_CODE DESC) AS person_upn_unknown,

    p.[EHM_SEN_FLAG] AS person_send,
    p.[DOB_ESTIMATED] AS person_expected_dob,
    p.[DEATH_DTTM] AS person_death_date,
    p.[NATNL_CODE] AS person_nationality

INTO 
    #ssd_person
FROM 
    Child_Social.DIM_PERSON AS p
WHERE 
    p.[EXTERNAL_ID] IS NOT NULL
AND (
    EXISTS (
        SELECT 1 FROM Child_Social.FACT_REFERRALS fr 
        WHERE fr.[EXTERNAL_ID] = p.[EXTERNAL_ID] 
        AND fr.REFRL_START_DTTM >= DATEADD(YEAR, -@YearsBack, GETDATE())
    )
    OR EXISTS (
        SELECT 1 FROM Child_Social.FACT_CONTACTS fc
        WHERE fc.[EXTERNAL_ID] = p.[EXTERNAL_ID] 
        AND fc.CONTACT_DTTM >= DATEADD(YEAR, -@YearsBack, GETDATE())
    )
    OR EXISTS (
        SELECT 1 FROM Child_Social.FACT_EHCP_EPISODE fe 
        WHERE fe.[EXTERNAL_ID] = p.[EXTERNAL_ID] 
        AND fe.REQUEST_DTTM >= DATEADD(YEAR, -@YearsBack, GETDATE())
    )
)
ORDER BY
    p.[EXTERNAL_ID] ASC;

-- Create a non-clustered index on la_person_id for quicker lookups and joins in the temp table
CREATE INDEX IDX_ssd_pers_la_person_id ON #ssd_person(pers_la_person_id);






/* ********************************************************************************************************** */
/* Development clean up */

IF OBJECT_ID('tempdb..#ssd_person') IS NOT NULL DROP TABLE #ssd_person;

-- Get & print run time 
SET @EndTime = GETDATE();
PRINT 'Run time duration: ' + CAST(DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS NVARCHAR(50)) + ' ms';

