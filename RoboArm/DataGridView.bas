B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=11.2
@EndOfDesignText@
'Custom View class 
#Event: ExampleEvent (Value As Int)
#DesignerProperty: Key: RowBackground, DisplayName: Tło wiersza, FieldType: Color, DefaultValue: 0xFFFFFFFF, Description: Kolor tła celek kolumny
#DesignerProperty: Key: GapColor, DisplayName: Kolor linii tabeli, FieldType: Color, DefaultValue: 0xFF000000, Description: Kolor linii między wierszami i kolumnami
#DesignerProperty: Key: ItemTextColor, DisplayName: Kolor wartości, FieldType: Color, DefaultValue: 0xFF000000, Description: Kolor napisów we wierszach tabeli
#DesignerProperty: Key: HeaderBackground, DisplayName: Tło nagłówka, FieldType: Color, DefaultValue: 0xFF808080, Description: Kolor tła nagłówków
#DesignerProperty: Key: HeaderTextColor, DisplayName: Kolor nagłówka, FieldType: Color, DefaultValue: 0xFF000000, Description: Kolor napisów w nagłówkach tabeli

Sub Class_Globals
	
	Private xui As XUI
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Private mBase As Panel
	Private Const DefaultColorConstant As Int = -984833 'ignore
	
	Private RowBackground As Int													'kolor tła celek kolumny
	Private GapColor As Int															'kolor linii między wierszami i kolumnami
	Private ItemTextColor As Int													'kolor napisów we wierszach tabeli
	Private HeaderBackground As Int													'kolor tła nagłówków
	Private HeaderTextColor As Int													'kolor napisów w nagłówkach
	
	Private HeadersTop = 2 As Int													'położenie nagłówków względem górnrj krawędzi kontrolki
	
	Private ColumnWidth As Int														'szerokość kolumny
	Private ColumnsGap = 4 As Int													'odstęp między kolumnami
	Private ColumnsCount = 5 As Int													'ilość kolumn
	
	Private RowHeight = 70 As Int													'wysokość wiersza
	Private RowsGap = 4 As Int														'odstęp między wierszami
	Private RowsCount = 1 As Int													'licznik wierszy
	
	Private Rows As Map																'dane zawarte w tabeli
	
End Sub

Public Sub Initialize (Callback As Object, EventName As String)
	mEventName = EventName
	mCallBack = Callback
End Sub

Public Sub DesignerCreateView (Base As Panel, Lbl As Label, Props As Map)
	
	mBase = Base																	'przypisanie panela dla kontrolki
	
	Rows.Initialize																	'inicjalizacja danych tabeli
	RowBackground = Props.Get("RowBackground")										'pobranie wartości właściwości koloru tła wierszy
	GapColor = Props.Get("GapColor")												'pobranie wartości właściwości koloru linii
	ItemTextColor = Props.Get("ItemTextColor")										'pobranie wartości właściwości koloru napisów we wierszach
	HeaderBackground = Props.Get("HeaderBackground")								'pobranie wartości właściwości koloru tla nagłóków
	HeaderTextColor = Props.Get("HeaderTextColor")									'pobranie wartości właściwości koloru napisów w nagłówkach
	
	mBase.Color = GapColor															'ustawienie koloru linii
	ColumnWidth = mBase.Width / ColumnsCount - ColumnsGap 							'obliczenie szerokości kolumny
	
	InsertHeaders																	'umieszczenie w kontrolce nagłówków tabeli
    
End Sub

Public Sub GetBase As Panel
	Return mBase
End Sub

