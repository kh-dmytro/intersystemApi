Class MyApp.BoardAccess Extends %Persistent
{

Property BoardId As %Integer [ Required ];

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

Method UpdateAccessData(userId As %String, permissionId As %String) As %Status
{
         // Обновляем значения свойств
        Set ..UserId = userId
        Set ..PermissionId = permissionId
        // Сохраняем изменения
        Return ..%Save()
}

Storage Default
{
<Data name="BoardAccessDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>BoardId</Value>
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
<DataLocation>^MyApp.BoardAccessD</DataLocation>
<DefaultData>BoardAccessDefaultData</DefaultData>
<IdLocation>^MyApp.BoardAccessD</IdLocation>
<IndexLocation>^MyApp.BoardAccessI</IndexLocation>
<StreamLocation>^MyApp.BoardAccessS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
