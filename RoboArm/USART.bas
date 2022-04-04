﻿B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=11.2
@EndOfDesignText@
#Event: DataAck
#Event: RunAck
#Event: StopAck
#Event: WorkDone
#Event: DriverNotReady
#Event: AdapterConnected
#Event: DriverConnected
#Event: DriverDisConnect

'Zmienne globalne  (w zakresie klasy)
Sub Class_Globals
	
	Private xui As XUI													'zmienna graficzna
	
	Private mTarget As Object											'obiekt klasy nadrzędnej
	Private mEventName As String										'nazwa eventu
	
	Type Device(Name As String, MAC As String)							'typ danuch opisujący zewnętrzne urządzenie bluetooth
	Private AvailableDevices As List									'lista odnalezionych urządzeńbluetooth
	
	Private Adapter As BluetoothAdmin									'wewnętrzny moduł bluetooth
	Private CommPort As Serial											'port szeregowy
	Private AsyncText As AsyncStreamsText								'komunikacja asynchroniczna
	
	'Type Frame(StartCode As String, Data1 As String, Data2 As String, Data3 As String, Data4 As String, EndCode As String, Complete As Boolean)
	Private ReceivedFrame As List										'ramka danych odebrana z uC
	
	Public IsAdapterConnected As Boolean								'czy zewnętrzny moduł bluetooth jest podłączony?
	
	
End Sub

'Inicjalizacja klasy
Public Sub Initialize(TargetModule As Object, EventName As String)
	
	Adapter.Initialize("Adapter")													'inicjalizacja modułu bluetooth
	CommPort.Initialize("CommPort")													'inicjlizacja portu szeregowego
	IsAdapterConnected = False														'wewnętrzny bluetooth nie połączony
	ReceivedFrame.Initialize														'inicjalizacja ramki danych
	mTarget = TargetModule															'ustawienie modułu nadrzędnego
	mEventName = EventName															'ustawienie nazwy eventu
	ReceivedFrame.Initialize														'inicjalizacja ramki danych
	
End Sub

#Region AdapterProcedures

Public Sub AskWindow(Question As String) As Object
	
	'procedura wyświetla okienko z zapytanie czy podłączyć urządzenie
	Return xui.Msgbox2Async(Question, "BLUETOOTH", "TAK", "", "NIE", LoadBitmap(File.DirAssets, "Question.png"))
	
End Sub

Public Sub ErrorWindow(Message As String)
	
	'procedura wyświetla komunikat błędu
	xui.Msgbox2Async(Message, "BLUETOOTH", "", "", "OK", LoadBitmap(File.DirAssets, "Error.png"))
	
End Sub

Public Sub InfoWindow(Message As String)
	
	'procedura wyświetla komunikat informacyjny
	xui.Msgbox2Async(Message, "BLUETOOTH", "", "", "OK", LoadBitmap(File.DirAssets, "Information.png"))
	
End Sub

Public Sub WarningWindow(Message As String)
	
	'procedura wyświetla komunikat ostrzegawczy
	xui.Msgbox2Async(Message, "BLUETOOTH", "", "", "OK", LoadBitmap(File.DirAssets, "Warning.png"))
	
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
	
	Dim DeviceInList As Device														'urządzenie na liście
	Dim CompatibilityDevice As Device												'kompatybilne urządzenie
	Dim IsFoundNotCompatibile = False As Boolean									'czy znaleziono niekompatybilne urządzenia
	
	For i = 0 To AvailableDevices.Size - 1
		DeviceInList = AvailableDevices.Get(i)										'pobierz pierwsze na liscie urządzenie
		If DeviceInList.Name == DeviceName Then										'jeśli nazwa pasuje do wzorca to:
			IsFoundNotCompatibile = True											'znaleziono kompatybilne urządzenie
			CompatibilityDevice = DeviceInList										'pobranie kompatybilnego urządzenia z listy znalezionych
		End If
	Next
	
	If AvailableDevices.Size == 0 Or IsFoundNotCompatibile == False Then			'jeśli nie odnaleziono żadnego urządzenia:
		InfoWindow("Nie odnaleziono kompatybilnego urządzenia")						'wyświetl komunikat o braku urządzeń
	Else
		If IsFoundNotCompatibile == True Then										'jeśli znaleziono kompatybilne urządzenie to:
			CommPort.Connect(CompatibilityDevice.MAC)								'podłącz do urządzenia poprzez port szeregowy
			ProgressDialogShow("Próba podłaczenia urządzenia : " & DeviceName)		'wyświetl okno informujące o prcesi podłączania
		End If
	End If
	
End Sub

Public Sub Send(Message As String)
	
	AsyncText.Write(Message & Chr(10) & Chr(13))									'wysłanie tekstu przez bluetooth
	
End Sub

Public Sub SendStatusFrame(StatusValue As String)
	
	Send("SF")
	Send("STATUS")
	Send(StatusValue)
	Send("0")
	Send("0")
	Send("0")
	Send("0")
	Send("EF")
	
End Sub

Public Sub SendRunFrame
	
	Send("SF")
	Send("JOB")
	Send("0")
	Send("0")
	Send("0")
	Send("0")
	Send("0")
	Send("EF")
	
End Sub

Public Sub SendStopFrame
	
	Send("SF")
	Send("EJOB")
	Send("0")
	Send("0")
	Send("0")
	Send("0")
	Send("0")
	Send("EF")
	
End Sub

