Examples for using the module
==============

Below you will find some examples to use the module to fetch performance counters.

### Fetch available counter categories on the system

```powershell
    Get-Icinga2Counter -ListCategories;
```

### Fetch a list of available Performance Counters for a category

#### Example 1
```powershell
    Get-Icinga2Counter -ListCounter 'Processor';
```

#### Example 2
```powershell
    Get-Icinga2Counter -ListCounter 'Memory';
```

### Fetch Performance Counters

By using the 'CounterArray' argument, you can provide an array with one or multiple performance counters to
fetch them at once. Note that the required sleep for certain counters is only applied once here, which
means fetching them in bulk mode will speed up the loading.

*Note:* This is the recommended way to fetch counters, even for single object values, because it will
fully load and fetch the counter informations and make it easier to work the results and access specific
counters, as they are entirely returned as a hashtable. Even though the module provides an alternative way,
this is the one which should be used.

#### Example 1

Fetch multiple counters at once and access a multi instance counter

```powershell
    $counter = Get-Icinga2Counter -CounterArray @(
        '\Processor(*)\% processor time',
        '\Memory\committed bytes',
        '\Memory\available mbytes'
    );
    $counter['\Processor(*)\% processor time']['\Processor(0)\% processor time'].value;
```

#### Example 2

Fetch a single instance counter and print its value

```powershell
    $counter = Get-Icinga2Counter -CounterArray @('\Processor(_Total)\% processor time');
    $counter['\Processor(_Total)\% processor time'].value
```

#### Example 3

Fetch a single multi instance counter and access a specific instance value

```powershell
    $counter = Get-Icinga2Counter -CounterArray @('\Processor(*)\% processor time');
    $counter['\Processor(*)\% processor time']['\Processor(_Total)\% processor time'].value
```
