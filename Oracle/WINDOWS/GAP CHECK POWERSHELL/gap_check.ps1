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
           |            v.1.12          |
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

  $NC=0;
  $T="`t"
  $_ = "_" * 70
  $GSS= 0;

  $P="set serveroutput on;`n SET FEEDBACK OFF;`n DECLARE NS NUMBER(10); C NUMBER(10) := 0; LS NUMBER(10); TIMED VARCHAR2(50); BEGIN FOR n IN( select cast( to_char( max( decode (archived, 'YES', sequence`#))) as varchar2(10)) sequence from v`$log group by thread`#) LOOP NS := n.sequence; C := C + 1; select to_char(next_time,'DD-MON-YY:HH24:MI:SS') Time, sequence`# INTO TIMED, LS from v`$archived_log where sequence`# = ( NS ); dbms_output.put_line( TIMED || ' ' || LS || ' ' || C); END LOOP; END; `n / `n exit;";
  $S="set serveroutput on;`n SET FEEDBACK OFF;`n DECLARE NS VARCHAR2(50); C NUMBER(10) := 0; LS NUMBER(10); TIMED VARCHAR2(50); BEGIN FOR n IN( SELECT MAX(FIRST_TIME) Time FROM V`$LOG_HISTORY GROUP BY THREAD`#) LOOP NS := n.Time ; select to_char(max(FIRST_TIME),'DD-MON-YY:HH24:MI:SS') Time, max(sequence`#) sequence`# INTO TIMED, LS from v`$log_history where FIRST_TIME >=( NS); dbms_output.put_line( TIMED || ' ' || LS || ' ' || C); END LOOP; END; `n / `n exit;"

  $QP = echo $P.replace("¦"," ") | sqlplus -S "system/$DBAPASS@primary"
  $QS = echo $S.replace("¦"," ") | sqlplus -S "sys/$DBAPASS@standby as sysdba"
  $CO=((echo $QP) -split " +")[2] # counter

  For ($i=1; $i -le $CO; $i++) {
    $BM = "`n";
    $PD = ((echo $QP) -split " +")[$NC] # date
    $PG = ((echo $QP) -split " +")[$NC+1] # gap
    $SD = ((echo $QS) -split " +")[$NC] # standby date
    $SG = ((echo $QS) -split " +")[$NC+1] # standby gap

    $TOTAL=($PG-$SG)
    $BM += " LOGS $T$T$T$T TIME $T$T$T SEQUENCE# `n" 
    $BM += " Last Generated on Primary[$i] $T $PD $T $PG `n" 
    $BM += " Last Applied on Standby $T $SD $T $SG `n" 
    $BM += " $_ `n"
    $BM += " GAP DIFERENCE$T$T$T$T$T$T $TOTAL `n"
    $BM += "`n"

    if ($TOTAL -ge $GA) {
      $GSS = 1;
    }

    $NC+=3
  }
 return $BM
}

if ( $GSS == 1) {
    foreach ($TO_ in $TO_USER) {
      MAIL  -s "GAP ALERT" -c $BM -to $TO_;
    }
}

$BM=GAP;
echo $BM

echo "close in 5 seconds"
Start-Sleep -s 5
Exit