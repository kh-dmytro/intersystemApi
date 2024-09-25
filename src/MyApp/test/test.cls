Class MyApp.test
{

ClassMethod ReversString(str As %String) As %String
{
        Set revers = ""
        For i = $LENGTH(str):-1:1 {
            Set revers = revers _ $EXTRACT(str, i)
        }
        Quit revers
}

ClassMethod ExplodeString(str As %String, sep As %String, ByRef words) As %ListOfDataTypes
{
        // Инициализация переменных
        Set temp = ""
        Set j = 1
        Set len = $Length(str)
        Set sepLen = $Length(sep)

        // Удаляем старые значения из words (если были)
        Set words =##class(%ListOfDataTypes).%New()
        If sepLen = 0 {
            Write "Separator is empty", !
            Quit words
        }

        If len = 0 {
            Write "String is empty", !
            Quit words
        }

        For i = 1:1:len {
            If $EXTRACT(str, i, i+sepLen-1) = sep {
                If temp '= "" {
                    Do words.Insert(temp) // Добавляем слово в массив
                    Set j = j + 1
                    Set temp = ""
                }
                Set i = i + sepLen - 1  // Пропускаем разделитель
            } Else {
                Set temp = temp _ $EXTRACT(str, i)
            }
        }

        If temp '= "" {
           Do words.Insert(temp)  
        }

        Quit words
}

ClassMethod StrReplace(str As %String, pat As %String, rep As %String) As %String
{
    Set ReplacedStr=""
    Set len = $Length(str)
    Set patLen = $Length(pat)
    For i=1:1:len
    {
         if $EXTRACT(str, i, i+patLen-1) = pat
        { 
            Set ReplacedStr=ReplacedStr_rep
            Set i=i+patLen-1
        }
        Else
        {
            Set ReplacedStr=ReplacedStr_$EXTRACT(str, i)
        }
    }
    Quit ReplacedStr
}

ClassMethod CountArrayElements(arr As %ArrayOfDataTypes) As %Integer
{
        Set count = 0
        Set key = ""

        For {
            Set key = $Order(arr(key))
            Quit:key=""
            Set count = count + 1
        }

        Quit count
}

ClassMethod main()
{
        Set string = "my fadfsad str ing forda sadf fdsafasdf fwfshdh da hdfdasdg dfsda asftest"
        Set result= ..ExplodeString(string, "  ")
        Write string,!
        Write ..StrReplace(string, "st","DA")


        
     
        
        
        // Получаем количество элементов массива
        Set countElement = result.Count()
       // Write "Count of array elements: ", countElement, !

        // Выводим все элементы массива
        For i = 1:1:countElement {
            //Write "Word ", i, ": ", result.GetAt(i), !
        }
}

}
