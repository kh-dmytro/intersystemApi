Class MyApp.ApiHandler Extends MyApp.REST.Base
{

Parameter Version = 1.0;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>

<Route Url="/" Method="GET" Call="GetInfo" Cors="true"/>
<Route Url="/login" Method="POST" Call="Login"/>
<Route Url="/logout" Method="POST" Call="Logout"/>  
<Route Url="/register" Method="POST" Call="Registration"/>  <!-- изменение на более распространённый "register" -->
<Route Url="/userdata" Method="GET" Call="GetUserData"/>  <!-- изменение на REST стиль -->

<!-- Работа с досками -->
<Route Url="/boards" Method="GET" Call="GetUserBoards"/>  <!-- получение всех досок пользователя -->
<Route Url="/boards" Method="POST" Call="CreateNewBoard"/>  <!-- создание новой доски -->
<Route Url="/boards/allowed" Method="GET" Call="GetAllowedBoards"/>  <!-- получение досок с доступом -->
<Route Url="/boards/:boardId" Method="PUT" Call="UpdateBoard"/>  <!-- обновление доски -->
<Route Url="/boards/:boardId" Method="DELETE" Call="DeleteBoard"/>  <!-- удаление доски -->
<!-- Работа с карточками -->
<Route Url="/boards/:boardId/cards" Method="GET" Call="GetBoardCards"/>  <!-- получение карточек для доски -->
 <Route Url="/boards/:boardId/cards" Method="POST" Call="CreateNewCard"/>  <!-- создание новой карточки -->
<Route Url="/cards/:cardId" Method="PUT" Call="UpdateCard"/>  <!-- обновление карточки -->
<Route Url="/cards/:cardId" Method="DELETE" Call="DeleteCard"/>  <!-- удаление карточки -->
<!-- Работа с чеклистами -->
<Route Url="/cards/:cardId/checklists" Method="GET" Call="GetCardLists"/>  <!-- получение чеклистов для карточки -->
<Route Url="/cards/:cardId/checklists" Method="POST" Call="CreateNewChecklist"/>   <!-- создание нового чеклиста -->
<Route Url="/checklists/:checklistId" Method="PUT" Call="UpdateChecklist"/>  <!-- обновление чеклиста -->
<Route Url="/checklists/:checklistId" Method="DELETE" Call="DeleteChecklist"/>  <!-- удаление чеклиста -->
<!-- Работа с задачами -->
<Route Url="/checklists/:checklistId/tasks" Method="GET" Call="GetListTasks"/>  <!-- получение задач для чеклиста -->
 <Route Url="/checklists/:checklistId/tasks" Method="POST" Call="CreateNewTask"/>   <!-- создание новой задачи -->
<Route Url="/tasks/update" Method="POST" Call="UpdateTasks"/>  <!-- обновление задачи -->
<Route Url="/tasks/:taskId" Method="DELETE" Call="DeleteTask"/>  <!-- удаление задачи -->
<Route Url="/tasks/:taskId/complete" Method="PUT" Call="TaskCompleted"/>  
<!-- Пользователи -->
<Route Url="/users/update" Method="POST" Call="UpdateUser"/>  <!-- обновление пользователя -->
<!-- Шаринг досок -->
<Route Url="/boards/:boardId/share" Method="POST" Call="ShareBoard"/>  <!-- расшаривание доски для других пользователей -->




<Route Url="/auth" Method="POST" Call="Auth"/>
<!-- Swagger specs -->
<Route Url="/_spec" Method="GET" Call="SwaggerSpec" />  
</Routes>
}

ClassMethod GetTest()
{
    Set version = ..#Version
    Set info = 
    {
    "version": (version)
    }
    Return ..%ProcessResult($$$OK, info)
}

