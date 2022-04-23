#SingleInstance force
;Modron Automation Gem Farming Script
;by mikebaldi1980
global ScriptDate := "03/15/22/v1"
;put together with the help from many different people. thanks for all the help.
SetWorkingDir, %A_ScriptDir%
CoordMode, Mouse, Client

;========================================
;User settings not accessible via the GUI
;========================================
;variables to consider changing if restarts are causing issues
global gOpenProcess	:= 10000	;time in milliseconds for your PC to open Idle Champions
global gGetAddress := 12000		;time in milliseconds after Idle Champions is opened for it to read moduel base address from memory
global ScriptSpeed := 25
global gZoneSkip := []
global oldgLevel_Number :=
;====================
;end of user settings
;====================

/* Changes
"11/13/21"
1. Added redundancy and checks for failed key inputs.
*/

;class and methods for parsing JSON (User details sent back from a server call)
#include JSON.ahk

;wrapper with memory reading functions sourced from: https://github.com/Kalamity/classMemory
#include classMemory.ahk

;Check if you have installed the class correctly.
if (_ClassMemory.__Class != "_ClassMemory")
{
    msgbox class memory not correctly installed. Or the (global class) variable "_ClassMemory" has been overwrittenmod
    ExitApp
}

;pointer addresses and offsets
#include IC_MemoryFunctions.ahk

;server call functions and variables Included after GUI so chest tabs maybe non optimal way of doing it
#include IC_ServerCallFunctions.ahk

;Thanks ThePuppy for the ini code
;Champions to level with Fkeys
global gFKeys := 
loop, 12
{
    IniRead, Seat%A_Index%Toggle, UserSettings.ini, Section1, Seat%A_Index%Toggle
    if (Seat%A_Index%Toggle)
    {
        gFKeys = %gFKeys%{F%A_Index%}
    }
}
loop, 5
{
	IniRead, tVal, UserSettings.ini, Section1, SkipZone%A_Index%, 0
	CheckboxZoneSkip%A_Index% := tVal
	gZoneSkip[A_Index] := tVal
}

global gSeatToggle := [Seat1Toggle,Seat2Toggle,Seat3Toggle,Seat4Toggle,Seat5Toggle,Seat6Toggle,Seat7Toggle,Seat8Toggle,Seat9Toggle,Seat10Toggle,Seat11Toggle,Seat12Toggle]
;Continued leveling stop zone
IniRead, ContinuedLeveling, UserSettings.ini, Section1, ContinuedLeveling, 10
global gContinuedLeveling := ContinuedLeveling
;Farm SB stacks after this zone
IniRead, AreaLow, UserSettings.ini, Section1, AreaLow, 30
global gAreaLow := AreaLow
;Lowest zone SB stacks can be farmed on
IniRead, MinStackZone, UserSettings.ini, Section1, MinStackZone, 25
global gMinStackZone := MinStackZone
;Target Haste stacks
IniRead, SBTargetStacks, UserSettings.ini, Section1, SBTargetStacks, 400
global gSBTargetStacks := SBTargetStacks
;Dash wait max time
IniRead, DashSleepTime, UserSettings.ini, Section1, DashSleepTime, 60000
global gDashSleepTime := DashSleepTime
;Hew's ult key
IniRead, HewUlt, UserSettings.ini, Section1, HewUlt, 6
global gHewUlt := HewUlt
;spam ults after initial leveling
IniRead, Ults, UserSettings.ini, Section1, Ults
global gUlts := Ults
;Briv swap to avoid bossese
IniRead, AvoidBosses, UserSettings.ini, Section1, AvoidBosses
global gAvoidBosses := AvoidBosses

;addby zhaoxp
;target sprint offline
IniRead, HastetackOnline, UserSettings.ini, Section1, HastetackOnline, 1
global gHastetackOnline := HastetackOnline
IniRead, DefaultFormation, UserSettings.ini, Section1, DefaultFormation, 0
global gDefaultFormation := DefaultFormation
IniRead, Backgroundmark, UserSettings.ini, Section1, Backgroundmark, 1
global gBackgroundmark := Backgroundmark
;ggamerestartlevel
IniRead, gamerestartlevel, UserSettings.ini, Section1, gamerestartlevel, 20
global ggamerestartlevel := gamerestartlevel
IniRead, restarttime, UserSettings.ini, Section1, restarttime
global grestarttime := restarttime
IniRead, myjumplevel, UserSettings.ini, Section1, myjumplevel, 1
global gmyjumplevel := myjumplevel
IniRead, restartgems, UserSettings.ini, Section1, restartgems, 10000
global grestartgems := restartgems
loop, 5
{
	IniRead, tVal, UserSettings.ini, Section1, SkipZone%A_Index%, 0
	CheckboxZoneSkip%A_Index% := tVal
	gZoneSkip[A_Index] := tVal
}


;Click damage toggle
IniRead, ClickLeveling, UserSettings.ini, Section1, ClickLeveling
global gClickLeveling := ClickLeveling
;Click damage toggle
IniRead, CtrlClickLeveling, UserSettings.ini, Section1, CtrlClickLeveling, 0
global gCtrlClickLeveling := CtrlClickLeveling
;Stack fail recovery toggle
IniRead, StackFailRecovery, UserSettings.ini, Section1, StackFailRecovery
global gStackFailRecovery := StackFailRecovery
;Stack fail recovery toggle
IniRead, StackFailConvRecovery, UserSettings.ini, Section1, StackFailConvRecovery
global gStackFailConvRecovery := StackFailConvRecovery
;Briv swap sleep time
IniRead, SwapSleep, UserSettings.ini, Section1, SwapSleep, 1500
global gSwapSleep := SwapSleep
;Restart stack sleep time
IniRead, RestartStackTime, UserSettings.ini, Section1, RestartStackTime, 12000
global gRestartStackTime := RestartStackTime
;Intall location
IniRead, GameInstallPath, Usersettings.ini, Section1, GameInstallPath, C:\Program Files (x86)\Steam\steamapps\common\IdleChampions\IdleDragons.exe
global gInstallPath := GameInstallPath
;Normal SB farm max time
IniRead, SBTimeMax, UserSettings.ini, Section1, SBTimeMax, 60000
global gSBTimeMax := SBTimeMax
;Enable servecalls to open chests during stack restart
IniRead, DoChests, UserSettings.ini, Section1, DoChests, 0
global gDoChests := DoChests
;Minimum gems to save when buying chests
IniRead, SCMinGemCount, UserSettings.ini, Section1, SCMinGemCount, 0
global gSCMinGemCount := SCMinGemCount
;Buy silver chests when can afford this many
IniRead, SCBuySilvers, UserSettings.ini, Section1, SCBuySilvers, 0
global gSCBuySilvers := SCBuySilvers
;Open silver chests when you have this many
IniRead, SCSilverCount, UserSettings.ini, Section1, SCSilverCount, 0
global gSCSilverCount := SCSilverCount
;Buy gold chests when can afford this many
IniRead, SCBuyGolds, UserSettings.ini, Section1, SCBuyGolds, 0
global gSCBuyGolds := SCBuyGolds
;Open silver chests when you have this many
IniRead, SCGoldCount, UserSettings.ini, Section1, SCGoldCount, 0
global gSCGoldCount := SCGoldCount

