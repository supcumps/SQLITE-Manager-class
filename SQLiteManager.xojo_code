#tag Class
Protected Class SQLiteManager
	#tag Method, Flags = &h0
		Function AddColumn(tableName As String, columnDef As String) As Boolean
		  // Public Function AddColumn(tableName As String, columnDef As String) As Boolean
		  Try
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
		    
		    ' ➕ Safe to add the column
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
		Sub Constructor()
		  //Sub Constructor()
		  db = Nil
		  dbFile = Nil
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CountRecords(tableName As String, whereClause As String = "", whereValues() As Variant = Nil) As Integer
		  //Public Function CountRecords(tableName As String, whereClause As String = "", whereValues() As Variant = Nil) As Integer
		  Try
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
		  // Function CreateDatabase(dbName As String) As Boolean
		  Try
		    dbFile = SpecialFolder.ApplicationData.Child(dbName)
		    db = New SQLiteDatabase
		    db.DatabaseFile = dbFile
		    
		    If Not dbFile.Exists Then
		      If db.CreateDatabaseFile Then
		        Return True
		      Else
		        Return False
		      End If
		    Else
		      Try
		        db.Connect
		        MessageBox("Database file is located at: " + db.DatabaseFile.ShellPath)
		        Return True
		      Catch connErr As DatabaseException
		        MessageBox("❌ Connection error: " + connErr.Message)
		        Return False
		      End Try
		    End If
		  Catch e As IOException
		    MessageBox("❌ IO Error: " + e.Message)
		    Return False
		  Catch e As RuntimeException
		    MessageBox("❌ Runtime Error: " + e.Message)
		    Return False
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CreateTableIfNotExists(tableName As String, fieldDefs As String) As Boolean
		  //Function CreateTableIfNotExists(tableName As String, fieldDefs As String) As Boolean
		  Try
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
		  //Public Function DeleteRecord(tableName As String, whereClause As String, whereValues() As Variant) As Boolean
		  Try
		    ' Build and run delete statement
		    Var sql As String = "DELETE FROM '" + tableName + "' WHERE " + whereClause
		    db.ExecuteSQL(sql, whereValues)
		    Return True
		  Catch e As DatabaseException
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
		  //Public Function ExportAndSaveCSV(tableName As String) As Boolean
		  LogMessage("Starting CSV export for table: " + tableName)
		  Try
		    ' Step 1: Generate the CSV data as a String from the given table name.
		    Var csv As String = ExportTableAsCSV(tableName)
		    
		    ' Step 2: Declare the FolderItem that will represent the file to save to.
		    Var file As FolderItem
		    
		    ' Step 3: Platform-specific handling
		    #If TargetDesktop Then
		      ' DESKTOP (macOS, Windows, Linux):
		      ' Prompt the user with a Save File dialog to choose a file location and name.
		      file = FolderItem.ShowSaveFileDialog("text/csv", tableName + ".csv")
		      
		      ' If the user cancels the dialog, exit the function with False.
		      If file = Nil Then
		        MessageBox("❗Save cancelled.")
		        Return False
		      End If
		      
		      ' Check if a file with the selected name already exists at that location.
		      Var existing As FolderItem = file.Parent.Child(file.Name)
		      If existing.Exists Then
		        ' Ask the user whether they want to overwrite the existing file.
		        Var d As New MessageDialog
		        d.Message = "A file named '" + file.Name + "' already exists."
		        d.Explanation = "Do you want to overwrite it?"
		        d.ActionButton.Caption = "Overwrite"
		        d.CancelButton.Visible = True
		        d.CancelButton.Caption = "Cancel"
		        
		        ' Show the modal dialog and get the user's response.
		        Var result As MessageDialogButton = d.ShowModal
		        If result <> d.ActionButton Then
		          ' User chose Cancel, so we exit without saving.
		          Return False
		        End If
		      End If
		      
		    #ElseIf TargetiOS Or TargetAndroid Then
		      ' MOBILE (iOS or Android):
		      ' Save the file automatically into the app's Documents folder.
		      ' FolderItem.ShowSaveFileDialog is not available on mobile.
		      file = SpecialFolder.Documents.Child(tableName + ".csv")
		      
		      ' If a file already exists with that name, remove it to allow overwrite.
		      If file.Exists Then
		        file.Remove
		      End If
		      
		    #Else
		      ' OTHER PLATFORMS (fallback, e.g., Linux console app):
		      ' Default to saving in the Documents folder with fixed name.
		      file = SpecialFolder.Documents.Child(tableName + ".csv")
		      
		      ' Remove any existing file with the same name to avoid errors on create.
		      If file.Exists Then
		        file.Remove
		      End If
		    #EndIf
		    
		    ' Step 4: Create a new text file (overwriting if needed) and write the CSV data to it.
		    Var output As TextOutputStream = TextOutputStream.Create(file)
		    output.Write(csv)
		    output.Close
		    
		    ' Step 5: Notify the user that the file has been saved successfully.
		    MessageBox("✅ CSV file saved to: " + file.NativePath)
		    
		    ' Step 6: Return True to indicate success.
		    Return True
		    
		    ' Step 7: Handle file-related errors (e.g., permission denied, disk full).
		  Catch e As IOException
		    MessageBox("❌ File write error: " + e.Message)
		    Return False
		    
		    ' Step 8: Catch other unexpected runtime exceptions and display the error message.
		  Catch e As RuntimeException
		    MessageBox("❌ Unexpected error: " + e.Message)
		    Return False
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ExportTableAsCSV(tableName As String) As String
		  //Function ExportTableAsCSV(tableName As String) As String
		  // returns a string ith the data
		  Try
		    Var rs As RowSet = db.SelectSQL("SELECT * FROM '" + tableName + "'")
		    Var csv As String
		    
		    For i As Integer = 0 To rs.ColumnCount - 1
		      csv = csv + rs.ColumnAt(i).Name
		      If i < rs.ColumnCount - 1 Then csv = csv + ","
		    Next
		    csv = csv + EndOfLine
		    
		    While Not rs.AfterLastRow
		      For i As Integer = 0 To rs.ColumnCount - 1
		        csv = csv + rs.ColumnAt(i).StringValue
		        If i < rs.ColumnCount - 1 Then csv = csv + ","
		      Next
		      csv = csv + EndOfLine
		      rs.MoveToNextRow
		    Wend
		    
		    Return csv
		  Catch e As DatabaseException
		    MessageBox("❌ Export CSV error: " + e.Message)
		    Return ""
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ExportTableAsJSON(tableName As String) As String
		  //Public Function ExportTableAsJSON(tableName As String) As String
		  Try
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
		Function GetRowSet(tableName As String, whereClause As String = "", whereValue As String = "") As RowSet
		  //Public Function GetRowSet(tableName As String, whereClause As String = "", whereValues() As Variant = Nil) As RowSet
		  Try
		    ' Build select statement with optional WHERE clause
		    Var sql As String = "SELECT * FROM [" + tableName + "]"
		    If whereClause <> "" Then sql = sql + " WHERE " + whereClause
		    If whereValue.Trim = "" Then
		      Return db.SelectSQL(sql)
		    Else
		      Return db.SelectSQL(sql, whereValue)
		    End If
		  Catch e As DatabaseException
		    MessageBox("❌ Select error: " + e.Message)
		    Return Nil
		  end try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function InsertRecord(tableName As String, data As Dictionary) As Boolean
		  //Function InsertRecord(tableName As String, data As Dictionary) As Boolean
		  Try
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
		Function TableExists(tableName As String) As Boolean
		  //Public Function TableExists(tableName As String) As Boolean
		  Try
		    ' Query sqlite_master table for presence of the table
		    Var rs As RowSet = db.SelectSQL("SELECT name FROM sqlite_master WHERE type='table' AND name=?", tableName)
		    Return Not rs.AfterLastRow
		  Catch e As DatabaseException
		    MessageBox("❌ Table exists check failed: " + e.Message)
		    Return False
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function UpdateSingleRecord(tableName As String, data As Dictionary, whereColumn As String, whereValue As String) As boolean
		  //Public Function UpdateSingleRecord(tableName As String, data As Dictionary, whereColumn As String, whereValue As String) As Boolean
		  Try
		    Var updates() As String     ' Will hold column = ? expressions
		    Var values() As String      ' Will hold values for binding
		    
		    ' Build the SET clause and collect values
		    For Each key As String In data.Keys
		      updates.Add(key + " = ?")
		      values.Add(data.Value(key))
		    Next
		    
		    ' Add the WHERE match value at the end
		    values.Add(whereValue)
		    
		    ' Final SQL string (e.g. UPDATE People SET age = ?, email = ? WHERE ID = ?)
		    Var sql As String = "UPDATE [" + tableName + "] SET " + String.FromArray(updates, ", ") + " WHERE [" + whereColumn + "] = ?"
		    
		    ' Execute with bound values
		    Select Case values.Count
		    Case 1
		      db.ExecuteSQL(sql, values(0))
		    Case 2
		      db.ExecuteSQL(sql, values(0), values(1))
		    Case 3
		      db.ExecuteSQL(sql, values(0), values(1), values(2))
		    Case 4
		      db.ExecuteSQL(sql, values(0), values(1), values(2), values(3))
		    Else
		      MessageBox("❌ Too many fields to update (max 4 supported)")
		      Return False
		    End Select
		    
		    Return True
		    
		  Catch e As DatabaseException
		    MessageBox("❌ Update error: " + e.Message)
		    Return False
		  End Try
		  
		  
		  //======= USAGE ========
		  '
		  'Var changes As New Dictionary
		  'changes.Value("email") = "updated@example.com"
		  'changes.Value("age") = "45"
		  '
		  'If manager.UpdateSingleRecord("People", changes, "ID", "1") Then
		  'MessageBox("✅ Person updated")
		  'Else
		  'MessageBox("❌ Update failed")
		  'End If
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		db As SQLiteDatabase
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
		#tag ViewProperty
			Name="dbFile"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="db"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
