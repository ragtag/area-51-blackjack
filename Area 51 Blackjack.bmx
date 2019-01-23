'=========================='
' BLACKJACK                '
'  by Ragnar Brynjulfsson  '
'=========================='

Rem
	A basic Blackjack game written to teach myself object oriented coding in BlitMax. The code and
	the game are both free.
	
	Compile it like it is if using osx.
	If on windows set the os Constant to win, and comment out the If os = "osx" bit.
	I haven't tried compling this for linux, but I guess it should work the same way it does for windows.
End Rem


Strict

Const os:String = "win"	' osx, win or linux. Change before compiling. Used to decide where to 
						' save your status in the game. (linux not implememnted)
Const w:Int = 1024
Const h:Int = 768
Const wh :Int= w/2
Const hh:Int = h/2
						

' -------------------------------------------------------------------------------------------------

'  SET GRAPHICS MODE

If GraphicsModeExists(w,h,32) Then
	Graphics w, h, 32
Else
	Graphics w, h, 0
End If

AutoMidHandle( True )
SetBlend ALPHABLEND		


Global SaveFile:String
' MAC OS X specific code.
Rem
If os = "osx" Then
	' Code posted on forum by Mark Sibly. Finds the current home directory.
	Const kUserDomain=-32763
	Const kVolumeRootFolderType=Asc("r") Shl 24 | Asc("o") Shl 16 | Asc( "o") Shl 8 | Asc("t")
	
	Extern
		Function FSFindFolder( vRefNum,folderType,createFolder,foundRef:Byte Ptr )
		Function FSRefMakePath( ref:Byte Ptr,path:Byte Ptr,maxPathsize )
	End Extern
	
	Function HomeDir$()
	
		Local buf:Byte[1024],ref:Byte[80]
		
		If FSFindFolder( kUserDomain,kVolumeRootFolderType,False,ref ) Return
		If FSRefMakePath( ref,buf,1024 ) Return
		
		Return String.FromCString( buf )
	
	End Function
	
	SaveFile = HomeDir() +"/Library/Preferences/BlackjackPrefs.txt"
End If
End Rem

' Windows specific code.
If os = "win" Then
	SaveFile = "BlackjackPrefs.txt"
End If 

' Linux specifc code.
If os = "linux" Then
	Print "Linux specific code not implemented yet. I'll get around to it some day."
	DebugStop
End If



' ----------------------------------------------------------------------------------------------

' LOAD MEDIA

Incbin "images/n1.png"
Incbin "images/n2.png"
Incbin "images/n3.png"
Incbin "images/n4.png"
Incbin "images/n5.png"
Incbin "images/n6.png"
Incbin "images/n7.png"
Incbin "images/n8.png"
Incbin "images/n9.png"
Incbin "images/n0.png"
Incbin "images/arrow.png"
Incbin "images/arrow_glow.png"
Incbin "images/hitme.png"
Incbin "images/hitme_glow.png"
Incbin "images/hold.png"
Incbin "images/hold_glow.png"
Incbin "images/deal.png"
Incbin "images/deal_glow.png"
Incbin "images/bust.png"
Incbin "images/blackjack.png"
Incbin "images/win.png"
Incbin "images/loose.png"
Incbin "images/tie.png"
Incbin "images/title.png"
Incbin "images/area51.png"
Incbin "images/ufo.png"
Incbin "images/broke.png"
' The card images
Incbin "images/back.png"
Incbin "images/2_club.png"
Incbin "images/3_club.png"
Incbin "images/4_club.png"
Incbin "images/5_club.png"
Incbin "images/6_club.png"
Incbin "images/7_club.png"
Incbin "images/8_club.png"
Incbin "images/9_club.png"
Incbin "images/10_club.png"
Incbin "images/11_club.png"
Incbin "images/12_club.png"
Incbin "images/13_club.png"
Incbin "images/14_club.png"
Incbin "images/2_diamond.png"
Incbin "images/3_diamond.png"
Incbin "images/4_diamond.png"
Incbin "images/5_diamond.png"
Incbin "images/6_diamond.png"
Incbin "images/7_diamond.png"
Incbin "images/8_diamond.png"
Incbin "images/9_diamond.png"
Incbin "images/10_diamond.png"
Incbin "images/11_diamond.png"
Incbin "images/12_diamond.png"
Incbin "images/13_diamond.png"
Incbin "images/14_diamond.png"
Incbin "images/2_heart.png"
Incbin "images/3_heart.png"
Incbin "images/4_heart.png"
Incbin "images/5_heart.png"
Incbin "images/6_heart.png"
Incbin "images/7_heart.png"
Incbin "images/8_heart.png"
Incbin "images/9_heart.png"
Incbin "images/10_heart.png"
Incbin "images/11_heart.png"
Incbin "images/12_heart.png"
Incbin "images/13_heart.png"
Incbin "images/14_heart.png"
Incbin "images/2_spade.png"
Incbin "images/3_spade.png"
Incbin "images/4_spade.png"
Incbin "images/5_spade.png"
Incbin "images/6_spade.png"
Incbin "images/7_spade.png"
Incbin "images/8_spade.png"
Incbin "images/9_spade.png"
Incbin "images/10_spade.png"
Incbin "images/11_spade.png"
Incbin "images/12_spade.png"
Incbin "images/13_spade.png"
Incbin "images/14_spade.png"
' Load card graphics
Global Back:TImage	= LoadImage( "incbin::images/back.png", FILTEREDIMAGE|MIPMAPPEDIMAGE )	' Backside of cards.	
Global CardImg:TImage[52]
Global AllSuit:String[52]
Global AllValue:Int[52]
Local Count:Int = 0
Global Suits:String[] = [ "club","diamond","heart","spade" ]
For Local Suit:String = EachIn Suits
	For Local n:Int=2 To 14
		CardImg[Count] = LoadImage( "incbin::images/"+n+"_"+Suit+".png", FILTEREDIMAGE|MIPMAPPEDIMAGE )
		AllSuit[Count] = Suit
		AllValue[Count] = n
		Count:+1
	Next
