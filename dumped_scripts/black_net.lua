-- ============================================
-- BLACK NET DATA - ОХОТНИЧЬИ ЦЕЛИ (Hunt Targets)
-- ============================================

local function registerHuntTargets()
    local huntTargets = {}
    
    -- === ЗЕЛЕНАЯ ЗОНА (Green Zone) ===
    
    -- gz_woi_s01e02
    huntTargets[#huntTargets + 1] = {
        staticID = "gz_woi_s01e02",
        locationID = ZoneId.Green,
        data = {
            missionUnlockKey = "gz_re_01",
            preHuntDialog = "gz_re_01_log_005",
            positionSet = "District1",
            targetTemplate = BlackNetData.templateGroups.GenTek
        }
    }
    
    -- gz_woi_s01e03
    huntTargets[#huntTargets + 1] = {
        staticID = "gz_woi_s01e03",
        locationID = ZoneId.Green,
        data = {
            missionUnlockKey = "gz_fi_01",
            preHuntDialog = "gz_fi_01_log_005",
            positionSet = "District1",
            targetTemplate = BlackNetData.templateGroups.BlackWatch
        }
    }
    
    -- gz_woi_s02e01
    huntTargets[#huntTargets + 1] = {
        staticID = "gz_woi_s02e01",
        locationID = ZoneId.Green,
        data = {
            missionUnlockKey = "gz_vc_01",
            preHuntDialog = "gz_vc_01_log_010",
            positionSet = "District2",
            targetTemplate = BlackNetData.templateGroups.BlackWatch
        }
    }
    
    -- gz_woi_s02e02
    huntTargets[#huntTargets + 1] = {
        staticID = "gz_woi_s02e02",
        locationID = ZoneId.Green,
        data = {
            missionUnlockKey = "gz_re_02",
            preHuntDialog = "gz_re_02_log_100",
            positionSet = "District2",
            targetTemplate = BlackNetData.templateGroups.BlackWatch
        }
    }
    
    -- gz_woi_s02e03
    huntTargets[#huntTargets + 1] = {
        staticID = "gz_woi_s02e03",
        locationID = ZoneId.Green,
        data = {
            missionUnlockKey = "gz_fi_02",
            preHuntDialog = "gz_fi_02_log_005",
            positionSet = "District2",
            targetTemplate = BlackNetData.templateGroups.GenTek
        }
    }
    
    -- gz_woi_s03e02 (PhoneStall)
    huntTargets[#huntTargets + 1] = {
        staticID = "gz_woi_s03e02",
        locationID = ZoneId.Green,
        data = {
            missionUnlockKey = "gz_it_01",
            preHuntDialog = "gz_it_01_log_005",
            positionSet = "District3",
            targetTemplate = BlackNetData.templateGroups.GenTek,
            smartnodeType = "PhoneStall"
        }
    }
    
    -- gz_woi_s03e03
    huntTargets[#huntTargets + 1] = {
        staticID = "gz_woi_s03e03",
        locationID = ZoneId.Green,
        data = {
            missionUnlockKey = "gz_vc_02",
            preHuntDialog = "gz_vc_02_log_100",
            positionSet = "District3",
            targetTemplate = BlackNetData.templateGroups.BlackWatchPilot,
            remainStationary = true
        }
    }
    
    -- gz_woi_s04e02
    huntTargets[#huntTargets + 1] = {
        staticID = "gz_woi_s04e02",
        locationID = ZoneId.Green,
        data = {
            missionUnlockKey = "gz_re_03",
            preHuntDialog = "gz_re_03_log_010",
            positionSet = "District2",
            targetTemplate = BlackNetData.templateGroups.Evolved,
            remainStationary = true
        }
    }
    
    -- gz_woi_s04e03
    huntTargets[#huntTargets + 1] = {
        staticID = "gz_woi_s04e03",
        locationID = ZoneId.Green,
        data = {
            missionUnlockKey = "gz_sc_02",
            preHuntDialog = "gz_sc_02_log_010",
            positionSet = "District3",
            targetTemplate = BlackNetData.templateGroups.GenTek
        }
    }
    
    -- === ЖЕЛТАЯ ЗОНА (Yellow Zone) - Миссии только для сюжета ===
    
    local storyMissions = {
        { id = "o2_woi_010", pos = "District1" },
        { id = "l1_woi_010", pos = "District1" },
        { id = "l1_woi_020", pos = "District1" },
        { id = "l1_woi_030", pos = "District1" },
        { id = "a1_woi_010", pos = "District1" },
        { id = "a1_woi_020", pos = "District1" },
        { id = "a3_woi_010", pos = "District1" },
        { id = "b2_woi_010", pos = "District1" },
        { id = "b3_woi_010", pos = "District1" },
        { id = "m1_woi_010", pos = "District1" },
        { id = "m1_woi_020", pos = "District1" },
    }
    
    for _, mission in ipairs(storyMissions) do
        huntTargets[#huntTargets + 1] = {
            staticID = mission.id,
            locationID = ZoneId.Yellow,
            data = {
                positionSet = mission.pos,
                targetTemplate = BlackNetData.templateGroups.GenTek,
                missionOnly = true
            }
        }
    end
    
    -- === ЗЕЛЕНАЯ ЗОНА - Сюжетные миссии ===
    
    local greenStoryMissions = {
        { id = "d3_woi_010", pos = "District1" },
        { id = "e1_woi_010", pos = "District1" },
        { id = "e1_woi_020", pos = "District1" },
        { id = "e2_woi_010", pos = "District1" },
        { id = "e2_woi_020", pos = "District1" },
        { id = "e2_woi_030", pos = "District1" },
        { id = "e3_woi_010", pos = "District1" },
        { id = "f3_woi_010", pos = "District1" },
    }
    
    for _, mission in ipairs(greenStoryMissions) do
        huntTargets[#huntTargets + 1] = {
            staticID = mission.id,
            locationID = ZoneId.Green,
            data = {
                positionSet = mission.pos,
                targetTemplate = BlackNetData.templateGroups.GenTek,
                missionOnly = true
            }
        }
    end
    
    -- === КРАСНАЯ ЗОНА (Red Zone) - Сюжетные миссии ===
    
    local redStoryMissions = {
        { id = "g1_woi_010", pos = "District1" },
        { id = "g2_woi_010", pos = "District1" },
        { id = "i1_woi_010", pos = "District1" },
        { id = "i1_woi_020", pos = "District1" },
        { id = "i3_woi_010", pos = "District1" },
        { id = "m4_woi_010", pos = "District1" },
    }
    
    for _, mission in ipairs(redStoryMissions) do
        huntTargets[#huntTargets + 1] = {
            staticID = mission.id,
            locationID = ZoneId.Red,
            data = {
                positionSet = mission.pos,
                targetTemplate = BlackNetData.templateGroups.GenTek,
                missionOnly = true
            }
        }
    end
    
    -- === ЖЕЛТАЯ ЗОНА - Основные миссии ===
    
    -- yz_woi_s01e03 (MaskHandout)
    huntTargets[#huntTargets + 1] = {
        staticID = "yz_woi_s01e03",
        locationID = ZoneId.Yellow,
        data = {
            missionUnlockKey = "yz_fi_01",
            preHuntDialog = "yz_fi_01_log_020",
            positionSet = "District1",
            targetTemplate = BlackNetData.templateGroups.GenTek,
            smartnodeType = "MaskHandout"
        }
    }
    
    -- yz_woi_s01e01 (SoldierConversation)
    huntTargets[#huntTargets + 1] = {
        staticID = "yz_woi_s01e01",
        locationID = ZoneId.Yellow,
        data = {
            missionUnlockKey = "yz_it_01",
            preHuntDialog = "yz_it_01_log_010",
            positionSet = "District1",
            targetTemplate = BlackNetData.templateGroups.BlackWatch,
            smartnodeType = "SoldierConversation"
        }
    }
    
    -- yz_woi_s01e02 (SoldierConversation)
    huntTargets[#huntTargets + 1] = {
        staticID = "yz_woi_s01e02",
        locationID = ZoneId.Yellow,
        data = {
            missionUnlockKey = "yz_it_02",
            preHuntDialog = "yz_it_02_log_005",
            positionSet = "District1",
            targetTemplate = BlackNetData.templateGroups.BlackWatch,
            smartnodeType = "SoldierConversation"
        }
    }
    
    -- yz_woi_s02e03
    huntTargets[#huntTargets + 1] = {
        staticID = "yz_woi_s02e03",
        locationID = ZoneId.Yellow,
        data = {
            missionUnlockKey = "yz_re_01",
            preHuntDialog = "yz_re_01_log_005",
            positionSet = "District2",
            targetTemplate = BlackNetData.templateGroups.BlackWatch
        }
    }
    
    -- yz_woi_s03e02 (Doctor)
    huntTargets[#huntTargets + 1] = {
        staticID = "yz_woi_s03e02",
        locationID = ZoneId.Yellow,
        data = {
            missionUnlockKey = "yz_sc_01",
            preHuntDialog = "yz_sc_01_log_010",
            positionSet = "District3",
            targetTemplate = BlackNetData.templateGroups.GenTek,
            smartnodeType = "Doctor"
        }
    }
    
    -- yz_woi_s03e03
    huntTargets[#huntTargets + 1] = {
        staticID = "yz_woi_s03e03",
        locationID = ZoneId.Yellow,
        data = {
            missionUnlockKey = "yz_vc_02",
            preHuntDialog = "yz_vc_02_log_005",
            positionSet = "District3",
            targetTemplate = BlackNetData.templateGroups.BlackWatch
        }
    }
    
    -- === КРАСНАЯ ЗОНА - Основные миссии ===
    
    -- rz_woi_s01e01
    huntTargets[#huntTargets + 1] = {
        staticID = "rz_woi_s01e01",
        locationID = ZoneId.Red,
        data = {
            missionUnlockKey = "rz_sc_01",
            preHuntDialog = "rz_sc_01_log_005",
            positionSet = "District3",
            targetTemplate = BlackNetData.templateGroups.GenTek
        }
    }
    
    -- rz_woi_s01e02
    huntTargets[#huntTargets + 1] = {
        staticID = "rz_woi_s01e02",
        locationID = ZoneId.Red,
        data = {
            missionUnlockKey = "rz_fi_01",
            preHuntDialog = "rz_fi_01_log_005",
            positionSet = "District2",
            targetTemplate = BlackNetData.templateGroups.BlackWatch
        }
    }
    
    -- rz_woi_s01e03
    huntTargets[#huntTargets + 1] = {
        staticID = "rz_woi_s01e03",
        locationID = ZoneId.Red,
        data = {
            missionUnlockKey = "rz_vc_01",
            preHuntDialog = "rz_vc_01_log_005",
            positionSet = "District3",
            targetTemplate = BlackNetData.templateGroups.BlackWatch
        }
    }
    
    -- rz_woi_s02e01 (CagePeople)
    huntTargets[#huntTargets + 1] = {
        staticID = "rz_woi_s02e01",
        locationID = ZoneId.Red,
        data = {
            missionUnlockKey = "rz_re_01",
            preHuntDialog = "rz_re_01_log_005",
            positionSet = "District2",
            targetTemplate = BlackNetData.templateGroups.Evolved,
            smartnodeType = "CagePeople"
        }
    }
    
    -- rz_woi_s04e03
    huntTargets[#huntTargets + 1] = {
        staticID = "rz_woi_s04e03",
        locationID = ZoneId.Red,
        data = {
            missionUnlockKey = "rz_fi_02",
            preHuntDialog = "rz_fi_02_log_005",
            positionSet = "District2",
            targetTemplate = BlackNetData.templateGroups.Evolved
        }
    }
    
    -- rz_woi_s03e01
    huntTargets[#huntTargets + 1] = {
        staticID = "rz_woi_s03e01",
        locationID = ZoneId.Red,
        data = {
            missionUnlockKey = "rz_re_02",
            preHuntDialog = "rz_re_02_log_005",
            positionSet = "District1",
            targetTemplate = BlackNetData.templateGroups.BlackWatch
        }
    }
    
    -- rz_woi_s03e02 (TroopTransport)
    huntTargets[#huntTargets + 1] = {
        staticID = "rz_woi_s03e02",
        locationID = ZoneId.Red,
        data = {
            missionUnlockKey = "rz_vc_02",
            preHuntDialog = "rz_vc_02_log_005",
            positionSet = "District1",
            targetTemplate = BlackNetData.templateGroups.BlackWatch,
            smartnodeType = "TroopTransport"
        }
    }
    
    -- rz_woi_s04e01
    huntTargets[#huntTargets + 1] = {
        staticID = "rz_woi_s04e01",
        locationID = ZoneId.Red,
        data = {
            missionUnlockKey = "rz_sc_02",
            preHuntDialog = "rz_sc_02_log_005",
            positionSet = "District4",
            targetTemplate = BlackNetData.templateGroups.GenTek
        }
    }
    
    -- rz_woi_s04e02
    huntTargets[#huntTargets + 1] = {
        staticID = "rz_woi_s04e02",
        locationID = ZoneId.Red,
        data = {
            missionUnlockKey = "rz_it_02",
            preHuntDialog = "rz_it_02_log_005",
            positionSet = "District4",
            targetTemplate = BlackNetData.templateGroups.BlackWatch
        }
    }
    
    -- rz_woi_s02e02
    huntTargets[#huntTargets + 1] = {
        staticID = "rz_woi_s02e02",
        locationID = ZoneId.Red,
        data = {
            missionUnlockKey = "rz_it_01",
            preHuntDialog = "rz_it_01_log_005",
            positionSet = "District4",
            targetTemplate = BlackNetData.templateGroups.Evolved
        }
    }
    
    BlackNetData.mms_HuntTargetData = huntTargets
