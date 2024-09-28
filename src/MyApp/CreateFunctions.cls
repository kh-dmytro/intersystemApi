Class MyApp.CreateFunctions
{

ClassMethod CreateUser(email As %String, pass As %String, userName As %String, firstName As %String, lastName As %String) As %Status
{
    Set checkEmail=$ORDER(^MyApp.UsersI("EmailIdx", $ZCONVERT(" "_email, "U"), ""))
    if checkEmail =""
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
    else
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
        if status= $$$OK
            {
                Return newBoard.%Id() 
            }
            Else
            {       
                Return 0  
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
        if status= $$$OK
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
            return newChecklist.%Id() 
        }
        else
        {
            return 0
        }
}

ClassMethod CreateTask(listId As %Integer, title As %String) As %Status
{
        Set newTask=##class(MyApp.Tasks).%New()
        Set newTask.Title=title
        Set newTask.ListId=listId
        Set status = newTask.%Save()
        if status= $$$OK
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
        if status= $$$OK
            {
              Return newShare.%Id()
            }
            Else
            {       
                Return "Something went wrong"
            }
}

}
