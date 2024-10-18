Class MyApp.Lists Extends %Persistent
{

Property Title As %String(MAXLEN = 128) [ Required ];

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

ClassMethod CreateList(title As %String, description As %String, cardId As %Integer) As %Status
{
    If '$ISOBJECT(##class(MyApp.Cards).%OpenId(cardId)) {
        Return $$$ERROR($$$GeneralError, "Card not found")
    }
    Set list = ##class(MyApp.Tasks).%New()
    Set list.Title = title
    Set list.Description = description
    Set list.CardId = cardId
    Set status = list.%Save()
    If $$$ISERR(status) {
        Return $$$ERROR($$$GeneralError, "Failed to create list")
    }
    Return list.%Id()
}

ClassMethod UpdateListInfo(id As %Integer, title As %String, description As %String) As %Status
{
    Set list = ##class(MyApp.Lists).%OpenId(id)
    If list 
    {
        Set list.Title=title
        Set list.Description=description
        Set status = list.%Save()
        If $$$ISERR(status) {
            Return 0
        }
        Return $$$OK
    }
    Return $$$ERROR($$$GeneralError, "List not found")
}

ClassMethod DeleteList(id As %Integer) As %Status
{
    Set list = ##class(MyApp.Lists).%OpenId(id)
    If list 
    {
        Set tStatus= ##class(MyApp.Tasks).DeleteAllTasksForList(id) 
        If $$$ISOK(tStatus)
        {
            Set status = ..%DeleteId(id)
            If $$$ISERR(status) 
            {
                 Return $$$ERROR($$$GeneralError, "Error deleting list: "_ status)
            }
            Return $$$OK
        }
        Return $$$ERROR($$$GeneralError, "Error deleting tasks: "_ tStatus)
        
    }
    Return $$$ERROR($$$GeneralError, "List not found")
}

ClassMethod GetListsByCardId(cardId As %Integer) As %ListOfDataTypes
{
    Set lists = ##class(%Library.DynamicArray).%New()
    Set result = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM MyApp.Lists WHERE CardId = ?", cardId)
    While result.%Next() 
    {
        Do lists.%Push(result.ID)
    }
    /*
    For 
    {
        Set list = ##class(MyApp.Lists).%OpenIdNext(cardId, list)
        Quit:list=""
        Do lists.Insert(list.ID)
    }
    */
    Write lists
    For i=1,1 ,lists.lenght
    {
        Write "id ",lists.i,!
    }
    Return lists
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
