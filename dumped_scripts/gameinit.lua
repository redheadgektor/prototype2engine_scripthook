-- ============================================
-- ИНИЦИАЛИЗАЦИЯ ИГРЫ
-- ============================================

-- Создание таблицы gameflowData
local function initGameflowData()
    gameflowData = {}
    gameflowData.missionInfo = {}
end

initGameflowData()

-- Пустая функция (заглушка)
local function emptyFunction()
    -- Ничего не делает
end

emptyFunction()

-- ============================================
-- СТАТЕМАШИНА GAMELINK
-- ============================================

local function initGameLinkStatemachine()
    GameLinkStatemachineData = {}
    
    function GameLinkStatemachineData:getData()
        return GameLinkStatemachineData
    end
    
    gamelink_GetStatemachineData = GameLinkStatemachineData.getData
    
    MAX_TRANSITION_HISTORY = 10
    
    if RAD_WIN32 then
        MAX_DEAD_STATEMACHINES = 20
    else
        MAX_DEAD_STATEMACHINES = 5
    end
end

initGameLinkStatemachine()

-- ============================================
-- ВОЗДУШНЫЕ МОСТЫ (AIR BRIDGES)
-- ============================================

local function registerAirBridges()
    local airBridges = {}
    
    -- Зеленая зона - Северо-восток
    airBridges[#airBridges + 1] = {
        staticID = "gz_ab_01",
        locationID = ZoneId.Green,
        data = {
            zoneId = ZoneId.Green,
            title = "$AirBridge_Green_Zone_Northeast_Title",
            description = "$AirBridge_Green_Zone_Northeast_Desc",
            addressPath = "Root|AirBridges|green|structure_green_blackwatch_275",
            position = address_GetPosition(address_GetAddressByPath("Root|AirBridges|green|structure_green_blackwatch_275")),
            structure = "structure_green_group001"
        }
    }
    
    -- Зеленая зона - Юго-запад
    airBridges[#airBridges + 1] = {
        staticID = "gz_ab_02",
        locationID = ZoneId.Green,
        data = {
            zoneId = ZoneId.Green,
            title = "$AirBridge_Green_Zone_Southwest_Title",
            description = "$AirBridgeInfoBox_Tutorial_TravelHere",
            addressPath = "Root|AirBridges|green|structure_green_military_213",
            position = address_GetPosition(address_GetAddressByPath("Root|AirBridges|green|structure_green_military_213")),
            structure = "structure_green_group002"
        }
    }
    
    -- Желтая зона - Запад
    airBridges[#airBridges + 1] = {
        staticID = "yz_ab_01",
        locationID = ZoneId.Yellow,
        data = {
            zoneId = ZoneId.Yellow,
            title = "$AirBridge_Yellow_Zone_West_Title",
            description = "$AirBridge_Yellow_Zone_West_Desc",
            addressPath = "Root|AirBridges|yellow|structure_yellow_blackwatch_154",
            position = address_GetPosition(address_GetAddressByPath("Root|AirBridges|yellow|structure_yellow_blackwatch_154")),
            structure = "structure_yellow_group002"
        }
    }
    
    -- Желтая зона - Север
    airBridges[#airBridges + 1] = {
        staticID = "yz_ab_02",
        locationID = ZoneId.Yellow,
        data = {
            zoneId = ZoneId.Yellow,
            title = "$AirBridge_Yellow_Zone_North_Title",
            description = "$AirBridgeInfoBox_Tutorial_TravelThere",
            addressPath = "Root|AirBridges|yellow|structure_yellow_military_245",
            position = address_GetPosition(address_GetAddressByPath("Root|AirBridges|yellow|structure_yellow_military_245")),
            structure = "structure_yellow_group001"
        }
    }
    
    -- Красная зона - Запад
    airBridges[#airBridges + 1] = {
        staticID = "rz_ab_01",
        locationID = ZoneId.Red,
        data = {
            zoneId = ZoneId.Red,
            title = "$AirBridge_Red_Zone_West_Title",
            description = "$AirBridge_Red_Zone_West_Desc",
            addressPath = "Root|AirBridges|red|structure_red_blackwatch_253",
            position = address_GetPosition(address_GetAddressByPath("Root|AirBridges|red|structure_red_blackwatch_253")),
            structure = "structure_red_group003"
        }
    }
    
    -- Красная зона - Юг
    airBridges[#airBridges + 1] = {
        staticID = "rz_ab_02",
        locationID = ZoneId.Red,
        data = {
            zoneId = ZoneId.Red,
            title = "$AirBridge_Red_Zone_South_Title",
            description = "$AirBridge_Red_Zone_South_Desc",
            addressPath = "Root|AirBridges|red|structure_red_blackwatch_94",
            position = address_GetPosition(address_GetAddressByPath("Root|AirBridges|red|structure_red_blackwatch_94")),
            structure = "structure_red_group006"
        }
    }
    
    BlackNetData.mms_AirBridgeData = airBridges
    
    -- Добавляем ID каждому мосту
    for index, bridge in ipairs(airBridges) do
        bridge.data.id = index
    end
