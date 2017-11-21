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
           |        check_disk.ps1 		|
           |            v.1.1           |
           +----------------------------+
#>

# define multiple server
# note: if file no exist or is empty only monitoring localhost
$file="./servers.txt";

#define warning percent alert
$PWarning = 70;

#mail setting
$name="Bryan A."
$Email = "user@gmail.com";
$Password= "Password";

#mail notifications 
$users="user@gmail.com","user1@gmail.com" ,"user2@gmail.com";

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

function check_disk(){
    $servers= get-content env:computername;
    if(Test-Path $file){
        if((Get-Item $file).length -gt 0kb){
            $servers= Get-Content -Path $file;
        }
    }

    $disks = Get-WmiObject -ComputerName $servers -Class Win32_LogicalDisk -ErrorAction SilentlyContinue ;
    
    foreach($disk in $disks){
     $ddata="";
     $deviceID = $disk.DeviceID;
     $server=$disk.SystemName;
     [float]$size = $disk.Size;
     [float]$freespace = $disk.FreeSpace;  
     $percentFree = [Math]::Round(($freespace / $size) * 100, 2);
     $sizeGB = [Math]::Round($size / 1073741824, 2);
     $freeSpaceGB = [Math]::Round($freespace / 1073741824, 2); 

         if($percentFree -lt $PWarning ){
            $ddata += "ID `t`t sizeGB `t freeGB `t`t server`n";
            $ddata += "$deviceID `t`t $sizeGB`t`t $freeSpaceGB `t`t $server`n";

            foreach($user in $users){
                MAIL  -s "Disk warning: $server" -c $ddata -to $user;
            } 
         }
        return $ddata;
    }
}

check_disk;