Installing the Module
=====================================

Fetch PowerShell module folders
--------------

At first we need to obtain folders in which we can install the module. For this type the following into 
your PowerShell
```powershell
    echo $env:PSModulePath
```    

Depending on your requirements who will be allowed to execute functions from the module, install it 
inside one of the provided folders. On demand you can also modify your path variable inside the Windows 
settings to add another module location.

While inside the modules folder, simply clone this repository or create a folder, named exactly like the 
.psm1 file and place it inside. Once done restart your PowerShell and validate the correct installation 
of the module by writing
```powershell
    Get-Module -ListAvailable
```    

You might require to scroll a bit to locate your module directory with the installed Icinga 2 module. 
Once it's there, the installation was successful.

If you are done, you might want to take a look on the [example page](30-Examples.md).

Execution Policy
--------------

In order to be able to use the module, you might require to update your execution policy on the Windows system
you wish to use the module on or sign it with a code certificate.

The cmdlets to fetch and update the execution policy are

```powershell
    Get-ExecutionPolicy
    Set-ExecutionPolicy
```