end

-- ============================================
-- НАБОРЫ ОХОТНИЧЬИХ ЦЕЛЕЙ (Hunt Target Sets)
-- ============================================

local function registerHuntTargetSets()
    local sets = {}
    
    -- Желтая зона - Set 1
    sets[#sets + 1] = {
        setID = "yz_woi_s01",
        locationID = ZoneId.Yellow,
        feIdentifier = "1",
        setReward = {
            Unlockable.Mutation_ThrowAttackDamageBoost,
            Unlockable.Mutation_AirAttackDamageBoost,
            Unlockable.Mutation_ComboDistanceBoost
        },
        members = { "yz_woi_s01e03" }
    }
    
    -- Желтая зона - Set 2
    sets[#sets + 1] = {
        setID = "yz_woi_s02",
        locationID = ZoneId.Yellow,
        feIdentifier = "2",
        setReward = {
            Unlockable.Mutation_HealthGainBoost,
            Unlockable.Mutation_SuspicionReduction
        },
        members = { "yz_woi_s01e01", "yz_woi_s01e02" }
    }
    
    -- Желтая зона - Set 3
    sets[#sets + 1] = {
        setID = "yz_woi_s03",
        locationID = ZoneId.Yellow,
        feIdentifier = "3",
        setReward = {
            Unlockable.Mutation_HealthBoost,
            Unlockable.Mutation_TimedBlockOpportunityBoost
        },
        members = { "yz_woi_s02e03" }
    }
    
    -- Желтая зона - Set 4
    sets[#sets + 1] = {
        setID = "yz_woi_s04",
        locationID = ZoneId.Yellow,
        feIdentifier = "4",
        setReward = {
            Unlockable.Mutation_JumpBoost,
            Unlockable.Mutation_AirDashDistanceBoost
        },
        members = { "yz_woi_s03e02", "yz_woi_s03e03" }
    }
    
    -- Зеленая зона - Set 1
    sets[#sets + 1] = {
        setID = "gz_woi_s01",
        locationID = ZoneId.Green,
        feIdentifier = "5",
        setReward = {
            Unlockable.Mutation_HealthGainBoost,
            Unlockable.Mutation_SuspicionReduction,
            Unlockable.Mutation_MeleeHitsGainMass,
            Unlockable.Mutation_ConsumeMassGainBoost,
            Unlockable.Mutation_StruggleRateBoost
        },
        members = { "gz_woi_s01e02", "gz_woi_s01e03" }
    }
    
    -- Зеленая зона - Set 2
    sets[#sets + 1] = {
        setID = "gz_woi_s02",
        locationID = ZoneId.Green,
        feIdentifier = "6",
        setReward = {
            Unlockable.Mutation_ImprovedBlackHole,
            Unlockable.Mutation_ImprovedPounce,
            Unlockable.Mutation_ImprovedTornado
        },
        members = { "gz_woi_s02e01", "gz_woi_s02e02", "gz_woi_s02e03" }
    }
    
    -- Зеленая зона - Set 3
    sets[#sets + 1] = {
        setID = "gz_woi_s03",
        locationID = ZoneId.Green,
        feIdentifier = "7",
        setReward = {
            Unlockable.Mutation_ThrowAttackDamageBoost,
            Unlockable.Mutation_AirAttackDamageBoost,
            Unlockable.Mutation_ComboDistanceBoost,
            Unlockable.Mutation_MeleeDamageBoost,
            Unlockable.Mutation_HumanFactionDamageBoost,
            Unlockable.Mutation_InfectedFactionDamageBoost,
            Unlockable.Mutation_DevastatorDamageBoost
        },
        members = { "gz_woi_s03e02", "gz_woi_s03e03" }
    }
    
    -- Зеленая зона - Set 4
    sets[#sets + 1] = {
        setID = "gz_woi_s04",
        locationID = ZoneId.Green,
        feIdentifier = "8",
        setReward = {
            Unlockable.Mutation_TacticalDodgeDistanceBoost,
            Unlockable.Mutation_DamageReduction,
            Unlockable.Mutation_HealthBoost,
            Unlockable.Mutation_TimedBlockOpportunityBoost,
            Unlockable.Mutation_DeflectBullets
        },
        members = { "gz_woi_s04e02", "gz_woi_s04e03" }
    }
    
    -- Красная зона - Set 1
    sets[#sets + 1] = {
        setID = "rz_woi_s01",
        locationID = ZoneId.Red,
        feIdentifier = "9",
        setReward = {
            Unlockable.Mutation_ThrowAttackDamageBoost,
            Unlockable.Mutation_AirAttackDamageBoost,
            Unlockable.Mutation_ComboDistanceBoost,
            Unlockable.Mutation_MeleeDamageBoost,
            Unlockable.Mutation_HumanFactionDamageBoost,
            Unlockable.Mutation_InfectedFactionDamageBoost,
            Unlockable.Mutation_DevastatorDamageBoost,
            Unlockable.Mutation_MilitaryAttackDamageBoost,
            Unlockable.Mutation_PackDamageBoost
        },
        members = { "rz_woi_s01e01", "rz_woi_s01e02", "rz_woi_s01e03" }
    }
    
    -- Красная зона - Set 2
    sets[#sets + 1] = {
        setID = "rz_woi_s02",
        locationID = ZoneId.Red,
        feIdentifier = "10",
        setReward = {
            Unlockable.Mutation_ImprovedBlackHole,
            Unlockable.Mutation_ImprovedPounce,
            Unlockable.Mutation_ImprovedTornado,
            Unlockable.Mutation_ImprovedLongShot,
            Unlockable.Mutation_ImprovedGroundSpike
        },
        members = { "rz_woi_s02e01", "rz_woi_s04e03" }
    }
    
    -- Красная зона - Set 3
    sets[#sets + 1] = {
        setID = "rz_woi_s03",
        locationID = ZoneId.Red,
        feIdentifier = "11",
        setReward = {
            Unlockable.Mutation_HealthGainBoost,
            Unlockable.Mutation_SuspicionReduction,
            Unlockable.Mutation_MeleeHitsGainMass,
            Unlockable.Mutation_ConsumeMassGainBoost,
            Unlockable.Mutation_StruggleRateBoost,
            Unlockable.Mutation_BioBombBoost,
            Unlockable.Mutation_MassAbilityActivateSpeedBoost
        },
        members = { "rz_woi_s03e01", "rz_woi_s03e02" }
    }
    
    -- Красная зона - Set 4
    sets[#sets + 1] = {
        setID = "rz_woi_s04",
        locationID = ZoneId.Red,
        feIdentifier = "12",
        setReward = {
            Unlockable.Mutation_ThrowAttackDamageBoost,
            Unlockable.Mutation_AirAttackDamageBoost,
            Unlockable.Mutation_ComboDistanceBoost,
            Unlockable.Mutation_MeleeDamageBoost,
            Unlockable.Mutation_HumanFactionDamageBoost,
            Unlockable.Mutation_InfectedFactionDamageBoost,
            Unlockable.Mutation_DevastatorDamageBoost,
            Unlockable.Mutation_MilitaryAttackDamageBoost,
            Unlockable.Mutation_PackDamageBoost
        },
        members = { "rz_woi_s04e01", "rz_woi_s04e02", "rz_woi_s02e02" }
    }
    
    BlackNetData.mms_HuntTargetSets = sets
