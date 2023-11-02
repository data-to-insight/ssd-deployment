


/* ********************************************************************************************************** */
/* Development set up */

-- Note: 
-- This sample is for creating TEMP tables within the temp DB name space for testing purposes. 
-- SSD extract files with the suffix ..._perm.sql are for creating the persistent table versions of the SSD. 

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
Object Name: #ssd_address
Description: Version for creating TEMP SSD tables. 
Author: D2I
Last Modified Date: 
Version: 0.1
Status: [Dev, *Testing, Release, Blocked, AwaitingReview, Backlog]
Remarks: Need to verify json obj structure on pre-2014 SQL server instances
Dependencies: 
- DIM_PERSON_ADDRESS
=============================================================================
*/
-- Check if exists, & drop 
IF OBJECT_ID('tempdb..#ssd_address') IS NOT NULL DROP TABLE #ssd_address;

-- Create the temporary table
SELECT
    pa.[DIM_PERSON_ADDRESS_ID] as addr_address_id,
    pa.[EXTERNAL_ID] as addr_la_person_id, -- Assuming EXTERNAL_ID corresponds to la_person_id
    pa.[ADDSS_TYPE_CODE] as addr_address_type,
    pa.[START_DTTM] as addr_address_start,
    pa.[END_DTTM] as addr_address_end,
    pa.[POSTCODE] as addr_address_postcode,
        
    -- Create JSON string for the address
    (
        SELECT 
            NULLIF(pa.[ROOM_NO], '') AS ROOM, 
            NULLIF(pa.[FLOOR_NO], '') AS FLOOR, 
            NULLIF(pa.[FLAT_NO], '') AS FLAT, 
            NULLIF(pa.[BUILDING], '') AS BUILDING, 
            NULLIF(pa.[HOUSE_NO], '') AS HOUSE, 
            NULLIF(pa.[STREET], '') AS STREET, 
            NULLIF(pa.[TOWN], '') AS TOWN,
            NULLIF(pa.[UPRN], '') AS UPRN,
            NULLIF(pa.[EASTING], '') AS EASTING,
            NULLIF(pa.[NORTHING], '') AS NORTHING
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) as addr_address_json

INTO #ssd_address
FROM 
    Child_Social.DIM_PERSON_ADDRESS AS pa
ORDER BY
    pa.[EXTERNAL_ID] ASC;

-- Add primary key
ALTER TABLE #ssd_address ADD CONSTRAINT PK_address_id PRIMARY KEY (addr_address_id);

-- Non-clustered index on la_person_id
CREATE INDEX IDX_address_person ON #ssd_address(addr_la_person_id);

-- Non-clustered indexes on address_start and address_end
CREATE INDEX IDX_address_start ON #ssd_address(addr_address_start);
CREATE INDEX IDX_address_end ON #ssd_address(addr_address_end);





/* ********************************************************************************************************** */
/* Development clean up */

IF OBJECT_ID('tempdb..#ssd_address') IS NOT NULL DROP TABLE #ssd_address;

-- Get & print run time 
SET @EndTime = GETDATE();
PRINT 'Run time duration: ' + CAST(DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS NVARCHAR(50)) + ' ms';

