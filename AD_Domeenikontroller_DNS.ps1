#  Installib AD domeenikontrolleri ja vajalikud haldustööriistad
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
# Loome uue Domeeni nimega oige.local ja installime DNS teenuse.
Install-ADDSForest -DomainName oige.local -InstallDns