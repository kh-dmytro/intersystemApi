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
        If boardId.%Next() 
        {
            Return boardId.ID
        }
         Else
        {
            Return 0
        }
}

ClassMethod GetBoardIdByList(listId As %Integer) As %Integer
{
        // Запрос для получения BoardId
        Set boardId = ##class(%SQL.Statement).%ExecDirect(,"SELECT b.Id FROM MyApp.Lists l JOIN MyApp.Cards c ON l.CardId = c.Id JOIN MyApp.Boards b ON c.BoardId = b.Id WHERE l.Id = ?", listId)
        If boardId.%Next() 
        {
            Return boardId.ID
        }
         Else
        {
            Return 0
        }
}

ClassMethod GetBoardIdByCard(cardId As %Integer) As %Integer
{
        // Запрос для получения BoardId
        Set boardId = ##class(%SQL.Statement).%ExecDirect(,"SELECT BoardID FROM MyApp.Cards WHERE ID = ?", cardId)
        If boardId.%Next() 
        {
            Return boardId.BoardId
        }
        Else
        {
            Return 0
        }
}

ClassMethod GetCardIdByTask(taskId As %Integer) As %Integer
{
        // Запрос для получения BoardId
        Set cardId = ##class(%SQL.Statement).%ExecDirect(,"SELECT l.CardId FROM MyApp.Tasks t JOIN MyApp.Lists l ON t.ListId = l.Id WHERE t.Id = ?", taskId)
        If cardId.%Next() 
        {
            Return cardId.CardId
        }
         Else
        {
            Return 0
        }
}

ClassMethod GetCardIdByList(listId As %Integer) As %Integer
{
        // Запрос для получения BoardId
        Set cardId = ##class(%SQL.Statement).%ExecDirect(,"SELECT CardId FROM MyApp.Lists WHERE ID = ?", listId)
        If cardId.%Next() 
        {
            Return cardId.CardId
        }
         Else
        {
            Return 0
        }
}

ClassMethod isUserHavePermission(type As %String, userId As %Integer, id As %Integer) As %Integer
{
    Set boardId=0
    Set cardId=0
    Set permission=0

    // Определение boardId и cardId в зависимости от типа
    If type = "task" {
        Set boardId=..GetBoardIdByTask(id)
        Set cardId= ..GetCardIdByTask(id)
    }
    ElseIf type = "list" {
        Set boardId=..GetBoardIdByList(id)
        Set cardId=..GetCardIdByList(id)
    }
    ElseIf type ="card" {
        Set boardId=..GetBoardIdByCard(id)
        Set cardId=id
    }
    ElseIf type= "board" {
        Set boardId=id
    }
    Else
    {
        //Write "no type",!
    }

    If boardId '= 0 {
        // Проверка прав владельца
        Set permission=..CheckUserOwner(userId, boardId)
        If permission = 1 {
            //Write "User is owner =",permission,! 
            Return permission
        }
        Else {
            // Проверка прав на доску
            Set boardPermission=..CheckUserBoardPermissions(userId, boardId)
             //Write "board permission ",boardPermission,!
            If boardPermission '= 0 
            {
                Set permission = boardPermission
            }
            If cardId '= 0 
            {
                
                Set cardPermission=..CheckUserCardPermissions(userId, cardId)
                //Write "card permission ",cardPermission,!
                If cardPermission '= 0 
                {       
                    Set permission =cardPermission
                }
            }
        }
    }
    //Write "permission ",permission,!
    Return permission
}

ClassMethod isBoardShared(userId As %Integer, boardId As %Integer) As %Boolean
{
    Set result = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM MyApp.BoardAccess WHERE BoardId = ? AND UserId = ?", boardId, userId)
    If result.%Next() 
    {
        Return 1
    }
    Else
    {
        Return 0
    }
}

ClassMethod isCardShared(userId As %Integer, cardId As %Integer, permissionId As %Integer) As %Boolean
{
    Set resultCard = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM MyApp.CardAccess WHERE CardId = ? AND UserId = ?", cardId, userId)
    If resultCard.%Next() 
    {
        Return 1
    }
    Else
    {
        Set resultBoard = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM MyApp.BoardAccess WHERE BoardId = ? AND UserId = ? AND PermissionId = ?", ..GetBoardIdByCard(cardId), userId, permissionId)
        If resultBoard.%Next() 
        {
            Return 1
        }
        Else
        {
            Return 0
        }    
    }
}

ClassMethod CreateSharedCard(ownerId As %Integer, cardId As %Integer, userId As %String, permission As %Integer) As %Status
{
    Set newShare=##class(MyApp.CardAccess).%New()
    Set newShare.CardId=cardId
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
ClassMethod UpdateSharedCard(ownerId As %Integer, cardId As %Integer, userId As %String, permission As %Integer) As %Status
{
    Set newShare=##class(MyApp.CardAccess).%New()
    Set newShare.CardId=cardId
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

}
