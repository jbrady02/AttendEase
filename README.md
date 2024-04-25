![Screenshot of AttendEase View/edit data page](https://github.com/jbrady02/Capstone/assets/89806788/df58d0e9-23af-4980-878f-46dc0f4a7b0a)
# AttendEase
AttendEase is an cross-platform Flutter application that assists educators in taking attendance and storing the data of multiple different classes. This uses a PostgreSQL database to store the class, student, and attendance data. Attendance is collected via a Google form that students access via a QR code and the form results can be imported automatically.
## Features
- Intuitive attendance taking
- Data synchronization via a PostgreSQL database
- Track percentage of classes each student attended
- Customizable student fields
- Automatic imports of attendance form data
- Easy editing of existing data
- Multi-class support
## Setup
1. Download the binary files for the operating system you will in the Releases section. 
2. Set up a PostgreSQL server and collect the database credentials.
3. Open the application and enter the database credentials to log in to the database.
## Add your first class, students, and class session
1. After you log in to the database, select "+" on the bottom left corner.
2. Enter the name of your class followed by the scheduled class time (example: My Class MWF 8:30-9:20) and select "Add class".
3. Select "Students" and select "+" to add a student. After entering the student information, select "Add student".
4. Select the back button on the top left corner and select "Edit class info" for your class.
5. Select "Add a student" and select the students that you want to add to the class.
6. Select "Make form" to copy your class data.
7. Create a Google form with one question (such as "What is your name?) that the students can access. Paste what is in your clipboard into the list of possible responses. Do not continue until your students are ready to verify their attendance.
8. Share the form and copy the form URL.
9. Go back to AttendEase and select "Add session". Enter the class session date and paste the form URL.
10. Tell students to scan the QR code and select their name. Export the form data once everyone has had the chance to verify themselves as present.
11. Select "Edit class info" for your class and select "Import form data". Select the class session and paste the form CSV data. Select "Import form data" to import the data.
12. To edit existing or missing attendance data, select "View/edit data". Select the data that you want to edit and select the option that you want to change the data to.
| Abbreviation | Expanded form        | Color                    |
|--------------|----------------------|--------------------------|
| P            | Present              | Green                    |
| AE           | Absent and excused   | Orange                   |
| AU           | Absent and unexcused | Orange with red outline  |
| TE           | Tardy and excused    | Yellow                   |
| TU           | Tardy and unexcused  | Yellow with red outline  |
| ?            | Unknown              | White with black outline |
