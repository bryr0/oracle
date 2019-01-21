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
           |   [Website By Bryan A.]  |
           |     [Bryro.comli.com]      |
           +============================+
           |        gap_check.ps1     |
           |            v.1.15          |
           +----------------------------+
#>

# GAP DIFFERENCE ALERT
$GA = 5;

# Email Parameter
$name="Company name."
$TO_USER = @("user@gmail.com","user@gmail.com");
$Email= "user@gmail.com"
$Password= "password";

# Database Parameter
$DBUSER = "SYS";
$DBAPASS = "system";


#Email html format
$HEAD="<head><style>table{color:#444;border-radius:5px;-moz-border-radius:5px;-webkit-border-radius:5px;border:1px solid #ddd}thead{background:#333;color:#fff}td,th{text-align:left;padding:8px}tr:nth-child(even){background-color:#eee}</style>
</head><body><h2>Gap Sequence</h2> <table> <thead> <tr> <th>LOGS</th> <th>TIME</th> <th>SEQUENCE#</th> </tr></thead>";
$BODY="<tbody>{0}</tbody></table></body>";

$TR1="<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>";
$TR2="<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>";
$TR3="<tr><td colspan='2'>{0}</td><td>{1}</td></tr>";

Function MAIL {
      Param (
          [Parameter(Mandatory=$true)]  [String]$s,
          [Parameter(Mandatory=$true)]  [String]$c,
          [Parameter(mandatory=$false)] [String]$a="none",
          [Parameter(Mandatory=$true)]  [String]$to
      )
            $message = new-object Net.Mail.MailMessage;
            $message.From = "$name <$Email>";
            $message.IsBodyHTML=$true
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
  $GC = "`n";
  $MSG="`n";
  $SCR=" LOGS $T$T$T$T TIME $T$T$T SEQUENCE# `n Last Generated on Primary[{0}] $T {1} $T {2} `n Last Applied on Standby[{0}] $T {3} $T {4} `n $_ `n GAP DIFERENCE$T$T$T$T$T$T {5} `n";


  $P="set serveroutput on;`n SET FEEDBACK OFF;`n DECLARE NS NUMBER(10); C NUMBER(10) := 0; LS NUMBER(10); TIMED VARCHAR2(50); BEGIN FOR n IN( 
  select cast( to_char( max( decode (archived, 'YES', sequence`#))) as varchar2(10)) sequence from v`$log group by thread`# order by sequence 
  DESC) LOOP NS := n.sequence; C := C + 1; 
  select to_char(next_time,'DD-MON-YY:HH24:MI:SS'),sequence`# into TIMED,LS from v`$log where sequence`# = (NS); 
  dbms_output.put_line( TIMED || ' ' || LS || ' ' || C); END LOOP; END; `n / `n exit;"

  $S="set serveroutput on;`n SET FEEDBACK OFF;`n DECLARE NS NUMBER(10); C NUMBER(10) := 0; LS NUMBER(10); TIMED VARCHAR2(50); BEGIN FOR n IN( 
  select max(sequence`#) sequence from v`$log_history group by thread# order by sequence DESC) LOOP NS := n.sequence 
  ; select to_char(max(FIRST_TIME),'DD-MON-YY:HH24:MI:SS') Time INTO TIMED from v`$log_history where sequence`# =(NS); dbms_output.put_line( 
  TIMED || ' ' || NS || ' ' || C); END LOOP; END; `n / `n exit;"


  $QP = echo $P.replace("¦"," ") | sqlplus -S "$DBUSER/$DBAPASS@PRIMARY as sysdba"
  $QS = echo $S.replace("¦"," ") | sqlplus -S "$DBUSER/$DBAPASS@standby as sysdba"

  $CO = ((echo $QP) -split " +") # split elements
  $CO = $CO[($CO.Length)-1];     # counter
  

  For ($i=1; $i -le $CO; $i++) {

    $PD = ((echo $QP) -split " +")[$NC] # date
    $PG = ((echo $QP) -split " +")[$NC+1] # gap
    $SD = ((echo $QS) -split " +")[$NC] # standby date
    $SG = ((echo $QS) -split " +")[$NC+1] # standby gap

    
    $TOTAL=($PG-$SG)
    $MSG += $TR1 -f "Last Generated on Primary[$i]",$PD,$PG;
    $MSG += $TR2 -f "Last Applied on Standby[$i]",$SD,$SG;
    $MSG += $TR3 -f "GAP DIFERENCE",$TOTAL;

    $GC += $SCR -f $i,$PD,$PG,$SD,$SG,$TOTAL;
    $GC += "`n";

    if ($TOTAL -ge $GA) {
      $GSS = 1;
    }

    $NC+=3
  }

  if ($GSS -eq 1) {
    foreach ($TO_ in $TO_USER) {
      $tmp = $HEAD;
      $tmp += $BODY -f $MSG;
      MAIL  -s "GAP ALERT" -c $tmp -to $TO_;
    }
  }
 return $GC;
}


$BM=GAP;
echo $BM

echo " Close in 10 seconds"
Start-Sleep -s 10
exit