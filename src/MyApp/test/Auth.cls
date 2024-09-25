Class MyApp.Auth
{

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
        Set storedPassword = $LIST(userRecord, 4)  // Предполагаем, что 2-й элемент — это пароль
        // Проверяем хэш пароля
        If ##class(MyApp.Users).HashPassword(pass) = storedPassword 
        {
            // Генерируем и возвращаем токен для успешной аутентификации
            Set token = ##class(MyApp.Tokens).CreateNewToken(userId)
            Return token
        } Else {
            Return "Invalid password"
        }
}

ClassMethod IsAuth(token As %String) As %Integer
{
    Set userId=##class(MyApp.Tokens).IsTokenValid(token)

    if userId >0
    {
        Quit userId
    }
    else
    {
        Quit "Error"
    }
}

ClassMethod LogOut(token As %String) As %Status
{
    Set status= ##class(MyApp.Tokens).InvalidateToken(token)
    Quit status
}

}
