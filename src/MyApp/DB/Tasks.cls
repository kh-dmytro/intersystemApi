Class MyApp.Tasks Extends %Persistent
{

Property Title As %String [ Required ];

Property IsCompleted As %Boolean;

Property ListId As %Integer [ Required ];

Property CreatedAt As %TimeStamp;

Property UpdatedAt As %TimeStamp;

Method %OnNew() As %Status
{
        // Устанавливаем CreationDate только если оно еще не было задано
     If ..CreatedAt = "" {
        Set ..CreatedAt = $ZDATETIME($HOROLOG,3)  // Преобразование временной метки в правильный формат
        Set ..IsCompleted=0
    }

    Quit $$$OK
}

// Метод для автоматического заполнения поля UpdatedAt при сохранении записи

Method %OnSave() As %Status
{
    // Устанавливаем текущую дату и время в поле UpdatedAt при любом сохранении объекта
    Set ..UpdatedAt = $ZDATETIME($HOROLOG,3)

    // Продолжаем стандартный процесс сохранения
    Quit $$$OK
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
