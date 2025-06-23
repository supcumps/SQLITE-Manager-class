#tag Module
Protected Module GlobalPropertiesAndMethods
	#tag Method, Flags = &h0
		Sub LogMessage(msg As String)
		  Try
		    ' Get the log file in the Documents folder
		    Var logFile As FolderItem = SpecialFolder.Documents.Child("log.txt")
		    
		    ' Open or create the file for appending
		    Var stream As TextOutputStream
		    If logFile.Exists Then
		      stream = TextOutputStream.Append(logFile)
		    Else
		      stream = TextOutputStream.Create(logFile)
		    End If
		    
		    ' Write message with timestamp
		    stream.WriteLine(DateTime.Now.ToString + " | " + msg)
		    stream.Close
		    
		  Catch e As IOException
		    ' If logging fails, silently ignore (to avoid recursive errors)
		  End Try
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
