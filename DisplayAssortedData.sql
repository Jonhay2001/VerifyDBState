--------------------------------------------------------------
-- 1. Display the USERID of any users who have not made an order.
--------------------------------------------------------------
SELECT u.USERID
FROM USERBASE u
MINUS
SELECT o.USERID
FROM ORDERS o;

--------------------------------------------------------------
-- 2. Display the PRODUCTCODE of any products that have no reviews.
--------------------------------------------------------------
SELECT p.PRODUCTCODE
FROM PRODUCTLIST p
MINUS
SELECT r.PRODUCTCODE
FROM REVIEWS r;

--------------------------------------------------------------
-- 3. Display all data in USERBASE with “Adult” or “Minor” column.
--------------------------------------------------------------
SELECT u.*, 
       CASE 
         WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, u.BIRTHDAY)/12) >= 18 THEN 'Adult' 
         ELSE 'Minor' 
       END AS AGE_GROUP
FROM USERBASE u;

--------------------------------------------------------------
-- 4. Display all data in PRODUCTLIST with “On Sale” or “Base Price” column.
--------------------------------------------------------------
SELECT p.*,
       CASE
         WHEN p.PRICE <= 20 THEN 'On Sale'
         ELSE 'Base Price'
       END AS PRICE_CATEGORY
FROM PRODUCTLIST p;

--------------------------------------------------------------
-- 5. Display USERID of users who played PRODUCTCODE = 'GAME6' and have a profile image.
--------------------------------------------------------------
SELECT DISTINCT u.USERID
FROM USERBASE u
JOIN USERLIBRARY l ON u.USERID = l.USERID
JOIN USERPROFILE p ON u.USERID = p.USERID
WHERE l.PRODUCTCODE = 'GAME6'
  AND p.IMAGEFILE IS NOT NULL;

--------------------------------------------------------------
-- 6. Display PRODUCTCODE from intersect of WISHLIST and REVIEWS (position 1 or 2, rating >= 3)
--------------------------------------------------------------
SELECT PRODUCTCODE
FROM WISHLIST
WHERE POSITION IN (1, 2)
INTERSECT
SELECT PRODUCTCODE
FROM REVIEWS
WHERE RATING >= 3;

--------------------------------------------------------------
-- 7. Display USERNAME and BIRTHDAY of users who share the same birthday.
--------------------------------------------------------------
SELECT a.USERNAME, a.BIRTHDAY
FROM USERBASE a
JOIN USERBASE b
  ON a.BIRTHDAY = b.BIRTHDAY
 AND a.USERID <> b.USERID;

--------------------------------------------------------------
-- 8. Display Cartesian Product of USERLIBRARY and WISHLIST.
--------------------------------------------------------------
SELECT *
FROM USERLIBRARY
CROSS JOIN WISHLIST;

--------------------------------------------------------------
-- 9. Perform UNION ALL on USERBASE and PRODUCTLIST.
--------------------------------------------------------------
SELECT TO_CHAR(USERID) AS ID, USERNAME AS NAME, EMAIL, 'User' AS TYPE
FROM USERBASE
UNION ALL
SELECT PRODUCTCODE AS ID, PRODUCTNAME AS NAME, NULL AS EMAIL, 'Product' AS TYPE
FROM PRODUCTLIST;

--------------------------------------------------------------
-- 10. Perform UNION ALL on CHATLOG and USERPROFILE.
--------------------------------------------------------------
SELECT  
    SENDERID AS USERID,  
    CONTENT AS ACTIVITY,  
    DATESENT AS ACTIVITY_DATE,  
    'Chat' AS SOURCE 
FROM CHATLOG 
UNION ALL 
SELECT  
    USERID,  
    DESCRIPTION AS ACTIVITY,  -- using DESCRIPTION instead of BIO
    SYSDATE AS ACTIVITY_DATE,  -- placeholder date
    'Profile' AS SOURCE 
FROM USERPROFILE;

--------------------------------------------------------------
-- 11. Display USERNAME of all users who have not received an INFRACTION.
--------------------------------------------------------------
SELECT USERNAME
FROM USERBASE
MINUS
SELECT u.USERNAME
FROM USERBASE u
JOIN INFRACTIONS i ON u.USERID = i.USERID;

--------------------------------------------------------------
-- 12. Display TITLE and DESCRIPTION of COMMUNITYRULES not broken.
--------------------------------------------------------------
SELECT TITLE, DESCRIPTION
FROM COMMUNITYRULES
MINUS
SELECT r.TITLE, r.DESCRIPTION
FROM COMMUNITYRULES r
JOIN INFRACTIONS i ON r.RULENUM = i.RULENUM;

--------------------------------------------------------------
-- 13. Display USERNAME and EMAIL of users penalized for an INFRACTION.
--------------------------------------------------------------
SELECT u.USERNAME, u.EMAIL
FROM USERBASE u
JOIN INFRACTIONS i ON u.USERID = i.USERID
WHERE i.PENALTY IS NOT NULL;

--------------------------------------------------------------
-- 14. Display dates where an INFRACTION was assigned and a USERSUPPORT ticket submitted same day.
--------------------------------------------------------------
SELECT i.DATEASSIGNED
FROM INFRACTIONS i
INTERSECT
SELECT s.DATESUBMITTED
FROM USERSUPPORT s;

--------------------------------------------------------------
-- 15. Display every COMMUNITYRULES TITLE and PENALTY.
--------------------------------------------------------------
SELECT r.TITLE, i.PENALTY
FROM COMMUNITYRULES r
LEFT JOIN INFRACTIONS i ON r.RULENUM = i.RULENUM;

--------------------------------------------------------------
-- 16. Display COMMUNITYRULES with “Bannable” or “Appealable” column.
--------------------------------------------------------------
SELECT c.*,
       CASE
         WHEN c.SEVERITYPOINT >= 10 THEN 'Bannable'
         ELSE 'Appealable'
       END AS RULE_STATUS
FROM COMMUNITYRULES c;

--------------------------------------------------------------
-- 17. Display USERSUPPORT with “High Priority” if not closed & not updated past week.
--------------------------------------------------------------
SELECT s.*,
       CASE
         WHEN s.STATUS <> 'CLOSED'
          AND s.DATEUPDATED < SYSDATE - 7 THEN 'High Priority'
         ELSE 'Normal'
       END AS PRIORITY_STATUS
FROM USERSUPPORT s;

--------------------------------------------------------------
-- 18. Display Cartesian Product of USERSUPPORT and INFRACTIONS.
--------------------------------------------------------------
SELECT *
FROM USERSUPPORT
CROSS JOIN INFRACTIONS;

--------------------------------------------------------------
-- 19. Display TICKETIDs and DATEUPDATED where CLOSED tickets updated same day.
--------------------------------------------------------------
SELECT a.TICKETID, a.DATEUPDATED
FROM USERSUPPORT a
JOIN USERSUPPORT b
  ON a.DATEUPDATED = b.DATEUPDATED
WHERE a.STATUS = 'CLOSED'
  AND b.STATUS = 'CLOSED';

--------------------------------------------------------------
-- 20. Perform UNION ALL on USERBASE and INFRACTIONS to show user activity.
--------------------------------------------------------------
SELECT USERID, USERNAME, 'User Account' AS SOURCE
FROM USERBASE
UNION ALL
SELECT USERID, PENALTY AS USERNAME, 'Infraction' AS SOURCE
FROM INFRACTIONS;
