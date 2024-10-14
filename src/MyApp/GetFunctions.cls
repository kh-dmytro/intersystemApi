Class MyApp.GetFunctions
{

ClassMethod GetUserData(userId As %Integer) As %DynamicObject
{
        If $DATA(^MyApp.UsersD(userId))
        { 
            Set userdata= ^MyApp.UsersD(userId) 
            Set data = 
            {
                "Success": "true",
                "username": ($LIST(userdata, 2)),
                "email": ($LIST(userdata, 3)),
                "firstName": ($LIST(userdata, 5)),
                "lastName": ($LIST(userdata, 6)), 
                "userId":(userId)
            }
            Return data
        }
        Else
        {
            Return 0
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
        Else
        {  
            Return boardList
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
        Else
        {  
            Return cardList
        }
}

ClassMethod GetCard(cardId As %Integer) As %DynamicObject
{
        Set card = ##class(MyApp.Cards).%OpenId(cardId)
        Set cardList = ##class(%Library.DynamicArray).%New()
        
            Set card = ##class(%Library.DynamicObject).%New()
            Do card.%Set("cardId", card.ID)
            Do card.%Set("title", card.Title)
            Do card.%Set("description", card.Description)
            Do card.%Set("checklists",..GetLists(card.ID))
            Do cardList.%Push(card)
       If cardList.%Size() = 0 
        {
            Return 0
        }
        Else
        {  
            Return cardList
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
        Else
        {  
            Return checklists
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
        Else
        {  
            Return taskList
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
            Do board.%Set("cards",..GetAllowedCard(allowedBoard.BoardId,userId,allowedBoard.PermissionId))
            Do boardList.%Push(board)
        }
        If boardList.%Size() = 0 
        {
            Return 0
        }
        Else
        {  
            Return boardList
        }
}

ClassMethod GetAllowedCards(userId As %Integer)
{
    Set allowedCards = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID, CardId, PermissionId, GrantedBy	 FROM MyApp.CardAccess WHERE UserId = ?", userId)
    Set CardList = ##class(%Library.DynamicArray).%New()
    While allowedCards.%Next() 
        {
            Set cardData = ##class(MyApp.Cards).%OpenId(allowedCards.CardId)
            Set card = ##class(%Library.DynamicObject).%New()
            Do card.%Set("cardId", allowedCards.CardId)
            Do card.%Set("owner", $LIST(^MyApp.UsersD(allowedCards.GrantedBy), 3))
            Do card.%Set("permission", allowedCards.PermissionId)
            Do card.%Set("title", cardData.Title)
            Do card.%Set("description", cardData.Description)
            Do card.%Set("checklists",..GetLists(allowedCards.CardId))
            Do CardList.%Push(card)
        }
        If CardList.%Size() = 0 
        {
            Return 0
        }
        Else
        {  
            Return CardList
        }
}

ClassMethod GetAllowedCard(boardId As %Integer, userId As %Integer, permission As %Integer) As %DynamicObject
{
        Set resultSet = ##class(%SQL.Statement).%ExecDirect(,"SELECT c.ID, c.Title, c.Description, ca.PermissionId FROM MyApp.Cards c LEFT JOIN MyApp.CardAccess ca ON c.ID = ca.CardId AND ca.UserId = ?  WHERE c.BoardId = ? ",userId, boardId)
        Set cardList = ##class(%Library.DynamicArray).%New()
       // Write "beginn ",resultSet,!
        While resultSet.%Next() 
        {
          // Write "in while",!
            Set card = ##class(%Library.DynamicObject).%New()
            Do card.%Set("cardId", resultSet.ID)
            If resultSet.PermissionId '=""
            {
                Do card.%Set("permission", resultSet.PermissionId) 
            }
            Else
            {
                 Do card.%Set("permission", permission)
            }
            Do card.%Set("title", resultSet.Title)
            Do card.%Set("description", resultSet.Description)
            Do card.%Set("checklists",..GetLists(resultSet.ID))
            //Write "card id", resultSet.ID,!
    //Write "permission ",card.permission,!
            Do cardList.%Push(card)
        }
        If cardList.%Size() = 0 
        {
            Return 0
        }
        Else
        {  
            Return cardList
        }
}

ClassMethod GetSharedList(userId As %Integer)
{
        Set resultSet = ##class(%SQL.Statement).%ExecDirect(,"SELECT ba.ID, ba.BoardId, b.Title, u.Email, p.Name,  ba.GrantedAt FROM MyApp.BoardAccess ba JOIN MyApp.Boards b ON ba.BoardId = b.ID JOIN MyApp.Users u ON ba.UserId = u.ID JOIN MyApp.Permissions p ON ba.PermissionId = p.ID WHERE ba.GrantedBy = ?", userId)
        Set sharedInfo = ##class(%Library.DynamicArray).%New()
        While resultSet.%Next() 
        {
            Set info = ##class(%Library.DynamicObject).%New()
            Do info.%Set("accessId", resultSet.ID)
            Do info.%Set("boardId", resultSet.BoardId)
            Do info.%Set("title", resultSet.Title)
            Do info.%Set("email", resultSet.Email)
            Do info.%Set("role", "Owner")
            Do info.%Set("type", "Board")
            Do info.%Set("grantedAt", resultSet.GrantedAt)
            Do info.%Set("permission", resultSet.Name)
            Do sharedInfo.%Push(info)
        }
        Set resultSet = ##class(%SQL.Statement).%ExecDirect(,"SELECT ba.ID, ba.BoardId, b.Title, u.Email, p.Name, ba.GrantedAt FROM MyApp.BoardAccess ba JOIN MyApp.Boards b ON ba.BoardId = b.ID JOIN MyApp.Users u ON ba.UserId = u.ID JOIN MyApp.Permissions p ON ba.PermissionId = p.ID WHERE ba.UserId = ? AND permissionId =?", userId, "1")
        While resultSet.%Next() 
        {
            Set info = ##class(%Library.DynamicObject).%New()
            Do info.%Set("accessId", resultSet.ID)
            Do info.%Set("boardId", resultSet.BoardId)
            Do info.%Set("title", resultSet.Title)
            Do info.%Set("email", resultSet.Email)
            Do info.%Set("role", "Admin")
              Do info.%Set("type", "Board")
            Do info.%Set("grantedAt", resultSet.GrantedAt)
            Do info.%Set("permission", resultSet.Name)
            Do sharedInfo.%Push(info)
        }
        Set resultSet = ##class(%SQL.Statement).%ExecDirect(,"SELECT ca.ID, ca.CardId, c.Title, u.Email, p.Name,  ca.GrantedAt FROM MyApp.CardAccess ca JOIN MyApp.Cards c ON ca.CardId = c.ID JOIN MyApp.Users u ON ca.UserId = u.ID JOIN MyApp.Permissions p ON ca.PermissionId = p.ID WHERE ca.GrantedBy = ?", userId)
        While resultSet.%Next() 
        {
            Set info = ##class(%Library.DynamicObject).%New()
            Do info.%Set("accessId", resultSet.ID)
            Do info.%Set("boardId", resultSet.CardId)
            Do info.%Set("title", resultSet.Title)
            Do info.%Set("email", resultSet.Email)
            Do info.%Set("role", "Owner")
            Do info.%Set("type", "Card")
            Do info.%Set("grantedAt", resultSet.GrantedAt)
            Do info.%Set("permission", resultSet.Name)
            Do sharedInfo.%Push(info)
        }
        Set resultSet = ##class(%SQL.Statement).%ExecDirect(,"SELECT ca.ID, ca.CardId, c.Title, u.Email, p.Name, ca.GrantedAt FROM MyApp.CardAccess ca JOIN MyApp.Cards c ON ca.CardId = c.ID JOIN MyApp.Users u ON ca.UserId = u.ID JOIN MyApp.Permissions p ON ca.PermissionId = p.ID WHERE ca.UserId = ? AND permissionId =?", userId, "1")
        While resultSet.%Next() 
        {
            Set info = ##class(%Library.DynamicObject).%New()
            Do info.%Set("accessId", resultSet.ID)
            Do info.%Set("boardId", resultSet.CardId)
            Do info.%Set("title", resultSet.Title)
            Do info.%Set("email", resultSet.Email)
            Do info.%Set("role", "Admin")
            Do info.%Set("type", "Card")
            Do info.%Set("grantedAt", resultSet.GrantedAt)
            Do info.%Set("permission", resultSet.Name)
            Do sharedInfo.%Push(info)
        }
        If sharedInfo.%Size() = 0 
        {
            Return 0
        }
        Else
        {  
            Return sharedInfo
        }
}

}