end

registerAirBridges()

-- ============================================
-- НАБОРЫ КОЛЛЕКЦИОНИРУЕМЫХ ПРЕДМЕТОВ
-- ============================================

local function registerCollectibleSets()
    mms_CollectibleSetData = {}
    
    mms_CollectibleSetData[WorldCollectibleType.HuntTarget] = BlackNetData.mms_HuntTargetSets
    mms_CollectibleSetData[WorldCollectibleType.BlackBox] = BlackNetData.mms_BlackBoxSets
    mms_CollectibleSetData[WorldCollectibleType.Lair] = BlackNetData.mms_LairSets
    mms_CollectibleSetData[WorldCollectibleType.DeathSquad] = BlackNetData.mms_DeathSquadSets
    mms_CollectibleSetData[WorldCollectibleType.Event] = BlackNetData.mms_EventSets
end

registerCollectibleSets()

-- ============================================
-- ДАННЫЕ КОЛЛЕКЦИОНИРУЕМЫХ ПРЕДМЕТОВ
-- ============================================

local function registerCollectibleData()
    mms_CollectibleData = {}
    
    -- === Охотничьи цели ===
    mms_CollectibleData[WorldCollectibleType.HuntTarget] = {
        rootPath = mms_HuntTargetPositionRoot,
        collectibles = BlackNetData.mms_HuntTargetData,
        functions = {
            getStatus = mms_CollectibleGetHuntTargetStatusInternal,
            setStatus = mms_CollectibleUpdateStatusInternal,
            unlock = mms_CollectibleUnlockInternal
        }
    }
    
    -- === Черные ящики ===
    mms_CollectibleData[WorldCollectibleType.BlackBox] = {
        rootPath = "Root|OpenWorld|BlackBoxes",
        collectibles = BlackNetData.mms_BlackBoxData,
        functions = {
            getStatus = mms_CollectibleGetStatusInternal,
            setStatus = mms_CollectibleUpdateStatusInternal,
            unlock = mms_CollectibleUnlockInternal,
            lock = mms_CollectibleLockInternal
        }
    }
    
    -- === Логова ===
    mms_CollectibleData[WorldCollectibleType.Lair] = {
        rootPath = "Root|OpenWorld|Lair",
        collectibles = BlackNetData.mms_LairData,
        functions = {
            getStatus = mms_CollectibleGetLairStatusInternal,
            setStatus = mms_CollectibleUpdateStatusInternal,
            unlock = mms_CollectibleUnlockInternal,
            lock = mms_CollectibleLockInternal
        }
    }
    
    -- === Эскадроны смерти ===
    mms_CollectibleData[WorldCollectibleType.DeathSquad] = {
        rootPath = "Root|OpenWorld|DeathSquads",
        collectibles = BlackNetData.mms_DeathSquadData,
        functions = {
            getStatus = mms_CollectibleGetStatusInternal,
            setStatus = mms_CollectibleUpdateStatusInternal,
            unlock = mms_CollectibleUnlockInternal,
            lock = mms_CollectibleLockInternal
        }
    }
    
    -- === Воздушные мосты ===
    mms_CollectibleData[WorldCollectibleType.AirBridge] = {
        rootPath = "Root|AirBridges",
        collectibles = BlackNetData.mms_AirBridgeData,
        functions = {
            getStatus = mms_CollectibleGetStatusInternal,
            setStatus = mms_CollectibleUpdateStatusInternal,
            unlock = mms_CollectibleUnlockInternal,
            lock = mms_CollectibleLockInternal
        }
    }
    
    -- === События ===
    mms_CollectibleData[WorldCollectibleType.Event] = {
        rootPath = "Root|Missions",
        collectibles = BlackNetData.mms_EventData,
        functions = {
            getStatus = mms_CollectibleGetStatusInternal,
            setStatus = mms_CollectibleUpdateStatusInternal,
            unlock = mms_UnlockEvent,
            lock = mms_CollectibleLockInternal,
            buildAddressPath = mms_BuildEventAddressPath
        }
    }
    
    -- Обрабатываем каждый тип коллекционируемых предметов
    for collectibleType, data in pairs(mms_CollectibleData) do
        data.total = 0
        
        for index, collectible in pairs(data.collectibles) do
            -- Назначаем функции
            if data.functions then
                collectible.functions = data.functions
            end
            
            -- Строим путь к адресу
            local addressPath
            if collectible.functions and collectible.functions.buildAddressPath then
                addressPath = collectible.functions.buildAddressPath(data.rootPath, collectible)
            else
                addressPath = data.rootPath .. "|" .. 
                              mms_ZonePathPrefix[collectible.locationID] .. "|" .. 
                              collectible.staticID
            end
            
            -- Находим адрес
            collectible.addressHandle = address_FindAddressByPath(addressPath)
            collectible.type = collectibleType
            collectible.gameDBIndex = data.total
            data.total = data.total + 1
            
            -- Индексируем
            mms_IndexedCollectibleData[collectible.staticID] = collectible
        end
    end
    
    -- Назначаем функции интерфейса для наборов
    for collectibleType, sets in pairs(mms_CollectibleSetData) do
        for _, setData in ipairs(sets) do
            setData.interfaceFunctions = mms_CollectibleSetFunctions[collectibleType]
        end
    end