end

-- ============================================
-- ЧЕРНЫЕ ЯЩИКИ (Black Boxes)
-- ============================================

local function registerBlackBoxes()
    local boxes = {}
    
    -- Зеленые ящики (gz_bb_01 - gz_bb_14)
    for i = 1, 14 do
        local id = string.format("gz_bb_%02d", i)
        boxes[#boxes + 1] = {
            staticID = id,
            locationID = ZoneId.Green
        }
    end
    
    -- Желтые ящики (yz_bb_01 - yz_bb_13)
    for i = 1, 13 do
        local id = string.format("yz_bb_%02d", i)
        boxes[#boxes + 1] = {
            staticID = id,
            locationID = ZoneId.Yellow
        }
    end
    
    -- Красные ящики (rz_bb_01 - rz_bb_18)
    for i = 1, 18 do
        local id = string.format("rz_bb_%02d", i)
        boxes[#boxes + 1] = {
            staticID = id,
            locationID = ZoneId.Red
        }
    end
    
    BlackNetData.mms_BlackBoxData = boxes
end

-- ============================================
-- НАБОРЫ ЧЕРНЫХ ЯЩИКОВ (Black Box Sets)
-- ============================================

local function registerBlackBoxSets()
    local sets = {}
    
    -- Зеленая зона - Set 1
    sets[#sets + 1] = {
        setID = "gz_bb_s01",
        locationID = ZoneId.Green,
        districtID = "gz_d01",
        setReward = {
            Unlockable.Mutation_HealthGainBoost,
            Unlockable.Mutation_SuspicionReduction,
            Unlockable.Mutation_MeleeHitsGainMass,
            Unlockable.Mutation_ConsumeMassGainBoost,
            Unlockable.Mutation_StruggleRateBoost
        },
        members = { "gz_bb_10", "gz_bb_11", "gz_bb_12", "gz_bb_13", "gz_bb_14" }
    }
    
    -- Зеленая зона - Set 2
    sets[#sets + 1] = {
        setID = "gz_bb_s02",
        locationID = ZoneId.Green,
        districtID = "gz_d02",
        setReward = {
            Unlockable.Mutation_TacticalDodgeDistanceBoost,
            Unlockable.Mutation_DamageReduction,
            Unlockable.Mutation_HealthBoost,
            Unlockable.Mutation_TimedBlockOpportunityBoost,
            Unlockable.Mutation_DeflectBullets
        },
        members = { "gz_bb_01", "gz_bb_02", "gz_bb_03", "gz_bb_04", "gz_bb_05" }
    }
    
    -- Зеленая зона - Set 3
    sets[#sets + 1] = {
        setID = "gz_bb_s03",
        locationID = ZoneId.Green,
        districtID = "gz_d03",
        setReward = {
            Unlockable.Mutation_ThrowAttackDamageBoost,
            Unlockable.Mutation_AirAttackDamageBoost,
            Unlockable.Mutation_ComboDistanceBoost,
            Unlockable.Mutation_MeleeDamageBoost,
            Unlockable.Mutation_HumanFactionDamageBoost,
            Unlockable.Mutation_InfectedFactionDamageBoost,
            Unlockable.Mutation_DevastatorDamageBoost
        },
        members = { "gz_bb_06", "gz_bb_07", "gz_bb_08", "gz_bb_09" }
    }
    
    -- Желтая зона - Set 1
    sets[#sets + 1] = {
        setID = "yz_bb_s01",
        locationID = ZoneId.Yellow,
        districtID = "yz_d01",
        setReward = {
            Unlockable.Mutation_SprintSpeedBoost,
            Unlockable.Mutation_SprintAccelerationBoost
        },
        members = { "yz_bb_01", "yz_bb_02", "yz_bb_03", "yz_bb_04" }
    }
    
    -- Желтая зона - Set 2
    sets[#sets + 1] = {
        setID = "yz_bb_s02",
        locationID = ZoneId.Yellow,
        districtID = "yz_d02",
        setReward = {
            Unlockable.Mutation_MeleeDamageBoost,
            Unlockable.Mutation_HumanFactionDamageBoost,
            Unlockable.Mutation_InfectedFactionDamageBoost
        },
        members = { "yz_bb_05", "yz_bb_06", "yz_bb_07", "yz_bb_08", "yz_bb_09" }
    }
    
    -- Желтая зона - Set 3
    sets[#sets + 1] = {
        setID = "yz_bb_s03",
        locationID = ZoneId.Yellow,
        districtID = "yz_d03",
        setReward = {
            Unlockable.Mutation_ThrowAttackDamageBoost,
            Unlockable.Mutation_AirAttackDamageBoost,
            Unlockable.Mutation_ComboDistanceBoost
        },
        members = { "yz_bb_10", "yz_bb_11", "yz_bb_12", "yz_bb_13" }
    }
    
    -- Красная зона - Set 1
    sets[#sets + 1] = {
        setID = "rz_bb_s01",
        locationID = ZoneId.Red,
        districtID = "rz_d01",
        setReward = {
            Unlockable.Mutation_ImprovedBlackHole,
            Unlockable.Mutation_ImprovedPounce,
            Unlockable.Mutation_ImprovedTornado,
            Unlockable.Mutation_ImprovedLongShot,
            Unlockable.Mutation_ImprovedGroundSpike
        },
        members = { "rz_bb_01", "rz_bb_02", "rz_bb_03", "rz_bb_04", "rz_bb_05", "rz_bb_06", "rz_bb_07" }
    }
    
    -- Красная зона - Set 2
    sets[#sets + 1] = {
        setID = "rz_bb_s02",
        locationID = ZoneId.Red,
        districtID = "rz_d02",
        setReward = {
            Unlockable.Mutation_HealthGainBoost,
            Unlockable.Mutation_SuspicionReduction,
            Unlockable.Mutation_MeleeHitsGainMass,
            Unlockable.Mutation_ConsumeMassGainBoost,
            Unlockable.Mutation_StruggleRateBoost,
            Unlockable.Mutation_BioBombBoost,
            Unlockable.Mutation_MassAbilityActivateSpeedBoost
        },
        members = { "rz_bb_08", "rz_bb_09", "rz_bb_10", "rz_bb_11", "rz_bb_12", "rz_bb_13" }
    }
    
    -- Красная зона - Set 3
    sets[#sets + 1] = {
        setID = "rz_bb_s03",
        locationID = ZoneId.Red,
        districtID = "rz_d03",
        setReward = {
            Unlockable.Mutation_TacticalDodgeDistanceBoost,
            Unlockable.Mutation_DamageReduction,
            Unlockable.Mutation_HealthBoost,
            Unlockable.Mutation_TimedBlockOpportunityBoost,
            Unlockable.Mutation_DeflectBullets,
            Unlockable.Mutation_SpineDamageBoost
        },
        members = { "rz_bb_14", "rz_bb_15", "rz_bb_16", "rz_bb_17", "rz_bb_18" }
    }
    
    BlackNetData.mms_BlackBoxSets = sets
