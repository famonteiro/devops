netsh advfirewall firewall add rule name="SQL Instances" dir=in action=allow protocol=TCP localport=1433; 

# Or disable it altogether
#Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
