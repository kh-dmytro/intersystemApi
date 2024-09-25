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
    SET version = ..#Version
    SET info = 
    {
    "version": (version)
    }
    RETURN ..%ProcessResult($$$OK, info)
}

ClassMethod TaskCompleted()
{
    Set authHeader = %request.GetCgiEnv("HTTP_AUTHORIZATION")
    Set token = $Piece(authHeader, " ", 2)
    Set respons = ##class(MyApp.Auth).IsAuth(token)
    If respons '= 0 
    {
        Set data=%request.Content
        If $Data(^MyApp.TasksD(data.taskId)) 
        {
            Set $LIST(^MyApp.TasksD(data.taskId), 3)=data.IsCompleted
            Set $LIST(^MyApp.TasksD(data.taskId), 5)=$ZDATETIME($HOROLOG,3)
            
            Return ..SendSuccessResponse("")
        }
        else
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
            SET data = {"boards":(boardList) }
            Return ..SendSuccessResponse(data)
        }
        else
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
            SET data = {"cards":(cardList) }
            Return ..SendSuccessResponse(data)
        }
        else
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
            SET data = {"checklists":(checkList) }
            Return ..SendSuccessResponse(data)
        }
        else
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
            SET data = {"tasks":(taskList) }
            Return ..SendSuccessResponse(data)
        }
        else
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
            SET data = {"boards":(boardList) }
            Return ..SendSuccessResponse(data)
        }
        else
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
    Set userId=..IsAuth()
    If userId '= 0 
    {
        Set data=%request.Content
        Set status=##class(MyApp.DeleteFunctions).DeleteBoard(data.boardId)
        if status = 1
        {
            Return ..SendSuccessResponse("")
        }
    }
    Else 
    {
        Return ..SendErrorResponse("Invalid token")
    }
}

ClassMethod DeleteCard()
{
    Set userId=..IsAuth()
    If userId '= 0  
    {
        Set data=%request.Content
        Set status=##class(MyApp.DeleteFunctions).DeleteCard(data.cardId)
        if status = 1
        {
            Return ..SendSuccessResponse("")
        }
    }
    Else 
    {
        Return ..SendErrorResponse("Invalid token")
    }
}

ClassMethod DeleteList()
{
    Set userId=..IsAuth()
    If userId '= 0  
    {
        Set data=%request.Content
        Set status=##class(MyApp.DeleteFunctions).DeleteList(data.checklistId)
        if status = 1
        {
            Return ..SendSuccessResponse("")
        }
    }
    Else 
    {
       Return ..SendErrorResponse("Invalid token")
    }
}

ClassMethod DeleteTask()
{
    Set userId=..IsAuth()
    If userId '= 0  
    {
        Set data=%request.Content
        Set status=##class(MyApp.DeleteFunctions).DeleteTask(data.taskId)
        if status = 1
        {
           Return ..SendSuccessResponse("")
        }
    }
    Else 
    {
        Return ..SendErrorResponse("Invalid token")
    }
}

ClassMethod CreateNewBord()
{
    Set respons=..IsAuth()
    if respons '= 0
    {
        Set data=%request.Content
        Set boardId = ##class(MyApp.CreateFunctions).CreateBord(respons,data.title,data.description)
        if boardId '= 0 
        {
            SET data = {"boardId":(boardId) }
            Return ..SendSuccessResponse(data)
        }
        Else
        {   
            Return ..SendErrorResponse("Failed to create board")    
        }
    }
    else
    {
        Return ..SendErrorResponse("Invalid token")
    }
}

ClassMethod CreateNewCard()
{
    Set respons=..IsAuth()
    if respons '= 0
    {
        Set data=%request.Content        
        Set cardId = ##class(MyApp.CreateFunctions).CreateCard(respons,data.boardId, data.title,data.description)
        if cardId'= 0 
        {
            SET data = {"cardId":(cardId) }
            Return ..SendSuccessResponse(data)
        }
        Else
        {   
            Return ..SendErrorResponse("Failed to create card")    
        }
    }
    else
    {
        Return ..SendErrorResponse("Invalid token")
    }
}

