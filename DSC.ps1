Configuration homelab{

    node ADDS{
        Import-DscResource –ModuleName @{ModuleName="xActiveDirectory";ModuleVersion="2.11.0.0"}

        $HostData = $ConfigurationData.DC
        $DomainCred = Get-AutomationPSCredential -Name "DA Credentials"
        $SafemodeAdministratorPassword = Get-AutomationPSCredential -Name "ADSafeMode"
        $NewADUserCred = = Get-AutomationPSCredential -Name "Defaul AD Pwd"

        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }

        xADDomain FirstDS
        {
            DomainName = $HostData.DomainName
            DomainAdministratorCredential = $DomainCred 
            SafemodeAdministratorPassword = $SafemodeAdministratorPassword 
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = $HostData.DomainName
            DomainUserCredential = $domainCred
            RetryCount = $HostData.RetryCount
            RetryIntervalSec = $HostData.RetryIntervalSec
            DependsOn = "[xADDomain]FirstDS"
        }
        xADUser FirstUser
        {
            DomainName = $HostData.DomainName
            DomainAdministratorCredential = $domainCred
            UserName = "dummy"
            Password = $NewADUserCred
            Ensure = "Present"
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }


    }
}