Next
' Load the rest of the graphics
Global NumberImg:TImage[10]
For Local i:Int=0 To 9
	NumberImg[i] = LoadImage( "incbin::images/n"+i+".png" )
Next
Global BetNumber:TNumber = TNumber.Create()
BetNumber.x = 56
BetNumber.Kind = 0
Global CashNumber:TNumber = TNumber.Create()
CashNumber.x = 910
CashNumber.Kind = 1
Global ArrowImg:TImage = LoadImage( "incbin::images/arrow.png" )
Global ArrowGlowImg:TImage = LoadImage( "incbin::images/arrow_glow.png"  )
Global HitMeImg:TImage = LoadImage( "incbin::images/hitme.png" )
Global HitMeGlowImg:TImage = LoadImage( "incbin::images/hitme_glow.png" )
Global HoldMeImg:TImage = LoadImage( "incbin::images/hold.png" )
Global HoldMeGlowImg:TImage = LoadImage( "incbin::images/hold_glow.png" )
Global DealMeImg:TImage = LoadImage( "incbin::images/deal.png" )
Global DealMeGlowImg:TImage = LoadImage( "incbin::images/deal_glow.png" )
' Make the main buttons.
Global ArrowUp:TButton = TButton.Create( "Arrow", ArrowImg, ArrowGlowImg )
ArrowUp.Pos = [ 70.0, 340.0, 0.0, 1.0, 1.0, 0.0 ]
ArrowUp.Goal = [ 70.0, 340.0, 0.0, 1.0, 1.0, 0.0 ]
ArrowUp.GlowPos = [ 70.0, 340.0, 0.0, 1.0, 1.0, 0.0 ]
ArrowUp.GlowGoal = [ 70.0, 340.0, 0.0, 1.0, 1.0, 0.0 ]
Global ArrowDown:TButton = TButton.Create( "Arrow", ArrowImg, ArrowGlowImg )
ArrowDown.Pos = [ 70.0, 428.0, 180.0, 1.0, 1.0, 0.0 ]
ArrowDown.Goal = [ 70.0, 428.0, 180.0, 1.0, 1.0, 0.0 ]
ArrowDown.GlowPos = [ 70.0, 428.0, 180.0, 1.0, 1.0, 0.0 ]
ArrowDown.GlowGoal = [ 70.0, 428.0, 180.0, 1.0, 1.0, 0.0 ]
Global HitMe:TButton = TButton.Create( "HitMe", HitMeImg, HitMeGlowImg )
HitMe.Pos = [ 512.0, 148.0, 0.0, 1.0, 1.0, 0.0 ]
HitMe.Goal = [ 512.0, 148.0, 0.0, 1.0, 1.0, 0.0 ]
HitMe.GlowPos = [ 512.0, 148.0, 0.0, 1.0, 1.0, 0.0 ]
HitMe.GlowGoal = [ 512.0, 148.0, 0.0, 1.0, 1.0, 0.0 ]
Global HoldMe:TButton = TButton.Create( "HoldMe", HoldMeImg, HoldMeGlowImg )
HoldMe.Pos = [ 512.0, 620.0, 0.0, 1.0, 1.0, 0.0 ]
HoldMe.Goal = [ 512.0, 620.0, 0.0, 1.0, 1.0, 0.0 ]
HoldMe.GlowPos = [ 512.0, 620.0, 0.0, 1.0, 1.0, 0.0 ]
HoldMe.GlowGoal = [ 512.0, 620.0, 0.0, 1.0, 1.0, 0.0 ]
Global DealMe:TButton = TButton.Create( "DealMe", DealMeImg, DealMeGlowImg )
DealMe.Pos = [ 512.0, 384.0, 0.0, 1.0, 1.0, 0.0 ]
DealMe.Goal = [ 512.0, 384.0, 0.0, 1.0, 1.0, 0.0 ]
DealMe.GlowPos = [ 512.0, 384.0, 0.0, 1.0, 1.0, 0.0 ]
DealMe.GlowGoal = [ 512.0, 384.0, 0.0, 1.0, 1.0, 0.0 ]
Global BustImg:TImage = LoadImage( "incbin::images/bust.png" )
Global Bust:TButton = TButton.Create( "Bust", BustImg, BustImg )
Bust.Pos = [ 512.0, 148.0, 0.0, 1.0, 1.0, 0.0 ]
Bust.Goal = [ 512.0, 148.0, 0.0, 1.0, 1.0, 0.0 ]
Global BlackjackImg:TImage = LoadImage( "incbin::images/blackjack.png" )
Global Blackjack:TButton = TButton.Create( "Blackjack", BlackjackImg, BlackjackImg )
Blackjack.Pos = [ 512.0, 148.0, 0.0, 1.0, 1.0, 0.0 ]
Blackjack.Goal = [ 512.0, 148.0, 0.0, 1.0, 1.0, 0.0 ]
Global WinImg:TImage = LoadImage( "incbin::images/win.png" )
Global Win:TButton = TButton.Create( "Win", WinImg, WinImg )
Win.Pos = [ 512.0, 384.0, 0.0, 1.0, 1.0, 0.0 ]
Win.Goal = [ 512.0, 384.0, 0.0, 1.0, 1.0, 0.0 ]
Global LooseImg:TImage = LoadImage( "incbin::images/loose.png" )
Global Loose:TButton = TButton.Create( "Loose", LooseImg, LooseImg )
Loose.Pos = [ 512.0, 384.0, 0.0, 1.0, 1.0, 0.0 ]
Loose.Goal = [ 512.0, 384.0, 0.0, 1.0, 1.0, 0.0 ]
Global TieImg:TImage = LoadImage( "incbin::images/tie.png" )
Global Tie:TButton = TButton.Create( "Tie", TieImg, TieImg )
Tie.Pos = [ 512.0, 384.0, 0.0, 1.0, 1.0, 0.0 ]
Tie.Goal = [ 512.0, 384.0, 0.0, 1.0, 1.0, 0.0 ]
Global BackgroundImg:TImage = LoadImage( "incbin::images/title.png" )
Global MeBrokeImg:TImage = LoadImage( "incbin::images/broke.png" )
Global Background:TButton = TButton.Create( "Background", BackgroundImg, MeBrokeImg )
Background.Pos = [ 512.0, 384.0, 0.0, 1.0, 1.0, 0.0 ]
Background.Goal = [ 512.0, 384.0, 0.0, 1.0, 1.0, 0.0 ]
Background.GlowPos = [ 512.0, 384.0, 0.0, 1.0, 1.0, 0.0 ]
Background.GlowGoal = [ 512.0, 384.0, 0.0, 1.0, 1.0, 0.0 ]
Global UfoImg:TImage = LoadImage( "incbin::images/ufo.png" )
Global Area51Img:TImage = LoadImage( "incbin::images/area51.png" )
Global Ufo:TButton = TButton.Create( "Ufo", UfoImg, Area51Img )
Ufo.Pos = [ 1000.0, -400.0, -30.0, 1.0, 1.0, 1.0 ]
Ufo.Goal = [ 1000.0, -400.0, -30.0, 1.0, 1.0, 1.0 ]
Ufo.GlowPos = [ -600.0, 650.0, 0.0, 1.0, 1.0, 0.5 ]
Ufo.GlowGoal = [ 600.0, 650.0, 0.0, 1.0, 1.0, 0.5 ]