ClassMethod TaskCompleted(taskId As %Integer)
{
    Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        If userId = 0 
        {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
        Set data = %request.Content
        If 'taskId
        {
            Throw ##class(%Exception.General).%New("Wrong task ID")
        }
        If '$Data(^MyApp.TasksD(taskId)) 
        {
            Throw ##class(%Exception.General).%New("Task not found")
        }
        // Получение boardId на основе taskId
        Set boardId = ##class(MyApp.AccessControl).GetBoardIdByTask(taskId)
        If boardId = "" {
            Throw ##class(%Exception.General).%New("Board ID not found for the given task")
        }
        // Проверка прав владельца
        Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, boardId)
        // Если не владелец, проверяем другие права доступа
        If isOwner '= 1 
        {
            Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, boardId)
            // Проверка прав пользователя
            If (CheckPermission '= 1) && (CheckPermission '= 2)   
            {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }
        }
        Set data=%request.Content
        If $DATA(^MyApp.TasksD(taskId)) 
        {
            Set $LIST(^MyApp.TasksD(taskId), 3)=data.IsCompleted
            Set $LIST(^MyApp.TasksD(taskId), 5)=$ZDATETIME($HOROLOG,3)
            Return ..SendSuccessResponse("")
        }
        Else
        {
            Return ..SendErrorResponse("Task not found")
        } 
    } 
    Catch ex 
    {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
}

ClassMethod GetUserBoards()
{
   Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        If userId = 0 
        {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
        Set data=%request.Content
        Set boardList = ##class(MyApp.GetFunctions).GetBoards(userId)
       // If boardList '=0
        If ($IsObject(boardList)) && (boardList.%Size() > 0)
        {
            Set data = {"boards":(boardList) }
            Return ..SendSuccessResponse(data)
        }
        Else
        {
            Return ..SendErrorResponse("Boards not found")
        }
    } 
    Catch ex 
    {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
}

ClassMethod GetBoardCards(boardId As %Integer) As %DynamicArray
{
    Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        If userId = 0 
        {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
       
        If '$Data(^MyApp.BoardsD(boardId)) 
        {
            Throw ##class(%Exception.General).%New("Board not found")
        }
        Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, boardId)
        // Если не владелец, проверяем другие права доступа
        If isOwner '= 1 
        {
            Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, boardId)
            // Проверка прав пользователя
            If (CheckPermission '= 1) && (CheckPermission '= 2)  && (CheckPermission '= 3) 
            {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }
        }
        
        // Получение списка задач
        Set cardList = ##class(MyApp.GetFunctions).GetCards(boardId)
        If ($IsObject(cardList)) && (cardList.%Size() > 0)
        {
            Set data = {"cards":(cardList) }
            Return ..SendSuccessResponse(data)
        }
        Else 
        {
            Return ..SendErrorResponse("Cards not found")
        }
        // Успешное завершение
        Return ..SendSuccessResponse("")
    } 
    Catch ex 
    {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
}

ClassMethod GetCardLists(cardId As %Integer) As %DynamicArray
{
    Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        If userId = 0 
        {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
       
        If '$Data(^MyApp.CardsD(cardId)) 
        {
            Throw ##class(%Exception.General).%New("Card not found")
        }
        Set boardId = ##class(MyApp.AccessControl).GetBoardIdByCard(cardId)
        If boardId = "" {
            Throw ##class(%Exception.General).%New("Board ID not found for the given lists")
        }
        // Проверка прав владельца
        Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, boardId)
        // Если не владелец, проверяем другие права доступа
        If isOwner '= 1 
        {
            Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, boardId)
            // Проверка прав пользователя
            If (CheckPermission '= 1) && (CheckPermission '= 2)  && (CheckPermission '= 3) 
            {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }
        }
        
        // Получение списка задач
        Set checkList = ##class(MyApp.GetFunctions).GetLists(cardId)
        If ($IsObject(checkList)) && (checkList.%Size() > 0)
        {
            Set data = {"checklists":(checkList) }
            Return ..SendSuccessResponse(data)
        }
        Else 
        {
            Return ..SendErrorResponse("Lists not found")
        }
        // Успешное завершение
        Return ..SendSuccessResponse("")
    } 
    Catch ex 
    {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
}

ClassMethod GetListTasks(checklistId As %Integer) As %DynamicArray
{
    Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        If userId = 0 
        {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
        If 'checklistId 
        {
            Throw ##class(%Exception.General).%New("Wrong checklist ID")
        }
        If '$Data(^MyApp.ListsD(checklistId)) 
        {
            Throw ##class(%Exception.General).%New("Checklist not found")
        }
        // Получение boardId на основе taskId
        Set boardId = ##class(MyApp.AccessControl).GetBoardIdByList(checklistId)
        If boardId = "" {
            Throw ##class(%Exception.General).%New("Board ID not found for the given task")
        }
        // Проверка прав владельца
        Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, boardId)
        // Если не владелец, проверяем другие права доступа
        If isOwner '= 1 
        {
            Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, boardId)
            // Проверка прав пользователя
            If (CheckPermission '= 1) && (CheckPermission '= 2)  && (CheckPermission '= 3) 
            {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }
        }
        
        // Получение списка задач
        Set taskList = ##class(MyApp.GetFunctions).GetTasks(checklistId)
        If ($IsObject(taskList)) && (taskList.%Size() > 0)
        {
            Set data = {"tasks": (taskList)}
            Return ..SendSuccessResponse(data)
        }
        Else 
        {
            Return ..SendErrorResponse("Tasks not found")
        }
        // Успешное завершение
        Return ..SendSuccessResponse("")
    } 
    Catch ex 
    {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
}

ClassMethod GetAllowedBoards()
{
    Set userId=..IsAuth()
    If userId '= 0 
    {  
        Set boardList = ##class(MyApp.GetFunctions).GetAllowedBoard(userId)
        If boardList '=0
        {
            Set data = {"boards":(boardList) }
            Return ..SendSuccessResponse(data)
        }
        Else
        {
            Return ..SendErrorResponse("Boards not found")
        }
    }
    Else 
    {
        Return ..SendErrorResponse("Invalid token")
    }
}

ClassMethod DeleteBoard(boardId As %Integer)
{
    Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        If userId = 0 
        {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
        Set data = %request.Content
        // Проверка прав владельца
        If '$Data(^MyApp.BoardsD(boardId)) 
        {
            Throw ##class(%Exception.General).%New("Board not found")
        }
        Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, boardId)
        // Если не владелец, проверяем другие права доступа
        If isOwner '= 1 
        {
            Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, boardId)
            // Проверка прав пользователя
            If CheckPermission '= 1
            {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }  
        }
       
        Set status=##class(MyApp.DeleteFunctions).DeleteBoard(boardId)
        If $$$ISERR(status) 
        {
            Throw ##class(%Exception.General).%New("Failed to delete board")
        }
        // Успешное удаление
        Return ..SendSuccessResponse("")
    }
    Catch ex {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
}

