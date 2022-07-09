{
License OpenConnect-for-Delphi

Copyright (C) 2021 Landrix Software GmbH & Co. KG
Sven Harazim, info@landrix.de

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
}

unit intf.OpenConnect;

interface

uses
  System.SysUtils, System.Classes,System.StrUtils,Vcl.Controls,
  System.Contnrs,Vcl.Dialogs,Vcl.Forms,System.IOUTils, System.Generics.Collections
  ;

type
  TOpenConnectSupplier = class(TObject)
  public
    ID        : Integer;
    Name      : string;
    Street    : string;
    Zip       : string;
    City      : string;
    Country   : string;
    ServiceURL: String;
    CustomerNumberRequired : Boolean;
    UsernameRequired : Boolean;
    PasswordRequired : Boolean;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
	  procedure AssignTo(_Dest : TOpenConnectSupplier);
  	function  Duplicate : TOpenConnectSupplier;
  end;

  TOpenConnectSupplierList = class(TObjectList<TOpenConnectSupplier>)
	  procedure AssignTo(_Dest : TOpenConnectSupplierList);
  	function  Duplicate : TOpenConnectSupplierList;
    function  GetItemBySupplierID(const _ID : Integer) : TOpenConnectSupplier;
  end;

  TOpenConnectBusiness = class(TObject)
  public
    ID : Integer;
    Description : String;
    ServiceURL : String;
    Supplier : TOpenConnectSupplierList;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
	  procedure AssignTo(_Dest : TOpenConnectBusiness);
  	function  Duplicate : TOpenConnectBusiness;
  end;

  TOpenConnectBusinessList = class(TObjectList<TOpenConnectBusiness>)
	  procedure AssignTo(_Dest : TOpenConnectBusinessList);
  	function  Duplicate : TOpenConnectBusinessList;
    function  GetItemByBusiness(const _ID : Integer;const _ServiceURL : String; _CreateIfNotExists : Boolean = false) : TOpenConnectBusiness;
  end;

  TOpenConnectLoginOptions = record
    SupplierID : Integer;
    CustomerNo : String;
    Username : String;
    Password : String;
    ServiceURL : String;
  end;

  TOpenConnectIDSConnectivity = record
    IDSConnectAvailable : Boolean;
    IDSConnectURL : String;
    IDSConnectSupportedProcesses : String;
  end;
  
  TOpenConnectHelper = class(TObject)
  public const
    SHKCONNECT_VERSION = '2.0';
  
    SHKCONNECT_SERVICE_ARGE  = 'https://arge20.shk-connect.de';
    SHKCONNECT_SERVICE_SHKGH = 'https://shkgh20.shk-connect.de';
    SHKCONNECT_SERVICE_OC    = 'https://o-connect.de';

    SHKCONNECT_SERVICE_PROC_BL  = '/services/Branchenliste';
    SHKCONNECT_SERVICE_PROC_AA  = '/services/AllgemeineAuskuenfte';
    SHKCONNECT_SERVICE_PROC_AIA = '/services/AnwenderIndividuelleAuskuenfte';
  public
    class function GetSupplierList(_ResultList : TOpenConnectBusinessList) : Boolean;
    class function CheckIDSConnectivitiy(_LoginOptions : TOpenConnectLoginOptions; out _IDSConnectivity : TOpenConnectIDSConnectivity) : Boolean;
  end;

implementation

uses
  intf.OpenConnectAllgemeineAuskuenfte
  ,intf.OpenConnectAnwenderIndividuelleAuskuenfte
  ,intf.OpenConnectBranchenliste;

{$I intf.OpenConnect.inc}

{ TOpenConnectSupplier }

procedure TOpenConnectSupplier.AssignTo(_Dest: TOpenConnectSupplier);
begin
  _Dest.ID := ID;
  _Dest.Name := Name;
  _Dest.Street := Street;
  _Dest.Zip :=  Zip;
  _Dest.City :=  City;
  _Dest.Country :=  Country;
  _Dest.ServiceURL := ServiceURL;
  _Dest.CustomerNumberRequired := CustomerNumberRequired;
  _Dest.UsernameRequired := UsernameRequired;
  _Dest.PasswordRequired := PasswordRequired;
end;

procedure TOpenConnectSupplier.Clear;
begin
  ID := -1;
  Name := '';
  Street := '';
  Zip := '';
  City := '';
  Country := '';
  ServiceURL := '';
  CustomerNumberRequired := false;
  UsernameRequired := false;
  PasswordRequired := false;
