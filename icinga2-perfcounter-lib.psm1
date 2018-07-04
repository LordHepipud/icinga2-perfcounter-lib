<#
.Synopsis
   Icinga 2 Performance Counter Library - Easy fetching of Performance Counter data
.DESCRIPTION
   More Information on https://github.com/LordHepipud/icinga2-perfcounter-lib
.EXAMPLE
    Get-Icinga2Counter -ListCounter 'Processor'
.EXAMPLE
    Get-Icinga2Counter -Counter '\Processor(*)\% Processor Time'
.EXAMPLE
    Get-Icinga2Counter -CounterArray @( '\Processor(*)\% Processor Time', '\Processor(*)\% c1 time')
.NOTES
#>
 function Get-Icinga2Counter
 {
    [CmdletBinding()]
    param(
        # Allows to specify the full path of a counter to fetch data. Example '\Processor(*)\% Processor Time'
        [string]$Counter                           = '',
        # Allows to fetch all counters of a specific category, like 'Processor'
        [string]$ListCounter                       = '',
        # Provide an array of counters we check in a bulk '\Processor(*)\% Processor Time', '\Processor(*)\% c1 time'"
        [array]$CounterArray                       = @(),
        # By default counters will wait globally for 500 milliseconds. With this we can skip it. Use with caution!
        [switch]$SkipWait                          = $FALSE,
        # These arguments apply to CreateStructuredPerformanceCounterTable
        # This is the category name we want to create a structured output
        # Example: 'Network Interface'
        [string]$CreateStructuredOutputForCategory = '',
        # This is the hashtable of Performance Counters, created by
        # PerformanceCounterArray
        [hashtable]$StructuredCounterInput         = @{},
        # This argument is just a helper to replace certain strings within
        # a instance name with simply nothing.
        # Example: 'HarddiskVolume1' => '1'
        [array]$StructuredCounterInstanceCleanup   = @(),
        # Enable PowerShell Tracing (0 / 1 / 2)
        [int16]$Trace         = 0
    );

    Set-PSDebug -Trace $Trace;
     
    $CounterScript = Join-Path $PSScriptRoot -ChildPath 'perfcounter.ps1';
 
    return (&$CounterScript `
            -Counter $Counter `
            -ListCounter $ListCounter `
            -CounterArray $CounterArray `
            -SkipWait $SkipWait `
            -CreateStructuredOutputForCategory $CreateStructuredOutputForCategory `
            -StructuredCounterInput $StructuredCounterInput `
            -StructuredCounterInstanceCleanup $StructuredCounterInstanceCleanup
    );
}

$exportModuleData = @{
    Function = @(
        'Get-Icinga2Counter'
    )
}

Export-ModuleMember @exportModuleData;