ClassMethod DeleteCard(cardId As %Integer)
{
 Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        //write "userId ",userId,!
        If userId = 0 {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
        // Получение данных из запроса
        Set data = %request.Content
        If 'cardId
        {
            Throw ##class(%Exception.General).%New("Wrong card Id")
        }
        If '$Data(^MyApp.CardsD(cardId)) 
        {
            Throw ##class(%Exception.General).%New("Card not found")
        }
        Set boardId = ##class(MyApp.AccessControl).GetBoardIdByCard(cardId)
        //write "board Id",boardId,!
        If boardId = "" {
            
            Throw ##class(%Exception.General).%New("Board ID not found for the given card")
        }
        
        // Проверка прав владельца
        Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, boardId)
        // Если не владелец, проверяем другие права доступа
        If isOwner '= 1 {
           // Write "Is owner",isOwner,!
            Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, boardId)
            //Write "permission",CheckPermission,!
            // Проверка прав пользователя
            If CheckPermission '= 1
            {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }  
        }
       
        Set status=##class(MyApp.DeleteFunctions).DeleteCard(cardId)
        If $$$ISERR(status) {
            Throw ##class(%Exception.General).%New("Failed to delete card")
        }
        // Успешное удаление
        Return ..SendSuccessResponse("")
    }
    Catch ex {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
}

ClassMethod DeleteChecklist(checklistId As %Integer)
{
    Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        //write "userId ",userId,!
        If userId = 0 {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
        If 'checklistId
        {
            Throw ##class(%Exception.General).%New("Wrong checklist Id")
        }
        If '$Data(^MyApp.ListsD(checklistId)) 
        {
            Throw ##class(%Exception.General).%New("Checklist not found")
        }
        Set boardId = ##class(MyApp.AccessControl).GetBoardIdByList(checklistId)
        //write "board Id",boardId,!
        If boardId = "" {
            
            Throw ##class(%Exception.General).%New("Board ID not found for the given list")
        }
        // Проверка прав владельца
        Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, boardId)
        // Если не владелец, проверяем другие права доступа
        If isOwner '= 1 {
           // Write "Is owner",isOwner,!
            Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, boardId)
            //Write "permission",CheckPermission,!
            // Проверка прав пользователя
            If CheckPermission '= 1
            {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }  
        }
       
        Set status=##class(MyApp.DeleteFunctions).DeleteList(checklistId)
        If $$$ISERR(status) {
            Throw ##class(%Exception.General).%New("Failed to delete list")
        }
        // Успешное удаление
        Return ..SendSuccessResponse("")
    }
    Catch ex {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
}