;variable for correctly tracking stats during a failed stack, to prevent fast/slow runs to be thrown off
global gStackFail := 0

;globals for various timers
global gSlowRunTime		:= 		
global gFastRunTime		:= 100
global gRunStartTime 	:=
global gTotal_RunCount	:= 0
global gStartTime 	    := 
global gPrevLevelTime	:=	
global gPrevRestart 	:=
global gprevLevel 	    :=
global dtCurrentLevelTime :=

;globals for reset tracking
global gFailedStacking := 0
global gFailedStackConv := 0
;globals used for stat tracking
global gGemStart		:=
global gCoreXPStart		:=
global gGemSpentStart	:=
global gRedGemsStart	:=

global gStackCountH	:=
global gStackCountSB :=

;define a new gui with tabs and buttons
Gui, MyWindow:New
Gui, MyWindow:+Resize -MaximizeBox
Gui, MyWindow:Add, Button, x415 y25 w60 gSave_Clicked, Save
Gui, MyWindow:Add, Button, x415 y+50 w60 gRun_Clicked, `Run
Gui, MyWindow:Add, Button, x415 y+100 w60 gReload_Clicked, `Reload
Gui, MyWindow:Add, Tab3, x5 y5 w400, Read First|Settings|Help|Stats|Debug|

Gui, Tab, Read First
Gui, MyWindow:Font, w700
Gui, MyWindow:Add, Text, x15 y30, Gem Farm, %ScriptDate%
Gui, MyWindow:Font, w400
Gui, MyWindow:Add, Text, x15 y+10, Instructions:
Gui, MyWindow:Add, Text, x15 y+2 w10, 1.
Gui, MyWindow:Add, Text, x+2 w370, Save your speed formation in formation save slot 1, in game `hotkey "Q". This formation must include Briv and at least one familiar on the field.
Gui, MyWindow:Add, Text, x15 y+2 w10, 2.
Gui, MyWindow:Add, Text, x+2 w370, Save your stack farming formation in formation save slot 2, in game `hotkey "W". Don't include any familiars on the field.
Gui, MyWindow:Add, Text, x15 y+2 w10, 3.
Gui, MyWindow:Add, Text, x+2 w370, Save your speed formation without Briv, Hew, or Melf in formation save slot 3, in game `hotkey "E".
Gui, MyWindow:Add, Text, x15 y+2, 4. Adjust the settings on the settings tab.
Gui, MyWindow:Add, Text, x15 y+2, 5. `Click the save button to save your settings.
Gui, MyWindow:Add, Text, x15 y+2, 6. Load into zone 1 of an adventure to farm gems.
Gui, MyWindow:Add, Text, x15 y+2, 7. Press the run button to start farming gems.
Gui, MyWindow:Add, Text, x15 y+10, Notes:
Gui, MyWindow:Add, Text, x15 y+2, 1. Use the pause hotkey, ``, to adjust settings after a run starts.
Gui, MyWindow:Add, Text, x15 y+2, 2. Don't forget to unpause after saving your settings.
Gui, MyWindow:Add, Text, x15 y+2, 3. First run is ignored for stats, in case it is a partial run.
Gui, MyWindow:Add, Text, x15 y+2, 4. Settings save to and load from UserSettings.ini file.
Gui, MyWIndow:Add, Text, x15 y+2 w10, 5.
Gui, MyWIndow:Add, Text, x+2 w370, Recommended SB stack level is [Modron Reset Zone] - X, with X = 4 for single skip, X = 6 for double skip, X = 8 for triple skip, and X = 10 for quadruple skip.
Gui, MyWindow:Add, Text, x15 y+2 w10, 6.
Gui, MyWindow:Add, Text, x+2 w370, Script will activate and focus the game window for manual resets as part of failed stacking.
Gui, MyWIndow:Add, Text, x15 y+2 w10, 7.
Gui, MyWIndow:Add, Text, x+2 w370, Script communicates directly with Idle Champions play servers to recover from a failed stacking and for when Modron resets to the World Map.
Gui, MyWIndow:Add, Text, x15 y+2 w10, 8.
Gui, MyWIndow:Add, Text, x+2 w370, Script reads system memory.
Gui, MyWIndow:Add, Text, x15 y+2 w10, 9.
Gui, MyWIndow:Add, Text, x+2 w370, Disable manual resets to recover from failed Briv stack conversions when running event free plays.
Gui, MyWIndow:Add, Text, x15 y+2 w10, 10.
Gui, MyWIndow:Add, Text, x+2 w370, Recommended Briv swap `sleep time is betweeb 1500 - 3000. If you are seeing Briv's landing animation then increase the the swap sleep time. If Briv is not back in the formation before monsters can be killed then decrease the swap sleep time.
Gui, MyWindow:Add, Text, x15 y+10, Known Issues:
Gui, MyWindow:Add, Text, x15 y+2, 1. Cannot fully interact with `GUI `while script is running.
Gui, MyWindow:Add, Text, x15 y+2 w10, 2. 
Gui, MyWindow:Add, Text, x+2 w370, Using Hew's ult throughout a run with Briv swapping can result in Havi's ult being triggered instead. Consider removing Havi from formation save slot 3, in game `hotkey "E".

Gui, Tab, Settings



Gui, MyWindow:Font, cBlack
;addby zhaoxp
Gui, MyWindow:Add, Edit, vrestarttime x15 y+10 w50, % grestarttime
Gui, MyWindow:Add, Text, x+5, myIC Is restarttime