end

-- ============================================
-- ЭСКАДРОНЫ СМЕРТИ (Death Squads)
-- ============================================

local function registerDeathSquads()
    local squads = {}
    
    local squadConfigs = {
        -- Зеленые
        { id = "gz_ds_01", zone = ZoneId.Green, fe = "fops1" },
        { id = "gz_ds_02", zone = ZoneId.Green, fe = "fops2" },
        { id = "gz_ds_03", zone = ZoneId.Green, fe = "fops3" },
        { id = "gz_ds_04", zone = ZoneId.Green, fe = "fops4" },
        { id = "gz_ds_05", zone = ZoneId.Green, fe = "fops5" },
        { id = "gz_ds_06", zone = ZoneId.Green, fe = "fops6" },
        { id = "gz_ds_07", zone = ZoneId.Green, fe = "fops7" },
        { id = "gz_ds_08", zone = ZoneId.Green, fe = "fops8" },
        -- Желтые
        { id = "yz_ds_01", zone = ZoneId.Yellow, fe = "fops9" },
        { id = "yz_ds_02", zone = ZoneId.Yellow, fe = "fops10" },
        { id = "yz_ds_03", zone = ZoneId.Yellow, fe = "fops11" },
        { id = "yz_ds_04", zone = ZoneId.Yellow, fe = "fops12" },
        { id = "yz_ds_05", zone = ZoneId.Yellow, fe = "fops13" },
        { id = "yz_ds_06", zone = ZoneId.Yellow, fe = "fops14" },
        { id = "yz_ds_07", zone = ZoneId.Yellow, fe = "fops15" },
        -- Красные
        { id = "rz_ds_01", zone = ZoneId.Red, fe = "fops16" },
        { id = "rz_ds_02", zone = ZoneId.Red, fe = "fops17" },
        { id = "rz_ds_03", zone = ZoneId.Red, fe = "fops18" },
        { id = "rz_ds_04", zone = ZoneId.Red, fe = "fops19" },
        { id = "rz_ds_05", zone = ZoneId.Red, fe = "fops20" },
        { id = "rz_ds_06", zone = ZoneId.Red, fe = "fops21" },
        { id = "rz_ds_07", zone = ZoneId.Red, fe = "fops22" },
        { id = "rz_ds_08", zone = ZoneId.Red, fe = "fops23" },
        { id = "rz_ds_09", zone = ZoneId.Red, fe = "fops24" },
        { id = "rz_ds_10", zone = ZoneId.Red, fe = "fops25" },
        { id = "rz_ds_11", zone = ZoneId.Red, fe = "fops26" },
        { id = "rz_ds_12", zone = ZoneId.Red, fe = "fops27" },
        { id = "rz_ds_13", zone = ZoneId.Red, fe = "fops28" },
    }
    
    for _, config in ipairs(squadConfigs) do
        squads[#squads + 1] = {
            staticID = config.id,
            locationID = config.zone,
            feIdentifier = config.fe
        }
    end
    
    BlackNetData.mms_DeathSquadData = squads