end

registerCollectibleData()

-- ============================================
-- ФУНКЦИИ УПРАВЛЕНИЯ СОХРАНЕНИЯМИ
-- ============================================

-- Отбрасываем ключи разблокировки, которые не должны сохраняться
function mms_DiscardUnlockKeysThatShouldNotBeSaved()
    for missionName, config in pairs(mm_MissionFlowConfigs) do
        if config.missionInfo and not config.missionInfo.isSaved then
            mm_CancelUnlockKey(config.MISSION_UNLOCK_KEY)
        end
    end
end

-- Исправляем сохранения миссий локаций
function mms_FixLocationMissionSaves()
    local lastMissionStarted = db_GetString(DB_PROTO_SAVE_LASTMISSIONSTARTED, 0, 0)
    
    for missionName, config in pairs(mm_MissionFlowConfigs) do
        if mm_HasUnlockKeyBeenReceived(config.MISSION_UNLOCK_KEY) then
            if not mms_IsMissionCompleted(config.MISSION_UNLOCK_KEY) then
                local preMission = config.missionInfo and config.missionInfo.preMission
                if preMission then
                    local preMissionConfig = mm_MissionFlowConfigs[preMission]
                    if preMissionConfig then
                        -- Отменяем ключ разблокировки
                        mm_CancelUnlockKey(config.MISSION_UNLOCK_KEY)
                        
                        -- Проверяем, завершена ли предварительная миссия
                        local preMissionKey = preMissionConfig.MISSION_UNLOCK_KEY
                        if mms_IsMissionCompleted(preMissionKey) then
                            mm_DebugResetMission(preMissionKey)
                        end
                        
                        -- Разблокируем предварительную миссию
                        mms_UnlockMission(preMissionKey, false)
                        
                        -- Обновляем последнюю запущенную миссию
                        if lastMissionStarted == config.MISSION_UNLOCK_KEY then
                            lastMissionStarted = preMissionKey
                            db_SetString(DB_PROTO_SAVE_LASTMISSIONSTARTED, 0, lastMissionStarted, 0)
                            
                            -- Сохраняем позицию спавна
                            local position, facing = mms_GetStartPositionForMission(preMissionKey)
                            if facing then
                                db_SetFloat(DB_PROTO_SAVE_SPAWNPOSITION, 0, position.x, 0)
                                db_SetFloat(DB_PROTO_SAVE_SPAWNPOSITION, 0, position.y, 1)
                                db_SetFloat(DB_PROTO_SAVE_SPAWNPOSITION, 0, position.z, 2)
                                db_SetFloat(DB_PROTO_SAVE_SPAWNFACING, 0, facing.x, 0)
                                db_SetFloat(DB_PROTO_SAVE_SPAWNFACING, 0, facing.y, 1)
                                db_SetFloat(DB_PROTO_SAVE_SPAWNFACING, 0, facing.z, 2)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Откладываем разблокировку сохраненных сюжетных миссий
