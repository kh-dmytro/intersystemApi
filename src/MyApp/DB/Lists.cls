Class MyApp.Lists Extends %Persistent
{

Property Title As %String [ Required ];

Property Description As %String(MAXLEN = 256);

Property CardId As %Integer [ Required ];

Property CreatedAt As %TimeStamp;

Property UpdatedAt As %TimeStamp;

Method %OnNew() As %Status
{
        // Устанавливаем CreationDate только если оно еще не было задано
     If ..CreatedAt = "" {
        Set ..CreatedAt = $ZDATETIME($HOROLOG,3)  // Преобразование временной метки в правильный формат
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
<Data name="ListsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Title</Value>
</Value>
<Value name="3">
<Value>Description</Value>
</Value>
<Value name="4">
<Value>CreatedAt</Value>
</Value>
<Value name="5">
<Value>UpdatedAt</Value>
</Value>
<Value name="6">
<Value>CardId</Value>
</Value>
</Data>
<DataLocation>^MyApp.ListsD</DataLocation>
<DefaultData>ListsDefaultData</DefaultData>
<IdLocation>^MyApp.ListsD</IdLocation>
<IndexLocation>^MyApp.ListsI</IndexLocation>
<StreamLocation>^MyApp.ListsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