Gui, MyWindow:Add, Edit, vNewgAreaLow x15 y+10 w50, % gAreaLow
Gui, MyWindow:Add, Text, x+5, Farm SB stacks AFTER this zone

Gui, MyWindow:Add, Checkbox, vgAvoidBosses Checked%gAvoidBosses% x15 y+10, Swap to 'e' formation when `on boss zones
;addby zhaoxp
Gui, MyWindow:Add, Checkbox, vgHastetackOnline Checked%HastetackOnline% x15 y+10, I want offline hate stack
Gui, MyWindow:Add, Checkbox, vgBackgroundmark Checked%Backgroundmark% x15 y+10, I wan't `Background
;addby zhaoxp end

Gui, MyWindow:Add, Edit, vNewSCMinGemCount x15 y+10 w100, % gSCMinGemCount
Gui, MyWindow:Add, Text, x+5, Maintain this many gems when buying chests
Gui, MyWindow:Add, Edit, vNewSCBuySilvers x15 y+10 w50, % gSCBuySilvers
Gui, MyWindow:Add, Text, x+5, When there are sufficient gems, buy this many silver chests
Gui, MyWindow:Add, Edit, vNewSCSilverCount x15 y+10 w50, % gSCSilverCount
Gui, MyWindow:Add, Text, x+5, When there are this many silver chests, open them
Gui, MyWindow:Add, Edit, vNewSCBuyGolds x15 y+10 w50, % gSCBuyGolds
Gui, MyWindow:Add, Text, x+5, When there are sufficient gems, buy this many Gold chests
Gui, MyWindow:Add, Edit, vNewSCGoldCount x15 y+10 w50, % gSCGoldCount
Gui, MyWindow:Add, Text, x+5, When there are this many gold chests, open them
Gui, MyWindow:Add, Button, x15 y+20 gChangeInstallLocation_Clicked, Change Install Path