ClassMethod DeleteTask(taskId As %Integer)
{
    Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        If userId = 0 {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
        If 'taskId
        {
            Throw ##class(%Exception.General).%New("Wrong task Id")
        }
        If '$Data(^MyApp.TasksD(taskId)) 
        {
            Throw ##class(%Exception.General).%New("Task not found")
        }
        Set boardId = ##class(MyApp.AccessControl).GetBoardIdByTask(taskId)
        If boardId = "" {
            Throw ##class(%Exception.General).%New("Board ID not found for the given task")
        }
        // Проверка прав владельца
        Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, boardId)
        // Если не владелец, проверяем другие права доступа
        If isOwner '= 1 {
            Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, boardId)
            // Проверка прав пользователя
            If CheckPermission '= 1
            {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }
        }
        // Удаление задачи
        Set status = ##class(MyApp.DeleteFunctions).DeleteTask(taskId)
        If $$$ISERR(status) {
            Throw ##class(%Exception.General).%New("Failed to delete task")
        }
        // Успешное удаление
        Return ..SendSuccessResponse("")
    }
    Catch ex {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
}

ClassMethod CreateNewBoard()
{
    Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        If userId = 0 {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
        // Получение данных из запроса
        Set data = %request.Content
       
        Set boardId = ##class(MyApp.CreateFunctions).CreateBoard(userId,data.title,data.description)
        If boardId '= 0 
        {
            Set data = {"boardId":(boardId) }
            Return ..SendSuccessResponse(data)
        }
        Else
        {   
            Return ..SendErrorResponse("Failed to create board")    
        }
        
        If $$$ISERR(boardId) {
            Throw ##class(%Exception.General).%New("Failed to create board")
        }
        // Успешное удаление
        Return ..SendSuccessResponse("")
    }
    Catch ex {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
    /*
    Set respons=..IsAuth()
    If respons '= 0
    {
        Set data=%request.Content
        Set boardId = ##class(MyApp.CreateFunctions).CreateBord(respons,data.title,data.description)
        If boardId '= 0 
        {
            Set data = {"boardId":(boardId) }
            Return ..SendSuccessResponse(data)
        }
        Else
        {   
            Return ..SendErrorResponse("Failed to create board")    
        }
    }
    Else
    {
        Return ..SendErrorResponse("Invalid token")
    }
    */
}

ClassMethod CreateNewCard(boardId As %Integer)
{
    Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        If userId = 0 {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
        // Получение данных из запроса
        Set data = %request.Content
        If 'boardId
        {
            Throw ##class(%Exception.General).%New("Wrong board Id")
        }
        If '$Data(^MyApp.BoardsD(boardId)) 
        {
            Throw ##class(%Exception.General).%New("Board not found")
        }
        // Проверка прав владельца
        Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, boardId)
        // Если не владелец, проверяем другие права доступа
        If isOwner '= 1 {
            Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, boardId)
            // Проверка прав пользователя
            If (CheckPermission '= 1) && (CheckPermission '= 2)
            {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }
        }
        // Удаление задачи
        Set cardId = ##class(MyApp.CreateFunctions).CreateCard(userId,boardId, data.title,data.description)
        If cardId'= 0 
        {
            Set data = {"cardId":(cardId) }
            Return ..SendSuccessResponse(data)
        }
        Else
        {   
            Return ..SendErrorResponse("Failed to create card")    
        }
        If $$$ISERR(cardId) {
            Throw ##class(%Exception.General).%New("Failed to create card")
        }
        // Успешное удаление
        Return ..SendSuccessResponse("")
    }
    Catch ex {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
    /*
    Set respons=..IsAuth()
    If respons '= 0
    {
        Set data=%request.Content        
        Set cardId = ##class(MyApp.CreateFunctions).CreateCard(respons,data.boardId, data.title,data.description)
        If cardId'= 0 
        {
            Set data = {"cardId":(cardId) }
            Return ..SendSuccessResponse(data)
        }
        Else
        {   
            Return ..SendErrorResponse("Failed to create card")    
        }
    }
    Else
    {
        Return ..SendErrorResponse("Invalid token")
    }
    */
}

