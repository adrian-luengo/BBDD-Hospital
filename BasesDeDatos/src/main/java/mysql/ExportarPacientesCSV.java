package mysql;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ExportarPacientesCSV {


    private static final String URL = "jdbc:mysql://localhost:3306/hospital_management_system?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";    private static final String USER = "root";

    private static final String PASSWORD = "";

    public static void main(String[] args) {
        int idPaciente = 100000002;

        String nombreArchivo = "paciente_" + idPaciente + ".csv";

        System.out.println("Iniciando exportación para el paciente: " + idPaciente);
        exportarMedicamentosPaciente(idPaciente, nombreArchivo);
    }

    public static void exportarMedicamentosPaciente(int idPaciente, String nombreArchivo) {
        String sql = "SELECT medicamento_codigo, medicamento_nombre, medicamento_marca, " +
                "paciente_nombre, fecha_prescripcion, doctor_nombre " +
                "FROM vista_medicamentos_prescritos " +
                "WHERE paciente_id = ?";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
                 PreparedStatement pstmt = conn.prepareStatement(sql);
                 FileWriter fw = new FileWriter(nombreArchivo);
                 PrintWriter pw = new PrintWriter(fw)) {


                pstmt.setInt(1, idPaciente);

                try (ResultSet rs = pstmt.executeQuery()) {

                    pw.println("Codigo,Nombre Medicamento,Marca,Paciente,Fecha,Doctor");

                    boolean hayDatos = false;

                    while (rs.next()) {
                        hayDatos = true;

                        String codigo = rs.getString("medicamento_codigo");
                        String medNombre = rs.getString("medicamento_nombre");
                        String marca = rs.getString("medicamento_marca");
                        String pacNombre = rs.getString("paciente_nombre");
                        String fecha = rs.getString("fecha_prescripcion");
                        String docNombre = rs.getString("doctor_nombre");

                        if (marca == null) marca = "N/A";

                        pw.println(codigo + "," + medNombre + "," + marca + "," +
                                pacNombre + "," + fecha + "," + docNombre);
                    }

                    if (hayDatos) {
                        System.out.println("¡ÉXITO! Archivo creado: " + nombreArchivo);
                    } else {
                        System.out.println("AVISO: El paciente con ID " + idPaciente + " no tiene recetas registradas.");
                    }
                }
            }

        } catch (ClassNotFoundException e) {
            System.err.println("ERROR: No se encuentra el Driver. Revisa el pom.xml y recarga Maven.");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("ERROR SQL: " + e.getMessage());
            e.printStackTrace();
        } catch (IOException e) {
            System.err.println("ERROR FICHERO: " + e.getMessage());
            e.printStackTrace();
        }
    }
}