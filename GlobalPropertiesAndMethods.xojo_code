#tag Module
Protected Module GlobalPropertiesAndMethods
	#tag Method, Flags = &h0
		Sub LogMessage(msg As String)
		  ' Logs a message to a file only when running in the Xojo IDE (debug mode)
		  // Sub LogMessage(msg As String)
		  #If DebugBuild Then
		    Try
		      ' Step 1: Get the log file path in Documents
		      Var logFile As FolderItem = SpecialFolder.Documents.Child("log.txt")
		      
		      ' Step 2: Open or create the log file for appending
		      Var stream As TextOutputStream
		      If logFile.Exists Then
		        stream = TextOutputStream.Append(logFile)
		      Else
		        stream = TextOutputStream.Create(logFile)
		      End If
		      
		      ' Step 3: Write timestamped log entry
		      stream.WriteLine(DateTime.Now.ToString(Locale.Current) + " | " + msg)
		      stream.Close
		      
		    Catch e As IOException
		      ' Optional: silently fail or write to IDE debug output
		      System.DebugLog("Logging failed: " + e.Message)
		    End Try
		  #EndIf
		  
		End Sub
	#tag EndMethod


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
End Module
#tag EndModule