ClassMethod CreateNewChecklist(cardId As %Integer)
{
    Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        If userId = 0 {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
        // Получение данных из запроса
        Set data = %request.Content
        If 'cardId
        {
            Throw ##class(%Exception.General).%New("Wrong card Id")
        }
        If '$Data(^MyApp.CardsD(cardId)) 
        {
            Throw ##class(%Exception.General).%New("Card not found")
        }
        Set boardId = ##class(MyApp.AccessControl).GetBoardIdByCard(cardId)
        If boardId = "" {
            Throw ##class(%Exception.General).%New("Board ID not found for the given card")
        }
        // Проверка прав владельца
        Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, boardId)
        // Если не владелец, проверяем другие права доступа
        If isOwner '= 1 {
            Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, boardId)
            // Проверка прав пользователя
            If (CheckPermission '= 1) && (CheckPermission '= 2)
            {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }
        }
        Set checklistId = ##class(MyApp.CreateFunctions).CreateChecklist(cardId ,data.title ,data.description)
        If checklistId '= 0
        {
            If $ISOBJECT(data.tasks) 
            {
                Set taskList = ##class(%Library.DynamicArray).%New()
                Set count = data.tasks.%Size() 
                For i=0:1:count-1 
                {
                    Set task = data.tasks.%Get(i)
                    Set taskId =##class(MyApp.CreateFunctions).CreateTask(checklistId,task)
                    If taskId '=0
                    {
                        Do taskList.%Push(taskId)
                    }
                }
            }
            Set data = {"checklistId":(checklistId), "tasks":(taskList) }
            Return ..SendSuccessResponse(data)
        }
        Else
        {
            Return ..SendErrorResponse("Failed to create Checklist") 
        }
    }
    Catch ex {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
    /*
    Set userId=..IsAuth()
    If userId '= 0
    {
        Set data=%request.Content
        Set checklistId = ##class(MyApp.CreateFunctions).CreateChecklist(data.cardId ,data.title ,data.description)
        If checklistId '= 0
        {
            If $ISOBJECT(data.tasks) 
            {
                Set taskList = ##class(%Library.DynamicArray).%New()
                Set count = data.tasks.%Size() 
                For i=0:1:count-1 
                {
                    Set task = data.tasks.%Get(i)
                    Set taskId =##class(MyApp.CreateFunctions).CreateTask(checklistId,task)
                    If taskId '=0
                    {
                        Do taskList.%Push(taskId)
                    }
                }
            }
            Set data = {"cahecklistId":(checklistId), "tasks":(taskList) }
            Return ..SendSuccessResponse(data)
        }
        Else
        {
            Return ..SendErrorResponse("Failed to create Checklist") 
        }
    }
    Else
    {
         Return ..SendErrorResponse("Invalid token")
    }
    */
}

ClassMethod CreateNewTask(checklistId As %Integer)
{
     Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        If userId = 0 {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
        // Получение данных из запроса
        Set data = %request.Content
        If 'checklistId
        {
            Throw ##class(%Exception.General).%New("Wrong checklist Id")
        }
        If '$Data(^MyApp.ListsD(checklistId)) 
        {
            Throw ##class(%Exception.General).%New("Checklist not found")
        }
        Set boardId = ##class(MyApp.AccessControl).GetBoardIdByList(checklistId)
        If boardId = "" {
            Throw ##class(%Exception.General).%New("Board ID not found for the given list")
        }
        // Проверка прав владельца
        Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, boardId)
        // Если не владелец, проверяем другие права доступа
        If isOwner '= 1 {
            Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, boardId)
            // Проверка прав пользователя
            If (CheckPermission '= 1) && (CheckPermission '= 2)
            {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }
        }
        If $ISOBJECT(data.tasks) 
        {       
            Set taskList = ##class(%Library.DynamicArray).%New()
            Set count = data.tasks.%Size() 
            For i=0:1:count-1 
            {
                Set task = data.tasks.%Get(i)
                Set taskId =##class(MyApp.CreateFunctions).CreateTask(checklistId,task)
                If taskId '= 0
                {
                    Do taskList.%Push(taskId)
                }   
            }
            Set data = {"tasks":(taskList) }
            Return ..SendSuccessResponse(data) 
        }
        Else
        {
            Return ..SendErrorResponse("Failed to create task") 
        }
    }
    Catch ex {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
}