Gui, Tab, Help
;Gui, MyWindow:Font, w700
Gui, MyWindow:Add, Text, x15 y30, Confirm your settings are saved. 
Gui, MyWindow:Add, Text, x15 y+2, 1 = true, yes, or enabled
Gui, MyWindow:Add, Text, x15 y+2, 0 = false, no, or disabled
;Gui, MyWindow:Font, w400
Gui, MyWindow:Add, Text, x15 y+15, Fkeys used for leveling: 
Gui, MyWindow:Add, Text, vgFKeysID x+2 w300, % gFKeys
Gui, MyWindow:Add, Text, x15 y+5, Use Fkey leveling while below this zone: 
Gui, MyWindow:Add, Text, vgContinuedLevelingID x+2 w200, % gContinuedLeveling
Gui, MyWindow:Add, Text, x15 y+5, Farm SB stacks AFTER this zone: 
Gui, MyWindow:Add, Text, vgAreaLowID x+2 w200, % gAreaLow
Gui, MyWindow:Add, Text, x15 y+5, Minimum zone Briv can farm SB stacks on: 
Gui, MyWindow:Add, Text, vgMinStackZoneID x+2 w200, % gMinStackZone 
Gui, MyWindow:Add, Text, x15 y+5, Target Haste stacks for next run: 
Gui, MyWindow:Add, Text, vgSBTargetStacksID x+2 w200, % gSBTargetStacks
Gui, MyWindow:Add, Text, x15 y+5, Max time script will farm SB Stacks normally: 
Gui, MyWindow:Add, Text, vgSBTimeMaxID x+2 w200, % gSBTimeMax
Gui, MyWindow:Add, Text, x15 y+5, Maximum time (ms) script will wait for Dash: 
Gui, MyWindow:Add, Text, vDashSleepTimeID x+2 w200, % gDashSleepTime
Gui, MyWindow:Add, Text, x15 y+5, Hew's ultimate key: 
Gui, MyWindow:Add, Text, vgHewUltID x+2 w200, % gHewUlt
Gui, MyWindow:Add, Text, x15 y+5, Time (ms) client remains closed for Briv Restart Stack:
Gui, MyWindow:Add, Text, vgRestartStackTimeID x+2 w200, % gRestartStackTime
Gui, MyWindow:Add, Text, x15 y+5, Use ults 2-9 after initial champion leveling:
Gui, MyWindow:Add, Text, vgUltsID x+2 w200, % gUlts
Gui, MyWindow:Add, Text, x15 y+5, Briv swap sleep time (ms):
Gui, MyWindow:Add, Text, vgSwapSleepID x+2 w200, % gSwapSleep
Gui, MyWindow:Add, Text, x15 y+5, Swap to 'e' formation when on boss zones:
Gui, MyWindow:Add, Text, vgAvoidBossesID x+2 w200, % gAvoidBosses
Gui, MyWindow:Add, Text, x15 y+5, Using a familiar on click damage:
Gui, MyWindow:Add, Text, vgClickLevelingID x+2 w200, % gClickLeveling
Gui, MyWindow:Add, Text, x15 y+5, Enable ctrl (x100) leveling of `click damage:
Gui, MyWindow:Add, Text, vgCtrlClickLevelingID x+2 w200, % gCtrlClickLeveling
Gui, MyWindow:Add, Text, x15 y+5, Enable manual resets to recover from failed Briv stacking:
Gui, MyWindow:Add, Text, vgStackFailRecoveryID x+2 w200, % gStackFailRecovery
Gui, MyWindow:Add, Text, x15 y+5, Enable manual resets to recover from failed Briv stack conversion:
Gui, MyWindow:Add, Text, vgStackFailConvRecoveryID x+2 w200, % gStackFailConvRecovery
Gui, MyWindow:Add, Text, x15 y+5, Enable server calls to buy and open chests during stack restart:
Gui, MyWindow:Add, Text, vgDoChestsID x+2 w200, % gDoChests
Gui, MyWindow:Add, Text, x15 y+5, Maintain this many gems when buying chests:
Gui, MyWindow:Add, Text, vgSCMinGemCountID x+2 w200, % gSCMinGemCount
Gui, MyWindow:Add, Text, x15 y+5, When there are sufficient gems, buy this many silver chests:
Gui, MyWindow:Add, Text, vgSCBuySilversID x+2 w200, % gSCBuySilvers
Gui, MyWindow:Add, Text, x15 y+5, When there are this many silver chests, open them:
Gui, MyWindow:Add, Text, vgSCSilverCountID x+2 w200, % gSCSilverCount
Gui, MyWindow:Add, Text, x15 y+5, When there are sufficient gems, buy this many gold chests:
Gui, MyWindow:Add, Text, vgSCBuyGoldsID x+2 w200, % gSCBuyGolds
Gui, MyWindow:Add, Text, x15 y+5, When there are this many gold chests, open them:
Gui, MyWindow:Add, Text, vgSCGoldCountID x+2 w200, % gSCGoldCount
Gui, MyWindow:Add, Text, x15 y+5, Install Path:
Gui, MyWindow:Add, Text, vgInstallPathID x15 y+2 w350 r5, %gInstallPath%
Gui, MyWindow:Add, Text, x15 y+15 w375 r5, Still having trouble? Take note of the information on the debug tab and ask for help in the scripting channel on the official discord.

statTabTxtWidth := 
Gui, Tab, Stats
Gui, MyWindow:Font, w700
Gui, MyWindow:Add, Text, x15 y33, Stats updated continuously (mostly):
Gui, MyWindow:Font, w400
Gui, MyWindow:Add, Text, x15 y+10 %statTabTxtWidth%, SB Stack `Count: 
Gui, MyWindow:Add, Text, vgStackCountSBID x+2 w50, % gStackCountSB
;Gui, MyWindow:Add, Text, vReadSBStacksID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+2 %statTabTxtWidth%, Haste Stack `Count:
Gui, MyWindow:Add, Text, vgStackCountHID x+2 w50, % gStackCountH
;Gui, MyWindow:Add, Text, vReadHasteStacksID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+10 %statTabTxtWidth%, Current `Run `Time:
Gui, MyWindow:Add, Text, vdtCurrentRunTimeID x+2 w50, % dtCurrentRunTime
Gui, MyWindow:Add, Text, x15 y+2 %statTabTxtWidth%, Total `Run `Time:
Gui, MyWindow:Add, Text, vdtTotalTimeID x+2 w50, % dtTotalTime
Gui, MyWindow:Add, Text, x15 y+5, ReadCurrentZone: 
Gui, MyWindow:Add, Text, vReadCurrentZoneID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+5, ReadHighestZone: 
Gui, MyWindow:Add, Text, vReadHighestZoneID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+5, ReadQuestRemaining: 
Gui, MyWindow:Add, Text, vReadQuestRemainingID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+5, ReadTimeScaleMultiplier: 
Gui, MyWindow:Add, Text, vReadTimeScaleMultiplierID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+5, ReadTransitioning: 
Gui, MyWindow:Add, Text, vReadTransitioningID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+5, ReadSBStacks: 
Gui, MyWindow:Add, Text, vReadSBStacksID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+5, ReadHasteStacks: 
Gui, MyWindow:Add, Text, vReadHasteStacksID x+2 w200,
;addby zhaoxp
;GuiControl, MyWindow:, vCurrentZoneID x+2 w50, % CurrentZone
Gui, MyWindow:Add, Text, x15 y+2 %statTabTxtWidth%, AreaSkipped:
Gui, MyWindow:Add, Text, vCurrentZoneID x+2 w50, % AreaSkipped
;
Gui, MyWindow:Font, w700
Gui, MyWindow:Add, Text, x15 y+10, Stats updated once per run:
Gui, MyWindow:Font, w400
Gui, MyWindow:Add, Text, x15 y+10 %statTabTxtWidth%, Total `Run `Count:
Gui, MyWindow:Add, Text, vgTotal_RunCountID x+2 w50, % gTotal_RunCount
Gui, MyWindow:Add, Text, x15 y+2 %statTabTxtWidth%, Previous `Run `Time:
Gui, MyWindow:Add, Text, vgPrevRunTimeID x+2 w50, % gPrevRunTime
Gui, MyWindow:Add, Text, x15 y+2 %statTabTxtWidth%, Fastest `Run `Time:
Gui, MyWindow:Add, Text, vgFastRunTimeID x+2 w50, 
Gui, MyWindow:Add, Text, x15 y+2 %statTabTxtWidth%, Slowest `Run `Time:
Gui, MyWindow:Add, Text, vgSlowRunTimeID x+2 w50, % gSlowRunTime
Gui, MyWindow:Add, Text, x15 y+2 %statTabTxtWidth%, Avg. `Run `Time:
Gui, MyWindow:Add, Text, vgAvgRunTimeID x+2 w50, % gAvgRunTime
Gui, MyWindow:Add, Text, x15 y+2 %statTabTxtWidth%, Fail `Run `Time:
Gui, MyWindow:Add, Text, vgFailRunTimeID x+2 w50, % gFailRunTime	
Gui, MyWindow:Add, Text, x15 y+2 %statTabTxtWidth%, Fail Stack Conversion:
Gui, MyWindow:Add, Text, vgFailedStackConvID x+2 w50, % gFailedStackConv
Gui, MyWindow:Add, Text, x15 y+2 %statTabTxtWidth%, Fail Stacking:
Gui, MyWindow:Add, Text, vgFailedStackingID x+2 w50, % gFailedStacking
Gui, MyWindow:Font, cBlue w700
Gui, MyWindow:Add, Text, x15 y+10 %statTabTxtWidth%, Bosses per hour:
Gui, MyWindow:Add, Text, vgbossesPhrID x+2 w50, % gbossesPhr
Gui, MyWindow:Font, cGreen
Gui, MyWINdow:Add, Text, x15 y+10, Total Gems:
Gui, MyWindow:Add, Text, vGemsTotalID x+2 w50, % GemsTotal
Gui, MyWINdow:Add, Text, x15 y+2, Gems per hour:
Gui, MyWindow:Add, Text, vGemsPhrID x+2 w200, % GemsPhr
Gui, MyWindow:Font, cRed
Gui, MyWINdow:Add, Text, x15 y+10, Total Black Viper Red Gems:
Gui, MyWindow:Add, Text, vRedGemsTotalID x+2 w50, % RedGemsTotal
Gui, MyWINdow:Add, Text, x15 y+2, Red Gems per hour:
Gui, MyWindow:Add, Text, vRedGemsPhrID x+2 w200, % RedGemsPhr
Gui, MyWindow:Font, cDefault w400
Gui, MyWindow:Font, w700
Gui, MyWindow:Add, Text, x15 y+10, `Loop: 
Gui, MyWindow:Add, Text, vgLoopID x+2 w200, Not Started
Gui, MyWindow:Font, w400

