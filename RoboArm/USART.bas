B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=11.2
@EndOfDesignText@
Sub Class_Globals
	
	Private xui As XUI													'zmienna graficzna
	
	Type Device(Name As String, MAC As String)							'typ danuch opisujący zewnętrzne urządzenie bluetooth
	Private AvailableDevices As List									'lista odnalezionych urządzeńbluetooth
	
	Private Adapter As BluetoothAdmin									'wewnętrzny moduł bluetooth
	Private CommPort As Serial											'port szeregowy
	Private AsyncText As AsyncStreamsText								'komunikacja asynchroniczna
	
	Public IsAdapterConnected As Boolean								'czy zewnętrzny moduł bluetooth jest podłączony?
	Public ReceivedText As String										'trkst odebrany przez bluetooth
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
	Adapter.Initialize("Adapter")													'inicjalizacja modułu bluetooth
	CommPort.Initialize("CommPort")													'inicjlizacja portu szeregowego
	IsAdapterConnected = False														'wewnętrzny bluetooth nie połączony
	
End Sub

#Region AdapterProcedures

Private Sub AskWindow(Question As String) As Object
	
	'procedura wyświetla okienko z zapytanie czy podłączyć urządzenie
	Return xui.Msgbox2Async(Question, "PYTANIE", "TAK", "", "NIE", LoadBitmap(File.DirAssets, "Question.png"))
	
End Sub

Private Sub ErrorWindow(Message As String)
	
	'procedura wyświetla komunikat błędu
	xui.Msgbox2Async(Message, "BŁĄD", "", "", "OK", LoadBitmap(File.DirAssets, "Error.png"))
	
End Sub

Private Sub InfoWindow(Message As String)
	
	'procedura wyświetla komunikat informacyjny
	xui.Msgbox2Async(Message, "INFORMACJA", "", "", "OK", LoadBitmap(File.DirAssets, "Information.png"))
	
End Sub

Private Sub WarningWindow(Message As String)
	
	'procedura wyświetla komunikat ostrzegawczy
	xui.Msgbox2Async(Message, "OSTRZEŻENIE", "", "", "OK", LoadBitmap(File.DirAssets, "Warning.png"))
	
End Sub


Public Sub Run
	
	If Adapter.IsEnabled = False Then												'czy bluetooth jest załączony ?
		If Adapter.Enable = False Then												'jeśli nie to go włącz. Czy udało się włączyć ?
			ErrorWindow("Problem z uruchomieniem !")								'jeśli nie to komunikat błędu
		Else
			ToastMessageShow("Włączam adapter blutooth...", False)					'jeśli tak to komunikat ok
		End If
	Else
		Adapter_StateChanged(Adapter.STATE_ON, 0)									'jeśli tak to zmien stan na załączony
	End If
	
End Sub

Public Sub Serch
	
	AvailableDevices.Initialize														'inicjalizacja listy urządzeń
	
	If Adapter.StartDiscovery = False Then											'jeśli proces poszukiwania urochomiomy poprawnie to:
		ErrorWindow("Problem z uruchomieniem wyszukiwania !")						'wyświetl informacje o błędzie poszukiwaniau urządzeń
	Else																			'wprzeciwnym razie:
		ToastMessageShow("Poszukiwanie urządzeń", False)							'wyświetl informacje o poszukiwaniu urządzeń
	End If
	
End Sub

Private Sub Connect(DeviceName As String)
	
	ProgressDialogHide																'ukrycie okna postępu wyszukiwania	
	
	Dim DeviceInList As Device														'kompatybilne urządzenie
	Dim IsFoundNotCompatibile = False As Boolean									'czy znaleziono niekompatybilne urządzenia
	
	For i = 0 To AvailableDevices.Size - 1
		DeviceInList = AvailableDevices.Get(i)										'pobierz pierwsze na liscie urządzenie
		IsFoundNotCompatibile = True												'ustawienie flagi niekompatybilnych urządzeń
		If DeviceInList.Name == DeviceName Then										'jeśli nazwa pasuje do wzorca to:
			IsFoundNotCompatibile = False											'zerowanie flagi niekompatybilnych urządzeń
			CommPort.Connect(DeviceInList.MAC)										'podłącz do urządzenia poprzez port szeregowy
			ProgressDialogShow("Próba podłaczenia urządzenia : " & DeviceName)		'wyświetl okno informujące o prcesi podłączania
		End If
	Next
	
	If AvailableDevices.Size == 0 Or IsFoundNotCompatibile Then						'jeśli nie odnaleziono żadnego urządzenia:
		InfoWindow("Nie odnaleziono kompatybilnego urządzenia")						'wyświetl komunikat o braku urządzeń
	End If
	
End Sub

Public Sub Send(Message As String)
	
	AsyncText.Write(Message)														'wysłanie tekstu przez bluetooth
	
End Sub

#End Region

#Region AdapterEvents

Private Sub Adapter_DiscoveryStarted
	
	ProgressDialogShow("Ilość urządzeń ... 0")										'okno postępu wyszukiwania
	
End Sub

Private Sub Adapter_DeviceFound (Name As String, MacAddress As String)
	
	Dim device As Device															'wykryte urządzenie
	device.Name = Name																'nazwa wykrytego urządzenia
	device.MAC = MacAddress															'macadres wykrytego urządzenia
	AvailableDevices.Add(device)													'dodania wykrytego urządzenia do listy
	ProgressDialogShow("Ilość urządzeń ... @".Replace("@", AvailableDevices.Size))	'aktualizacja okna postępu wyszukiwania
	
End Sub

Private Sub Adapter_DiscoveryFinished
	
	Connect("HC-05")																'podłącz urządzenie RoboArm
	
End Sub

Private Sub Adapter_StateChanged (NewState As Int, OldState As Int)
	
End Sub

Private Sub CommPort_Connected (Success As Boolean)
	
	If Success == True And IsAdapterConnected == False Then									'jeśli połączenie się powiodło to:
		IsAdapterConnected = True															'ustaw zmienną 
		ProgressDialogHide																	'ukryj okno postępu połączenia
		If AsyncText.IsInitialized Then														'jeśli komunikacja asynchronicza jest już zainicjowana t:
			AsyncText.Close																	'zamknij kanał
		End If
		AsyncText.Initialize(Me, "AsyncText", CommPort.InputStream, CommPort.OutputStream)	'inicjalizacja komunikacji asynchronicznej
		InfoWindow("Połączenie przebiegło pomyślnie")										'pokaż info
		IsAdapterConnected = True															'ustaw zmienną informującą o stanie połaczenia
		
	Else																					'w przeciwnym razie :
		ErrorWindow("Problem z nawiązaniem połączenia")										'wyświetl błąd połączenia		
	End If
	
End Sub


Private Sub AsyncText_Terminated
	
	WarningWindow("Połączenie zostało zerwane")
	
End Sub

Private Sub AsyncText_NewText (Text As String)
	
	ReceivedText = Text																		'odczyt tekstu z bluetooth
	
End Sub


#End Region