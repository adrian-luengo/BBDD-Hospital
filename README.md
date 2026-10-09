
## 📖 Descripción

Práctica sobre el diseño y la explotación de una base de datos relacional para un **sistema de gestión hospitalaria** (`hospital_management_system`, MySQL). Cubre el ciclo completo: modelado conceptual, paso a tablas, consultas y programación SQL avanzada, y acceso desde Java para exportar datos a CSV y XML.

La práctica se divide en tres apartados:

1. **Diseño de la base de datos** (modelo Entidad-Relación y paso a tablas)
2. **SQL** (consultas, triggers, funciones y procedimientos almacenados)
3. **Programación y ficheros** (vistas, permisos y exportación con Java/JDBC)

---

## 🗂️ Contenido

### Apartado 1 – Diseño

- **Modelo Entidad-Relación (notación Chen)** con entidades fuertes (Paciente, Doctor, Personal de enfermería, Personal de farmacología, TIGA, Departamento, Laboratorio, Medicamento, Bloque, Tipo de procedimiento, Habitación, Cabina de distribución, Sala de oncología) y entidades débiles (Cita/Consulta, Estancia, Máquina, Quimio), junto con sus 27 relaciones y cardinalidades.
- **Semántica no contemplada** en el modelo: caducidad de certificaciones, exclusividad de laboratorios para oncología, aforo dinámico de salas y lógica de recalibración de máquinas.
- **Dominios** de las entidades `Paciente`, `Estancia` y `Cita` (tipo de dato, restricciones y descripción).
- **Paso a tablas** (modelo relacional).

> Los diagramas están hechos con [draw.io](https://app.diagrams.net/) y se incluyen como imagen junto al resto de documentos de la carpeta.

### Apartado 2 – SQL

| Apartado | Descripción |
|---|---|
| **b** | Doctores de *General Medicine* que han recetado medicamentos en 2023 o 2024 |
| **c** | Pacientes con el ingreso más largo y más corto (habitación, planta, bloque y duración) |
| **d** | `UPDATE` que marca medicamentos como *Possible discontinuation* si no se han recetado en los últimos 2 años en *General Medicine* |
| **e** | Nº de procedimientos, coste total y coste medio por doctor |
| **f** | Doctores que han realizado todos los procedimientos con coste > 5000 y más de 3 en total |
| **g** | Enfermeros siempre asignados al mismo bloque/piso y que siempre han trabajado con el mismo doctor |
| **h** | Por medicamento: veces prescrito, doctor(es) que más lo recetan y dosis media |
| **i** | Medicamentos prescritos por todos los doctores de más de un departamento |
| **j** | **Trigger** `check_certification`: solo permite programar intervenciones a doctores con certificación válida y vigente |
| **k** | Cambio de política de borrado de pacientes (`ON DELETE CASCADE`) + **trigger** `check_delete_patient` que impide borrar pacientes con actividad reciente (últimos 3 años) o citas futuras |
| **l** | **Función** `total_cost_patient`: coste total de los procedimientos de un paciente |
| **m** | **Función** `calc_TO_stay_cost`: coste de una estancia según tipo de habitación (ICU 500 €/día, Single 300 €/día, Double 150 €/día, resto 100 €/día) |
| **n** | **Procedimiento** `physician_report`: informe de texto con los pacientes atendidos por un doctor y sus medicamentos en un rango de fechas |

### Apartado 3 – Programación y ficheros

1. **Vista** `vista_medicamentos_prescritos`: código, nombre y marca del medicamento, paciente, fecha de prescripción y doctor.
2. **Permisos**: usuario `user_view` con permiso `SELECT` únicamente sobre la vista.
3. **`ExportarPacientesCSV.java`**: exporta a CSV las prescripciones de un paciente (por JDBC).
4. **`ExportarPacientesXML.java`**: exporta a XML las prescripciones de un paciente (por JDBC).

---

## 🛠️ Tecnologías

- **MySQL** (SQL, triggers, funciones y procedimientos almacenados)
- **Java** + **JDBC** (MySQL Connector/J, gestionado con Maven)
- **draw.io** (diagramas E-R y paso a tablas)

---

## 🚀 Cómo ejecutarlo

### Requisitos

- MySQL 8.x
- JDK 11 o superior
- Maven

### Base de datos

1. Crea la base de datos y carga el script con las tablas y los datos:
   ```sql
   CREATE DATABASE hospital_management_system;
   USE hospital_management_system;
   SOURCE ruta/al/script.sql;
   ```
2. Ejecuta las consultas, triggers, funciones y procedimientos del apartado 2 sobre esa base de datos.
3. Crea la vista y el usuario del apartado 3.

### Programas Java

1. Revisa las credenciales y la URL de conexión en las constantes `URL`, `USER` y `PASSWORD` de cada clase.
2. Indica el identificador del paciente en la variable `idPaciente` del `main`.
3. Compila y ejecuta:
   ```bash
   mvn compile
   mvn exec:java -Dexec.mainClass="mysql.ExportarPacientesCSV"
   mvn exec:java -Dexec.mainClass="mysql.ExportarPacientesXML"
   ```
4. Se generará `paciente_<id>.csv` o `paciente_<id>.xml` en el directorio de ejecución.

---

## 📁 Estructura sugerida del repositorio

```
.
├── README.md
├── docs/
│   ├── BBDD_3.docx              # Memoria de la práctica
│   ├── modelo_entidad_relacion.png
│   └── paso_a_tablas.png
├── sql/
│   ├── consultas.sql            # Apartado 2 (b–n)
│   └── vista_y_permisos.sql     # Apartado 3 (vista y usuario)
└── java/
    └── src/main/java/mysql/
        ├── ExportarPacientesCSV.java
        └── ExportarPacientesXML.java
```

---

## 📝 Licencia y uso académico

Trabajo realizado con fines académicos en la UPM. Si lo consultas como referencia, te recomendamos no copiarlo directamente en tus propias entregas.