Public Sub SendWorkFrame(FrameType As String, FrameData As Map)
	
	Dim DataList As List															'lista danych do wysłania
	DataList.Initialize																'inicjalizacja listy danych
	DataList.Add("SF")																'dodanie do listy kodu początku ramki
	DataList.Add(FrameType)															'dodanie do listy typu ramki
	Dim axis = FrameData.Get("Name") As String
	DataList.Add(axis.SubString2(axis.Length - 1, axis.Length))
	
	Dim angle = FrameData.Get("Angle") As String
	DataList.Add(angle)
	
	Dim angle = FrameData.Get("Speed") As String
	DataList.Add(angle)
	
	Dim angle = FrameData.Get("Dir") As String
	DataList.Add(angle)
	
	Dim angle = FrameData.Get("Blend") As String
	DataList.Add(angle)
	
	DataList.Add("EF")															 	'dodanie do listy kodu końca ramki
	
	For i = 0 To DataList.Size - 1													'iteracja po liście danych do wysłania
		Log(DataList.Get(i))														'wysyłanie elementów z listy
		Send(DataList.Get(i))
	Next
	
End Sub

Private Sub GetData(DataText As String) As Int
	
	ReceivedFrame.Add(DataText.Trim)												'zapisz odebrane dane
	Log(DataText.Trim)
	If ReceivedFrame.Size == 8 Then													'jeśli odebrano 7 pakietów to:
		If ReceivedFrame.Get(0) == "SF" And ReceivedFrame.Get(7) == "EF" Then		'sprawdź czy ramka posiada prawidłowe kody początku i końca, jeśli tak to:
			Dim Status = ReceivedFrame.Get(2) As Int								'odczytaj kod statusu
			Select Status															'sprawdź kod statusu
				Case 1																'jeśli kod statusu 1 to:
					ReceivedFrame.Initialize										'czyszczenie zawartoci ramki
					Return 1														'zwróć 1 (sterownik potwierdza odebranie danych)
				Case 2																'jeśli kod statusu 2 to:
					ReceivedFrame.Initialize										'czyszczenie zawartoci ramki
					Return 2														'zwróć 2 (sterownik potwierdza połączenie)
				Case 3																'jeśli kod statusu 3 to:
					ReceivedFrame.Initialize										'czyszczenie zawartoci ramki
					Return 3														'zwróć 3 (sterownik potwierdza odłączenie)
				Case 4																'jeśli kod statusu 4 to:
					ReceivedFrame.Initialize										'czyszczenie zawartoci ramki
					Return 4														'zwróć 4 (sterownik potwierdza uruchomienie robota)
				Case 5																'jeśli kod statusu 5 to:
					ReceivedFrame.Initialize										'czyszczenie zawartoci ramki
					Return 5														'zwróć 5 (sterownik potwierdza zatrzymanie robota)
				Case 6																'jeśli kod statusu 6 to:
					ReceivedFrame.Initialize										'czyszczenie zawartoci ramki
					Return 6														'zwróć 6 (robot zakończył pracę)
				Case 99																'jeśli kod statusu 99 to:
					ReceivedFrame.Initialize										'czyszczenie zawartoci ramki
					Return 99														'zwróć 99 (sterownik nie gotowy)
			End Select
			Return 0
		Else																		'jeśli ramka zawiera nieprawidłowe kody startu ikońca to:
			ErrorWindow("Ramka zawiera błędne dane.")								'wyświetl okno błędu
			Return 0																'zwróć cyfrę 0
		End If
	Else																			'jeśli ramka zawiera mniej niż 8 wartości to :
		Return 0																	'zwróć cyfrę 0
	End If
	
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
	Log(Name)
	
End Sub

Private Sub Adapter_DiscoveryFinished
	
	Connect("ROBOARM")	
	'Connect("HC-05")																'podłącz urządzenie RoboArm
	
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
		CallSub(mTarget, mEventName & "_AdapterConnected")									'wywołanie eventu potwierdzenia podłaczenie adaptera bluetooth
		
	Else																					'w przeciwnym razie :
		ErrorWindow("Problem z nawiązaniem połączenia")										'wyświetl błąd połączenia		
	End If
	
End Sub


Private Sub AsyncText_Terminated
	
	WarningWindow("Połączenie zostało zerwane")										'informacjao zerwaniu połączenia
	
End Sub

Private Sub AsyncText_NewText (Text As String)
	
	Dim s = Text As String
	Select GetData(s) 																'jeśli odebrano ramkę danych to:
		Case 1
			CallSub(mTarget, mEventName & "_DataAck")								'wywołanie eventu potwierdzenia odbioru danych
		Case 2
			CallSub(mTarget, mEventName & "_DriverConnected")						'wywołanie eventu potwierdzenia podłączenie sterownika
		Case 3
			CallSub(mTarget, mEventName & "_DriverDisConnect")						'wywołanie eventu potwierdzenia odłączenie sterownika
		Case 4
			CallSub(mTarget, mEventName & "_RunAck")								'wywołanie eventu potwierdzającego uruchomienie robota
		Case 5 
			CallSub(mTarget, mEventName & "_StopAck")								'wywołanie eventu potwierdzającego zatrzymanie robota
		Case 6
			CallSub(mTarget, mEventName & "_WorkDone")								'robot zakończył pracę
		Case 99
			CallSub(mTarget, mEventName & "_DriverNotReady")						'wywołanie eventu informującego że sterownik nie jest gotowy
	End Select
End Sub


#End Region