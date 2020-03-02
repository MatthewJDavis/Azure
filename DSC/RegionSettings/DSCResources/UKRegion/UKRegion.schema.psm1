Configuration UKRegion {
        Import-DscResource -ModuleName xTimezone
        Import-DscResource -ModuleName SystemLocaleDsc

        xTimeZone GMT
        {
            TimeZone         = 'GMT Standard Time'
            IsSingleInstance = 'Yes'
        }
        SystemLocale SystemLocaleExample
        {
            SystemLocale     = 'en-GB'
            IsSingleInstance = 'Yes'
        }       
}