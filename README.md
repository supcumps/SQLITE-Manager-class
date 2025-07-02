# SQLiteFunctions

## Project Overview

This Xojo project contains the following components:

### Project Components

- **Classes:** 2 (App, SQLiteManagerClass)
- **Modules:** 1 (lobalPropertiesAndMethods)
- **Menus:** 1 (MainMenuBar)

## Classes

### App

#### Properties

- **`Manager`** Public SQLiteManagerClass

- **`kEditClear`** Public String

- **`kFileQuit`** Public String

- **`kFileQuitShortcut`** Public String

#### Methods

- **`Opening`** Public Sub
  - **Signature:** `Public Sub Opening()`

#### Events

None

---

### SQLiteManagerClass

#### Properties

- **`db`** Private SQLiteDatabase

- **`dbFile`** Private FolderItem

#### Methods

- **`AddColumn`** Public Function
  - **Parameters:** `tableName As String, columnDef As String`
  - **Returns:** `Boolean`
  - **Signature:** `Public Function AddColumn(tableName As String, columnDef As String) As Boolean`

- **`Connect`** Public Function
  - **Returns:** `Boolean`
  - **Signature:** `Public Function Connect() As Boolean`

- **`Constructor`** Public Constructor
  - **Signature:** `Public Constructor()`

- **`CountRecords`** Public Function
  - **Parameters:** `tableName As String, whereClause As String = "", whereValues() As Variant = Nil`
  - **Returns:** `Integer`
  - **Signature:** `Public Function CountRecords(tableName As String, whereClause As String = "", whereValues() As Variant = Nil) As Integer`

- **`CreateDatabase`** Public Function
  - **Parameters:** `dbName As String`
  - **Returns:** `Boolean`
  - **Signature:** `Public Function CreateDatabase(dbName As String) As Boolean`

- **`CreateTableIfNotExists`** Public Function
  - **Parameters:** `tableName As String, fieldDefs As String`
  - **Returns:** `Boolean`
  - **Signature:** `Public Function CreateTableIfNotExists(tableName As String, fieldDefs As String) As Boolean`

- **`DeleteRecord`** Public Function
  - **Parameters:** `tableName As String, whereClause As String, whereValues() As Variant`
  - **Returns:** `Boolean`
  - **Signature:** `Public Function DeleteRecord(tableName As String, whereClause As String, whereValues() As Variant) As Boolean`

- **`DropTable`** Public Function
  - **Parameters:** `tableName As String`
  - **Returns:** `Boolean`
  - **Signature:** `Public Function DropTable(tableName As String) As Boolean`

- **`ExportAndSaveCSV`** Public Function
  - **Parameters:** `tableName As String`
  - **Returns:** `Boolean`
  - **Signature:** `Public Function ExportAndSaveCSV(tableName As String) As Boolean`

- **`ExportTableAsCSV`** Public Function
  - **Parameters:** `tableName As String`
  - **Returns:** `String`
  - **Signature:** `Public Function ExportTableAsCSV(tableName As String) As String`

- **`ExportTableAsJSON`** Public Function
  - **Parameters:** `tableName As String`
  - **Returns:** `String`
  - **Signature:** `Public Function ExportTableAsJSON(tableName As String) As String`

- **`GetRowSet`** Public Function
  - **Parameters:** `tableName As String, whereClause As String = "", whereValues() As Variant = Nil`
  - **Returns:** `RowSet`
  - **Signature:** `Public Function GetRowSet(tableName As String, whereClause As String = "", whereValues() As Variant = Nil) As RowSet`

- **`InsertRecord`** Public Function
  - **Parameters:** `tableName As String, data As Dictionary`
  - **Returns:** `Boolean`
  - **Signature:** `Public Function InsertRecord(tableName As String, data As Dictionary) As Boolean`

- **`RecordExists`** Public Function
  - **Parameters:** `tableName As String, whereClause As String, whereValues() As Variant`
  - **Returns:** `Boolean`
  - **Signature:** `Public Function RecordExists(tableName As String, whereClause As String, whereValues() As Variant) As Boolean`

- **`TableExists`** Public Function
  - **Parameters:** `tableName As String`
  - **Returns:** `Boolean`
  - **Signature:** `Public Function TableExists(tableName As String) As Boolean`

- **`UpdateSingleRecord`** Public Function
  - **Parameters:** `tableName As String, data As Dictionary, whereColumn As String, whereValue As String`
  - **Returns:** `boolean`
  - **Signature:** `Public Function UpdateSingleRecord(tableName As String, data As Dictionary, whereColumn As String, whereValue As String) As boolean`

#### Events

None

---

## Requirements

- **Xojo:** Latest compatible version

## Installation

1. Clone or download this repository
2. Open the `.xojo_project` file in Xojo
3. Build and run the project

## Usage

[Add specific usage instructions for your application]

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

[Specify your license here]

---
*This README was automatically generated from the Xojo project file on 3 Jul 2025 at 9:28:58 am*