if (gDoChests)
{
    Gui, MyWindow:Font, w700
    Gui, MyWindow:Add, Text, x15 y+10 w300, Chest Data:
    Gui, MyWindow:Font, w400
    Gui, MyWindow:Add, Text, x15 y+5, Starting Gems Spent: 
    Gui, MyWindow:Add, Text, vgSCRedRubiesSpentStartID x+2 w200,
    Gui, MyWindow:Add, Text, x15 y+5, Starting Silvers Opened: 
    Gui, MyWindow:Add, Text, vgSCSilversOpenedStartID x+2 w200,
    Gui, MyWindow:Add, Text, x15 y+5, Starting Golds Opened: 
    Gui, MyWindow:Add, Text, vgSCGoldsOpenedStartID x+2 w200,	
    Gui, MyWindow:Add, Text, x15 y+5, Silvers Opened: 
    Gui, MyWindow:Add, Text, vgSCSilversOpenedID x+2 w200,
    Gui, MyWindow:Add, Text, x15 y+5, Golds Opened: 
    Gui, MyWindow:Add, Text, vgSCGoldsOpenedID x+2 w200,
    Gui, MyWindow:Add, Text, x15 y+5, Gems Spent: 
    Gui, MyWindow:Add, Text, vGemsSpentID x+2 w200,
}


Gui, Tab, Debug
Gui, MyWindow:Font, w700
Gui, MyWindow:Add, Text, x15 y35, Timers:
Gui, MyWindow:Font, w400
Gui, MyWindow:Add, Text, x15 y+10, ElapsedTime:
Gui, MyWindow:Add, Text, x15 y+5, ReadResetting: 
Gui, MyWindow:Add, Text, vReadResettingID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+5, ReadUserID: 
Gui, MyWindow:Add, Text, vReadUserIDID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+5, ReadUserHash: 
Gui, MyWindow:Add, Text, vReadUserHashID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+5, ReadScreenWidth: 
Gui, MyWindow:Add, Text, vReadScreenWidthID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+5, ReadScreenHeight: 
Gui, MyWindow:Add, Text, vReadScreenHeightID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+5, ReadMonstersSpawned:
Gui, MyWindow:Add, Text, vReadMonstersSpawnedID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+5, ReadChampLvlByID:
Gui, MyWindow:Add, Text, vReadChampLvlByIDID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+5, ReadCoreXP: 
Gui, MyWindow:Add, Text, vReadCoreXPID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+5, ReadGems: 
Gui, MyWindow:Add, Text, vReadGemsID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+5, ReadGemsSpent: 
Gui, MyWindow:Add, Text, vReadGemsSpentID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+5, ReadRedGems: 
Gui, MyWindow:Add, Text, vReadRedGemsID x+2 w200,
Gui, MyWindow:Add, Text, x15 y+5, ReadChampBenchedByID: 
Gui, MyWindow:Add, Text, vReadChampBenchedByIDID x+2 w200,

Gui, MyWindow:Font, w700
Gui, MyWindow:Add, Text, x15 y+15, Server Call Variables: 
Gui, MyWindow:Font, w400
Gui, MyWindow:Add, Text, x15 y+5, advtoload:
Gui, MyWindow:Add, Text, vadvtoloadID x+2 w300, % advtoload
Gui, MyWindow:Add, Text, x15 y+5, current_adventure_id:
Gui, MyWindow:Add, Text, vCurrentAdventureID x+2 w300,
Gui, MyWindow:Add, Text, x15 y+5, InstanceID:
Gui, MyWindow:Add, Text, vInstanceIDID x+2 w300, % InstanceID
Gui, MyWindow:Add, Text, x15 y+5, ActiveInstance:
Gui, MyWindow:Add, Text, vActiveInstanceID x+2 w300, % ActiveInstance

Gui, MyWindow:Show

;GUI to input a new install path.
Gui, InstallGUI:New
Gui, InstallGUI:Add, Edit, vNewInstallPath x15 y+10 w300 r5, % gInstallPath
Gui, InstallGUI:Add, Button, x15 y+25 gInstallOK_Clicked, Save and `Close
Gui, InstallGUI:Add, Button, x+100 gInstallCancel_Clicked, `Cancel

InstallCancel_Clicked:
{
    GuiControl, InstallGUI:, NewInstallPath, %gInstallPath%
    Gui, InstallGUI:Hide
    Return
}

InstallOK_Clicked:
{
    Gui, Submit, NoHide
    gInstallPath := NewInstallPath
    GuiControl, MyWindow:, gInstallPathID, %gInstallPath%
    IniWrite, %gInstallPath%, Usersettings.ini, Section1, GameInstallPath
    Gui, InstallGUI:Hide
    Return
}

ChangeInstallLocation_Clicked:
{
    Gui, InstallGUI:Show
    Return
}

Skip_Clicked:
{
	Gui, Submit, NoHide
	Loop, 5
	{
		Checked := CheckboxZoneSkip%A_Index%
		gZoneSkip[A_Index] := %Checked%
	}
	GuiControl, , BrivWarning ,Selection Modified hope you know what your doing
	return
}

