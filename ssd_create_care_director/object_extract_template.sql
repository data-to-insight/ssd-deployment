
/* ********************************************************************************************************** */
/* Development set up */

-- Note: 
-- SSD extract files with the suffix ..._per.sql - for creating the persistent table versions.
-- SSD extract files with the suffix ..._tmp.sql - for creating the temporary table versions(within the temp DB name space for testing purposes).


-- Query run time vars
DECLARE
    v_StartTime TIMESTAMP;
BEGIN
    v_StartTime := SYSTIMESTAMP;
END;
/
/* ********************************************************************************************************** */


-- ssd time-frame (YRS)
DECLARE
    v_ssd_timeframe_years NUMBER := 6;
    v_ssd_sub1_range_years NUMBER := 1;



/* 
=============================================================================
Object Name: 
Description: 

Author: 
Last Modified Date: 
DB Compatibility: Oracle|
Version: 0.1
Status: [*Dev, Testing, Release, Blocked, AwaitingReview, Backlog]
Remarks: 
Dependencies: 
- 
=============================================================================
*/

-- Extract script here







/* ********************************************************************************************************** */
/* Development clean up */
DECLARE
    v_StartTime TIMESTAMP := SYSTIMESTAMP; 
    v_EndTime TIMESTAMP;
    v_Duration NUMBER; -- diff' in seconds
BEGIN
    v_EndTime := SYSTIMESTAMP;

    -- Calculate the difference in seconds
    v_Duration := (EXTRACT(SECOND FROM (v_EndTime - v_StartTime)) + 
                   EXTRACT(MINUTE FROM (v_EndTime - v_StartTime)) * 60 + 
                   EXTRACT(HOUR FROM (v_EndTime - v_StartTime)) * 3600);

    DBMS_OUTPUT.PUT_LINE('Run time duration: ' || TO_CHAR(v_Duration) || ' seconds');
END;
/
