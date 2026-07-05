local function initGlobalTables()
    mm_MissionFlowConfigs = {}
    mms_AmbientStreamGroups = {}
    _MetaMission = nil
end

initGlobalTables()

-- Добавление стандартных полей в таблицу конфига
function mms_AddStandardFieldsToConfigTable(config)
    local flowConfig = mm_MissionFlowConfigs[config.name]
    
    flowConfig.MISSION_NAME = config.name
    flowConfig.MISSION_UNLOCK_KEY = config.unlockKey
    flowConfig.MISSION_NAME_UID = UID(config.name)
    flowConfig.MISSION_MANAGEMENT_TYPE = config.type
    flowConfig.MISSION_OBJECT_TAG = config.name .. "_Object"
    flowConfig.DEBUG_START_POSITION = config.debugStartPosition
    flowConfig.DEBUG_START_ROTATION = config.debugStartRotation
    
    flowConfig.pipData = table.copy(mm_MissionTable[config.name])
    
    PreprocessOpenData(flowConfig)
    PreprocessActivationData(flowConfig)
    PreprocessPackageData(flowConfig)
    PreprocessCompletionData(flowConfig)
end

-- Предобработка открытых данных
function PreprocessOpenData(config)
    if not config.openData then
        config.openData = {}
    elseif config.openData.scopingTriggers then
        mms_MakeListASublist(config.openData, "scopingTriggers")
    end
end

-- Предобработка данных активации
function PreprocessActivationData(config)
    if not config.activationData then
        config.activationData = {}
    end
end

-- Предобработка данных пакетов
function PreprocessPackageData(config)
    local packageData = config.packageData
    
    if not packageData then
        packageData = {
            openList = { list = {} },
            activeList = { list = {} },
            activePreloadList = { list = {} },
            activeCharacterList = { list = {} }
        }
        config.packageData = packageData
    else
        mms_MakeListASublist(packageData, "openList")
        mms_MakeListASublist(packageData, "activeList")
        mms_MakeListASublist(packageData, "activePreloadList")
        packageData.activeCharacterList = table.copy(packageData.activeList)
        mms_MakeListASublist(packageData, "activeCharacterList")
        packageData.activeList.list = {}
    end
    
    -- Обработка фоновых миссий
    if config.MISSION_MANAGEMENT_TYPE == MissionType.Background then
        if config.pipData.location then
            if packageData.openStreamGroup or packageData.activeStreamGroup then
                mms_Error("", "Stream group definitions should not be supplied for 'background' missions")
            end
            
            local groupName = "locationBGM_" .. config.pipData.location
            local streamGroup = mm_StreamGroupDefs[groupName] or mm_StreamGroupDefs.locationBGM_default
            streamGroup.name = UID("locationMissionShared")
            packageData.openStreamGroup = streamGroup
            packageData.activeStreamGroup = streamGroup
        else
            mms_Error(config.MISSION_NAME, "Support for global background missions is incomplete")
        end
        
        -- Проверка списков
        if not table.isempty(packageData.openList.list) then
            mms_Error(config.MISSION_NAME, "'Background' mission cannot specify openList assets")
        end
        if not table.isempty(packageData.activeList.list) then
            mms_Error(config.MISSION_NAME, "'Background' mission cannot specify activeList assets")
        end
        if not table.isempty(packageData.activePreloadList.list) then
            mms_Error(config.MISSION_NAME, "'Background' mission cannot specify activePreloadList assets")
        end
    else
        -- Обычные миссии
        if not packageData.openStreamGroup then
            if config.pipData.tags and config.pipData.tags ~= "None" then
                for _, tag in pairs(config.pipData.tags) do
                    local tagGroup = mm_TagSetGroupDefs[tag]
                    if tagGroup then
                        packageData.openStreamGroup = tagGroup
                        break
                    end
                end
            end
            if not packageData.openStreamGroup then
                packageData.openStreamGroup = table.copy(mm_StreamGroupDefs.defaultMissionOpenGroup)
            end
        end
        
        packageData.openStreamGroup.name = UID(config.MISSION_NAME .. "_open")
        packageData.openStreamGroup.useHighMemory = packageData.openStreamGroup.useHighMemory or nil
        
        if packageData.activeStreamGroup == false then
            packageData.activeStreamGroup = packageData.openStreamGroup
            packageData.openStreamGroup.name = UID(config.MISSION_NAME .. "_shared")
        elseif not packageData.activeStreamGroup then
            packageData.activeStreamGroup = table.copy(mm_StreamGroupDefs.defaultMissionActiveGroup)
        end
        
        packageData.activeStreamGroup.name = UID(config.MISSION_NAME .. "_active")
        packageData.activeStreamGroup.useHighMemory = true
    end
    
    -- Назначение групп
    packageData.openList.groupDef = packageData.openStreamGroup
    packageData.activeList.groupDef = packageData.activeStreamGroup
    packageData.activePreloadList.groupDef = packageData.activeStreamGroup
    packageData.activeCharacterList.groupDef = packageData.activeStreamGroup
    
    -- Добавление стандартных списков
    table.insert(packageData.openList.list, config.MISSION_NAME .. "_open_props")
    table.insert(packageData.openList.list, config.MISSION_NAME .. "_open")
    table.insert(packageData.activePreloadList.list, config.MISSION_NAME .. "_active_props")
    table.insert(packageData.activeList.list, config.MISSION_NAME .. "_active")
    
    packageData.openPackages = {
        groupDef = packageData.openStreamGroup,
        list = { config.MISSION_NAME .. "_open_fig" }
    }
    
    packageData.activePackages = {
        groupDef = packageData.activeStreamGroup,
        list = { config.MISSION_NAME .. "_active_fig" }
    }
    
    packageData.pendingCount = 0
end

-- Предобработка данных завершения
function PreprocessCompletionData(config)
    if not config.completionData then
        config.completionData = {}
    end
    
    if config.completionData.onCompleteAllowReplay == nil then
        config.completionData.onCompleteAllowReplay = false
    end
    
    if config.completionData.onCompleteReplayDelay == nil then
        config.completionData.onCompleteReplayDelay = 0
    end
    
    if config.completionData.saveOnComplete == nil then
        config.completionData.saveOnComplete = true
    end
end

-- ============================================
-- 2. ЛОГОВА (LAIRS)
-- ============================================

-- gz_la_01
local function define_gz_la_01()
    local missionName = "gz_la_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            autoUnlock = false,
            leaveFadeActive = true
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 1792,
                ps3cpu = 512,
                ps3gpu = 968,
                useHighMemory = true
            },
            activeList = {
                PUSTULE_PACKAGE,
                INFECTED3_SLAMMER_PACKAGE,
                BRAWLER_EVADER_PACKAGE
            },
            ambientActiveList = {
                INFECTED1_1,
                INFECTED1_5
            }
        },
        missionInfo = {
            isAnInterior = true,
            timeOfDay = TOD_LAIR,
            isLair = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleMissionCompleted
        },
        audioData = {
            ambience = "lair_ambience"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_gz_la_01()

-- Вспомогательные функции для врагов
local function brawler_encounter()
    return {
        {
            name = "gz_la_02_enc_2_" .. util_GetUniqueName(),
            markerType = false,
            templates = {
                {
                    template = BRAWLER_TEMPLATE,
                    min = 1,
                    max = 2,
                    total = 9999,
                    delay = 25
                }
            }
        }
    }
end

local function pustule_encounter()
    return {
        {
            name = "gz_la_02_enc_2_" .. util_GetUniqueName(),
            markerType = Marker_Mission_Defeat,
            templates = {
                { template = PUSTULE_TEMPLATE }
            }
        }
    }
end

-- fsmConfigData для gz_la_02
local function define_fsmConfigData()
    local fsmData = {
        disableIntroAnim = true,
        destructibleWallSequence = nil,
        destructibleWall2 = "gz_la_02_wall2",
        destructibleWall3 = "gz_la_02_wall3",
        teleportOutAddress = "structure_green_group001|gz_la_02|accessLink_startPos",
        exitAddress = "Missions|gz_la_02|exit",
        lairEntranceAddressPath = "structure_green_group001|gz_la_02|lairEntrance_1",
        devastateAddress = "Missions|gz_la_02|devastate_cam|1",
        sequenceTable = {
            -- DefeatBlackwatch
            {
                type = LairSeq.DefeatBlackwatch,
                data = {
                    audioCallout = "gz_la_02_log_010",
                    framerVolume = "gz_la_02_FramerVolume",
                    useFramerVolume = false,
                    useFramerSpline = true,
                    useConsumable = true,
                    BWpositionSource = "Missions|gz_la_02|blackwatch_brawler_encounter",
                    BWtemplate1 = BLACKWATCH_TEMPLATE,
                    BWmin1 = 7,
                    BWmax1 = 7,
                    BWtotal1 = 7,
                    BWdefendArea1 = 3,
                    BWrootPath1 = "Missions|gz_la_02|blackwatch_brawler_encounter|bw",
                    BWmaxResults1 = 7,
                    BWtemplate2 = BLACKWATCH_SAW_TEMPLATE,
                    BWmin2 = 3,
                    BWmax2 = 3,
                    BWtotal2 = 3,
                    BWdefendArea2 = 3,
                    BWrootPath2 = "Missions|gz_la_02|blackwatch_brawler_encounter|saw",
                    BWmaxResults2 = 3,
                    BWtemplate3 = BLACKWATCH_ROCKET_TEMPLATE,
                    BWmin3 = 2,
                    BWmax3 = 2,
                    BWtotal3 = 2,
                    BWdefendArea3 = 3,
                    BWrootPath3 = "Missions|gz_la_02|blackwatch_brawler_encounter|rocket",
                    BWmaxResults3 = 2,
                    useEvolved = false,
                    useFramerCam = true,
                    posRelObjects = "Missions|gz_la_02|brawler_framercam|cam",
                    focusObjects = { "Missions|gz_la_02|brawler_framercam|focus" },
                    posRelObjectsSpline = "gz_la_02_position",
                    focusObjectsSpline = "gz_la_02_target",
                    framingHeights = { 30 },
                    shotTimes = { 0, 0, 0, 0 },
                    transitionTimes = { 3, 3, 3 }
                }
            },
            -- DestroyWall (стена 2)
            {
                type = LairSeq.DestroyWall,
                data = {
                    wallProp = "gz_la_02_wall2",
                    goTo = "Missions|gz_la_02|goto2"
                }
            },
            -- DestroyPustules
            {
                type = LairSeq.DestroyPustules,
                data = {
                    useFramerCam = false,
                    componentPaths = {
                        ["gz_la_02|pustule_field_hall1"] = { eventResponse = true }
                    },
                    structureDef = {
                        COMPONENTS = {
                            PUSTULE_FIELDS = {
                                pustule_field_hall1 = {
                                    COMPONENTS = {
                                        ENCOUNTERS = {
                                            pustules = {
                                                ENCOUNTER_SETUP = pustule_encounter(),
                                                SLAVE_TO = "pustule_field_hall1"
                                            }
                                        }
                                    },
                                    ENFORCED_BY = { "pustules" },
                                    PUSTULE_CONFIG = {
                                        markerProfile = Marker_Mission_Defeat,
                                        characterTemplates = { BRAWLER_TEMPLATE },
                                        maxPustuleEnemyCount = 1
                                    }
                                }
                            }
                        }
                    }
                }
            },
            -- DestroyWall (стена 3)
            {
                type = LairSeq.DestroyWall,
                data = {
                    wallProp = "gz_la_02_wall3",
                    goTo = "Missions|gz_la_02|goto3"
                }
            },
            -- DefeatDevolved
            {
                type = LairSeq.DefeatDevolved,
                data = {
                    useIdleFlavour = true,
                    idleVolume1 = "gz_la_02_FlavourVolume",
                    useConsumable = true,
                    template = INFECTED3_HAMMERER_TEMPLATE,
                    positionSource = "Missions|gz_la_02|brawler_encounter",
                    min = 2,
                    max = 2,
                    total = 2,
                    rootPath = "Missions|gz_la_02|brawler_encounter",
                    maxResults = 2,
                    useFramerCam = true,
                    posRelObjects = "Missions|gz_la_02|brawler_framercam2|cam",
                    focusObjects = { "Missions|gz_la_02|brawler_framercam2|focus" },
                    shotTimes = { 5 },
                    framingHeights = { 6 },
                    fightEvolved = false
                }
            }
        }
    }
    
    fsmConfigData = fsmData
end

define_fsmConfigData()

-- gz_la_02
local function define_gz_la_02()
    local missionName = "gz_la_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = { autoUnlock = false },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 2816,
                ps3cpu = 512,
                ps3gpu = 3016,
                useHighMemory = true
            },
            activeList = {
                PUSTULE_PACKAGE,
                INFECTED3_HAMMERER_PACKAGE
            },
            ambientActiveList = {
                INFECTED1_1,
                INFECTED1_5
            }
        },
        missionInfo = {
            isAnInterior = true,
            timeOfDay = TOD_LAIR,
            isLair = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleMissionCompleted
        },
        audioData = {
            ambience = "lair_ambience"
        },
        activeFSMData = {
            path = "//MissionTemplates/collectibles/Lair",
            params = fsmConfigData
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_gz_la_02()

-- gz_la_03
local function define_gz_la_03()
    local missionName = "gz_la_03"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = { autoUnlock = false },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 2816,
                ps3cpu = 512,
                ps3gpu = 3016,
                useHighMemory = true
            },
            activeList = {
                PUSTULE_PACKAGE,
                BRAWLER_EVADER_PACKAGE
            },
            ambientActiveList = {
                INFECTED1_1,
                INFECTED1_5
            }
        },
        missionInfo = {
            isAnInterior = true,
            timeOfDay = TOD_LAIR,
            isLair = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleMissionCompleted
        },
        audioData = {
            ambience = "lair_ambience"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_gz_la_03()

-- gz_la_04
local function define_gz_la_04()
    local missionName = "gz_la_04"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = { autoUnlock = false },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 2688,
                ps3cpu = 512,
                ps3gpu = 3016,
                useHighMemory = true
            },
            activeList = {
                PUSTULE_PACKAGE,
                EVOLVED_PACKAGE
            },
            ambientActiveList = {
                INFECTED1_1,
                INFECTED1_5
            }
        },
        missionInfo = {
            isAnInterior = true,
            timeOfDay = TOD_LAIR,
            isLair = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleMissionCompleted
        },
        audioData = {
            ambience = "lair_ambience"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_gz_la_04()

-- rz_la_02
local function define_rz_la_02()
    local missionName = "rz_la_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = { autoUnlock = false },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 64,
                ps3cpu = 64,
                ps3gpu = 0
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 1536,
                ps3cpu = 512,
                ps3gpu = 1280,
                useHighMemory = true
            },
            activeList = {
                PUSTULE_PACKAGE,
                EVOLVED_PACKAGE,
                SUPERSOLDIER_PACKAGE,
                BLACKWATCH_COMMANDER_FULL_V3_PACKAGE
            },
            ambientActiveList = {
                INFECTED1_1,
                INFECTED1_5
            }
        },
        missionInfo = {
            isAnInterior = true,
            timeOfDay = TOD_LAIR,
            isLair = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleMissionCompleted
        },
        audioData = {
            ambience = "lair_ambience"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_la_02()

-- rz_la_04
local function define_rz_la_04()
    local missionName = "rz_la_04"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = { autoUnlock = false },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 0
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 3840,
                ps3cpu = 512,
                ps3gpu = 3016,
                useHighMemory = true
            },
            activeList = {
                PUSTULE_PACKAGE,
                HYDRA_PACKAGE
            },
            ambientActiveList = {
                INFECTED1_1,
                INFECTED1_5
            }
        },
        missionInfo = {
            isAnInterior = true,
            timeOfDay = TOD_LAIR,
            isLair = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleMissionCompleted
        },
        audioData = {
            ambience = "lair_ambience"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_la_04()

-- rz_la_05
local function define_rz_la_05()
    local missionName = "rz_la_05"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = { autoUnlock = false },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 0
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 2816,
                ps3cpu = 512,
                ps3gpu = 3016,
                useHighMemory = true
            },
            activeList = {
                PUSTULE_PACKAGE,
                BRAWLER_EVADER_PACKAGE
            },
            ambientActiveList = {
                INFECTED1_1,
                INFECTED1_5
            }
        },
        missionInfo = {
            isAnInterior = true,
            timeOfDay = TOD_LAIR,
            isLair = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleMissionCompleted
        },
        audioData = {
            ambience = "lair_ambience"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_la_05()

-- rz_la_06
local function define_rz_la_06()
    local missionName = "rz_la_06"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = { autoUnlock = false },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 0
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 3840,
                ps3cpu = 512,
                ps3gpu = 3016,
                useHighMemory = true
            },
            activeList = {
                PUSTULE_PACKAGE,
                SUPERSOLDIER_PACKAGE,
                BRAWLER_EVADER_PACKAGE
            },
            ambientActiveList = {
                INFECTED1_1,
                INFECTED1_5
            }
        },
        missionInfo = {
            isAnInterior = true,
            timeOfDay = TOD_LAIR,
            isLair = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleMissionCompleted
        },
        audioData = {
            ambience = "lair_ambience"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_la_06()

-- yz_la_01
local function define_yz_la_01()
    local missionName = "yz_la_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = { autoUnlock = false },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 3840,
                ps3cpu = 512,
                ps3gpu = 3016,
                useHighMemory = true
            },
            activeList = { PUSTULE_PACKAGE },
            ambientActiveList = {
                INFECTED1_1,
                INFECTED1_5
            }
        },
        missionInfo = {
            isAnInterior = true,
            timeOfDay = TOD_LAIR,
            isLair = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleMissionCompleted
        },
        audioData = {
            ambience = "lair_ambience"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_la_01()

-- ============================================
-- 3. ЛОКАЦИИ (LOCATIONS)
-- ============================================

local function define_location(missionName, unlockKey)
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = unlockKey,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        openData = { neverActivate = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_location("location_green", "location_green")
define_location("location_red", "location_red")
define_location("location_yellow", "location_yellow")
define_location("location_green_empty", "location_green_empty")
define_location("location_red_empty", "location_red_empty")
define_location("location_yellow_empty", "location_yellow_empty")

-- ============================================
-- 4. МЕТА-МИССИИ (META MISSIONS)
-- ============================================

local function define_meta_mission(missionName)
    local config = {
        name = missionName,
        type = MissionType.Background,
        unlockKey = missionName,
        blockDebugSelection = true
    }
    
    mm_ConfigureMission(config)
    
    local location = missionName:match("meta_(.*)")
    mm_MissionFlowConfigs[missionName] = {
        openData = { autoUnlock = true },
        missionInfo = { isMeta = true },
        audioData = {
            ambience = "ambience_" .. location .. "zone",
            mix = "ingame_default",
            reverb = "radverb_street"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_meta_mission("meta_green")
define_meta_mission("meta_red")
define_meta_mission("meta_yellow")

-- ============================================
-- 5. СОБЫТИЯ (EVENTS) - RAMPAGE
-- ============================================

-- gz_ra_01
local function define_gz_ra_01()
    local missionName = "gz_ra_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "ra"
                    },
                    id = nil
                }
            },
            contentCalendarEventType = ContentCalendarEventType.Collateral,
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = {
                EVOLVED_PACKAGE,
                "bw_officer_full",
                "radnet_events"
            }
        },
        missionInfo = {
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_RA },
            timeOfDay = TOD_GREENZONE_NIGHT,
            isSaved = true,
            isEventMission = true,
            quitRespawnAddress = "Root|Missions|gz_ra_01"
        },
        audioData = { mix = "rampage" }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_gz_ra_01()

