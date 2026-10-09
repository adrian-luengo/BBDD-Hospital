CREATE OR REPLACE VIEW vista_medicamentos_prescritos AS
SELECT 
    p.ssn AS paciente_id, 
    m.code AS medicamento_codigo, 
    m.name AS medicamento_nombre, 
    m.brand AS medicamento_marca, 
    p.name AS paciente_nombre, 
    pr.date AS fecha_prescripcion, 
    ph.name AS doctor_nombre 
FROM prescribes pr 
JOIN medication m ON pr.medicationid = m.code
JOIN patient p ON pr.patientid = p.ssn
JOIN physician ph ON pr.physicianid = ph.employeeid;

CREATE USER 'user_view' IDENTIFIED BY 'user123';
    GRANT SELECT ON hospital_management_system.vista_medicamentos_prescritos TO 'user_view';
    USE hospital_management_system;