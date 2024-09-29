Class MyApp.DeleteFunctions
{

ClassMethod DeleteBoard(boardId As %Integer)
{
        // Выполнение SQL-запроса
        Set resultSet = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM MyApp.Cards WHERE BoardId = ?", boardId)
        While resultSet.%Next() 
        {
            Set status= ..DeleteCard(resultSet.ID)
             
            if status =0
            {
                return 0
            }
        }
        Set result = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM MyApp.BoardAccess WHERE BoardId = ? ", boardId)
        If result.%Next() 
        {
            Kill ^MyApp.BoardAccessD(result.ID)
        }
        Kill ^MyApp.BoardsD(boardId)
        If '$Data(^MyApp.BoardsD(boardId)) {
            Return 1
        } 
        Else 
        {
            return 0
        }
}

ClassMethod DeleteCard(cardId)
{
      // Выполнение SQL-запроса
        Set resultSet = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM MyApp.Lists WHERE CardId = ?", cardId)
        While resultSet.%Next() 
        {
            Set status= ..DeleteList(resultSet.ID)
             
            if status =0
            {
                return 0
            }
        }
        Kill ^MyApp.CardsD(cardId)
        If '$Data(^MyApp.CardsD(cardId)) {
            Return 1
        } 
        Else 
        {
            return 0
        }
}

ClassMethod DeleteList(listId)
{
     // Выполнение SQL-запроса
        Set resultSet = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM MyApp.Tasks WHERE ListId = ?", listId)
        While resultSet.%Next() 
        {   
            Set status= ..DeleteTask(resultSet.ID)
             
            if status =0
            {
                return 0
            }
        }
        Kill ^MyApp.ListsD(listId)
        If '$Data(^MyApp.ListsD(listId)) {
            Return 1
        } 
        Else 
        {
            return 0
        }
}

ClassMethod DeleteTask(taskId) As %Boolean
{
    //write "id;" ,taskId,!
    //return 1
    Kill ^MyApp.TasksD(taskId)
    If '$Data(^MyApp.TasksD(taskId)) {
    Return 1
    } 
    Else 
    {
    return 0
    }
}

}
