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
'#DesignerProperty: Key: BooleanExample, DisplayName: Boolean Example, FieldType: Boolean, DefaultValue: True, Description: Example of a boolean property.
'#DesignerProperty: Key: IntExample, DisplayName: Int Example, FieldType: Int, DefaultValue: 10, MinRange: 0, MaxRange: 100, Description: Note that MinRange and MaxRange are optional.
'#DesignerProperty: Key: StringWithListExample, DisplayName: String With List, FieldType: String, DefaultValue: Sunday, List: Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday
'#DesignerProperty: Key: StringExample, DisplayName: String Example, FieldType: String, DefaultValue: Text
'#DesignerProperty: Key: ColorExample, DisplayName: Color Example, FieldType: Color, DefaultValue: 0xFFCFDCDC, Description: You can use the built-in color picker to find the color values.
'#DesignerProperty: Key: DefaultColorExample, DisplayName: Default Color Example, FieldType: Color, DefaultValue: Null, Description: Setting the default value to Null means that a nullable field will be displayed.
Sub Class_Globals
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Private mBase As Panel
	Private Const DefaultColorConstant As Int = -984833 'ignore
	
	Private RowBackground As Int													'kolor tła celek kolumny
	Private GapColor As Int															'kolor linii między wierszami i kolumnami
	Private ItemTextColor As Int													'kolor napisów we wierszach tabeli
	
	Private HeadersTop = 2 As Int													'położenie nagłówków względem górnrj krawędzi kontrolki
	
	Private ColumnWidth As Int														'szerokość kolumny
	Private ColumnsGap = 4 As Int													'odstęp między kolumnami
	Private ColumnsCount = 5 As Int													'ilość kolumn
	
	Private RowHeight = 70 As Int													'wysokość wiersza
	
End Sub

Public Sub Initialize (Callback As Object, EventName As String)
	mEventName = EventName
	mCallBack = Callback
End Sub

Public Sub DesignerCreateView (Base As Panel, Lbl As Label, Props As Map)
	
	mBase = Base																	'przypisanie panela dla kontrolki
	
	RowBackground = Props.Get("RowBackground")										'pobranie wartości właściwości koloru tła
	GapColor = Props.Get("GapColor")												'pobranie wartości właściwości koloru linii
	ItemTextColor = Props.Get("ItemTextColor")										'pobranie wartości właściwości koloru napisów
	
	mBase.Color = GapColor															'ustawienie koloru linii
	ColumnWidth = mBase.Width / ColumnsCount - ColumnsGap 							'obliczenie szerokości kolumny
	
	InsertHeaders																	'umieszczenie w kontrolce nagłówków tabeli
    
End Sub

Public Sub GetBase As Panel
	Return mBase
End Sub

'procedura wstawia nagłówki do tabeli
Private Sub InsertHeaders
	
	Dim hName As Label
	Dim hAngle As Label
	Dim hSpeed As Label
	Dim hDir As Label
	Dim hBlend As Label
	Dim headers As List
	
	headers.Initialize
	hName.Initialize("HeaderEvent")
	hName.Text = "Oś"
	headers.Add(hName)
	hAngle.Initialize("HeaderEvent")
	hAngle.Text = "Kąt"
	headers.Add(hAngle)
	hSpeed.Initialize("HeaderEvent")
	hSpeed.Text = "Obroty"
	headers.Add(hSpeed)
	hDir.Initialize("HeaderEvent")
	hDir.Text = "Kierunek"
	headers.Add(hDir)
	hBlend.Initialize("HeaderEvent")
	hBlend.Text = "Blend"
	headers.Add(hBlend)
	
	For i = 0 To ColumnsCount - 1
		Dim h = headers.Get(i) As Label
		h.Tag = ":header:"
		h.Color = Colors.Gray
		h.TextColor = Colors.Black
		mBase.AddView(h, (ColumnWidth * i) + ((i + 1) * ColumnsGap), HeadersTop, ColumnWidth, RowHeight)
	Next
	
End Sub

'rozpoczęcie prac nad modułem 21-02-2022