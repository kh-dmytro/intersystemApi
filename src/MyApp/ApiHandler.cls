Class MyApp.ApiHandler Extends MyApp.REST.Base
{

Parameter Version = 1.0;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<!-- Server Info -->
<Route Url="/" Method="GET" Call="GetInfo" Cors="true"/>
<Route Url="/login" Method="POST" Call="Login"/>
<Route Url="/logout" Method="POST" Call="Logout"/>  
<Route Url="/registration" Method="POST" Call="Registration"/>
<Route Url="/getusername" Method="GET" Call="GetUserName"/>
<Route Url="/createboard" Method="POST" Call="CreateNewBord"/>
<Route Url="/createcard" Method="POST" Call="CreateNewCard"/>
<Route Url="/createchecklist" Method="POST" Call="CreateNewChecklist"/>
<Route Url="/createtask" Method="POST" Call="CreateNewTask"/> 
<Route Url="/getboardsfromuser" Method="POST" Call="GetBoardsFromUser"/>
<Route Url="/getcardsfromboard" Method="POST" Call="GetCardsFromBoard"/>
<Route Url="/getlistsfromcard" Method="POST" Call="GetListsFromCard"/>
<Route Url="/gettaskfromlist" Method="POST" Call="GetTasksFromList"/> 
<Route Url="/getallowedboards" Method="POST" Call="GetAllowedBoards"/>
<Route Url="/deleteboard" Method="POST" Call="DeleteBoard"/>
<Route Url="/deletecard" Method="POST" Call="DeleteCard"/>
<Route Url="/deletelist" Method="POST" Call="DeleteList"/>
<Route Url="/deletetask" Method="POST" Call="DeleteTask"/>
<Route Url="/taskcompleted" Method="POST" Call="TaskCompleted"/>
<Route Url="/updateuser" Method="POST" Call="UpdateUser"/>
<Route Url="/updateboard" Method="POST" Call="UpdateBoard"/>
<Route Url="/updatecard" Method="POST" Call="UpdateCard"/>
<Route Url="/updatechecklist" Method="POST" Call="UpdateCheckList"/>
<Route Url="/updatetasks" Method="POST" Call="UpdateTasks"/>
<Route Url="/shareboard" Method="POST" Call="ShareBorad"/>


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

ClassMethod TaskCompleted()
{
    Set authHeader = %request.GetCgiEnv("HTTP_AUTHORIZATION")
    Set token = $PIECE(authHeader, " ", 2)
    Set respons = ##class(MyApp.Auth).IsAuth(token)
    If respons '= 0 
    {
        Set data=%request.Content
        If $DATA(^MyApp.TasksD(data.taskId)) 
        {
            Set $LIST(^MyApp.TasksD(data.taskId), 3)=data.IsCompleted
            Set $LIST(^MyApp.TasksD(data.taskId), 5)=$ZDATETIME($HOROLOG,3)
            
            Return ..SendSuccessResponse("")
        }
        Else
        {
            Return ..SendErrorResponse("Task not found")
        } 
    }
    Else 
    {
        Return ..SendErrorResponse("Invalid token")
    }
}

ClassMethod GetBoardsFromUser()
{
    Set userId=..IsAuth()
    If userId '= 0 
    {
        Set data=%request.Content
        Set boardList = ##class(MyApp.GetFunctions).GetBoards(userId)
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

ClassMethod GetCardsFromBoard() As %DynamicArray
{
    Set userId=..IsAuth()
    If userId '= 0 
    {
        Set data=%request.Content
        Set cardList = ##class(MyApp.GetFunctions).GetCards(data.boardId)
        If cardList '=0
        {
            Set data = {"cards":(cardList) }
            Return ..SendSuccessResponse(data)
        }
        Else
        {
            Return ..SendErrorResponse("Cards not found")
        }
    }
    Else 
    {
        Return ..SendErrorResponse("Invalid token")
    }
}

ClassMethod GetListsFromCard() As %DynamicArray
{
    Set userId=..IsAuth()
    If userId '= 0 
    {
        Set data=%request.Content
        Set checkList = ##class(MyApp.GetFunctions).GetLists(data.cardId)
        If checkList '=0
        {
            Set data = {"checklists":(checkList) }
            Return ..SendSuccessResponse(data)
        }
        Else
        {
            Return ..SendErrorResponse("Check lists not found")
        }
    }
    Else 
    {
        Return ..SendErrorResponse("Invalid token")
    }
}

ClassMethod GetTasksFromList() As %DynamicArray
{
    Set userId=..IsAuth()
    If userId '= 0 
    {   
        Set data=%request.Content
        Set taskList = ##class(MyApp.GetFunctions).GetTasks(data.listId)
        If taskList '=0
        {
            Set data = {"tasks":(taskList) }
            Return ..SendSuccessResponse(data)
        }
        Else
        {
            Return ..SendErrorResponse("Tasks not found")
        }
    }
    Else 
    {
        Return ..SendErrorResponse("Invalid token")
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

ClassMethod DeleteBoard()
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
        // Проверка прав владельца
        Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, data.boardId)
        // Если не владелец, проверяем другие права доступа
        If isOwner '= 1 {
           // Write "Is owner",isOwner,!
            Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, data.boardId)
            //Write "permission",CheckPermission,!
            // Проверка прав пользователя
            If (CheckPermission '= 1) && (CheckPermission '= 2) {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }  
        }
       
        Set status=##class(MyApp.DeleteFunctions).DeleteBoard(data.boardId)
        If $$$ISERR(status) {
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

ClassMethod DeleteCard()
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
        Set boardId = ##class(MyApp.AccessControl).GetBoardIdByCard(data.cardId)
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
            If (CheckPermission '= 1) && (CheckPermission '= 2) {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }  
        }
       
        Set status=##class(MyApp.DeleteFunctions).DeleteCard(data.cardId)
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

ClassMethod DeleteList()
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
        Set boardId = ##class(MyApp.AccessControl).GetBoardIdByList(data.checklistId)
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
            If (CheckPermission '= 1) && (CheckPermission '= 2) {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }  
        }
       
        Set status=##class(MyApp.DeleteFunctions).DeleteList(data.checklistId)
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

ClassMethod DeleteTask()
{
    Try {
        // Проверка аутентификации
        Set userId = ..IsAuth()
        If userId = 0 {
            Throw ##class(%Exception.General).%New("Invalid token")
        }
        // Получение данных из запроса
        Set data = %request.Content
        Set boardId = ##class(MyApp.AccessControl).GetBoardIdByTask(data.taskId)
        If boardId = "" {
            Throw ##class(%Exception.General).%New("Board ID not found for the given task")
        }
        // Проверка прав владельца
        Set isOwner = ##class(MyApp.AccessControl).CheckUserOwner(userId, boardId)
        // Если не владелец, проверяем другие права доступа
        If isOwner '= 1 {
            Set CheckPermission = ##class(MyApp.AccessControl).CheckUserPermissions(userId, boardId)
            // Проверка прав пользователя
            If (CheckPermission '= 1) && (CheckPermission '= 2) {
                Throw ##class(%Exception.General).%New("User does not have permission")
            }
        }
        // Удаление задачи
        Set status = ##class(MyApp.DeleteFunctions).DeleteTask(data.taskId)
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

ClassMethod CreateNewBord()
{
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
}

ClassMethod CreateNewCard()
{
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
}

ClassMethod CreateNewChecklist()
{
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
}

ClassMethod CreateNewTask()
{
    Set userId=..IsAuth()
    If userId '= 0
    {
        Set data=%request.Content
        If $ISOBJECT(data.tasks) 
        {       
            Set taskList = ##class(%Library.DynamicArray).%New()
            Set count = data.tasks.%Size() 
            For i=0:1:count-1 
            {
                Set task = data.tasks.%Get(i)
                Set taskId =##class(MyApp.CreateFunctions).CreateTask(data.checklistId,task)
                If taskId '= 0
                {
                    Do taskList.%Push(taskId)
                }   
            }
            Set data = {"tasks":(taskList) }
            Return ..SendSuccessResponse(data) 
        }
    }
    Else
    {
        Return ..SendErrorResponse("Invalid token") 
    }
}

ClassMethod UpdateUser()
{
    Set userId=..IsAuth()
    If userId '= 0  
    {
        Set data=%request.Content
        Set status=##class(MyApp.UpdateFunctions).UpdateUserData(userId,data.email,data.userName,data.firstName,data.lastName)
        If status = $$$OK
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
       Return ..SendErrorResponse("Invalid token")
    }
}

ClassMethod UpdateBoard()
{
    Set userId=..IsAuth()
    If userId '= 0  
    {
        Set data=%request.Content
        Set status=##class(MyApp.UpdateFunctions).UpdateBoard(data.boardId,data.title,data.description)
        If status = $$$OK
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
       Return ..SendErrorResponse("Invalid token")
    }
}

ClassMethod UpdateCard()
{
    Set userId=..IsAuth()
    If userId '= 0  
    {
        Set data=%request.Content
        Set status=##class(MyApp.UpdateFunctions).UpdateCard(data.cardId,data.title,data.description)
        If status = $$$OK
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
       Return ..SendErrorResponse("Invalid token")
    }
}

ClassMethod UpdateCheckList()
{
    Set userId=..IsAuth()
    If userId '= 0  
    {
        Set data=%request.Content
        Set status=##class(MyApp.UpdateFunctions).UpdateList(data.checklistId,data.title,data.description)
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
    Else 
    {
       Return ..SendErrorResponse("Invalid token")
    }
}

ClassMethod UpdateTasks()
{
    Set userId=..IsAuth()
    If userId '= 0  
    {
        Set data=%request.Content
        
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
       Return ..SendErrorResponse("Invalid token")
    }
}

ClassMethod ShareBorad()
{
    Set userId=..IsAuth()
    If userId '= 0  
    {      
        Set data=%request.Content
       


        Set recipientId=$ORDER(^MyApp.UsersI("EmailIdx", $ZCONVERT(" "_data.email, "U"), ""))
        
        If recipientId '=""
        { 
            Set isShared=##class(MyApp.CreateFunctions).CreateSharedBoard(userId,data.boardId,recipientId,data.permission)
            If isShared '=0
            {
                Return ..SendSuccessResponse("")
            }
            Else
            {
                Return ..SendErrorResponse(isShared)
            }
        }
        Else
        {
           Return ..SendErrorResponse("Recipient not found")
        }
    
    }
    Else 
    {
       Return ..SendErrorResponse("Invalid token")
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

ClassMethod ChaeckPermission()
{
}

ClassMethod GetUserName()
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
