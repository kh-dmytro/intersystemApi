Class MyApp.main
{

ClassMethod Main()
{
    // Создаем новый объект класса MyApp.Users
    Set newUser = ##class(MyApp.Users).%New()

    // Устанавливаем значения свойств
    Set newUser.UserName = "johndoe12111"
    Set newUser.Email = "john.doe@example.com"
    Set newUser.Password = "password123"
    Set newUser.FirstName = "John123"
    Set newUser.LastName = "Doe123"

    // Сохраняем объект
    Set status = newUser.%Save()

    // Проверка успешности сохранения
    If $$$ISOK(status) {
    Write "User created successfully!", !
    } Else {
    Write "Error creating user: ", status.GetErrorText(), !
    }
}

}
