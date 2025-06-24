#tag Class
Protected Class SQLiteManager
	#tag Method, Flags = &h0
		Function AddColumn(tableName As String, columnDef As String) As Boolean
		  // Public Function AddColumn(tableName As String, columnDef As String) As Boolean
		  Try
		    If Not Connect Then Return False
		    
		    ' 🧠 Extract column name from definition (assumes format: "email TEXT", etc.)
		    Var columnName As String = columnDef.NthField(" ", 1).Trim
		    
		    ' 🔍 Inspect existing table columns via PRAGMA
		    Var sql As String = "PRAGMA table_info('" + tableName + "')"
		    Var rs As RowSet = db.SelectSQL(sql)
		    
		    ' 🔁 Look for a match to avoid re-adding the column
		    While Not rs.AfterLastRow
		      If rs.Column("name").StringValue.Trim = columnName Then
		        rs.Close
		        Return True ' Column already exists
		      End If
		      rs.MoveToNextRow 
		    Wend
		    rs.Close
		    
		    '//➕ Safe to add the column
		    
		    sql = "ALTER TABLE '" + tableName + "' ADD COLUMN " + columnDef
		    db.ExecuteSQL(sql)
		    
		    Return True
		    
		  Catch e As DatabaseException
		    MessageBox("❌ Add column error: " + e.Message)
		    Return False
		  End Try
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Connect() As Boolean
		  ' Connect to existing database
		  //Public Function Connect() As Boolean
		  Try
		    If db = Nil Then
		      If dbFile = Nil Then
		        MessageBox("❌ Database file not set.")
		        Return False
		      End If
		      
		      db = New SQLiteDatabase
		      db.DatabaseFile = dbFile
		    End If
		    
		    If Not db.isConnected Then
		      db.Connect
		    End If
		    
		    Return True
		    
		  Catch e As DatabaseException
		    MessageBox("❌ Connection Error: " + e.Message)
		    Return False
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  ' Constructor: do nothing; call CreateDatabase() separately
		  
		  db = Nil
		  dbFile = Nil
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CountRecords(tableName As String, whereClause As String = "", whereValues() As Variant = Nil) As Integer
		  
		  Try
		    If Not Connect Then Return 0
		    ' Build count SQL
		    Var sql As String = "SELECT COUNT(*) FROM '" + tableName + "'"
		    If whereClause <> "" Then sql = sql + " WHERE " + whereClause
		    Var rs As RowSet
		    If whereValues = Nil Then
		      rs = db.SelectSQL(sql)
		    Else
		      rs = db.SelectSQL(sql, whereValues)
		    End If
		    If rs <> Nil Then
		      Return rs.ColumnAt(0).IntegerValue ' Return count
		    Else
		      Return 0
		    End If
		  Catch e As DatabaseException
		    MessageBox("❌ Count error: " + e.Message)
		    Return -1
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CreateDatabase(dbName As String) As Boolean
		  ' Creates a new SQLite database file in ApplicationData if it doesn't exist,
		  ' or connects to it if it already exists.
		  // Public Function CreateDatabase(dbName As String) As Boolean
		  Try
		    
		    ' Step 1: Make sure the ApplicationData folder is available
		    If SpecialFolder.ApplicationData = Nil Then
		      MessageBox("❌ ApplicationData folder not available on this platform.")
		      Return False
		    End If
		    
		    ' Step 2: Construct the file path for the database
		    dbFile = SpecialFolder.ApplicationData.Child(dbName)
		    
		    ' Step 3: Initialize a new SQLiteDatabase object
		    db = New SQLiteDatabase
		    db.DatabaseFile = dbFile
		    
		    ' Step 4: Check if the database file already exists
		    If dbFile.Exists Then
		      ' ✅ File exists — try connecting
		      Try
		        db.Connect
		        LogMessage("✅ Connected to existing database at: " + dbFile.NativePath)
		        Return True
		      Catch connErr As DatabaseException
		        MessageBox("❌ Could not connect to existing database: " + connErr.Message)
		        Return False
		      End Try
		      
		    Else
		      ' 🚧 File does not exist — try to create a new one
		      If db.CreateDatabaseFile Then
		        LogMessage("✅ New database created at: " + dbFile.NativePath)
		        Return True
		      Else
		        MessageBox("❌ Could not create database file.")
		        Return False
		      End If
		    End If
		    
		    ' Step 5: Handle file system-related errors
		  Catch e As IOException
		    MessageBox("❌ IO Error while creating or accessing database: " + e.Message)
		    Return False
		    
		    ' Step 6: Handle unexpected runtime errors
		  Catch e As RuntimeException
		    MessageBox("❌ Runtime Error: " + e.Message)
		    Return False
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CreateTableIfNotExists(tableName As String, fieldDefs As String) As Boolean
		  ' Create a table if it doesn't already exist
		  //Public Function CreateTableIfNotExists(tableName As String, fieldDefs As String) As Boolean
		  Try
		    If Not Connect Then Return False
		    
		    Var sql As String = "CREATE TABLE IF NOT EXISTS '" + tableName + "' (" + fieldDefs + ")"
		    db.ExecuteSQL(sql)
		    Return True
		    
		  Catch e As DatabaseException
		    MessageBox("❌ SQL Error: " + e.Message)
		    Return False
		  End Try
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DeleteRecord(tableName As String, whereClause As String, whereValues() As Variant) As Boolean
		  ' Deletes one or more rows from a specified table based on a WHERE clause and parameter values
		  //Public Function DeleteRecord(tableName As String, whereClause As String, whereValues() As Variant) As Boolean
		  '
		  // Step 1: Ensure we are connected To the database
		  If Not Connect Then Return False
		  
		  Try
		    ' Step 2: Build the DELETE SQL statement
		    ' WARNING: Table name is inserted directly — make sure it comes from a trusted source
		    ' The WHERE clause uses placeholders (e.g., "ID = ? AND Name = ?")
		    Var sql As String = "DELETE FROM '" + tableName + "' WHERE " + whereClause
		    
		    ' Step 3: Execute the statement with parameter substitution
		    ' whereValues() is an array of values that correspond to each "?" in whereClause
		    db.ExecuteSQL(sql, whereValues)
		    
		    ' Step 4: Indicate success
		    Return True
		    
		  Catch e As DatabaseException
		    ' Step 5: Show error message if something goes wrong
		    MessageBox("❌ Delete error: " + e.Message)
		    Return False
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DropTable(tableName As String) As Boolean
		  '=== Delete Table ===
		  //Public Function DropTable(tableName As String) As Boolean
		  Try
		    If Not Connect Then Return False
		    
		    db.ExecuteSQL("DROP TABLE IF EXISTS '" + tableName + "'") ' Safely drop if exists
		    Return True
		  Catch e As DatabaseException
		    MessageBox("❌ Drop table error: " + e.Message)
		    Return False
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ExportAndSaveCSV(tableName As String) As Boolean
		  ' Exports the contents of the specified table as CSV and saves it to disk
		  ' Works across Desktop, iOS, and Android
		  //Public Function ExportAndSaveCSV(tableName As String) As Boolean
		  
		  If Not Connect Then Return False
		  LogMessage("Starting CSV export for table: " + tableName)
		  
		  Try
		    ' Step 1: Make sure the table exists before trying to export it
		    If Not TableExists(tableName) Then
		      MessageBox("❌ The table '" + tableName + "' does not exist.")
		      Return False
		    End If
		    
		    ' Step 2: Generate the CSV content from the table
		    Var csv As String = ExportTableAsCSV(tableName)
		    
		    ' Step 3: Declare a FolderItem to represent the output file
		    Var file As FolderItem
		    
		    ' Step 4: Platform-specific handling
		    #If TargetDesktop Then
		      ' ----- macOS / Windows / Linux -----
		      ' Prompt user to choose where to save the file
		      file = FolderItem.ShowSaveFileDialog("text/csv", tableName + ".csv")
		      
		      ' If user cancels the save dialog, exit the function
		      If file = Nil Then
		        MessageBox("❗ Save cancelled.")
		        Return False
		      End If
		      
		      ' Check if file already exists and ask user for confirmation
		      If file.Exists Then
		        Var d As New MessageDialog
		        d.Message = "A file named '" + file.Name + "' already exists."
		        d.Explanation = "Do you want to overwrite it?"
		        d.ActionButton.Caption = "Overwrite"
		        d.CancelButton.Visible = True
		        d.CancelButton.Caption = "Cancel"
		        Var result As MessageDialogButton = d.ShowModal
		        
		        ' User clicked Cancel
		        If result <> d.ActionButton Then
		          Return False
		        End If
		      End If
		      
		    #ElseIf TargetiOS Or TargetAndroid Then
		      ' ----- iOS / Android -----
		      ' Automatically save to the app's Documents folder
		      file = SpecialFolder.Documents.Child(tableName + ".csv")
		      
		      ' Remove existing file to avoid overwrite conflict
		      If file.Exists Then
		        file.Remove
		      End If
		      
		    #Else
		      ' ----- Other Platforms (e.g. Linux console) -----
		      ' Default to Documents folder
		      file = SpecialFolder.Documents.Child(tableName + ".csv")
		      
		      If file.Exists Then
		        file.Remove
		      End If
		    #EndIf
		    
		    ' Step 5: Write the CSV data to the chosen file
		    Var output As TextOutputStream = TextOutputStream.Create(file)
		    output.Write(csv)
		    output.Close
		    
		    ' Step 6: Notify the user of success
		    MessageBox("✅ CSV file saved to: " + file.NativePath)
		    Return True
		    
		  Catch e As IOException
		    ' Handle file write errors (e.g., permission denied)
		    MessageBox("❌ File write error: " + e.Message)
		    Return False
		    
		  Catch e As RuntimeException
		    ' Handle any other unexpected runtime errors
		    MessageBox("❌ Unexpected error: " + e.Message)
		    Return False
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ExportTableAsCSV(tableName As String) As String
		  // Public Function ExportTableAsCSV(tableName As String) As String
		  Try
		    ' Make sure we're connected to the database
		    If Not Connect Then Return ""
		    
		    ' Query all rows from the specified table
		    Var rs As RowSet = db.SelectSQL("SELECT * FROM " + tableName)
		    
		    ' String to hold the final CSV
		    Var csv As String
		    
		    ' --- Step 1: Add the header row (column names) ---
		    For i As Integer = 0 To rs.ColumnCount - 1
		      csv = csv + rs.ColumnAt(i).Name ' Get column name by index
		      If i < rs.ColumnCount - 1 Then
		        csv = csv + ","
		      End If
		    Next
		    csv = csv + EndOfLine
		    
		    ' --- Step 2: Add each row of data ---
		    While Not rs.AfterLastRow
		      For i As Integer = 0 To rs.ColumnCount - 1
		        ' Get column name
		        Var colName As String = rs.ColumnAt(i).Name
		        
		        ' Get the value in the current row for that column
		        Var cellValue As String = rs.Column(colName).StringValue
		        
		        ' Append value to CSV
		        csv = csv + cellValue
		        
		        If i < rs.ColumnCount - 1 Then
		          csv = csv + ","
		        End If
		      Next
		      csv = csv + EndOfLine
		      rs.MoveToNextRow
		    Wend
		    
		    ' Return the completed CSV content
		    Return csv
		    
		  Catch e As DatabaseException
		    ' Show any SQL/database error
		    MessageBox("❌ Export CSV error: " + e.Message)
		    Return ""
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ExportTableAsJSON(tableName As String) As String
		  //Public Function ExportTableAsJSON(tableName As String) As String
		  
		  Try
		    If Not Connect Then Return ""
		    
		    Var rs As RowSet = db.SelectSQL("SELECT * FROM '" + tableName + "'")
		    Var jArray As New JSONItem
		    While Not rs.AfterLastRow
		      Var rowItem As New JSONItem
		      For i As Integer = 0 To rs.ColumnCount - 1
		        rowItem.Value(rs.ColumnAt(i).Name) = rs.ColumnAt(i).Value
		      Next
		      jArray.Add(rowItem)
		      rs.MoveToNextRow
		    Wend
		    Return jArray.ToString
		  Catch e As DatabaseException
		    MessageBox("❌ Export JSON error: " + e.Message)
		    Return ""
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetRowSet(tableName As String, whereClause As String = "", whereValues() As Variant = Nil) As RowSet
		  //Public Function GetRowSet(tableName As String, whereClause As String = "", whereValues() As Variant = Nil) As RowSet
		  'Try
		  '
		  '' Build select statement with optional WHERE clause
		  'Var sql As String = "SELECT * FROM [" + tableName + "]"
		  'If whereClause <> "" Then sql = sql + " WHERE " + whereClause
		  'If whereValue.Trim = "" Then
		  'Return db.SelectSQL(sql)
		  'Else
		  'Return db.SelectSQL(sql, whereValue)
		  'End If
		  'Catch e As DatabaseException
		  'MessageBox("❌ Select error: " + e.Message)
		  'Return Nil
		  'End Try
		  
		  
		  ' Retrieves a RowSet from the specified table with an optional WHERE clause and bind values.
		  ' Returns Nil if the query fails or the database isn't connected.
		  //Public Function GetRowSet(tableName As String, whereClause As String = "", whereValues() As Variant = Nil) As RowSet
		  Try
		    ' Step 1: Check if the database is initialized and connected
		    If db = Nil Or Not db.IsConnected Then
		      MessageBox("❌ Database is not connected.")
		      Return Nil
		    End If
		    
		    ' Step 2: Construct SQL statement
		    Var sql As String = "SELECT * FROM [" + tableName + "]"
		    If whereClause.Trim <> "" Then
		      sql = sql + " WHERE " + whereClause
		    End If
		    
		    ' Step 3: Execute query with or without bound parameters
		    If whereValues = Nil Or whereValues.Count = 0 Then
		      Return db.SelectSQL(sql)
		    Else
		      Return db.SelectSQL(sql, whereValues)
		    End If
		    
		  Catch e As DatabaseException
		    ' Step 4: Catch and report database errors
		    MessageBox("❌ Select error: " + e.Message)
		    Return Nil
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function InsertRecord(tableName As String, data As Dictionary) As Boolean
		  ' Insert a record from a Dictionary
		  //Public Function InsertRecord(tableName As String, data As Dictionary) As Boolean
		  Try
		    If Not Connect Then Return False
		    
		    Var keys() As String
		    Var placeholders() As String
		    Var values() As Variant
		    
		    For Each key As String In data.Keys
		      keys.Add(key)
		      placeholders.Add("?")
		      values.Add(data.Value(key))
		    Next
		    
		    Var sql As String = "INSERT INTO '" + tableName + "' (" + String.FromArray(keys, ", ") + ") VALUES (" + String.FromArray(placeholders, ", ") + ")"
		    db.ExecuteSQL(sql, values)
		    Return True
		    
		  Catch e As DatabaseException
		    MessageBox("❌ Insert error: " + e.Message)
		    Return False
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RecordExists(tableName As String, whereClause As String, whereValues() As Variant) As Boolean
		  ' Checks whether a record matching a WHERE clause exists in the given table
		  //Public Function RecordExists(tableName As String, whereClause As String, whereValues() As Variant) As Boolean
		  If Not Connect Then Return False
		  
		  Try
		    ' Use a SELECT COUNT(*) to check if any matching records exist
		    Var sql As String = "SELECT COUNT(*) FROM '" + tableName + "' WHERE " + whereClause
		    Var rs As RowSet = db.SelectSQL(sql, whereValues)
		    
		    ' If at least one row matches, return True
		    Return rs.ColumnAt(0).IntegerValue > 0
		    
		  Catch e As DatabaseException
		    MessageBox("❌ RecordExists error: " + e.Message)
		    Return False
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TableExists(tableName As String) As Boolean
		  ' Checks if a table exists in the connected SQLite database
		  //Public Function TableExists(tableName As String) As Boolean
		  
		  Try
		    If Not Connect Then Return False
		    Var rs As RowSet = db.SelectSQL("SELECT name FROM sqlite_master WHERE type='table' AND name = ?", tableName)
		    Return Not rs.AfterLastRow
		  Catch e As DatabaseException
		    MessageBox("❌ TableExists check error: " + e.Message)
		    Return False
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function UpdateSingleRecord(tableName As String, data As Dictionary, whereColumn As String, whereValue As String) As boolean
		  // Updates a single record in the specified table using a WHERE match on one column.
		  ' Parameters:
		  ' - tableName: The name of the table (e.g., "People")
		  ' - data: A Dictionary of column names and new values to set
		  ' - whereColumn: The column to match (e.g., "ID")
		  ' - whereValue: The value to match in whereColumn (e.g., "1")
		  // Public Function UpdateSingleRecord(tableName As String, data As Dictionary, whereColumn As String, whereValue As Variant) As Boolean
		  If Not Connect Then Return False
		  
		  Try
		    Var updates() As String         ' Holds the "column = ?" pairs
		    Var values() As Variant         ' Holds values to bind to the placeholders
		    
		    ' Build SET clause from dictionary
		    For Each key As String In data.Keys
		      updates.Add("[" + key + "] = ?")        ' Use square brackets for SQL safety (avoids keyword issues)
		      values.Add(data.Value(key))             ' Add the value to the bind array
		    Next
		    
		    ' Add WHERE value at the end (for the final "?" in the WHERE clause)
		    values.Add(whereValue)
		    
		    ' Build the full SQL UPDATE command
		    Var sql As String = "UPDATE [" + tableName + "] SET " + String.FromArray(updates, ", ") + " WHERE [" + whereColumn + "] = ?"
		    
		    ' Execute the SQL with all collected values bound to placeholders
		    db.ExecuteSQL(sql, values)
		    
		    ' If no error occurred, return success
		    Return True
		    
		  Catch e As DatabaseException
		    ' Handle any SQL error gracefully
		    MessageBox("❌ Update error: " + e.Message)
		    Return False
		  End Try
		  
		  //========= see call  button for example usage
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private db As SQLiteDatabase
	#tag EndProperty

	#tag Property, Flags = &h21
		Private dbFile As FolderItem
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
