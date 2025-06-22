# SQLiteManager for Xojo

## 📦 Overview

`SQLiteManager` is a robust, cross-platform Xojo class for managing SQLite databases. It simplifies common database operations with an easy-to-use API, and works seamlessly on:

- ✅ iOS
- ✅ macOS
- ✅ Windows
- ✅ Linux
- ✅ Android (Xojo 2024r2+)

## ✨ Features

- Create or open SQLite database files
- Platform-aware default storage paths
- Override database path manually
- Create tables (only if not already existing)
- Insert, update, delete records
- Add columns to existing tables
- Check if a table exists
- Count rows with or without conditions
- Fetch records as `RowSet`
- Export tables to:
  - JSON (`ExportTableAsJSON`)
  - CSV (`ExportTableAsCSV`)

## ⚙️ Platform Support

| Platform   | Supported | Notes |
|------------|-----------|-------|
| iOS        | ✅         | Uses `ApplicationData` folder |
| macOS      | ✅         | Uses `ApplicationData` folder |
| Windows    | ✅         | Uses `ApplicationData` folder |
| Linux      | ✅         | Uses `ApplicationData` folder |
| Android    | ✅         | Uses `Documents` folder |
| Web        | ❌         | Local file storage not supported in Xojo Web |

## 📁 Installation



## 🚀 Usage

### Initialize and Create a Database

```xojo
Var manager As New SQLiteManager

// Optional: override database location
'manager.SetDatabaseFile(SpecialFolder.Documents.Child("custom.sqlite"))

If manager.CreateDatabase("myapp.sqlite") Then
  MessageBox("✅ Database ready!")
End If
```

### Create a Table

```xojo
manager.CreateTableIfNotExists("People", _
  "id INTEGER PRIMARY KEY, name TEXT, age INTEGER")
```

### Insert a Record

```xojo
Var person As New Dictionary
person.Value("name") = "Alice"
person.Value("age") = 35

manager.InsertRecord("People", person)
```

### Update a Record

```xojo
Var updateData As New Dictionary
updateData.Value("age") = 36

manager.UpdateRecord("People", updateData, "name = ?", Array("Alice"))
```

### Delete a Record

```xojo
manager.DeleteRecord("People", "name = ?", Array("Alice"))
```

### Add a Column

```xojo
manager.AddColumn("People", "email TEXT")
```

### Count Records

```xojo
Var total As Integer = manager.CountRecords("People")
```

### Export Table to JSON

```xojo
Var json As String = manager.ExportTableAsJSON("People")
```

### Export Table to CSV

```xojo
Var csv As String = manager.ExportTableAsCSV("People")
```

## 📚 Class API Summary

| Method                        | Description |
|------------------------------|-------------|
| `CreateDatabase(name)`       | Opens or creates a SQLite DB file |
| `SetDatabaseFile(file)`      | Sets a custom database `FolderItem` |
| `CreateTableIfNotExists()`   | Safe table creation |
| `InsertRecord()`             | Insert row from `Dictionary` |
| `UpdateRecord()`             | Update rows by condition |
| `DeleteRecord()`             | Delete rows by condition |
| `DropTable()`                | Delete entire table |
| `AddColumn()`                | Add column to table |
| `GetRowSet()`                | Select query as `RowSet` |
| `TableExists()`              | Check if table exists |
| `CountRecords()`             | Return row count |
| `ExportTableAsJSON()`        | Export all rows to JSON |
| `ExportTableAsCSV()`         | Export all rows to CSV |

## 🛠 Requirements

- ✅ Xojo 2021r3 or later (2025r1+ recommended for Android)
- ✅ SQLite is built-in — no plugins required
- ❌ Not designed for Web projects

## 📄 License

MIT License (or use freely for any purpose)

## 🙋 Support

For feedback or suggestions, feel free to open a GitHub issue or contact the author.