end

-- ============================================
-- НАБОРЫ ЭСКАДРОНОВ СМЕРТИ (Death Squad Sets)
-- ============================================

local function registerDeathSquadSets()
    local sets = {}
    
    -- Зеленая зона - Set 1
    sets[#sets + 1] = {
        setID = "gz_ds_s01",
        locationID = ZoneId.Green,
        districtID = "gz_d01",
        setReward = {
            Unlockable.Mutation_JumpBoost,
            Unlockable.Mutation_AirDashDistanceBoost,
            Unlockable.Mutation_SprintSpeedBoost,
            Unlockable.Mutation_SprintAccelerationBoost,
            Unlockable.Mutation_GlideDistanceBoost
        },
        members = { "gz_ds_01", "gz_ds_02", "gz_ds_03", "gz_ds_04" }
    }
    
    -- Зеленая зона - Set 2
    sets[#sets + 1] = {
        setID = "gz_ds_s02",
        locationID = ZoneId.Green,
        districtID = "gz_d02",
        setReward = {
            Unlockable.Mutation_HealthGainBoost,
            Unlockable.Mutation_SuspicionReduction,
            Unlockable.Mutation_MeleeHitsGainMass,
            Unlockable.Mutation_ConsumeMassGainBoost,
            Unlockable.Mutation_StruggleRateBoost
        },
        members = { "gz_ds_05", "gz_ds_06", "gz_ds_07", "gz_ds_08" }
    }
    
    -- Желтая зона - Set 1
    sets[#sets + 1] = {
        setID = "yz_ds_s01",
        locationID = ZoneId.Yellow,
        districtID = "yz_d01",
        setReward = {
            Unlockable.Mutation_MeleeDamageBoost,
            Unlockable.Mutation_HumanFactionDamageBoost,
            Unlockable.Mutation_InfectedFactionDamageBoost
        },
        members = { "yz_ds_01", "yz_ds_02", "yz_ds_03", "yz_ds_04" }
    }
    
    -- Желтая зона - Set 2
    sets[#sets + 1] = {
        setID = "yz_ds_s02",
        locationID = ZoneId.Yellow,
        districtID = "yz_d03",
        setReward = {
            Unlockable.Mutation_TacticalDodgeDistanceBoost,
            Unlockable.Mutation_DamageReduction
        },
        members = { "yz_ds_05", "yz_ds_06", "yz_ds_07" }
    }
    
    -- Красная зона - Set 1
    sets[#sets + 1] = {
        setID = "rz_ds_s01",
        locationID = ZoneId.Red,
        districtID = "rz_d02",
        setReward = {
            Unlockable.Mutation_ThrowAttackDamageBoost,
            Unlockable.Mutation_AirAttackDamageBoost,
            Unlockable.Mutation_ComboDistanceBoost,
            Unlockable.Mutation_MeleeDamageBoost,
            Unlockable.Mutation_HumanFactionDamageBoost,
            Unlockable.Mutation_InfectedFactionDamageBoost,
            Unlockable.Mutation_DevastatorDamageBoost,
            Unlockable.Mutation_MilitaryAttackDamageBoost,
            Unlockable.Mutation_PackDamageBoost
        },
        members = { "rz_ds_01", "rz_ds_02", "rz_ds_03", "rz_ds_04" }
    }
    
    -- Красная зона - Set 2
    sets[#sets + 1] = {
        setID = "rz_ds_s02",
        locationID = ZoneId.Red,
        districtID = "rz_d03",
        setReward = {
            Unlockable.Mutation_TacticalDodgeDistanceBoost,
            Unlockable.Mutation_DamageReduction,
            Unlockable.Mutation_HealthBoost,
            Unlockable.Mutation_TimedBlockOpportunityBoost,
            Unlockable.Mutation_DeflectBullets,
            Unlockable.Mutation_SpineDamageBoost
        },
        members = { "rz_ds_05", "rz_ds_06", "rz_ds_07", "rz_ds_08" }
    }
    
    -- Красная зона - Set 3
    sets[#sets + 1] = {
        setID = "rz_ds_s03",
        locationID = ZoneId.Red,
        districtID = "rz_d04",
        setReward = {
            Unlockable.Mutation_JumpBoost,
            Unlockable.Mutation_AirDashDistanceBoost,
            Unlockable.Mutation_SprintSpeedBoost,
            Unlockable.Mutation_SprintAccelerationBoost,
            Unlockable.Mutation_GlideDistanceBoost,
            Unlockable.Mutation_MoreAirDashes
        },
        members = { "rz_ds_09", "rz_ds_10", "rz_ds_11", "rz_ds_12", "rz_ds_13" }
    }
    
    BlackNetData.mms_DeathSquadSets = sets