function mms_DelayUnlockOfSavedStoryMissions()
    local delayedMissions = {}
    
    for missionName, config in pairs(mm_MissionFlowConfigs) do
        if mm_HasUnlockKeyBeenReceived(config.MISSION_UNLOCK_KEY) then
            if not mms_IsMissionCompleted(config.MISSION_UNLOCK_KEY) then
                if config.missionInfo and config.missionInfo.isStoryMission == true then
                    table.insert(delayedMissions, config.MISSION_NAME)
                    mm_CancelUnlockKey(config.MISSION_UNLOCK_KEY)
                end
            end
        end
    end
    
    return delayedMissions
end

-- Делаем мутации доступными для New Game+
function mms_MakeMutationsAvailableForNewGamePlus()
    unlockable_SetIsAvailableByUnlockableType(0, UnlockableType.MutationOffensive, true)
    unlockable_SetIsAvailableByUnlockableType(0, UnlockableType.MutationLoco, true)
    unlockable_SetIsAvailableByUnlockableType(0, UnlockableType.MutationDefensive, true)
    unlockable_SetIsAvailableByUnlockableType(0, UnlockableType.MutationHunting, true)
    unlockable_SetIsAvailableByUnlockableType(0, UnlockableType.MutationWildCard, true)
end

-- Запуск New Game+
function mms_StartNewGamePlus()
    -- Отключаем способности
    local abilities = {
        Unlockable.JackHelicopter,
        Unlockable.JackArmouredVehicle,
        Unlockable.TaintedBloodToxCloudEnabled,
        Unlockable.Opsticky_Display_Alerts,
        Unlockable.Disguise,
        Unlockable.Hunting
    }
    
    for _, ability in ipairs(abilities) do
        unlockable_SetIsAvailable(0, ability, false)
        unlockable_SetIsAcquired(0, ability, false)
        unlockable_SetIsActivated(0, ability, false)
    end
    
    -- Делаем мутации доступными
    mms_MakeMutationsAvailableForNewGamePlus()
end

-- ============================================
-- ПОЛУЧЕНИЕ ВРЕМЕНИ СУТОК ИЗ АДРЕСА СПАВНА
-- ============================================

function mms_GetTimeOfDayFromPlayerSpawnAddress(address)
    local timeOfDayMap = {
        [AddressData.PlayerSpawn.TimeOfDay.YellowZone_Dawn] = TOD_YELLOWZONE_DAWN,
        [AddressData.PlayerSpawn.TimeOfDay.YellowZone_Dawn_Rain] = TOD_YELLOWZONE_DAWN_RAIN,
        [AddressData.PlayerSpawn.TimeOfDay.YellowZone_Day] = TOD_YELLOWZONE_DAY,
        [AddressData.PlayerSpawn.TimeOfDay.YellowZone_Night] = TOD_YELLOWZONE_NIGHT,
        [AddressData.PlayerSpawn.TimeOfDay.YellowZone_Night_Rain] = TOD_YELLOWZONE_NIGHT_RAIN,
        [AddressData.PlayerSpawn.TimeOfDay.GreenZone_Dawn] = TOD_GREENZONE_DAWN,
        [AddressData.PlayerSpawn.TimeOfDay.GreenZone_Day] = TOD_GREENZONE_DAY,
        [AddressData.PlayerSpawn.TimeOfDay.GreenZone_Day_Rain] = TOD_GREENZONE_DAY_RAIN,
        [AddressData.PlayerSpawn.TimeOfDay.GreenZone_Night] = TOD_GREENZONE_NIGHT,
        [AddressData.PlayerSpawn.TimeOfDay.GreenZone_Night_Rain] = TOD_GREENZONE_NIGHT_RAIN,
        [AddressData.PlayerSpawn.TimeOfDay.RedZone_Dawn] = TOD_REDZONE_DAWN,
        [AddressData.PlayerSpawn.TimeOfDay.RedZone_Day] = TOD_REDZONE_DAY,
        [AddressData.PlayerSpawn.TimeOfDay.RedZone_Night] = TOD_REDZONE_NIGHT,
        [AddressData.PlayerSpawn.TimeOfDay.RedZone_Night_Rain] = TOD_REDZONE_NIGHT_RAIN
    }
    
    local timeOfDayParam = address_GetCustomData(address, AddressParam.PlayerSpawn.TimeOfDay)
    return timeOfDayMap[timeOfDayParam]