'procedura wstawia nagłówki do tabeli
Private Sub InsertHeaders
	
	mBase.Height = RowsGap + RowHeight								'ustawienie wysokości tabelki
	
	Dim hName As Label												'deklaracja labelki nagłówka kolumny nazwy osi
	Dim hAngle As Label												'deklaracja labelki nagłówka kolumny kąta osi
	Dim hSpeed As Label												'deklaracja labelki nagłówka kolumny prędkości osi
	Dim hDir As Label												'deklaracja labelki nagłówka kolumny kierunku osi
	Dim hBlend As Label												'deklaracja labelki nagłówka kolumny miksowania ruchów
	Dim headers As List												'deklaracja listy labelek nagłówków
	
	headers.Initialize												'inicjalizacja listy labelek
	
	hName.Initialize("HeaderEvent")									'inicjalizacja labelki
	hAngle.Initialize("HeaderEvent")								'-- || --
	hSpeed.Initialize("HeaderEvent")								'-- || --
	hDir.Initialize("HeaderEvent")									'-- || --
	hBlend.Initialize("HeaderEvent")								'-- || --
	
	hName.Text = " Oś"												'wstawienie napisu do labelki
	hAngle.Text = " Kąt"												'-- || --
	hSpeed.Text = " Obroty"											'-- || --
	hDir.Text = " Kierunek"											'-- || --
	hBlend.Text = " Blend"											'-- || --
	
	headers.Add(hName)												'wstawienie labelki do listy
	headers.Add(hAngle)												'-- || --
	headers.Add(hSpeed)												'-- || --
	headers.Add(hDir)												'-- || --
	headers.Add(hBlend)												'-- || --
	
	For i = 0 To ColumnsCount - 1
		Dim h = headers.Get(i) As Label								'pobranie labelki z listy
		h.Tag = ":header:"											'ustawienie tagu labelki
		h.Color = HeaderBackground									'ustawienie koloru tła nagłówka
		h.TextColor = HeaderTextColor								'ustawienie koloru tekstu w nagłówka
		mBase.AddView(h, (ColumnWidth * i) + ((i + 1) * ColumnsGap), HeadersTop, ColumnWidth, RowHeight)	'wstawienie nagłówka do tabeli
	Next
	
End Sub

'procedura wstawia wiersz danych do tabeli
Public Sub InsertRow(RowData As List)

	mBase.Height = RowsGap + RowHeight + mBase.Height				'ustawienie wysokości tabelki
	Private row As Map												'deklaracja zmiennej danych wiersza
	row.Initialize													'inicjalizacja danych wiersza
	Dim tags As List												'deklaracja listy tagów dla celek tabeli
	tags.Initialize													'inicjalizacja listy tagów
	tags.Add("Name")												'wstawienie tagu nazwy do listy
	tags.Add("Angle")												'wstawienie tagu kąta do listy
	tags.Add("Speed")												'wstawienie tagu prędkości do listy
	tags.Add("Dir")													'wstawienie tagu kierunku do listy
	tags.Add("Blend")												'wstawienie tagu miksowania ruchów do listy
	
	Dim axisName = RowData.Get(0) As String							'pobranie nazwy osi z listy danych podanej jako parametr procedury
	
	For i = 0 To 3
		row.Put(tags.Get(i), RowData.Get(i))						'zapis danych wiersza w warstwie danych (Key:tag, Value:RowData[i])
		Dim item As Label											'deklaracja labelki do wyświetlania wartości w warstwie wizualnej
		item.Initialize("ItemEvent")								'inicjalizacja labelki
		item.Color = RowBackground									'ustawienie koloru tła labelki
		item.TextColor = ItemTextColor								'ustawienie koloru tekstu w labelce
		item.Gravity = Gravity.CENTER								'centrowanie tekstu
		item.Text = RowData.Get(i)									'wstawienie do labelki tekstu z listy danych
		item.Tag = tags.Get(i) & ":" & axisName & ":"				'ustawienie tagu
		'wyświetlenie celki tabeli
		mBase.AddView(item, (ColumnWidth * i) + ((i + 1) * ColumnsGap), (RowHeight * RowsCount) + (RowsCount * RowsGap), ColumnWidth, RowHeight)
	Next
	
	Dim blendCheckBox As CheckBox									'deklaracja zmiennej do załączania/wyłączania miksowania ruchów
	blendCheckBox.Initialize("BlendChecked")						'inicjalizacja checkbox'a
	blendCheckBox.Tag = tags.Get(4) & ":" & axisName & ":"			'ustawienie tagu
	blendCheckBox.Color = RowBackground								'ustawienie koloru tła
	If RowData.Get(4) == "1" Then									'jeśli przekazana wartość miksowania = 1 to:
		blendCheckBox.Checked = True								'właczenie miksowania ruchów
		row.Put(tags.Get(4), blendCheckBox.Checked)					'dodanie do wiersza informacji o miksowaniu ruchów
	Else
		blendCheckBox.Checked = False								'wyłączenie miksowania róchów
		row.Put(tags.Get(4), blendCheckBox.Checked)					'dodanie do wiersza informacji o miksowaniu ruchów
	End If
	'wyświetlenie celki tabeli
	mBase.AddView(blendCheckBox, (ColumnWidth * 4) + ((4 + 1) * ColumnsGap), (RowHeight * RowsCount) + (RowsCount * RowsGap), ColumnWidth, RowHeight)
	Rows.Put(RowData.Get(0), row)
	RowsCount = RowsCount + 1
	
