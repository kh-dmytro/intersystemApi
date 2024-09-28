Class MyApp.AccessControl Extends %RegisteredObject
{

/// Метод для проверки прав пользователя
ClassMethod CheckUserOwner(userId As %Integer, boardId As %Integer, permission As %String) As %Boolean
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

ClassMethod CheckUserPermissions(userId As %Integer, boardId As %Integer) As %Integer
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

}
