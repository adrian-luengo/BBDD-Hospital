-- APARTADO B
SELECT P.name AS Doctor_Name, M.name AS Medication_Name, PR.date AS Date_Prescribed  

FROM physician P  

JOIN affiliated_with A ON P.employeeid = A.physicianid JOIN department D ON A.departmentid = D.departmentid  

JOIN prescribes PR ON P.employeeid = PR.physicianid  

JOIN medication M ON PR.medicationid = M.code  

WHERE D.name = 'General Medicine' AND (YEAR(STR_TO_DATE(PR.date, '%d/%m/%Y')) IN (2023, 2024) ); 


-- APARTADO C
SELECT P.name AS Nombre_Paciente, R.roomnumber AS Numero_Habitacion, R.blockfloorid AS Piso, R.blockcodeid AS Bloque, DATEDIFF(STR_TO_DATE(S.end_time, '%d/%m/%Y'), STR_TO_DATE(S.start_time, '%d/%m/%Y')) AS estancia_dias  

FROM patient P  

JOIN stay S ON P.ssn = S.patientid  

JOIN room R ON S.roomid = R.roomnumber  

WHERE  DATEDIFF(STR_TO_DATE(S.end_time, '%d/%m/%Y'), STR_TO_DATE(S.start_time, '%d/%m/%Y')) =  

(SELECT MAX(DATEDIFF(STR_TO_DATE(end_time, '%d/%m/%Y'), STR_TO_DATE(start_time, '%d/%m/%Y'))) FROM stay) 

OR  

DATEDIFF(STR_TO_DATE(S.end_time, '%d/%m/%Y'), STR_TO_DATE(S.start_time, '%d/%m/%Y')) =  
(SELECT MIN(DATEDIFF(STR_TO_DATE(end_time, '%d/%m/%Y'), STR_TO_DATE(start_time, '%d/%m/%Y')))  
    FROM stay 
); 

-- APARTADO D
UPDATE medication SET description = CONCAT(description, ' - Possible discontinuation')  

WHERE description NOT LIKE '%Possible discontinuation%' 

AND code > 0  

AND code NOT IN ( 
    SELECT medicationid FROM ( 
        SELECT DISTINCT PR.medicationid 
        FROM prescribes PR 
        JOIN physician P ON PR.physicianid = P.employeeid 
        JOIN affiliated_with A ON P.employeeid = A.physicianid 
        JOIN department D ON A.departmentid = D.departmentid 
        WHERE  
            D.name = 'General Medicine' 
            AND STR_TO_DATE(PR.date, '%d/%m/%Y') >= DATE_SUB(NOW(), INTERVAL 2 YEAR) 
    ) AS lista_medicamentos_activos 
); 
 
 
 -- APARTADO E
 SELECT P.name AS Nombre_Doctor, COUNT(U.procedureid) AS Total_Procedimientos, SUM(MP.cost) AS Coste_Total, AVG(MP.cost) AS Coste_Promedio 

FROM physician P 

    JOIN undergoes U ON P.employeeid = U.physicianid 

    JOIN medical_procedure MP ON U.procedureid = MP.code 

GROUP BY P.employeeid, P.name 

ORDER BY Total_Procedimientos DESC; 


-- APARTADO F
SELECT name, position 

FROM physician 

WHERE  

    employeeid IN ( 

        SELECT physicianid 

        FROM undergoes 

        GROUP BY physicianid 

        HAVING COUNT(*) > 3 

    ) 

    AND 

    employeeid IN ( 

        SELECT U.physicianid 

        FROM undergoes U 

        JOIN medical_procedure MP ON U.procedureid = MP.code 

        WHERE MP.cost > 5000 

        GROUP BY U.physicianid 

        HAVING COUNT(DISTINCT MP.code) = ( 

            SELECT COUNT(*)  

            FROM medical_procedure  

            WHERE cost > 5000 

        ) 

    ); 
    
    
    
 -- APARTADO G   
    SELECT N.employeeid, N.name 

FROM nurse N 

WHERE N.employeeid IN ( 

        SELECT nurseid 

        FROM on_call 

        GROUP BY nurseid 

        HAVING COUNT(DISTINCT blockfloorid, blockcodeid) = 1 

    ) 

    AND 

    N.employeeid NOT IN ( 

        SELECT assistingnurseid 

        FROM undergoes 

        GROUP BY assistingnurseid 

        HAVING COUNT(DISTINCT physicianid) > 1 

    ); 
    
    
-- APARTADO H   
SELECT M.code AS Codigo,M.name AS Nombre_Medicamento,T.Total_Global AS Total_Veces_Prescrito,P.name AS Nombre_Doctor_Recetado,T.Dosis_Global AS Dosis_Promedio  

