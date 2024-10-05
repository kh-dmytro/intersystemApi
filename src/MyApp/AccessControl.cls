Class MyApp.AccessControl Extends %RegisteredObject
{

/// Метод для проверки прав пользователя
ClassMethod CheckUserOwner(userId As %Integer, boardId As %Integer) As %Boolean
{
    // Проверяем, является ли пользователь владельцем доски
    Set boardOwner = ##class(%SQL.Statement).%ExecDirect(,"SELECT OwnerId FROM MyApp.Boards WHERE ID = ?", boardId)
    // Считываем первую строку
    If boardOwner.%Next() 
    {
        //Set ownerId = boardOwner.OwnerId  // Получаем значение поля OwnerId
        // Write "owner id: ", ownerId, !
        // Проверяем, совпадает ли OwnerId с userId
        If boardOwner.OwnerId = userId 
        {
            Return 1
        }
        Else 
        {
            Return 0
        }
    }
    Else 
    {
        Return 0
    }
}

ClassMethod CheckUserBoardPermissions(userId As %Integer, boardId As %Integer) As %Integer
{
   
    // Проверка в таблице BoardAccess
        Set result = ##class(%SQL.Statement).%ExecDirect(,"SELECT PermissionId FROM MyApp.BoardAccess WHERE BoardId = ? AND UserId = ?", boardId, userId)
        If result.%Next() 
        {
            Return result.PermissionId           
        }
        Else
        {
            Return 0
        }
}

ClassMethod CheckUserCardPermissions(userId As %Integer, cardId As %Integer) As %Integer
{
    Set result = ##class(%SQL.Statement).%ExecDirect(,"SELECT PermissionId FROM MyApp.CardAccess WHERE CardId = ? AND UserId = ?", cardId, userId)
    If result.%Next() 
    {
        Return result.PermissionId           
    }
    Else
    {
        Return 0
    }
}

/// Метод для получения BoardId по TaskId
ClassMethod GetBoardIdByTask(taskId As %Integer) As %Integer
{
        // Запрос для получения BoardId
        Set boardId = ##class(%SQL.Statement).%ExecDirect(,"SELECT b.Id FROM MyApp.Tasks t JOIN MyApp.Lists l ON t.ListId = l.Id JOIN MyApp.Cards c ON l.CardId = c.Id JOIN MyApp.Boards b ON c.BoardId = b.Id WHERE t.Id = ?", taskId)
        if boardId.%Next() 
        {
            Return boardId.ID
        }
}

ClassMethod GetBoardIdByList(listId As %Integer) As %Integer
{
        // Запрос для получения BoardId
        Set boardId = ##class(%SQL.Statement).%ExecDirect(,"SELECT b.Id FROM MyApp.Lists l JOIN MyApp.Cards c ON l.CardId = c.Id JOIN MyApp.Boards b ON c.BoardId = b.Id WHERE l.Id = ?", listId)
        if boardId.%Next() 
        {
            Return boardId.ID
        }
}

ClassMethod GetBoardIdByCard(cardId As %Integer) As %Integer
{
        // Запрос для получения BoardId
        Set boardId = ##class(%SQL.Statement).%ExecDirect(,"SELECT BoardID FROM MyApp.Cards WHERE ID = ?", cardId)
        if boardId.%Next() 
        {
            Return boardId.BoardId
        }
}

ClassMethod GetCardIdByTask(taskId As %Integer) As %Integer
{
        // Запрос для получения BoardId
        Set cardId = ##class(%SQL.Statement).%ExecDirect(,"SELECT l.CardId FROM MyApp.Tasks t JOIN MyApp.Lists l ON t.ListId = l.Id WHERE t.Id = ?", taskId)
        if cardId.%Next() 
        {
            Return cardId.CardId
        }
}

ClassMethod GetCardIdByList(listId As %Integer) As %Integer
{
        // Запрос для получения BoardId
        Set cardId = ##class(%SQL.Statement).%ExecDirect(,"SELECT CardId FROM MyApp.Lists WHERE ID = ?", listId)
        if cardId.%Next() 
        {
            Return cardId.CardId
        }
}

ClassMethod isUserHavePermission(type As %String, userId As %Integer, id As %Integer) As %Integer
{
    Set boardId=0
    Set cardId=0
    Set permission=0
    if type = "task"
    {
        Set boardId=..GetBoardIdByTask(id)
        Set cardId= ..GetCardIdByTask(id)
    }
    if type = "list"
    {
        Set boardId=..GetBoardIdByList(id)
        Set cardId=..GetCardIdByList(id)
    }
    if type ="card"
    {
        Set boardId=..GetBoardIdByCard(id)
        Set cardId=id
    }
    if type="board"
    {
        Set boardId=id
    }
    if (boardId '=0) || (cardId '=0)
    {
        Set permission=..CheckUserOwner(userId, boardId)
        if permission = 1
        {
            return permission
        }
        else
        {
            Set permission=..CheckUserBoardPermissions(userId,boardId)
            if permission '= 0
            {
                return permission
            }
            else
            {
                Set permission=..CheckUserCardPermissions(userId,cardId)
                if permission '= 0
                {
                    return permission
                }
            }
        }
    }
    else
    {
        return permission
    }
}

}
