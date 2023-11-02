
/* ********************************************************************************************************** */
/* Development set up */

USE HDM;
GO

-- Query run time vars
DECLARE @StartTime DATETIME, @EndTime DATETIME;
SET @StartTime = GETDATE(); -- Record the start time
/* ********************************************************************************************************** */





-- ssd time-frame (YRS)
DECLARE @ssd_timeframe_years INT = 6;
        @ssd_sub1_range_years INT = 1;

/*
=============================================================================
Object Name: ssd_person
Description: person/child details
Author: D2I
Last Modified Date: 2023-10-20
DB Compatibility: SQL Server 2014+|...

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
-- check exists & drop
IF OBJECT_ID('Child_Social.ssd_person') IS NOT NULL DROP TABLE Child_Social.ssd_person;

-- Create structure
CREATE TABLE ssd_person (
    pers_la_person_id NVARCHAR(36) PRIMARY KEY, 
    pers_sex NVARCHAR(48),
    pers_ethnicity NVARCHAR(38),
    pers_dob DATETIME,
    pers_common_child_id NVARCHAR(10),
    pers_upn NVARCHAR(20),
    pers_upn_unknown NVARCHAR(96),
    pers_send NVARCHAR(1),
    pers_expected_dob DATETIME,
    pers_death_date DATETIME,
    pers_nationality NVARCHAR(48)
);

-- Insert data 
INSERT INTO ssd_person (
    pers_la_person_id,
    pers_sex,
    pers_ethnicity,
    pers_dob,
    pers_common_child_id,
    pers_upn,
    pers_upn_unknown,
    pers_send,
    pers_expected_dob,
    pers_death_date,
    pers_nationality
)
SELECT 
    p.[EXTERNAL_ID],
    p.[DIM_LOOKUP_VARIATION_OF_SEX_CODE],
    p.[ETHNICITY_MAIN_CODE],
    p.[BIRTH_DTTM],
    NULL AS pers_common_child_id, -- Set to NULL
    p.[UPN],

    (SELECT TOP 1 f.NO_UPN_CODE              -- Subquery to fetch ANY/MOST RECENT? NO_UPN_CODE.
    FROM Child_Social.FACT_903_DATA f        -- This *unlikely* to be the best source
    WHERE f.EXTERNAL_ID = p.EXTERNAL_ID
    AND f.NO_UPN_CODE IS NOT NULL
    ORDER BY f.NO_UPN_CODE DESC) AS pers_upn_unknown,  -- desc order to ensure a non-null value first

    p.[EHM_SEN_FLAG],
    p.[DOB_ESTIMATED],
    p.[DEATH_DTTM],
    p.[NATNL_CODE]

FROM 
    Child_Social.DIM_PERSON AS p
WHERE 
    p.[EXTERNAL_ID] IS NOT NULL
AND (
    EXISTS (
        -- has open referral
        SELECT 1 FROM Child_Social.FACT_REFERRALS fr 
        WHERE fr.[EXTERNAL_ID] = p.[EXTERNAL_ID] 
        AND fr.REFRL_START_DTTM >= DATEADD(YEAR, -@YearsBack, GETDATE())
    )
    OR EXISTS (
        -- contact in last x@yrs
        SELECT 1 FROM Child_Social.FACT_CONTACTS fc
        WHERE fc.[EXTERNAL_ID] = p.[EXTERNAL_ID] 
        AND fc.CONTACT_DTTM >= DATEADD(YEAR, -@YearsBack, GETDATE())
    )
    OR EXISTS (
        -- ehcp request in last x@yrs
        SELECT 1 FROM Child_Social.FACT_EHCP_EPISODE fe 
        WHERE fe.[EXTERNAL_ID] = p.[EXTERNAL_ID] 
        AND fe.REQUEST_DTTM >= DATEADD(YEAR, -@YearsBack, GETDATE())
    )
    -- OR EXISTS (
        -- active plan or has been active in x@yrs
    --)
    -- OR EXISTS (
        -- eh_referral open in last x@yrs
    --)
    -- OR EXISTS (
        -- record in send
    --)
)
ORDER BY
    p.[EXTERNAL_ID] ASC;

-- Create a non-clustered index on la_person_id for quicker lookups and joins
CREATE INDEX IDX_ssd_person_la_person_id ON Child_Social.ssd_person(pers_la_person_id);

-- [done]has open referral - FACT_REFERRALS.REFRL_START_DTTM
-- [done]contact in last 6yrs - Child_Social.FACT_CONTACTS.CONTACT_DTTM
-- [done]ehcp request in last 6yrs - Child_Social.FACT_EHCP_EPISODE.REQUEST_DTTM ;
-- active plan or has been active in 6yrs
-- eh_referral open in last 6yrs - Child_Social.FACT_REFERRALS.REFRL_START_DTTM
-- record in send - where from ? Child_Social.FACT_SEN, DIM_LOOKUP_SEN, DIM_LOOKUP_SEN_TYPE
