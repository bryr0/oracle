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
           |     [Bryro.comli.com]	    |
           +============================+
           |        gap_check.ps1 		|
           |            v.1.7           |
           +----------------------------+
#>

# GAP DIFFERENCE ALERT
$GA = 5;

#Email Parameter
$name="Bryan A."
$Email = "user@gmail.com";
$Password= "password";

Function MAIL {
      Param (
          [Parameter(Mandatory=$true)]  [String]$s,
          [Parameter(Mandatory=$true)]  [String]$c,
          [Parameter(mandatory=$false)] [String]$a="none",
          [Parameter(Mandatory=$true)]  [String]$to
      )
            $message = new-object Net.Mail.MailMessage;
            $message.From = "$name <$Email>";
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

$P="sELECT 'Last Generated on Primary:'Logs,to_char(next_time,'DD-MON-YY:HH24:MI:SS') Time,sequence`# from v`$archived_log where sequence`# = (select cast(to_char(max( decode (archived, 'YES', sequence#, 0)) ) as varchar2(10)) from v`$log group by thread`#);
exit;" 

$S="select 'Last Applied on Standby: 'Logs, to_char(max(FIRST_TIME),'DD-MON-YY:HH24:MI:SS') Time, max(sequence`#) sequence`# from v`$log_history where FIRST_TIME >= (SELECT MAX(FIRST_TIME) FROM V`$LOG_HISTORY GROUP BY THREAD`#);
exit;" 

$QP=echo $P.replace("¦"," ") | sqlplus 'system/system_mgr@primary'
$QS=echo $S.replace("¦"," ") | sqlplus '/as sysdba'

$PD=((echo $QP | Select-String "Primary") -split " +")[4] # date
$PG=((echo $QP | Select-String "Primary") -split " +")[5] # gap
$SD=((echo $QS | Select-String "Standby") -split " +")[4] # date standby
$SG=((echo $QS | Select-String "Standby") -split " +")[5] # gap standby

$TOTAL=($PG-$SG)

$BM  = "`n" 
$BM += " LOGS $T$T$T$T TIME $T$T$T$T SEQUENCE# `n" 
$BM += " Last Generated on Primary $T $PD $T $PG `n" 
$BM += " Last Applied on Standby $T $SD $T $SG `n" 
$BM += " $_ `n"
$BM += " GAP DIFERENCE$T$T$T$T$T$T$T $TOTAL `n"
$BM += "`n"

if ($TOTAL -ge $GA) {
  MAIL  -s "GAP ALERT" -c $BM -to "xx.abryan.xx@gmail.com";
}
return $BM
}

$BM=GAP;
echo $BM

#atachment
#MAIL  -s "subject hello" -c "body text" -a 'C:\backup\file.txt' "user@gmail.com";

#simple
#MAIL  -s "subject hello" -c "body text" -to "user@gmail.com";

Read-Host "Press any key to exit..."
exit