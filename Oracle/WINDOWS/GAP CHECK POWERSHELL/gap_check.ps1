<# 
/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
/_/_/_/_/                                      _/_/_/_/_/
_/_/_/_/  _____  ____  _  ___ ___  _    __    _/_/_/_/_/
/_/_/_/  / __  \/ __ \/ |/  / __ |/ \  / /   _/_/_/_/_/
_/_/_/  / /_/ _/ /_/ /\   _/ /_/ /   \/ /   _/_/_/_/_/
/_/_/  / /__/ / _, _/ /  // _,  / /\   /   _/_/_/_/_/
_/_/   \_____/_/ |_/ /__//_/ \_/_/  \_/   _/_/_/_/_/
/_/                                      _/_/_/_/_/
_/                                      _/_/_/_/_/
/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

           +============================+
           |   [Website By Bryan A.] 	|
           |     [github.com/bryr0/]	   |
           +============================+
           |        gap_check.ps1 		|
           |            v.1.9           |
           +----------------------------+
#>

# GAP DIFFERENCE ALERT
$GA = 5;

#Email Parameter
$name="Company name."
$TO_USER = @("user@gmail.com","user@gmail.com");

$Email= "user@gmail.com"
$Password= "mail_password";
$DBAPASS="dba_password"

Function MAIL {
      Param (
          [Parameter(Mandatory=$true)]  [String]$s,
          [Parameter(Mandatory=$true)]  [String]$c,
          [Parameter(mandatory=$false)] [String]$a="none",
          [Parameter(Mandatory=$true)]  [String]$to
      )
            $message = new-object Net.Mail.MailMessage;
            $message.From = "$name <$Email>";
            $message.IsBodyHTML=$true;
            $message.To.Add($to);
            $message.Subject = $s;
            $message.Body = $c;

          if(($PSBoundParameters.ContainsKey('a')) -and $a){
              $attachment = New-Object Net.Mail.Attachment($a);
              $message.Attachments.Add($attachment);
            }

            $smtp = new-object Net.Mail.SmtpClient("smtp.gmail.com", "587");
            $smtp.EnableSSL = $true;
            $smtp.Credentials = New-Object System.Net.NetworkCredential($Email, $Password);
            $smtp.send($message);
            write-host "`n Mail Sent `n" ;

          if(($PSBoundParameters.ContainsKey('a')) -and $a){
                $attachment.Dispose();
            }

  }


Function GAP(){

$T="`t"
$_ = "_" * 73

$P="set serveroutput on;`n SET FEEDBACK OFF;`n DECLARE NS NUMBER(10); LS NUMBER(10); TIMED VARCHAR2(50); BEGIN FOR n IN( select cast( to_char( max( decode (archived, 'YES', sequence`#))) as varchar2(10)) sequence from v`$log group by thread`#) LOOP NS := n.sequence; select to_char(next_time,'DD-MON-YY:HH24:MI:SS') Time, sequence`# INTO TIMED, LS from v`$archived_log where sequence`# = ( NS ); dbms_output.put_line( TIMED || ' ' || LS); END LOOP; END; `n / `n exit;";
$S="set serveroutput on;`n SET FEEDBACK OFF;`n DECLARE LS NUMBER(10); TIMED VARCHAR2(50); BEGIN select to_char(max(FIRST_TIME),'DD-MON-YY:HH24:MI:SS') Time, max(sequence`#) sequence`# INTO TIMED, LS from v`$log_history where FIRST_TIME >=( SELECT MAX(FIRST_TIME) FROM V`$LOG_HISTORY WHERE ROWNUM = 1 GROUP BY THREAD`#); dbms_output.put_line( TIMED || ' ' || LS); END; `n / `n exit;";

$QP = echo $P.replace("¦"," ") | sqlplus -S "system/$DBAPASS@primary"
$QS = echo $S.replace("¦"," ") | sqlplus -S "sys/$DBAPASS@standby as sysdba"

$PD=((echo $QP) -split " +")[0] # date
$PG=((echo $QP) -split " +")[1] # gap
$SD=((echo $QP) -split " +")[0] # date standby
$SG=((echo $QP) -split " +")[1] # gap standby

$TOTAL=($PG-$SG)

$BM  = "`n" 
$BM += " LOGS $T$T$T$T TIME $T$T$T SEQUENCE# `n" 
$BM += " Last Generated on Primary $T $PD $T $PG `n" 
$BM += " Last Applied on Standby $T $SD $T $SG `n" 
$BM += " $_ `n"
$BM += " GAP DIFERENCE$T$T$T$T$T$T $TOTAL `n"
$BM += "`n"

if ($TOTAL -ge $GA) {
	foreach ($TO_ in $TO_USER) {
		MAIL  -s "GAP ALERT" -c $BM -to $TO_;
	}
Exit
  
}
return $BM
}

$BM=GAP;
echo $BM

echo "close in 5 seconds"
Start-Sleep -s 5
Exit