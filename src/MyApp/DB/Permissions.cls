Class MyApp.Permissions Extends %Persistent
{

Property Name As %String [ Required ];

Property Description As %String;

Storage Default
{
<Data name="PermissionsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Description</Value>
</Value>
</Data>
<DataLocation>^MyApp.PermissionsD</DataLocation>
<DefaultData>PermissionsDefaultData</DefaultData>
<IdLocation>^MyApp.PermissionsD</IdLocation>
<IndexLocation>^MyApp.PermissionsI</IndexLocation>
<StreamLocation>^MyApp.PermissionsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