-- gz_rr_01
local function define_gz_rr_01()
    local missionName = "gz_rr_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "rr"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        missionInfo = {
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_RR },
            isSaved = true,
            isEventMission = true,
            quitRespawnAddress = "Root|Missions|gz_rr_01",
            timeOfDay = TOD_GREENZONE_NIGHT_RAIN
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { "radnet_events" }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_gz_rr_01()

-- gz_sp_01
local function define_gz_sp_01()
    local missionName = "gz_sp_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "sp"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { "radnet_events" }
        },
        missionInfo = {
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_SP },
            isSaved = true,
            isEventMission = true,
            quitRespawnAddress = "Root|Missions|gz_sp_01"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_gz_sp_01()

-- gz_sp_02
local function define_gz_sp_02()
    local missionName = "gz_sp_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "sp"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { "radnet_events" }
        },
        missionInfo = {
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_SP },
            isSaved = true,
            isEventMission = true,
            quitRespawnAddress = "Root|Missions|gz_sp_02"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_gz_sp_02()

-- rz_cr_01
local function define_rz_cr_01()
    local missionName = "rz_cr_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "cr"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        missionInfo = {
            timeOfDay = TOD_REDZONE_NIGHT_RAIN,
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_CR },
            isSaved = true,
            isEventMission = true,
            quitRespawnAddress = "Root|Missions|rz_cr_01"
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_cr_01()

-- rz_cr_02
local function define_rz_cr_02()
    local missionName = "rz_cr_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "cr"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        missionInfo = {
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_CR },
            timeOfDay = TOD_REDZONE_NIGHT,
            isSaved = true,
            isEventMission = true,
            quitRespawnAddress = "Root|Missions|rz_cr_02"
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_cr_02()

-- rz_ra_01
local function define_rz_ra_01()
    local missionName = "rz_ra_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "ra"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        missionInfo = {
            timeOfDay = TOD_REDZONE_NIGHT,
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_RA },
            isSaved = true,
            isEventMission = true,
            quitRespawnAddress = "Root|Missions|rz_ra_01"
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = {
                "radnet_events",
                SUPERSOLDIER_PACKAGE,
                INFECTED3_SLAMMER_PACKAGE
            }
        },
        audioData = { mix = "rampage" }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_ra_01()

-- rz_rr_01
local function define_rz_rr_01()
    local missionName = "rz_rr_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "rr"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        missionInfo = {
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_RR },
            isSaved = true,
            timeOfDay = TOD_REDZONE_NIGHT,
            isEventMission = true,
            quitRespawnAddress = "Root|Missions|rz_rr_01"
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { "radnet_events" }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_rr_01()

-- rz_rr_02
local function define_rz_rr_02()
    local missionName = "rz_rr_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "rr"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        missionInfo = {
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_RR },
            isSaved = true,
            timeOfDay = TOD_REDZONE_DAY,
            isEventMission = true,
            quitRespawnAddress = "Root|Missions|rz_rr_02"
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { "radnet_events" }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_rr_02()

-- rz_sp_01
local function define_rz_sp_01()
    local missionName = "rz_sp_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "sp"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        missionInfo = {
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_SP },
            timeOfDay = TOD_REDZONE_DAWN,
            isSaved = true,
            isEventMission = true,
            quitRespawnAddress = "Root|Missions|rz_sp_01"
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { "radnet_events" }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_sp_01()

-- ============================================
-- 5. СОБЫТИЯ (EVENTS) - COLLATERAL DAMAGE (ПРОДОЛЖЕНИЕ)
-- ============================================

-- yz_cd_01
local function define_yz_cd_01()
    local missionName = "yz_cd_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "cd"
                    },
                    id = nil
                }
            },
            contentCalendarEventType = ContentCalendarEventType.Collateral,
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        missionInfo = {
            isSaved = true,
            isEventMission = true,
            timeOfDay = TOD_YELLOWZONE_DAY,
            quitRespawnAddress = "Root|Missions|yz_cd_01",
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_CD }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { "radnet_events" }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_cd_01()

-- yz_cd_02
local function define_yz_cd_02()
    local missionName = "yz_cd_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "cd"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        missionInfo = {
            timeOfDay = TOD_YELLOWZONE_NIGHT,
            isSaved = true,
            isEventMission = true,
            quitRespawnAddress = "Root|Missions|yz_cd_02",
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_CD }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { "radnet_events" }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_cd_02()

-- yz_cd_03
local function define_yz_cd_03()
    local missionName = "yz_cd_03"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "cd"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        missionInfo = {
            isSaved = true,
            timeOfDay = TOD_YELLOWZONE_NIGHT,
            isEventMission = true,
            quitRespawnAddress = "Root|Missions|yz_cd_03",
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_CD }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { "radnet_events" }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_cd_03()

-- yz_cd_04
local function define_yz_cd_04()
    local missionName = "yz_cd_04"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "cd"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        missionInfo = {
            isSaved = true,
            isEventMission = true,
            timeOfDay = TOD_YELLOWZONE_NIGHT,
            quitRespawnAddress = "Root|Missions|yz_cd_04",
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_CD }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { "radnet_events" }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_cd_04()

-- ============================================
-- 5. СОБЫТИЯ (EVENTS) - YELLOW ZONE (ПРОДОЛЖЕНИЕ)
-- ============================================

-- yz_cr_01
local function define_yz_cr_01()
    local missionName = "yz_cr_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "cr"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        missionInfo = {
            isSaved = true,
            isEventMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_CR },
            timeOfDay = TOD_YELLOWZONE_NIGHT,
            quitRespawnAddress = "Root|Missions|yz_cr_01"
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { GUNSHIP_PACKAGE }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_cr_01()

-- yz_cr_02
local function define_yz_cr_02()
    local missionName = "yz_cr_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "cr"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        missionInfo = {
            isSaved = true,
            isEventMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_CR },
            timeOfDay = TOD_YELLOWZONE_NIGHT,
            quitRespawnAddress = "Root|Missions|yz_cr_02"
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { GUNSHIP_PACKAGE }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_cr_02()

-- yz_ra_01
local function define_yz_ra_01()
    local missionName = "yz_ra_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "ra"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        missionInfo = {
            isSaved = true,
            isEventMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_RA },
            timeOfDay = TOD_YELLOWZONE_NIGHT_RAIN,
            quitRespawnAddress = "Root|Missions|yz_ra_01"
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = {
                INFECTED3_SLAMMER_PACKAGE,
                "radnet_events"
            },
            ambientActiveList = {
                INFECTED1_1,
                INFECTED1_2,
                INFECTED1_3,
                INFECTED1_4,
                INFECTED1_5,
                INFECTED1_6
            }
        },
        audioData = { mix = "rampage" }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_ra_01()

-- yz_ra_02
local function define_yz_ra_02()
    local missionName = "yz_ra_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "ra"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        missionInfo = {
            isSaved = true,
            timeOfDay = TOD_YELLOWZONE_NIGHT,
            isEventMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_RA },
            quitRespawnAddress = "Root|Missions|yz_ra_02"
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = {
                SUPERSOLDIER_PACKAGE,
                "radnet_events"
            }
        },
        audioData = { mix = "rampage" }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_ra_02()

-- yz_rr_01
local function define_yz_rr_01()
    local missionName = "yz_rr_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "rr"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        missionInfo = {
            timeOfDay = TOD_YELLOWZONE_NIGHT,
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_RR },
            isSaved = true,
            isEventMission = true,
            quitRespawnAddress = "Root|Missions|yz_rr_01"
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { "radnet_events" }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_rr_01()

-- yz_sp_01
local function define_yz_sp_01()
    local missionName = "yz_sp_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "sp"
                    },
                    id = nil
                }
            },
            requiredButtonPressToActivate = true,
            requiredButtonPressPrompt = "$EVENT_START",
            cheatingBlocksAccess = true,
            buttonHintButtonToPress = ButtonHintButton.Action,
            leaveFadeActive = true,
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteAllowReplay = true,
            onCompleteReplayDelay = 0
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { "radnet_events" }
        },
        missionInfo = {
            isSaved = true,
            isEventMission = true,
            quitRespawnAddress = "Root|Missions|yz_sp_01",
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_SP }
        },
        audioData = { mix = "stockpile" }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_sp_01()

-- ============================================
-- 6. ИНФИЛЬТРАЦИЯ (INFILTRATION)
-- ============================================

-- Параметры для gz_fi_01
local function define_paramData_gz_fi_01()
    paramData = {
        exteriorStructureGroup = "structure_green_group001",
        exteriorStructurePath = "structure_green_group001|structure_green_blackwatch_275",
        interiorStructurePath = "structure_green_blackwatch_interior_275",
        superSoldiers = true
    }
end

define_paramData_gz_fi_01()

-- gz_fi_01
local function define_gz_fi_01()
    local missionName = "gz_fi_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 5760,
                ps3cpu = 512,
                ps3gpu = 5144,
                useHighMemory = true
            },
            activeList = {
                VS_BLACKWATCH_COMMANDER_PACKAGE,
                SUPERSOLDIER_PACKAGE
            }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/Infiltration/MotorPool",
            params = paramData
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_gz_fi_01()

-- gz_fi_02
local function define_gz_fi_02()
    local missionName = "gz_fi_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 8608,
                ps3cpu = 512,
                ps3gpu = 6048,
                useHighMemory = true
            },
            ambientActiveList = { INFECTED1_1 },
            activeList = { SUPERSOLDIER_PACKAGE }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/Infiltration/FacilityInTrouble"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_gz_fi_02()

-- gz_it_01
local function define_gz_it_01()
    local missionName = "gz_it_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            ambientActiveList = { LAB_COAT_SCIENTIST },
            activeList = { BRAWLER_EVADER_PACKAGE }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/InfectedTransport/MultipleLocations"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_gz_it_01()

-- ============================================
-- 7. ВОССТАНОВЛЕНИЕ (RECOVERY) - gz_re_01
-- ============================================

