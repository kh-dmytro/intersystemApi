Class MyApp.Tokens Extends %Persistent
{

// Указываем SQL-схему

Parameter SQLSchema = "MyApp";

Property Token As %String(MAXLEN = 128) [ Required ];

Property ExpiresAt As %TimeStamp;

Property CreatedAt As %TimeStamp;

Property UserId As %Integer;

Method %OnNew() As %Status
{
    // Устанавливаем текущее время для CreatedAt
    Set ..CreatedAt = $ZDATETIME($HOROLOG,3)
    // Добавляем один месяц к текущей дате
    Set ..ExpiresAt = $ZDATETIME($HOROLOG +30,3)
    Quit $$$OK
}

ClassMethod IsTokenValid(token As %String) As %Integer
{
   
     Set resultSet = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID,UserId, ExpiresAt FROM MyApp.Tokens WHERE Token = ?", token)
    If resultSet.%Next() 
    {
        Set id = resultSet.%Get("ID")
        Set userId=resultSet.%Get("UserId")
        Set expiresAt = resultSet.%Get("ExpiresAt")
        //Write "Token ExpiresAt: ", expiresAt, !
        if $ZDATETIMEH(expiresAt, 3) > $HOROLOG
        {
                //Write "token Valid id-",id,!
                Quit userId
        }
        else
        {  
                //Write "Token invalid id-",id,!
                Kill ^MyApp.TokensD(id)
                Quit 0
        }
    } 
    Else 
    {
        //Write "Token not found: ", token, !
        Quit 0
    }
}

ClassMethod InvalidateToken(token As %String) As %Status
{
        Set resultSet = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM MyApp.Tokens WHERE Token = ?", token)
        If resultSet.%Next() 
        {
                Set id = resultSet.%Get("ID")
                Kill ^MyApp.TokensD(id)
                return 1
        }
        else
        {
                return 0
        }
        
        /*
    // Удаление токена из базы данных
    //Set status = $SYSTEM.SQL.Execute("DELETE FROM MyApp.Tokens WHERE Token = ?", token)
        Set status= ##class(%SQL.Statement).%ExecDirect(,"DELETE FROM MyApp.Tokens WHERE Token = ?", token)
        If $$$ISERR(status) {
         Write "Ошибка: ", $System.Status.GetErrorText(status), !

        } Else {
        Write "Операция выполнена успешно", !
        }
    Quit status
    */
}

ClassMethod isUnique(token As %String) As %Boolean
{
        Set resultSet = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM MyApp.Tokens WHERE Token = ?", token)
        // Если результат найден, выводим поле ExpiresAt
        If resultSet.%Next() 
        {
                Set id = resultSet.%Get("ID")
               // Write "Token not unique"
                Quit 0
        } 
        Else 
        {
               // Write "Token not found: ", token, !
                Quit 1
        }
}

ClassMethod CreateNewToken(id As %Integer) As %String
{
        Set newToken=..%New()
        Set token=..GenerateToken()
        Set newToken.Token= token
        Set newToken.UserId=id

        Set status = newToken.%Save()

        if status= $$$OK
        {
                Quit token
        }
        Else
        {       

                Quit "Error"      
        }
}

ClassMethod GenerateToken() As %String
{
        Set status=0
        //Set charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+=-_!?^%$#,./"
        Set charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        Set length=64
        while (status '= 1 )
        {
                Set token = ""
                For i = 1:1:length
                {
                // Получаем случайный индекс в диапазоне длины набора символов
                Set randomIndex = $RANDOM($Length(charset)) + 1
                // Добавляем символ из набора в результат
                Set token = token_$Extract(charset, randomIndex, randomIndex)
                }
                //Set token =$SYSTEM.Encryption.Base64Encode(token) 
                Set status=..isUnique(token)
        } 
        Quit token
}

Storage Default
{
<Data name="TokensDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>UserId</Value>
</Value>
<Value name="3">
<Value>Token</Value>
</Value>
<Value name="4">
<Value>CreatedAt</Value>
</Value>
<Value name="5">
<Value>ExpiresAt</Value>
</Value>
</Data>
<DataLocation>^MyApp.TokensD</DataLocation>
<DefaultData>TokensDefaultData</DefaultData>
<ExtentSize>30</ExtentSize>
<IdLocation>^MyApp.TokensD</IdLocation>
<IndexLocation>^MyApp.TokensI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,16,$lb("-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000","-10000000000000000000"),$lb(21,21,21,21,21,21,21,21,21,21,21,21,21,21,21),$lb(758198320,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,758198320))</Histogram>
<OutlierSelectivity>.999999:</OutlierSelectivity>
<Selectivity>0.0001%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,1,0,$lb(1,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30),$lb(0,0,0,0,0,1,1,1,1,0,1,1,1,1,0),$lb(822083584,822083584,838860800,838860800,872415232,872415232,905969664,905969664,939524096,939524096,825229312,805306368,838860800,838860800,872415232,872415232,905969664,905969664,939524096,825753600,842006528,805306368,838860800,838860800,872415232,872415232,905969664,905969664,939524096,842530816,858783744,858783744))</Histogram>
<Selectivity>1</Selectivity>
</Property>
<Property name="CreatedAt">
<AverageFieldSize>21</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb("2024-09-18 15:34:02","2024-09-18 15:34:19","2024-09-18 16:04:47","2024-09-18 16:16:01","2024-09-18 16:16:42","2024-09-18 16:20:04","2024-09-18 16:20:52","2024-09-18 16:21:48","2024-09-18 16:27:44","2024-09-18 17:50:40","2024-09-18 18:18:45","2024-09-18 18:21:20","2024-09-18 18:28:09","2024-09-19 07:08:47","2024-09-19 07:13:42","2024-09-19 07:24:16"),$lb(17,12,14,17,14,17,15,15,12,12,14,15,9,14,14),$lb(842019380,808583168,825819136,893006644,909783092,808729140,825637424,808517632,875692032,825637428,842021424,808714240,892469248,809121074,825898040,825898040,926561332,909783607,926561584,926561584,943337784,825768500,842086962,825897520,943337529,941633848,958410807,808991284,825440820,825440820,842283569,842019380))</Histogram>
<Selectivity>3.3333%</Selectivity>
</Property>
<Property name="ExpiresAt">
<AverageFieldSize>21</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb("2024-10-18 00:00:00","2024-10-18 00:00:00","2024-10-18 00:00:00","2024-10-18 00:00:00","2024-10-18 00:00:00","2024-10-18 00:00:00","2024-10-18 00:00:00","2024-10-18 00:00:00","2024-10-18 00:00:00","2024-10-18 00:00:00","2024-10-18 00:00:00","2024-10-18 00:00:00","2024-10-18 00:00:00","2024-10-19 00:00:00","2024-10-19 00:00:00","2024-10-19 00:00:00"),$lb(20,20,20,20,20,20,20,20,20,20,20,20,9,20,20),$lb(842019380,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,941633584,958410800,0,0,0,0,842019380))</Histogram>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="Token">
<AverageFieldSize>66</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" $TILLXI%EM4UG9N1DS9FVDO+JAJ9+KUX1MZH-FDACC6V/YSXT-Z026PVUWVR0HAG"," .OBE_ZL?R##GPM?TR,.B4BOXE$-D2YIQJQ?SB3+F?VJ02EQYR4Z3OYU$832PBM-E"," 5LE,$YYBA3P!-=KPAC,VBTY_O?ZUQL01+HP0RLF,Q3^5F/0GF%GMAFQW.PFI2SZE"," CWJIG1UWCCTBRUGLKBAYDN8NYE76A0LBBCSFNVOGKX5E2J7SMILMAPO1PESXXK1H"," G7UTFEBAB.1NPA-^AAP_ANH_X/VV.RTGO9CFF/DI-#32B,HW,IW.NZOA6J2P0N6$"," HOXCRHHCPB3MJWO3N2HXLX7KHTBPLDNCCNDDMBX5QUEAZIZYR1GPFXBMSWOMEHH6"," JVHVYU4FQ4QEJRYCBBTWGWVRLDRVSJS2SVQ10KI6QBQFT9QJWHAFRV8POD5HD6VY"," MEHDHZLV7JQBILO50UKLFCNIVTZTDS9BBXQAMDPEKNELRDECWYZUGWC0YA7AOWKB"," PU78FPZBYM^CAD_KZBHEW^PE7IXEQ7$.NRNUNM$HKK^KS1PE6XBV?QMYFOTJB4P$"," T6$4Q,+9P+F-=Y#TN!47^1JMRNAFGTAZMEN?AOJ?JLYG+JU4^=W-9XG,WTD2SOQ#"," UGB0BETJLT4NSRL6QJ7ZLPJOSVRSUMLXZTJLQ7OQJKFYDS2PCMBOVKTOOKBHANRH"," UTFFK3NXDWPC8?C%/T/E^BWLZXTUW9FPX-VPJ5CL,J_5UGH-GB=^LK97Y^UGWU7Y"," WW-TNV1X883%.2T^F+6.RMHABZ%V$RWU6URX%,.B-K9DEDVPF3OOV/BXUPY6I6FV"," YB87SESI7WJCTETXI9MK8GNUASPRQZBFKYI5MDMKTZ55EDRCV2KJVM0BLWZYIXAY"," ZG-XMSU,VHN$8V^E1HI!3_8EMFH.04Z/HLX2ZD#+IIO1NTPUAISRDP3WIQ8WSFSU"," ^IEVWJMIL^_!NV=DG1YF/CJH#Z4SOAWI2UA8EWING1L_UXET%H-FI-IBP$S#NMYS"),$lb(1,1,1,1,1,1,1,1,1,1,2,1,1,1,1),$lb(539251785,609503564,776946245,776946245,894190892,894190892,1129794121,1129794121,1194808660,1194808660,1213159491,1213159491,1247168598,1247168598,1296386116,1296386116,1347761976,1347761976,1412834356,1412834356,1430733360,1195520066,1413891659,1431586374,1465331028,1465331028,1497511991,1497511991,1514614104,1514614104,1581860182,543050053))</Histogram>
<Selectivity>3.3333%</Selectivity>
</Property>
<Property name="UserId">
<AverageFieldSize>3</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,1,0,$lb(1,1,1,1,2,2,2,2,2,2,2,2,5,5,5,5),$lb(1,1,1,0,1,1,1,1,1,1,1,0,1,1,1),$lb(822083584,0,0,0,0,0,0,822083584,838860800,0,0,0,0,0,0,0,0,0,0,0,0,0,0,838860800,889192448,0,0,0,0,0,0,889192448))</Histogram>
<Selectivity>33.3333%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^MyApp.TokensS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