FROM medication M  

INNER JOIN prescribes PR ON M.code = PR.medicationid INNER JOIN physician P ON PR.physicianid = P.employeeid  

INNER JOIN (  

SELECT medicationid, COUNT(*) AS Total_Global, AVG(dose) AS Dosis_Global  

FROM prescribes  

GROUP BY medicationid  

) T ON M.code = T.medicationid  

GROUP BY M.code, M.name, P.employeeid, P.name, T.Total_Global, T.Dosis_Global  

HAVING COUNT(*) >= ALL ( SELECT COUNT(*) FROM prescribes PR2 WHERE PR2.medicationid = M.code GROUP BY PR2.physicianid )  

ORDER BY T.Total_Global DESC; 


-- APARTADO I
SELECT m.name 

FROM medication m 

JOIN prescribes p ON m.code = p.medicationid 

WHERE p.physicianid IN ( 

    SELECT physicianid  

    FROM affiliated_with  

    GROUP BY physicianid  

    HAVING COUNT(departmentid) > 1 

) 

GROUP BY m.code, m.name 

HAVING COUNT(DISTINCT p.physicianid) = ( 

    SELECT COUNT(*)  

    FROM ( 

        SELECT physicianid  

        FROM affiliated_with  

        GROUP BY physicianid  

        HAVING COUNT(departmentid) > 1 

    ) AS TotalDoctores 

);
    
    
    
    
-- APARTADO J   
DELIMITER $$  

CREATE TRIGGER check_certification  

BEFORE INSERT ON undergoes  

FOR EACH ROW BEGIN  

DECLARE certificate_count INT;  

SELECT COUNT(*) INTO certificate_count  

FROM trained_in  

	WHERE physicianid = NEW.physicianid 

	 AND treatmentid = NEW.procedureid; 

	 IF certificate_count = 0 THEN  

	SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'Doctor no posee certificación'; 	ELSE  

	SELECT COUNT(*) INTO certificate_count  

	FROM trained_in  

	WHERE physicianid = NEW.physicianid AND treatmentid = New.procedureid 	AND STR_TO_DATE(NEW.date, '%Y-%m-%d') BETWEEN 

	STR_TO_DATE(certificationdate, '%d/%m/%Y')  

	AND STR_TO_DATE(certificationexpires, '%d/%m/%Y');  

	IF certificate_count = 0 THEN  

	SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'Certificación caducada';  

	END IF; 

END IF;  

END $$  

DELIMITER ; 




-- APARTADO K
ALTER TABLE appointments DROP FOREIGN KEY appointments_ibfk_1; ALTER TABLE appointments ADD CONSTRAINT fk_app_patient FOREIGN KEY (patientid) REFERENCES patient(ssn) ON DELETE CASCADE; 

ALTER TABLE prescribes DROP FOREIGN KEY prescribes_ibfk_2; ALTER TABLE prescribes ADD CONSTRAINT fk_pres_patient FOREIGN KEY (patientid) REFERENCES patient(ssn) ON DELETE CASCADE; 

ALTER TABLE stay DROP FOREIGN KEY stay_ibfk_1; ALTER TABLE stay ADD CONSTRAINT fk_stay_patient FOREIGN KEY (patientid) REFERENCES patient(ssn) ON DELETE CASCADE; 

ALTER TABLE undergoes DROP FOREIGN KEY undergoes_ibfk_1; ALTER TABLE undergoes ADD CONSTRAINT fk_under_patient FOREIGN KEY (patientid) REFERENCES patient(ssn) ON DELETE CASCADE; 

 

DELIMITER $$  

CREATE TRIGGER check_delete_patient  

BEFORE DELETE ON patient  

FOR EACH ROW BEGIN  

IF EXISTS (SELECT 1 FROM appointments  

WHERE patientid = OLD.ssn AND STR_TO_DATE(start_dt_time,'%d/%m/%Y') > CURDATE()) THEN  

SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'ERROR: citas futuras'; 

 END IF; 

IF EXISTS  
    (SELECT 1 FROM appointments  
    WHERE patientid = OLD.ssn  
    AND STR_TO_DATE(start_dt_time,'%d/%m/%Y') >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR)) THEN 
    SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'ERROR: citas recientes'; 
END IF; 
 
IF EXISTS  
    (SELECT 1 FROM stay 
    WHERE patientid = OLD.ssn 
    AND STR_TO_DATE(start_time,'%d/%m/%Y') >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR)) THEN 
    SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'ERROR: estancias recientes'; 
END IF; 
 
IF EXISTS  
    (SELECT 1 FROM undergoes 
    WHERE patientid = OLD.ssn 
    AND STR_TO_DATE(date,'%d/%m/%Y') >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR)) THEN 
    SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'ERROR: procedimientos recientes'; 
