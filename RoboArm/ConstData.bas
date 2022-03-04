B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=11.2
@EndOfDesignText@
'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	
	Type RowKeys_t (Name As String, Angle As String, Speed As String, Dir As String, Blend As String)
	Dim const RowKeys As RowKeys_t
	RowKeys.Name = "Name"
	RowKeys.Angle = "Angle"
	RowKeys.Speed = "Speed"
	RowKeys.Dir = "Dir"
	RowKeys.Blend = "Blend"
	
	Type FrameKeys_t (StartCode As String, Data1 As String, Data2 As String, Data3 As String, Data4 As String, EndCode As String, Complete As Boolean)
	Dim const FrameKeys As FrameKeys_t
	FrameKeys.StartCode = "StartCode"
	FrameKeys.Data1 = "Data1"
	FrameKeys.Data2 = "Data2"
	FrameKeys.Data3 = "Data3"
	FrameKeys.Data4 = "Data4"
	FrameKeys.EndCode = "EndCode"
	FrameKeys.Complete = "Complete"
	
End Sub