end

-- ============================================
-- ПОИСК БЛИЖАЙШЕЙ ПОЗИЦИИ СПАВНА
-- ============================================

function mms_GetClosestStartPosition(missionName)
    local config = mm_MissionFlowConfigs[missionName]
    local location = config.pipData.location
    
    local position, facing = mms_GetStartPositionForMission(missionName)
    local timeOfDay = config.missionInfo.timeOfDay
    
    local defaultPosition = Vector(0, 0, 0)
    defaultPosition.x = db_GetFloat(DB_PROTO_SAVE_SPAWNPOSITION, 0, 0)
    defaultPosition.y = db_GetFloat(DB_PROTO_SAVE_SPAWNPOSITION, 0, 1)
    defaultPosition.z = db_GetFloat(DB_PROTO_SAVE_SPAWNPOSITION, 0, 2)
    
    -- Определяем зону
    local zonePath = ""
    if location == "green_zone" then
        zonePath = "green"
    elseif location == "yellow_zone" then
        zonePath = "yellow"
    elseif location == "red_zone" then
        zonePath = "red"
    end
    
    -- Ищем ближайший спавн
    local searchParams = {
        searchDepth = 0,
        searchCondition = AddressSearchCondition.Closest,
        origin = defaultPosition,
        type = AddressType.PlayerSpawn,
        maxResults = 1,
        rootPath = "LocationStartPositions|" .. zonePath
    }
    
    local foundAddresses = address_FindAddressList(searchParams)
    if foundAddresses and not table.isempty(foundAddresses) then
        position = address_GetPosition(foundAddresses[1])
        facing = address_GetOrientation(foundAddresses[1])
        timeOfDay = mms_GetTimeOfDayFromPlayerSpawnAddress(foundAddresses[1])
    end
    
    return position, facing, timeOfDay
end

-- ============================================
-- ЗАПУСК ИГРЫ
-- ============================================

