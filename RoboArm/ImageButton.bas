B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=11.2
@EndOfDesignText@
'Custom View class 
#Event: Click
#RaisesSynchronousEvents: Click
#DesignerProperty: Key: ButtonText, DisplayName: Napis w przycisku, FieldType: String, DefaultValue: Przycisk, Description: Napis wyświetlany w przycisku.
#DesignerProperty: Key: FrameColor, DisplayName: Kolor ramki, FieldType: Color, DefaultValue: 0xFF000000, Description: Kolor obramowania przycisku.
#DesignerProperty: Key: BackgroundColor, DisplayName: Kolor tła, FieldType: Color, DefaultValue: 0xFFD3D3D3, Description: Kolor tła przycisku.
#DesignerProperty: Key: TextPosY, DisplayName: Położenie tekstu Y, FieldType: Int, DefaultValue: 25, Description: Położenie tekstu w osi Y (procent wysokości przycisku)
#DesignerProperty: Key: TextPosX, DisplayName: Położenie tekstu X, FieldType: Int, DefaultValue: 27, Description: Położenie tekstu w osi X (procent szerokości przycisku)
#DesignerProperty: Key: ImageWidth, DisplayName: Szerokość obrazka, FieldType: Int, DefaultValue: 15, Description: Szerokość obrazka liczona w procentach szerokości przycisku
#DesignerProperty: Key: ImageHeight, DisplayName: Wysokość obrazka, FieldType: Int, DefaultValue: 96, Description: Wysokość obrazka liczona w procentach wysokości przycisku


Sub Class_Globals
	
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Private mBase As Panel
	Private Const DefaultColorConstant As Int = -984833 'ignore
	
	Private FrameColor As Int		'kolor ramki przycisku
	Private BackgroundColor As Int	'kolor tła przycisku
	Private ButtonText As String	'tekst dla przycisku
	Private ButtonTextPosY As Int	'pozycja tekstu Y
	Private ButtonTextPosX As Int	'pozycja tekstu X
	Private ImageWidth As Int		'szerokość obrazka
	Private ImageHeight As Int      'wysokość obrazka
	
	Private ButtonPanel As Panel	'panel na którym umieszczone są elementy przycisku
	Private Image As ImageView		'obrazek
	Private ButtonLabel As Label	'labelka z tekstem
	
	
End Sub

Public Sub Initialize (Callback As Object, EventName As String)
	
	mEventName = EventName
	mCallBack = Callback
	
	ButtonPanel.Initialize("")													'inicjalizacja panelu ramki
	Image.Initialize("ButtonImageEvent")										'inicjalizacja obrazka przycisku
	Image.Bitmap = LoadBitmap(File.DirAssets, "DefaultButtonImage.png")			'załadowanie domyślnego obrazka
	Image.Gravity = Gravity.FILL												'ustawienie trybu wyświetlania obrazka
	ButtonLabel.Initialize("ButtonImageEvent")									'inicjalizacja labelki tekstu przycisku
	
End Sub

Public Sub DesignerCreateView (Base As Panel, Lbl As Label, Props As Map)
	
	mBase = Base
	mBase.Color = Colors.Black
	
	FrameColor = Props.Get("FrameColor")										'odczyt właściwości koloru ramki z designera
	BackgroundColor = Props.Get("BackgroundColor")								'odczyt właściwości koloru tła z designera
	ButtonTextPosY = Props.Get("TextPosY")										'odczyt pozycji Y tekstu z designera
	ButtonTextPosX = Props.Get("TextPosX")										'odczyt pozycji X tekstu z designera
	ButtonText = Props.Get("ButtonText")										'odczyt tekstu dla przycisku z designera
	ImageWidth = Props.Get("ImageWidth")										'odczyt szerokości obrazka z designera
	ImageHeight = Props.Get("ImageHeight")										'odczyt wysokości obrazka z designera
	
	Dim imageX = Base.Width / 100 * 2 As Int									'pozycja obrazka w osi X
	Dim imageY = Base.Height / 100 As Int										'pozycja obrazka w osi Y
	Dim ImageW = Base.Width / 100 * ImageWidth As Int							'szerokość obrazka
	Dim ImageH = Base.Height / 100 * ImageHeight As Int							'wysokość obrazka
	
	Dim textX = Base.Width / 100 * ButtonTextPosX As Int						'pozycja tekstu w osi X
	Dim textY = Base.Height / 100 * ButtonTextPosY As Int						'pozycja tekstu w osi Y
	Dim textWidth = Base.Width / 100 * 71 As Int								'szerokość tekstu
	Dim textHeight = Base.Height / 100 * 96 As Int								'wysokość tekstu
	
	Base.Color = FrameColor														'ustawienie koloru ramki
	ButtonPanel.Color = BackgroundColor											'ustawienie koloru tła
	ButtonLabel.Text = ButtonText												'wstawienie tekstu do przycisku
	ButtonPanel.AddView(Image, imageX, imageY, ImageW, ImageH)					'dodanie obrazka
	ButtonPanel.AddView(ButtonLabel, textX, textY, textWidth, textHeight)		'dodanie napisu
	Base.AddView(ButtonPanel, 2, 2, Base.Width - 4, Base.Height - 4)			'wyświetlenie przycisku
	
    
End Sub

Public Sub SetImage(BtImage As Bitmap)
	
	Image.Bitmap = BtImage														'ustawienie nowego obrazka w przyciski
	
End Sub

Public Sub SetText(BtText As String)
	
	ButtonLabel.Text = BtText													'wstawienie tekstu do przycisku
	
End Sub

Public Sub SetFrameColor(BtFrameColor As Int)
	
	mBase.Color = BtFrameColor													'ustawienie nowego koloru ramki
	
End Sub

Public Sub SetBackgraund(BtBackgrounColor As Int)
	
	ButtonPanel.Color = BtBackgrounColor										'ustawienie nowego koloru tła
	
End Sub

Public Sub Disable
	
	mBase.Enabled = False														'dezaktywacja przycisku
	ButtonPanel.Enabled = False
	ButtonLabel.Enabled = False
	Image.Enabled = False
	
End Sub

Public Sub Enable
	
	mBase.Enabled = True														'aktywacja przycisku
	ButtonPanel.Enabled = True
	ButtonLabel.Enabled = True
	Image.Enabled = True
	
End Sub

Private Sub ButtonImageEvent_Click
	
	ButtonPanel.SetColorAnimated(1, Colors.Blue, BackgroundColor)
	CallSub(mCallBack, mEventName & "_Click")
	
End Sub

Public Sub GetBase As Panel
	Return mBase
End Sub