' -------------------------------------------------------------------------------------------------


Global mpf:Int = 1000/60
Global Timer:TTimer = TTimer.Create( 300 )	' Interval between dealing cards.

' Initialize the game.
Global Game:TGame = New TGame		' Main object for the game itself. 
Global QuitGame:Int = 0			' Flag when sets to 1 that quits the game.
SeedRnd MilliSecs()

Global Deck:TDeck = TDeck.Create() 	' Build a deck of 52 cards.
Deck.Shuffle()
Global Human:THand = New THand		' Create a default object for the player.
Human.CPU = 0
Global Computer:THand = New THand	' Create an object for the CPU player.
Computer.CPU = 1

' ----------------------------------------------------------------------------------------------

' MAIN GAME LOOP

Repeat
	Cls
	Local now:Int = MilliSecs()
	Game.Main()
	While MilliSecs() < mpf + now
	Wend

	' Toggle between windowed mode and full screen.	
	If KeyHit( KEY_W ) Then
		Local Depth:Int = GraphicsDepth()
		If GraphicsDepth() = 32 Then
			EndGraphics
			Graphics w, h, 0						
			AutoMidHandle( True )
			SetBlend ALPHABLEND
		Else If GraphicsModeExists(w,h,32) Then
			EndGraphics
			Graphics w, h, 32
			AutoMidHandle( True )
			SetBlend ALPHABLEND
		End If
	End If
	Flip
Until QuitGame


' ----------------------------------------------------------------------------------------------

' TYPE DEFINITIONS

