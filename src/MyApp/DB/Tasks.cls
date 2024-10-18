Class MyApp.Tasks Extends %Persistent
{

Property Title As %String(MAXLEN = 256) [ Required ];

Property IsCompleted As %Boolean;

Property ListId As %Integer [ Required ];

ForeignKey fkList(ListId) References MyApp.Lists() [ OnDelete = cascade ];

Property CreatedAt As %TimeStamp;

Property UpdatedAt As %TimeStamp;

Method %OnNew() As %Status
{
    // Устанавливаем CreationDate только если оно еще не было задано
    If ..CreatedAt = "" 
    {
        Set ..CreatedAt = $ZDATETIME($HOROLOG,3)  // Преобразование временной метки в правильный формат
        Set ..IsCompleted=0
    }
    Quit $$$OK
}

Method %OnSave() As %Status
{
    Set ..UpdatedAt = $ZDATETIME($HOROLOG,3)
    Quit $$$OK
}

ClassMethod CreateTask(title As %String, listId As %Integer) As %Integer
{
    // Проверяем, существует ли лист с таким ID
    If '$ISOBJECT(##class(MyApp.Lists).%OpenId(listId)) {
        Return $$$ERROR($$$GeneralError, "List not found")
    }
    // Создаем новую задачу
    Set task = ##class(MyApp.Tasks).%New()
    Set task.Title = title
    Set task.ListId = listId
    Set status = task.%Save()
    If $$$ISERR(status) {
        Return $$$ERROR($$$GeneralError, "Failed to create task")
    }
    // Возвращаем ID новой задачи
    Return task.%Id()
}

ClassMethod GetTasksByListId(listId As %Integer) As %ListOfDataTypes
{
    Set tasks = ##class(%ListOfDataTypes).%New()
    Set task = ""
    For 
    {
        Set task = ##class(MyApp.Tasks).%OpenIdNext(listId, task)
        Quit:task=""
        Do tasks.Insert(task.ID)
    }
    Return tasks
}

ClassMethod UpdateTaskTitle(id As %Integer, title As %String) As %Status
{
    Set task = ##class(MyApp.Tasks).%OpenId(id)
    If task 
    {
        Set task.Title=title
        Set status = task.%Save()
        If $$$ISERR(status) {
            Return 0
        }
        Return $$$OK
    }
    Return $$$ERROR($$$GeneralError, "Task not found")
}

ClassMethod DeleteTask(id As %Integer) As %Status
{
    Set task = ##class(MyApp.Tasks).%OpenId(id)
    If task {
    Set status = ..%DeleteId(id)
    If $$$ISERR(status) {
        Return 0
    }
    Return $$$OK
    }
}

ClassMethod DeleteAllTasksForList(listId As %Integer) As %Status
{
    Set resultSet = ##class(%SQL.Statement).%ExecDirect(,"DELETE FROM MyApp.Tasks WHERE ListId = ?", listId)
    If $$$ISERR(resultSet.%SQLCODE) 
    { 
        Return $$$ERROR($$$GeneralError, "Failed to delete tasks for ListId "_listId)
    }
    Return $$$OK
}

ClassMethod GetTaskById(id As %Integer) As %DynamicObject
{
    Set task = ##class(MyApp.Tasks).%OpenId(id)
    If task {
        Set taskData = ##class(%Library.DynamicObject).%New()
        Do taskData.%Set("taskId", task.ID)
        Do taskData.%Set("title", task.Title)
        Do taskData.%Set("isCompleted", task.IsCompleted)
        Do taskData.%Set("listId", task.ListId)
        Do taskData.%Set("createdAt", task.CreatedAt)
        Do taskData.%Set("updatedAt", task.UpdatedAt)
        Return taskData
    }
    Return $$$ERROR($$$GeneralError, "Task not found")
}

ClassMethod MarkAsCompleted(id As %Integer) As %Status
{
    Set task = ..%OpenId(id)
    If 'task {
        Return $$$ERROR($$$GeneralError, "Task not found")
    }
    Set task.IsCompleted = 1
    Set status=task.%Save()
    If $$$ISERR(status)
    {
        Return status
    }
    Else
    {
        Return $$$OK
    }
}

ClassMethod MarkAsIncompleted(id As %Integer) As %Status
{
    Set task = ..%OpenId(id)
    If 'task {
        Return $$$ERROR($$$GeneralError, "Task not found")
    }
    Set task.IsCompleted = 0
    Set status=task.%Save()
    If $$$ISERR(status)
    {
        Return status
    }
    Else
    {
        Return $$$OK
    }
}

Storage Default
{
<Data name="TasksDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Title</Value>
</Value>
<Value name="3">
<Value>IsCompleted</Value>
</Value>
<Value name="4">
<Value>CreatedAt</Value>
</Value>
<Value name="5">
<Value>UpdatedAt</Value>
</Value>
<Value name="6">
<Value>ListId</Value>
</Value>
</Data>
<DataLocation>^MyApp.TasksD</DataLocation>
<DefaultData>TasksDefaultData</DefaultData>
<IdLocation>^MyApp.TasksD</IdLocation>
<IndexLocation>^MyApp.TasksI</IndexLocation>
<StreamLocation>^MyApp.TasksS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
