
-- ssd time-frame (YRS)
DECLARE @YearsBack INT = 6;


/* 
=============================================================================
Object Name: Ofsted List 1 - Contacts YYYY
Description: List 1: Contacts "All contacts received in the six months before the date of inspection. 
Where a contact refers to multiple children, include an entry for each child in the contact.

Author: D2I
Last Modified Date: 
DB Compatibility: SQL Server 2014+|...
Version: 0.1
Status: [*Dev, Testing, Release, Blocked, AwaitingReview, Backlog]
Remarks: script needs modifying to ref revised field/item naming 271023
Dependencies: 
- ssd_contacts
- ssd_person
=============================================================================
*/

-- CREATE TEMPORARY TABLE `AA_1_contacts` AS 
CREATE VIEW AA_1_contacts_vw AS
SELECT
    /* Common AA fields */
    p.la_person_id,
    p.person_gender,
    p.person_ethnicity,
    FORMAT(p.person_dob, 'dd/MM/yyyy') AS formatted_person_dob,
    CASE -- provide the child's age in years at their last birthday.
        WHEN p.person_dob > GETDATE() THEN -1 -- If a child is unborn, enter their age as '-1'
        -- If born on Feb 29 and the current year is not a leap year and the date is before Feb 28, adjust the age
        WHEN MONTH(p.person_dob) = 2 AND DAY(p.person_dob) = 29 AND
            MONTH(GETDATE()) <= 2 AND DAY(GETDATE()) < 28 AND
            (YEAR(GETDATE()) % 4 != 0 OR (YEAR(GETDATE()) % 100 = 0 AND YEAR(GETDATE()) % 400 != 0))
        THEN YEAR(GETDATE()) - YEAR(p.person_dob) - 2
        ELSE 
            YEAR(GETDATE()) - YEAR(p.person_dob) - 
            CASE 
                WHEN MONTH(GETDATE()) < MONTH(p.person_dob) OR 
                    (MONTH(GETDATE()) = MONTH(p.person_dob) AND DAY(GETDATE()) < DAY(p.person_dob))
                THEN 1 
                ELSE 0 -- returned if age is < 1yr
            END
    END as CurrentAge, -- Calculated Age (Note on List 1 is 'AGE')
    
    /* Returns fields */
    FORMAT(c.contact_date, 'dd/MM/yyyy') AS formatted_contact_date,
    c.contact_source

FROM
    contacts c
LEFT JOIN
    person p ON c.la_person_id = p.la_person_id
WHERE
    c.contact_date >= DATEADD(MONTH, -@YearsBack, GETDATE());
