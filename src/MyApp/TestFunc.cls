Class MyApp.TestFunc Extends %RegisteredObject
{

ClassMethod CreateTestData(userId As %Integer)
{
    Set title="test title"
    Set description="Test description lenght dada ffsdf test tstes ttsss ttdvcvxxvzvzxv"
    
    Set task="test task TO DO"

    //For i=1:1:100
    For i=1:1:20
    {
        Set bTitle=title_" "_i
        Set bDesc=description_" "_i
        Set boardId= ##class(MyApp.CreateFunctions).CreateBoard(userId,bTitle ,bDesc)
        Write "Board id: ",boardId,!
        Set randomCountCards=$RANDOM(25) + 1
        For c=1:1:randomCountCards
        {
            Set cardId= ##class(MyApp.CreateFunctions).CreateCard(userId,boardId,title_" "_i_" , "_c, description_" "_i_" , "_c)
            Write "  Card id: ",cardId,!
            Set randomCountLists=$RANDOM(8) + 1
            For l=1:1:randomCountLists
            {
                Set listId=##class(MyApp.CreateFunctions).CreateChecklist(cardId,title_" "_i_" , "_c_","_l, description_" "_i_" , "_c_","_l)
                Write "    List id: ",listId,!
                Set randomCountTasks=$RANDOM(10) + 1
                For t=1:1:randomCountTasks
                {
                    Set taskId=##class(MyApp.CreateFunctions).CreateTask(listId,task_" "_i_" , "_c_","_l_","_t)
                    Write "      Task id: ",taskId,!
                }
            }
        }
    }
}

ClassMethod DeleteTestData(userId As %Integer)
{
    Set boardsIds = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM MyApp.Boards WHERE OwnerID = ?", userId)
    While boardsIds.%Next() 
    {
        Write "Board ID : ",boardsIds.ID,!
        Set cardsIds = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM MyApp.Cards WHERE BoardId = ?", boardsIds.ID)
        While cardsIds.%Next() 
        {
            Write "Card ID : ",cardsIds.ID,!
            Set status= ##class(MyApp.DeleteFunctions).DeleteCard(cardsIds.ID)
            If status =0
            {
                Return 0
            }
        }
        Set result = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM MyApp.BoardAccess WHERE BoardId = ? ", boardsIds.ID)
        If result.%Next() 
        {
            Kill ^MyApp.BoardAccessD(result.ID)
        }
        Kill ^MyApp.BoardsD(boardsIds.ID)
        If '$DATA(^MyApp.BoardsD(boardsIds.ID)) {
           Write "Board ID : ",boardsIds.ID, "DELETED!",!
        } 
        
    }
}

}