ClassMethod UpdateUser()
{
    Try 
    {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        If userId = 0 {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
        Set password=""
        
        Set data=%request.Content
        Set user = ##class(MyApp.Users).%OpenId(userId)
        If (user '= "") 
        {
            Set checkEmail=$ORDER(^MyApp.UsersI("EmailIdx", $ZCONVERT(" "_data.email, "U"), ""))
            if checkEmail '=""
            {
                Throw ##class(%Exception.General).%New("Email already exists")
                
            }
            if (data.oldPassword '= "") && (data.newPassword '="")
            {
                Set checkPass=##class(MyApp.Users).CheckPass(userId,data.oldPassword)
                if checkPass =0
                {
                    Throw ##class(%Exception.General).%New("Wrong password")
                }
                Set password=data.newPassword
            }
            // Обновление информации о пользователе
            Set status = user.UpdateUserData(data.userName, data.email,data.newPassword,data.firstName,data.lastName)
            
            If $$$ISERR(status) 
            {
                Throw ##class(%Exception.General).%New("Error updating user: "_ status)
            } 
            Else 
            {
                Return ..SendSuccessResponse("")
               // Write "User updated successfully!"
            }
        } 
       
       /* Set data=%request.Content
        if (data.oldPassword '= "") && (data.newPassword '="")
        {
            Set checkPass=##class(MyApp.Users).CheckPass(userId,data.oldPassword)
            if checkPass =0
            {
                Throw ##class(%Exception.General).%New("Wrong password")
            }
            Set password=data.newPassword
        }
        Set status=##class(MyApp.UpdateFunctions).UpdateUserData(userId,data.email,data.userName,data.firstName,data.lastName,password)
        If status = $$$OK
        {
            Return ..SendSuccessResponse("")
        }

        */
        Else
        {
            Throw ##class(%Exception.General).%New(status)
        }
    }
    Catch ex {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
}

ClassMethod UpdateBoard(boardId As %Integer)
{
      Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        If userId = 0 {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
        // Получение данных из запроса
        Set data = %request.Content
        // Проверка прав владельца
        Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, boardId)
        If '$Data(^MyApp.BoardsD(boardId)) 
        {
            Throw ##class(%Exception.General).%New("Board not found")
        }
        // Если не владелец, проверяем другие права доступа
        If isOwner '= 1 
        {
            Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, boardId)
            // Проверка прав пользователя
            If CheckPermission '= 1
            {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }
        }
        Set status=##class(MyApp.UpdateFunctions).UpdateBoard(boardId,data.title,data.description)
        If status = $$$OK
        {
            Return ..SendSuccessResponse("")
        }
        Else
        {
             Return ..SendErrorResponse(status)
        } 
    }
    Catch ex {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
}

ClassMethod UpdateCard(cardId As %Integer)
{

    Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        If userId = 0 {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
        // Получение данных из запроса
        Set data = %request.Content
        If '$Data(^MyApp.CardsD(cardId)) 
        {
            Throw ##class(%Exception.General).%New("Card not found")
        }
        Set boardId = ##class(MyApp.AccessControl).GetBoardIdByCard(cardId)
        If boardId = "" {
            Throw ##class(%Exception.General).%New("Board ID not found for the given list")
        }
        // Проверка прав владельца
        Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, boardId)
        // Если не владелец, проверяем другие права доступа
        If isOwner '= 1 
        {
            Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, boardId)
            // Проверка прав пользователя
            If CheckPermission '= 1
            {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }
        }
        Set status=##class(MyApp.UpdateFunctions).UpdateCard(cardId,data.title,data.description)
        If status = $$$OK
        {
            Return ..SendSuccessResponse("")
        }
        Else
        {
             Return ..SendErrorResponse(status)
        }
    }
    Catch ex {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
}

ClassMethod UpdateChecklist(checklistId As %Integer)
{
     Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        If userId = 0 {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
        // Получение данных из запроса
        Set data = %request.Content
        If 'checklistId
        {
            Throw ##class(%Exception.General).%New("Wrong checklist id parameter")
        }
        If '$Data(^MyApp.ListsD(checklistId)) 
        {
            Throw ##class(%Exception.General).%New("Checklist not found")
        }
        Set boardId = ##class(MyApp.AccessControl).GetBoardIdByList(checklistId)
        If boardId = "" {
            Throw ##class(%Exception.General).%New("Board ID not found for the given list")
        }
        // Проверка прав владельца
        Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, boardId)
        // Если не владелец, проверяем другие права доступа
        If isOwner '= 1 
        {
            Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, boardId)
            // Проверка прав пользователя
            If CheckPermission '= 1
            {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }
        }
        Set status=##class(MyApp.UpdateFunctions).UpdateList(checklistId,data.title,data.description)
        If status = $$$OK
        {
            If $ISOBJECT(data.tasks) 
            {
                
                Set count = data.tasks.%Size() 
                For i=0:1:count-1 
                {
                    Set task = data.tasks.%Get(i)
                    Set taskId =##class(MyApp.UpdateFunctions).UpdateTask(task.taskId,task.title)
                }
            }
            Return ..SendSuccessResponse("")
        }
        Else
        {
             Return ..SendErrorResponse(status)
        }  
    }
    Catch ex {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
}

