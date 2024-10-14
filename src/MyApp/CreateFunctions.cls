Class MyApp.CreateFunctions
{

ClassMethod CreateUser(email As %String, pass As %String, userName As %String, firstName As %String, lastName As %String) As %Status
{
    Set checkEmail=$ORDER(^MyApp.UsersI("EmailIdx", $ZCONVERT(" "_email, "U"), ""))
    If checkEmail =""
    {
        Set newUser = ##class(MyApp.Users).%New()
        Set newUser.Email = email
        Set newUser.UserName = userName
        Set newUser.Password = ##class(MyApp.Users).HashPassword(pass)
        Set newUser.FirstName=firstName
        Set newUser.LastName=lastName
        Set status = newUser.%Save()
        If $$$ISOK(status) 
        {
            Return $$$OK 
        }
        Else 
        {
            Return "Something went wrong"
        }
    }
    Else
    {
        Return "Email already exists"
    }
}

ClassMethod CreateBoard(ownerId As %Integer, title As %String, description As %String) As %Status
{
        Set newBoard=##class(MyApp.Boards).%New()
        Set newBoard.Title=title
        Set newBoard.Description=description
        Set newBoard.OwnerId=ownerId
        Set status = newBoard.%Save()
        If status= $$$OK
            {
                Return newBoard.%Id() 
            }
            Else
            {       
                Return status  
            }
}

ClassMethod CreateCard(ownerId As %Integer, boardId As %Integer, title As %String, description As %String) As %Status
{
        Set newCard=##class(MyApp.Cards).%New()
        Set newCard.Title=title
        Set newCard.Description=description
        Set newCard.BoardId=boardId
        Set newCard.OwnerId=ownerId
        Set status = newCard.%Save()
        If status= $$$OK
            {
                Return newCard.%Id()
            }
            Else
            {       
               Return 0 
            }
}

ClassMethod CreateChecklist(cardId As %Integer, title As %String, description As %String) As %Status
{
        Set newChecklist=##class(MyApp.Lists).%New()
        Set newChecklist.Title=title
        Set newChecklist.Description=description
        Set newChecklist.CardId=cardId
        Set status = newChecklist.%Save()
        If status =$$$OK
        {
            Return newChecklist.%Id() 
        }
        Else
        {
            Return 0
        }
}

ClassMethod CreateTask(listId As %Integer, title As %String) As %Status
{
        Set newTask=##class(MyApp.Tasks).%New()
        Set newTask.Title=title
        Set newTask.ListId=listId
        Set status = newTask.%Save()
        If status= $$$OK
            {
              Return newTask.%Id()
            }
            Else
            {       
                Return 0 
            }
}

ClassMethod CreateSharedBoard(ownerId As %Integer, boardId As %Integer, userId As %String, permission As %Integer) As %Status
{
        Set newShare=##class(MyApp.BoardAccess).%New()
        Set newShare.BoardId=boardId
        Set newShare.UserId=userId
        Set newShare.GrantedBy=ownerId
        Set newShare.PermissionId=permission
        Set status = newShare.%Save()
        If status= $$$OK
            {
              Return newShare.%Id()
            }
            Else
            {       
                Return "Something went wrong"
            }
}

ClassMethod CreateTestData(userId As %Integer)
{
    Set title="test title"
    Set description="Test description lenght dada ffsdf test tstes ttsss ttdvcvxxvzvzxv"
    
    Set task="test task TO DO"

    //For i=1:1:100
    For i=1:1:50
    {
        Set bTitle=title_" "_i
        Set bDesc=description_" "_i
        Set boardId= ..CreateBoard(userId,bTitle ,bDesc)
        Write "Board id: ",boardId,!
        Set randomCountCards=$RANDOM(25) + 1
        For c=1:1:randomCountCards
        {
            Set cardId= ..CreateCard(userId,boardId,title_" "_i_" , "_c, description_" "_i_" , "_c)
            Write "  Card id: ",cardId,!
            Set randomCountLists=$RANDOM(30) + 1
            For l=1:1:randomCountLists
            {
                Set listId=..CreateChecklist(cardId,title_" "_i_" , "_c_","_l, description_" "_i_" , "_c_","_l)
                Write "    List id: ",listId,!
                Set randomCountTasks=$RANDOM(65) + 1
                For t=1:1:randomCountTasks
                {
                    Set taskId=..CreateTask(listId,task_" "_i_" , "_c_","_l_","_t)
                    Write "      Task id: ",taskId,!
                }
            }
        }
    }
}

}