function mms_GameStartUp(showLoadingScreen)
    local transitionData = {
        waitForDetailCells = true,
        suppressFadeToBlack = true,
        isLoadingScreenActive = showLoadingScreen or false,
        onCompleteCallback = function()
            if fe_GetEngineOption("MissionTest") then
                mms_DebugStartMissionAutoTester(mms_MainMissionAutoTestSettings)
            elseif fe_GetEngineOption("CharacterTest") then
                mms_DebugStartMissionAutoTester(mms_MainCharacterAutoTestSettings)
            elseif fe_GetEngineOption("FEScreenTest") then
                fe_RunFETest()
            elseif fe_GetEngineOption("FramerateTest") then
                mms_DebugStartFramerateTester(mms_FramerateSceneTestSettings)
            elseif fe_GetEngineOption("FramerateIntersectionTest") then
                mms_DebugStartFramerateTester(mms_FramerateIntersectionTestSettings)
            end
        end
    }
    
    mm_GameStartupMissionPreload = nil
    
    -- Обработка режима "comicon"
    if opt_GetKey("comicon") then
        local mission = "story_c3"
        local position, facing = mms_GetStartPositionForMission(mission)
        
        db_SetString(DB_PROTO_SAVE_LASTMISSIONSTARTED, 0, mission, 0)
        db_SetFloat(DB_PROTO_SAVE_SPAWNPOSITION, 0, position.x, 0)
        db_SetFloat(DB_PROTO_SAVE_SPAWNPOSITION, 0, position.y, 1)
        db_SetFloat(DB_PROTO_SAVE_SPAWNPOSITION, 0, position.z, 2)
        db_SetFloat(DB_PROTO_SAVE_SPAWNFACING, 0, facing.x, 0)
        db_SetFloat(DB_PROTO_SAVE_SPAWNFACING, 0, facing.y, 1)
        db_SetFloat(DB_PROTO_SAVE_SPAWNFACING, 0, facing.z, 2)
    end
    
    local startType = db_GetString(DB_PROTO_VOLATILE_STARTTYPE, 0, 0)
    local lastMissionStarted = db_GetString(DB_PROTO_SAVE_LASTMISSIONSTARTED, 0, 0)
    local goToMainMenu = db_GetInt(DB_PROTO_VOLATILE_GOTO_MAINMENU, 0, 0) == 1
    local defaultTransform = nil
    
    -- Режим разработчика (выбор уровня)
    if startType == STARTTYPE_DEVSELECT then
        local level = opt_GetKeyValue("level")
        if level then
            transitionData.toMissionStart = level
            transitionData.startMissions = { level }
            transitionData.setTimeOfDay = mm_MissionFlowConfigs[level].missionInfo.timeOfDay
            transitionData.debugStart = true
            lastMissionStarted = level
            db_SetString(DB_PROTO_SAVE_LASTMISSIONSTARTED, 0, level, 0)
        end
    
    -- Переход в главное меню
    elseif goToMainMenu then
        cprint("mm", "mms_GameStartUp lastMissionStarted = " .. tostring(lastMissionStarted))
        
        local mission = lastMissionStarted
        if mission == "" then
            mission = NEW_GAME_START_MISSION
        end
        
        local config = mm_MissionFlowConfigs[mission]
        transitionData.requiredLocation = config.pipData.location
        
        if mission == NEW_GAME_START_MISSION then
            local position, facing = mms_GetStartPositionForMission(mission)
            transitionData.orientation = facing
            transitionData.position = position
            transitionData.setTimeOfDay = config.missionInfo.timeOfDay
        else
            local position, facing, timeOfDay = mms_GetClosestStartPosition(mission)
            transitionData.setTimeOfDay = timeOfDay
            transitionData.orientation = facing
            transitionData.position = position
        end
        
        if mission == NEW_GAME_START_MISSION then
            mm_GameStartupMissionPreload = mission
            transitionData.preloadMission = mission
            if config.initialTransitionData then
                defaultTransform = config.initialTransitionData.defaultTransform
            end
        end
        
        transitionData.suppressFadeFromBlack = true
        transitionData.onTransitionCallback = fes_StartInGameMainMenuCamera
        transitionData.onCompleteCallback = fes_ActivateInGameMainMenu
    
    -- Продолжение игры
    elseif lastMissionStarted ~= "" then
        local config = mm_MissionFlowConfigs[lastMissionStarted]
        transitionData.requiredLocation = config.pipData.location
        
        if mms_IsMissionAutoStart(lastMissionStarted) and not mms_IsMissionCompleted(lastMissionStarted) then
            if config.missionInfo.isSaved == true then
                transitionData.toMissionStart = lastMissionStarted
                transitionData.startMissions = { lastMissionStarted }
                transitionData.setTimeOfDay = config.missionInfo.timeOfDay
            end
        else
            local position, facing, timeOfDay = mms_GetClosestStartPosition(lastMissionStarted)
            transitionData.setTimeOfDay = timeOfDay
            transitionData.orientation = facing
            transitionData.position = position
            transitionData.completionEvent = "CheckForPendingPlayerAwards"
        end
    
    -- Новая игра
    else
        transitionData.toMissionStart = NEW_GAME_START_MISSION
        transitionData.startMissions = { NEW_GAME_START_MISSION }
    end
    
    -- Спавн игрока
    local mass = 0
    if not go_IsValid(PLAYER) then
        if transitionData.position then
            mms_SpawnPlayer("Player", "PrototypeTemplate", transitionData.position, transitionData.orientation, mass, defaultTransform)
        else
            local position, facing = mms_GetStartPositionForMission(transitionData.toMissionStart)
            mms_SpawnPlayer("Player", "PrototypeTemplate", position, facing, mass, defaultTransform)
        end
    end
    
    -- Разблокировка стандартных предметов
    mms_UnlockDefaultUnlockables()
    
    -- Отложенные сюжетные миссии
    local delayedMissions = mms_DelayUnlockOfSavedStoryMissions()
    transitionData.unlockMissions = delayedMissions
    
    -- Установка времени суток
    if transitionData.setTimeOfDay then
        tod_SetTimeOfDay(transitionData.setTimeOfDay)
        transitionData.setTimeOfDay = nil
    end
    
    -- Запуск перехода
    mms_StartTransition(transitionData)
end

