Class MyApp.CardAccess Extends %Persistent
{

Property CardId As %Integer [ Required ];

Property UserId As %Integer [ Required ];

Property GrantedBy As %Integer [ Required ];

Property PermissionId As %Integer [ Required ];

Property GrantedAt As %TimeStamp;

Method %OnNew() As %Status
{
    // Устанавливаем CreationDate только если оно еще не было задано
     If ..GrantedAt = "" {
        Set ..GrantedAt = $ZDATETIME($HOROLOG,3)  // Преобразование временной метки в правильный формат
    }
    Quit $$$OK
}

Method UpdateCardAccessData(userId As %Integer, permissionId As %Integer) As %Status
{
         // Обновляем значения свойств
        Set ..UserId = userId
        Set ..PermissionId = permissionId
        // Сохраняем изменения
        Return ..%Save()
}

Storage Default
{
<Data name="CardAccessDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>CardId</Value>
</Value>
<Value name="3">
<Value>UserId</Value>
</Value>
<Value name="4">
<Value>GrantedBy</Value>
</Value>
<Value name="5">
<Value>PermissionId</Value>
</Value>
<Value name="6">
<Value>GrantedAt</Value>
</Value>
</Data>
<DataLocation>^MyApp.CardAccessD</DataLocation>
<DefaultData>CardAccessDefaultData</DefaultData>
<IdLocation>^MyApp.CardAccessD</IdLocation>
<IndexLocation>^MyApp.CardAccessI</IndexLocation>
<StreamLocation>^MyApp.CardAccessS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
