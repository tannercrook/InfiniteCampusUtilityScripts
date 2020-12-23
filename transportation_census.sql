/* transportation_census.sql
 * ------------------------------------------
 * (c)2020 Tanner Crook
 *  -----------------------------------------
 * This script will pull student information with census data such as physical and mailing addresses and contact information for 3 contacts
 * based upon the contact sequence value set in the database.
 *
*/

SELECT DISTINCT
  s.studentNumber AS "Student ID"
, s.lastName AS "Last Name"
, s.firstName AS "First Name"
, s.middleName AS "Middle Name"
, re.name AS "Ethnicity"
, s.gender AS "Gender"
, s.birthdate AS "DOB"
, school.name AS "School Name"
, school.[number] AS "School Code"
, s.grade AS "Grade"
, CONCAT(COALESCE(ap.number+' ',''), COALESCE(ap.prefix+' ',''), COALESCE(ap.street+' ',''), COALESCE(ap.tag+' ',''), COALESCE(ap.dir+' ',''), COALESCE(ap.apt, ''))AS "Physical Address"
, NULL AS "Physical Address Line 2"
, ap.city AS "City"
, ap.state AS "State"
, ap.zip AS "Zip"
, CASE WHEN am.postOfficeBox = 1 
			THEN CONCAT('PO Box ',COALESCE(am.number+' ',''), COALESCE(am.prefix+' ',''), COALESCE(am.street+' ',''), COALESCE(am.tag+' ',''), COALESCE(am.dir+' ',''), COALESCE(am.apt, ''))
		   ELSE CONCAT(COALESCE(am.number+' ',''), COALESCE(am.prefix+' ',''), COALESCE(am.street+' ',''), COALESCE(am.tag+' ',''), COALESCE(am.dir+' ',''), COALESCE(am.apt, ''))
	  END AS "Mailing Address 1"
, NULL AS "Mailing Address Line 2"
, am.city AS "City"
, am.state AS "State"
, am.zip AS "Zip"
, CONCAT(cpi1.firstName,' ',cpi1.lastName) AS "Contact 1 Full Name"
, cp1c.cellPhone AS "Contact 1 Cell phone"
, cp1c.workPhone AS "Contact 1 Work phone"
, cp1c.email AS "Contact 1 email"
, rp1.name AS "Contact 1 Relationship"
, CONCAT(cpi2.firstName,' ',cpi2.lastName) AS "Contact 2 Full Name"
, cp2c.cellPhone AS "Contact 2 Cell phone"
, cp2c.workPhone AS "Contact 2 Work phone"
, cp2c.email AS "Contact 2 email"
, rp2.name AS "Contact 2 Relationship"
, CONCAT(cpi3.firstName,' ',cpi3.lastName) AS "Contact 3 Full Name"
, cp3c.cellPhone AS "Contact 3 Cell phone"
, cp3c.workPhone AS "Contact 3 Work phone"
, cp3c.email AS "Contact 3 email"
, rp3.name AS "Contact 3 Relationship"
, NULL AS "Withdrawal Date"
, NULL AS "Comments" 
, NULL AS "Wheelchair"
, NULL AS "Bus Aide Required"
, NULL AS "Transportation Needed"
, NULL AS "Transportation Code"
FROM person sp INNER JOIN student s
ON sp.personID = s.personID
INNER JOIN enrollment se
ON sp.personID = se.personID
AND s.enrollmentID = se.enrollmentID
INNER JOIN calendar c
ON se.calendarID = c.calendarID
INNER JOIN schoolYear
ON c.endYear = schoolYear.endYear
INNER JOIN householdmember hm
ON sp.personID = hm.personID
AND hm.secondary = 0
AND ISNULL(hm.endDate, GETDATE()+1) >= GETDATE()
INNER JOIN household h
ON hm.householdID = h.householdID
INNER JOIN householdLocation hlp
ON h.householdID = hlp.householdID
AND hlp.secondary = 0
AND hlp.physical = 1
AND ISNULL(hlp.endDate, GETDATE()+1) >= GETDATE()
INNER JOIN address ap
ON hlp.addressID = ap.addressID
AND ap.postOfficeBox = 0
LEFT JOIN householdLocation hlm 
ON h.householdID = hlm.householdID 
AND hlm.mailing = 1
AND ISNULL(hlm.endDate, GETDATE()+1) >= GETDATE()
LEFT JOIN Address am 
ON hlm.addressID = am.addressID 
INNER JOIN school
ON c.schoolID = school.schoolID
LEFT JOIN RelatedPair rp1 
ON sp.personID = rp1.personID1 
AND ISNULL(rp1.endDate, GETDATE()+1) >= GETDATE()
AND rp1.seq = 1
LEFT JOIN Person cp1 
ON rp1.personID2 = cp1.personID 
LEFT JOIN [Identity] cpi1 
ON cp1.currentIdentityID = cpi1.identityID
LEFT JOIN Contact cp1c 
ON cp1.personID = cp1c.personID 
LEFT JOIN RelatedPair rp2
ON sp.personID = rp2.personID1 
AND ISNULL(rp2.endDate, GETDATE()+1) >= GETDATE()
AND rp2.seq = 2
LEFT JOIN Person cp2 
ON rp2.personID2 = cp2.personID 
LEFT JOIN [Identity] cpi2 
ON cp2.currentIdentityID = cpi2.identityID 
LEFT JOIN Contact cp2c 
ON cp2.personID = cp2c.personID 
LEFT JOIN RelatedPair rp3
ON sp.personID = rp3.personID1 
AND ISNULL(rp3.endDate, GETDATE()+1) >= GETDATE()
AND rp3.seq = 3
LEFT JOIN Person cp3 
ON rp3.personID2 = cp3.personID 
LEFT JOIN [Identity] cpi3 
ON cp3.currentIdentityID = cpi3.identityID 
LEFT JOIN Contact cp3c 
ON cp3.personID = cp3c.personID 
LEFT JOIN RaceEthnicity re 
ON s.raceEthnicity = re.code 
WHERE s.activeYear = 1
AND school.exclude != 1
ORDER BY s.lastname, s.firstName;
