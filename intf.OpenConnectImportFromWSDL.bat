del intf.OpenConnectProzessListe.pas
del intf.OpenConnectBranchenliste.pas
del intf.OpenConnectAllgemeineAuskuenfte.pas
del intf.OpenConnectAnwenderIndividuelleAuskuenfte.pas

"C:\Program Files (x86)\Embarcadero\Studio\22.0\bin\WSDLIMP.exe" -P -D. -=+ @intf.OpenConnectWSDL.txt

ren intf_SHKConnectProzessListe.pas intf.OpenConnectProzessListe.pas
ren intf_SHKConnectBranchenliste.pas intf.OpenConnectBranchenliste.pas
ren intf_SHKConnectAllgemeineAuskuenfte.pas intf.OpenConnectAllgemeineAuskuenfte.pas
ren intf_SHKConnectAnwenderIndividuelleAuskuenfte.pas intf.OpenConnectAnwenderIndividuelleAuskuenfte.pas

pause