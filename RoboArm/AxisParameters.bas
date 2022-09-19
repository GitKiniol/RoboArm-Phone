B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=11.2
@EndOfDesignText@
Sub Class_Globals
	
	Public CW_Travel As Int						'maksymalny obrót w prawo jaki może wykonać oś [stopnie]
	Public CCW_Travel As Int					'maksymalny obrót w lewo jaki może wykonać oś [stopnie]
	Public ActualPosition As Int				'aktualna pozycja osi
	Public TravelToGo As Int					'kąt obrotu do wykonania
	Public MaxTravel As Int						'maksymalny możliwy obrót (zasięg całkowity)
	Public Direction As Int						'kierunek obrotu -1 lewo, 1 prawo
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(cwt As Int, ccwt As Int, actp As Int, ttg As Int, mt As Int, dir As Int)
	
	SetParameters(cwt, ccwt, actp, ttg, mt, dir)
	
End Sub

Public Sub SetParameters(cwt As Int, ccwt As Int, actp As Int, ttg As Int, mt As Int, dir As Int)
	
	CW_Travel = cwt
	CCW_Travel = ccwt
	ActualPosition = actp
	TravelToGo = ttg
	Direction = dir
	MaxTravel = mt
	
End Sub

Public Sub RangeCalculate(Value As Int)
	
	CW_Travel = MaxTravel - Value
	CCW_Travel = Value
	
End Sub

Public Sub TravelToGoCalculate(Value As Int, RotaryAxis As Boolean) As Int
	
	If RotaryAxis == True Then
		TravelToGo = Value															'obliczanie kąta dla osi servo
	Else
		TravelToGo = (Value - (MaxTravel / 2)) - ActualPosition						'obliczanie konta obrotu dla osi rotacyjnej
	End If
	Return TravelToGo
	
End Sub