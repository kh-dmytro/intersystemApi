Class MyApp.Boards Extends %Persistent
{

Property Title As %String [ Required ];

Property Description As %String(MAXLEN = 256);

Property OwnerId As %Integer [ Required ];

Property CreatedAt As %TimeStamp;

Property UpdatedAt As %TimeStamp;

Method %OnNew() As %Status
{
        // Устанавливаем CreationDate только если оно еще не было задано
     If ..CreatedAt = "" {
       // Устанавливаем текущее время для CreatedAt
    Set ..CreatedAt = $ZDATETIME($HOROLOG,3)
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
<Data name="BoardsDefaultData">
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
<Value>OwnerId</Value>
</Value>
<Value name="5">
<Value>CreatedAt</Value>
</Value>
<Value name="6">
<Value>UpdatedAt</Value>
</Value>
</Data>
<DataLocation>^MyApp.BoardsD</DataLocation>
<DefaultData>BoardsDefaultData</DefaultData>
<IdLocation>^MyApp.BoardsD</IdLocation>
<IndexLocation>^MyApp.BoardsI</IndexLocation>
<StreamLocation>^MyApp.BoardsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
