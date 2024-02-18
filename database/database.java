import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Scanner;

// Example INSERT INTO The values(100, 'ExampleFirst', 'ExampleLast', 'P');

public class database {
    public static void main(String[] args) {
        Connection connection = null;
        Scanner keyboard = new Scanner(System.in);

        try {
            connection = DriverManager.getConnection("jdbc:sqlite:AttendanceDB.db");
            Statement statement = connection.createStatement();
            statement.setQueryTimeout(30);
            String COURSE = keyboard.nextLine();
            statement.executeUpdate("drop table if exists " + COURSE);
            statement.executeUpdate("create table " + COURSE
                    + " (StudentID INTEGER NOT NULL, name VARCHAR(20), surname VARCHAR(30), status VARCHAR(30), PRIMARY KEY (StudentID))");
            int studentID = keyboard.nextInt();
            String name = keyboard.nextLine();
            String surname = keyboard.nextLine();
            String status = keyboard.nextLine();
            statement.executeUpdate("insert into " + COURSE + " values(" + studentID + ", '" + name + "', '" + surname
                    + "', '" + status + "')");

            System.out.println(COURSE + "\n");

            ResultSet rs = statement.executeQuery("select * from " + COURSE);

            while (rs.next()) {
                System.out.println("StudentID = " + rs.getInt("StudentID"));
                System.out.println("name = " + rs.getString("Name"));
                System.out.println("surname = " + rs.getString("Surname"));
                System.out.println("status = " + rs.getString("Status"));
            }

        } catch (SQLException e) {
            System.err.println(e.getMessage());
        } finally {
            try {
                if (connection != null)
                    connection.close();
            } catch (SQLException e) {
                System.err.println(e.getMessage());
            }
        }
        keyboard.close();
    }
}