Save_Clicked:
{
    Gui, Submit, NoHide
    Loop, 12
    {
        gSeatToggle[A_Index] := CheckboxSeat%A_Index%
        var := CheckboxSeat%A_Index%
        IniWrite, %var%, UserSettings.ini, Section1, Seat%A_Index%Toggle
    }
    gFKeys :=
    Loop, 12
    {
        if (gSeatToggle[A_Index])
        {
            gFKeys = %gFKeys%{F%A_Index%}
            IniWrite, 1, UserSettings.ini, Section1, Seat%A_Index%Toggle
        }
        Else
        IniWrite, 0, UserSettings.ini, Section1, Seat%A_Index%Toggle
    }
    GuiControl, MyWindow:, gFkeysID, % gFKeys
    gAreaLow := NewgAreaLow
    GuiControl, MyWindow:, gAreaLowID, % gAreaLow
    IniWrite, %gAreaLow%, UserSettings.ini, Section1, AreaLow
    gMinStackZone := NewgMinStackZone
    GuiControl, MyWindow:, gMinStackZoneID, % gMinStackZone
    IniWrite, %gMinStackZone%, Usersettings.ini, Section1, MinStackZone
    gSBTargetStacks := NewSBTargetStacks
    GuiControl, MyWindow:, gSBTargetStacksID, % gSBTargetStacks
    IniWrite, %gSBTargetStacks%, UserSettings.ini, Section1, SBTargetStacks
    gSBTimeMax := NewgSBTimeMax
    GuiControl, MyWindow:, gSBTimeMaxID, %gSBTimeMax%
    IniWrite, %gSBTimeMax%, Usersettings.ini, Section1, SBTimeMax
    gDashSleepTime := NewDashSleepTime
    GuiControl, MyWindow:, DashSleepTimeID, % gDashSleepTime
    IniWrite, %gDashSleepTime%, UserSettings.ini, Section1, DashSleepTime
    gContinuedLeveling := NewContinuedLeveling
    GuiControl, MyWindow:, gContinuedLevelingID, % gContinuedLeveling
    IniWrite, %gContinuedLeveling%, UserSettings.ini, Section1, ContinuedLeveling
    gHewUlt := NewHewUlt
    GuiControl, MyWindow:, gHewUltID, % gHewUlt
    IniWrite, %gHewUlt%, UserSettings.ini, Section1, HewUlt
    GuiControl, MyWindow:, gUltsID, % gUlts
    IniWrite, %gUlts%, UserSettings.ini, Section1, Ults
    GuiControl, MyWindow:, gAvoidBossesID, % gAvoidBosses
    IniWrite, %gAvoidBosses%, UserSettings.ini, Section1, AvoidBosses
    ;addby zhaoxp
    GuiControl, MyWindow:, gHastetackOnlineID, % gHastetackOnline
    IniWrite, %gHastetackOnline%, UserSettings.ini, Section1, HastetackOnline
    gHastetackOnline := HastetackOnline
    loop, 5
	{
		tVal := CheckboxZoneSkip%A_Index%
		IniWrite, %tVal%, UserSettings.ini, Section1, SkipZone%A_Index%
		gZoneSkip[A_Index] := tVal
	}
    
    ;DefaultFormation gamerestartlevel
	ggamerestartlevel := gamerestartlevel
    GuiControl, MyWindow:, ggamerestartlevelID, % ggamerestartlevel
    IniWrite, %ggamerestartlevel%, UserSettings.ini, Section1, gamerestartlevel
    GuiControl, MyWindow:, gDefaultFormationID, % gDefaultFormation
    IniWrite, %gDefaultFormation%, UserSettings.ini, Section1, DefaultFormation
    gDefaultFormation := DefaultFormation
    ;Backgroundmark
    GuiControl, MyWindow:, gBackgroundmarkID, % gBackgroundmark
    IniWrite, %gBackgroundmark%, UserSettings.ini, Section1, Backgroundmark
    gDefaultFormation := DefaultFormation
    ;addby zhaoxp end
    GuiControl, MyWindow:, gClickLevelingID, % gClickLeveling
    IniWrite, %gClickLeveling%, UserSettings.ini, Section1, ClickLeveling
    GuiControl, MyWindow:, gCtrlClickLevelingID, % gCtrlClickLeveling
    IniWrite, %gCtrlClickLeveling%, UserSettings.ini, Section1, CtrlClickLeveling
    GuiControl, MyWindow:, gStackFailRecoveryID, % gStackFailRecovery
    IniWrite, %gStackFailRecovery%, UserSettings.ini, Section1, StackFailRecovery
    GuiControl, MyWindow:, gStackFailConvRecoveryID, % gStackFailConvRecovery
    IniWrite, %gStackFailConvRecovery%, UserSettings.ini, Section1, StackFailConvRecovery
    gSwapSleep := NewSwapSleep
    GuiControl, MyWindow:, gSwapSleepID, % gSwapSleep
    IniWrite, %gSwapSleep%, UserSettings.ini, Section1, SwapSleep
    ;addby zhaoxp
    grestarttime := restarttime
    GuiControl, MyWindow:, grestarttimeID, % grestarttime
    IniWrite, %grestarttime%, UserSettings.ini, Section1, restarttime
    gmyjumplevel := myjumplevel
    GuiControl, MyWindow:, gmyjumplevelID, % gmyjumplevel
    IniWrite, %gmyjumplevel%, UserSettings.ini, Section1, myjumplevel
    grestartgems := restartgems
    GuiControl, MyWindow:, grestartgemsID, % gmyjumplevel
    IniWrite, %grestartgems%, UserSettings.ini, Section1, restartgems
    
    gRestartStackTime := NewRestartStackTime
    GuiControl, MyWindow:, gRestartStackTimeID, % gRestartStackTime
    IniWrite, %gRestartStackTime%, UserSettings.ini, Section1, RestartStackTime
    GuiControl, MyWindow:, gDoChestsID, % gDoChests
    IniWrite, %gDoChests%, UserSettings.ini, Section1, DoChests
    gSCMinGemCount := NewSCMinGemCount
    GuiControl, MyWindow:, gSCMinGemCount, % gSCMinGemCount
    IniWrite, %gSCMinGemCount%, UserSettings.ini, Section1, SCMinGemCount
    gSCBuySilvers := NewSCBuySilvers
    if (gSCBuySilvers > 100)
    gSCBuySilvers := 100
    GuiControl, MyWindow:, gSCBuySilversID, % gSCBuySilvers
    IniWrite, %gSCBuySilvers%, UserSettings.ini, Section1, SCBuySilvers
    gSCSilverCount := NewSCSilverCount
    if (gSCSilverCount > 99)
    gSCSilverCount := 99
    GuiControl, MyWindow:, gSCSilverCountID, % gSCSilverCount
    IniWrite, %gSCSilverCount%, UserSettings.ini, Section1, SCSilverCount
    gSCBuyGolds := NewSCBuyGolds
    if (gSCBuyGolds > 100)
    gSCBuyGolds := 100
    GuiControl, MyWindow:, gSCBuyGoldsID, % gSCBuyGolds
    IniWrite, %gSCBuyGolds%, UserSettings.ini, Section1, SCBuyGolds
    gSCGoldCount := NewSCGoldCount
    if (gSCGoldCount > 99)
    gSCGoldCount := 99
    GuiControl, MyWindow:, gSCGoldCountID, % gSCGoldCount
    IniWrite, %gSCGoldCount%, UserSettings.ini, Section1, SCGoldCount
    return
}