end;

function TOpenConnectSupplier.Duplicate: TOpenConnectSupplier;
begin
  Result := TOpenConnectSupplier.Create;
  AssignTo(Result);
end;

constructor TOpenConnectSupplier.Create;
begin
  Clear;
end;

destructor TOpenConnectSupplier.Destroy;
begin
  inherited;
end;

{ TOpenConnectSupplierList }

function TOpenConnectSupplierList.GetItemBySupplierID(
  const _ID: Integer): TOpenConnectSupplier;
begin
  Result := TOpenConnectSupplier.Create;
  Result.ID := _ID;
  Add(Result);
end;

procedure TOpenConnectSupplierList.AssignTo(_Dest: TOpenConnectSupplierList);
var
  i : Integer;
begin
  _Dest.Clear;
  for i := 0 to Count-1 do
    _Dest.Add(Items[i].Duplicate);
end;

function TOpenConnectSupplierList.Duplicate : TOpenConnectSupplierList;
begin
  Result := TOpenConnectSupplierList.Create;
  AssignTo(Result);
end;

{ TOpenConnectBusiness }

constructor TOpenConnectBusiness.Create;
begin
  Supplier := TOpenConnectSupplierList.Create;
  Clear;
end;

destructor TOpenConnectBusiness.Destroy;
begin
  if Assigned(Supplier) then begin Supplier.Free; Supplier := nil; end;
  inherited;
end;

procedure TOpenConnectBusiness.AssignTo(_Dest: TOpenConnectBusiness);
begin
  _Dest.ID := ID;
  _Dest.Description := Description;
  _Dest.ServiceURL := ServiceURL;
  Supplier.AssignTo(_Dest.Supplier);
end;

procedure TOpenConnectBusiness.Clear;
begin
  ID := -1;
  Description := '';
  ServiceURL := '';
  Supplier.Clear;
end;

function TOpenConnectBusiness.Duplicate: TOpenConnectBusiness;
begin
  Result := TOpenConnectBusiness.Create;
  AssignTo(Result);
end;

{ TOpenConnectBusinessList }

function TOpenConnectBusinessList.GetItemByBusiness(const _ID: Integer;
  const _ServiceURL : String; _CreateIfNotExists: Boolean): TOpenConnectBusiness;
var
  i : Integer;
begin
  REsult := nil;
  for I := 0 to Count - 1 do
  if (Items[i].ID = _ID) and SameText(Items[i].ServiceURL,_ServiceURL) then
  begin
    Result := Items[i];
    break;
  end;
  if (Result = nil) and (_CreateIfNotExists) then
  begin
    Result := TOpenConnectBusiness.Create;
    Result.ID := _ID;
    Result.ServiceURL := _ServiceURL;
    Add(Result);
  end;
end;

procedure TOpenConnectBusinessList.AssignTo(_Dest: TOpenConnectBusinessList);
var
  i : Integer;
begin
  _Dest.Clear;
  for i := 0 to Count-1 do
    _Dest.Add(Items[i].Duplicate);
end;

function TOpenConnectBusinessList.Duplicate : TOpenConnectBusinessList;
begin
  Result := TOpenConnectBusinessList.Create;
  AssignTo(Result);
end;

{ TOpenConnectHelper }

class function TOpenConnectHelper.GetSupplierList(_ResultList: TOpenConnectBusinessList): Boolean;
var
  bl_gb : GetBranchenListe;
  bl_b : BranchenlisteBean;
  bl_resp : GetBranchenListeAntwort;
  bl_br : Branche;

  aa_gb : GetAllgemeineAuskunft;
  aa_b : AllgemeineAuskuenfteBean;
  aa_resp : GetAllgemeineAuskunftAntwort;
  aa_u : Unternehmen;

  i : Integer;

  businessItm : TOpenConnectBusiness;
  supplierItm : TOpenConnectSupplier;
