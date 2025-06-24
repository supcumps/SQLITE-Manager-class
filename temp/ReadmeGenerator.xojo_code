#tag Class
Protected Class ReadmeGenerator
	#tag Method, Flags = &h0
		Sub Constructor(projectFile As FolderItem, Optional outputFile As FolderItem = Nil)
		  // Sub Constructor(projectFile As FolderItem, Optional outputFile As FolderItem = Nil)
		  mProjectFile = projectFile
		  If outputFile = Nil Then
		    mOutputFile = projectFile.Parent.Child("README.md")
		  Else
		    mOutputFile = outputFile
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GenerateREADME() As Boolean
		  // Function GenerateREADME() As Boolean
		  Try
		    If Not ParseProjectFile() Then
		      Return False
		    End If
		    
		    Return WriteREADME()
		    
		  Catch err As RuntimeException
		    System.DebugLog("Error generating README: " + err.Message)
		    Return False
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetProjectInfo() As Dictionary
		  //Function GetProjectInfo() As Dictionary
		  Dim info As New Dictionary
		  info.Value("Name") = mProjectName
		  info.Value("Version") = mProjectVersion
		  info.Value("Description") = mProjectDescription
		  info.Value("Windows") = mWindows
		  info.Value("Classes") = mClasses
		  info.Value("Modules") = mModules
		  info.Value("Menus") = mMenus
		  info.Value("BuildTargets") = mBuildTargets
		  info.Value("ExternalItems") = mExternalItems
		  Return info
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ParseClassDetails()
		  //Private Sub ParseClassDetails()
		  // Clear existing class details
		  Redim mClassDetails(-1)
		  
		  For i As Integer = 0 To mClasses.Count - 1
		    Dim className As String = mClasses(i)
		    Dim classFile As FolderItem = FindClassFile(className)
		    
		    If classFile <> Nil And classFile.Exists Then
		      Dim detail As ClassDetail
		      detail.Name = className
		      detail.FilePath = classFile.NativePath
		      
		      // Parse the class file
		      ParseClassFile(classFile, detail)
		      
		      mClassDetails.Append(detail)
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseProjectFile() As Boolean
		  //Private Function ParseProjectFile() As Boolean
		  Try
		    If mProjectFile = Nil Or Not mProjectFile.Exists Then
		      System.DebugLog("Project file is nil or doesn't exist")
		      Return False
		    End If
		    
		    ' Check if file is readable
		    If Not mProjectFile.IsReadable Then
		      System.DebugLog("Project file is not readable")
		      Return False
		    End If
		    
		    Dim Input As TextInputStream
		    Dim retryCount As Integer = 0
		    Const maxRetries As Integer = 3
		    
		    While retryCount < maxRetries
		      Try
		        Input = TextInputStream.Open(mProjectFile)
		        If Input <> Nil Then
		          Exit While
		        End If
		      Catch e As IOException
		        retryCount = retryCount + 1
		        If retryCount >= maxRetries Then
		          System.DebugLog("Failed to open file after " + maxRetries.ToString + " attempts: " + e.Message)
		          Return False
		        End If
		        ' Brief pause before retry
		        App.DoEvents()
		      End Try
		    Wend
		    
		    If Input = Nil Then
		      System.DebugLog("Failed to open TextInputStream after retries")
		      Return False
		    End If
		    
		    Input.Encoding = Encodings.UTF8
		    
		    Dim content As String = Input.ReadAll()
		    Input.Close()
		    
		    ' Initialize arrays
		    Redim mWindows(-1)
		    Redim mClasses(-1)
		    Redim mModules(-1)
		    Redim mMenus(-1)
		    Redim mBuildTargets(-1)
		    Redim mExternalItems(-1)
		    
		    ' Parse the project file content
		    Dim lines() As String = content.Split(EndOfLine)
		    
		    For i As Integer = 0 To lines.UBound
		      Dim line As String = lines(i).Trim()
		      
		      If line.BeginsWith("Title=") Then
		        mProjectName = line.Mid(7)
		      ElseIf line.BeginsWith("Version=") Then
		        mProjectVersion = line.Mid(9)
		      ElseIf line.BeginsWith("Description=") Then
		        mProjectDescription = line.Mid(13)
		      ElseIf line.BeginsWith("Window=") Then
		        Dim windowData As String = line.Mid(8)
		        Dim semicolonPos As Integer = windowData.IndexOf(";")
		        If semicolonPos > 0 Then
		          mWindows.Append(windowData.Left(semicolonPos))
		        Else
		          mWindows.Append(windowData)
		        End If
		      ElseIf line.BeginsWith("Class=") Then
		        Dim classData As String = line.Mid(7)
		        Dim semicolonPos As Integer = classData.IndexOf(";")
		        If semicolonPos > 0 Then
		          mClasses.Append(classData.Left(semicolonPos))
		        Else
		          mClasses.Append(classData)
		        End If
		      ElseIf line.BeginsWith("Module=") Then
		        Dim moduleData As String = line.Mid(8)
		        Dim semicolonPos As Integer = moduleData.IndexOf(";")
		        If semicolonPos > 0 Then
		          mModules.Append(moduleData.Left(semicolonPos))
		        Else
		          mModules.Append(moduleData)
		        End If
		      ElseIf line.BeginsWith("MenuBar=") Then
		        Dim menuData As String = line.Mid(9)
		        Dim semicolonPos As Integer = menuData.IndexOf(";")
		        If semicolonPos > 0 Then
		          mMenus.Append(menuData.Left(semicolonPos))
		        Else
		          mMenus.Append(menuData)
		        End If
		      ElseIf line.BeginsWith("BuildTarget=") Then
		        Dim targetData As String = line.Mid(13)
		        Dim semicolonPos As Integer = targetData.IndexOf(";")
		        If semicolonPos > 0 Then
		          mBuildTargets.Append(targetData.Left(semicolonPos))
		        Else
		          mBuildTargets.Append(targetData)
		        End If
		      ElseIf line.BeginsWith("ExternalItem=") Then
		        Dim externalData As String = line.Mid(14)
		        Dim semicolonPos As Integer = externalData.IndexOf(";")
		        If semicolonPos > 0 Then
		          mExternalItems.Append(externalData.Left(semicolonPos))
		        Else
		          mExternalItems.Append(externalData)
		        End If
		      End If
		    Next
		    
		    ' Set default project name if not found
		    If mProjectName = "" Then
		      Dim fileName As String = mProjectFile.DisplayName
		      Dim dotPosition As Integer = -1
		      
		      ' Find the last dot manually
		      For j As Integer = fileName.Length - 1 DownTo 0
		        If fileName.Mid(j + 1, 1) = "." Then
		          dotPosition = j
		          Exit For j
		        End If
		      Next j
		      
		      If dotPosition >= 0 Then
		        mProjectName = fileName.Left(dotPosition)
		      Else
		        mProjectName = fileName
		      End If
		    End If
		    
		    Return True
		    
		  Catch err As IOException
		    System.DebugLog("Error reading project file: " + err.Message)
		    Return False
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ProjectDescription() As String
		  Return mProjectDescription
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ProjectName() As String
		  ' Property getters
		  Return mProjectName
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ProjectVersion() As String
		  Return mProjectVersion
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function WriteREADME() As Boolean
		  // Private Function WriteREADME() As Boolean
		  Try
		    Dim output As TextOutputStream = TextOutputStream.Create(mOutputFile)
		    output.Encoding = Encodings.UTF8
		    
		    ' Write README content
		    output.WriteLine("# " + mProjectName)
		    output.WriteLine("")
		    
		    If mProjectDescription <> "" Then
		      output.WriteLine(mProjectDescription)
		      output.WriteLine("")
		    End If
		    
		    If mProjectVersion <> "" Then
		      output.WriteLine("**Version:** " + mProjectVersion)
		      output.WriteLine("")
		    End If
		    
		    output.WriteLine("## Project Overview")
		    output.WriteLine("")
		    output.WriteLine("This is a Xojo project that contains the following components:")
		    output.WriteLine("")
		    
		    ' Windows section
		    If mWindows.UBound >= 0 Then
		      output.WriteLine("### Windows")
		      output.WriteLine("")
		      For i As Integer = 0 To mWindows.UBound
		        output.WriteLine("- " + mWindows(i))
		      Next
		      output.WriteLine("")
		    End If
		    
		    ' Classes section
		    If mClasses.UBound >= 0 Then
		      output.WriteLine("### Classes")
		      output.WriteLine("")
		      For i As Integer = 0 To mClasses.UBound
		        output.WriteLine("- " + mClasses(i))
		      Next
		      output.WriteLine("")
		    End If
		    
		    ' Modules section
		    If mModules.UBound >= 0 Then
		      output.WriteLine("### Modules")
		      output.WriteLine("")
		      For i As Integer = 0 To mModules.UBound
		        output.WriteLine("- " + mModules(i))
		      Next
		      output.WriteLine("")
		    End If
		    
		    ' Menus section
		    If mMenus.UBound >= 0 Then
		      output.WriteLine("### Menus")
		      output.WriteLine("")
		      For i As Integer = 0 To mMenus.UBound
		        output.WriteLine("- " + mMenus(i))
		      Next
		      output.WriteLine("")
		    End If
		    
		    ' Build Targets section
		    If mBuildTargets.UBound >= 0 Then
		      output.WriteLine("### Build Targets")
		      output.WriteLine("")
		      For i As Integer = 0 To mBuildTargets.UBound
		        output.WriteLine("- " + mBuildTargets(i))
		      Next
		      output.WriteLine("")
		    End If
		    
		    ' External Items section
		    If mExternalItems.UBound >= 0 Then
		      output.WriteLine("### External Dependencies")
		      output.WriteLine("")
		      For i As Integer = 0 To mExternalItems.UBound
		        output.WriteLine("- " + mExternalItems(i))
		      Next
		      output.WriteLine("")
		    End If
		    
		    ' Requirements section
		    output.WriteLine("## Requirements")
		    output.WriteLine("")
		    output.WriteLine("- Xojo (compatible version)")
		    output.WriteLine("- Operating System: [Specify based on build targets]")
		    output.WriteLine("")
		    
		    ' Installation section
		    output.WriteLine("## Installation")
		    output.WriteLine("")
		    output.WriteLine("1. Clone or download this repository")
		    output.WriteLine("2. Open the `.xojo_project` file in Xojo")
		    output.WriteLine("3. Build and run the project")
		    output.WriteLine("")
		    
		    ' Usage section
		    output.WriteLine("## Usage")
		    output.WriteLine("")
		    output.WriteLine("[Add specific usage instructions for your application]")
		    output.WriteLine("")
		    
		    ' Contributing section
		    output.WriteLine("## Contributing")
		    output.WriteLine("")
		    output.WriteLine("1. Fork the repository")
		    output.WriteLine("2. Create a feature branch")
		    output.WriteLine("3. Make your changes")
		    output.WriteLine("4. Submit a pull request")
		    output.WriteLine("")
		    
		    ' License section
		    output.WriteLine("## License")
		    output.WriteLine("")
		    output.WriteLine("[Specify your license here]")
		    output.WriteLine("")
		    
		    ' Generated notice
		    output.WriteLine("---")
		    output.WriteLine("*This README was automatically generated from the Xojo project file.*")
		    
		    output.Close()
		    Return True
		    
		  Catch err As IOException
		    System.DebugLog("Error writing README file: " + err.Message)
		    Return False
		  End Try
		  
		  
		  
		  
		  
		  
		  
		  
		End Function
	#tag EndMethod


	#tag Note, Name = Example usage
		 Example usage in a method or event handler:
		'
		 Sub GenerateREADME()
		   Dim projectFile As FolderItem = GetOpenFolderItem(FileTypes1.XojoProject)
		   If projectFile <> Nil Then
		     Dim generator As New XojoProjectREADMEGenerator(projectFile)
		     If generator.GenerateREADME() Then
		       MsgBox("README.md generated successfully!")
		     Else
		       MsgBox("Failed to generate README.md")
		     End If
		   End If
		'End Sub
		
	#tag EndNote


	#tag Property, Flags = &h0
		mBuildTargets() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		mClasses() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		mExternalItems() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		mMenus() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		mModules() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		mOutputFile As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		mProjectDescription As String
	#tag EndProperty

	#tag Property, Flags = &h0
		mProjectFile As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		mProjectName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		mProjectVersion As String
	#tag EndProperty

	#tag Property, Flags = &h0
		mWindows() As String
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