ClassMethod CreateNewChecklist()
{
    Set userId=..IsAuth()
    if userId '= 0
    {
        Set data=%request.Content
        Set checklistId = ##class(MyApp.CreateFunctions).CreateChecklist(data.cardId ,data.title ,data.description)
        if checklistId '= 0
        {
            If $IsObject(data.tasks) 
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
            SET data = {"cahecklistId":(checklistId), "tasks":(taskList) }
            Return ..SendSuccessResponse(data)
        }
        else
        {
            Return ..SendErrorResponse("Failed to create Checklist") 
        }
    }
    else
    {
         Return ..SendErrorResponse("Invalid token")
    }
}

ClassMethod CreateNewTask()
{
    Set userId=..IsAuth()
    if userId '= 0
    {
        Set data=%request.Content
        If $IsObject(data.tasks) 
        {       
            Set taskList = ##class(%Library.DynamicArray).%New()
            Set count = data.tasks.%Size() // Попробуем использовать %Size() для получения количества элементов
            For i=0:1:count-1 
            {
                Set task = data.tasks.%Get(i)
                Write "task :",task,!
                Set taskId =##class(MyApp.CreateFunctions).CreateTask(data.checklistId,task)
                write "task id ",taskId,!
                If taskId '= 0
                {
                    Do taskList.%Push(taskId)
                }   
            }
            SET data = {"tasks":(taskList) }
            Return ..SendSuccessResponse(data) 
        }
    }
    else
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
        if status = $$$OK
        {
            Return ..SendSuccessResponse("")
        }
        else
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
        if status = $$$OK
        {
            Return ..SendSuccessResponse("")
        }
        else
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
        if status = $$$OK
        {
            Return ..SendSuccessResponse("")
        }
        else
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
        if status = $$$OK
        {
            If $IsObject(data.tasks) 
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
        else
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
        
            If $IsObject(data.tasks) 
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
        write "board id", data.boardId,!
        write "email ",data.email,!
        write "permissions", data.permission,!


        Set recipientId=$ORDER(^MyApp.UsersI("EmailIdx", $ZCONVERT(" "_data.email, "U"), ""))
         write "recipietn ",recipientId,!
        if recipientId '=""
        { 
            Set isShared=##class(MyApp.CreateFunctions).CreateSharedBoard(userId,data.boardId,recipientId,data.permission)
            if isShared '=0
            {
                Return ..SendSuccessResponse("")
            }
            else
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
    SET info = {"Success": "false","error": (error)}
    RETURN ..%ProcessResult($$$OK, info)
}

ClassMethod Auth()
{
    Set authHeader = %request.GetCgiEnv("HTTP_AUTHORIZATION")
    Set token = $Piece(authHeader, " ", 2)
    Set respons=##class(MyApp.Auth).IsAuth(token)
    if respons '= 0
    {
        Return ..SendSuccessResponse("")
    }
    else
    {
        Return ..SendErrorResponse("Invalid token") 
    }
}

ClassMethod IsAuth()
{
    Set authHeader = %request.GetCgiEnv("HTTP_AUTHORIZATION")
    Set token = $Piece(authHeader, " ", 2)
    Set respons=##class(MyApp.Auth).IsAuth(token)
    Return respons
}

ClassMethod GetUserName()
{
    Set authHeader = %request.GetCgiEnv("HTTP_AUTHORIZATION")
    Set token = $Piece(authHeader, " ", 2)
    Set respons=##class(MyApp.Auth).IsAuth(token)
    if respons '= 0
    {
        // Do ..SendSuccessResponse()
        Set userdata= ^MyApp.UsersD(respons)  
        SET info = 
        {
            "Success": "true",
            "username": ($LIST(userdata, 2)),
            "email": ($LIST(userdata, 3)),
            "user_id":(respons)
        }
        RETURN ..%ProcessResult($$$OK, info)
     }
     else
     {
        Return ..SendErrorResponse("Invalid token") 
     }
}

ClassMethod Login() As %Status
{
    Set data=%request.Content
    Set email =data.email
    Set pass=data.password
    Set token = ##class(MyApp.Auth).Authenticate( email,pass)
    if token '= 0
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
    Set token = $Piece(authHeader, " ", 2)
    Set status= ##class(MyApp.Tokens).InvalidateToken(token)
    If status = 1
    {
        Return ..SendSuccessResponse("")
    }
    else
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
    SET version = ..#Version
    SET info = 
    {
        "version": (version)
    }
    RETURN ..%ProcessResult($$$OK, info)
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
