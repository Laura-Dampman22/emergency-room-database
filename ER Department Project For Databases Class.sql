CREATE DATABASE er_department TEMPLATE template0;

CREATE TABLE ER_wait_time (
	wait_time_id 			VARCHAR (6),
	check_in_time	 		TIME 	NOT NULL,
	triage_complete_time 	TIME,
	assigned_bed			NUMERIC,
	start_treatment_time	TIME,
	end_treatment_time		TIME,
	discharged				TIME,
	total_wait_time			VARCHAR(10),
CONSTRAINT ER_wait_time_pk PRIMARY KEY (wait_time_id)
);

ALTER TABLE ER_wait_time
ALTER COLUMN total_wait_time TYPE VARCHAR(10);


CREATE TABLE medical_staff (
	medical_staff_id		VARCHAR (6),
	first_name				VARCHAR (15)	NOT NULL,
	last_name				VARCHAR (25)	NOT NULL,
	contact_number			VARCHAR (12),
	shift_start				TIME,
	shift_end				TIME,
CONSTRAINT medical_staff_pk PRIMARY KEY (medical_staff_id)
);

CREATE TABLE NURSES (
	medical_staff_id 	VARCHAR (6),
	first_name			VARCHAR (15),
	last_name			VARCHAR (25),
	contact_number		VARCHAR (12),
	shift_start			TIME,
	shift_end			TIME,
CONSTRAINT nurses_pkey PRIMARY KEY (medical_staff_id),
CONSTRAINT nurses_fkey FOREIGN KEY (medical_staff_id) REFERENCES medical_staff (medical_staff_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE doctors (
	medical_staff_id	VARCHAR (6),
	first_name			VARCHAR (15),
	last_name			VARCHAR (25),
	contact_number		VARCHAR (12),
	shift_start			TIME,
	shift_end 			TIME,
	specialty			VARCHAR (35),
CONSTRAINT doctors_pkey PRIMARY KEY (medical_staff_id),
CONSTRAINT doctors_fkey FOREIGN KEY (medical_staff_id) REFERENCES medical_staff (medical_staff_id)
	ON DELETE CASCADE 
	ON UPDATE CASCADE
);

CREATE TABLE triage_assessment (
	triage_id			VARCHAR(5)	PRIMARY KEY,
	wait_time_id		VARCHAR (6),
	medical_staff_id	VARCHAR (6),
	time_of_assessment  TIME,
	triage_level		VARCHAR(12)		CHECK (triage_level IN ('ESI LEVEL 1', 'ESI LEVEL 2', 'ESI LEVEL 3', 'ESI LEVEL 4', 'ESI LEVEL 5')),
	priority_status		VARCHAR (35)    CHECK (priority_status IN ( 'critical', 'high priority', 'moderate priority', 'low priority', 'non-urgent')),
	reason_at_er		TEXT,
CONSTRAINT triage_assessment_fkey FOREIGN KEY (wait_time_id) REFERENCES ER_wait_time (wait_time_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
CONSTRAINT triage_assessment_fkey1 FOREIGN KEY (medical_staff_id) REFERENCES medical_staff (medical_staff_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE transfer (
	transfer_id 		VARCHAR (5)		PRIMARY KEY,
	wait_time_id		VARCHAR (6),
	receiving_doctor	VARCHAR (25),
	transfer_time		TIME,
	reason_for_transfer TEXT,
CONSTRAINT transfer_fkey FOREIGN KEY (wait_time_id) REFERENCES ER_wait_time (wait_time_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE patients (
    patient_id       VARCHAR(4) PRIMARY KEY,
    triage_id        VARCHAR(5),
    wait_time_id     VARCHAR(6),
    first_name       VARCHAR(25) NOT NULL,
    last_name        VARCHAR(35) NOT NULL,
    date_of_birth    VARCHAR(10),
    gender           VARCHAR(50) CHECK (gender IN ('M', 'F', 'Transgender', 'Gender non-conforming', 'Cisgender', 'Prefer not to answer')),
   CONSTRAINT patients_fkey FOREIGN KEY (triage_id) REFERENCES triage_assessment (triage_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
   CONSTRAINT patients_fkey1 FOREIGN KEY (wait_time_id) REFERENCES ER_wait_time (wait_time_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE phone_number (
    patient_id     VARCHAR(4) NOT NULL,
    phone_number   VARCHAR(12) NOT NULL,
  CONSTRAINT phone_number_pkey PRIMARY KEY (patient_id, phone_number),
  CONSTRAINT phone_number_fkey FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE email (
    patient_id     VARCHAR(4) NOT NULL,
    email          VARCHAR(65) NOT NULL CHECK (email LIKE '%@%'),
  CONSTRAINT email_fkey FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE treatments (
	treatment_id	VARCHAR(5)	PRIMARY KEY,
	patient_id		VARCHAR(4),
	timestamp		TIMESTAMP, /*2025-04-17 14:30:00*/
	procedure_type	TEXT,
	outcome			TEXT,
  CONSTRAINT treatments_fkey FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
  	ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE insurance_status (
	insurance_id	 VARCHAR(4) PRIMARY KEY,
	patient_id		 VARCHAR(4),
	insurance_status VARCHAR(8)	 CHECK (insurance_status IN ('ACTIVE', 'NOT ACTIVE')),
  CONSTRAINT insurance_status_fkey FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
  	ON DELETE CASCADE
	ON UPDATE CASCADE
);

ALTER TABLE insurance_status
ALTER COLUMN insurance_status TYPE VARCHAR(12)

CREATE TABLE patient_treatment (
	patient_id			VARCHAR(4),
	medical_staff_id	VARCHAR(6),
  CONSTRAINT patient_treatment_pkey PRIMARY KEY (patient_id, medical_staff_id),
  CONSTRAINT patient_traetement_fkey FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  CONSTRAINT patient_treatment_fkey1 FOREIGN KEY (medical_staff_id) REFERENCES medical_staff (medical_staff_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);

CREATE TABLE beds (
	bed_number		INTEGER	  PRIMARY KEY,
	patient_id		VARCHAR(4),
	bed_status		VARCHAR (20)	CHECK (bed_status IN ('avaliable', 'being cleaned', 'out of service')),
  CONSTRAINT bed_fkey FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
    ON DELETE CASCADE
	ON UPDATE CASCADE
);

ALTER TABLE beds
DROP CONSTRAINT beds_bed_status_check;

ALTER TABLE beds
ADD CONSTRAINT bed_status_check CHECK (bed_status IN ('available', 'occupied', 'under maintenance'));

CREATE TABLE zones (
	zone_number		VARCHAR(15)	 CHECK (zone_number IN( 'Zone 1', 'Zone 2', 'Zone 3', 'Zone 4', 'Zone 5', 'Zone 6', 'Zone 7', 'Zone 8', 'Zone 9', 'Zone 10')) PRIMARY KEY,
	zone_name		VARCHAR(35) CHECK ( zone_name IN ('trauma Bay', 'fast track for minor cases', 'fast track for critical cases', ' acute care', ' intake', 'triage', ' pediatric ER', 'critical care', 'observation', 'behavioral health'))
);

CREATE TABLE nurse_assigned_zones (
	medical_staff_id	VARCHAR(6),
	zone_number			VARCHAR(15),
	bed_number			INTEGER,
  CONSTRAINT nurse_assigned_zones_pkey PRIMARY KEY (medical_staff_id, zone_number, bed_number),
  CONSTRAINT nurse_assigned_zones_fkey FOREIGN KEY (medical_staff_id) REFERENCES medical_staff (medical_staff_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  CONSTRAINT nurse_assigned_zones_fkey1 FOREIGN KEY (zone_number) REFERENCES zones (zone_number)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  CONSTRAINT nurse_assigned_zones_fkey2 FOREIGN KEY (bed_number) REFERENCES beds (bed_number)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);

INSERT INTO ER_wait_time (wait_time_id, check_in_time, triage_complete_time, assigned_bed, start_treatment_time, end_treatment_time, discharged, total_wait_time)
VALUES ('WT001', '12:41:00', '12:50:00', 102, '12:51:00', '14:43:00', '14:45:00', '2hr 4min'),
		('WT002', '11:57:00', '11:59:00', 109, '12:04:00', '13:15:00', '13:52:00', '1hr 55min'),
		('WT003', '13:23:00', '17:47:00', 110, '18:11:00', '18:36:00', '18:45:00', '5hr 23min'),
		('WT004', '12:10:00', '14:07:00', 108, '15:15:00', '15:39:00', '16:10:00', '4hr 00min'),
		('WT005', '10:16:00', '10:36:00', 104, '11:22:00', '12:13:00', NULL, NULL),
		('WT006', '15:06:00', '15:25:00', 106, '15:54:00', '16:47:00', '17:40:00', '2hr 34min'),
		('WT007', '07:47:00', '08:16:00', 101, '09:37:00', '10:49:00', '11:14:00', '3hr 27min'),
		('WT008', '12:37:00', '14:57:00', 107, '15:04:00', '15:40:00', '16:34:00', '3 hr 57min'),
		('WT009', '12:51:00', '13:09:00', 101, '13:19:00', '14:23:00', NULL, NULL),
		('WT010', '09:00:00', '09:11:00', 105, '10:22:00', '11:23:00', '11:43:00', '2hr 43min'),
		('WT011', '14:24:00', '14:37:00', 103, '13:55:00', '15:51:00', '16:28:00', '2hr 4min'),
		('WT012', '09:16:00', '09:37:00', 109, '09:57:00', '10:48:00', NULL, NULL),
		('WT013', '13:05:00', '13:29:00', 105, '14:16:00', '15:07:00', '15:37:00', '2hr 32min'),
		('WT014', '08:18:00', '10:36:00', 108, '11:07:00', '11:55:00', '12:18:00', '4 hr 00min'),
		('WT015', '10:44:00', '11:08:00', 107, '11:53:00', '12:32:00', '13:01:00', '2hr 17min'),
		('WT016', '14:35:00', '14:59:00', 102, '15:35:00', '16:50:00', NULL, NULL),
		('WT017', '13:08:00', '13:36:00', 109, '14:21:00', '15:28:00', '16:16:00', '3hr 8min'),
		('WT018', '10:26:00', '10:40:00', 110, '11:34:00', '12:09:00', '12:31:00', '2hr 05min'),
		('WT019', '08:29:00', '08:52:00', 106, '09:55:00', '10:29:00', NULL, NULL),
		('WT020', '14:21:00', '15:46:00', 104, '16:30:00', '16:55:00', '16:59:00', '2hr 34min'),
		('WT021', '13:18:00', '13:39:00', 103, '14:34:00', '15:45:00', '16:41:00', '3hr 23min'),
		('WT022', '11:35:00', '12:58:00', 109, '13:15:00', '13:41:00', '14:40:00', '3hr 05min'),
		('WT023', '07:39:00', '10:03:00', 105, '10:30:00', '10:35:00', '11:49:00', '4hr 00min'),
		('WT024', '13:25:00', '13:40:00', 101, '14:25:00', '15:02:00', NULL, NULL),
		('WT025', '14:49:00', '17:06:00', 104, '17:53:00', '18:41:00', '19:50:00', '5hr 01min'),
		('WT026', '10:32:00', '14:53:00', 107, '11:43:00', '12:27:00', '13:13:00', '2hr 41min'),
		('WT027', '08:04:00', '08:28:00', 108, '09:01:00', '09:56:00', NULL, NULL);

		
INSERT INTO medical_staff (medical_staff_id, first_name, last_name, contact_number, shift_start, shift_end)
VALUES ('MS001', 'George', 'Clooney', '555-123-1001', '07:00:00', '15:00:00'),
		('MS002', 'Brad', 'Pitt', '555-123-1002', '08:00:00', '16:00:00'),
		('MS003', 'Chris', 'Evans', '555-123-1003', '10:00:00', '18:00:00'),
		('MS004', 'Dwayne', 'Johnson', '555-123-1004', '15:00:00', '23:00:00'),
		('MS005', 'Ryan', 'Reynolds', '555-123-1005', '16:00:00', '00:00:00'),
		('MS006', 'Emma', 'Watson', '555-123-1006', '18:00:00', '02:00:00'),
		('MS007', 'Scarlett', 'Johansson', '555-123-1007', '23:00:00', '07:00:00'),
		('MS008', 'Taylor', 'Swift', '555-123-1008', '07:00:00', '15:00:00'),
		('MS009', 'Natalie', 'Portman', '555-123-1009', '08:00:00', '16:00:00'),
		('MS010', 'Zendaya', 'Coleman', '555-123-1010', '10:00:00', '18:00:00'),
		('MS011', 'Beyonce', 'Knowles', '555-123-1011', '15:00:00', '23:00:00'),
		('MS012', 'Gal', 'Gadot', '555-123-1012', '18:00:00', '02:00:00'),
		('MS013', 'Anthony', 'Mackie', '555-123-1013', '07:00:00', '15:00:00'),
		('MS014', 'Mark', 'Ruffalo', '555-123-1014', '15:00:00', '23:00:00'),
		('MS015', 'Jennifer', 'Lawrence', '555-123-1015', '08:00:00', '16:00:00'),
		('MS016', 'Anne', 'Hathaway', '555-123-1016', '10:00:00', '18:00:00'),
		('MS017', 'Viola', 'Davis', '555-123-1017', '16:00:00', '00:00:00'),
		('MS018', 'Florence', 'Pugh', '555-123-1018', '18:00:00', '02:00:00'),
		('MS019', 'Daniel', 'Kaluuya', '555-123-1019', '23:00:00', '07:00:00'),
		('MS020', 'Jessica', 'Chastain', '555-123-1020', '07:00:00', '15:00:00');


INSERT INTO NURSES (medical_staff_id, first_name, last_name, contact_number, shift_start, shift_end)
VALUES 	('MS001', 'George', 'Clooney', '555-123-1001', '07:00:00', '15:00:00'),  
		('MS002', 'Brad', 'Pitt', '555-123-1002', '08:00:00', '16:00:00'),      
		('MS006', 'Emma', 'Watson', '555-123-1006', '18:00:00', '02:00:00'),    
		('MS007', 'Scarlett', 'Johansson', '555-123-1007', '23:00:00', '07:00:00'), 
		('MS008', 'Taylor', 'Swift', '555-123-1008', '07:00:00', '15:00:00'),   
		('MS009', 'Natalie', 'Portman', '555-123-1009', '08:00:00', '16:00:00'), 
		('MS011', 'Beyonce', 'Knowles', '555-123-1011', '15:00:00', '23:00:00'),
		('MS012', 'Gal', 'Gadot', '555-123-1012', '18:00:00', '02:00:00'),
		('MS013', 'Anthony', 'Mackie', '555-123-1013', '07:00:00', '15:00:00'),
		('MS015', 'Jennifer', 'Lawrence', '555-123-1015', '08:00:00', '16:00:00'),
		('MS016', 'Anne', 'Hathaway', '555-123-1016', '10:00:00', '18:00:00'),
		('MS017', 'Viola', 'Davis', '555-123-1017', '16:00:00', '00:00:00');
		

INSERT INTO doctors (medical_staff_id, first_name, last_name, contact_number, shift_start, shift_end, specialty)
VALUES ('MS003', 'Chris', 'Evans', '555-123-1003', '10:00:00', '18:00:00', 'Emergency Medicine'),
		('MS004', 'Dwayne', 'Johnson', '555-123-1004', '15:00:00', '23:00:00', 'Orthopedics'),
		('MS005', 'Ryan', 'Reynolds', '555-123-1005', '16:00:00', '00:00:00', 'Cardiology'),
		('MS010', 'Zendaya', 'Coleman', '555-123-1010', '10:00:00', '18:00:00', 'Emergency Medicine'),
		('MS014', 'Mark', 'Ruffalo', '555-123-1014', '15:00:00', '23:00:00', 'Trauma Surgery'),
		('MS018', 'Florence', 'Pugh', '555-123-1018', '18:00:00', '02:00:00', 'Critical Care'),
		('MS019', 'Daniel', 'Kaluuya', '555-123-1019', '23:00:00', '07:00:00', 'Behavioral Health'),
		('MS020', 'Jessica', 'Chastain', '555-123-1020', '07:00:00', '15:00:00', 'Pediatric Emergency');

INSERT INTO triage_assessment ( triage_id, wait_time_id, medical_staff_id, time_of_assessment, triage_level, priority_status, reason_at_er)
VALUES ('TR001', 'WT001', 'MS001', '12:30:00',  'ESI LEVEL 1', 'critical', 'Coughing or vomiting blood'),
		('TR002', 'WT002', 'MS008', '11:50:00', 'ESI LEVEL 1', 'critical', 'head laceration and uncontrolled bleeding'),
		('TR003', 'WT003', 'MS002', '16:50:00', 'ESI LEVEL 4', 'low priority', 'ear infection'),
		('TR004', 'WT004', 'MS009', '13:07:00', 'ESI LEVEL 5', 'non-urgent', 'rash'),
		('TR005', 'WT005', 'MS013', '10:30:00', 'ESI LEVEL 2', 'high priority', 'possible stroke'),
		('TR006', 'WT006', 'MS015', '15:15:00', 'ESI LEVEL 2', 'high priority', 'chest pains'),
		('TR007', 'WT007', 'MS016', '08:00:00', 'ESI LEVEL 4', 'low priority', 'cough'),
		('TR008', 'WT008', 'MS001', '14:45:00', 'ESI LEVEL 5', 'non-urgent', 'dizzyness'),
		('TR009', 'WT009', 'MS002', '13:00:00', 'ESI LEVEL 3', 'moderate priority', 'schizophrenia behavioral episode'),
		('TR010', 'WT010', 'MS008', '09:00:00', 'ESI LEVEL 5', 'non-urgent', 'cold sypmtoms'),
		('TR011', 'WT011', 'MS009', '14:24:00', 'ESI LEVEL 4', 'low priority', 'Fever and cough'),
		('TR012', 'WT012', 'MS006', '09:15:00', 'ESI LEVEL 2', 'high priority', 'fell down set of stairs, lacerations and tenderness'),
		('TR013', 'WT013', 'MS011', '13:04:00', 'ESI LEVEL 3', 'moderate priority', 'alergic reaction, shortness of breath'),
		('TR014', 'WT014', 'MS013', '10:28:00', 'ESI LEVEL 4', 'low priority', 'fell off scooter, lacerations on hands, possible broken wrist'),
		('TR015', 'WT015', 'MS015', '10:55:00', 'ESI LEVEL 2', 'high priority', 'High blood pressure and pregnant'),
		('TR016', 'WT016', 'MS016', '14:34:00', 'ESI LEVEL 1', 'critical', 'overdose'),
		('TR017', 'WT017', 'MS011', '13:04:00', 'ESI LEVEL 1', 'critical', 'car accident, unconscious on arrival'),
		('TR018', 'WT018', 'MS011', '10:55:00', 'ESI LEVEL 2', 'high priority', 'abdominal pain'),
		('TR019', 'WT019', 'MS017', '08:07:00', 'ESI LEVEL 3', 'moderate priority', 'post-surgery pain and inflammation'),
		('TR020', 'WT020', 'MS017', '15:15:00', 'ESI LEVEL 5', 'non-urgent', 'migraine'),
		('TR021', 'WT021', 'MS011', '13:34:00', 'ESI LEVEL 3', 'moderate priority', 'Back pain radiating to legs'),
		('TR022', 'WT022', 'MS016', '12:30:00', 'ESI LEVEL 4', 'low priority', 'flu symptoms'),
		('TR023', 'WT023', 'MS006', '09:48:00', 'ESI LEVEL 1', 'critical', 'bar fight, unconscious on arrival and seizures'),
		('TR024', 'WT024', 'MS012', '13:25:00', 'ESI LEVEL 1', 'critical', 'suicide attempt by hanging, unconscious on arrival'),
		('TR025', 'WT025', 'MS006', '16:45:00', 'ESI LEVEL 4', 'low priority', 'tooth ache'),
		('TR026', 'WT026', 'MS012', '14:30:00', 'ESI LEVEL 3', 'moderate priority', 'abdominal pain, vomiting, history of kidney stones'),
		('TR027', 'WT027', 'MS006', '08:00:00', 'ESI LEVEL 1', 'critical', 'hit by car while crossing street to get ball');

INSERT INTO transfer (transfer_id, wait_time_id, receiving_doctor, transfer_time, reason_for_transfer)
VALUES ('11111', 'WT002', 'Brown', '13:52:00', 'No avalible surgens for uncotrolled bleeding'),
		('22222', 'WT006', 'Smith', '17:40:00', 'Family request'),
		('33333', 'WT015', 'Johnson', '13:01:00', 'No avalible OBGYN for pregnant patient'),
		('44444', 'WT018', 'Williams', '14:30:00', 'No avalible doctors to treat patient in reasonable amount of time');
		

INSERT INTO patients (patient_id, triage_id, wait_time_id, first_name, last_name, date_of_birth, gender)
VALUES ('P001', 'TR001', 'WT001', 'John', 'Deer', '09/22/1979', 'M'),
		('P002', 'TR002', 'WT002', 'Jane', 'Doe', '11/15/1985', 'F'),
		('P003', 'TR003', 'WT003', 'Mary', 'Smith', '01/30/2014', 'Prefer not to answer'),
		('P004', 'TR004', 'WT004', 'Michael', 'Johnson', '03/12/1988', 'M'),
		('P005', 'TR005', 'WT005', 'Emily', 'Davis', '05/25/1939', 'F'),
		('P006', 'TR006', 'WT006', 'David', 'Brown', '07/18/1960', 'M'),
		('P007', 'TR007', 'WT007', 'Sarah', 'Wilson','09/10/2020','F'),
		('P008','TR008','WT008','Chris','Garcia','02/14/1995','Prefer not to answer'),
		('P009','TR009','WT009','Jessica','Martinez','04/20/1999','F'),
		('P010','TR010','WT010','Daniel','Hernandez','06/30/1991','Cisgender'),
		('P011','TR011','WT011','Sophia','Lopez','08/05/2024','F'),
		('P012','TR012','WT012','James','Gonzalez','10/11/1936','M'),
		('P013','TR013','WT013','Olivia','Perez','12/22/1984','F'),
		('P014','TR014','WT014','William','Wilson', '01/15/2010', 'M'),
		('P015', 'TR015', 'WT015', 'Ava', 'Anderson', '03/28/1993', 'Prefer not to answer'),
		('P016', 'TR016', 'WT016', 'Liam', 'Thomas', '05/30/1981', 'M'),
		('P017', 'TR017', 'WT017', 'Isabella', 'Taylor', '07/14/2006', 'F'),
		('P018', 'TR018', 'WT018', 'Noah', 'Moore', '09/02/1985', 'M'),
		('P019', 'TR019', 'WT019', 'Mia', 'Jackson', '11/19/1990', 'Transgender'),
		('P020', 'TR020', 'WT020', 'Ethan', 'Martin', '01/25/1989', 'M'),
		('P021', 'TR021', 'WT021', 'Charlotte', 'Lee', '03/10/1950', 'F'),
		('P022', 'TR022', 'WT022', 'Aiden', 'Harris', '05/18/2012', 'M'),
		('P023', 'TR023', 'WT023', 'Amelia', 'Clark', '07/27/1987', 'F'),
		('P024', 'TR024', 'WT024', 'Lucas', 'Lewis', '09/15/1996', 'Gender non-conforming'),
		('P025', 'TR025', 'WT025', 'Harper', 'Walker', '11/22/1990', 'F'),
		('P026', 'TR026', 'WT026', 'Mason', 'Hall', '01/30/1988', 'M'),
		('P027', 'TR027', 'WT027', 'Ella', 'Allen','03/12/2022','F');

INSERT INTO phone_number (patient_id, phone_number)
VALUES ('P001', '484-123-1001'),
		('P002', '610-553-1092'),
		('P003', '484-823-4503'),
		('P004', '609-863-1994'),
		('P005', '484-903-1005'),
		('P006', '555-183-1306'),
		('P007', '484-129-1657'),
		('P008', '610-623-4908'),
		('P009', '885-173-7765'),
		('P010', '555-993-3333'),
		('P011', '610-973-1987'),
		('P012', '484-443-1862'),
		('P013', '609-109-1334'),
		('P014', '610-123-5634'),
		('P015', '610-733-2766'),
		('P016', '484-883-1076'),
		('P017', '335-154-1247'),
		('P018', '484-003-1998'),
		('P019', '610-333-1749'),
		('P020', '610-985-2880'),
		('P021', '484-118-5555'),
		('P022', '484-377-8442'),
		('P023', '484-098-0003'),
		('P024', '609-223-1997'),
		('P025', '610-666-1015'),
		('P026', '610-754-1936'),
		('P027', '484-889-7557');

INSERT INTO email (patient_id, email)
VALUES ('P001', 'hyyet@aol.com'),
		('P002', 'tfee@protonmail.com'),
		('P003', 'CodingisAwesome@outlook.com'),
		('P004', 'Databases@protonmail.com'),
		('P005', 'YoGabaGaba@yahoo.com'),
		('P006', 'skaterboi22@outlook.com'),
		('P007', 'pupperlover77@aol.com'),
		('P008', 'dragonqueen@protonmail.com'),
		('P009', 'xXSilentWolfXx@aol.com'),
		('P010', 'bubblewrapjoy@protonmail.com'),
		('P011', 'readmorebooks@yahoo.com'),
		('P012', 'nightowl_3am@outlook.com'),
		('P013', 'claymore42@gmail.com'),
		('P014', 'guitarhero88@gmail.com'),
		('P015', 'ilovecoding123@aol.com'),
		('P016', 'thematrixisreal@yahoo.com'),
		('P017', 'debugme@protonmail.com'),
		('P018', 'sunshine_smiles@protonmail.com'),
		('P019', 'no1coder@aol.com'),
		('P020', 'fasttrackfan@protonmail.com'),
		('P021', 'javamaster@gmail.com'),
		('P022', 'bughunter@aol.com'),
		('P023', 'l33tdev@outlook.com'),
		('P024', 'secureloginz@yahoo.com'),
		('P025', 'username_not_taken@protonmail.com'),
		('P026', 'cheeselover@aol.com'),
		('P027', 'logicguru@outlook.com');

INSERT INTO treatments (treatment_id, patient_id, timestamp, procedure_type, outcome)
VALUES ('T001', 'P001', '2025-04-17 12:51:00', 'upper endoscopy', 'identified internal bleeding, sent to surgery, patient time of death 14:30:00'),
		('T003', 'P003', '2025-04-17 18:11:00', 'ear exam', 'infected ear drum, prescribed antibiotics and patient discharged'),
		('T004', 'P004', '2025-04-17 15:15:00', 'external exam', 'given topical cream for rash and patient discharged'),
		('T005', 'P005', '2025-04-17 11:22:00', 'MRI', 'brain bleed detected, sent to surgery'),
		('T007', 'P007', '2025-04-17 09:37:00', 'external exam', 'no fluid heard in lungs, given cough syrup and discharged'),
		('T008', 'P008', '2025-04-17 14:04:00', 'exam and head CT', 'No issues detected, patient discharged'),
		('T009', 'P009', '2025-04-17 13:19:00', 'Reviewed medications and consulted with psychologist', 'admitted to behavioral health unit'),
		('T010', 'P010', '2025-04-17 10:22:00', 'external exam, tested for flu', 'results negative, patient discharged'),
		('T011', 'P011', '2025-04-17 13:55:00', 'external exam, viral test given for Covid 19', 'test results positive, patient discharged with instructions to isolate'),
		('T012', 'P012', '2025-04-17 09:57:00', 'CT scan, MRI Scan', 'Fractures found and brain bleed detected, sent to surgery'),
		('T013', 'P013', '2025-04-17 14:16:00', 'external exam and recent history given', 'given allergy medication, patient discharged'),
		('T014', 'P014', '2025-04-17 09:07:00', 'CT scan on wrist and cleaned up wounds','CT scan showed no fractures, patient discharged with splint and pain medication'),
		('T016', 'P016', '2025-04-17 15:35:00', 'Started CPR and given Noxolone','patient was revived and sent to ICU for further treatment'),
		('T017', 'P017', '2025-04-17 14:21:00', 'CT Scan, MRI and life saving measures given in ER', 'Patient time of death 16:16:00'),
		('T019', 'P019', '2025-04-17 09:55:00', 'MRI and blood test given','found tear in right aortial valve, sent to surgery'),
		('T020', 'P020', '2025-04-18 15:30:00', 'external exam given','patient given motrin and discharged'),
		('T021', 'P021', '2025-04-18 14:34:00', 'MRI and ultrasound given','slipped disk found, patient referred to ortho for follow up, patient discharged'),
		('T022', 'P022', '2025-04-18 13:15:00', 'external exam given, viral test given for Covid 19 and flu','test results normal, patient told to drink fluids and take tylenol as needed, patient discharged'),
		('T023', 'P023', '2025-04-18 10:30:00', 'X-Ray, CT scan, MRI','brain bleed detected, bleed in kidneys, fractured right arm, sent to surgery'),
		('T024', 'P024', '2025-04-18 14:25:00', 'CPR administered, shocked heart 4 times', 'patient was revived and sent to ICU for further treatment'),
		('T025', 'P025', '2025-04-18 17:53:00', 'dental exam given', 'patient needs root canal, given pain medication and referred to dentist, patient discharged'),
		('T026', 'P026', '2025-04-18 11:43:00', 'Ultrasound of kidneys given', 'kidney stone found, given pain medication and referred to urologist, patient discharged'),
		('T027', 'P027', '2025-04-18 09:01:00', 'CT Scan. MRI, CPR administered, shocked heart 6 times', 'brian bleed detected, broken ribs, broken right femur, sent to surgery');

INSERT INTO insurance_status (insurance_id, patient_id, insurance_status)
VALUES ('IS01', 'P001', 'ACTIVE'),
		('IS02', 'P002', 'ACTIVE'),
		('IS03', 'P003', 'NOT ACTIVE'),
		('IS04', 'P004', 'ACTIVE'),
		('IS05', 'P005', 'ACTIVE'),
		('IS06', 'P006', 'ACTIVE'),
		('IS07', 'P007', 'ACTIVE'),
		('IS08', 'P008', 'NOT ACTIVE'),
		('IS09', 'P009', 'ACTIVE'),
		('IS10', 'P010', 'ACTIVE'),
		('IS11', 'P011', 'NOT ACTIVE'),
		('IS12', 'P012', 'ACTIVE'),
		('IS13', 'P013', 'ACTIVE'),
		('IS14', 'P014', 'NOT ACTIVE'),
		('IS15', 'P015', 'NOT ACTIVE'),
		('IS16', 'P016', 'ACTIVE'),
		('IS17', 'P017', 'ACTIVE'),
		('IS18', 'P018', 'ACTIVE'),
		('IS19', 'P019', 'ACTIVE'),
		('IS20', 'P020', 'NOT ACTIVE'),
		('IS21', 'P021', 'NOT ACTIVE'),
		('IS22', 'P022', 'ACTIVE'),
		('IS23', 'P023', 'NOT ACTIVE'),
		('IS24', 'P024', 'ACTIVE'),
		('IS25', 'P025', 'NOT ACTIVE'),
		('IS26', 'P026', 'NOT ACTIVE'),
		('IS27', 'P027', 'ACTIVE');

INSERT INTO patient_treatment (patient_id, medical_staff_id)
VALUES ('P001', 'MS014'),
		('P003', 'MS020'),
		('P004', 'MS010'),
		('P005', 'MS003'),
		('P006', 'MS004'),
		('P007', 'MS020'),
		('P008', 'MS003'),
		('P009', 'MS019'),
		('P010', 'MS003'),
		('P011', 'MS010'),
		('P012', 'MS014'),
		('P013', 'MS011'),
		('P014', 'MS013'),
		('P016', 'MS016'),
		('P017', 'MS011'),
		('P019', 'MS017'),
		('P020', 'MS017'),
		('P021', 'MS011'),
		('P022', 'MS016'),
		('P023', 'MS006'),
		('P024', 'MS012'),
		('P025', 'MS006'),
		('P026', 'MS012'),
		('P027', 'MS006');
		
INSERT INTO beds (bed_number, patient_id, bed_status)
VALUES (101, 'P001', 'occupied'),
		(102, 'P003', 'occupied'),
		(103, 'P004', 'occupied'),
		(104, 'P005', 'occupied'),
		(105, 'P007', 'occupied'),
		(106, 'P008', 'occupied'),
		(107, 'P009', 'occupied'),
		(108, 'P010', 'occupied'),
		(109, 'P011', 'occupied'),
		(110, 'P012', 'occupied'),
		(111, 'P013', 'occupied'),
		(112, 'P014', 'occupied'),
		(113, 'P016', 'occupied'),
		(114, 'P017', 'occupied'),
		(115, 'P019', 'occupied'),
		(116, 'P020', 'occupied'),
		(117, 'P021', 'occupied'),
		(118, 'P022', 'occupied'),
		(119, 'P023', 'occupied'),
		(120, 'P024', 'occupied'),
		(121, 'P025', 'occupied'),
		(122, 'P026', 'occupied'),
		(123, 'P027', 'occupied'),
		(124, NULL, 'available'),
		(125, NULL, 'available'),
		(126, NULL, 'under maintenance'),
		(127, NULL, 'under maintenance'),
		(128, NULL, 'under maintenance');

INSERT INTO zones (zone_number, zone_name)
VALUES ('Zone 1', 'trauma Bay'),
		('Zone 2', 'fast track for minor cases'),
		('Zone 3', 'fast track for critical cases'),
		('Zone 4', ' acute care'),
		('Zone 5', ' intake'),
		('Zone 6', 'triage'),
		('Zone 7', ' pediatric ER'),
		('Zone 8', 'critical care'),
		('Zone 9', 'observation'),
		('Zone 10', 'behavioral health');

INSERT INTO nurse_assigned_zones (medical_staff_id, zone_number, bed_number)
VALUES('MS001', 'Zone 1', 101),
		('MS002', 'Zone 2', 102),
		('MS006', 'Zone 3', 103),
		('MS007', 'Zone 4', 104),
		('MS008', 'Zone 5', 105),
		('MS009', 'Zone 6', 106),
		('MS011', 'Zone 7', 107),
		('MS012', 'Zone 8', 108),
		('MS013', 'Zone 9', 109),
		('MS015', 'Zone 10', 110),
		('MS016', 'Zone 1', 111),
		('MS017', 'Zone 2', 112),
		('MS001', 'Zone 3', 113),
		('MS002', 'Zone 4', 114),
		('MS006', 'Zone 5', 115),
		('MS007', 'Zone 6', 116),
		('MS008', 'Zone 7', 117),
		('MS009', 'Zone 8', 118),
		('MS011', 'Zone 9', 119),
		('MS012', 'Zone 10', 120),
		('MS013', 'Zone 1', 121),
		('MS015', 'Zone 2', 122),
		('MS016', 'Zone 3', 123),
		('MS017', 'Zone 4', 124),
		('MS001', 'Zone 5', 125);

--UPDATE DELETE STATEMENTS
		
-- updating patient who got a new email
UPDATE email
SET email = 'newemail@example.com'
WHERE patient_id = 'P003';

--updating nurse MS002 to a new zone
UPDATE nurse_assigned_zones
SET zone_number = 'Zone 5'
WHERE medical_staff_id = 'MS002'AND bed_number = 102;

-- Updating bed status after discharge
UPDATE beds
SET bed_status = 'under maintenance'
WHERE bed_number = 101;

-- Deleting transferred patient who no longer needs a bed
DELETE FROM patients
WHERE patient_id = 'P002';

--QUERIES

-- Shows first and last names of all patients and thier insurance status
-- this can be helpful with hospital staff in charge of checking patients, knowing if they have valid insurance or not, and for hospital staff that bills thier insurance. 
-- could also be a part of understanding how patients with insurance are treated versus patients without insurance, the first step in knowing which patients had insurance and which did not.
SELECT p.first_name, p.last_name, i.insurance_status
FROM patients p
JOIN insurance_status i ON p.patient_id = i.patient_id;

-- List all beds, their status, and the zone they are assigned to.
-- This can help staff identify available beds across different care areas, ensuring efficient patient placement and resource allocation.
SELECT b.bed_number, b.bed_status, z.zone_name
FROM beds b
JOIN nurse_assigned_zones nz ON b.bed_number = nz.bed_number
JOIN zones z ON nz.zone_number = z.zone_number;

-- Retrieves each triage assessment, the priority status, and the name of the nurse or medical staff who performed the assessment.
-- This can help track which medical staff member conducted each patient’s triage assessment and what the priority level was for each patient.
SELECT t.triage_id, t.priority_status, m.first_name, m.last_name
FROM triage_assessment t
JOIN medical_staff m ON t.medical_staff_id = m.medical_staff_id;

-- Shows first and last name of patients who were transfered, what the reason of the transfer was and thier priority status (critical, high priority, low priority etc.)
-- This could help ER managers review whether the right patients were transferred and help with getting more staff hired if there are constant transfers in certian areas. 
SELECT p.first_name, p.last_name, t.reason_for_transfer, ta.priority_status
FROM transfer t
JOIN ER_wait_time wt ON t.wait_time_id = wt.wait_time_id
JOIN patients p ON p.wait_time_id = wt.wait_time_id
JOIN triage_assessment ta ON p.triage_id = ta.triage_id;


--This procedure allows you to delete a patient from the patients table by entering their patient ID.
CREATE OR REPLACE PROCEDURE delete_patient_by_id(IN input_patient_id VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM patients
    WHERE patient_id = input_patient_id;
END;
$$;
-- calling procedure
CALL delete_patient_by_id('P005');

-- This is a trigger will notifiy someone if a patients insurance changes from active to not active. 
--create the function
CREATE OR REPLACE FUNCTION notify_insurance_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.insurance_status = 'NOT ACTIVE' THEN
        RAISE NOTICE 'Patient % insurance status is now NOT ACTIVE.', NEW.patient_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--create the trigger
--code automatically alerts staff with a message whenever a patient's insurance status is updated to "NOT ACTIVE" in the database.
CREATE TRIGGER insurance_status_alert
AFTER UPDATE ON insurance_status
FOR EACH ROW
WHEN (OLD.insurance_status IS DISTINCT FROM NEW.insurance_status)
EXECUTE FUNCTION notify_insurance_status_change();

-- counts how many patients fall under a certian priority status
-- can be helpful in showing hospital how many patients in a particular priority status they have, for staffing purposes
SELECT priority_status, COUNT(*) AS number_of_patients
FROM triage_assessment
GROUP BY priority_status;

--this is a view that shows the patient id, first name, last name, priority status and reason for being in the er of all critical patients
--this can be helpful to quickly show hospital staff all critical patients instead of have to sort through all patients. 
CREATE VIEW critical_patients_view AS
SELECT  p.patient_id, p.first_name, p.last_name, ta.priority_status, ta.reason_at_er
FROM patients p
JOIN triage_assessment ta ON p.triage_id = ta.triage_id
WHERE ta.priority_status = 'critical';

SELECT * FROM critical_patients_view;