End Sub

'procedura usuwa wskazany wiersz z tabeli
Public Sub DeleteRow(Axis As String)
	
	Dim isRowDeleted As Boolean														'czy wiersz został usunięty
	Dim keyAxis = "Oś " & Axis As String											'nazwa wiersza do zmodyfikowania
	Dim deletedPosition = 0 As Int													'zmienna do zapamietywania pozycji top usuwanych elementów
	
	'usuwanie wizualnych elementóe tabeli
	For Each item As View In mBase.GetAllViewsRecursive								'iteracja po elementach wizualnych panela
		Dim tag = item.Tag As String												'pobranie ptagu elementu
		If tag.Contains(":" & keyAxis & ":") Then									'jeśli tag pasuje do wzorca, to:
			deletedPosition = item.Top												'ustaw pozycję usuwanych elementów
			item.RemoveView															'usuń element z panela
			isRowDeleted = True														'tak wiersz został usunięty
		End If
	Next
	
	If isRowDeleted == True Then
		Rows.Remove(keyAxis)														'usuń dane wiersza
		RowsCount = RowsCount - 1													'dekrementacja licznika wierszy
	
		'przesuwanie wierszy w górę
		For Each item As View In mBase.GetAllViewsRecursive							'iteracja po elementach wizualnych panela
			If item.Top > deletedPosition Then										'jesli element jest poniżej usuniętego, to:
				item.Top = item.Top - (RowHeight + RowsGap)							'przesuń element w miejsce usuniętego
			End If
		Next
		mBase.Height = mBase.Height - RowsGap - RowHeight							'ustawienie wysokości tabelki
	End If
	
End Sub

'procedura pobiera wartość elementu który znajduje się we wierszu podanej Osi (np. A) oraz we wskazanej kolumnie
Public Sub GetItem(Axis As String, Column As String) As String
	
	Dim itemValue As String															'zmienna do przechowywania pobranej wartości
	Dim row = Rows.Get(("Oś " & Axis)) As Map										'odczyt wiersza danych wskazanej osi
	itemValue = row.Get(Column)														'pobranie wartość ze wskazanej kolumny
	Return itemValue																'zwrócenie odczytanej wartości
	
End Sub

'procedura wstawia dane do wiersza wskazanej osi (np. Z) i podanej kolumny
Public Sub SetItemValue(Axis As String, Column As String, Value As String) As Boolean
	
	Dim keyAxis = "Oś " & Axis As String											'nazwa wiersza do zmodyfikowania
	Dim row = Rows.Get(keyAxis) As Map												'pobranie wiersza do modyfikacji
	If row.IsInitialized Then														'sprawdzenie czy w tabeli istnieje podany wiersz
		row.Put(Column, Value)														'zapis nowej wartości do wskazanej kolumny
	
		For Each item In mBase.GetAllViewsRecursive									'iteracja po elementach wizualnych panela
			Dim it = item As Label													'pobranie pierwszego elementu panela
			Dim tagitem = it.Tag As String											'odczyt tagu elementu
			If tagitem.Contains(Column & ":" & keyAxis & ":") Then					'jeśli tag pasuje do wzorca, to:
				it.Text = Value														'zmień zawartość elementu
			End If
		Next
	
		Return True
		
	Else
		Return False	
	End If
End Sub

'procedura sprawdza czy dany wiersz już istenieje
Public Sub IsRowExist(Name As String) As Boolean
	
	Return Rows.ContainsKey(Name)													'sprawdź czy wiersz o podanej nazwie znajduje się w tabeli
	
End Sub

'procedura zwraca całą tabelę
Public Sub GetTable As Map
	Return Rows
End Sub


Public Sub BlendChecked_CheckedChange(Checked As Boolean)
	
	Dim cb = Sender As CheckBox
	Dim tag = cb.Tag As String
	
	Dim axis = tag.SubString2(tag.IndexOf(":") + 1, tag.LastIndexOf(":")) As String		'pobierz nazwę osi
	Dim row = Rows.Get(axis) As Map														'pobierz wiersz tabeli
	If row.IsInitialized Then
		row.Put(tag.SubString2(0, tag.IndexOf(":")), cb.Checked)						'zmień wartość miksowania
	End If


End Sub

'rozpoczęcie prac nad modułem: 21-02-2022
