Class MyApp.UpdateFunctions
{

ClassMethod UpdateUserData(userId As %Integer, email As %String, userName As %String, firstName As %String, lastName As %String)
{
        If $Data(^MyApp.UsersD(userId)) 
        {
            Set $LIST(^MyApp.UsersD(userId), 2)=userName
            Set $LIST(^MyApp.UsersD(userId), 3)=email
            Set $LIST(^MyApp.UsersD(userId), 5)=firstName
            Set $LIST(^MyApp.UsersD(userId), 6)=lastName
            Return $$$OK
        }
        else
        {
            Return "User not found"
        }
}

ClassMethod UpdateBoard(boardId As %Integer, title As %String, description As %String)
{
        If $Data(^MyApp.BoardsD(boardId)) 
        {
            Set $LIST(^MyApp.BoardsD(boardId), 2)=title
            Set $LIST(^MyApp.BoardsD(boardId), 3)=description
            Set $LIST(^MyApp.BoardsD(boardId), 6)=$ZDATETIME($HOROLOG,3)
            Return $$$OK
        }
        else
        {
            Return "Board not found"
        }
}

ClassMethod UpdateCard(cardId As %Integer, title As %String, description As %String)
{
        If $Data(^MyApp.CardsD(cardId)) 
        {
            Set $LIST(^MyApp.CardsD(cardId), 2)=title
            Set $LIST(^MyApp.CardsD(cardId), 3)=description
            Set $LIST(^MyApp.CardsD(cardId), 6)=$ZDATETIME($HOROLOG,3)
            Return $$$OK
        }
        else
        {
            Return "Card not found"
        }
}

ClassMethod UpdateList(listId As %Integer, title As %String, description As %String)
{
        If $Data(^MyApp.ListsD(listId)) 
        {
            Set $LIST(^MyApp.ListsD(listId), 2)=title
            Set $LIST(^MyApp.ListsD(listId), 3)=description
            Set $LIST(^MyApp.ListsD(listId), 5)=$ZDATETIME($HOROLOG,3)
            Return $$$OK
        }
        else
        {
            Return "List not found"
        }
}

ClassMethod UpdateTask(taskId As %Integer, title As %String)
{
        If $Data(^MyApp.TasksD(taskId)) 
        {
            Set $LIST(^MyApp.TasksD(taskId), 2)=title
            Set $LIST(^MyApp.TasksD(taskId), 5)=$ZDATETIME($HOROLOG,3)
            Return $$$OK
        }
        else
        {
            Return "Task not found"
        }
}

}