' Class for the main game screen.
Type TGame
	Field ScreenButtons:TList = CreateList()

	Field Stage:String = "title"
	
	Field WinLoose:Int = 10
	Field TickCount:Int = 0
	
	Field ButtonTimer:Int = MilliSecs()
	Field BetTimer:Int = MilliSecs()
	Field Flush:Int = 1
	
	Method Main()
		Select Stage
		Case "title"
			Title()
		Case "help"
			Help()
		Case "init"
			Initialize()
		Case "deal"
			Deal()
		Case "reset"
			Reset()
		Case "hit"
			Hit()
		Case "hold"
			Hold()
		Case "result"
			Result()
		Case "ready"
			Ready()
		Case "broke"
			Broke()
		End Select
		Update()
		
		If KeyDown( KEY_ESCAPE ) Then QuitGame = 1
		If Flush
			FlushMouse()
		End If
		FlushKeys()
	End Method
	
	Method MouseWithin:Int(x,y,w,h)
		If MouseX() > x And MouseX() < x+w And MouseY() > y And MouseY() < y+h Then Return 1
	End Method
	
	' Updates everything on the game screen.
	Method Update()
		Background.Update()
		Background.Draw()
		Ufo.Update()
		Ufo.Draw()
		Computer.Update()
		Computer.Draw()
		Human.Update()
		Human.Draw()
		BetNumber.Draw()
		CashNumber.Draw()
		For Local Butt:TButton = EachIn ScreenButtons
			Butt.Update()
			Butt.Draw()
		Next
		
		ArrowUp.Goal[5] = 0.0
		ArrowDown.Goal[5] = 0.0		
		ArrowUp.GlowGoal[5] = 0.0
		ArrowDown.GlowGoal[5] = 0.0
		If MilliSecs() > ButtonTimer + 300
			HitMe.Goal[5] = 0.0
			HitMe.GlowGoal[5] = 0.0
			HoldMe.Goal[5] = 0.0
			HoldMe.GlowGoal[5] = 0.0
			DealMe.Goal[5] = 0.0
			DealMe.GlowGoal[5] = 0.0
			ButtonTimer = MilliSecs()
		End If		
		For Local Card:TCard = EachIn Human.Cards
			Card.Goal[5] = 1.0
		Next
		For Local Card:TCard = EachIn Computer.Cards
			Card.Goal[5] = 1.0
		Next
	End Method
	
	' --- Title Screen Methods ---
	
	Method Title()
		TButton.Lag = 20.0
		Background.Goal[5] = 1.0
		If KeyHit( Key_Space ) Or MouseHit(1) Then 
			TButton.Lag = 8.0 
			Background.Goal[0] = 850.0
			Stage = "help"
		End If
	End Method
	
	Method Broke()
		BetNumber.Visible = 0
		CashNumber.Visible = 0
		TCard.Lag = 50.0
		TButton.Lag = 50.0
		' Clear the screen of cards.
		For Local Card:TCard = EachIn Human.Cards
			Card.Goal = [ 512.0, 850.0, 9.0, 0.0, 0.0, 0.0 ]
		Next
		For Local Card:TCard = EachIn Computer.Cards
			Card.Goal = [ 512.0, -100.0, -90.0, 0.0, 0.0, 0.0 ] 
		Next
		Background.Goal[5] = 0.0
		Background.GlowGoal[5] = 1.0
		If KeyHit( Key_Escape ) Then QuitGame = 1
	End Method
	
	' --- Game Screen Methods ---
	
	Method Help()
		Ufo.Goal = [ 200.0, 160.0, 0.0, 1.0, 1.0, 1.0 ]
		Ufo.GlowGoal[0] = 2000.0
		Ufo.GlowGoal[5] = 0.0 
		SetAlpha 0.5
		DrawText( "Welcome to Area 51 Blackjack by Ragnar B.", 60, 60 )
		DrawText( "How to play!", 160, 260 )
		DrawText( "Raise and lower your bet with the arrows on", 50, 300 )
		DrawText( "the left side of the screen between hands.", 50, 320 )
		DrawText( "Click on DEAL or hit space to deal the cards.", 50, 360 )
		DrawText( "Click on the dealers hand or hit space to get", 50, 400 )
		DrawText( "an extra card.", 50, 420 )
		DrawText( "Click on your hand or hit H to hold.", 50, 460 )
		DrawText( "The winner is the one with the highest hand", 50, 500 )
		DrawText( "that is not above 21.", 50 , 520 )
		DrawText( "Aces count as either 11 or 1 and jacks, kings", 50, 540 )
		DrawText( "and queens count as 10.", 50, 560 )
		DrawText( "If you get five cards without going bust you", 50, 620 )
		DrawText( "win.", 50, 640 )
		DrawText( "Hit Escape to Quit at any time.", 100, 680 )
		DrawText( "Hit SPACE to continue.", 130, 700 )
		
		SetAlpha 1.0
		If KeyHit( KEY_SPACE ) Or MouseHit(1) Then Stage = "init"
	End Method
	
	Method Initialize()
		' Load in the last saved cash status.
		Local File:TStream = OpenFile( SaveFile )
		If File Then 
			Local TempStr:String = ReadLine( File )
			Human.Cash = Int(TempStr)
			CloseStream File
			If Human.Cash < 1 Then Human.Cash = 1000
		End If
		ScreenButtons.AddLast( ArrowUp )
		ScreenButtons.AddLast( ArrowDown )
		ScreenButtons.AddLast( HitMe )
		ScreenButtons.AddLast( HoldMe )
		ScreenButtons.AddLast( DealMe )
		ScreenButtons.AddLast( Win )
		ScreenButtons.AddLast( Loose )
		ScreenButtons.AddLast( Tie )
		ScreenButtons.AddLast( Blackjack )
		ScreenButtons.AddLast( Bust )
		BetNumber.Visible = 1
		CashNumber.Visible = 1
		Background.Goal[5] = 0.5
		Ufo.Goal[5] = 0.5
		Ufo.Goal[0] = -300.0
		Ufo.Goal[1] = 600.0
		Stage = "ready"
	End Method
	
	Method Deal()
		Timer.Wait = 300
		Select TickCount
		Case 1
			Computer.PutCard( Deck.PullCard() )
			Computer.GetCard().Face = 0
			TickCount:+1
		Case 3
			Human.PutCard( Deck.PullCard() )
			TickCount:+1
		Case 5
			Computer.PutCard( Deck.PullCard() )
			TickCount:+1
		Case 7
			Human.PutCard( Deck.PullCard() )
			TickCount = 0
			WinLoose = Human.CompareHands( Computer, 1 )
			If WinLoose = 2 Or WinLoose = -2
				stage = "result"
			Else
				stage = "hit"
			End If
		End Select
		If Timer.Tick() Then TickCount:+1
	End Method
	
	' Resets the game and shuffles the deck.
	Method Reset()
		' Clear the table.
		Win.Goal[5] = 0.0
		Tie.Goal[5] = 0.0
		Loose.Goal[5] = 0.0
		Blackjack.Goal[5] = 0.0
		Bust.Goal[5] = 0.0
		Timer.Wait = 300
		If TickCount = 1
			For Local Card:TCard = EachIn Human.Cards
				Card.Goal =  [ 0.0, 896.0, 0.0, 1.0, 1.0, 0.0 ]
			Next
			For Local Card:TCard = EachIn Computer.Cards
				Card.Goal =  [ 0.0, -128.0, 0.0, 1.0, 1.0, 0.0 ]
			Next
		End If
		If TickCount = 3		
			For Local Card:TCard = EachIn Human.Cards
				Deck.PutCard( Human.PullCard() )
			Next
			For Local Card:TCard = EachIn Computer.Cards
				Deck.PutCard( Computer.PullCard() )
			Next			
			Deck.Shuffle()
			TickCount = 0
			stage = "deal"
		End If
		If Timer.Tick() Then TickCount:+1
	End Method
			
	Method Hit()
		DealMe.Goal[5] = 0.0
		Local Hit:Int = 0
		Local Hold:Int = 0
		
		' Hit me button.
		If KeyDown( KEY_SPACE ) Then Hit = 1
		If MouseWithin(200,-1,624,300) Then
			HitMe.Goal[5] = 0.6
			For Local Card:TCard = EachIn Computer.Cards
				Card.Goal[5] = 0.4
			Next
			If MouseHit(1) Then Hit = 1
		Else
			'HitMe.Goal[5] = 0.0
			For Local Card:TCard = EachIn Human.Cards
				Card.Goal[5] = 1.0
			Next
		End If
		
		' Hold button.
		If KeyDown( KEY_H ) Then Hold = 1
		If MouseWithin(200,476,624,300) Then
			HoldMe.Goal[5] = 0.6
			For Local Card:TCard = EachIn Human.Cards
				Card.Goal[5] = 0.4
			Next
			If MouseHit(1) Then Hold = 1
		Else
			'HoldMe.Goal[5] = 0.0
			For Local Card:TCard = EachIn Human.Cards
				Card.Goal[5] = 1.0
			Next
		End If
		
		If Hit Then
			HitMe.Goal[5] = 0.9
			HitMe.GlowGoal[5] = 1.0
			ButtonTimer = MilliSecs()
			Human.PutCard( Deck.PullCard() )
			WinLoose = Human.CompareHands( Computer )
			If WinLoose = -3 Or Human.GetSize() = 5 Then stage = "result"
		Else If Hold Then 
			HoldMe.Goal[5] = 0.9
			HoldMe.GlowGoal[5] = 1.0
			ButtonTimer = MilliSecs()
			TickCount = 0
			stage = "hold"
		End If
	End Method

	Method Hold()
		Timer.Wait = 600
		Computer.GetCard().Face = 1
		Local hisHand:Int = Computer.Evaluate()
		Local myHand:Int = Human.Evaluate()
		If TickCount Then
			TickCount = 0
			If myHand > hisHand And Computer.GetSize() < 5 Then
				Computer.PutCard( Deck.PullCard() )
			Else
				WinLoose = Human.CompareHands( Computer )
				Stage = "result"
			End If
		End If
		If Timer.Tick() Then TickCount = 1
	End Method 
	
	' Move cash around.
	Method Result()
		If WinLoose > 0 Then Human.Cash:+ Human.Bet
		If WinLoose < 0 Then Human.Cash:- Human.Bet
		If Human.Bet > Human.Cash Then Human.Bet = Human.Cash
		' Save cash to file.
		Local File:TStream = WriteFile( SaveFile )
		If File Then
			WriteLine File,Human.Cash
			CloseStream File
		Else
			Print "Failed to open file "+SaveFile
		End If
		' Check if you're broke.
		If Human.Cash = 0 Then Stage = "broke" Else Stage = "ready"
	End Method
	
	' Displays the result of one round.
	Method Ready()
		Select WinLoose
			Case 3
				For Local Card:TCard = EachIn Computer.Cards
					Card.Goal[5] = 0.4
				Next
				Bust.Pos[1] = 148.0
				Bust.Goal[1] = 148.0
				Bust.Goal[5] = 0.8
				Win.Goal[5] = 1.0			
			Case 2
				For Local Card:TCard = EachIn Human.Cards
					Card.Goal[5] = 0.4
				Next
				Blackjack.Pos[1] = 620.0
				Blackjack.Goal[1] = 620.0
				Blackjack.Goal[5] = 0.8
				Win.Goal[5] = 1.0
			Case 1
				Win.Goal[5] = 1.0
			Case 0
				Tie.Goal[5] = 1.0
			Case -1
				Loose.Goal[5] = 1.0
			Case -2
				Computer.GetCard().Face = 1	
				For Local Card:TCard = EachIn Computer.Cards
					Card.Goal[5] = 0.4
				Next
				Blackjack.Pos[1] = 148.0
				Blackjack.Goal[1] = 148.0
				Blackjack.Goal[5] = 0.8
				Loose.Goal[5] = 1.0
			Case -3
				For Local Card:TCard = EachIn Human.Cards
					Card.Goal[5] = 0.4
				Next
				Bust.Pos[1] = 620.0
				Bust.Goal[1] = 620.0
				Bust.Goal[5] = 0.8
				Loose.Goal[5] = 1.0
		End Select

		' Raise bet.
		If MouseWithin(20,290,100,90)  Then
			ArrowUp.Goal[5] = 0.9
			If MouseDown(1) Then
				If Human.Bet < 100 And Human.Bet < Human.Cash And MilliSecs() > BetTimer + 75
					Human.Bet:+1
					BetTimer = MilliSecs()
				End If
				ArrowUp.GlowGoal[5] = 1.0
				Flush = 0
			End If 
		Else
			ArrowUp.Goal[5] = 0.6
		End If
		
		' Decrease bet.
		If MouseWithin(20,388,100,90)  Then
			ArrowDown.Goal[5] = 0.9
			If MouseDown(1) Then
				If Human.Bet > 1 And MilliSecs() > BetTimer + 75
					Human.Bet:-1
					BetTimer = MilliSecs()
				End If
				ArrowDown.GlowGoal[5] = 1.0
				Flush = 0
			End If
		Else
			ArrowDown.Goal[5] = 0.6
		End If
		
		If Not MouseWithin(50,280,100,70) And Not MouseWithin(50,410,100,70) Then Flush=1
		
		DealMe.Goal[5] = 0.1
		
		Local DealNow:Int = 0
		If KeyDown( Key_Space ) Then DealNow = 1
		If MouseWithin(250,270,500,230) Then
			DealMe.Goal[5] = 0.2
			If MouseHit(1) Then DealNow = 1
		End If
		If DealNow Then
			DealMe.GlowGoal[5] = 1.0
			DealMe.Goal[5] = 1.0
			ButtonTimer = MilliSecs()
			TickCount = 0
			Stage = "reset"
		End If
	End Method
	
	Function Create:TGame()
		Return New TGame
	End Function
