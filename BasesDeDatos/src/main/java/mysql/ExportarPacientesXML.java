package mysql;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ExportarPacientesXML {


    private static final String URL = "jdbc:mysql://localhost:3306/hospital_management_system?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USER = "root";

    private static final String PASSWORD = "";

    public static void main(String[] args) {
        int idPaciente = 100000002;

        String nombreArchivo = "paciente_" + idPaciente + ".xml";

        System.out.println("Iniciando exportación XML para el paciente: " + idPaciente);
        exportarMedicamentosXML(idPaciente, nombreArchivo);
    }

    public static void exportarMedicamentosXML(int idPaciente, String nombreArchivo) {
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


                    pw.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");

                    pw.println("<historial_clinico id_paciente=\"" + idPaciente + "\">");

                    boolean hayDatos = false;

                    while (rs.next()) {
                        hayDatos = true;

                        String codigo = rs.getString("medicamento_codigo");
                        String medNombre = rs.getString("medicamento_nombre");
                        String marca = rs.getString("medicamento_marca");
                        if (marca == null) marca = "Generico";

                        String pacNombre = rs.getString("paciente_nombre");
                        String fecha = rs.getString("fecha_prescripcion");
                        String docNombre = rs.getString("doctor_nombre");

                        pw.println("\t<prescripcion>");

                        pw.println("\t\t<medicamento_codigo>" + codigo + "</medicamento_codigo>");
                        pw.println("\t\t<medicamento_nombre>" + medNombre + "</medicamento_nombre>");
                        pw.println("\t\t<marca>" + marca + "</marca>");
                        pw.println("\t\t<paciente>" + pacNombre + "</paciente>");
                        pw.println("\t\t<fecha>" + fecha + "</fecha>");
                        pw.println("\t\t<doctor>" + docNombre + "</doctor>");

                        pw.println("\t</prescripcion>");
                    }

                    pw.println("</historial_clinico>");

                    if (hayDatos) {
                        System.out.println("¡ÉXITO! Archivo XML creado: " + nombreArchivo);
                    } else {
                        System.out.println("AVISO: No se encontraron datos, se ha generado un XML vacío.");
                    }
                }
            }

        } catch (ClassNotFoundException e) {
            System.err.println("ERROR: No se encuentra el Driver.");
        } catch (SQLException e) {
            System.err.println("ERROR SQL: " + e.getMessage());
            e.printStackTrace();
        } catch (IOException e) {
            System.err.println("ERROR FICHERO: " + e.getMessage());
        }
    }
}