Briv_Changed:
{
	Gui, Submit, NoHide

	skip := Mod(gBrivSkip, 5)

	zone := (4 - skip)
	Loop, 50
	{
		CheckboxZoneSkip%A_Index% := 0
		GuiControl, MyWindow: , CheckboxZoneSkip%A_Index% , 0
		gZoneSkip[A_Index] := 0
			
		if ((Mod(A_Index, 5) = zone))
		{
			CheckboxZoneSkip%A_Index% := 1
			GuiControl, MyWindow: , CheckboxZoneSkip%A_Index% , 1
			gZoneSkip[A_Index] := 1
		}
		if (not g100PercentBriv and (Mod(A_Index, 5) = zone+1) and not skip = 1)
		{
			CheckboxZoneSkip%A_Index% := 1
			GuiControl, MyWindow: , CheckboxZoneSkip%A_Index% , 1
			gZoneSkip[A_Index] := 1
		}
	}

	Gui, Font
	GuiControl, , BrivWarning ,Selection Updated.
	GuiControl, Font, BrivWarning
	if (gBrivSkip = 5 or (gBrivSkip = 6 and not g100PercentBriv))
	{
		Gui, Font, cRed Bold
		GuiControl, , BrivWarning, Careful! You can land on bosses. 100`% 6 Skip recommended. GL!
		GuiControl, Font, BrivWarning
	}
	if ((gBrivSkip = 1) and not g100PercentBriv)
	{
		Gui, Font, cRed Bold
		GuiControl, , BrivWarning, You need at least 100`% 1 Skip Briv for Jimothy.
		GuiControl, Font, BrivWarning
	}
	Gui, Submit, NoHide

	return
}

Reload_Clicked:
{
    Reload
    return
}

Run_Clicked:
{
    gStartTime := A_TickCount
    gRunStartTime := A_TickCount
    GemFarm()
    return
}