END IF; 
 
IF EXISTS  
    (SELECT 1 FROM prescribes 
    WHERE patientid = OLD.ssn 
    AND STR_TO_DATE(date,'%d/%m/%Y') >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR)) THEN 
    SIGNAL SQLSTATE '02000' SET MESSAGE_TEXT = 'ERROR: prescripciones recientes'; 
END IF; 
  

END$$ DELIMITER ; 


-- APARTADO L

DELIMITER // 

CREATE FUNCTION total_cost_patient(p_patient_id INT)  

RETURNS INT  

DETERMINISTIC  

BEGIN  

DECLARE total INT;  

SELECT SUM(mp.cost)  

INTO total  

FROM undergoes u  

JOIN medical_procedure mp  

ON u.procedureid = mp.code  

WHERE u.patientid = p_patient_id;  

IF total IS NULL THEN  

set total = 0;  

END IF;  

RETURN total;  

END //  

DELIMITER ; 


-- APARTADO M

DELIMITER $$ CREATE FUNCTION calc_TO_stay_cost(stay_id INT) RETURNS INT DETERMINISTIC BEGIN DECLARE room_type VARCHAR(20); DECLARE daily_cost INT; DECLARE total_days INT; DECLARE total_cost INT; 

SELECT r.roomtype 
INTO room_type 
FROM stay s 
JOIN room r ON s.roomid = r.roomnumber 
WHERE s.stayid = stay_id; 
 
IF room_type = 'ICU' THEN 
    SET daily_cost = 500; 
ELSEIF room_type = 'Single' THEN 
    SET daily_cost = 300; 
ELSEIF room_type = 'Double' THEN 
    SET daily_cost = 150; 
ELSE 
    SET daily_cost = 100; 
END IF; 
 
SELECT DATEDIFF( 
    STR_TO_DATE(end_time, '%d/%m/%Y'), 
    STR_TO_DATE(start_time, '%d/%m/%Y') 
) 
INTO total_days 
FROM stay 
WHERE stayid = stay_id; 
 
SET total_cost = daily_cost * total_days; 
 
RETURN total_cost; 
  

END$$ 

DELIMITER ; 

-- APARTADO N

DELIMITER $$ 

CREATE PROCEDURE physician_report( IN p_physician_id INT, IN p_start_date VARCHAR(10), IN p_end_date VARCHAR(10), OUT p_report TEXT ) 

BEGIN  

DECLARE v_doctor_name VARCHAR(50);  

DECLARE v_patient_name VARCHAR(50);  

DECLARE v_date VARCHAR(10);  

DECLARE v_med TEXT; 

DECLARE done INT DEFAULT 0; 
 
DECLARE cur CURSOR FOR 
    SELECT patient.name, appointments.start_dt_time 
    FROM appointments 
    JOIN patient ON patient.ssn = appointments.patientid 
    WHERE appointments.physicianid = p_physician_id 
    AND STR_TO_DATE(appointments.start_dt_time,'%d/%m/%Y') 
        BETWEEN STR_TO_DATE(p_start_date,'%d/%m/%Y') 
        AND STR_TO_DATE(p_end_date,'%d/%m/%Y') 
    ORDER BY STR_TO_DATE(appointments.start_dt_time,'%d/%m/%Y'); 
 
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1; 
 
SET p_report = ''; 
 
SELECT name INTO v_doctor_name 
FROM physician 
WHERE employeeid = p_physician_id; 
 
SET p_report = CONCAT('INFORME DE ', v_doctor_name, '\n'); 
 
OPEN cur; 
 
read_loop: LOOP 
    FETCH cur INTO v_patient_name, v_date; 
    IF done = 1 THEN 
        LEAVE read_loop; 
    END IF; 
 
    SET p_report = CONCAT(p_report, v_patient_name, ' (', v_date, ')\n'); 
 
    SELECT GROUP_CONCAT(medication.name SEPARATOR ', ') 
    INTO v_med 
    FROM prescribes 
    JOIN medication ON medication.code = prescribes.medicationid 
    WHERE prescribes.physicianid = p_physician_id 
    AND prescribes.patientid = (SELECT ssn FROM patient WHERE name = v_patient_name) 
    AND prescribes.date = v_date; 
 
    IF v_med IS NULL THEN 
        SET p_report = CONCAT(p_report, '# No medications prescribed\n'); 
    ELSE 
        SET p_report = CONCAT(p_report, '# ', v_med, '\n'); 
    END IF; 
 
END LOOP; 
 
CLOSE cur; 
  

END$$ 

DELIMITER ; 