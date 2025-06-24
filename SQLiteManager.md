
# SQLiteManager Reference Guide

## Overview

The `SQLiteManager` class encapsulates common SQLite database operations for use in Xojo projects targeting multiple platforms, including iOS, Android, and Desktop. It provides methods for table and record manipulation, exporting data, and managing connections.

---

## 🔐 Class-Level Properties

| Property Name | Scope   | Type           | Description                       |
|---------------|---------|----------------|-----------------------------------|
| `db`          | Private | `SQLiteDatabase` | The database connection instance. |
| `dbFile`      | Private | `FolderItem`     | The database file location.       |

---

## 📦 Constructor

```
Sub Constructor()
```

- Initializes `db` and `dbFile` to `Nil`.
- Does **not** open or create a database—`CreateDatabase` must be called explicitly.

---

## 🧠 Methods

### `Function AddColumn(tableName As String, columnDef As String) As Boolean`

Adds a new column to a table, if it doesn't already exist.

- ✅ Uses `PRAGMA table_info` to check for existing column.
- ❌ Alerts on failure with message box.

---

### `Function Connect() As Boolean`

Connects to the database file if `db` or `dbFile` are uninitialized.

- ❗ Shows error message if file is not set or connection fails.
- ⚠ Automatically reconnects if needed.

---

### `Function CountRecords(tableName As String, whereClause As String = "", whereValues() As Variant = Nil) As Integer`

Returns the count of records optionally filtered by a WHERE clause.

- ✅ Safe for null `whereValues`.
- ❌ Returns `-1` on error.

---

### `Function CreateDatabase(dbName As String) As Boolean`

Creates or connects to a database in the `ApplicationData` folder.

- ✅ Logs success.
- ❌ Alerts on IO or runtime failure.

---

### `Function CreateTableIfNotExists(tableName As String, fieldDefs As String) As Boolean`

Creates a new table if it doesn't already exist.

- 📌 `fieldDefs` must follow SQL format, e.g., `"id INTEGER PRIMARY KEY, name TEXT"`.

---

### `Function DeleteRecord(tableName As String, whereClause As String, whereValues() As Variant) As Boolean`

Deletes records matching the `WHERE` clause.

- ⚠ Assumes `tableName` is trusted—no sanitation.

---

### `Function DropTable(tableName As String) As Boolean`

Deletes a table if it exists.

- ✅ Uses `DROP TABLE IF EXISTS`.

---

### `Function ExportAndSaveCSV(tableName As String) As Boolean`

Exports a table's content to a `.csv` file and saves it to disk.

- 🌐 Platform-aware save location (Documents or user prompt).
- ✅ Checks for file overwrite and table existence.

---

### `Function ExportTableAsCSV(tableName As String) As String`

Returns the full table content as CSV-formatted text.

- ✅ Adds header row.
- ❌ Returns `""` on error.

---

### `Function ExportTableAsJSON(tableName As String) As String`

Exports the table contents to a JSON array of objects.

- ✅ Fully serializes all columns to JSON.

---

### `Function GetRowSet(tableName As String, whereClause As String = "", whereValues() As Variant = Nil) As RowSet`

Returns a `RowSet` for a table with optional filtering.

- ❗ Returns `Nil` if not connected or query fails.

---

### `Function InsertRecord(tableName As String, data As Dictionary) As Boolean`

Inserts a record using dictionary key-value pairs.

- ✅ Uses parameter binding to prevent injection.

---

### `Function RecordExists(tableName As String, whereClause As String, whereValues() As Variant) As Boolean`

Checks if at least one row matches the provided WHERE clause.

---

### `Function TableExists(tableName As String) As Boolean`

Returns `True` if the named table exists in the database.

- ✅ Uses `sqlite_master`.

---

### `Function UpdateSingleRecord(tableName As String, data As Dictionary, whereColumn As String, whereValue As String) As Boolean`

Updates one row in the specified table matching a single column.

- ✅ Escapes column names with `[]`.
- ❗ Returns `False` on any failure.