ClassMethod UpdateTasks()
{
    Try {
    // Проверка аутентификации
    Set userId = ..IsAuth()
    If userId = 0 {
        Throw ##class(%Exception.General).%New("Invalid token")
    }

    // Получение данных из запроса
    Set data = %request.Content
    If 'data.tasks || '$IsObject(data.tasks) {
        Throw ##class(%Exception.General).%New("Tasks parameter is missing or invalid")
    }

    // Проверка прав владельца для одной из задач, чтобы не делать это на каждую задачу
    Set firstTaskId = data.tasks.%Get(0).taskId
    If '$Data(^MyApp.TasksD(firstTaskId)) {
        Throw ##class(%Exception.General).%New("Task not found")
    }
    
    Set boardId = ##class(MyApp.AccessControl).GetBoardIdByTask(firstTaskId)
    If boardId = "" {
        Throw ##class(%Exception.General).%New("Board ID not found for the given task")
    }

    // Проверка прав владельца
    Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, boardId)
    If isOwner '= 1 {
        Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, boardId)
        If CheckPermission '= 1 {
            Throw ##class(%Exception.General).%New("User does not have permission")
        }
    }

    // Обновление задач
    Set count = data.tasks.%Size()
    For i = 0:1:count-1 {
        Set task = data.tasks.%Get(i)
        If '$Data(^MyApp.TasksD(task.taskId)) {
            Throw ##class(%Exception.General).%New("Task with ID "_task.taskId_" not found")
        }

        // Обновляем задачу
        Set taskId = ##class(MyApp.UpdateFunctions).UpdateTask(task.taskId, task.title)
        If $$$ISERR(taskId) {
            Throw ##class(%Exception.General).%New("Failed to update task with ID "_task.taskId)
        }
    }

    // Успешное завершение
    Return ..SendSuccessResponse("")
    }
    Catch ex {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
}

ClassMethod ShareBoard(boardId As %Integer)
{
    Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        If userId = 0 {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
        // Получение данных из запроса
        Set data = %request.Content
        If 'boardId
        {
            Throw ##class(%Exception.General).%New("Wrong  Board ID")
        }
        If 'data.permission
        {
            Throw ##class(%Exception.General).%New("Wrong  Permission")
        }
        If '$Data(^MyApp.BoardsD(boardId)) 
        {
            Throw ##class(%Exception.General).%New("Board not found")
        }
        
        // Проверка прав владельца
        Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, boardId)
        // Если не владелец, проверяем другие права доступа
        If isOwner '= 1 
        {
            Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, boardId)
            // Проверка прав пользователя
            If CheckPermission '= 1
            {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }
        }
        Set recipientId=$ORDER(^MyApp.UsersI("EmailIdx", $ZCONVERT(" "_data.email, "U"), ""))
        If recipientId '=""
        { 
            if ..isBoardShared(recipientId,boardId) = 1
            {
                Throw ##class(%Exception.General).%New("You have already shared the board with "_data.email)
            }
            Set status=##class(MyApp.CreateFunctions).CreateSharedBoard(userId,boardId,recipientId,data.permission)
            If status '=0
            {
                Return ..SendSuccessResponse("")
            }
            Else
            {
                Return ..SendErrorResponse(status)
            }
        }
        Else
        {
           Return ..SendErrorResponse("Recipient not found")
        }
    }
    Catch ex {
        // Логирование ошибки и возврат ответа
        Return ..SendErrorResponse(ex.DisplayString())
    }
}