begin
  Result := false;

  if _ResultList = nil then
    exit;

  try
    bl_gb := GetBranchenListe.Create;
    bl_gb.Schnittstellenversion := TOpenConnectHelper.SHKCONNECT_VERSION;
    bl_gb.Softwarename := OPENCONNECT_LOGIN;
    bl_gb.Softwarepasswort := OPENCONNECT_PASSWORD;

    bl_b := GetBranchenlisteBean(false,SHKCONNECT_SERVICE_ARGE+SHKCONNECT_SERVICE_PROC_BL);
    bl_resp := bl_b.GetBranchenListe(bl_gb);

    if bl_resp.Status.Code = '0' then
    begin
      for bl_br in bl_resp.Branche do
      begin
        businessItm := _ResultList.GetItemByBusiness(bl_br.ID,SHKCONNECT_SERVICE_ARGE,true);
        businessItm.Description := bl_br.Name_;
      end;
    end;// else
      //WideMessageDialog(SHKCONNECT_SERVICE_ARGE+SHKCONNECT_SERVICE_BL+#10+bl_resp.Status.Meldung, mtError, [mbOK], 0);

    bl_resp.Free;
    bl_b := nil;

    bl_gb.Free;
  except
//    On E:Exception do begin TLog.Log(true,P_ERROR,'GetBranchenlisteBean '+SHKCONNECT_SERVICE_ARGE,e);  end;
  end;

  try
    bl_gb := GetBranchenListe.Create;
    bl_gb.Schnittstellenversion := TOpenConnectHelper.SHKCONNECT_VERSION;
    bl_gb.Softwarename := OPENCONNECT_LOGIN;
    bl_gb.Softwarepasswort := OPENCONNECT_PASSWORD;

    bl_b := GetBranchenlisteBean(false,SHKCONNECT_SERVICE_SHKGH+SHKCONNECT_SERVICE_PROC_BL);
    bl_resp := bl_b.GetBranchenListe(bl_gb);

    if bl_resp.Status.Code = '0' then
    begin
      for bl_br in bl_resp.Branche do
      begin
        businessItm := _ResultList.GetItemByBusiness(bl_br.ID,SHKCONNECT_SERVICE_SHKGH,true);
        businessItm.Description := bl_br.Name_;
      end;
    end;// else
      //WideMessageDialog(SHKCONNECT_SERVICE_SHKGH+SHKCONNECT_SERVICE_BL+#10+bl_resp.Status.Meldung, mtError, [mbOK], 0);

    bl_resp.Free;
    bl_b := nil;

    bl_gb.Free;
  except
//    On E:Exception do begin TLog.Log(true,P_ERROR,'GetBranchenlisteBean '+SHKCONNECT_SERVICE_SHKGH,e);  end;
  end;

  try
    bl_gb := GetBranchenListe.Create;
    bl_gb.Schnittstellenversion := TOpenConnectHelper.SHKCONNECT_VERSION;
    bl_gb.Softwarename := OPENCONNECT_LOGIN;
    bl_gb.Softwarepasswort := OPENCONNECT_PASSWORD;

    bl_b := GetBranchenlisteBean(false,SHKCONNECT_SERVICE_OC+SHKCONNECT_SERVICE_PROC_BL);
    bl_resp := bl_b.GetBranchenListe(bl_gb);

    if bl_resp.Status.Code = '0' then
    begin
      for bl_br in bl_resp.Branche do
      begin
        businessItm := _ResultList.GetItemByBusiness(bl_br.ID,SHKCONNECT_SERVICE_OC,true);
        businessItm.Description := bl_br.Name_;
      end;
    end;// else
      //WideMessageDialog(SHKCONNECT_SERVICE_SHKGH+SHKCONNECT_SERVICE_BL+#10+bl_resp.Status.Meldung, mtError, [mbOK], 0);

    bl_resp.Free;
    bl_b := nil;

    bl_gb.Free;
  except