end

-- ============================================
-- ЛОГОВА (Lairs)
-- ============================================

local function registerLairs()
    local lairs = {}
    
    local lairConfigs = {
        { id = "gz_la_01", zone = ZoneId.Green },
        { id = "gz_la_02", zone = ZoneId.Green },
        { id = "gz_la_03", zone = ZoneId.Green },
        { id = "gz_la_04", zone = ZoneId.Green },
        { id = "yz_la_01", zone = ZoneId.Yellow },
        { id = "rz_la_02", zone = ZoneId.Red },
        { id = "rz_la_04", zone = ZoneId.Red },
        { id = "rz_la_05", zone = ZoneId.Red },
        { id = "rz_la_06", zone = ZoneId.Red },
    }
    
    for _, config in ipairs(lairConfigs) do
        lairs[#lairs + 1] = {
            staticID = config.id,
            locationID = config.zone
        }
    end
    
    BlackNetData.mms_LairData = lairs
end

-- ============================================
-- НАБОРЫ ЛОГОВ (Lair Sets)
-- ============================================

local function registerLairSets()
    local sets = {}
    
    -- Зеленая зона - Set 1
    sets[#sets + 1] = {
        setID = "gz_la_s01",
        locationID = ZoneId.Green,
        districtID = "gz_d01",
        setReward = {
            Unlockable.Mutation_ImprovedBlackHole,
            Unlockable.Mutation_ImprovedPounce,
            Unlockable.Mutation_ImprovedTornado
        },
        members = { "gz_la_01", "gz_la_03" }
    }
    
    -- Зеленая зона - Set 2
    sets[#sets + 1] = {
        setID = "gz_la_s02",
        locationID = ZoneId.Green,
        districtID = "gz_d02",
        setReward = {
            Unlockable.Mutation_JumpBoost,
            Unlockable.Mutation_AirDashDistanceBoost,
            Unlockable.Mutation_SprintSpeedBoost,
            Unlockable.Mutation_SprintAccelerationBoost,
            Unlockable.Mutation_GlideDistanceBoost
        },
        members = { "gz_la_02", "gz_la_04" }
    }
    
    -- Желтая зона - Set 1
    sets[#sets + 1] = {
        setID = "yz_la_s01",
        locationID = ZoneId.Yellow,
        districtID = "yz_d03",
        setReward = {
            Unlockable.Mutation_MeleeHitsGainMass,
            Unlockable.Mutation_ConsumeMassGainBoost
        },
        members = { "yz_la_01" }
    }
    
    -- Красная зона - Set 1
    sets[#sets + 1] = {
        setID = "rz_la_s01",
        locationID = ZoneId.Red,
        districtID = "rz_d01",
        setReward = {
            Unlockable.Mutation_ImprovedBlackHole,
            Unlockable.Mutation_ImprovedPounce,
            Unlockable.Mutation_ImprovedTornado,
            Unlockable.Mutation_ImprovedLongShot,
            Unlockable.Mutation_ImprovedGroundSpike
        },
        members = { "rz_la_02", "rz_la_05" }
    }
    
    -- Красная зона - Set 2
    sets[#sets + 1] = {
        setID = "rz_la_s02",
        locationID = ZoneId.Red,
        districtID = "rz_d02",
        setReward = {
            Unlockable.Mutation_JumpBoost,
            Unlockable.Mutation_AirDashDistanceBoost,
            Unlockable.Mutation_SprintSpeedBoost,
            Unlockable.Mutation_SprintAccelerationBoost,
            Unlockable.Mutation_GlideDistanceBoost,
            Unlockable.Mutation_MoreAirDashes
        },
        members = { "rz_la_04", "rz_la_06" }
    }
    
    BlackNetData.mms_LairSets = sets