ClassMethod isBoardShared(userId As %Integer, boardId As %Integer) As %Boolean
{
    Set result = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM MyApp.BoardAccess WHERE BoardId = ? AND UserId = ?", boardId, userId)
    If result.%Next() 
    {
        Return 1
    }
    else
    {
        Return 0
    }
}

ClassMethod SendSuccessResponse(data As %DynamicObject)
{
    Set info = {"Success": "true"}
    If data '= "" 
    {
        Set iter = data.%GetIterator()
        While iter.%GetNext(.key, .value) 
        {
            Do info.%Set(key, value)  
        }
    }
    Return ..%ProcessResult($$$OK, info)
}

ClassMethod SendErrorResponse(error As %String) As %Status
{
    Set info = {"Success": "false","error": (error)}
    Return ..%ProcessResult($$$OK, info)
}

ClassMethod Auth()
{
    Set authHeader = %request.GetCgiEnv("HTTP_AUTHORIZATION")
    Set token = $PIECE(authHeader, " ", 2)
    Set respons=##class(MyApp.Auth).IsAuth(token)
    If respons '= 0
    {
        Return ..SendSuccessResponse("")
    }
    Else
    {
        Return ..SendErrorResponse("Invalid token") 
    }
}

ClassMethod IsAuth()
{
    Set authHeader = %request.GetCgiEnv("HTTP_AUTHORIZATION")
    Set token = $PIECE(authHeader, " ", 2)
    Set respons=##class(MyApp.Auth).IsAuth(token)
    Return respons
}

ClassMethod GetUserData()
{
    Set authHeader = %request.GetCgiEnv("HTTP_AUTHORIZATION")
    Set token = $PIECE(authHeader, " ", 2)
    Set respons=##class(MyApp.Auth).IsAuth(token)
    If respons '= 0
    {
        // Do ..SendSuccessResponse()
        Set userdata= ^MyApp.UsersD(respons)  
        Set info = 
        {
            "Success": "true",
            "username": ($LIST(userdata, 2)),
            "email": ($LIST(userdata, 3)),
            "firstName": ($LIST(userdata, 5)),
            "lastName": ($LIST(userdata, 6)),
            "user_id":(respons)
        }
        Return ..%ProcessResult($$$OK, info)
     }
     Else
     {
        Return ..SendErrorResponse("Invalid token") 
     }
}

ClassMethod Login() As %Status
{
   
    Set data=%request.Content
    Set email =data.email
    Set pass=data.password
    Set token = ##class(MyApp.Auth).Authenticate(email,pass)
   
    If token '= 0
    {
        Set result=
        {
        "token":(token)  
        }
        Return ..SendSuccessResponse(result)
    }
    Else 
    {
         Return ..SendErrorResponse("User not found")
    }
}

ClassMethod Logout()
{
    Set authHeader = %request.GetCgiEnv("HTTP_AUTHORIZATION")
    Set token = $PIECE(authHeader, " ", 2)
    Set status= ##class(MyApp.Tokens).InvalidateToken(token)
    If status = 1
    {
        Return ..SendSuccessResponse("")
    }
    Else
    {
       Return ..SendErrorResponse("Invalid token")
    }
}

ClassMethod Registration() As %Status
{
    Set data=%request.Content
    
        Set isCreated= ##class(MyApp.CreateFunctions).CreateUser(data.email,data.password,data.userName,data.firstName,data.lastName)
        If $$$ISOK(isCreated) 
        {
            Set token = ##class(MyApp.Auth).Authenticate( data.email,data.password)
            Set result=
            {
                "token": (token)
            }
            Return ..SendSuccessResponse(result)
        }
        Else 
        {
            Return ..SendErrorResponse(isCreated)
        }
}

/// testREST general information
ClassMethod GetInfo() As %Status
{
    Set version = ..#Version
    Set info = 
    {
        "version": (version)
    }
    Return ..%ProcessResult($$$OK, info)
}

/// Retreive all the records of MyApp.ApiHandler
ClassMethod SwaggerSpec() As %Status
{
    Set tSC = ##class(%REST.API).GetWebRESTApplication($NAMESPACE, %request.Application, .swagger)
    Do swagger.info.%Remove("x-ISC_Namespace")
    Set swagger.basePath = "/myapi"
    Set swagger.info.title = "InterSystems api"
    Set swagger.info.version = "0.1"
    Set swagger.host = "localhost:52773"
    Return ..%ProcessResult($$$OK, swagger)
}

}
