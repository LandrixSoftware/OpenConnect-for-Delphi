{
License OpenConnect-for-Delphi

Copyright (C) 2022 Landrix Software GmbH & Co. KG
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
  System.Contnrs,Vcl.Dialogs,Vcl.Forms,System.IOUTils,
  System.Generics.Collections, System.UITypes
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

  TOpenConnectConnectivityOptions = record
    DatanormOnlineAvailable : Boolean;
    IDSConnectAvailable : Boolean;
    IDSConnectURL : String;
    IDSConnectSupportedProcesses : String;
    OpenMasterdataAvailable : Boolean;
    OpenMasterdata_OAuthURL : String;
    OpenMasterdata_OAuthCustomernumberRequired : Boolean;
    OpenMasterdata_OAuthUsernameRequired : Boolean;
    OpenMasterdata_OAuthClientSecretRequired : Boolean;
    OpenMasterdata_bySupplierPIDURL : String;
    OpenMasterdata_byManufacturerDataURL : String;
    OpenMasterdata_byGTINURL : String;
  public
    procedure Clear;
    function Support_IDSConnectWKEProcess : Boolean;
    function Support_IDSConnectWKSProcess : Boolean;
    function Support_IDSConnectADLProcess : Boolean;
  end;

  TOpenConnectDatanormFile = class
  public
    Text : String;
    FileID : Cardinal;
    FileURL : String;
    FileSize : Cardinal;
    FileName : String;
    FileDate : TDateTime;
    HttpAuthActiv    : Boolean;
    HttpAuthUsername : String;
    HttpAuthPassword : String;
    CookieActiv : Boolean;
    Cookie : TStringList;
  public
    procedure Clear;
    constructor Create;
    destructor Destroy; override;
  end;

  TOpenConnectDatanormFileList = class(TObjectList<TOpenConnectDatanormFile>)
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
    class function GetDatanormFileList(_LoginOptions : TOpenConnectLoginOptions; _ResultList : TOpenConnectDatanormFileList) : Boolean;
    class function CheckConnectivitiy(_LoginOptions : TOpenConnectLoginOptions; out _Connectivity : TOpenConnectConnectivityOptions) : Boolean;
    class function GetErrorCodeAsString(_ErrorNumber : Integer) : String;
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

class function TOpenConnectHelper.GetDatanormFileList(
  _LoginOptions: TOpenConnectLoginOptions;
  _ResultList: TOpenConnectDatanormFileList): Boolean;
var
  aia_gb : GetIndividuelleAuskunft;
  aia_b : AnwenderIndividuelleAuskuenfteBean;
  aia_resp : GetIndividuelleAuskunftAntwort;
  aia_p : Prozess;
  aia_l : Link;
  aia_c : String;//Cookie;
  serviceURL : String;
  dof : TOpenConnectDatanormFile;
begin
  Result := false;

  if _ResultList = nil then
    exit;

  try
    serviceURL := _LoginOptions.ServiceURL;
    if String.StartsText('http://',serviceURL) then
      serviceURL := serviceURL.Insert(4,'s');

    aia_gb := GetIndividuelleAuskunft.Create;
    aia_gb.Schnittstellenversion := TOpenConnectHelper.SHKCONNECT_VERSION;
    aia_gb.Softwarename := OPENCONNECT_LOGIN;
    aia_gb.Softwarepasswort := OPENCONNECT_PASSWORD;
    aia_gb.UnternehmensID := _LoginOptions.SupplierID;
    aia_gb.Kundennummer := _LoginOptions.CustomerNo;
    aia_gb.Benutzername := _LoginOptions.Username;
    aia_gb.Passwort := _LoginOptions.Password;

    aia_b := GetAnwenderIndividuelleAuskuenfteBean(false,serviceURL+SHKCONNECT_SERVICE_PROC_AIA);
    aia_resp := aia_b.GetIndividuelleAuskunft(aia_gb);

    if aia_resp.Status.Code = '0' then
    begin
      for aia_p in aia_resp.Prozessliste do
      if (aia_p.Prozesscode = 'STD') then
      begin
        for aia_l in aia_p.Link do
        begin
          dof := TOpenConnectDatanormFile.Create;
          _ResultList.Add(dof);
          dof.Text := aia_l.Beschreibung + ' '+aia_l.AenderungsInfo;
          //dof.FileID := aia_l.Beschreibung;
          dof.FileURL := aia_l.URL;
          dof.FileDate := StrToDateDef(aia_l.DatenDatum,0);//aia_l.Datum,0);
          dof.FileSize := aia_l.Groesse;
          if aia_l.Authentifizierungsmethode = Authentifizierungsmethode.HTTPAUTH then
          begin
            dof.HttpAuthActiv := true;
            dof.HttpAuthUsername := _LoginOptions.Username;
            dof.HttpAuthPassword := _LoginOptions.Password;
          end
          else
          if aia_l.Authentifizierungsmethode = Authentifizierungsmethode.URL then
          begin
            dof.HttpAuthActiv := false;
          end
          else
          if aia_l.Authentifizierungsmethode = Authentifizierungsmethode.COOKIE then
          begin
            for aia_c in aia_l.CookieList do
            begin
              dof.Cookie.Add(aia_c);
            end;
            //URL, , KEINE,
          end;
        end;
      end;
      //_ResultList.SortByDate;
      Result := true;
    end else
      MessageDlg(serviceURL+SHKCONNECT_SERVICE_PROC_AIA+#10+aia_resp.Status.Meldung, mtError, [mbOK], 0);

    aia_resp.Free;
    aia_b := nil;

    aia_gb.Free;
  except
    on E:Exception do begin MessageDlg('GetAnwenderIndividuelleAuskuenfteBean'+#10+e.Message+' '+e.ClassName, mtError, [mbOK], 0);; exit; end;
  end;
end;

class function TOpenConnectHelper.GetErrorCodeAsString(
  _ErrorNumber: Integer): String;
begin
  case _ErrorNumber of
    1 : Result := 'Fehler bei der Authentifizierung der anfragenden Software.';
    2 : Result := 'Der angefragte Prozess existiert nicht im SHK Connect Server.';
    3 : Result := 'Das angefragte Unternehmen existiert nicht im SHK Connect Server.';
    4 : Result := 'Fehler bei der Authentifizierung des Anwenders beim Unternehmen.';
    5 : Result := 'Angefragte Branche existiert nicht.';
    6 : Result := 'Angefragte PLZ aus der Umkreissuche existiert nicht.';
    7 : Result := 'Fehler bei der Kommunikation mit dem angefragten Unternehmen.';
    9 : Result := 'Fehlerhafte Anfrage (z.B. Pflichtfelder in der Anfrage fehlen)';
    10 : Result := 'Testantwort';
    else Result := 'Es ist kein Fehler aufgetreten.';
  end;
end;

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
    end else
      MessageDlg(SHKCONNECT_SERVICE_ARGE+SHKCONNECT_SERVICE_PROC_BL+#10+bl_resp.Status.Meldung, mtError, [mbOK], 0);

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
    end else
      MessageDlg(SHKCONNECT_SERVICE_SHKGH+SHKCONNECT_SERVICE_PROC_BL+#10+bl_resp.Status.Meldung, mtError, [mbOK], 0);

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
    end else
      MessageDlg(SHKCONNECT_SERVICE_OC+SHKCONNECT_SERVICE_PROC_BL+#10+bl_resp.Status.Meldung, mtError, [mbOK], 0);

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
      end else
        MessageDlg(_ResultList[i].ServiceURL+SHKCONNECT_SERVICE_PROC_AA+#10+aa_resp.Status.Meldung, mtError, [mbOK], 0);

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

class function TOpenConnectHelper.CheckConnectivitiy(_LoginOptions: TOpenConnectLoginOptions;
  out _Connectivity : TOpenConnectConnectivityOptions): Boolean;
var
  aia_gb : GetIndividuelleAuskunft;
  aia_b : AnwenderIndividuelleAuskuenfteBean;
  aia_resp : GetIndividuelleAuskunftAntwort;
  aia_p : Prozess;
  aia_tp : String;//Teilprozess
begin
  Result := false;

  _Connectivity.Clear;

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
      for aia_p in aia_resp.Prozessliste do
        if SameText(aia_p.Prozesscode,'STD') then
        begin
          _Connectivity.DatanormOnlineAvailable := true;
        end else
        if SameText(aia_p.Prozesscode,'SHA') then
        begin
          //Viele liefern mehrere SHA, je nachdem, welche IDS-Connect-Version
          //unterstützt werden. Allerdings geben sie keine Versionsnummer an
          _Connectivity.IDSConnectAvailable := true;
          _Connectivity.IDSConnectURL := aia_p.URL;

          for aia_tp in aia_p.Teilprozesse do
          if Pos(aia_tp,_Connectivity.IDSConnectSupportedProcesses) = 0 then
            _Connectivity.IDSConnectSupportedProcesses := Trim(_Connectivity.IDSConnectSupportedProcesses+' '+aia_tp);
        end else
        if SameText(aia_p.Prozesscode,'OMD-oauth') then
        begin
          _Connectivity.OpenMasterdataAvailable := true;
          _Connectivity.OpenMasterdata_OAuthURL := aia_p.URL;
          for aia_tp in aia_p.Teilprozesse do
          if SameText(aia_tp,'OMD-oauth-Username') then
            _Connectivity.OpenMasterdata_OAuthUsernameRequired := true
          else
          if SameText(aia_tp,'OMD-oauth-Customernumber') then
            _Connectivity.OpenMasterdata_OAuthCustomernumberRequired := true
          else
          if SameText(aia_tp,'OMD-oauth-ClientSecret') then
            _Connectivity.OpenMasterdata_OAuthClientSecretRequired := true;
        end else
        if SameText(aia_p.Prozesscode,'OMD-1-0-5-bySupplierPID') then
        begin
          _Connectivity.OpenMasterdata_bySupplierPIDURL := aia_p.URL;
        end else
        if SameText(aia_p.Prozesscode,'OMD-1-0-5-byManufacturerData') then
        begin
          _Connectivity.OpenMasterdata_byManufacturerDataURL := aia_p.URL;
        end else
        if SameText(aia_p.Prozesscode,'OMD-1-0-5-byGtin') then
        begin
          _Connectivity.OpenMasterdata_byGTINURL := aia_p.URL;
        end;
      Result := true;
    end else
      MessageDlg(_LoginOptions.ServiceURL+SHKCONNECT_SERVICE_PROC_AIA+#10+aia_resp.Status.Meldung, mtError, [mbOK], 0);

    aia_resp.Free;
    aia_b := nil;

  finally
    aia_gb.Free;
  end;
  except
//    On E:Exception do begin TLog.Log(true,P_ERROR,'GetAnwenderIndividuelleAuskuenfteBean',e); exit; end;
  end;
end;

{ TOpenConnectConnectivityOptions }

procedure TOpenConnectConnectivityOptions.Clear;
begin
  DatanormOnlineAvailable := false;
  IDSConnectAvailable := false;
  IDSConnectURL := '';
  IDSConnectSupportedProcesses := '';
  OpenMasterdataAvailable := false;
  OpenMasterdata_OAuthURL := '';
  OpenMasterdata_OAuthCustomernumberRequired := false;
  OpenMasterdata_OAuthUsernameRequired := false;
  OpenMasterdata_OAuthClientSecretRequired := false;
  OpenMasterdata_bySupplierPIDURL := '';
  OpenMasterdata_byManufacturerDataURL := '';
  OpenMasterdata_byGTINURL := '';
end;

function TOpenConnectConnectivityOptions.Support_IDSConnectADLProcess: Boolean;
begin
  Result := false;
  if not IDSConnectAvailable then
    exit;
  Result := Pos('ADL',IDSConnectSupportedProcesses.ToUpper)>0;
end;

function TOpenConnectConnectivityOptions.Support_IDSConnectWKEProcess: Boolean;
begin
  Result := false;
  if not IDSConnectAvailable then
    exit;
  Result := Pos('WKE',IDSConnectSupportedProcesses.ToUpper)>0;
end;

function TOpenConnectConnectivityOptions.Support_IDSConnectWKSProcess: Boolean;
begin
  Result := false;
  if not IDSConnectAvailable then
    exit;
  Result := Pos('WKS',IDSConnectSupportedProcesses.ToUpper)>0;
end;

{ TOpenConnectDatanormFile }

constructor TOpenConnectDatanormFile.Create;
begin
  Cookie := TStringList.Create;
  Clear;
end;

destructor TOpenConnectDatanormFile.Destroy;
begin
  if Assigned(Cookie) then begin Cookie.Free; Cookie := nil; end;
  inherited;
end;

procedure TOpenConnectDatanormFile.Clear;
begin
  FileID := 0;
  FileURL := '';
  FileSize := 0;
  FileName := '';
  FileDate := 0;
  Text := '';
  HttpAuthActiv := false;
  HttpAuthUsername := '';
  HttpAuthPassword := '';
  CookieActiv := false;
  Cookie.Clear;
end;

end.