---

## 📑 Summary Table

| Method                         | Return Type | Description                                  |
|--------------------------------|-------------|----------------------------------------------|
| `AddColumn`                    | Boolean     | Add new column if not already present        |
| `Connect`                      | Boolean     | Open DB connection                           |
| `CountRecords`                 | Integer     | Count rows matching a WHERE clause           |
| `CreateDatabase`              | Boolean     | Create or connect to SQLite DB               |
| `CreateTableIfNotExists`      | Boolean     | Create table only if it doesn't exist        |
| `DeleteRecord`                | Boolean     | Delete rows by WHERE clause                  |
| `DropTable`                   | Boolean     | Remove a table if it exists                  |
| `ExportAndSaveCSV`            | Boolean     | Save CSV dump of table to disk               |
| `ExportTableAsCSV`            | String      | Return CSV content as text                   |
| `ExportTableAsJSON`           | String      | Return JSON content as text                  |
| `GetRowSet`                   | RowSet      | Retrieve records optionally filtered         |
| `InsertRecord`                | Boolean     | Insert new row from dictionary               |
| `RecordExists`                | Boolean     | Return true if any row matches               |
| `TableExists`                 | Boolean     | Return true if table exists                  |
| `UpdateSingleRecord`          | Boolean     | Update one row by key match                  |

---

## 📘 Suggestions for Improvement

- ✅ Wrap column and table names using `[name]` or backticks to avoid keyword conflicts.
- ❗Add error logging to file instead of relying solely on `MessageBox`.
- 📘 Consider exposing read-only access to `dbFile.NativePath` for external components.
- 🧪 Unit tests should validate behavior across platforms.

---




## 🧪 Method Call Examples

> ℹ️ The following examples assume your `App` class has a **public property**:
>
> ```xojo
> Public Property Manager As SQLiteManager
> ```
>
> And in the App.Opening event or equivalent startup code, you initialize it with:
>
> ```xojo
> App.Manager = New SQLiteManager
> ```

### 📂 Create or Connect to a Database

```xojo
If Not App.Manager.CreateDatabase("MyData.db") Then
  MessageBox("Database creation failed.")
End If
```

### 📋 Create Table If Not Exists

```xojo
Var schema As String = "id INTEGER PRIMARY KEY, name TEXT, age INTEGER"
Call App.Manager.CreateTableIfNotExists("People", schema)
```

### ➕ Add Column If Missing

```xojo
Call App.Manager.AddColumn("People", "email TEXT")
```

### 🧾 Insert a Record

```xojo
Var person As New Dictionary
person.Value("name") = "Alice"
person.Value("age") = 35
Call App.Manager.InsertRecord("People", person)
```

### 🔍 Count Records

```xojo
Var total As Integer = App.Manager.CountRecords("People")
MessageBox("Total people: " + total.ToString)
```

### 🧼 Delete Record

```xojo
Var params() As Variant = Array("Alice")
Call App.Manager.DeleteRecord("People", "name = ?", params)
```

### 🔄 Update Single Record

```xojo
Var updateDict As New Dictionary
updateDict.Value("age") = 36
Call App.Manager.UpdateSingleRecord("People", updateDict, "name", "Alice")
```

### ✅ Check Record Exists

```xojo
Var params() As Variant = Array("Alice")
If App.Manager.RecordExists("People", "name = ?", params) Then
  MessageBox("Alice exists.")
End If
```

### 📤 Export CSV

```xojo
Call App.Manager.ExportAndSaveCSV("People")
```

### 🌐 Export JSON

```xojo
Var json As String = App.Manager.ExportTableAsJSON("People")
MessageBox(json)
```

### 📚 Retrieve RowSet

```xojo
Var rs As RowSet = App.Manager.GetRowSet("People")
If rs <> Nil Then
  While Not rs.AfterLastRow
    System.DebugLog(rs.Column("name").StringValue)
    rs.MoveToNextRow
  Wend
End If
```

---
