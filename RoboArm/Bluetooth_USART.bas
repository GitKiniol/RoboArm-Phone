B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=11.2
@EndOfDesignText@
Sub Class_Globals
	
	Private xui As XUI																			'zmienna 
	
	Private ComPort As Serial																	'zmienna do obsługi portu szeregowego
	Private Bluetooth As BluetoothAdmin															'zmienna do obsługi sprzętowego modułu Bluetooth
	Private SerialData As AsyncStreamsText														'zmienna do odbioru i wysyłania danych
	
	Private AvailableDevices As List															'lista znalezionych urządzeń
	Type Device (Name As String, MAC As String)													'typ opisujący urządzenie bluetooth
	Private ConnectedDevice As Device															'podłączone urządzenie
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(Bt As BluetoothAdmin, Cp As Serial, Sd As AsyncStreamsText)
	
	ComPort = Cp
	Bluetooth = Bt
	SerialData = Sd
	Bluetooth.Initialize("BluetoothEvent")
	ComPort.Initialize("ComPortEvent")
	
End Sub

Public Sub Run
	
	If Bluetooth.IsEnabled = False Then
		If Bluetooth.Enable = False Then
			ToastMessageShow("Nie udało się włączyć blutooth", True)
		Else
			ToastMessageShow("Włączam adapter blutooth...", False)
		End If
	Else
		BluetoothEvent_StateChanged(Bluetooth.STATE_ON, 0)
	End If
	
End Sub

Public Sub Search
	
	AvailableDevices.Initialize																	'inicjalizacja listy urządzeń
	If Bluetooth.StartDiscovery == True Then													'start wyszukiwania
		ToastMessageShow("Wyszkiwanie rozpoczęte", False)										'informacja o starcie wyszukiwania
	Else
		xui.Msgbox2Async("Coś poszło nie tak podczas urochamiania wyszukiwania", "Bluetooth", "", "", "OK", LoadBitmap(File.DirAssets, "Warning.png")) 
	End If
	
End Sub

Private Sub BluetoothEvent_DiscoveryStarted
	
	ProgressDialogShow("Dostępne urządzenia..0")
	
End Sub

Private Sub BluetoothEvent_DeviceFound (Name As String, MacAddress As String)
	
	Dim device As Device
	device.Name = Name
	device.MAC = MacAddress
	AvailableDevices.Add(device)
	ProgressDialogShow("Dostępne urządzenia..@".Replace("@", AvailableDevices.Size))
	
End Sub

Private Sub BluetoothEvent_DiscoveryFinished
	
End Sub

Private Sub BluetoothEvent_StateChanged (NewState As Int, OldState As Int)
	
End Sub




