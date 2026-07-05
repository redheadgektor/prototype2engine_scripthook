-- ============================================
-- Миссии и зоны
-- ============================================

local function registerMission(missionData)
    local missionTable = {}
    
    -- Красная зона - RZ_CR
    missionTable.rz_cr_02 = {
        location = "red_zone",
        tags = {"event", "chopper"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.rz_cr_01 = {
        location = "red_zone",
        tags = {"event", "chopper"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    -- Тестовые зоны
    missionTable.test_props = {
        location = "prop_content_test",
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.test_prop_green = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None"
    }
    
    -- Желтая зона - структуры
    missionTable.structure_yellow_facility_interior_164 = {
        location = "yellow_zone",
        tags = {"structureYellow"},
        openDependency = "_structureYellowCheckpoint",
        activeDependency = "None",
        concurrencyList = {"_structureYellowCheckpoint"}
    }
    
    missionTable.structure_yellow_checkpoint004 = {
        location = "yellow_zone",
        tags = {"structureYellowCheckpoint"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    -- Красная зона - складирование
    missionTable.rz_sp_01 = {
        location = "red_zone",
        tags = {"event", "stockpile"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    -- Зеленая зона - логово
    missionTable.structure_green_lair_interior_test_v_c_1 = {
        location = "green_zone",
        tags = {"structureGreen"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.structure_yellow_checkpoint001 = {
        location = "yellow_zone",
        tags = {"structureYellowCheckpoint"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    -- Тестовые шейдеры
    missionTable.test_shaders_green = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_autotest_green_zone = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.gz_m001 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_combat_interior = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None"
    }
    
    missionTable.meta_red = {
        location = "red_zone",
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.test_prop_yellow = {
        location = "yellow_zone",
        openDependency = "_structureYellow",
        activeDependency = "None"
    }
    
    missionTable.test_combat_2 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None"
    }
    
    missionTable.yz_sp_01 = {
        location = "yellow_zone",
        tags = {"event", "stockpile"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    -- Сюжетные миссии
    missionTable.story_FinalBoss = {
        location = "red_zone",
        tags = {"story"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.test_minimal = {
        location = "minimal"
    }
    
    missionTable.test_autotest_red_zone = {
        location = "red_zone",
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.test_prop_sandbox = {
        location = "prop_sandbox",
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.ms8_character_test = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None"
    }
    
    missionTable.test_infected = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.story_h1 = {
        location = "red_zone",
        tags = {"story"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.test_recovery_2 = {
        location = "red_zone",
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.structure_green_lair_interior_253 = {
        location = "green_zone",
        tags = {"structureGreen"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.structure_yellow_lair_interior_it_02 = {
        location = "yellow_zone",
        tags = {"structureYellow"},
        openDependency = "_structureYellowCheckpoint",
        activeDependency = "None",
        concurrencyList = {"_structureYellowCheckpoint"}
    }
    
    missionTable.test_recovery_3 = {
        location = "red_zone",
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    -- События восстановления
    missionTable.gz_rr_01 = {
        location = "green_zone",
        tags = {"event", "recovery"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    -- Логова зеленой зоны
    missionTable.gz_la_02 = {
        location = "green_zone",
        tags = {"lair"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.gz_la_03 = {
        location = "green_zone",
        tags = {"lair"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.gz_la_01 = {
        location = "green_zone",
        tags = {"lair"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    -- Черная сеть
    missionTable.gz_it_01 = {
        location = "green_zone",
        tags = {"blacknet"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.gz_la_04 = {
        location = "green_zone",
        tags = {"lair"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.structure_yellow_checkpoint002 = {
        location = "yellow_zone",
        tags = {"structureYellowCheckpoint"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.test_infected_transport_4 = {
        location = "red_zone",
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.structure_red_lair_interior_315 = {
        location = "red_zone",
        tags = {"structureRed"},
        openDependency = "_structureRedHotSpots",
        activeDependency = "None",
        concurrencyList = {"_structureRedHotSpots"}
    }
    
    missionTable.test_infected_transport_1 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.yz_rr_01 = {
        location = "yellow_zone",
        tags = {"event", "recovery"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.test_infected_transport_3 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.meta_yellow = {
        location = "yellow_zone",
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.test_stockpile_2 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.location_red = {
        location = "red_zone",
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.location_green_empty = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None"
    }
    
    -- События коллатерального ущерба
    missionTable.yz_cd_04 = {
        location = "yellow_zone",
        tags = {"event", "collateral"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.story_a1 = {
        location = "yellow_zone",
        tags = {"story"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.yz_cd_01 = {
        location = "yellow_zone",
        tags = {"event", "collateral"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.story_a3 = {
        location = "yellow_zone",
        tags = {"story"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.story_a2 = {
        location = "yellow_zone",
        tags = {"story"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.yz_cd_03 = {
        location = "yellow_zone",
        tags = {"event", "collateral"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.yz_m001 = {
        location = "yellow_zone",
        openDependency = "_structureYellow",
        activeDependency = "None"
    }
    
    missionTable.structure_red_bunker_interior_214 = {
        location = "red_zone",
        tags = {"structureRed"},
        openDependency = "_structureRedHotSpots",
        activeDependency = "None",
        concurrencyList = {"_structureRedHotSpots"}
    }
    
    missionTable.test_infection_green = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_scientist_consume_5 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.hex_test = {
        location = "Test_Hex"
    }
    
    missionTable.rz_rr_02 = {
        location = "red_zone",
        tags = {"event", "recovery"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.test_ambient_vehicles = {
        location = "loco_test_bed",
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.rz_rr_01 = {
        location = "red_zone",
        tags = {"event", "recovery"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.test_scientist_consume_1 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.story_i1 = {
        location = "red_zone",
        tags = {"story"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.yz_vc_02 = {
        location = "yellow_zone",
        tags = {"blacknet"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.story_i3 = {
        location = "red_zone",
        tags = {"story"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.test_prop_store = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_vc1 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_apc_tank_race = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.structure_green_lair_interior_test_s_c_4 = {
        location = "green_zone",
        tags = {"structureGreen"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.location_red_empty = {
        location = "red_zone",
        openDependency = "_structureRed",
        activeDependency = "None"
    }
    
    missionTable.test_vehicles = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_vip_hunting = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.structure_red_lair_interior_306 = {
        location = "red_zone",
        tags = {"structureRed"},
        openDependency = "_structureRedHotSpots",
        activeDependency = "None",
        concurrencyList = {"_structureRedHotSpots"}
    }
    
    missionTable.structure_yellow_military_interior_245 = {
        location = "yellow_zone",
        tags = {"structureYellow"},
        openDependency = "_structureYellowCheckpoint",
        activeDependency = "None",
        concurrencyList = {"_structureYellowCheckpoint"}
    }
    
    missionTable.test_nis_autotest = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None"
    }
    
    missionTable.structure_yellow_lair_interior_s_c_02 = {
        location = "yellow_zone",
        tags = {"structureYellow"},
        openDependency = "_structureYellowCheckpoint",
        activeDependency = "None",
        concurrencyList = {"_structureYellowCheckpoint"}
    }
    
    missionTable.test_vehicle_commander_2 = {
        location = "red_zone",
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.structure_red_blackwatch_interior_94 = {
        location = "red_zone",
        tags = {"structureRed"},
        openDependency = "_structureRedHotSpots",
        activeDependency = "None",
        concurrencyList = {"_structureRedHotSpots"}
    }
    
    missionTable.test_jump = {
        location = "loco_test_bed",
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.gz_vc_02 = {
        location = "green_zone",
        tags = {"blacknet"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.structure_green_lair_interior_304 = {
        location = "green_zone",
        tags = {"structureGreen"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.gz_vc_01 = {
        location = "green_zone",
        tags = {"blacknet"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.story_f1 = {
        location = "green_zone",
        tags = {"story"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.story_f2 = {
        location = "green_zone",
        tags = {"story"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.structure_yellow_lair_interior_yz_ra_01 = {
        location = "yellow_zone",
        tags = {"structureYellow"},
        openDependency = "_structureYellowCheckpoint",
        activeDependency = "None",
        concurrencyList = {"_structureYellowCheckpoint"}
    }
    
    missionTable.test_nis_yellow = {
        location = "yellow_zone",
        openDependency = "_structureYellow",
        activeDependency = "None"
    }
    
    missionTable.location_green = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_lars = {
        location = "green_zone",
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.yz_sc_01 = {
        location = "yellow_zone",
        tags = {"blacknet"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.test_audio = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_prop_red = {
        location = "red_zone",
        openDependency = "_structureRed",
        activeDependency = "None"
    }
    
    missionTable.test_optimization = {
        location = "loco_test_bed",
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.rz_it_02 = {
        location = "red_zone",
        tags = {"blacknet"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.rz_it_01 = {
        location = "red_zone",
        tags = {"blacknet"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.yz_fi_01 = {
        location = "yellow_zone",
        tags = {"blacknet"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.story_l2 = {
        location = "green_zone",
        tags = {"story"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.story_l3 = {
        location = "red_zone",
        tags = {"story"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.story_l1 = {
        location = "yellow_zone",
        tags = {"story"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.structure_yellow_blackwatch_interior_204 = {
        location = "yellow_zone",
        tags = {"structureYellow"},
        openDependency = "_structureYellowCheckpoint",
        activeDependency = "None",
        concurrencyList = {"_structureYellowCheckpoint"}
    }
    
    missionTable.test_nis_green = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None"
    }
    
    missionTable.rz_ra_01 = {
        location = "red_zone",
        tags = {"event", "rampage"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.test_scientist = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_infection_red = {
        location = "red_zone",
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.test_combat_military = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None"
    }
    
    missionTable.test_combat_infected = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None"
    }
    
    missionTable.structure_yellow_checkpoint003 = {
        location = "yellow_zone",
        tags = {"structureYellowCheckpoint"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.story_g3 = {
        location = "red_zone",
        tags = {"story"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.story_g2 = {
        location = "red_zone",
        tags = {"story"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.story_g1 = {
        location = "red_zone",
        tags = {"story"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.test_facility_infiltration_1 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_combatTestBed = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None"
    }
    
    missionTable.structure_yellow_facility_interior_135 = {
        location = "yellow_zone",
        tags = {"structureYellow"},
        openDependency = "_structureYellowCheckpoint",
        activeDependency = "None",
        concurrencyList = {"_structureYellowCheckpoint"}
    }
    
    missionTable.gz_sc_02 = {
        location = "green_zone",
        tags = {"blacknet"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.story_m1 = {
        location = "yellow_zone",
        tags = {"story"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.story_m3 = {
        location = "red_zone",
        tags = {"story"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.story_m2 = {
        location = "green_zone",
        tags = {"story"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.rz_la_05 = {
        location = "red_zone",
        tags = {"lair"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.rz_la_04 = {
        location = "red_zone",
        tags = {"lair"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.test_combat_3way = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None"
    }
    
    missionTable.rz_la_06 = {
        location = "red_zone",
        tags = {"lair"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.test_recovery_4 = {
        location = "red_zone",
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.test_gray01 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.rz_la_02 = {
        location = "red_zone",
        tags = {"lair"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.yz_ra_01 = {
        location = "yellow_zone",
        tags = {"event", "rampage"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.structure_green_lair_interior_294 = {
        location = "green_zone",
        tags = {"structureGreen"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.yz_cd_02 = {
        location = "yellow_zone",
        tags = {"event", "collateral"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.structure_red_hotspot001 = {
        location = "red_zone",
        tags = {"structureRedHotSpots"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    -- Группы зеленой зоны
    missionTable.structure_green_group004 = {
        location = "green_zone",
        tags = {"structureGreen"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.structure_green_group001 = {
        location = "green_zone",
        tags = {"structureGreen"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.structure_green_group003 = {
        location = "green_zone",
        tags = {"structureGreen"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.structure_green_group002 = {
        location = "green_zone",
        tags = {"structureGreen"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.test_nis = {
        location = "red_zone",
        openDependency = "_structureRed",
        activeDependency = "None"
    }
    
    -- Группы красной зоны
    missionTable.structure_red_group006 = {
        location = "red_zone",
        tags = {"structureRed"},
        openDependency = "_structureRedHotSpots",
        activeDependency = "None",
        concurrencyList = {"_structureRedHotSpots"}
    }
    
    missionTable.structure_red_group005 = {
        location = "red_zone",
        tags = {"structureRed"},
        openDependency = "_structureRedHotSpots",
        activeDependency = "None",
        concurrencyList = {"_structureRedHotSpots"}
    }
    
    missionTable.structure_red_blackwatch_interior_253 = {
        location = "red_zone",
        tags = {"structureRed"},
        openDependency = "_structureRedHotSpots",
        activeDependency = "None",
        concurrencyList = {"_structureRedHotSpots"}
    }
    
    missionTable.structure_red_group003 = {
        location = "red_zone",
        tags = {"structureRed"},
        openDependency = "_structureRedHotSpots",
        activeDependency = "None",
        concurrencyList = {"_structureRedHotSpots"}
    }
    
    missionTable.structure_red_group002 = {
        location = "red_zone",
        tags = {"structureRed"},
        openDependency = "_structureRedHotSpots",
        activeDependency = "None",
        concurrencyList = {"_structureRedHotSpots"}
    }
    
    missionTable.structure_red_group001 = {
        location = "red_zone",
        tags = {"structureRed"},
        openDependency = "_structureRedHotSpots",
        activeDependency = "None",
        concurrencyList = {"_structureRedHotSpots"}
    }
    
    missionTable.yz_la_01 = {
        location = "yellow_zone",
        tags = {"lair"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.structure_red_group004 = {
        location = "red_zone",
        tags = {"structureRed"},
        openDependency = "_structureRedHotSpots",
        activeDependency = "None",
        concurrencyList = {"_structureRedHotSpots"}
    }
    
    missionTable.story_d3 = {
        location = "green_zone",
        tags = {"story"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.structure_red_facility_interior_it_01 = {
        location = "red_zone",
        tags = {"structureRed"},
        openDependency = "_structureRedHotSpots",
        activeDependency = "None",
        concurrencyList = {"_structureRedHotSpots"}
    }
    
    missionTable.test_personnel = {
        location = "loco_test_bed"
    }
    
    missionTable.rz_sc_01 = {
        location = "red_zone",
        tags = {"blacknet"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.rz_sc_02 = {
        location = "red_zone",
        tags = {"blacknet"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.yz_it_01 = {
        location = "yellow_zone",
        tags = {"blacknet"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.gz_fi_01 = {
        location = "green_zone",
        tags = {"blacknet"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.gz_fi_02 = {
        location = "green_zone",
        tags = {"blacknet"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.story_l3pre = {
        location = "green_zone",
        tags = {"story"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.story_intro1 = {
        location = "red_zone",
        tags = {"story"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.story_intro2 = {
        location = "red_zone",
        tags = {"story"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.test_gray02 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_infected_transport_2 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_loco = {
        location = "loco_test_bed"
    }
    
    missionTable.gz_re_01 = {
        location = "green_zone",
        tags = {"blacknet"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.gz_re_02 = {
        location = "green_zone",
        tags = {"blacknet"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.gz_re_03 = {
        location = "green_zone",
        tags = {"blacknet"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.rz_re_02 = {
        location = "red_zone",
        tags = {"blacknet"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.gz_sp_02 = {
        location = "green_zone",
        tags = {"event", "stockpile"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.gz_sp_01 = {
        location = "green_zone",
        tags = {"event", "stockpile"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.rz_re_01 = {
        location = "red_zone",
        tags = {"blacknet"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.yz_cr_02 = {
        location = "yellow_zone",
        tags = {"event", "chopper"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.location_yellow_empty = {
        location = "yellow_zone",
        openDependency = "_structureYellow",
        activeDependency = "None"
    }
    
    missionTable.story_e1 = {
        location = "green_zone",
        tags = {"story"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_scientist_consume_4 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.story_e3 = {
        location = "green_zone",
        tags = {"story"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.story_e2 = {
        location = "green_zone",
        tags = {"story"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_infection_yellow = {
        location = "yellow_zone",
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.test_scientist_consume_3 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_scientist_consume_2 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_aidan = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.yz_cr_01 = {
        location = "yellow_zone",
        tags = {"event", "chopper"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.test_behemoth = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None"
    }
    
    missionTable.ow_red_black_net_hunt_target = {
        location = "red_zone",
        tags = {"hunt"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.test_autotest_yellow_zone = {
        location = "yellow_zone",
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.structure_yellow_group003 = {
        location = "yellow_zone",
        tags = {"structureYellow"},
        openDependency = "_structureYellowCheckpoint",
        activeDependency = "None",
        concurrencyList = {"_structureYellowCheckpoint"}
    }
    
    missionTable.structure_yellow_group002 = {
        location = "yellow_zone",
        tags = {"structureYellow"},
        openDependency = "_structureYellowCheckpoint",
        activeDependency = "None",
        concurrencyList = {"_structureYellowCheckpoint"}
    }
    
    missionTable.structure_yellow_group001 = {
        location = "yellow_zone",
        tags = {"structureYellow"},
        openDependency = "_structureYellowCheckpoint",
        activeDependency = "None",
        concurrencyList = {"_structureYellowCheckpoint"}
    }
    
    missionTable.test_markers = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.structure_yellow_group005 = {
        location = "yellow_zone",
        tags = {"structureYellow"},
        openDependency = "_structureYellowCheckpoint",
        activeDependency = "None",
        concurrencyList = {"_structureYellowCheckpoint"}
    }
    
    missionTable.structure_yellow_group004 = {
        location = "yellow_zone",
        tags = {"structureYellow"},
        openDependency = "_structureYellowCheckpoint",
        activeDependency = "None",
        concurrencyList = {"_structureYellowCheckpoint"}
    }
    
    missionTable.rz_m001 = {
        location = "red_zone",
        openDependency = "_structureRed",
        activeDependency = "None"
    }
    
    missionTable.structure_yellow_facility_interior_94 = {
        location = "yellow_zone",
        tags = {"structureYellow"},
        openDependency = "_structureYellowB",
        activeDependency = "None",
        concurrencyList = {"_structureYellowB"}
    }
    
    missionTable.structure_green_blackwatch_interior_275 = {
        location = "green_zone",
        tags = {"structureGreen"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.test_objective_templates = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None"
    }
    
    missionTable.test_jak = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_scripted_checkpoints = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None"
    }
    
    missionTable.yz_ra_02 = {
        location = "yellow_zone",
        tags = {"event", "rampage"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.test_black_box_manager = {
        location = "green_zone",
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.ow_green_black_net_hunt_target = {
        location = "green_zone",
        tags = {"hunt"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.Red_Zone_Press = {
        location = "red_zone",
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.story_b2 = {
        location = "yellow_zone",
        tags = {"story"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.story_b3 = {
        location = "yellow_zone",
        tags = {"story"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.test_combat_3 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None"
    }
    
    missionTable.gz_ra_01 = {
        location = "green_zone",
        tags = {"event", "rampage"},
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.test_combat_1 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None"
    }
    
    missionTable.test_rampage01 = {
        location = "yellow_zone",
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.meta_green = {
        location = "green_zone",
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.ow_yellow_black_net_hunt_target = {
        location = "yellow_zone",
        tags = {"hunt"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.story_l2pre = {
        location = "yellow_zone",
        tags = {"story"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.test_facility_infiltration_2 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.rz_vc_01 = {
        location = "red_zone",
        tags = {"blacknet"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.test_recovery_1 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.rz_vc_02 = {
        location = "red_zone",
        tags = {"blacknet"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.test_shaders_yellow = {
        location = "yellow_zone",
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.structure_green_facility_interior_185 = {
        location = "green_zone",
        tags = {"structureGreen"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.structure_green_facility_interior_113 = {
        location = "green_zone",
        tags = {"structureGreen"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.yz_it_02 = {
        location = "yellow_zone",
        tags = {"blacknet"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.test_vehicle_commander_1 = {
        location = "green_zone",
        openDependency = "_structureGreen",
        activeDependency = "None",
        concurrencyList = {"_structureGreen"}
    }
    
    missionTable.yz_vc_02_lair_interior = {
        location = "yellow_zone",
        tags = {"structureYellow"},
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.location_yellow = {
        location = "yellow_zone",
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.yz_re_01 = {
        location = "yellow_zone",
        tags = {"blacknet"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.story_c3 = {
        location = "yellow_zone",
        tags = {"story"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.story_c2 = {
        location = "yellow_zone",
        tags = {"story"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.story_c1 = {
        location = "yellow_zone",
        tags = {"story"},
        openDependency = "_structureYellow",
        activeDependency = "None",
        concurrencyList = {"_structureYellow"}
    }
    
    missionTable.test_shaders_red = {
        location = "red_zone",
        openDependency = "None",
        activeDependency = "None"
    }
    
    missionTable.rz_fi_02 = {
        location = "red_zone",
        tags = {"blacknet"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    missionTable.rz_fi_01 = {
        location = "red_zone",
        tags = {"blacknet"},
        openDependency = "_structureRed",
        activeDependency = "None",
        concurrencyList = {"_structureRed"}
    }
    
    return missionTable
end

-- ============================================
-- Создание таблицы миссий
-- ============================================

mm_MissionTable = registerMission()

-- ============================================
-- Коллекционируемые предметы
-- ============================================

mm_CollectiblesDef = {
    [WorldCollectibleType.HuntTarget] = {
        name = "HuntTargets",
        max = 128,
        requiresUnlocking = true
    },
    [WorldCollectibleType.BlackBox] = {
        name = "BlackBoxes",
        max = 45,
        requiresUnlocking = true
    },
    [WorldCollectibleType.DeathSquad] = {
        name = "DeathSquads",
        max = 28,
        requiresUnlocking = true
    },
    [WorldCollectibleType.AirBridge] = {
        name = "AirBridge",
        max = 10,
        requiresUnlocking = true
    },
    [WorldCollectibleType.Event] = {
        name = "Event",
        max = 50,
        requiresUnlocking = true
    },
    [WorldCollectibleType.Lair] = {
        name = "Lair",
        max = 9,
        requiresUnlocking = true,
        requiresDiscovery = true
    }
}

-- ============================================
-- Определение миссий
-- ============================================

mm_MissionsDef = {
    missions = mm_MissionTable
}

-- ============================================
-- Функции сброса и уничтожения миссий
-- ============================================

function mm_MissionVarReset()
    mm_ResetMissionVars(mm_MissionTable)
end

function mm_MissionVarDestroy()
    mm_DestroyMissionVars(mm_MissionTable)
end

-- ============================================
-- Регистрация коллекционируемых предметов и миссий
-- ============================================

mm_RegisterCollectibles(mm_CollectiblesDef)
mm_RegisterMissions(mm_MissionsDef)

-- ============================================
-- Список валидных миссий
-- ============================================

local function addAllValidMissions()
    local function addMission(name, location)
        AddValidMission(name, location)
    end
    
    -- Зеленые миссии
    addMission("gz_fi_01", "green_zone")
    addMission("gz_fi_02", "green_zone")
    addMission("gz_it_01", "green_zone")
    addMission("gz_la_01", "green_zone")
    addMission("gz_la_02", "green_zone")
    addMission("gz_la_03", "green_zone")
    addMission("gz_la_04", "green_zone")
    addMission("gz_m001", "green_zone")
    addMission("gz_ra_01", "green_zone")
    addMission("gz_re_01", "green_zone")
    addMission("gz_re_02", "green_zone")
    addMission("gz_re_03", "green_zone")
    addMission("gz_rr_01", "green_zone")
    addMission("gz_sc_02", "green_zone")
    addMission("gz_sp_01", "green_zone")
    addMission("gz_sp_02", "green_zone")
    addMission("gz_vc_01", "green_zone")
    addMission("gz_vc_02", "green_zone")
    addMission("location_green", "green_zone")
    addMission("location_green_empty", "green_zone")
    addMission("meta_green", "green_zone")
    addMission("ms8_character_test", "green_zone")
    addMission("ow_green_black_net_hunt_target", "green_zone")
    addMission("story_d3", "green_zone")
    addMission("story_e1", "green_zone")
    addMission("story_e2", "green_zone")
    addMission("story_e3", "green_zone")
    addMission("story_f1", "green_zone")
    addMission("story_f2", "green_zone")
    addMission("story_l2", "green_zone")
    addMission("story_l3pre", "green_zone")
    addMission("story_m2", "green_zone")
    addMission("structure_green_blackwatch_interior_275", "green_zone")
    addMission("structure_green_facility_interior_113", "green_zone")
    addMission("structure_green_facility_interior_185", "green_zone")
    addMission("structure_green_group001", "green_zone")
    addMission("structure_green_group002", "green_zone")
    addMission("structure_green_group003", "green_zone")
    addMission("structure_green_group004", "green_zone")
    addMission("structure_green_lair_interior_253", "green_zone")
    addMission("structure_green_lair_interior_294", "green_zone")
    addMission("structure_green_lair_interior_304", "green_zone")
    addMission("structure_green_lair_interior_test_s_c_4", "green_zone")
    addMission("structure_green_lair_interior_test_v_c_1", "green_zone")
    addMission("test_aidan", "green_zone")
    addMission("test_apc_tank_race", "green_zone")
    addMission("test_audio", "green_zone")
    addMission("test_autotest_green_zone", "green_zone")
    addMission("test_behemoth", "green_zone")
    addMission("test_black_box_manager", "green_zone")
    addMission("test_combatTestBed", "green_zone")
    addMission("test_combat_1", "green_zone")
    addMission("test_combat_2", "green_zone")
    addMission("test_combat_3", "green_zone")
    addMission("test_combat_3way", "green_zone")
    addMission("test_combat_infected", "green_zone")
    addMission("test_combat_interior", "green_zone")
    addMission("test_combat_military", "green_zone")
    addMission("test_facility_infiltration_1", "green_zone")
    addMission("test_facility_infiltration_2", "green_zone")
    addMission("test_gray01", "green_zone")
    addMission("test_gray02", "green_zone")
    addMission("test_infected", "green_zone")
    addMission("test_infected_transport_1", "green_zone")
    addMission("test_infected_transport_2", "green_zone")
    addMission("test_infected_transport_3", "green_zone")
    addMission("test_infection_green", "green_zone")
    addMission("test_jak", "green_zone")
    addMission("test_lars", "green_zone")
    addMission("test_markers", "green_zone")
    addMission("test_nis_autotest", "green_zone")
    addMission("test_nis_green", "green_zone")
    addMission("test_objective_templates", "green_zone")
    addMission("test_prop_green", "green_zone")
    addMission("test_prop_store", "green_zone")
    addMission("test_recovery_1", "green_zone")
    addMission("test_scientist", "green_zone")
    addMission("test_scientist_consume_1", "green_zone")
    addMission("test_scientist_consume_2", "green_zone")
    addMission("test_scientist_consume_3", "green_zone")
    addMission("test_scientist_consume_4", "green_zone")
    addMission("test_scientist_consume_5", "green_zone")
    addMission("test_scripted_checkpoints", "green_zone")
    addMission("test_shaders_green", "green_zone")
    addMission("test_stockpile_2", "green_zone")
    addMission("test_vc1", "green_zone")
    addMission("test_vehicle_commander_1", "green_zone")
    addMission("test_vehicles", "green_zone")
    addMission("test_vip_hunting", "green_zone")
    
    -- Красные миссии
    addMission("location_red", "red_zone")
    addMission("location_red_empty", "red_zone")
    addMission("meta_red", "red_zone")
    addMission("ow_red_black_net_hunt_target", "red_zone")
    addMission("Red_Zone_Press", "red_zone")
    addMission("rz_cr_01", "red_zone")
    addMission("rz_cr_02", "red_zone")
    addMission("rz_fi_01", "red_zone")
    addMission("rz_fi_02", "red_zone")
    addMission("rz_it_01", "red_zone")
    addMission("rz_it_02", "red_zone")
    addMission("rz_la_02", "red_zone")
    addMission("rz_la_04", "red_zone")
    addMission("rz_la_05", "red_zone")
    addMission("rz_la_06", "red_zone")
    addMission("rz_m001", "red_zone")
    addMission("rz_ra_01", "red_zone")
    addMission("rz_re_01", "red_zone")
    addMission("rz_re_02", "red_zone")
    addMission("rz_rr_01", "red_zone")
    addMission("rz_rr_02", "red_zone")
    addMission("rz_sc_01", "red_zone")
    addMission("rz_sc_02", "red_zone")
    addMission("rz_sp_01", "red_zone")
    addMission("rz_vc_01", "red_zone")
    addMission("rz_vc_02", "red_zone")
    addMission("story_FinalBoss", "red_zone")
    addMission("story_g1", "red_zone")
    addMission("story_g2", "red_zone")
    addMission("story_g3", "red_zone")
    addMission("story_h1", "red_zone")
    addMission("story_i1", "red_zone")
    addMission("story_i3", "red_zone")
    addMission("story_intro1", "red_zone")
    addMission("story_intro2", "red_zone")
    addMission("story_l3", "red_zone")
    addMission("story_m3", "red_zone")
    addMission("structure_red_blackwatch_interior_253", "red_zone")
    addMission("structure_red_blackwatch_interior_94", "red_zone")
    addMission("structure_red_bunker_interior_214", "red_zone")
    addMission("structure_red_facility_interior_it_01", "red_zone")
    addMission("structure_red_group001", "red_zone")
    addMission("structure_red_group002", "red_zone")
    addMission("structure_red_group003", "red_zone")
    addMission("structure_red_group004", "red_zone")
    addMission("structure_red_group005", "red_zone")
    addMission("structure_red_group006", "red_zone")
    addMission("structure_red_hotspot001", "red_zone")
    addMission("structure_red_lair_interior_306", "red_zone")
    addMission("structure_red_lair_interior_315", "red_zone")
    addMission("test_autotest_red_zone", "red_zone")
    addMission("test_infected_transport_4", "red_zone")
    addMission("test_infection_red", "red_zone")
    addMission("test_nis", "red_zone")
    addMission("test_prop_red", "red_zone")
    addMission("test_recovery_2", "red_zone")
    addMission("test_recovery_3", "red_zone")
    addMission("test_recovery_4", "red_zone")
    addMission("test_shaders_red", "red_zone")
    addMission("test_vehicle_commander_2", "red_zone")
    
    -- Желтые миссии
    addMission("location_yellow", "yellow_zone")
    addMission("location_yellow_empty", "yellow_zone")
    addMission("meta_yellow", "yellow_zone")
    addMission("ow_yellow_black_net_hunt_target", "yellow_zone")
    addMission("story_a1", "yellow_zone")
    addMission("story_a2", "yellow_zone")
    addMission("story_a3", "yellow_zone")
    addMission("story_b2", "yellow_zone")
    addMission("story_b3", "yellow_zone")
    addMission("story_c1", "yellow_zone")
    addMission("story_c2", "yellow_zone")
    addMission("story_c3", "yellow_zone")
    addMission("story_l1", "yellow_zone")
    addMission("story_l2pre", "yellow_zone")
    addMission("story_m1", "yellow_zone")
    addMission("structure_yellow_blackwatch_interior_204", "yellow_zone")
    addMission("structure_yellow_checkpoint001", "yellow_zone")
    addMission("structure_yellow_checkpoint002", "yellow_zone")
    addMission("structure_yellow_checkpoint003", "yellow_zone")
    addMission("structure_yellow_checkpoint004", "yellow_zone")
    addMission("structure_yellow_facility_interior_135", "yellow_zone")
    addMission("structure_yellow_facility_interior_164", "yellow_zone")
    addMission("structure_yellow_facility_interior_94", "yellow_zone")
    addMission("structure_yellow_group001", "yellow_zone")
    addMission("structure_yellow_group002", "yellow_zone")
    addMission("structure_yellow_group003", "yellow_zone")
    addMission("structure_yellow_group004", "yellow_zone")
    addMission("structure_yellow_group005", "yellow_zone")
    addMission("structure_yellow_lair_interior_it_02", "yellow_zone")
    addMission("structure_yellow_lair_interior_s_c_02", "yellow_zone")
    addMission("structure_yellow_lair_interior_yz_ra_01", "yellow_zone")
    addMission("structure_yellow_military_interior_245", "yellow_zone")
    addMission("test_autotest_yellow_zone", "yellow_zone")
    addMission("test_infection_yellow", "yellow_zone")
    addMission("test_nis_yellow", "yellow_zone")
    addMission("test_prop_yellow", "yellow_zone")
    addMission("test_rampage01", "yellow_zone")
    addMission("test_shaders_yellow", "yellow_zone")
    addMission("yz_cd_01", "yellow_zone")
    addMission("yz_cd_02", "yellow_zone")
    addMission("yz_cd_03", "yellow_zone")
    addMission("yz_cd_04", "yellow_zone")
    addMission("yz_cr_01", "yellow_zone")
    addMission("yz_cr_02", "yellow_zone")
    addMission("yz_fi_01", "yellow_zone")
    addMission("yz_it_01", "yellow_zone")
    addMission("yz_it_02", "yellow_zone")
    addMission("yz_la_01", "yellow_zone")
    addMission("yz_m001", "yellow_zone")
    addMission("yz_ra_01", "yellow_zone")
    addMission("yz_ra_02", "yellow_zone")
    addMission("yz_re_01", "yellow_zone")
    addMission("yz_rr_01", "yellow_zone")
    addMission("yz_sc_01", "yellow_zone")
    addMission("yz_sp_01", "yellow_zone")
    addMission("yz_vc_02", "yellow_zone")
    addMission("yz_vc_02_lair_interior", "yellow_zone")
end

addAllValidMissions()

-- ============================================
-- Показ HUD
-- ============================================

fehudcounter_Show()
fehudcounter_Set("init.lua", "ok!")