//    On E:Exception do begin TLog.Log(true,P_ERROR,'GetBranchenlisteBean '+SHKCONNECT_SERVICE_OC,e);  end;
  end;

  try
    aa_gb := GetAllgemeineAuskunft.Create;
    aa_gb.Schnittstellenversion := TOpenConnectHelper.SHKCONNECT_VERSION;

    aa_gb.Softwarename := OPENCONNECT_LOGIN;
    aa_gb.Softwarepasswort := OPENCONNECT_PASSWORD;

    for i := 0 to _ResultList.Count - 1 do
    begin
      aa_gb.BrancheID := IntToStr(_ResultList[i].ID);

      try
      aa_b := GetAllgemeineAuskuenfteBean(false,_ResultList[i].ServiceURL+SHKCONNECT_SERVICE_PROC_AA);
      aa_resp := aa_b.GetAllgemeineAuskunft(aa_gb);

      if aa_resp.Status.Code = '0' then
      begin
        for aa_u in aa_resp.Unternehmen do
        begin
          supplierItm := _ResultList[i].Supplier.GetItemBySupplierID(aa_u.ID);
          supplierItm.Name := aa_u.Name_;
          supplierItm.Street := aa_u.Strasse;
          supplierItm.Zip := aa_u.PLZ;
          supplierItm.City := aa_u.Ort;
          supplierItm.Country := aa_u.Land;
          supplierItm.ServiceURL := _ResultList[i].ServiceURL;
          supplierItm.CustomerNumberRequired := aa_u.Kundennummer_erforderlich;
          supplierItm.UsernameRequired := aa_u.Benutzername_erforderlich;
          supplierItm.PasswordRequired := aa_u.Passwort_erforderlich;
        end;
      end;// else
        //WideMessageDialog(SHKCONNECT_SERVICE_ARGE+SHKCONNECT_SERVICE_AA+#10+bl_resp.Status.Meldung, mtError, [mbOK], 0);

      aa_resp.Free;
      aa_b := nil;
      except
        //On E:Exception do begin TLog.Log(true,P_ERROR,'GetAllgemeineAuskuenfteBean '+SHKCONNECT_SERVICE_ARGE,e); exit; end;
      end;
    end;

    aa_gb.Free;
  except
//    On E:Exception do begin TLog.Log(true,P_ERROR,'GetAllgemeineAuskuenfteBean',e); exit; end;
  end;

  Result := true;
end;

class function TOpenConnectHelper.CheckIDSConnectivitiy(_LoginOptions: TOpenConnectLoginOptions;
  out _IDSConnectivity: TOpenConnectIDSConnectivity): Boolean;
var
  aia_gb : GetIndividuelleAuskunft;
  aia_b : AnwenderIndividuelleAuskuenfteBean;
  aia_resp : GetIndividuelleAuskunftAntwort;
  aia_p : Prozess;
  aia_tp : String;//Teilprozess
begin
  Result := false;

  _IDSConnectivity.IDSConnectAvailable := false;
  _IDSConnectivity.IDSConnectURL := '';
  _IDSConnectivity.IDSConnectSupportedProcesses := '';

  if _LoginOptions.CustomerNo.IsEmpty and _LoginOptions.Username.IsEmpty and _LoginOptions.Password.IsEmpty then
    exit;
  if _LoginOptions.ServiceURL.IsEmpty then
    exit;
  if _LoginOptions.SupplierID = 0 then
    exit;
  
  aia_gb := GetIndividuelleAuskunft.Create;
  try
  try
    aia_gb.Schnittstellenversion := TOpenConnectHelper.SHKCONNECT_VERSION;
    aia_gb.Softwarename := OPENCONNECT_LOGIN;
    aia_gb.Softwarepasswort := OPENCONNECT_PASSWORD;
    aia_gb.UnternehmensID := _LoginOptions.SupplierID;
    aia_gb.Kundennummer := _LoginOptions.CustomerNo;
    aia_gb.Benutzername := _LoginOptions.Username;
    aia_gb.Passwort := _LoginOptions.Password;

    aia_b := GetAnwenderIndividuelleAuskuenfteBean(false,_LoginOptions.ServiceURL+SHKCONNECT_SERVICE_PROC_AIA);
    aia_resp := aia_b.GetIndividuelleAuskunft(aia_gb);

    if aia_resp.Status.Code = '0' then
    begin
      //Besonderheiten
      //Zander Freiburg bringt SHA zweimal hintereinander mit dem gleichen Inhalt, deswegen break
    
      for aia_p in aia_resp.Prozessliste do
      if aia_p.Prozesscode = 'SHA' then
      begin
        _IDSConnectivity.IDSConnectAvailable := true;
        _IDSConnectivity.IDSConnectURL := aia_p.URL;

        for aia_tp in aia_p.Teilprozesse do
          _IDSConnectivity.IDSConnectSupportedProcesses := Trim(_IDSConnectivity.IDSConnectSupportedProcesses+' '+aia_tp);

        Result := true;
        break;
      end;
    end else
      //WideMessageDialog(_LoginOptions.ServiceURL+SHKCONNECT_SERVICE_PROC_AIA+#10+aia_resp.Status.Meldung, mtError, [mbOK], 0);

    aia_resp.Free;
    aia_b := nil;

  finally  
    aia_gb.Free;
  end;  
  except
//    On E:Exception do begin TLog.Log(true,P_ERROR,'GetAnwenderIndividuelleAuskuenfteBean',e); exit; end;
  end;
end;

end.