End Type

' Base class for anything that can hold cards (i.e. the deck, players hands etc.)
Type TDeck
	Field Cards:TList = CreateList()

	
	' Returns one card from the TDeck.
	Method GetCard:TCard( Number:Int = 0 )
		Local n=0
		For Local c:TCard = EachIn Cards
			If n = Number Then Return c
			n:+1
		Next
	End Method
	
	' Returns the number of cards in a deck.
	Method GetSize:Int()
		Return CountList( Cards )
	End Method
	
	' Pulls (draws) the top card from the TDeck.
	Method PullCard:TCard()
		Local TempCard:TCard = GetCard()
		If TempCard Then Self.Cards.RemoveFirst()
		Return TempCard
	End Method
	
	
	' Puts a card last in the deck.
	Method PutCard:TCard( inCard:TCard )
		Self.Cards.AddLast( inCard )
	End Method
	
	' Shuffles the cards in the TDeck. Shuffling is done by setting the order
	' field to a random value and then sorting the TDeck by that.
	Method Shuffle()
		For Local c:TCard = EachIn Cards
			c.Order = Rnd(0,65000)
		Next
		Cards.Sort(True)
	End Method
	
	' Creates a deck of cards. By default it contains 52 cards, but you can decide
	' to start it from a higher number, such as seven and up. Useless for this game,
	' but handy if I decide to create a different game later. :)
	Function Create:TDeck() Final
		Local TempDeck:TDeck = New TDeck
		For Local i:Int=0 To 51
			TempDeck.Cards.AddLast( TCard.Create( i ) )
		Next
		Return TempDeck
	End Function	
