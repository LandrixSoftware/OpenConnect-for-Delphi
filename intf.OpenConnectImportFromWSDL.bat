del intf.OpenConnectProzessListe.pas
del intf.OpenConnectBranchenliste.pas
del intf.OpenConnectAllgemeineAuskuenfte.pas
del intf.OpenConnectAnwenderIndividuelleAuskuenfte.pas

"C:\Program Files (x86)\Embarcadero\Studio\21.0\bin\WSDLIMP.exe" -P -D. -=+ @intf.SHKConnectWSDL.txt

ren intf_OpenConnectProzessListe.pas intf.OpenConnectProzessListe.pas
ren intf_OpenConnectBranchenliste.pas intf.OpenConnectBranchenliste.pas
ren intf_OpenConnectAllgemeineAuskuenfte.pas intf.OpenConnectAllgemeineAuskuenfte.pas
ren intf_OpenConnectAnwenderIndividuelleAuskuenfte.pas intf.OpenConnectAnwenderIndividuelleAuskuenfte.pas

pause