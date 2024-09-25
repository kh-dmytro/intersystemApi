Class MyApp.Users Extends %Persistent
{

Property UserName As %String;

Property Email As %String [ Required ];

Index EmailIdx On Email [ Unique ];

Property Password As %String [ Required ];

Property FirstName As %String;

Property LastName As %String;

Property CreationDate As %TimeStamp;

// Метод для автоматического заполнения поля CreationDate при сохранении записи

Method %OnNew() As %Status
{
        // Устанавливаем CreationDate только если оно еще не было задано
        If ..CreationDate = "" 
        {
                Set ..CreationDate = $ZDATETIME($HOROLOG,3)  // Преобразование временной метки в правильный формат
        }
        Quit $$$OK
}

ClassMethod HashPassword(password As %String) As %String
{
        // Используем встроенные возможности InterSystems для хеширования
        Set hashedPassword = $SYSTEM.Encryption.SHA1Hash(password)
        Quit hashedPassword
}

ClassMethod Authenticate(email As %String, pass As %String) As %Integer
{
          // Ищем пользователя по email
        Set userId = $ORDER(^MyApp.UsersI("EmailIdx", $ZCONVERT(" "_email, "U"), ""))
        
        If userId = "" {
            Return "User not found"
        }
       // Quit userId
        
        // Получаем запись пользователя
        Set userRecord = ^MyApp.UsersD(userId)
        Set storedPassword = $LIST(userRecord, 4)  
        // Проверяем хэш пароля
        If ..HashPassword(pass) = storedPassword 
        {
            // Генерируем и возвращаем токен для успешной аутентификации
            Set token = ##class(MyApp.Tokens).CreateNewToken(userId)
            Return token
        } Else {
            Return "Invalid password"
        }
}

Storage Default
{
<Data name="UsersDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>UserName</Value>
</Value>
<Value name="3">
<Value>Email</Value>
</Value>
<Value name="4">
<Value>Password</Value>
</Value>
<Value name="5">
<Value>FirstName</Value>
</Value>
<Value name="6">
<Value>LastName</Value>
</Value>
<Value name="7">
<Value>CreationDate</Value>
</Value>
</Data>
<DataLocation>^MyApp.UsersD</DataLocation>
<DefaultData>UsersDefaultData</DefaultData>
<IdLocation>^MyApp.UsersD</IdLocation>
<IndexLocation>^MyApp.UsersI</IndexLocation>
<StreamLocation>^MyApp.UsersS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