-- Параметры для gz_re_01
local function define_paramData_gz_re_01()
    paramData = {
        goToData = {
            -- recovery_group_1 (sequence)
            {
                goToType = "sequence",
                addressRootPath = "Missions|gz_re_01|recovery_group_1",
                markerType = Marker_Mission_GoTo,
                daisyChain = true,
                OnStartCallback = function(parent)
                    snd_PlayDialogueSequence("gz_re_01_log_010", "PlayerTalking")
                    parent.playerTalking = true
                end
            },
            -- recovery_group_3 (open)
            {
                goToType = "open",
                addressRootPath = "Missions|gz_re_01|recovery_group_3",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_4 (sequence)
            {
                goToType = "sequence",
                addressRootPath = "Missions|gz_re_01|recovery_group_4",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_5 (open)
            {
                goToType = "open",
                addressRootPath = "Missions|gz_re_01|recovery_group_5",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_6 (open)
            {
                goToType = "open",
                addressRootPath = "Missions|gz_re_01|recovery_group_6",
                markerType = Marker_Mission_GoTo,
                daisyChain = true,
                OnStartCallback = function(parent)
                    snd_PlayDialogueSequence("gz_re_01_log_020", "PlayerTalking")
                    parent.playerTalking = true
                end
            },
            -- recovery_group_7 (open)
            {
                goToType = "open",
                addressRootPath = "Missions|gz_re_01|recovery_group_7",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_8 (open)
            {
                goToType = "open",
                addressRootPath = "Missions|gz_re_01|recovery_group_8",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_8b (open)
            {
                goToType = "open",
                addressRootPath = "Missions|gz_re_01|recovery_group_8b",
                markerType = Marker_Mission_GoTo,
                daisyChain = true,
                OnStartCallback = function(parent)
                    snd_PlayDialogueSequence("gz_re_01_log_030", "PlayerTalking")
                    parent.playerTalking = true
                end
            },
            -- recovery_group_8c (open)
            {
                goToType = "open",
                addressRootPath = "Missions|gz_re_01|recovery_group_8c",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_9 (open)
            {
                goToType = "open",
                addressRootPath = "Missions|gz_re_01|recovery_group_9",
                markerType = Marker_Mission_GoTo,
                daisyChain = true,
                OnStartCallback = function(parent)
                    snd_PlayDialogueSequence("gz_re_01_log_050", "PlayerTalking")
                    parent.playerTalking = true
                end
            },
            -- recovery_group_10 (open)
            {
                goToType = "open",
                addressRootPath = "Missions|gz_re_01|recovery_group_10",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_11 (open)
            {
                goToType = "open",
                addressRootPath = "Missions|gz_re_01|recovery_group_11",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            }
        },
        RooftopObstructions = {
            Cell_224 = {
                "Cell_224billBoard_GZ_006",
                "Cell_224watertowerOS005",
                "Cell_224rooftopAccess003",
                "Cell_224skyLight005",
                "Cell_224fireEscapeTop002",
                "Cell_224fireEscapeMiddle002",
                "Cell_224fireEscapeMiddle001",
                "Cell_224DYPowerPoles003"
            },
            Cell_244 = {
                "Cell_244skyLight003",
                "Cell_244airconditionerOS001",
                "Cell_244airconditionerOS002",
                "Cell_244airconditionerOS003",
                "Cell_244WaterTowerOS001",
                "Cell_244CTRoofBuilding001",
                "Cell_244billboard_GZ_001",
                "Cell_244CTRoofBuilding001",
                "Cell_244airconditionerOS003",
                "Cell_244WaterTowerOS001",
                "Cell_244billboard_GZ_001",
                "Cell_244_skyLight006_011",
                "Cell_244watertowerOS004",
                "Cell_244CTRoofBuilding006",
                "Cell_244_skyLight005_008",
                "Cell_244skyLight006"
            },
            Cell_244_detail = {
                "Cell_244_detailairconUnitOS008",
                "Cell_244_detail_DYLamp001_002"
            },
            Cell_263 = {
                "Cell_263_billBoard_GZ_006_001",
                "Cell_263_CTRoofBuilding003_003",
                "Cell_263_CTRoofBuilding001_001",
                "Cell_263_billboard_GZ_001_001",
                "Cell_263_AirVent_007_002",
                "Cell_263_AirVent_005_001"
            },
            Cell_263_detail = {
                "Cell_263_detail_airconUnitOS007_001",
                "Cell_263_detail_skyLight001_001",
                "Cell_263_detail_skyLight001_002",
                "Cell_263_detail_skyLight001_003",
                "Cell_263_detail_airconditionerOS001_002",
                "Cell_263_detail_airconditionerOS001_005",
                "Cell_263_detail_DYLamp001_013"
            },
            Cell_264 = {
                "Cell_264airconditionerOS004",
                "Cell_264airconditionerOS008",
                "Cell_264_CTRoofBuilding001_001",
                "Cell_264_WaterTowerOS001_001",
                "Cell_264airconditionerOS005",
                "Cell_264airconditionerOS003",
                "Cell_264_rooftopAccess003_001",
                "Cell_264_skyLight005_001"
            },
            Cell_264_detail = {
                "Cell_264_detail_DYLamp001_009"
            },
            Cell_273 = {
                "Cell_273_skyLight001_001",
                "Cell_273_AirVent_007_002",
                "Cell_273_AirVent_005_003"
            },
            Cell_273_detail = {
                "Cell_273_detail_skyLight006_004",
                "Cell_273_detailskyLight008",
                "Cell_273_detailskyLight006"
            },
            Cell_203 = {
                "Cell_213_billBoard_GZ_006_003"
            },
            Cell_193 = {
                "Cell_193_airconditionerOS001_002"
            }
        },
        timeLimit = 55,
        timeBonus = 2,
        isEvent = false,
        introChopperFocusLocator = "ChopperFocus",
        introChopperSpawnAddress = "Missions|gz_re_01|IntroChopper|1",
        introChopperCaseFocusAddress = "Missions|gz_re_01|CaseFocus",
        introChopperPath = "ChopperCrashPath",
        introChopperRoofCamAddress = "Missions|gz_re_01|RoofCam",
        introChopperStreetCamAddress = "Missions|gz_re_01|StreetCam",
        introChopperDamageNode = "chopper_damage",
        introChopperRoofCamNode = "roofcam_engage",
        introChopperCaseDropNode = "focus_switch_to_case",
        introChopperStreetShotNode = "streetcam_engage",
        introChopperExplosionNode = "chopper_explode",
        introChopperCaseAddress = "Missions|gz_re_01|CaseFocus",
        introChopperCaseSpawn = "Missions|gz_re_01|CaseSpawn",
        lastCaseDialogue = "gz_re_01_log_060"
    }
end

define_paramData_gz_re_01()

-- gz_re_01
local function define_gz_re_01()
    local missionName = "gz_re_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/Recovery/Standard",
            params = paramData
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_gz_re_01()

-- ============================================
-- 7. ВОССТАНОВЛЕНИЕ (RECOVERY) - gz_re_02
-- ============================================

-- Параметры для gz_re_02
local function define_paramData_gz_re_02()
    paramData = {
        goToData = {
            -- recovery_group_0 (sequence)
            {
                goToType = "sequence",
                addressRootPath = "Missions|gz_re_02|recovery_group_0",
                markerType = Marker_Mission_Container,
                daisyChain = true
            },
            -- recovery_group_0b (open)
            {
                goToType = "open",
                addressRootPath = "Missions|gz_re_02|recovery_group_0b",
                markerType = Marker_Mission_Container,
                daisyChain = true
            },
            -- recovery_group_0c (sequence)
            {
                goToType = "sequence",
                addressRootPath = "Missions|gz_re_02|recovery_group_0c",
                markerType = Marker_Mission_Container,
                daisyChain = true
            },
            -- recovery_group_2 (open)
            {
                goToType = "open",
                addressRootPath = "Missions|gz_re_02|recovery_group_2",
                markerType = Marker_Mission_Container,
                daisyChain = true
            },
            -- recovery_group_3a (open)
            {
                goToType = "open",
                addressRootPath = "Missions|gz_re_02|recovery_group_3a",
                markerType = Marker_Mission_Container,
                daisyChain = true
            },
            -- recovery_group_3b (open)
            {
                goToType = "open",
                addressRootPath = "Missions|gz_re_02|recovery_group_3b",
                markerType = Marker_Mission_Container,
                daisyChain = true
            },
            -- recovery_group_3c (open)
            {
                goToType = "open",
                addressRootPath = "Missions|gz_re_02|recovery_group_3c",
                markerType = Marker_Mission_Container,
                daisyChain = true
            },
            -- recovery_group_4 (open)
            {
                goToType = "open",
                addressRootPath = "Missions|gz_re_02|recovery_group_4",
                markerType = Marker_Mission_Container,
                daisyChain = true
            },
            -- recovery_group_5 (open)
            {
                goToType = "open",
                addressRootPath = "Missions|gz_re_02|recovery_group_5",
                markerType = Marker_Mission_Container,
                daisyChain = true
            }
        },
        timeLimit = 30,
        timeBonus = 2,
        evolvedSpawnAddress = "Missions|gz_re_02|recovery_group_5|1",
        evolvedChasePath = "evolved_chase",
        introChopperFocusLocator = "ChopperFocus",
        introChopperSpawnAddress = "Root|Missions|gz_re_02|IntroChopper|1",
        introChopperCaseFocusAddress = "Root|Missions|gz_re_02|CaseFocus",
        introChopperPath = "ChopperCrashPath",
        introChopperRoofCamAddress = "Root|Missions|gz_re_02|RoofCam",
        introChopperStreetCamAddress = "Root|Missions|gz_re_02|StreetCam",
        introChopperDamageNode = "chopper_damage",
        introChopperRoofCamNode = "roofcam_engage",
        introChopperCaseDropNode = "focus_switch_to_case",
        introChopperStreetShotNode = "streetcam_engage",
        introChopperExplosionNode = "chopper_explode",
        introChopperCaseAddress = "Root|Missions|gz_re_02|CaseFocus"
    }
end

define_paramData_gz_re_02()

-- gz_re_02
local function define_gz_re_02()
    local missionName = "gz_re_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { EVOLVED_DEFAULT_PACKAGE }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/Recovery/EvolvedThief",
            params = paramData
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_gz_re_02()

-- ============================================
-- 7. ВОССТАНОВЛЕНИЕ (RECOVERY) - gz_re_03
-- ============================================

-- Параметры для gz_re_03
local function define_paramData_gz_re_03()
    paramData = {
        goToData = {
            -- recovery_group_2 (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|gz_re_03|recovery_group_2",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_3 (sequence)
            {
                goToType = "sequence",
                addressRootPath = "Root|Missions|gz_re_03|recovery_group_3",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_6 (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|gz_re_03|recovery_group_6",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_7 (sequence)
            {
                goToType = "sequence",
                addressRootPath = "Root|Missions|gz_re_03|recovery_group_7",
                markerType = Marker_Mission_GoTo,
                daisyChain = true,
                OnStartCallback = function(parent)
                    snd_PlayDialogueSequence("gz_re_03_log_080", "gz_re_03_log_080_tag")
                    parent.playerTalking = true
                end
            },
            -- recovery_group_9a (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|gz_re_03|recovery_group_9a",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_9b (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|gz_re_03|recovery_group_9b",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_10b (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|gz_re_03|recovery_group_10b",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_11 (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|gz_re_03|recovery_group_11",
                markerType = Marker_Mission_GoTo,
                daisyChain = true,
                OnStartCallback = function(parent)
                    snd_PlayDialogueSequence("gz_re_03_log_090", "gz_re_03_log_090_tag")
                    parent.playerTalking = true
                end
            },
            -- recovery_group_12 (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|gz_re_03|recovery_group_12",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            }
        },
        encounterList = {
            {
                noCleanup = true,
                encounterSetup = {
                    {
                        name = "heli1a",
                        activeRadius = 100000,
                        markerType = false,
                        templates = {
                            {
                                template = HELI_BH_TEMPLATE,
                                onSpawnCallback = HeliSpawnCallback,
                                min = 2,
                                max = 2,
                                total = 2,
                                respawnPositions = {
                                    address = {
                                        rootPath = "Root|Missions|gz_re_03|ChopperEncounter1",
                                        maxResults = 2
                                    }
                                }
                            },
                            {
                                template = BLACKWATCH_ROCKET,
                                onSpawnCallback = RocketSpawnCallback,
                                defendArea = "RestrictionVolume2",
                                min = 3,
                                max = 3,
                                total = 3,
                                respawnPositions = {
                                    address = {
                                        rootPath = "Root|Missions|gz_re_03|RocketEncounter2",
                                        maxResults = 3
                                    }
                                }
                            },
                            {
                                template = BLACKWATCH_ROCKET,
                                onSpawnCallback = RocketSpawnCallback,
                                defendArea = "RestrictionVolume3",
                                min = 3,
                                max = 3,
                                total = 3,
                                respawnPositions = {
                                    address = {
                                        rootPath = "Root|Missions|gz_re_03|RocketEncounter3",
                                        maxResults = 3
                                    }
                                }
                            },
                            {
                                template = BLACKWATCH_ROCKET,
                                onSpawnCallback = RocketSpawnCallback,
                                defendArea = "RestrictionVolume4",
                                min = 3,
                                max = 3,
                                total = 3,
                                respawnPositions = {
                                    address = {
                                        rootPath = "Root|Missions|gz_re_03|RocketEncounter4",
                                        maxResults = 3
                                    }
                                }
                            }
                        }
                    }
                }
            }
        },
        RooftopObstructions = {
            Cell_265 = {
                "Cell_265_airconditionerOS001_001",
                "Cell_265airconditionerOS002",
                "Cell_265tree0016",
                "Cell_265tree0015",
                "Cell_265tree0011",
                "Cell_265skyLight008",
                "Cell_265roofAccess001",
                "Cell_265skyLight006"
            },
            Cell_265_detail = {
                "Cell_265_detail_airconUnitOS007_005",
                "Cell_265_detail_airconUnitOS007_006"
            },
            Cell_263 = {
                "Cell_263_detail_DYLamp001_013",
                "Cell_263_detail_ventOS004_004",
                "Cell_263_detail_DYLamp001_012",
                "Cell_263_AirVent_005_001"
            },
            Cell_255 = {
                "Cell_255_skyLight001_001",
                "Cell_255_detail_AirVent_007_001",
                "Cell_255_airconditionerOS001_003",
                "Cell_255_detail_rooftop_airduct_01_003",
                "Cell_255_airconditionerOS001_001",
                "Cell_255_billboard_GZ_001_001"
            },
            Cell_255_detail = {
                "Cell_255_detail_ventOS002_004",
                "Cell_255_detail_AirVent_007_001",
                "Cell_255_detail_rooftop_airduct_01_003",
                "Cell_255_detail_rooftop_airduct_01_001",
                "Cell_255_detail_skyLight006_005",
                "Cell_255_detail_skyLight006_002",
                "Cell_255_detailskyLight006",
                "Cell_255_detail_airconUnitOS007_003"
            },
            Cell_243 = {
                "Cell_243_airconditionerOS003_002",
                "Cell_243_skyLight006_002",
                "Cell_243_skyLight006_003",
                "Cell_243_CTRoofBuilding003_001"
            },
            Cell_233 = {
                "Cell_235_airconditionerOS001_002",
                "Cell_235_airconditionerOS001_005",
                "Cell_235rooftop_airduct_04"
            },
            Cell_235 = {
                "Cell_235CTRoofBuilding004",
                "Cell_235_CTRoofBuilding002_003",
                "Cell_235airconditionerOS004",
                "Cell_235_airconditionerOS002_006",
                "Cell_235_WaterTowerOS001_003",
                "Cell_235rooftopAccess003",
                "Cell_235airconditionerOS002",
                "Cell_235_airconditionerOS001_002",
                "Cell_235_airconditionerOS002_004",
                "Cell_235_airconditionerOS001_005",
                "Cell_235rooftop_airduct_04",
                "Cell_235skyLight002",
                "Cell_235airconditionerOS008"
            },
            Cell_226 = {
                "Cell_226_roofAccess001_001",
                "Cell_226_detailairconUnitOS007",
                "Cell_226_detailskyLight008"
            },
            Cell_215 = {
                "Cell_215_skyLight001_001",
                "Cell_215billboard_GZ_001"
            },
            Cell_215_detail = {
                "Cell_215_detail_skyLight007_002",
                "Cell_215_detailskyLight007"
            },
            Cell_195 = {
                "Cell_195_watertowerOS004_001",
                "Cell_195_CTRoofBuilding001_002",
                "Cell_195airconditionerOS004",
                "Cell_195airconditionerOS002"
            },
            Cell_195_detail = {
                "Cell_195_detail_DYLamp001_001"
            },
            Cell_194 = {
                "Cell_194_detail_194_airconditionerOS003_002",
                "Cell_194_detail_194_airconditionerOS003_001"
            },
            Cell_205 = {
                "Cell_205_watertowerOS004_001",
                "Cell_205airconUnitOS007",
                "Cell_205CTRoofBuilding004",
                "Cell_205skyLight001",
                "Cell_205billBoard_GZ_006",
                "Cell_205CTRoofBuilding003",
                "Cell_205treeSapling001",
                "Cell_205treeSapling002",
                "Cell_205poorPlanter013",
                "Cell_205poorPlanter015",
                "Cell_205CTRoofBuilding002",
                "Cell_205airconditionerOS002",
                "Cell_205WaterTowerOS001"
            },
            Cell_205_detail = {
                "Cell_205_detailchairOS001",
                "Cell_205_detailchairOS003",
                "Cell_205_detailplanterOS005",
                "Cell_205poorPlanter002",
                "Cell_205_detailplanter003",
                "Cell_205poorPlanter004",
                "Cell_205_detailplanterOS007",
                "Cell_205_detail_DYLamp001_011"
            },
            Cell_203 = {
                "Cell_203_airconUnitOS007_004",
                "Cell_203_airconUnitOS007_005",
                "Cell_203_airconUnitOS007_002"
            },
            Cell_223 = {
                "Cell_223_airconUnitOS007_002",
                "Cell_223_airconUnitOS007_001"
            },
            Cell_193 = {
                "Cell_193airconditionerOS002",
                "Cell_193_airconditionerOS002_003",
                "Cell_193airconditionerOS002",
                "Cell_193_airconditionerOS002_003",
                "Cell_193_skyLight001_001",
                "Cell_193_airconditionerOS001_001",
                "Cell_193_airconditionerOS001_002"
            },
            Cell_193_detail = {
                "Cell_193_detail_skyLight001_001",
                "Cell_193_detailskyLight001"
            },
            Cell_173 = {
                "Cell_173rooftopAccess003",
                "Cell_173_skyLight001_005",
                "Cell_173skyLight002"
            }
        },
        timeLimit = 45,
        timeBonus = 2,
        introChopperFocusLocator = "ChopperFocus",
        introChopperSpawnAddress = "Root|Missions|gz_re_03|IntroChopper|1",
        introChopperCaseFocusAddress = "Root|Missions|gz_re_03|CaseFocus",
        introChopperPath = "ChopperCrashPath",
        introChopperRoofCamAddress = "Root|Missions|gz_re_03|RoofCam",
        introChopperStreetCamAddress = "Root|Missions|gz_re_03|StreetCam",
        introChopperDamageNode = "chopper_damage",
        introChopperRoofCamNode = "roofcam_engage",
        introChopperCaseDropNode = "focus_switch_to_case",
        introChopperStreetShotNode = "streetcam_engage",
        introChopperExplosionNode = "chopper_explode",
        introChopperCaseAddress = "Root|Missions|gz_re_03|CaseFocus",
        introChopperCaseSpawn = "Missions|gz_re_03|CaseSpawn",
        bonusObjective = "$GZ_RE_03_BONUS",
        HeliSpawnCallback = function(object)
            go_AddTag(object, "HeliTag")
        end,
        RocketSpawnCallback = function(object)
            go_AddTag(object, "RocketTag")
        end
    }
end

define_paramData_gz_re_03()

-- gz_re_03
local function define_gz_re_03()
    local missionName = "gz_re_03"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/Recovery/HeavyFire",
            params = paramData
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_gz_re_03()

-- ============================================
-- 8. ПОГЛОЩЕНИЕ УЧЕНЫХ (SCIENTIST CONSUME)
-- ============================================

-- gz_sc_02
local function define_gz_sc_02()
    local missionName = "gz_sc_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = {
                EVOLVED_PACKAGE,
                "bw_officer_full"
            }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/ScientistConsume/Evolved"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_gz_sc_02()

-- ============================================
-- 9. КОМАНДИР ТЕХНИКИ (VEHICLE COMMANDER)
-- ============================================

-- gz_vc_01
local function define_gz_vc_01()
    local missionName = "gz_vc_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = {
                SUPERSOLDIER_PACKAGE,
                VS_BLACKWATCH_COMMANDER_PACKAGE
            }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/VehicleCommander/Flying"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_gz_vc_01()

-- gz_vc_02
local function define_gz_vc_02()
    local missionName = "gz_vc_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { "bw_officer_full" }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/VehicleCommander/StrikeTeam"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_gz_vc_02()

-- ============================================
-- 10. ОХОТА (HUNT TARGETS)
-- ============================================

-- ow_green_black_net_hunt_target
local function define_ow_green_hunt()
    local missionName = "ow_green_black_net_hunt_target"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            autoUnlock = false,
            disableLoadingScreen = true
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { EVOLVED_DEFAULT_PACKAGE }
        },
        completionData = {
            onCompleteRelock = true,
            onCompleteAllowReplay = true,
            onCompleteCallback = nil
        },
        missionInfo = {
            noAutoTest = true,
            isHuntMission = true
        },
        retryData = {}
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_ow_green_hunt()

-- ow_red_black_net_hunt_target
local function define_ow_red_hunt()
    local missionName = "ow_red_black_net_hunt_target"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            autoUnlock = false,
            disableLoadingScreen = true
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = {
                EVOLVED_DEFAULT_PACKAGE,
                FLYER_PACKAGE
            }
        },
        completionData = {
            onCompleteRelock = true,
            onCompleteAllowReplay = true,
            onCompleteCallback = nil
        },
        missionInfo = {
            noAutoTest = true,
            isHuntMission = true
        },
        retryData = {}
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_ow_red_hunt()

-- ow_yellow_black_net_hunt_target
local function define_ow_yellow_hunt()
    local missionName = "ow_yellow_black_net_hunt_target"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            autoUnlock = false,
            disableLoadingScreen = true
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { EVOLVED_DEFAULT_PACKAGE }
        },
        completionData = {
            onCompleteRelock = true,
            onCompleteAllowReplay = true,
            onCompleteCallback = nil
        },
        missionInfo = {
            noAutoTest = true,
            isHuntMission = true
        },
        retryData = {}
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_ow_yellow_hunt()

-- ============================================
-- 6. ИНФИЛЬТРАЦИЯ (INFILTRATION) - КРАСНАЯ ЗОНА
-- ============================================

-- Параметры для rz_fi_01
local function define_paramData_rz_fi_01()
    paramData = {
        exteriorStructureGroup = "structure_red_group006",
        exteriorStructurePath = "structure_red_group006|structure_red_blackwatch_94",
        interiorStructurePath = "structure_red_blackwatch_interior_94"
    }
end

define_paramData_rz_fi_01()

-- rz_fi_01
local function define_rz_fi_01()
    local missionName = "rz_fi_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = {
                EVOLVED_PACKAGE,
                BRAWLER_EVADER_PACKAGE
            }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/Infiltration/BloodTox",
            params = paramData
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_fi_01()

-- rz_fi_02
local function define_rz_fi_02()
    local missionName = "rz_fi_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 64,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 3328,
                ps3cpu = 1024,
                ps3gpu = 3096,
                useHighMemory = true
            },
            ambientActiveList = {
                LAB_COAT_SCIENTIST,
                INFECTED1_3
            },
            activeList = {
                SUPERSOLDIER_PACKAGE,
                "bw_officer_full",
                EVOLVED_DEFAULT_PACKAGE
            }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/Infiltration/Evolved"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_fi_02()

-- ============================================
-- 7. ТРАНСПОРТ ЗАРАЖЕННЫХ (INFECTED TRANSPORT) - КРАСНАЯ ЗОНА
-- ============================================

-- rz_it_01
local function define_rz_it_01()
    local missionName = "rz_it_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 3072,
                ps3cpu = 1024,
                ps3gpu = 2176,
                useHighMemory = true
            },
            activeList = {
                INFECTED3_PACKAGE,
                FLYER_PACKAGE,
                "bw_officer_full"
            }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/InfectedTransport/TwelveMonkeys"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_it_01()

-- rz_it_02
local function define_rz_it_02()
    local missionName = "rz_it_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 1536,
                ps3cpu = 512,
                ps3gpu = 768,
                useHighMemory = true
            },
            activeList = {
                BEHEMOTH_PACKAGE,
                FLYER_PACKAGE
            }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/InfectedTransport/Behemoth"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_it_02()

-- Параметры для rz_re_01
local function define_paramData_rz_re_01()
    paramData = {
        timeLimit = 30,
        timeBonus = 2,
        addressRootPath = "Missions|rz_re_01|recovery_group_1",
        camFocusLocator = "CamFocus",
        crashLocator = "CrashLocator"
    }
end

define_paramData_rz_re_01()

-- rz_re_01
local function define_rz_re_01()
    local missionName = "rz_re_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { EVOLVED_DEFAULT_PACKAGE }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/Recovery/RainMaker",
            params = paramData
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_re_01()

-- ============================================
-- 7. ВОССТАНОВЛЕНИЕ (RECOVERY) - КРАСНАЯ ЗОНА (ПРОДОЛЖЕНИЕ)
-- ============================================

-- Параметры для rz_re_02
local function define_paramData_rz_re_02()
    paramData = {
        goToData = {
            -- recovery_group_1 (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|rz_re_02|recovery_group_1",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_2 (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|rz_re_02|recovery_group_2",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_3 (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|rz_re_02|recovery_group_3",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_4 (sequence)
            {
                goToType = "sequence",
                addressRootPath = "Root|Missions|rz_re_02|recovery_group_4",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_5 (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|rz_re_02|recovery_group_5",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_6 (sequence)
            {
                goToType = "sequence",
                addressRootPath = "Root|Missions|rz_re_02|recovery_group_6",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_8 (sequence)
            {
                goToType = "sequence",
                addressRootPath = "Root|Missions|rz_re_02|recovery_group_8",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_8a (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|rz_re_02|recovery_group_8a",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_8b (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|rz_re_02|recovery_group_8b",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_12 (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|rz_re_02|recovery_group_12",
                markerType = Marker_Mission_GoTo,
                daisyChain = true,
                OnStartCallback = function(parent)
                    snd_PlayDialogueSequence("d2_log_100", "d2_log_100")
                    parent.playerTalking = true
                end
            },
            -- recovery_group_13 (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|rz_re_02|recovery_group_13",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_13a (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|rz_re_02|recovery_group_13a",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_14 (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|rz_re_02|recovery_group_14",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_15 (sequence)
            {
                goToType = "sequence",
                addressRootPath = "Root|Missions|rz_re_02|recovery_group_15",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_16 (open)
            {
                goToType = "open",
                addressRootPath = "Root|Missions|rz_re_02|recovery_group_16",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_17 (sequence)
            {
                goToType = "sequence",
                addressRootPath = "Root|Missions|rz_re_02|recovery_group_17",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            }
        },
        RooftopObstructions = {
            Cell_145 = {
                "Cell_145airconditionerOS011"
            },
            Cell_154 = {
                "Cell_154planterRich007",
                "Cell_154planterRich006",
                "Cell_154patioTable001",
                "Cell_154patioTable003",
                "Cell_154_CTRoofBuilding003_001",
                "Cell_154scrub001",
                "Cell_154airconditionerOS005",
                "Cell_154airconditionerOS018",
                "Cell_154airconditionerOS004",
                "Cell_154planterRich003",
                "Cell_154planterRich004",
                "Cell_154CTChair004",
                "Cell_154CTChair009",
                "Cell_154planterRich005",
                "Cell_154skyLight001",
                "Cell_154airconditionerOS009",
                "Cell_154tree0017",
                "Cell_154patioUmbrella001",
                "Cell_154patioUmbrella002",
                "Cell_154CTChair007",
                "Cell_154skyLight003"
            },
            Cell_154_detail = {
                "Cell_154_detailplanter006",
                "Cell_154_detailplanter005",
                "Cell_154_detailplanterOS005",
                "Cell_154_detailplanterOS004",
                "Cell_154_detailplanterOS002",
                "Cell_154_detailCTChair001",
                "Cell_154_detailCTChair002",
                "Cell_154_detailCTChair003",
                "Cell_154_detailCTGarbage003",
                "Cell_154_detailplanter004",
                "Cell_154_detailplanterOS0053",
                "Cell_154_detailpatioTable003",
                "Cell_154_detailplanterOS001",
                "Cell_154_detailplanterOS003",
                "Cell_154_detailpatioTable001"
            },
            Cell_165 = {
                "Cell_165airconUnitOS008",
                "Cell_165skyLight007",
                "Cell_165skyLight004",
                "Cell_165commTower001"
            },
            Cell_185 = {
                "Cell_185_watertowerOS004_002",
                "Cell_185airconditionerOS012",
                "Cell_185airconditionerOS005",
                "Cell_185roofAccess001",
                "Cell_185skyLight002",
                "Cell_185_watertowerOS004_005",
                "Cell_185airconditionerOS010",
                "Cell_185skyLight003",
                "Cell_185skyLight001",
                "Cell_185airconditionerOS019"
            },
            Cell_195 = {
                "Cell_195skyLight005",
                "Cell_195tree0012",
                "Cell_195_planterOS001_005",
                "Cell_195_planter004_004",
                "Cell_195_planterOS001_004",
                "Cell_195CThangingLanterns_001",
                "Cell_195CTChair002",
                "Cell_195patioTable001",
                "Cell_195CTChair004",
                "Cell_195_planter004_003",
                "Cell_195CTChair007",
                "Cell_195patioTable002",
                "Cell_195CTChair012",
                "Cell_195CTChair003",
                "Cell_195patioTable003",
                "Cell_195CTChair001",
                "Cell_195bench002",
                "Cell_195_planter004_001",
                "Cell_195bench005",
                "Cell_195skyLight001",
                "Cell_195tree0010",
                "Cell_195CThangingLanterns_003"
            },
            Cell_215 = {
                "Cell_215_CTRoofBuilding003_011",
                "Cell_215_watertowerOS004_020",
                "Cell_215CTClothesLine002",
                "Cell_215_CTClothesLine001_016",
                "Cell_215_airconditionerOS001_009",
                "Cell_215poorPlanter014",
                "Cell_215poorPlanter013",
                "Cell_215poorPlanter012",
                "Cell_215CTRoofBuilding004",
                "Cell_215poorPlanter016",
                "Cell_215_airconditionerOS004_003",
                "Cell_215_airconditionerOS004_001",
                "Cell_215_detail_skyLight007_002",
                "Cell_215_detailskyLight007"
            },
            Cell_215_detail = {
                "Cell_215_detailplanterOS017",
                "Cell_215_detailplanterOS015",
                "Cell_215_detailplanterOS016",
                "Cell_215_detailplanter006",
                "Cell_215_detailplanterOS013"
            },
            Cell_226 = {
                "Cell_226rooftopAccess003"
            },
            Cell_235 = {
                "Cell_235_airconditionerOS001_007",
                "Cell_235_airconditionerOS001_006"
            },
            Cell_246 = {
                "Cell_246_skyLight002_001",
                "Cell_246CTRoofBuilding003",
                "Cell_246airconUnitOS007",
                "Cell_246_airconUnitOS007_007"
            },
            Cell_256 = {
                "Cell_256_airconditionerOS002_003",
                "Cell_256airconditionerOS004",
                "Cell_256_accessDoor001_001",
                "Cell_256CTRoofBuilding005",
                "Cell_256_skyLight001_001",
                "Cell_256CTRoofBuilding003",
                "Cell_256_airconditionerOS003_006",
                "Cell_256_airconUnitOS007_006",
                "Cell_256_airconUnitOS007_010"
            },
            Cell_276 = {
                "Cell_276airconUnitOS007",
                "Cell_276airconUnitOS008",
                "Cell_276_airconditionerOS002_004"
            }
        },
        encounterList = {
            -- Chopper encounter
            {
                noCleanup = true,
                encounterSetup = {
                    {
                        name = "helib",
                        positionSource = PLAYER,
                        activeRadius = 1000,
                        markerType = false,
                        templates = {
                            {
                                template = HELI_BH_TEMPLATE,
                                onSpawnCallback = HeliSpawnCallback,
                                min = 2,
                                max = 2,
                                total = 2,
                                respawnPositions = {
                                    address = {
                                        rootPath = "Root|Missions|rz_re_02|ChopperEncounter1",
                                        maxResults = 2
                                    }
                                }
                            }
                        }
                    }
                }
            },
            -- Blackwatch encounter 1
            {
                noCleanup = false,
                encounterSetup = {
                    {
                        name = "blackwatch1",
                        positionSource = PLAYER,
                        activeRadius = 1000,
                        markerType = false,
                        templates = {
                            {
                                template = BLACKWATCH_ROCKET,
                                onSpawnCallback = RocketSpawnCallback,
                                min = 3,
                                max = 3,
                                total = 3,
                                defendArea = 0,
                                respawnPositions = {
                                    address = {
                                        rootPath = "Root|Missions|rz_re_02|RocketEncounter1",
                                        maxResults = 3
                                    }
                                }
                            },
                            {
                                template = BLACKWATCH_ROCKET,
                                onSpawnCallback = RocketSpawnCallback,
                                min = 3,
                                max = 3,
                                total = 3,
                                defendArea = 0,
                                respawnPositions = {
                                    address = {
                                        rootPath = "Root|Missions|rz_re_02|RocketEncounter2",
                                        maxResults = 3
                                    }
                                }
                            },
                            {
                                template = BLACKWATCH_ROCKET,
                                onSpawnCallback = RocketSpawnCallback,
                                min = 3,
                                max = 3,
                                total = 3,
                                defendArea = 0,
                                respawnPositions = {
                                    address = {
                                        rootPath = "Root|Missions|rz_re_02|RocketEncounter3",
                                        maxResults = 3
                                    }
                                }
                            },
                            {
                                template = BLACKWATCH_ROCKET,
                                onSpawnCallback = RocketSpawnCallback,
                                min = 3,
                                max = 3,
                                total = 3,
                                defendArea = 0,
                                respawnPositions = {
                                    address = {
                                        rootPath = "Root|Missions|rz_re_02|RocketEncounter4",
                                        maxResults = 3
                                    }
                                }
                            },
                            {
                                template = BLACKWATCH_ROCKET,
                                onSpawnCallback = RocketSpawnCallback,
                                min = 2,
                                max = 2,
                                total = 2,
                                defendArea = 0,
                                respawnPositions = {
                                    address = {
                                        rootPath = "Root|Missions|rz_re_02|RocketEncounter5",
                                        maxResults = 2
                                    }
                                }
                            },
                            {
                                template = BLACKWATCH_ROCKET,
                                onSpawnCallback = RocketSpawnCallback,
                                min = 3,
                                max = 3,
                                total = 3,
                                defendArea = 0,
                                respawnPositions = {
                                    address = {
                                        rootPath = "Root|Missions|rz_re_02|RocketEncounter6",
                                        maxResults = 3
                                    }
                                }
                            }
                        }
                    }
                }
            },
            -- Blackwatch encounter 2
            {
                noCleanup = true,
                encounterSetup = {
                    {
                        name = "blackwatch2",
                        positionSource = PLAYER,
                        activeRadius = 1000,
                        markerType = false,
                        templates = {
                            {
                                template = BLACKWATCH_ROCKET,
                                onSpawnCallback = RocketSpawnCallback,
                                min = 6,
                                max = 6,
                                total = 6,
                                defendArea = 0,
                                respawnPositions = {
                                    address = {
                                        rootPath = "Root|Missions|rz_re_02|RocketEncounter7",
                                        maxResults = 6
                                    }
                                }
                            },
                            {
                                template = BLACKWATCH_ROCKET,
                                onSpawnCallback = RocketSpawnCallback,
                                min = 7,
                                max = 7,
                                total = 7,
                                defendArea = 0,
                                respawnPositions = {
                                    address = {
                                        rootPath = "Root|Missions|rz_re_02|RocketEncounter8",
                                        maxResults = 7
                                    }
                                }
                            }
                        }
                    }
                }
            }
        },
        OnMissionComplete = function() end,
        timeLimit = 30,
        timeBonus = 2,
        introChopperFocusLocator = "ChopperFocus",
        introChopperCaseFocusAddress = "Root|Missions|rz_re_02|CaseFocus",
        introChopperPath = "ChopperCrashPath",
        introChopperRoofCamAddress = "Root|Missions|rz_re_02|RoofCam",
        introChopperStreetCamAddress = "Root|Missions|rz_re_02|StreetCam",
        introChopperDamageNode = "chopper_damage",
        introChopperRoofCamNode = "roofcam_engage",
        introChopperCaseDropNode = "focus_switch_to_case",
        introChopperStreetShotNode = "streetcam_engage",
        introChopperExplosionNode = "chopper_explode",
        introChopperCaseAddress = "Root|Missions|rz_re_02|CaseFocus",
        bonusObjective = "$RZ_RE_02_BONUS",
        totalEnemies = 0,
        lastCaseDialogue = "rz_re_02_log_020",
        HeliSpawnCallback = function(object)
            ai_SetExclusiveTask(object, "destroy", { target = PLAYER })
        end,
        RocketSpawnCallback = function(object)
            ai_SetExclusiveTask(object, "engage", {})
            ai_ForceSee(object, PLAYER, 0.1)
            ai_SetFixedTarget(object, PLAYER)
        end,
        FlyerSpawnCallback = function() end
    }
end

define_paramData_rz_re_02()

-- rz_re_02
local function define_rz_re_02()
    local missionName = "rz_re_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { FLYER_PACKAGE }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/Recovery/HeavyFire",
            params = paramData
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_re_02()

-- ============================================
-- 8. ПОГЛОЩЕНИЕ УЧЕНЫХ (SCIENTIST CONSUME) - КРАСНАЯ ЗОНА
-- ============================================

-- rz_sc_01
local function define_rz_sc_01()
    local missionName = "rz_sc_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 2048,
                xenon = 2048,
                ps3cpu = 1024,
                ps3gpu = 1024,
                useHighMemory = true
            },
            ambientActiveList = {
                INFECTED1_3,
                INFECTED1_5
            },
            activeList = {
                FLYER_PACKAGE,
                BEHEMOTH_PACKAGE,
                "bw_officer_full"
            }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/ScientistConsume/Hidden"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_sc_01()

-- rz_sc_02
local function define_rz_sc_02()
    local missionName = "rz_sc_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 2048,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = {
                FLYER_PACKAGE,
                HYDRA_PACKAGE
            }
        },
        missionInfo = {
            isStoryMission = false,
            numBonusObjectives = 2
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/ScientistConsume/RoundUp"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_sc_02()

-- ============================================
-- 9. КОМАНДИР ТЕХНИКИ (VEHICLE COMMANDER) - КРАСНАЯ ЗОНА
-- ============================================

-- rz_vc_01
local function define_rz_vc_01()
    local missionName = "rz_vc_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { SUPERSOLDIER_PACKAGE }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/VehicleCommander/InfectedDestroyer"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_vc_01()

-- rz_vc_02
local function define_rz_vc_02()
    local missionName = "rz_vc_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 1024,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = {
                EVOLVED_PACKAGE,
                VS_BLACKWATCH_COMMANDER_PACKAGE,
                FLYER_PACKAGE
            }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/VehicleCommander/Evolved"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_rz_vc_02()

-- ============================================
-- 12. СТРУКТУРЫ - ЖЕЛТЫЕ ЛОГОВА (STRUCTURES - YELLOW LAIRS)
-- ============================================

-- structure_yellow_lair_interior_s_c_02
local function define_structure_yellow_lair_interior_s_c_02()
    local missionName = "structure_yellow_lair_interior_s_c_02"
    local config = {
        name = missionName,
        type = MissionType.Restricted,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        openData = {
            forceOpenPackages = true,
            neverActivate = true
        },
        packageData = {
            openStreamGroup = {
                win32 = 3072,
                xenon = 2048,
                ps3cpu = 512,
                ps3gpu = 1536
            }
        },
        missionInfo = {
            isAnInterior = true,
            isStructure = true
        },
        audioData = {
            ambience = "lair_ambience"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_structure_yellow_lair_interior_s_c_02()

-- structure_yellow_lair_interior_it_02
local function define_structure_yellow_lair_interior_it_02()
    local missionName = "structure_yellow_lair_interior_it_02"
    local config = {
        name = missionName,
        type = MissionType.Restricted,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        openData = {
            forceOpenPackages = true,
            neverActivate = true
        },
        packageData = {
            openStreamGroup = {
                win32 = 3072,
                xenon = 2048,
                ps3cpu = 512,
                ps3gpu = 1536
            }
        },
        missionInfo = {
            isAnInterior = true,
            isStructure = true,
            timeOfDay = TOD_LAIR
        },
        audioData = {
            ambience = "lair_ambience"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_structure_yellow_lair_interior_it_02()

-- ============================================
-- 6. ИНФИЛЬТРАЦИЯ (INFILTRATION) - ЖЕЛТАЯ ЗОНА
-- ============================================

-- yz_fi_01
local function define_yz_fi_01()
    local missionName = "yz_fi_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted,
            onCompleteUnlockKeys = { "story_a1" },
            onCompleteSetUnlockKeys = {
                "yz_woi_s02",
                "ev_s01",
                "ev_s02",
                "ev_s03",
                "ev_s04",
                "ev_s05"
            }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 7096,
                ps3cpu = 512,
                ps3gpu = 5048,
                useHighMemory = true
            },
            ambientActiveList = { MILITARY_SCIENTIST },
            activeList = {
                VS_BLACKWATCH_COMMANDER_PACKAGE,
                BLACKWATCH_COMMANDER_FULL_V2_PACKAGE
            }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/Infiltration/Standard"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_fi_01()

-- ============================================
-- 7. ТРАНСПОРТ ЗАРАЖЕННЫХ (INFECTED TRANSPORT) - ЖЕЛТАЯ ЗОНА
-- ============================================

-- yz_it_01
local function define_yz_it_01()
    local missionName = "yz_it_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            ambientActiveList = {
                INFECTED1_1,
                INFECTED1_2,
                INFECTED1_3,
                INFECTED1_4,
                INFECTED1_5
            }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/InfectedTransport/Standard"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_it_01()

-- yz_it_02
local function define_yz_it_02()
    local missionName = "yz_it_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 3072,
                useHighMemory = true
            },
            ambientActiveList = {
                LAB_COAT_SCIENTIST,
                INFECTED1_1,
                INFECTED1_2,
                INFECTED1_3,
                INFECTED1_4,
                INFECTED1_5,
                INFECTED1_6
            }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/InfectedTransport/Lair"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_it_02()

-- ============================================
-- 7. ВОССТАНОВЛЕНИЕ (RECOVERY) - ЖЕЛТАЯ ЗОНА
-- ============================================

-- Параметры для yz_re_01
local function define_paramData_yz_re_01()
    paramData = {
        goToData = {
            -- recovery_group_1 (sequence)
            {
                goToType = "sequence",
                addressRootPath = "Missions|yz_re_01|recovery_group_1",
                markerType = Marker_Mission_GoTo,
                daisyChain = true,
                OnStartCallback = function() end
            },
            -- recovery_group_3 (sequence)
            {
                goToType = "sequence",
                addressRootPath = "Missions|yz_re_01|recovery_group_3",
                markerType = Marker_Mission_GoTo,
                daisyChain = true,
                OnStartCallback = function(parent)
                    snd_PlayDialogueSequence("yz_re_01_log_020", "yz_re_01_log_020_tag")
                    parent.playerTalking = true
                end
            },
            -- recovery_group_3b (open)
            {
                goToType = "open",
                addressRootPath = "Missions|yz_re_01|recovery_group_3b",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_4 (open)
            {
                goToType = "open",
                addressRootPath = "Missions|yz_re_01|recovery_group_4",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_5 (open)
            {
                goToType = "open",
                addressRootPath = "Missions|yz_re_01|recovery_group_5",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_5b (open)
            {
                goToType = "open",
                addressRootPath = "Missions|yz_re_01|recovery_group_5b",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_6 (open)
            {
                goToType = "open",
                addressRootPath = "Missions|yz_re_01|recovery_group_6",
                markerType = Marker_Mission_GoTo,
                daisyChain = true,
                OnStartCallback = function(parent)
                    snd_PlayDialogueSequence("yz_re_01_log_025", "yz_re_01_log_025_tag")
                    parent.playerTalking = true
                end
            },
            -- recovery_group_7 (open)
            {
                goToType = "open",
                addressRootPath = "Missions|yz_re_01|recovery_group_7",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            },
            -- recovery_group_8 (open)
            {
                goToType = "open",
                addressRootPath = "Missions|yz_re_01|recovery_group_8",
                markerType = Marker_Mission_GoTo,
                daisyChain = true,
                OnStartCallback = function(parent)
                    snd_PlayDialogueSequence("yz_re_01_log_030", "yz_re_01_log_030_tag")
                    parent.playerTalking = true
                end
            },
            -- recovery_group_9 (open)
            {
                goToType = "open",
                addressRootPath = "Missions|yz_re_01|recovery_group_9",
                markerType = Marker_Mission_GoTo,
                daisyChain = true
            }
        },
        RooftopObstructions = {
            Cell_214 = {
                "Cell_214_airconditionerOS001_006"
            },
            Cell_205 = {
                "Cell_205_CTRoofBuilding001_003",
                "Cell_205WaterTowerOS001",
                "Cell_205_airconditionerOS001_003",
                "Cell_205_airconditionerOS001_005",
                "Cell_205billboard_GZ_001",
                "Cell_205airconUnitOS008",
                "Cell_205airconUnitOS009",
                "Cell_205airconUnitOS007"
            },
            Cell_185 = {
                "Cell_185_garbagePile001_003",
                "Cell_185_CTRoofBuilding002_002",
                "Cell_185_airconUnitOS007_008",
                "Cell_185_airconUnitOS007_005",
                "Cell_185skyLight003",
                "Cell_185roofAccess002",
                "Cell_185_garbagePile001_002",
                "Cell_185_airconditionerOS001_002",
                "Cell_185_garbagePile001_007",
                "Cell_185_watertowerOS004_007",
                "Cell_185_airconUnitOS007_010",
                "Cell_185_airconUnitOS007_011",
                "Cell_185_CTRoofBuilding002_001",
                "Cell_185_watertowerOS004_003",
                "Cell_185_airconditionerOS001_007",
                "Cell_185_airconditionerOS001_004",
                "Cell_185_skyLight002_003"
            },
            Cell_185_detail = {
                "Cell_185_detailpoorPlanter001",
                "Cell_185_detailpoorPlanter003",
                "Cell_185_detailbenchOS007",
                "Cell_185_detailbenchOS005",
                "Cell_185_detailgrassScattered001",
                "Cell_185_detailventOS003",
                "Cell_185_detail_Matress002_001",
                "Cell_185_detail_vendorTable001_003",
                "Cell_185_detail_Matress001_004",
                "Cell_185_watertowerOS004_002",
                "Cell_185_billBoard_GZ_004_001",
                "Cell_185_detailpoorPlanter007",
                "Cell_185_detailpoorPlanter004",
                "Cell_185_detailpoorPlanter002",
                "Cell_185_detailpoorPlanter006",
                "Cell_185_detail_CTChair001_016",
                "Cell_185_garbageCouch001_002",
                "Cell_185_detail_CTChair001_010",
                "Cell_185_detail_garbageTelevision001_001",
                "Cell_185_detail_vendorTable001_004",
                "Cell_185_detail_CTChair001_013",
                "Cell_185_detail_CTChair001_012",
                "Cell_185_detailventOS004"
            },
            Cell_174 = {
                "Cell_174airconUnitOS007",
                "Cell_174_airconditionerOS001_001",
                "Cell_174_airconditionerOS001_004",
                "Cell_174_CTRoofBuilding001_001"
            },
            Cell_174_detail = {
                "Cell_174_detail_ventOS003_001"
            },
            Cell_165 = {
                "Cell_165airconditionerOS003",
                "Cell_165airconditionerOS002",
                "Cell_165airconditionerOS001",
                "Cell_165airconditionerOS005"
            },
            Cell_155 = {
                "Cell_155airconditionerOS008",
                "Cell_155_airconditionerOS001_008",
                "Cell_155airconditionerOS009",
                "Cell_155WaterTowerOS001",
                "Cell_155_billboard_GZ_001_001",
                "Cell_155_CTRoofBuilding002_003",
                "Cell_155_watertowerOS004_003",
                "Cell_155_airconditionerOS001_005",
                "Cell_155airconditionerOS004",
                "Cell_155airconditionerOS006",
                "Cell_155_CTRoofBuilding003_002",
                "Cell_155_rooftopAccess003_003"
            },
            Cell_155_detail = {
                "Cell_155_detailpoorPlanter010",
                "Cell_155_detailpoorPlanter009",
                "Cell_155_detailpoorPlanter006",
                "Cell_155_detailpoorPlanter007",
                "Cell_155_detail_CTChair001_001",
                "Cell_155_detail_CTChair001_006f"
            },
            Cell_154 = {
                "Cell_154airconditionerOS007",
                "Cell_154airconditionerOS004",
                "Cell_154airconditionerOS005",
                "Cell_154_005",
                "Cell_154airconditionerOS002",
                "Cell_154airconditionerOS003",
                "Cell_154airconditionerOS001",
                "Cell_154_008",
                "Cell_154_007",
                "Cell_154airconditionerOS006",
                "Cell_154airconditionerOS009"
            },
            Cell_154_detail = {
                "Cell_154_detailgarbageTelevision001",
                "Cell_154_detailflamingGarbageCan004",
                "Cell_154_detailCTChair002",
                "Cell_154_detailCTChair003",
                "Cell_154_detailgarbageCouch001",
                "Cell_154_detailflamingGarbageCan001",
                "Cell_154_detailCTGarbage001"
            },
            Cell_145 = {
                "Cell_145airconditionerOS004",
                "Cell_145_001",
                "Cell_145airconditionerOS008",
                "Cell_145_003",
                "Cell_145airconditionerOS006",
                "Cell_145airconditionerOS013",
                "Cell_145_004",
                "Cell_145airconditionerOS005",
                "Cell_145airconditionerOS012",
                "Cell_145airconditionerOS007",
                "Cell_145airconditionerOS010"
            },
            Cell_145_detail = {
                "Cell_145_detailgarbageCouch003",
                "Cell_145_detailflamingGarbageCan007",
                "Cell_145_detailMatress003",
                "Cell_145_detailgarbageCouch002",
                "Cell_145_detailflamingGarbageCan004",
                "Cell_145_detailCTChair005",
                "Cell_145_detailCTChair006",
                "Cell_145_detailgarbageTelevision001",
                "Cell_145_detailflamingGarbageCan006",
                "Cell_145_detailCTGarbage007",
                "Cell_145_detailCTChair008",
                "Cell_145_detailgarbageCouch005",
                "Cell_145_detailflamingGarbageCan005"
            }
        },
        timeLimit = 20,
        timeBonus = 3,
        introChopperFocusLocator = "ChopperFocus",
        introChopperSpawnAddress = "Missions|yz_re_01|IntroChopper|1",
        introChopperCaseFocusAddress = "Missions|yz_re_01|CaseFocus",
        introChopperPath = "ChopperCrashPath",
        introChopperRoofCamAddress = "Missions|yz_re_01|RoofCam",
        introChopperStreetCamAddress = "Missions|yz_re_01|StreetCam",
        introChopperDamageNode = "chopper_damage",
        introChopperRoofCamNode = "roofcam_engage",
        introChopperCaseDropNode = "focus_switch_to_case",
        introChopperStreetShotNode = "streetcam_engage",
        introChopperExplosionNode = "chopper_explode",
        introChopperCaseAddress = "Missions|yz_re_01|CaseFocus",
        lastCaseDialogue = "yz_sc_02_log_040"
    }
end

define_paramData_yz_re_01()

-- yz_re_01
local function define_yz_re_01()
    local missionName = "yz_re_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/Recovery/Standard",
            params = paramData
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_re_01()

-- ============================================
-- 8. ПОГЛОЩЕНИЕ УЧЕНЫХ (SCIENTIST CONSUME) - ЖЕЛТАЯ ЗОНА
-- ============================================

-- yz_sc_01
local function define_yz_sc_01()
    local missionName = "yz_sc_01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            ambientActiveList = { MILITARY_SCIENTIST }
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/ScientistConsume/Standard"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_sc_01()

-- ============================================
-- 9. КОМАНДИР ТЕХНИКИ (VEHICLE COMMANDER) - ЖЕЛТАЯ ЗОНА
-- ============================================

-- yz_vc_02
local function define_yz_vc_02()
    local missionName = "yz_vc_02"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            disableLoadingScreen = true
        },
        completionData = {
            onCompleteCallback = mms_CollectibleBlackNetMissionCompleted
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = {}
        },
        activeFSMData = {
            path = "//MissionTemplates/OpenWorld/Missions/VehicleCommander/AssualtLair"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_vc_02()

-- yz_vc_02_lair_interior
local function define_yz_vc_02_lair_interior()
    local missionName = "yz_vc_02_lair_interior"
    local config = {
        name = missionName,
        type = MissionType.Restricted,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        openData = {
            forceOpenPackages = true,
            neverActivate = true
        },
        packageData = {
            openStreamGroup = {
                win32 = 4096,
                xenon = 2048,
                ps3cpu = 512,
                ps3gpu = 1536
            }
        },
        missionInfo = {
            isAnInterior = true,
            isStructure = true,
            timeOfDay = TOD_LAIR
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_vc_02_lair_interior()

-- ============================================
-- 14. СЮЖЕТНЫЕ МИССИИ (STORY MISSIONS)
-- ============================================
local function define_story_a1()
    local missionName = "story_a1"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteUnlockKeys = { "story_a2" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 2560,
                xenon = 2560,
                ps3cpu = 1024,
                ps3gpu = 2048,
                useHighMemory = true,
                ambientConfiguration = "story_a1"
            },
            ambientActiveList = {
                LAB_COAT_SCIENTIST,
                INFECTED1_1,
                INFECTED1_5
            },
            activeList = {}
        },
        missionInfo = {
            timeOfDay = TOD_YELLOWZONE_DAWN_RAIN,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartRooks },
            isSaved = true,
            numBonusObjectives = 2
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_a1()

-- ============================================
-- story_a2
-- ============================================
local function define_story_a2()
    local missionName = "story_a2"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteUnlockKeys = { "story_a3", "story_c2" },
            onCompleteSetUnlockKeys = { "yz_woi_s04" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 3072,
                xenon = 6096,
                ps3cpu = 512,
                ps3gpu = 3584,
                useHighMemory = true,
                ambientConfiguration = "story_a1"
            },
            ambientActiveList = { LAB_COAT_SCIENTIST },
            activeList = {
                HYDRA_PACKAGE,
                "bw_officer_full"
            }
        },
        missionInfo = {
            timeOfDay = TOD_YELLOWZONE_NIGHT,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartRooks },
            isSaved = true,
            numBonusObjectives = 2
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_a2()

-- ============================================
-- story_a3
-- ============================================
local function define_story_a3()
    local missionName = "story_a3"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteProcessUnlockSet = { "yzArcs" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 2048,
                ps3cpu = 512,
                ps3gpu = 1536,
                useHighMemory = true,
                ambientConfiguration = "story_a3"
            },
            ambientActiveList = { LAB_COAT_SCIENTIST },
            activeList = {}
        },
        missionInfo = {
            timeOfDay = TOD_YELLOWZONE_NIGHT,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartRooks },
            isSaved = true,
            numBonusObjectives = 1
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_a3()

-- ============================================
-- story_b2
-- ============================================
local function define_story_b2()
    local missionName = "story_b2"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteUnlockKeys = { "story_b3" },
            onCompleteSetUnlockKeys = {
                "ev_s01",
                "ev_s02",
                "ev_s03",
                "ev_s04",
                "ev_s05"
            }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 5824,
                xenon = 5824,
                ps3cpu = 1024,
                ps3gpu = 5376,
                useHighMemory = true
            },
            activeList = {
                SUPERSOLDIER_PACKAGE,
                "bw_officer_full"
            },
            ambientActiveList = {
                LAB_COAT_SCIENTIST,
                LAB_COAT_FEMALE,
                MILITARY_SCIENTIST,
                HAZMAT_NOMASK
            }
        },
        missionInfo = {
            timeOfDay = TOD_YELLOWZONE_DAY,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartGuerra },
            isSaved = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_b2()

-- ============================================
-- story_b3
-- ============================================
local function define_story_b3()
    local missionName = "story_b3"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            preloadPresentation = {
                branchAnimation = MISSION_ACQ_PDA_READY,
                forceDisguise = DISGUISE_HELLER,
                fmvData = {
                    name = "movies/story/B3_FMV_010.bik",
                    mix = "fmv_mix"
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteUnlockKeys = { "story_m1" },
            onCompleteSetUnlockKeys = { "yz_la_s01" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 3456,
                xenon = 3456,
                ps3cpu = 1024,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = { ORION_SUPERSOLDIER_PACKAGE }
        },
        missionInfo = {
            timeOfDay = TOD_YELLOWZONE_NIGHT_RAIN,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartKoenig },
            isSaved = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_b3()

-- ============================================
-- story_c1
-- ============================================
local function define_story_c1()
    local missionName = "story_c1"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteSetUnlockKeys = { "yz_woi_s01" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 2176,
                xenon = 2176,
                ps3cpu = 576,
                ps3gpu = 1856,
                useHighMemory = true
            },
            ambientActiveList = {
                INFECTED1_1,
                INFECTED1_2,
                INFECTED1_3,
                PED_FEMALE_1
            },
            activeList = { COMMANDER_BW_PACKAGE }
        },
        missionInfo = {
            timeOfDay = TOD_YELLOWZONE_NIGHT_RAIN,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartGuerra },
            isSaved = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_c1()

-- ============================================
-- story_c2
-- ============================================
local function define_story_c2()
    local missionName = "story_c2"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            preloadPresentation = {
                branchAnimation = MISSION_ACQ_PDA_VIDEO,
                forceDisguise = DISGUISE_HELLER,
                fmvData = {
                    name = "movies/story/C2_FMV_010.bik",
                    mix = "fmv_mix",
                    hideLoad = true,
                    startOnBlack = true
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteUnlockKeys = { "story_c3" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1152,
                xenon = 3200,
                ps3cpu = 576,
                ps3gpu = 2880,
                useHighMemory = true
            },
            activeList = {
                INFECTED3_SLAMMER_PACKAGE,
                "bw_officer_full"
            },
            ambientActiveList = {
                FORCE_LOAD_PEDS_C2_M1,
                FORCE_LOAD_PEDS_C2_M2,
                FORCE_LOAD_PEDS_C2_F1,
                FORCE_LOAD_PEDS_C2_F2
            }
        },
        missionInfo = {
            timeOfDay = TOD_YELLOWZONE_DAY,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartGuerra },
            isSaved = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_c2()

-- ============================================
-- story_c3
-- ============================================
local function define_story_c3()
    local missionName = "story_c3"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            preloadPresentation = {
                branchAnimation = MISSION_ACQ_PDA_READY,
                forceDisguise = DISGUISE_HELLER,
                fmvData = {
                    name = "movies/story/C3_FMV_010.bik",
                    mix = "fmv_mix",
                    hideLoad = true,
                    startOnBlack = true
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteProcessUnlockSet = { "yzArcs" },
            onCompleteSetUnlockKeys = { "yz_woi_s03" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 1024,
                ps3cpu = 512,
                ps3gpu = 768,
                useHighMemory = true
            },
            activeList = { "bw_officer_full" }
        },
        missionInfo = {
            timeOfDay = TOD_YELLOWZONE_DAWN,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartGuerra },
            isSaved = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_c3()

-- ============================================
-- story_d3
-- ============================================
local function define_story_d3()
    local missionName = "story_d3"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            preloadPresentation = {
                branchAnimation = MISSION_ACQ_PDA_READY,
                forceDisguise = DISGUISE_HELLER,
                fmvData = {
                    name = "movies/story/D3_FMV_010.bik",
                    mix = "fmv_mix",
                    hideLoad = true,
                    startOnBlack = true
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteUnlockKeys = { "story_e1" },
            onCompleteSetUnlockKeys = {
                "gz_woi_s02",
                "gz_woi_s03",
                "ev_s01",
                "ev_s02",
                "ev_s03",
                "ev_s04",
                "ev_s05"
            }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1536,
                xenon = 1024,
                ps3cpu = 1024,
                ps3gpu = 512,
                useHighMemory = true
            },
            activeList = {
                "evolved_d3",
                HYDRA_PACKAGE,
                SUPERSOLDIER_PACKAGE
            },
            ambientActiveList = { INFECTED1_1 }
        },
        missionInfo = {
            timeOfDay = TOD_GREENZONE_NIGHT_RAIN,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartGuerra },
            isSaved = true
        },
        audioData = { mix = "story_d3" }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_d3()

-- ============================================
-- story_e1
-- ============================================
local function define_story_e1()
    local missionName = "story_e1"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteUnlockKeys = { "story_e2" },
            onCompleteSetUnlockKeys = { "gz_woi_s04" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 0
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 1024,
                ps3cpu = 512,
                ps3gpu = 512,
                useHighMemory = true
            },
            activeList = {
                SUPERSOLDIER_PACKAGE,
                "riley"
            },
            ambientActiveList = {
                LAB_COAT_SCIENTIST,
                LAB_COAT_FEMALE,
                HAZMAT_NOMASK
            }
        },
        missionInfo = {
            timeOfDay = TOD_GREENZONE_DAY_RAIN,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartRooks },
            isSaved = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_e1()

-- ============================================
-- story_e2
-- ============================================
local function define_story_e2()
    local missionName = "story_e2"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            preloadPresentation = {
                branchAnimation = MISSION_ACQ_PDA_VIDEO,
                forceDisguise = DISGUISE_RILEY,
                fmvData = {
                    name = "movies/story/E2_FMV_010.bik",
                    mix = "fmv_mix"
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteUnlockKeys = { "story_e3" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 512,
                ps3cpu = 512,
                ps3gpu = 512,
                useHighMemory = true
            },
            activeList = {
                "evolved_e2",
                "bw_officer_full"
            }
        },
        missionInfo = {
            timeOfDay = TOD_GREENZONE_DAY,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartRooks },
            isSaved = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_e2()

-- ============================================
-- story_e3
-- ============================================
local function define_story_e3()
    local missionName = "story_e3"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            preloadPresentation = {
                branchAnimation = MISSION_ACQ_PDA_VIDEO,
                forceDisguise = DISGUISE_RILEY,
                fmvData = {
                    name = "movies/story/E3_FMV_010.bik",
                    mix = "fmv_mix"
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteProcessUnlockSet = { "gzArcs" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 0
            },
            activeStreamGroup = {
                win32 = 2560,
                xenon = 4096,
                ps3cpu = 512,
                ps3gpu = 3072,
                useHighMemory = true
            },
            activeList = {
                "evolved_e3",
                SUPERSOLDIER_PACKAGE
            }
        },
        missionInfo = {
            timeOfDay = TOD_GREENZONE_NIGHT,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartRooks },
            isSaved = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_e3()

-- ============================================
-- story_f1
-- ============================================
local function define_story_f1()
    local missionName = "story_f1"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            preloadPresentation = {
                branchAnimation = MISSION_ACQ_NORMALDOOR,
                forceDisguise = DISGUISE_HELLER,
                fmvData = {
                    name = "movies/story/F1_FMV_010.bik",
                    mix = "fmv_mix"
                }
            },
            leaveFadeActive = true,
            enablePlacard = true
        },
        completionData = {
            onCompleteUnlockKeys = { "story_f2" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 64,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 2560,
                xenon = 5120,
                ps3cpu = 768,
                ps3gpu = 3840,
                useHighMemory = true,
                ambientConfiguration = "story_f1"
            },
            ambientActiveList = {
                INFECTED1_1,
                INFECTED1_2,
                INFECTED1_3,
                LAB_COAT_SCIENTIST,
                HAZMAT_NOMASK
            },
            activeList = {
                "bw_officer_full",
                "evolved_f1",
                HYDRA_PACKAGE
            }
        },
        missionInfo = {
            timeOfDay = TOD_GREENZONE_NIGHT_RAIN,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartGalloway },
            isSaved = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_f1()

-- ============================================
-- story_f2
-- ============================================
local function define_story_f2()
    local missionName = "story_f2"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            preloadPresentation = {
                branchAnimation = MISSION_ACQ_PDA_READY,
                forceDisguise = DISGUISE_HELLER,
                fmvData = {
                    name = "movies/story/F2_FMV_010.bik",
                    mix = "fmv_mix"
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteProcessUnlockSet = { "gzArcs" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 64,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 576,
                ps3cpu = 256,
                ps3gpu = 256,
                useHighMemory = true,
                ambientConfiguration = "story_f2"
            },
            activeList = {
                HYDRA_PACKAGE,
                SUPERSOLDIER_PACKAGE,
                "evolved_f2",
                INFECTED3_HAMMERER_PACKAGE
            },
            ambientActiveList = { INFECTED1_1 },
            vehicleActiveList = { SEDAN }
        },
        missionInfo = {
            timeOfDay = TOD_GREENZONE_DAWN,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartGalloway },
            isSaved = true,
            numBonusObjectives = 2
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_f2()

-- ============================================
-- story_FinalBoss
-- ============================================
local function define_story_FinalBoss()
    local missionName = "story_FinalBoss"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    activationTrigger = "story_finalboss_active_001",
                    id = "startTrigger1"
                }
            },
            disableStopOnVolume = true,
            resetStrikeTeams = true,
            enablePlacard = true,
            leaveFadeActive = true,
            markerPos = Vector(-106, 143, 561)
        },
        completionData = {
            onCompleteUnlockKeys = {},
            onCompleteReplayDelay = 0,
            onCompleteAchievement = "Alex Consumed"
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1536,
                xenon = 2560,
                ps3cpu = 512,
                ps3gpu = 2048,
                useHighMemory = true
            },
            activeList = {
                ALEX_BOSS_PACKAGE,
                FLYER_PACKAGE
            },
            ambientActiveList = {
                INFECTED1_3,
                INFECTED1_4,
                INFECTED1_5
            }
        },
        initialTransitionData = {
            stayInVehicle = false,
            keepGrabbedObject = false,
            forceDisguise = DEFAULT_PLAYER_TRANSFORMATION_DESC,
            forceAttackPower = HUD_POWERS.Off,
            setAlertState = false,
            resetMass = 1,
            resetHealth = 1,
            setTimeOfDay = TOD_REDZONE_FINALBOSS1
        },
        missionInfo = {
            timeOfDay = TOD_REDZONE_FINALBOSS1,
            isStoryMission = true,
            isSaved = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartDana },
            disableImmediateUnloadOnAbort = true
        },
        audioData = {
            mix = "final_boss",
            ambience = "amb_finalboss"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_FinalBoss()

-- ============================================
-- story_g1
-- ============================================
local function define_story_g1()
    local missionName = "story_g1"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            preloadPresentation = {
                forceDisguise = DISGUISE_HELLER,
                fmvData = {
                    name = "movies/story/G1_FMV_010.bik",
                    mix = "fmv_mix",
                    hideLoad = true,
                    startOnBlack = true
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteUnlockKeys = { "story_g2", "story_i1" },
            onCompleteSetUnlockKeys = {
                "rz_woi_s02",
                "rz_woi_s03",
                "rz_woi_s04"
            }
        },
        packageData = {
            openStreamGroup = {
                win32 = 64,
                xenon = 64,
                ps3cpu = 64,
                ps3gpu = 0
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 1152,
                ps3cpu = 242,
                ps3gpu = 2048,
                useHighMemory = true,
                ambientConfiguration = "story_g1"
            },
            activeList = {
                INFECTED3_SLAMMER_PACKAGE,
                "evolved_g1",
                SUPERSOLDIER_PACKAGE,
                FLYER_PACKAGE,
                "bw_officer_full"
            }
        },
        missionInfo = {
            timeOfDay = TOD_REDZONE_NIGHT_RAIN,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartGalloway },
            isSaved = true,
            numBonusObjectives = 2
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_g1()

-- ============================================
-- story_g2
-- ============================================
local function define_story_g2()
    local missionName = "story_g2"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            preloadPresentation = {
                branchAnimation = MISSION_ACQ_PDA_VIDEO,
                forceDisguise = DISGUISE_HELLER,
                fmvData = {
                    name = "movies/story/G2_FMV_010.bik",
                    mix = "fmv_mix",
                    hideLoad = true,
                    startOnBlack = true
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteUnlockKeys = { "story_g3" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1536,
                xenon = 1536,
                ps3cpu = 512,
                ps3gpu = 1280,
                useHighMemory = true
            },
            activeList = {
                HYDRA_PACKAGE,
                FLYER_PACKAGE,
                INFECTED3_SLAMMER_PACKAGE,
                "bw_officer_full"
            }
        },
        missionInfo = {
            timeOfDay = TOD_REDZONE_NIGHT,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartGalloway },
            isSaved = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_g2()

-- ============================================
-- story_g3
-- ============================================
local function define_story_g3()
    local missionName = "story_g3"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            preloadPresentation = {
                branchAnimation = MISSION_ACQ_PDA_VIDEO,
                forceDisguise = DISGUISE_HELLER,
                fmvData = {
                    name = "movies/story/G3_FMV_010.bik",
                    mix = "fmv_mix",
                    hideLoad = true,
                    startOnBlack = true
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteProcessUnlockSet = { "rzArcs" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 3328,
                xenon = 3328,
                ps3cpu = 512,
                ps3gpu = 2816,
                useHighMemory = true
            },
            activeList = {},
            ambientActiveList = {}
        },
        missionInfo = {
            timeOfDay = TOD_REDZONE_DAWN,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartGalloway },
            isSaved = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_g3()

-- ============================================
-- story_h1
-- ============================================
local function define_story_h1()
    local missionName = "story_h1"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            preloadPresentation = {
                branchAnimation = MISSION_ACQ_NORMALDOOR,
                forceDisguise = DISGUISE_HELLER,
                fmvData = {
                    name = "movies/story/H1_FMV_010.bik",
                    mix = "fmv_mix",
                    hideLoad = true,
                    startOnBlack = true
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteUnlockKeys = { "story_g1" },
            onCompleteSetUnlockKeys = { "rz_woi_s01" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1536,
                xenon = 1024,
                ps3cpu = 128,
                ps3gpu = 2560,
                useHighMemory = true
            },
            activeList = {
                INFECTED3_HAMMERER_PACKAGE,
                SUPERSOLDIER_PACKAGE,
                EVOLVED_DEFAULT_PACKAGE
            },
            ambientActiveList = { PED_MALE_2 },
            vehicleActiveList = { SEDAN }
        },
        missionInfo = {
            timeOfDay = TOD_REDZONE_DAY,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartDana },
            isSaved = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_h1()

-- ============================================
-- story_i1
-- ============================================
local function define_story_i1()
    local missionName = "story_i1"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            preloadPresentation = {
                branchAnimation = MISSION_ACQ_PDA_VIDEO,
                forceDisguise = DISGUISE_RILEY,
                fmvData = {
                    name = "movies/story/I1_FMV_010.bik",
                    mix = "fmv_mix",
                    hideLoad = true,
                    startOnBlack = true
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteUnlockKeys = { "story_i3" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 0
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 768,
                ps3cpu = 512,
                ps3gpu = 256,
                useHighMemory = true
            },
            ambientActiveList = {},
            activeList = {
                "evolved_i1",
                HYDRA_PACKAGE,
                BW_PLAINCLOTHES1_PACKAGE
            }
        },
        missionInfo = {
            timeOfDay = TOD_REDZONE_NIGHT_RAIN,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartRooks },
            isSaved = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_i1()

-- ============================================
-- story_i3
-- ============================================
local function define_story_i3()
    local missionName = "story_i3"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            preloadPresentation = {
                branchAnimation = MISSION_ACQ_NORMALDOOR,
                forceDisguise = DISGUISE_HELLER,
                fmvData = {
                    name = "movies/story/H3_FMV_020.bik",
                    mix = "fmv_mix",
                    hideLoad = true,
                    startOnBlack = true
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteProcessUnlockSet = { "rzArcs" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 64,
                ps3cpu = 64,
                ps3gpu = 0
            },
            activeStreamGroup = {
                win32 = 2048,
                xenon = 768,
                ps3cpu = 140,
                ps3gpu = 1536,
                useHighMemory = true,
                ambientConfiguration = "story_i3"
            },
            ambientActiveList = { LAB_COAT_SCIENTIST },
            activeList = {
                EVOLVED_2ND_RUNNER_PACKAGE,
                BEHEMOTH_PACKAGE,
                INFECTED3_SLAMMER_PACKAGE,
                "riley"
            },
            vehicleActiveList = {
                SUV,
                CUBE_VAN
            }
        },
        missionInfo = {
            timeOfDay = TOD_REDZONE_DAWN,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartDana },
            isSaved = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_i3()

-- ============================================
-- story_intro1
-- ============================================
local function define_story_intro1()
    local missionName = "story_intro1"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            leaveFadeActive = true
        },
        completionData = {},
        initialTransitionData = {
            defaultTransform = "HellerMilitaryTransformationDescription",
            suppressFadeFromBlack = true
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 2048,
                xenon = 7168,
                ps3cpu = 1024,
                ps3gpu = 6072,
                useHighMemory = true,
                ambientConfiguration = "story_intro1"
            },
            activeList = {
                BEHEMOTH_PACKAGE,
                ALEX_REGULAR_PACKAGE,
                FLYER_PACKAGE,
                "heller_intro"
            },
            ambientActiveList = {
                INFECTED1_1,
                FORCE_LOAD_PED
            },
            vehicleActiveList = {
                SEDAN,
                VAN
            },
            preloadActive = true
        },
        missionInfo = {
            isStoryMission = true,
            timeOfDay = TOD_REDZONE_INTRO1,
            suppressUnlockedAlert = true,
            isSaved = true,
            isIntroMission = true
        },
        audioData = {
            mix = "story_intro1",
            ambience = "ambience_redzone_minimal",
            reverb = "radverb_intro1"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_intro1()

-- ============================================
-- story_intro2
-- ============================================
local function define_story_intro2()
    local missionName = "story_intro2"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            leaveFadeActive = true
        },
        completionData = {},
        initialTransitionData = {
            suppressFadeFromBlack = true
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 3072,
                ps3cpu = 1024,
                ps3gpu = 3584,
                useHighMemory = true
            },
            activeList = {
                "evolved_m1",
                "riley"
            },
            ambientActiveList = {
                INFECTED1_1,
                INFECTED1_2,
                INFECTED1_3,
                INFECTED1_4,
                INFECTED1_5,
                INFECTED1_LABTECH,
                INFECTED1_BRUISER,
                LAB_COAT_FEMALE,
                LAB_COAT_SCIENTIST
            }
        },
        missionInfo = {
            timeOfDay = TOD_BUNKER_INTRO2,
            isStoryMission = true,
            isAnInterior = true,
            suppressUnlockedAlert = true,
            isSaved = true,
            isIntroMission = true
        },
        audioData = {
            ambience = "facility_ambience",
            mix = "story_intro2"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_intro2()

-- ============================================
-- story_l1
-- ============================================
local function define_story_l1()
    local missionName = "story_l1"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {},
        completionData = {
            onCompleteUnlockKeys = { "story_c1" },
            onCompleteSetUnlockKeys = {
                "yz_bb_s01",
                "yz_bb_s02",
                "yz_bb_s03",
                "yz_ds_s01",
                "yz_ds_s02"
            }
        },
        initialTransitionData = {
            suppressFadeFromBlack = true
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 3072,
                xenon = 3072,
                ps3cpu = 512,
                ps3gpu = 2816,
                useHighMemory = true
            },
            activeList = {
                "bw_officer_full",
                "bw_officer_full_v3"
            },
            ambientActiveList = {
                PED_FEMALE_1,
                PED_MALE_1
            }
        },
        missionInfo = {
            timeOfDay = TOD_YELLOWZONE_DAWN,
            isStoryMission = true,
            suppressUnlockedAlert = true,
            isSaved = true,
            isIntroMission = true
        },
        audioData = {
            mix = "story_l1",
            applyOnRemove = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_l1()

-- ============================================
-- story_l2pre
-- ============================================
local function define_story_l2pre()
    local missionName = "story_l2pre"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            enablePlacard = true
        },
        completionData = {
            saveOnComplete = false
        },
        initialTransitionData = {
            resetStructures = { "structure_yellow_group001" }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 1024,
                ps3cpu = 512,
                ps3gpu = 768,
                useHighMemory = true
            },
            activeList = {}
        },
        missionInfo = {
            timeOfDay = TOD_YELLOWZONE_DAWN_RAIN,
            isStoryMission = true,
            isSaved = true,
            isPreMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartGuerra }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_l2pre()

-- ============================================
-- story_l2
-- ============================================
local function define_story_l2()
    local missionName = "story_l2"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {},
        completionData = {
            onCompleteUnlockKeys = { "story_d3", "story_f1" },
            onCompleteSetUnlockKeys = {
                "gz_bb_s01",
                "gz_bb_s02",
                "gz_bb_s03",
                "gz_la_s01",
                "gz_la_s02",
                "gz_ds_s01",
                "gz_ds_s02",
                "gz_woi_s01",
                "ev_s01",
                "ev_s02",
                "ev_s03",
                "ev_s04",
                "ev_s05"
            },
            onCompleteBlackNetUnlockKeys = {
                "yz_ab_01",
                "yz_ab_02",
                "gz_ab_01",
                "gz_ab_02"
            }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 3072,
                xenon = 3072,
                ps3cpu = 512,
                ps3gpu = 2560,
                useHighMemory = true
            },
            activeList = {
                INFECTED3_SLAMMER_PACKAGE,
                HYDRA_PACKAGE,
                VS_BLACKWATCH_COMMANDER_PACKAGE
            },
            ambientActiveList = {
                INFECTED1_1,
                INFECTED1_3,
                INFECTED1_5
            }
        },
        missionInfo = {
            timeOfDay = TOD_GREENZONE_DAWN,
            isStoryMission = true,
            preMission = "story_l2pre",
            isSaved = true,
            suppressUnlockedAlert = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_l2()

-- ============================================
-- story_l3pre
-- ============================================
local function define_story_l3pre()
    local missionName = "story_l3pre"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            enablePlacard = true
        },
        completionData = {
            saveOnComplete = false
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 1024,
                ps3cpu = 512,
                ps3gpu = 768,
                useHighMemory = true
            },
            activeList = {}
        },
        missionInfo = {
            timeOfDay = TOD_GREENZONE_DAWN,
            isStoryMission = true,
            isSaved = true,
            isPreMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartDana }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_l3pre()

-- ============================================
-- story_l3
-- ============================================
local function define_story_l3()
    local missionName = "story_l3"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            leaveFadeActive = true
        },
        completionData = {
            onCompleteUnlockKeys = { "story_h1" },
            onCompleteSetUnlockKeys = {
                "rz_bb_s01",
                "rz_bb_s02",
                "rz_bb_s03",
                "rz_la_s01",
                "rz_la_s02",
                "rz_ds_s01",
                "rz_ds_s02",
                "rz_ds_s03",
                "ev_s01",
                "ev_s02",
                "ev_s03",
                "ev_s04",
                "ev_s05"
            },
            onCompleteBlackNetUnlockKeys = {
                "rz_ab_01",
                "rz_ab_02"
            }
        },
        initialTransitionData = {
            intoVehicle = HELI_BH_TEMPLATE,
            blockVehicleExit = true,
            forceDisguise = "SoldierTransformationDescription"
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1536,
                xenon = 1024,
                ps3cpu = 512,
                ps3gpu = 512,
                useHighMemory = true
            },
            activeList = {
                HYDRA_PACKAGE,
                INFECTED3_SLAMMER_PACKAGE,
                BEHEMOTH_PACKAGE
            },
            ambientActiveList = {
                INFECTED1_3,
                INFECTED1_4,
                INFECTED1_5
            }
        },
        missionInfo = {
            timeOfDay = TOD_REDZONE_DAWN,
            isStoryMission = true,
            preMission = "story_l3pre",
            isSaved = true,
            suppressUnlockedAlert = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_l3()

-- ============================================
-- story_m1
-- ============================================
local function define_story_m1()
    local missionName = "story_m1"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            preloadPresentation = {
                forceDisguise = DISGUISE_HELLER
            },
            leaveFadeActive = true,
            enablePlacard = true
        },
        completionData = {
            onCompleteUnlockKeys = { "story_l2pre" },
            onCompleteAchievement = "M1 Completed"
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4416,
                xenon = 2048,
                ps3cpu = 512,
                ps3gpu = 1544,
                useHighMemory = true
            },
            ambientActiveList = { LAB_COAT_SCIENTIST },
            activeList = {
                "evolved_m1",
                SUPERSOLDIER_PACKAGE,
                "bw_officer_full",
                GUNSHIP_PACKAGE
            }
        },
        missionInfo = {
            timeOfDay = TOD_YELLOWZONE_NIGHT,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartKoenig },
            isSaved = true,
            numBonusObjectives = 2
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_m1()

-- ============================================
-- story_m2
-- ============================================
local function define_story_m2()
    local missionName = "story_m2"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            leaveFadeActive = true,
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteUnlockKeys = { "story_l3pre" },
            onCompleteAchievement = "M2 Completed"
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 1024,
                ps3cpu = 512,
                ps3gpu = 768,
                useHighMemory = true
            },
            activeList = {
                BEHEMOTH_PACKAGE,
                EVOLVED_2ND_RUNNER_PACKAGE,
                "bw_officer_full"
            }
        },
        missionInfo = {
            timeOfDay = TOD_GREENZONE_DAWN,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartGuerra },
            isSaved = true,
            numBonusObjectives = 2
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_m2()

-- ============================================
-- story_m3
-- ============================================
local function define_story_m3()
    local missionName = "story_m3"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        blockReleaseSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            },
            preloadPresentation = {
                branchAnimation = MISSION_ACQ_NORMALDOOR,
                forceDisguise = DISGUISE_HELLER,
                fmvData = {
                    name = "movies/story/M3_FMV_010.bik",
                    mix = "fmv_mix",
                    hideLoad = true,
                    startOnBlack = true
                }
            },
            enablePlacard = true
        },
        completionData = {
            onCompleteUnlockKeys = { "story_FinalBoss" },
            onCompleteAchievement = "M3 Completed"
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 0
            },
            activeStreamGroup = {
                win32 = 2048,
                xenon = 2048,
                ps3cpu = 256,
                ps3gpu = 1792,
                useHighMemory = true
            },
            activeList = {
                INFECTED3_SLAMMER_PACKAGE,
                SUPERSOLDIER_PACKAGE,
                BRAWLER_EVADER_PACKAGE
            },
            ambientActiveList = { INFECTED1_1 }
        },
        missionInfo = {
            timeOfDay = TOD_REDZONE_NIGHT_RAIN,
            isStoryMission = true,
            markerData = { onOpen = Marker_FreeRoam_MissionStartDana },
            isSaved = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_story_m3()

-- ============================================
-- 12. СТРУКТУРЫ (STRUCTURES)
-- ============================================

-- ============================================
-- Зеленые структуры
-- ============================================

local function define_structure(missionName, isInterior, timeOfDay, ambientOpenList)
    local config = {
        name = missionName,
        type = MissionType.Restricted,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    local missionConfig = {
        openData = {
            forceOpenPackages = true,
            neverActivate = true
        },
        missionInfo = {
            isAnInterior = isInterior or false,
            isStructure = true
        },
        audioData = {
            ambience = "base_ambience",
            mix = "interior_default",
            reverb = "radverb_warehouse"
        }
    }
    
    if timeOfDay then
        missionConfig.missionInfo.timeOfDay = timeOfDay
    end
    
    if ambientOpenList then
        missionConfig.packageData = {
            ambientOpenList = ambientOpenList
        }
    end
    
    mm_MissionFlowConfigs[missionName] = missionConfig
    mms_AddStandardFieldsToConfigTable(config)
end

-- structure_green_blackwatch_interior_275
define_structure("structure_green_blackwatch_interior_275", true, TOD_BREWERY)

-- structure_green_facility_interior_113
define_structure("structure_green_facility_interior_113", true, TOD_BREWERY_NIGHT)

-- structure_green_facility_interior_185
define_structure("structure_green_facility_interior_185", true, TOD_BREWERY)

-- structure_green_lair_interior_294
define_structure("structure_green_lair_interior_294", true, TOD_LAIR, {
    INFECTED1_1,
    INFECTED1_2,
    INFECTED1_3
})

-- structure_green_lair_interior_253
define_structure("structure_green_lair_interior_253", true, TOD_LAIR, {
    INFECTED1_1,
    INFECTED1_2,
    INFECTED1_3,
    INFECTED1_4,
    INFECTED1_5,
    INFECTED1_6
})

-- structure_green_lair_interior_304
define_structure("structure_green_lair_interior_304", true, TOD_LAIR, {
    INFECTED1_1,
    INFECTED1_2,
    INFECTED1_3,
    INFECTED1_4,
    INFECTED1_5,
    INFECTED1_6
})

-- structure_green_lair_interior_test_s_c_4
define_structure("structure_green_lair_interior_test_s_c_4", true, nil, nil)

-- structure_green_lair_interior_test_v_c_1
define_structure("structure_green_lair_interior_test_v_c_1", true, nil, nil)

-- ============================================
-- Зеленые группы (Restricted)
-- ============================================

local function define_structure_group(missionName)
    local config = {
        name = missionName,
        type = MissionType.Restricted,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        openData = {
            autoUnlock = true,
            scopingTriggers = { missionName .. "_open_001" },
            neverActivate = true
        },
        missionInfo = { isStructure = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_structure_group("structure_green_group001")
define_structure_group("structure_green_group002")
define_structure_group("structure_green_group003")
define_structure_group("structure_green_group004")

-- ============================================
-- Красные структуры
-- ============================================

-- structure_red_blackwatch_interior_94
define_structure("structure_red_blackwatch_interior_94", true, TOD_BREWERY)

-- structure_red_blackwatch_interior_253
define_structure("structure_red_blackwatch_interior_253", true, TOD_BREWERY)

-- structure_red_bunker_interior_214
local function define_structure_red_bunker()
    local missionName = "structure_red_bunker_interior_214"
    local config = {
        name = missionName,
        type = MissionType.Restricted,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        openData = {
            forceOpenPackages = true,
            neverActivate = true
        },
        packageData = { openList = {} },
        missionInfo = {
            isAnInterior = true,
            isStructure = true,
            timeOfDay = TOD_BUNKER
        },
        audioData = {
            ambience = "base_ambience",
            mix = "interior_default",
            reverb = "radverb_warehouse"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_structure_red_bunker()

-- structure_red_facility_interior_it_01
define_structure("structure_red_facility_interior_it_01", true, 2, {
    INFECTED1_1,
    INFECTED1_2,
    INFECTED1_3,
    INFECTED1_4,
    INFECTED1_5,
    INFECTED1_6
})

-- structure_red_lair_interior_306
define_structure("structure_red_lair_interior_306", true, TOD_LAIR, {
    INFECTED1_1,
    INFECTED1_2,
    INFECTED1_3
})

-- structure_red_lair_interior_315
define_structure("structure_red_lair_interior_315", true, nil, {
    INFECTED1_1,
    INFECTED1_2,
    INFECTED1_3,
    INFECTED1_4,
    INFECTED1_5,
    INFECTED1_6
})

-- ============================================
-- Красные группы (Restricted)
-- ============================================

local function define_red_structure_group(missionName, scopingTriggers)
    local config = {
        name = missionName,
        type = MissionType.Restricted,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        openData = {
            autoUnlock = true,
            scopingTriggers = scopingTriggers or { missionName .. "_open_001" },
            neverActivate = true
        },
        missionInfo = { isStructure = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_red_structure_group("structure_red_group001", { "structure_red_group001_open_001", "structure_red_group001_open_002" })
define_red_structure_group("structure_red_group002")
define_red_structure_group("structure_red_group003")
define_red_structure_group("structure_red_group004")
define_red_structure_group("structure_red_group005")
define_red_structure_group("structure_red_group006")

-- structure_red_hotspot001
local function define_structure_red_hotspot()
    local missionName = "structure_red_hotspot001"
    local config = {
        name = missionName,
        type = MissionType.Restricted,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        openData = {
            autoUnlock = true,
            scopingTriggers = { missionName .. "_open_001" },
            neverActivate = true
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 128,
                ps3gpu = 0
            }
        },
        missionInfo = { isStructure = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_structure_red_hotspot()

-- ============================================
-- Желтые структуры
-- ============================================

-- structure_yellow_blackwatch_interior_204
define_structure("structure_yellow_blackwatch_interior_204", true, TOD_BREWERY)

-- structure_yellow_facility_interior_94
local function define_structure_yellow_facility_94()
    local missionName = "structure_yellow_facility_interior_94"
    local config = {
        name = missionName,
        type = MissionType.Restricted,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        openData = {
            forceOpenPackages = true,
            neverActivate = true
        },
        missionInfo = {
            isAnInterior = true,
            isStructure = true,
            timeOfDay = TOD_BUNKER
        },
        audioData = {
            ambience = "facility_ambience",
            mix = "interior_default",
            reverb = "radverb_warehouse"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_structure_yellow_facility_94()

-- structure_yellow_facility_interior_135
define_structure("structure_yellow_facility_interior_135", true, TOD_BREWERY)

-- structure_yellow_facility_interior_164
define_structure("structure_yellow_facility_interior_164", true, TOD_BREWERY)

-- structure_yellow_military_interior_245
define_structure("structure_yellow_military_interior_245", true, TOD_BUNKER)

-- structure_yellow_lair_interior_yz_ra_01
define_structure("structure_yellow_lair_interior_yz_ra_01", true, TOD_LAIR, {
    INFECTED1_1,
    INFECTED1_2,
    INFECTED1_3,
    INFECTED1_4,
    INFECTED1_5,
    INFECTED1_6
})

-- ============================================
-- Желтые группы (Restricted)
-- ============================================

local function define_yellow_structure_group(missionName)
    local config = {
        name = missionName,
        type = MissionType.Restricted,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        openData = {
            autoUnlock = true,
            scopingTriggers = { missionName .. "_open_001" },
            neverActivate = true
        },
        missionInfo = { isStructure = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yellow_structure_group("structure_yellow_checkpoint001")
define_yellow_structure_group("structure_yellow_checkpoint002")
define_yellow_structure_group("structure_yellow_checkpoint003")
define_yellow_structure_group("structure_yellow_checkpoint004")
define_yellow_structure_group("structure_yellow_group001")
define_yellow_structure_group("structure_yellow_group002")
define_yellow_structure_group("structure_yellow_group003")
define_yellow_structure_group("structure_yellow_group004")
define_yellow_structure_group("structure_yellow_group005")

-- ============================================
-- 13. ТЕСТОВЫЕ МИССИИ
-- ============================================

local function define_test_mission(missionName, unlockKey, startPos, startRot, activeList, isInterior)
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = unlockKey or missionName
    }
    
    if startPos then
        config.debugStartPosition = startPos
    end
    if startRot then
        config.debugStartRotation = startRot
    end
    
    mm_ConfigureMission(config)
    
    local missionConfig = {
        missionInfo = {
            noAutoTest = true
        }
    }
    
    if isInterior then
        missionConfig.missionInfo.isAnInterior = true
        missionConfig.missionInfo.debugBlockAmbience = true
    end
    
    if activeList then
        missionConfig.packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 1024,
                ps3cpu = 512,
                ps3gpu = 768,
                useHighMemory = true
            },
            activeList = activeList
        }
    else
        missionConfig.packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 1024,
                ps3cpu = 512,
                ps3gpu = 768,
                useHighMemory = true
            }
        }
    end
    
    mm_MissionFlowConfigs[missionName] = missionConfig
    mms_AddStandardFieldsToConfigTable(config)
end

-- ms8_character_test
define_test_mission("ms8_character_test", "ms8_character_test", nil, nil, {
    SUPERSOLDIER_PACKAGE,
    EVOLVED
})

-- test_aidan
define_test_mission("test_aidan", "test_aidan", nil, nil, {})

-- test_ambient_vehicles
local function define_test_ambient_vehicles()
    local missionName = "test_ambient_vehicles"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {},
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 128,
                ps3gpu = 128,
                useHighMemory = true,
                ambientConfiguration = "test_ambient_vehicles"
            }
        },
        missionInfo = { noAutoTest = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_ambient_vehicles()

-- test_apc_tank_race
define_test_mission("test_apc_tank_race", "test_apc_tank_race", nil, nil, {})

-- test_audio
local function define_test_audio()
    local missionName = "test_audio"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        missionInfo = { noAutoTest = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_audio()

-- test_behemoth
define_test_mission("test_behemoth", "test_behemoth", nil, nil, { BEHEMOTH_PACKAGE })

-- test_combat_1
define_test_mission("test_combat_1", "test_combat_1", nil, nil, {
    EVOLVED_DEFAULT_PACKAGE,
    TANK_BLACKWATCH_PACKAGE,
    SUPERSOLDIER_PACKAGE
})

-- test_combat_2
define_test_mission("test_combat_2", "test_combat_2", nil, nil, {
    EVOLVED_DEFAULT_PACKAGE,
    INFECTED3_SLAMMER_PACKAGE
})

-- test_combat_3
define_test_mission("test_combat_3", "test_combat_3", nil, nil, {
    EVOLVED_DEFAULT_PACKAGE,
    GUNSHIP_PACKAGE
})

-- test_combat_interior
define_test_mission("test_combat_interior", "test_combat_interior", nil, nil, {}, true)

-- test_combatTestBed
local function define_test_combatTestBed()
    local missionName = "test_combatTestBed"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            }
        },
        missionInfo = { noAutoTest = true },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 1024,
                ps3cpu = 512,
                ps3gpu = 768,
                useHighMemory = true
            },
            activeList = {
                EVOLVED_DEFAULT_PACKAGE,
                HYDRA_PACKAGE,
                FLYER_PACKAGE,
                INFECTED3_SLAMMER_PACKAGE,
                SUPERSOLDIER_PACKAGE
            }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_combatTestBed()

-- test_facility_infiltration_1
define_test_mission("test_facility_infiltration_1", "test_facility_infiltration_1", nil, nil, {})

-- test_facility_infiltration_2
define_test_mission("test_facility_infiltration_2", "test_facility_infiltration_2", nil, nil, {})

-- test_gray01
define_test_mission("test_gray01", "test_gray01", nil, nil, {})

-- test_gray02
define_test_mission("test_gray02", "test_gray02", nil, nil, {})

-- test_infected
define_test_mission("test_infected", "test_infected", nil, nil, {
    BRAWLER_EVADER_PACKAGE,
    INFECTED3_SLAMMER_PACKAGE
})

-- test_infected_transport_1
define_test_mission("test_infected_transport_1", "test_infected_transport_1", nil, nil, { BEHEMOTH_PACKAGE })

-- test_infected_transport_2
define_test_mission("test_infected_transport_2", "test_infected_transport_2", nil, nil, { EVOLVED_DEFAULT_PACKAGE })

-- test_infected_transport_3
define_test_mission("test_infected_transport_3", "test_infected_transport_3", nil, nil, {})

-- test_infected_transport_4
define_test_mission("test_infected_transport_4", "test_infected_transport_4", nil, nil, { BEHEMOTH_PACKAGE })

-- test_infection_green
local function define_test_infection_green()
    local missionName = "test_infection_green"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {},
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 1024,
                ps3gpu = 3072,
                useHighMemory = true,
                ambientConfiguration = "empty"
            },
            activeList = {
                HYDRA_PACKAGE,
                BRAWLER_EVADER_PACKAGE,
                INFECTED3_SLAMMER_PACKAGE,
                BEHEMOTH_PACKAGE,
                EVOLVED_DEFAULT_PACKAGE
            }
        },
        missionInfo = { noAutoTest = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_infection_green()

-- test_infection_red
local function define_test_infection_red()
    local missionName = "test_infection_red"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {},
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 1024,
                ps3gpu = 3072,
                useHighMemory = true,
                ambientConfiguration = "empty"
            },
            activeList = {
                HYDRA_PACKAGE,
                BRAWLER_EVADER_PACKAGE,
                INFECTED3_SLAMMER_PACKAGE,
                BEHEMOTH_PACKAGE,
                EVOLVED_DEFAULT_PACKAGE
            }
        },
        missionInfo = { noAutoTest = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_infection_red()

-- test_infection_yellow
local function define_test_infection_yellow()
    local missionName = "test_infection_yellow"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {},
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 1024,
                ps3gpu = 3072,
                useHighMemory = true,
                ambientConfiguration = "empty"
            },
            activeList = {
                HYDRA_PACKAGE,
                BRAWLER_EVADER_PACKAGE,
                INFECTED3_SLAMMER_PACKAGE,
                BEHEMOTH_PACKAGE,
                EVOLVED_DEFAULT_PACKAGE
            }
        },
        missionInfo = { noAutoTest = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_infection_yellow()

-- test_jak
define_test_mission("test_jak", "test_jak", nil, nil, {})

-- test_jump
local function define_test_jump()
    local missionName = "test_jump"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = "test_jump",
        debugStartPosition = Vector(-646.3, 20, -236.1),
        debugStartRotation = Vector(1, 0, 1),
        blockDebugSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = Vector(-646.3, 0.3, -236.1)
                }
            }
        },
        openData = { forceOpenPackages = true },
        missionInfo = {
            isAnInterior = true,
            debugBlockAmbience = true,
            noAutoTest = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_jump()

-- test_lars
local function define_test_lars()
    local missionName = "test_lars"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        packageData = {
            activeList = {
                SUPERSOLDIER_PACKAGE,
                APC_BLACKWATCH_PACKAGE,
                HELI_BH_BLACKWATCH_PACKAGE,
                INFECTED3_PACKAGE,
                HYDRA_PACKAGE,
                EVOLVED_PACKAGE,
                BW_SCIENTIST_PACKAGE
            }
        },
        missionInfo = { noAutoTest = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_lars()

-- test_loco
local function define_test_loco()
    local missionName = "test_loco"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = "test_loco",
        debugStartPosition = Vector(365.1, 135.3, -350.4),
        debugStartRotation = Vector(0, 0, 1),
        blockDebugSelection = false
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        openData = { neverActivate = true },
        packageData = {
            ambientOpenList = { INFECTED1_1 }
        },
        missionInfo = {
            debugBlockAmbience = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_loco()

-- test_markers
define_test_mission("test_markers", "test_markers", nil, nil, { SUPERSOLDIER_PACKAGE })

-- test_nis
local function define_test_nis()
    local missionName = "test_nis"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        packageData = {
            activeList = {
                SUPERSOLDIER_PACKAGE,
                "test_nis_characters"
            }
        },
        missionInfo = { noAutoTest = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_nis()

-- test_nis_autotest
local function define_test_nis_autotest()
    local missionName = "test_nis_autotest"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        missionInfo = { noAutoTest = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_nis_autotest()

-- test_nis_green
local function define_test_nis_green()
    local missionName = "test_nis_green"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        packageData = {
            activeList = {
                SUPERSOLDIER_PACKAGE,
                "test_nis_characters"
            }
        },
        missionInfo = { noAutoTest = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_nis_green()

-- test_nis_yellow
local function define_test_nis_yellow()
    local missionName = "test_nis_yellow"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        packageData = {
            activeList = {
                SUPERSOLDIER_PACKAGE,
                "test_nis_characters"
            }
        },
        missionInfo = { noAutoTest = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_nis_yellow()

-- test_objective_templates
define_test_mission("test_objective_templates", "test_objective_templates", nil, nil, { EVOLVED_DEFAULT_PACKAGE })

-- test_personnel
local function define_test_personnel()
    local missionName = "test_personnel"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = "personnel"
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = { path = "Missions|" .. missionName },
                    id = nil
                }
            }
        },
        packageData = {
            activeList = {
                SUPERSOLDIER_PACKAGE,
                BW_SCIENTIST_PACKAGE,
                BW_PLAINCLOTHES1_PACKAGE,
                BW_PLAINCLOTHES2_PACKAGE
            }
        },
        missionInfo = { noAutoTest = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_personnel()

-- test_prop_sandbox
local function define_test_prop_sandbox()
    local missionName = "test_prop_sandbox"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        debugStartPosition = Vector(-51.3, 51.6, 49.3),
        debugStartRotation = Vector(0.707, 0, 0.707)
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        openData = {},
        missionInfo = {
            debugBlockAmbience = true,
            noAutoTest = true
        },
        packageData = {
            openStreamGroup = {
                win32 = 4196,
                xenon = 4196,
                ps3cpu = 2048,
                ps3gpu = 2048
            },
            activeStreamGroup = {
                win32 = 4196,
                xenon = 4196,
                ps3cpu = 2048,
                ps3gpu = 2048,
                useHighMemory = true
            }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_prop_sandbox()

-- test_prop_green
local function define_test_prop_green()
    local missionName = "test_prop_green"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        debugStartPosition = Vector(-45, 7.3, 225),
        debugStartRotation = Vector(0, 0, 1)
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        missionInfo = {
            debugBlockAmbience = true,
            noAutoTest = true
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 12288,
                xenon = 12288,
                ps3cpu = 4096,
                ps3gpu = 8192,
                useHighMemory = true,
                ambientConfiguration = "empty"
            }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_prop_green()

-- test_prop_yellow
local function define_test_prop_yellow()
    local missionName = "test_prop_yellow"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        debugStartPosition = Vector(-100, 6, -318),
        debugStartRotation = Vector(0, 0, 1)
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        missionInfo = {
            debugBlockAmbience = true,
            noAutoTest = true
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 12288,
                xenon = 12288,
                ps3cpu = 4096,
                ps3gpu = 8192,
                useHighMemory = true,
                ambientConfiguration = "empty"
            }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_prop_yellow()

-- test_prop_red
local function define_test_prop_red()
    local missionName = "test_prop_red"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        debugStartPosition = Vector(197, 17, 455),
        debugStartRotation = Vector(0, 0, 1)
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        missionInfo = {
            debugBlockAmbience = true,
            noAutoTest = true
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 12288,
                xenon = 12288,
                ps3cpu = 4096,
                ps3gpu = 8192,
                useHighMemory = true,
                ambientConfiguration = "empty"
            }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_prop_red()

-- test_prop_store
define_test_mission("test_prop_store", "test_prop_store", nil, nil, {})

-- test_props
local function define_test_props()
    local missionName = "test_props"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName,
        debugStartPosition = Vector(-590, 60, -590),
        debugStartRotation = Vector(0.707, 0, 0.707)
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        openData = {},
        missionInfo = {
            debugBlockAmbience = true,
            noAutoTest = true
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_props()

-- test_rampage01
local function define_test_rampage01()
    local missionName = "test_rampage01"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start",
                        showEventStart = true,
                        buttonMarkerStyle = "event",
                        eventType = "ra"
                    },
                    id = nil
                }
            },
            contentCalendarEventType = ContentCalendarEventType.Collateral,
            cheatingBlocksAccess = true,
            leaveFadeActive = true,
            activePreloadRadius = 10
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 1024,
                xenon = 1024,
                ps3cpu = 512,
                ps3gpu = 768,
                useHighMemory = true
            },
            activeList = {
                SUPERSOLDIER_PACKAGE,
                "radnet_events"
            }
        },
        missionInfo = {
            markerData = { onOpen = Marker_FreeRoam_MissionStartEvent_RA },
            noAutoTest = true,
            timeOfDay = TOD_YELLOWZONE_DAY,
            isSaved = true,
            isEventMission = true,
            quitRespawnAddress = "Root|Missions|test_rampage01"
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_rampage01()

-- test_recovery_1
local function define_test_recovery_1()
    local missionName = "test_recovery_1"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            autoUnlock = false,
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            }
        },
        completionData = {
            onCompleteCallback = mms_CollectibleMissionCompleted
        },
        missionInfo = { noAutoTest = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_recovery_1()

-- test_recovery_2
local function define_test_recovery_2()
    local missionName = "test_recovery_2"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            autoUnlock = false,
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            }
        },
        completionData = {
            onCompleteCallback = mms_CollectibleMissionCompleted
        },
        missionInfo = {
            markerData = { onOpen = Marker_OpenWorld_VehicleCommander },
            noAutoTest = true
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 4096,
                ps3gpu = 2048,
                useHighMemory = true
            }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_recovery_2()

-- test_recovery_3
local function define_test_recovery_3()
    local missionName = "test_recovery_3"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            autoUnlock = false,
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            }
        },
        completionData = {
            onCompleteCallback = mms_CollectibleMissionCompleted
        },
        missionInfo = {
            markerData = { onOpen = Marker_OpenWorld_VehicleCommander },
            noAutoTest = true
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 4096,
                ps3gpu = 2048,
                useHighMemory = true
            }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_recovery_3()

-- test_recovery_4
local function define_test_recovery_4()
    local missionName = "test_recovery_4"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        activationData = {
            autoUnlock = false,
            startPoints = {
                {
                    buttonStart = {
                        type = AddressType.ButtonStartLocator,
                        name = "start"
                    },
                    id = nil
                }
            }
        },
        completionData = {
            onCompleteCallback = mms_CollectibleMissionCompleted
        },
        missionInfo = {
            markerData = { onOpen = Marker_OpenWorld_VehicleCommander }
        },
        packageData = {
            openStreamGroup = {
                win32 = 128,
                xenon = 128,
                ps3cpu = 64,
                ps3gpu = 64
            },
            activeStreamGroup = {
                win32 = 4096,
                xenon = 4096,
                ps3cpu = 4096,
                ps3gpu = 2048,
                useHighMemory = true
            }
        }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_test_recovery_4()

-- test_scientist_consume_1..5
for i = 1, 5 do
    define_test_mission("test_scientist_consume_" .. i, "test_scientist_consume_" .. i, nil, nil, {})
end

-- test_scripted_checkpoints
define_test_mission("test_scripted_checkpoints", "test_scripted_checkpoints", nil, nil, {})

-- test_shaders_green
define_test_mission("test_shaders_green", "test_shaders_green", nil, nil, {})

-- test_shaders_red
define_test_mission("test_shaders_red", "test_shaders_red", nil, nil, {})

-- test_shaders_yellow
define_test_mission("test_shaders_yellow", "test_shaders_yellow", nil, nil, {})

-- test_stockpile_2
define_test_mission("test_stockpile_2", "test_stockpile_2", nil, nil, {})

-- test_vehicle_commander_1
define_test_mission("test_vehicle_commander_1", "test_vehicle_commander_1", nil, nil, {})

-- test_vehicle_commander_2
define_test_mission("test_vehicle_commander_2", "test_vehicle_commander_2", nil, nil, {})

-- test_vehicles
define_test_mission("test_vehicles", "test_vehicles", nil, nil, { HELI_BH_MARINE_PACKAGE })

-- yz_m001
local function define_yz_m001()
    local missionName = "yz_m001"
    local config = {
        name = missionName,
        type = MissionType.Priority,
        unlockKey = missionName
    }
    
    mm_ConfigureMission(config)
    
    mm_MissionFlowConfigs[missionName] = {
        missionInfo = { noAutoTest = true }
    }
    
    mms_AddStandardFieldsToConfigTable(config)
end

define_yz_m001()

-- ============================================
-- 15. АВТОМАТИЧЕСКАЯ РЕГИСТРАЦИЯ НЕДОСТАЮЩИХ МИССИЙ
-- ============================================

for missionName, missionData in pairs(mm_MissionTable) do
    if not mm_MissionFlowConfigs[missionName] then
        local config = {
            name = missionName,
            type = MissionType.Priority,
            unlockKey = missionName,
            blockDebugSelection = false
        }
        
        mm_ConfigureMission(config)
        
        mm_MissionFlowConfigs[missionName] = {
            openData = {
                forceOpenPackages = true,
                neverActivate = true
            },
            missionInfo = {
                noAutoTest = true,
                debugBlockAmbience = true
            }
        }
        
        mms_AddStandardFieldsToConfigTable(config)
    end
end

-- ============================================
-- 16. НАСТРОЙКА ТЕГОВ И ФОНОВЫХ МИССИЙ
-- ============================================

mm_BackgroundMissions = { global = {} }
mm_TagSets = {}

-- Функция для создания набора тегов
function createTagSet(tag, force)
    if not mm_TagSets[tag] then
        mm_TagSets[tag] = {
            tag = tag,
            missions = mms_GetAllTaggedMissions(tag)
        }
    end
    
    local tagSet = mm_TagSets[tag]
    
    if force then
        if not tagSet.groupDef then
            local missions = tagSet.missions
            if #missions > 0 then
                local groupDef = {
                    name = UID("TagGroup_" .. tag),
                    win32 = 0,
                    xenon = 0,
                    ps3cpu = 0,
                    ps3gpu = 0,
                    numSlots = 0,
                    numSharedSlots = 0,
                    tagSetGroup = true
                }
                
                for _, mission in ipairs(missions) do
                    local streamGroup = mission.packageData.openStreamGroup
                    if not streamGroup.tagSetGroup then
                        local slotConfig = mms_BuildSlotGroupConfigForPackageLists(
                            mission.packageData.openStreamGroup,
                            { mission.packageData.openList, mission.packageData.openPackages }
                        )
                        
                        if slotConfig.win32 > groupDef.win32 then
                            groupDef.win32 = slotConfig.win32
                        end
                        if slotConfig.xenon > groupDef.xenon then
                            groupDef.xenon = slotConfig.xenon
                        end
                        if slotConfig.ps3cpu > groupDef.ps3cpu then
                            groupDef.ps3cpu = slotConfig.ps3cpu
                        end
                        if slotConfig.ps3gpu > groupDef.ps3gpu then
                            groupDef.ps3gpu = slotConfig.ps3gpu
                        end
                        if slotConfig.useHighMemory ~= groupDef.useHighMemory then
                            mms_Error("", "Missions in tag-set " .. tag .. " have differing useHighMemory setting")
                        end
                        if slotConfig.numSharedSlots > groupDef.numSharedSlots then
                            groupDef.numSharedSlots = slotConfig.numSharedSlots
                        end
                        if #slotConfig.slots > groupDef.numSlots then
                            groupDef.numSlots = #slotConfig.slots
                        end
                    end
                end
                
                for _, mission in ipairs(missions) do
                    mission.packageData.openStreamGroup = groupDef
                    mission.packageData.openList.groupDef = groupDef
                    mission.packageData.openPackages.groupDef = groupDef
                    mission.packageData.tagSet = tagSet
                end
                
                tagSet.groupDef = groupDef
            end
        end
    end
end

-- Функция для добавления тега в список concurrency
function addTagToConcurrencyList(tag, list)
    local tagGroupName = mms_GetTagGroupName(tag)
    
    if tagGroupName then
        local tagSet = mm_TagSets[tagGroupName]
        if tagSet and tagSet.missions then
            for _, mission in ipairs(tagSet.missions) do
                table.insert(list, mission.MISSION_NAME)
            end
            
            local firstMission = tagSet.missions[1]
            if firstMission then
                local dependencyTag = mms_GetTagGroupName(firstMission.pipData.openDependency)
                if dependencyTag then
                    addTagToConcurrencyList(firstMission.pipData.openDependency, list)
                end
            end
        end
    else
        table.insert(list, tag)
    end
end

-- Обработка тегов в конфигурациях миссий
for missionName, config in pairs(mm_MissionFlowConfigs) do
    local pipData = config.pipData
    
    if pipData.tags then
        if pipData.tags ~= "None" then
            local newTags = {}
            for _, tag in pairs(pipData.tags) do
                newTags[tag] = _
            end
            pipData.tags = newTags
        end
    else
        pipData.tags = nil
    end
    
    if config.MISSION_MANAGEMENT_TYPE == MissionType.Background then
        if not (config.missionInfo and config.missionInfo.dependencyIgnore) then
            if pipData.openDependency and pipData.openDependency ~= "None" then
                mms_Error(config.MISSION_NAME, "'Background' mission cannot have an openDependency")
            end
            
            if pipData.location and pipData.location ~= "None" then
                if not mm_BackgroundMissions[pipData.location] then
                    mm_BackgroundMissions[pipData.location] = {}
                end
                table.insert(mm_BackgroundMissions[pipData.location], config)
            else
                table.insert(mm_BackgroundMissions.global, config)
            end
        end
    else
        if pipData.location then
            if not pipData.openDependency or pipData.openDependency == "None" then
                pipData.openDependency = "locationBGM"
            end
            if not pipData.activeDependency or pipData.activeDependency == "None" then
                pipData.activeDependency = "locationBGM"
            end
        end
    end
end

-- Создание наборов тегов
for missionName, config in pairs(mm_MissionFlowConfigs) do
    if config.pipData.tags then
        for tag, _ in pairs(config.pipData.tags) do
            createTagSet(tag)
        end
    end
end

-- Обработка зависимостей
for missionName, config in pairs(mm_MissionFlowConfigs) do
    local dependencies = { "openDependency", "activeDependency" }
    
    for _, depType in ipairs(dependencies) do
        local dep = config.pipData[depType]
        if dep then
            local tagGroupName = mms_GetTagGroupName(dep)
            if tagGroupName then
                if mm_TagSets[tagGroupName] then
                    createTagSet(tagGroupName, true)
                else
                    config.pipData[depType] = "locationBGM"
                    cprint("error", "Warning: " .. config.MISSION_NAME .. " found tag group " .. tagGroupName .. " to be empty")
                end
            end
        end
    end
end

-- Обработка concurrencyList
for missionName, config in pairs(mm_MissionFlowConfigs) do
    local concurrencyList = config.pipData.concurrencyList
    if concurrencyList then
        local newList = {}
        for _, item in ipairs(concurrencyList) do
            addTagToConcurrencyList(item, newList)
        end
        config.pipData.concurrencyList = newList
    end
end

-- Проверка размера ключей в БД
local missionCount = 0
local totalLength = 1

for missionName, config in pairs(mm_MissionFlowConfigs) do
    if not (config.missionInfo and config.missionInfo.noAutoTest == true) then
        totalLength = totalLength + string.len(missionName) + 1
        missionCount = missionCount + 1
    end
end

if totalLength > MISSION_KEY_DB_ACCUMULATED_STRING_SIZE then
    mms_Error("mm", "ERROR: Mission keys require " .. totalLength .. 
        " characters in game db, but we have allocated only " .. 
        MISSION_KEY_DB_ACCUMULATED_STRING_SIZE .. ".\n" ..
        "MISSION_KEY_DB_MAX_INSTANCES should be >= " .. missionCount .. 
        " and MISSION_KEY_ESTIMATED_AVG_LENGTH should be >= " .. (totalLength / missionCount))
end

-- Очистка временных функций (для предотвращения повторного использования)
mms_AddStandardFieldsToConfigTable = nil
PreprocessOpenData = nil
PreprocessActivationData = nil
PreprocessPackageData = nil
PreprocessCompletionData = nil