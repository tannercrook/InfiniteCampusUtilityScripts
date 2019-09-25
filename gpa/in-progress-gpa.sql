-- ----------------------------------------------------------------------------
-- Author: Tanner Crook
-- Copyright: (c) Tanner Crook 2017
-- ----------------------------------------------------------------------------
-- This script will calculate the GPA for a given term and grading task.
-- ----------------------------------------------------------------------------







SELECT
  grades.studentNumber AS studentNumber
, grades.lastName AS lastName
, grades.firstName AS firstName
, ROUND(AVG(grades.gpaValue), 3) AS gpa
, grades.grade AS gradeLevel
, grades.STARS AS STARS
FROM
(
SELECT
  p.studentNumber AS studentNumber
, i.lastName AS lastName
, i.firstName AS firstName
, gs.sectionID AS sectionID
, gs.taskID AS task
, gs.progressScore AS score
, sli.unweightedGPAValue AS gpaValue
, vas.grade AS grade
, vas.homeroomTeacher AS STARS
FROM person p 
INNER JOIN [identity] i 
ON p.currentIdentityID = i.identityID
INNER JOIN roster r 
ON p.personID = r.personID 
INNER JOIN section sec 
ON r.sectionID = sec.sectionID
INNER JOIN gradingScore gs 
ON p.personID = gs.personID
AND sec.sectionID = gs.sectionID
INNER JOIN scoreListItem sli
ON gs.progressScore = sli.score
INNER JOIN term t 
ON gs.termID = t.termID
INNER JOIN gradingTask gt 
ON gs.taskID = gt.taskID
AND scoreGroupID = 1
INNER JOIN course c 
ON sec.courseID = c.courseID
INNER JOIN calendar cal 
ON c.calendarID = cal.calendarID
INNER JOIN V_AdHocStudent vas 
ON p.personID = vas.personID
AND cal.calendarID = vas.calendarID
WHERE cal.name = 'CALENDAR'
AND (CURRENT_TIMESTAMP >= t.startDate AND CURRENT_TIMESTAMP <= t.endDate)
AND ((CURRENT_TIMESTAMP >= r.startDate OR r.startDate IS NULL) AND (CURRENT_TIMESTAMP <= r.endDate OR r.endDate IS NULL))
AND gt.name = 'GRADING TASK NAME') AS grades
GROUP BY grades.studentNumber, grades.lastName, grades.firstName, grades.grade, grades.STARS
ORDER BY grades.grade, grades.STARS, grades.lastName, grades.firstName;

