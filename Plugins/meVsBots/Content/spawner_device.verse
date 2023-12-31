
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }


# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
spawner_device := class(creative_device):

    @editable
        bomb : explosive_device = explosive_device{} 
    @editable
        SwitchDisableBuildsReset : switch_device = switch_device{} 
    @editable
        SwitchEnableSpawner : switch_device = switch_device{} 
    @editable
        ButtonUpLimitSpawn : button_device = button_device{} 
    @editable
        ButtonDownLimitSpawn : button_device = button_device{} 
    @editable
        guards : guard_spawner_device = guard_spawner_device{} 

    var spawnMax : int = 2
    var spawnValue : int = 0
    var guardsKilled : int = 0
    var switchIsOn : logic = false
    var isDisableBuildReset : logic = false
        
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        ButtonUpLimitSpawn.InteractedWithEvent.Subscribe(OnButtonUpLimitSpawn)
        ButtonDownLimitSpawn.InteractedWithEvent.Subscribe(OnButtonDownLimitSpawn)
        guards.EliminatedEvent.Subscribe(OnGuardEliminated)
        SwitchEnableSpawner.TurnedOnEvent.Subscribe(OnSwitchIsOn)
        SwitchEnableSpawner.TurnedOffEvent.Subscribe(OnSwitchIsOff)
        SwitchDisableBuildsReset.TurnedOnEvent.Subscribe(OnSwitchDisableBuildResetIsOn)
        SwitchDisableBuildsReset.TurnedOffEvent.Subscribe(OnSwitchDisableBuildResetIsOff)

        loop:
            if (switchIsOn = true):
                Spawn()
                Print("switchIsOn is true")
            else:
                Print("switchIsOn is false")
            Sleep(1.0)

    OnButtonUpLimitSpawn(Player:agent):void=
        set spawnMax += 1
        Print("maxSpawn {spawnMax}")

    OnButtonDownLimitSpawn(Player:agent):void=
        set spawnMax -= 1
        guards.Despawn()
        set spawnValue = 0
        Print("maxSpawn {spawnMax}")
        
    Spawn():void=
        Print("{spawnValue} < {spawnMax}")
        if (spawnValue < spawnMax):
            set spawnValue += 1
            guards.Spawn()
            
    OnGuardEliminated(Result:device_ai_interaction_result) : void=
        set guardsKilled += 1

        if (guardsKilled >= spawnMax):
            set spawnValue = 0
            set guardsKilled = 0
            
            if (isDisableBuildReset = false):
                AllPlayers: []player = Self.GetPlayspace().GetPlayers()
                if (FirstPlayer : player = AllPlayers[0]):
                    bomb.Reset()
                    bomb.Explode(FirstPlayer)

    OnSwitchIsOn(Player:agent) : void=
        Print("switch is on")
        set switchIsOn = true
    
    OnSwitchIsOff(Player:agent) : void=
        Print("switch is off")
        guards.Despawn()
        set switchIsOn = false
        set spawnValue = 0
        set guardsKilled = 0

    OnSwitchDisableBuildResetIsOn(Player:agent) : void=
        Print("switch is on")
        set isDisableBuildReset = true
    OnSwitchDisableBuildResetIsOff(Player:agent) : void=
        Print("switch is off")
        set isDisableBuildReset = false