end

-- ============================================
-- СОБЫТИЯ (Events)
-- ============================================

local function registerEvents()
    local events = {}
    
    -- Желтая зона - Collateral Damage события
    local cdEvents = {
        { id = "yz_cd_01", platinum = 140, gold = 110, silver = 70, bronze = 32, stat = "Stat: Collateral Damage Event 1 Score" },
        { id = "yz_cd_02", platinum = 65, gold = 58, silver = 50, bronze = 35, stat = "Stat: Collateral Damage Event 2 Score" },
        { id = "yz_cd_03", platinum = 124, gold = 104, silver = 85, bronze = 45, stat = "Stat: Collateral Damage Event 3 Score" },
        { id = "yz_cd_04", platinum = 160, gold = 85, silver = 70, bronze = 55, stat = "Stat: Collateral Damage Event 4 Score" },
    }
    
    for _, ev in ipairs(cdEvents) do
        events[#events + 1] = {
            staticID = ev.id,
            locationID = ZoneId.Yellow,
            data = {
                platinum = ev.platinum,
                gold = ev.gold,
                silver = ev.silver,
                bronze = ev.bronze,
                ep_platinum = 2000,
                ep_gold = 1500,
                ep_silver = 1000,
                ep_bronze = 500,
                compStat = ev.stat,
                markerType = MARKER_TYPE.EVENT_CD,
                prerequisiteMission = "yz_fi_01"
            }
        }
    end
    
    -- Rampage события
    local rampageEvents = {
        { id = "gz_ra_01", zone = ZoneId.Green, plat = 110000, gold = 80000, silver = 50000, bronze = 30000, prereq = "story_d3" },
        { id = "rz_ra_01", zone = ZoneId.Red, plat = 140000, gold = 85000, silver = 50000, bronze = 38000, prereq = "story_l3" },
        { id = "yz_ra_01", zone = ZoneId.Yellow, plat = 70000, gold = 30000, silver = 24000, bronze = 15000, prereq = "story_l2" },
        { id = "yz_ra_02", zone = ZoneId.Yellow, plat = 70000, gold = 45000, silver = 35000, bronze = 28000, prereq = "story_b2" },
    }
    
    for _, ev in ipairs(rampageEvents) do
        events[#events + 1] = {
            staticID = ev.id,
            locationID = ev.zone,
            data = {
                platinum = ev.plat,
                gold = ev.gold,
                silver = ev.silver,
                bronze = ev.bronze,
                ep_platinum = 2000,
                ep_gold = 1500,
                ep_silver = 1000,
                ep_bronze = 500,
                compStat = string.format("Stat: Rampage Event %d Score", #rampageEvents),
                markerType = MARKER_TYPE.EVENT_RA,
                prerequisiteMission = ev.prereq
            }
        }
    end
    
    -- Recovery Race события
    local rrEvents = {
        { id = "rz_rr_01", zone = ZoneId.Red, plat = 76000, gold = 83000, silver = 90000, bronze = 95000, prereq = "story_l3" },
        { id = "rz_rr_02", zone = ZoneId.Red, plat = 88000, gold = 92000, silver = 98000, bronze = 115000, prereq = "story_l3" },
        { id = "yz_rr_01", zone = ZoneId.Yellow, plat = 88000, gold = 96000, silver = 101000, bronze = 107000, prereq = "yz_fi_01" },
        { id = "gz_rr_01", zone = ZoneId.Green, plat = 72000, gold = 79000, silver = 85000, bronze = 92000, prereq = "story_l2" },
    }
    
    for _, ev in ipairs(rrEvents) do
        events[#events + 1] = {
            staticID = ev.id,
            locationID = ev.zone,
            data = {
                platinum = ev.plat,
                gold = ev.gold,
                silver = ev.silver,
                bronze = ev.bronze,
                ep_platinum = 2000,
                ep_gold = 1500,
                ep_silver = 1000,
                ep_bronze = 500,
                compStat = string.format("Stat: Recovery Race Event %d Score", #rrEvents),
                markerType = MARKER_TYPE.EVENT_RR,
                prerequisiteMission = ev.prereq
            }
        }
    end
    
    -- Chopper Race события
    local crEvents = {
        { id = "rz_cr_01", zone = ZoneId.Red, plat = 77000, gold = 79000, silver = 85000, bronze = 105000, prereq = "story_l3" },
        { id = "rz_cr_02", zone = ZoneId.Red, plat = 79000, gold = 82000, silver = 85000, bronze = 100000, prereq = "story_l3" },
        { id = "yz_cr_01", zone = ZoneId.Yellow, plat = 74000, gold = 77000, silver = 81000, bronze = 90000, prereq = "story_l3" },
        { id = "yz_cr_02", zone = ZoneId.Yellow, plat = 74000, gold = 77000, silver = 81000, bronze = 90000, prereq = "story_l3" },
    }
    
    for _, ev in ipairs(crEvents) do
        events[#events + 1] = {
            staticID = ev.id,
            locationID = ev.zone,
            data = {
                platinum = ev.plat,
                gold = ev.gold,
                silver = ev.silver,
                bronze = ev.bronze,
                ep_platinum = 2000,
                ep_gold = 1500,
                ep_silver = 1000,
                ep_bronze = 500,
                compStat = string.format("Stat: Chopper Race Event %d Score", #crEvents),
                markerType = MARKER_TYPE.EVENT_CR,
                prerequisiteMission = ev.prereq
            }
        }
    end
    
    -- Stockpile события
    local spEvents = {
        { id = "gz_sp_01", zone = ZoneId.Green, plat = 58000, gold = 65000, silver = 85000, bronze = 115000, prereq = "story_l2" },
        { id = "gz_sp_02", zone = ZoneId.Green, plat = 60000, gold = 84000, silver = 94000, bronze = 116000, prereq = "story_l2" },
        { id = "yz_sp_01", zone = ZoneId.Yellow, plat = 60000, gold = 76000, silver = 86000, bronze = 120000, prereq = "yz_fi_01" },
        { id = "rz_sp_01", zone = ZoneId.Red, plat = 48000, gold = 53000, silver = 65000, bronze = 105000, prereq = "story_l3" },
    }
    
    for _, ev in ipairs(spEvents) do
        events[#events + 1] = {
            staticID = ev.id,
            locationID = ev.zone,
            data = {
                platinum = ev.plat,
                gold = ev.gold,
                silver = ev.silver,
                bronze = ev.bronze,
                ep_platinum = 2000,
                ep_gold = 1500,
                ep_silver = 1000,
                ep_bronze = 500,
                compStat = string.format("Stat: Stockpile Event %d Score", #spEvents),
                markerType = MARKER_TYPE.EVENT_SP,
                prerequisiteMission = ev.prereq
            }
        }
    end
    
    -- Статистические события (для отслеживания)
    local statEvents = {
        "Stat: Devastator Kills",
        "Stat: Tactical Hits",
        "Stat: Grenade Launcher Kills",
        "Stat: Hammer Fist Kills",
        "Stat: Bio Bomb Kills",
        "Stat: Helicopter Rocket Kills",
        "Stat: Toxic Tank Infections",
        "Stat: Strike Team Kill Time",
        "Stat: Longest Glide",
        "Stat: Ped Thrown"
    }
    
    for _, stat in ipairs(statEvents) do
        events[#events + 1] = {
            staticID = stat,
            locationID = ZoneId.Yellow,
            data = {}
        }
    end
    
    BlackNetData.mms_EventData = events
end

-- ============================================
-- НАБОРЫ СОБЫТИЙ (Event Sets)
-- ============================================

local function registerEventSets()
    local sets = {}
    
    -- Week 1
    sets[#sets + 1] = {
        setID = "ev_s01",
        locationID = ZoneId.Yellow,
        achievement = "Complete Week 1",
        setReward = {
            Unlockable.Opsticky_Video1,
            Unlockable.Mutation_EPOnKillBoost
        },
        members = {
            "yz_cd_01", "yz_cd_02", "yz_rr_01", "gz_rr_01",
            "Stat: Tactical Hits", "Stat: Grenade Launcher Kills"
        }
    }
    
    -- Week 2
    sets[#sets + 1] = {
        setID = "ev_s02",
        locationID = ZoneId.Yellow,
        achievement = "Complete Week 2",
        setReward = {
            Unlockable.Opsticky_Video2,
            Unlockable.Mutation_ConsumeSooner
        },
        members = {
            "yz_ra_01", "yz_ra_02", "gz_sp_02", "yz_sp_01",
            "Stat: Hammer Fist Kills", "Stat: Ped Thrown"
        }
    }
    
    -- Week 3
    sets[#sets + 1] = {
        setID = "ev_s03",
        locationID = ZoneId.Yellow,
        achievement = "Complete Week 3",
        setReward = {
            Unlockable.Opsticky_Video3,
            Unlockable.Mutation_PackLeaderHealthBoost
        },
        members = {
            "yz_cd_03", "gz_ra_01", "rz_rr_01", "gz_sp_01",
            "Stat: Devastator Kills", "Stat: Longest Glide"
        }
    }
    
    -- Week 4
    sets[#sets + 1] = {
        setID = "ev_s04",
        locationID = ZoneId.Red,
        achievement = "Complete Week 4",
        setReward = {
            Unlockable.Opsticky_Video4,
            Unlockable.Mutation_HealthRegenWhileBlocking
        },
        members = {
            "rz_rr_02", "rz_cr_01", "rz_cr_02", "rz_sp_01",
            "Stat: Bio Bomb Kills", "Stat: Helicopter Rocket Kills"
        }
    }
    
    -- Week 5
    sets[#sets + 1] = {
        setID = "ev_s05",
        locationID = ZoneId.Yellow,
        achievement = "Complete Week 5",
        setReward = {
            Unlockable.Opsticky_Video5,
            Unlockable.Mutation_FloatTimeAtPeakOfJump
        },
        members = {
            "yz_cd_04", "rz_ra_01", "yz_cr_01", "yz_cr_02",
            "Stat: Toxic Tank Infections", "Stat: Strike Team Kill Time"
        }
    }
    
    BlackNetData.mms_EventSets = sets
end

-- ============================================
-- ВЫПОЛНЕНИЕ ВСЕХ РЕГИСТРАЦИЙ
-- ============================================

registerHuntTargets()
registerHuntTargetSets()
registerBlackBoxes()
registerBlackBoxSets()
registerDeathSquads()
registerDeathSquadSets()
registerLairs()
registerLairSets()
registerEvents()
registerEventSets()