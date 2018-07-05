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

### Create a structured Performance Counter Output

#### Description of the current problem

Plenty of counters provide instances, which are required to allow the specific assignment of values to an object. Such examples are Network Interface counters for different interfaces or PhysicalDisk/LogicalDisk counters for each installed disk.

By simply fetching all informations from a counter, like '\LogicalDisk(*)\free megabytes', we receive each disk value within our output. This is fine in general, is however problematic in the following scenario:

```powershell
    $counter = Get-Icinga2Counter -CounterArray @(
        '\LogicalDisk(*)\free megabytes',
        '\LogicalDisk(*)\% idle time'
    );
```

Of course we will receive the correct amount of data, but the output is not something we can effectively work with, because the parent of our access is always the specified counter with all instances below. You will have to access both of these objects to receive informations of your C disk for example:

```powershell
    $counter['\LogicalDisk(*)\free megabytes']['\LogicalDisk(C:)\free megabytes'].value;
    $counter['\LogicalDisk(*)\% idle time']['\LogicalDisk(C:)\% idle time'].value;
```

As you can see, the 'problem' is not that big, but imagine you have 10 counters you wish to include for your disk. This is not something you wish to handle manually.

#### Solution: Structured outputs

As we now have learned the problem and some workarounds, lets handle the real solution for proper results: **structured output**

To make the example a little more interesting, lets do as much automation as possible.

At first we will create a variable and store all Counters inside the system provides

```powershell
    $CounterList = Get-Icinga2Counter -ListCounter 'LogicalDisk';
```

The -ListCounter argument is returning a hashtable, with the counter path including the instances. We will however only require the counter path, which is our key of the hashtable.
Lets make use of this and forward all of our counter paths ($CounterList.Keys) to the module again, but tell it to use the keys as -CounterArray argument to fetch all informations

```powershell
    $counters = Get-Icinga2Counter -CounterArray $CounterList.Keys
```

Now we have initialised all counters and instances and received them as output from the module. This is quite fine, but we still have the same result as described within our problem scenario.

```powershell
Name                           Value
----                           -----
\LogicalDisk(*)\free megabytes {\LogicalDisk(R:)\free megabytes, \LogicalDisk(V:)\free megabytes, \LogicalDisk(HarddiskVolume4)\free megabytes, \LogicalDisk(HarddiskVolume5)\free megabytes...}
\LogicalDisk(*)\% disk read... {\LogicalDisk(HarddiskVolume4)\% disk read time, \LogicalDisk(_Total)\% disk read time, \LogicalDisk(R:)\% disk read time, \LogicalDisk(V:)\% disk read time...}
\LogicalDisk(*)\avg. disk w... {\LogicalDisk(E:)\avg. disk write queue length, \LogicalDisk(C:)\avg. disk write queue length, \LogicalDisk(_Total)\avg. disk write queue length, \LogicalDisk(V:)\avg. disk write queue length...}
\LogicalDisk(*)\disk transf... {\LogicalDisk(_Total)\disk transfers/sec, \LogicalDisk(HarddiskVolume4)\disk transfers/sec, \LogicalDisk(R:)\disk transfers/sec, \LogicalDisk(C:)\disk transfers/sec...}
\LogicalDisk(*)\avg. disk s... {\LogicalDisk(HarddiskVolume5)\avg. disk sec/write, \LogicalDisk(E:)\avg. disk sec/write, \LogicalDisk(D:)\avg. disk sec/write, \LogicalDisk(HarddiskVolume4)\avg. disk sec/write...}
...
```

Now let the module do the magic and re-organice the entire counter hashtable based on a group parent. As we fetch LogicalDisk data, lets group them by the instances of the category and add our previous loaded counters to the call

```powershell
    $output = Get-Icinga2Counter -CreateStructuredOutputForCategory 'LogicalDisk' -StructuredCounterInput $counters;
```

The output is now very well structured by each available instance.

```powershell
Name                           Value
----                           -----
R:                             {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
D:                             {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
E:                             {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
_Total                         {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
HarddiskVolume4                {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
C:                             {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
HarddiskVolume5                {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
HarddiskVolume2                {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
V:                             {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
```

Last but not least you can now access the output hashtable by a drive letter, interface or whatever instance and counter you picked and work with the results alot easier.

```powershell
    $output['C:']['avg. disk queue length'].value;
    $output['C:']['% disk time'].value;
    $output['C:']['avg. disk bytes/transfer'].value;
```