End Type


' Base class for a hand of cards and the player holding that hand. Used for human and CPU players.
Type THand Extends TDeck
	Field CPU:Int					' Human = 0 or CPU = 1
	Field Cash:Int = 1000
	Field Bet:Int =1
	
	' Adds a card To the bottom of the TDeck.
	Method PutCard:TCard( inCard:TCard )
		Self.Cards.AddLast( inCard )
		Local CardCount = Cards.Count()
		Local FirstCardPosition:Float = (CardCount*(-100))+100+wh
		FirstCardPosition:+ 200*(CardCount-1)
		inCard.Pos[0] = FirstCardPosition

		If CPU Then 
			inCard.Pos =   [ FirstCardPosition, 0.0, -90.0, 0.0, 0.0, 0.0 ]
			inCard.Goal =  [ FirstCardPosition, 148.0, 0.0, 1.0, 1.0, 1.0 ]
			inCard.Face = 1
		Else
			inCard.Pos =   [ FirstCardPosition, 768.0, 90.0, 0.0, 0.0, 0.0 ]
			inCard.Goal =  [ FirstCardPosition, 620.0, 0.0, 1.0, 1.0, 1.0 ]
			inCard.Face = 1
		End If 
	End Method
	
	' Updates the positions of the cards on the screen.
	Method Update()
		Local CardCount = Cards.Count()
		Local FirstCardPosition:Int = (CardCount*(-100))+100+wh
		Local i:Int = 0
		For Local Card:TCard = EachIn Cards
			Card.Goal[0] = FirstCardPosition
			FirstCardPosition:+ 200
			Card.Update()
		Next
	End Method
	
	' Draws the hand on the screen.
	Method Draw()
		For Local Card:TCard = EachIn Cards
			Card.Draw()
		Next
	End Method
	
	' Figures out the value of a hand. Returns two values in case you havea an ace.
	' Returns -1 if you're bust.
	Method Evaluate:Int()
		Local TotalValue:Int[2]
		Local Ace:Int = 0	' Has an ace on hand.
		For Local myCard:TCard = EachIn Cards
			Local Value:Int = myCard.Value
			If Value > 10 And Value < 14 Then Value = 10
			If Value = 14 Then
				Value = 1
				Ace = 1
			End If
			TotalValue[0] = TotalValue[0] + Value
			If Ace Then
				TotalValue[1] = TotalValue[0] + 10
			End If
		Next
		If TotalValue[1] < 22 And TotalValue[1] > TotalValue[0] Then 
			Return TotalValue[1]
		Else 
			Return TotalValue[0]
		End If
	End Method
	
	' Compares two hands, returns 1 if the owner wins.
	Rem
	 3 - Computer is bust.
	 2 - You got a Blackjack with two cards.
	 1 - You win.
	 0 - It's a tie.
	-1 - Computer wins.
	-2 - Comptur got a Blackjack with two cards.
	-3 - You are bust.
	End Rem
	Method CompareHands:Int( inHand:THand, Initial:Int=0 )
		Local winner:Int
		Local myHand:Int = Evaluate()
		Local hisHand:Int = inHand.Evaluate()
		If Initial Then
			If myHand = 21
				Return 2
			Else If hisHand = 21
				Return -2
			End If
		End If
		If myHand > 21 Then Return -3
		If hisHand > 21 Then Return 3
		If Self.GetSize() = 5 And myHand < 22 Then Return 1
		If inHand.GetSize() = 5 And hisHand < 22 Then Return -1
		If myHand > hisHand And myHand < 22
			Return 1
		Else If myHand < hisHand And hisHand < 22
			Return -1
		Else If myHand = hisHand And myHand < 22
			Return 0
		End If
	End Method