MyWindowGuiClose() 
{
    MsgBox 4,, Are you sure you want to `exit?
    IfMsgBox Yes
    ExitApp
    IfMsgBox No
    return True
}

$`::
Pause
gPrevLevelTime := A_TickCount
return

;a function that checks if IC is closed and restarts it. Then opens the process and reads the module base address, two necessary steps to read memory.
SafetyCheck() 
{
    While (Not WinExist("ahk_exe IdleDragons.exe")) 
    {
        Run, %gInstallPath%
        ;Run, "C:\Program Files (x86)\Steam\steamapps\common\IdleChampions\IdleDragons.exe"
        StartTime := A_TickCount
        ElapsedTime := 0
        GuiControl, MyWindow:, gloopID, Opening IC
        While (Not WinExist("ahk_exe IdleDragons.exe") AND ElapsedTime < grestarttime) 
        {
            Sleep 1000
            ElapsedTime := UpdateElapsedTime(StartTime)
            UpdateStatTimers()
        }
        If (Not WinExist("ahk_exe IdleDragons.exe"))
          Return

        ;the script doesn't update GUI with elapsed time while IC is loading, opening the address, or readying base address, to minimize use of CPU.
        GuiControl, MyWindow:, gloopID, Opening `Process
        OpenProcess()
		Sleep grestarttime
        GuiControl, MyWindow:, gloopID, Loading Module Base
        ;Sleep gGetAddress
        
        ;reset timer for checking if IC is stuck on a zone.
        gPrevLevelTime := A_TickCount
    }
}

;A function that closes IC. If IC takes longer than 60 seconds to save and close then the script will force it closed.
CloseIC()
{
    PostMessage, 0x112, 0xF060,,, ahk_exe IdleDragons.exe
    StartTime := A_TickCount
    ElapsedTime := 0
    GuiControl, MyWindow:, gloopID, Saving and Closing IC
    While (WinExist("ahk_exe IdleDragons.exe") AND ElapsedTime < 10000) 
    {
        Sleep 100
        ElapsedTime := UpdateElapsedTime(StartTime)
        UpdateStatTimers()
    }
    ;~ While (WinExist("ahk_exe IdleDragons.exe")) 
    ;~ {
        ;~ GuiControl, MyWindow:, gloopID, Forcing IC Close
        ;~ PostMessage, 0x112, 0xF060,,, ahk_exe IdleDragons.exe
        ;~ sleep 1000
        ;~ ElapsedTime := UpdateElapsedTime(StartTime)
        ;~ UpdateStatTimers()
    ;~ }
}

FinishZone()
{
    StartTime := A_TickCount
    ElapsedTime := 0
    GuiControl, MyWindow:, gloopID, Finishing Zone
    ;check if stuck function would fail here on some cases where game gets stuck in offline progress calc, common after invalid instance. memory would read as if progress was still happening.
    if (ElapsedTime < grestarttime)
    {
        CloseIC()
        Sleep, 10000()
        GetUserDetails()
        EndAdventure()
    }
    ;look for Briv no benched when spamming 'w' formation.
    StartTime := A_TickCount
    ElapsedTime := 0
    GuiControl, MyWindow:, gloopID, Confirming Zone Load
    if (ElapsedTime > grestarttime)
    {
        CloseIC()
        Sleep, 10000()
        GetUserDetails()
        EndAdventure()
    }
    return
}

EndAdventure() 
{
    DirectedInput("r")
    xClick := (ReadScreenWidth(1) / 2) - 80
    yClickMax := ReadScreenHeight(1)
    yClick := yClickMax / 2
    StartTime := A_TickCount
    ElapsedTime := 0
    GuiControl, MyWindow:, gloopID, Manually Ending Adventure
    while(!ReadResetting(1) AND ElapsedTime < restarttime)
    {
        WinActivate, ahk_exe IdleDragons.exe
        MouseClick, Left, xClick, yClick, 1
        if (yClick < yClickMax)
        yClick := yClick + 10
        Else
        yClick := yClickMax / 2
        Sleep, 25
        ElapsedTime := UpdateElapsedTime(StartTime)
        UpdateStatTimers()
    }
    GuiControl, MyWindow:, gloopID, Manually Rebeginning Adventure
    LoadAdventure()

}


LoadingZoneREV()
{
    ;look for Briv benched when spamming 'e' formation.
    StartTime := A_TickCount
    ElapsedTime := 0
    GuiControl, MyWindow:, gloopID, Loading Zone
    CloseIC()
    GetUserDetails()
    LoadAdventure()
    OpenProcess()
    SafetyCheck() 

}



UpdateStartLoopStats(gLevel_Number)
{
    if ( gTotal_RunCount = 0 )
    {
        gStartTime := A_TickCount
        gCoreXPStart := ReadCoreXP(1)
        gGemStart := ReadGems(1)
        gGemSpentStart := ReadGemsSpent(1)
        gRedGemsStart := ReadRedGems(1)
    }
    if ( gTotal_RunCount )
    {
        gPrevRunTime := round((A_TickCount - gRunStartTime) / 60000, 2)
        GuiControl, MyWindow:, gPrevRunTimeID, % gPrevRunTime
        if (gSlowRunTime < gPrevRunTime AND !gStackFail)
        {
            gSlowRunTime := gPrevRunTime
            GuiControl, MyWindow:, gSlowRunTimeID, % gSlowRunTime
        }
        if (gFastRunTime > gPrevRunTime AND !gStackFail)
        {
            gFastRunTime := gPrevRunTime
            GuiControl, MyWindow:, gFastRunTimeID, % gFastRunTime
        }
        if (gStackFail)
        {
            gFailRunTime := gPrevRunTime
            GuiControl, MyWindow:, gFailRunTimeID, % gFailRunTime
            if (gStackFail = 1)
            {
                ++gFailedStacking
                GuiControl, MyWindow:, gFailedStackingID, % gFailedStacking
            }
            else if (gStackFail = 2)
            {
                ++gFailedStackConv
                GuiControl, MyWindow:, gFailedStackConvID, % gFailedStackConv
            }
        }
        dtTotalTime := (A_TickCount - gStartTime) / 3600000
        gAvgRunTime := Round((dtTotalTime / gTotal_RunCount) * 60, 2)
        GuiControl, MyWindow:, gAvgRunTimeID, % gAvgRunTime
        dtTotalTime := (A_TickCount - gStartTime) / 3600000
        TotalBosses := (ReadCoreXP(1) - gCoreXPStart) / 5
        gbossesPhr := Round(TotalBosses / dtTotalTime, 2)
        GuiControl, MyWindow:, gbossesPhrID, % gbossesPhr
        GuiControl, MyWindow:, gTotal_RunCountID, % gTotal_RunCount
        GemsTotal := (ReadGems(1) - gGemStart) + (ReadGemsSpent(1) - gGemSpentStart)
        GuiControl, MyWindow:, GemsTotalID, % GemsTotal
        GemsPhr := Round(GemsTotal / dtTotalTime, 2)
        GuiControl, MyWindow:, GemsPhrID, % GemsPhr
        if (  !mod(gTotal_RunCount,ggamerestartlevel) )
        {
            CloseIC()
        }
        if ( GemsPhr < grestartgems )
        {
            UserID := ReadUserID(1)
            UserHash := ReadUserHash(1)
            advtoload := ReadCurrentObjID(0)
            TotalBosses := 0
            dtTotalTime := 0
            gAvgRunTime := 0
            GemsTotal := 0
            GemsPhr := 0
            gPrevLevelTime := A_TickCount
            CloseIC()

        }
        RedGemsTotal := (ReadRedGems(1) - gRedGemsStart)
        if (RedGemsTotal)
        {
            GuiControl, MyWindow:, RedGemsTotalID, % RedGemsTotal
            RedGemsPhr := Round(RedGemsTotal / dtTotalTime, 2)
            GuiControl, MyWindow:, RedGemsPhrID, % RedGemsPhr
        }
        Else
        {
            GuiControl, MyWindow:, RedGemsTotalID, 0
            GuiControl, MyWindow:, RedGemsPhrID, Pathetic
        }	
    }
    gRunStartTime := A_TickCount
    gPrevLevel := gLevel_Number
    GuiControl, MyWindow:, gPrevLevelID, % gPrevLevel
}

UpdateStatTimers()
{
    dtCurrentRunTime := Round((A_TickCount - gRunStartTime) / 60000, 2)
    GuiControl, MyWindow:, dtCurrentRunTimeID, % dtCurrentRunTime
    dtTotalTime := Round((A_TickCount - gStartTime) / 3600000, 2)
    GuiControl, MyWindow:, dtTotalTimeID, % dtTotalTime
    dtCurrentLevelTime := Round((A_TickCount - gPrevLevelTime) / 1000, 2)
    GuiControl, MyWindow:, dtCurrentLevelTimeID, % dtCurrentLevelTime
    oldgLevel_Number := gLevel_Number - 1
    gLevel_Number := ReadCurrentZone(1)

}

UpdateElapsedTime(StartTime)
{
    ElapsedTime := A_TickCount - StartTime
    GuiControl, MyWindow:, ElapsedTimeID, % ElapsedTime
    return ElapsedTime
}


GemFarm() 
{  
    OpenProcess()
    UserID := ReadUserID(1)
    UserHash := ReadUserHash(1)
    advtoload := ReadCurrentObjID(0)
    
    GetUserDetails()
    ReadMonstersSpawned:= ReadMonstersSpawned()
    GuiControl, MyWindow:, advtoloadID, % advtoload
    GuiControl, MyWindow:, ReadMonstersSpawnedID, % ReadMonstersSpawned

    gPrevLevelTime := A_TickCount

    loop 
    {
        GuiControl, MyWindow:, gLoopID, Main `Loop
        gLevel_Number := ReadCurrentZone(1)
        DirectedInput("q")
        if (gLevel_Number = 1)
        {
            DirectedInput("g")
            DirectedInput("g")
        }
        else if (gLevel_Number > 1 and gLevel_Number < gAreaLow)
        {
            ToggleAutoProgress( 1 )
        }
        else if (gLevel_Number > gAreaLow)
        {
            FinishZone()
            LoadingZoneREV()
        }
        else
        {
            FinishZone()
            LoadingZoneREV()
            
        }

        UpdateStatTimers()
    }
}

DirectedInput(s) 
{
    ControlFocus,, ahk_exe IdleDragons.exe
    ControlSend,, {Blind}%s%, ahk_exe IdleDragons.exe
    Sleep, %ScriptSpeed%
}

;parameter should be 0 or 1, for off or on
ToggleAutoProgress( toggleOn := 1 )
{
    if ( ReadAutoProgressToggled( 3 ) != toggleOn )
    {
        DirectedInput( "{g}" )
    }
    return
}


