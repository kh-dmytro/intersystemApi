Class MyApp.GetFunctions
{

ClassMethod GetUserData(userId As %Integer) As %DynamicObject
{
        If $DATA(^MyApp.UsersD(userId))
        { 
            Set userdata= ^MyApp.UsersD(userId) 
            SET data = 
            {
                "Success": "true",
                "username": ($LIST(userdata, 2)),
                "email": ($LIST(userdata, 3)),
                "firstName": ($LIST(userdata, 5)),
                "lastName": ($LIST(userdata, 6)), 
                "userId":(userId)
            }
            return data
        }
        else
        {
            return 0
        }
}

ClassMethod GetBoards(userId As %Integer) As %DynamicObject
{
        Set resultSet = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID, Title, Description FROM MyApp.Boards WHERE OwnerID = ?", userId)
        Set boardList = ##class(%Library.DynamicArray).%New()
        While resultSet.%Next() 
        {
            Set board = ##class(%Library.DynamicObject).%New()
            Do board.%Set("boardId", resultSet.ID)
            Do board.%Set("title", resultSet.Title)
            Do board.%Set("description", resultSet.Description)
            Do board.%Set("cards",..GetCards(resultSet.ID))
            Do boardList.%Push(board)
        }
        If boardList.%Size() = 0 
        {
            Return 0
        }
        else
        {  
            RETURN boardList
        }
}

ClassMethod GetCards(boardId As %Integer) As %DynamicObject
{
        Set resultSet = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID, Title, Description	 FROM MyApp.Cards WHERE BoardId = ?", boardId)
        Set cardList = ##class(%Library.DynamicArray).%New()
        While resultSet.%Next() 
        {
            Set card = ##class(%Library.DynamicObject).%New()
            Do card.%Set("cardId", resultSet.ID)
            Do card.%Set("title", resultSet.Title)
            Do card.%Set("description", resultSet.Description)
            Do card.%Set("checklists",..GetLists(resultSet.ID))
            Do cardList.%Push(card)
        }
       If cardList.%Size() = 0 
        {
            Return 0
        }
        else
        {  
            RETURN cardList
        }
}

ClassMethod GetLists(cardId As %Integer) As %DynamicObject
{
        Set resultSet = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID, Title, Description	 FROM MyApp.Lists WHERE CardId = ?", cardId)
        Set checklists = ##class(%Library.DynamicArray).%New()
        While resultSet.%Next() 
        {
            Set list = ##class(%Library.DynamicObject).%New()
            Do list.%Set("checklistId", resultSet.ID)
            Do list.%Set("title", resultSet.Title)
            Do list.%Set("description", resultSet.Description)
            Do list.%Set("tasks",..GetTasks(resultSet.ID))
            Do checklists.%Push(list)
        }
        If checklists.%Size() = 0 
        {
            Return 0
        }
        else
        {  
            RETURN checklists
        }
}

ClassMethod GetTasks(listId As %Integer) As %DynamicObject
{
        Set resultSet = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID, Title, IsCompleted	 FROM MyApp.Tasks WHERE ListId = ?", listId)
        Set taskList = ##class(%Library.DynamicArray).%New()
        While resultSet.%Next() 
        {
            Set task = ##class(%Library.DynamicObject).%New()
            Do task.%Set("taskId", resultSet.ID)
            Do task.%Set("title", resultSet.Title)
            Do task.%Set("IsCompleted", resultSet.IsCompleted)
            Do taskList.%Push(task)
        } 
        If taskList.%Size() = 0 
        {
            Return 0
        }
        else
        {  
            RETURN taskList
        }
}

ClassMethod GetAllowedBoard(userId As %Integer)
{
   
   
    Set allowedBoard = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID, BoardId, PermissionId, GrantedBy	 FROM MyApp.BoardAccess WHERE UserId = ?", userId)
    Set boardList = ##class(%Library.DynamicArray).%New()
    While allowedBoard.%Next() 
        {
            Set boardData=^MyApp.BoardsD(allowedBoard.BoardId)
            Set board = ##class(%Library.DynamicObject).%New()
            Do board.%Set("boardId", allowedBoard.BoardId)
            Do board.%Set("owner", $LIST(^MyApp.UsersD(allowedBoard.GrantedBy), 3))
            Do board.%Set("permission", allowedBoard.PermissionId)
            Do board.%Set("title", $LIST(boardData, 2))
            Do board.%Set("description", $LIST(boardData, 3))
            Do board.%Set("cards",..GetCards(allowedBoard.BoardId))
            Do boardList.%Push(board)
        }
        If boardList.%Size() = 0 
        {
            Return 0
        }
        else
        {  
            RETURN boardList
        }
}

}