End Type

' Base class for each playing card.
Type TCard
	Field Suit:String			' club, diamond, heart, spade
	Field Value:Int			' 2..14  ( 11=jack, 12=queen, 13=king, 14=ace)
	Field Order:Int			' Used to shuffle the cards with.

	' Array fields for positioning and moving the card. The index in the array is as follow:
	'[ 0=PositionX, 1=PositionY, 2=Rotate, 3=ScaleX, 4=ScaleY, 5=Alpha ]
	Field Pos:Float[] =   [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
	Field Goal:Float[] =  [ 0.0, 0.0, 0.0, 1.0, 1.0, 1.0 ]
	Field Speed:Float[] = [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
	Field Face:Int = 1		' If the card should face up 1 or down 0.
	Field Front:TImage		' Main image to display.
	Global lag:Float = 8.0

	' Overrides the TList function to make cards be sorted by the Order field.
	Method Compare(Obj:Object)
		If TCard(Obj).Order < Order Then Return 1 Else Return -1
	End Method

	' Updates the position of the card.
	Method Update()
		For Local i:Int = 0 To 5
			Local Distance:Float = Goal[i] - Pos[i]
			Local Acceleration:Float = (Distance - Speed[i]*Lag)*2/(Lag*Lag)
			Speed[i]:+ Acceleration
			Pos[i]:+ Speed[i]
		Next
	End Method
	
	' Draws an image of the card on the screen at x,y.
	Method Draw()
		SetTransform( Pos[2],Pos[3],Pos[4] )
		SetAlpha( Pos[5] )
		If Face Then
			DrawImage( Front, Pos[0], Pos[1] )
		Else
			DrawImage( Back, Pos[0], Pos[1] )
		End If
		SetTransform 0,1,1 
		SetAlpha 1
	End Method
	
	
	' Create a single card.
	Function Create:TCard( inCount )
		Local Card:TCard = New TCard
		Card.Suit = AllSuit[inCount]
		Card.Value = AllValue[inCount]
		Card.Front = CardImg[inCount]
		'MidHandleImage( Card.Back )
		Return Card
	End Function
End Type

' Used for the graphic representation of buttons.
Type TButton
	Field Pos:Float[] =   [ 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 ]
	Field Goal:Float[] =  [ 0.0, 0.0, 0.0, 1.0, 1.0, 1.0 ]
	Field Speed:Float[] = [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
	Field GlowPos:Float[] =   [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
	Field GlowGoal:Float[] =  [ 0.0, 0.0, 0.0, 1.0, 1.0, 0.0 ]
	Field GlowSpeed:Float[] = [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
	Field Image:TImage
	Field GlowImage:TImage
	Field Name:String
	Global Lag:Float = 8.0
	
	' Updates the position of the button.
	Method Update()
		For Local i:Int = 0 To 5
			Local Distance:Float = Goal[i] - Pos[i]
			Local Acceleration:Float = (Distance - Speed[i]*Lag)*2/(Lag*Lag)
			Speed[i]:+ Acceleration
			Pos[i]:+ Speed[i]
			Distance = GlowGoal[i] - GlowPos[i]
			Acceleration = (Distance - GlowSpeed[i]*Lag)*2/(Lag*Lag)
			GlowSpeed[i]:+ Acceleration
			GlowPos[i]:+ GlowSpeed[i]
		Next
	End Method
	
	' Draw the button.
	Method Draw()
		SetTransform( Pos[2],Pos[3],Pos[4] )
		SetAlpha( Pos[5] )
		DrawImage( Image, Pos[0], Pos[1] )
		SetTransform( GlowPos[2],GlowPos[3],GlowPos[4] )
		SetAlpha( GlowPos[5] )
		DrawImage( GlowImage, GlowPos[0], GlowPos[1] )
		SetTransform 0,1,1
		SetAlpha 1
	End Method
	
	' Create a representation for a button.
	Function Create:TButton( inName:String, inImage:TImage, inGlow:TImage )
		Local MyButton:TButton = New TButton
		MyButton.Name = inName
		MyButton.Image = inImage
		MyButton.GlowImage = inGlow
		Return MyButton
	End Function
End Type

Type TNumber
	Field Visible:Int = 0
	Field Kind:Int		' 0 = Bet, 1 = Cash
	Field x:Int = 100
	Field y:Int = 384
	
	Method Draw(  )
		If Visible
			Local Number:Int
			If Kind Then Number = Human.Cash Else Number = Human.Bet
			Local NumberString:String = Number
			Local Digits:Int = NumberString.Length
			
			Local FirstNumberPosition:Int = (Digits*(-12))+25+x
			For Local i:Int = 0 To Digits-1
				Local OneDigit:Int = NumberString[i]
				OneDigit:-48
				SetAlpha 0.9
				DrawImage( NumberImg[OneDigit], FirstNumberPosition, y )
				SetAlpha 1.0
				FirstNumberPosition:+ 25
			Next
		End If
	End Method
	
	Function Create:TNumber()
		Return New TNumber
	End Function
End Type

' Timer function. Use [ If Time.Tick() Then something... ]
Type TTimer
	Field Start:Int		' Start time.
	Field Ticks:Int		' The number of times the timer has clicked.
	Field Wait:Int		' Number of millisecs to wait between ticks.
	
	' Returns true if the timer ticks. Add's one to Tick count.
	Method Tick:Int()
		If MilliSecs() > Start + Wait
			Ticks:+1
			Start = MilliSecs()
			Return 1
		Else
			Return 0
		End If
	End Method

	' Creates a timer. Takes time to wait between ticks as input.
	Function Create:TTimer( inWait:Int = 60 )
		Local Time:TTimer = New TTimer
		Time.Start = MilliSecs()
		Time.Ticks = 0
		Time.Wait = inWait
		Return Time
	End Function
End Type