-- ============================================
-- ГЛАВНАЯ ФУНКЦИЯ ИНИЦИАЛИЗАЦИИ
-- ============================================

local function main()
    -- Проверка режима тестирования пакетов
    if fe_GetEngineOption("PackageTest") then
        return
    end
    
    -- Новая игра
    NEW_GAME_START_MISSION = "story_intro1"
    
    -- Проверка наличия сохранения
    local lastMissionStarted = db_GetString(DB_PROTO_SAVE_LASTMISSIONSTARTED, 0, 0)
    if lastMissionStarted == "" then
        if db_GetInt(DB_PROTO_VOLATILE_GOTO_MAINMENU, 0, 0) == 0 then
            if mms_IsNewGamePlus() then
                mms_StartNewGamePlus()
            end
        end
    end
    
    -- Очистка временных разблокировок
    mm_ClearCollectibleTempUnlocked()
    
    -- Обработка сохранений
    mms_DiscardUnlockKeysThatShouldNotBeSaved()
    mms_FixLocationMissionSaves()
    
    -- Настройка достижений
    ach_EnableAllAchievements(false)
    mms_UnlockMatchActivatedToAcquired()
    ach_EnableAllAchievements(true)
    
    -- Пост-обработка ключей
    mms_PostAutoUnlockKeys()
    
    -- Запуск игры
    mms_GameStartUp(true)
    
    -- Читы
    cheats_OnGameStarting()
    
    -- Режим отладки (не финальная версия)
    if fe_GetBuildType() ~= "RAD_FINAL" then
        if fe_GetEngineOption("PlayerInvincible") then
            debug_SetPlayerInvincible(true)
        end
    end
    
    -- Телеметрия
    local evoState = ep_GetCharacterEvolutionState()
    telemetry_LogData("player/evolution level", evoState.characterEvolutionThreshold, telemetry_Final)
end

main()

-- ============================================
-- ОТЛАДОЧНЫЕ КНОПКИ ДЛЯ ПАКЕТОВ
-- ============================================

local function initDebugButtons()
    local debug = _G.Game.debug
    debug.PKGButtons = debug.PKGButtons or {}
    debug.PKGButtons.state = debug.PKGButtons.state or false
    debug.PKGButtons.data = debug.PKGButtons.data or {}
    
    -- Функция отображения кнопок пакетов
    function debug_PackageButtonDisplay(show)
        local data = _G.Game.debug.PKGButtons.data
        
        if show then
            for _, button in pairs(data) do
                ToolInterface_CreateCustomButton(button.label, button.label, button.script)
            end
        else
            for _, button in pairs(data) do
                ToolInterface_DestroyCustomButton(button.label)
            end
        end
    end
    
    -- Переключение отображения кнопок
    function debug_TogglePackageButtonDisplay()
        local pkgButtons = _G.Game.debug.PKGButtons
        pkgButtons.state = not pkgButtons.state
        debug_PackageButtonDisplay(pkgButtons.state)
    end
    
    -- Добавление кнопки пакета
    function debug_AddPKGButton(label, script)
        local data = _G.Game.debug.PKGButtons.data
        local exists = false
        local needsUpdate = false
        
        for _, button in pairs(data) do
            if button.label == label then
                exists = true
                if button.script ~= script then
                    needsUpdate = true
                end
                break
            end
        end
        
        if not exists then
            table.insert(data, { label = label, script = script })
            needsUpdate = true
        end
        
        if needsUpdate and _G.Game.debug.PKGButtons.state then
            debug_PackageButtonDisplay(false)
            debug_PackageButtonDisplay(true)
        end
    end
    
    -- Удаление кнопки пакета
    function debug_RemoveDebugButtons(label)
        local data = _G.Game.debug.PKGButtons.data
        local index = nil
        
        for i, button in ipairs(data) do
            if button.label == label then
                index = i
                break
            end
        end
        
        if index then
            local removed = table.remove(data, index)
            if _G.Game.debug.PKGButtons.state then
                ToolInterface_DestroyCustomButton(removed.label)
            end
        end
    end
    
    -- Создаем кнопку переключения
    ToolInterface_DestroyCustomButton("DBG_PACKAGE_LIST")
    ToolInterface_CreateCustomButton("DBG_PACKAGE_LIST", "PKGS", "debug_TogglePackageButtonDisplay()")
end

initDebugButtons()