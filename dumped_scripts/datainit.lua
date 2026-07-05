-- =============================================================================
-- File: datainit.lua
-- Description: Main initialization script for the game. Sets up global
--              variables, utility functions, logging, markers, missions,
--              consumables, and many other core systems.
-- =============================================================================

-- ########################### INITIAL SETUP ###########################

-- Global Game table to hold various game-related data
Game = {}

-- Set up a debug table within the Game table
Game.debug = {}

-- Register a metatable for the global 'ldebug'? This might be legacy or for debugging purposes.
ldebug.setmetatable(nil, { __index = function() end })

-- ########################### UTILITY MODULE ###########################

-- Create the global 'util' table for utility functions
util = util or {}

-- Generic walk function that applies a function to each element in a table or string
function util.walk(obj, func)
    local success, result
    if type(obj) == "string" then
        -- If the object is a string, use pcall to safely execute the function
        success, result = pcall(func, obj)
    elseif type(obj) == "table" then
        -- Iterate over the table and apply the function to each element
        for i = 1, #obj do
            success, result = util.walk(obj[i], func)
            if not success then
                break
            end
        end
        return success, result
    else
        -- Error for unsupported types
        return nil, "bad type (" .. type(obj) .. "), something undefined?"
    end
end

-- StringTree class for building strings from a tree structure
function util.StringTree()
    local self = setmetatable({}, { __index = util.StringTree })
    return self
end

-- Push an element onto the StringTree's internal list
function util.StringTree:push(value)
    if type(value) ~= "function" then
        table.insert(self, value)
        return self:push -- Allows chaining? Or a bug.
    end
end

-- Push all arguments onto the StringTree's list
function util.StringTree:pushall(...)
    for i = 1, select("#", ...) do
        table.insert(self, select(i, ...))
    end
end

-- Flatten the StringTree into a single concatenated string
function util.StringTree:flatten()
    local result = {}
    self:walk(function(value)
        table.insert(result, value)
    end)
    return table.concat(result)
end

-- Helper to create a new StringTree object
util.StringTree.new = function()
    return setmetatable({}, { __index = util.StringTree })
end

-- ########################### LOGGING MODULE ###########################

-- Setup a simple logging system (LuaLogging style)
logging = {}
local LOG_LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    FATAL = 5
}
logging.levels = LOG_LEVELS

-- Create a new appender (a function that handles log messages)
function logging.new(appenderFunc)
    assert(type(appenderFunc) == "function", "Appender must be a function.")
    local appender = {
        level = "DEBUG", -- Default level
        append = appenderFunc,
        setLevel = function(self, level)
            self.level = level
        end,
        log = function(self, level, message)
            if LOG_LEVELS[level] < LOG_LEVELS[self.level] then
                return
            end
            if type(message) ~= "string" then
                message = tostring(message)
            end
            return self.append(level, message)
        end
    }
    -- Add convenience methods for each log level
    for levelName, _ in pairs(LOG_LEVELS) do
        appender[levelName:lower()] = function(self, message)
            return self.log(self, levelName, message)
        end
    end
    return appender
end

-- Helper to prepare a log message with line and source info
function logging.prepareLogMsg(format, line, source, message)
    format = format or "%message       : from line %line in %node"
    format = string.gsub(format, "%%line", tostring(line))
    format = string.gsub(format, "%%node", tostring(source))
    format = string.gsub(format, "%%message", message)
    return format
end

-- Create a console appender that prints to the game's console
function logging.console(format)
    return logging.new(function(level, message)
        local info = debug.getinfo(4)
        local line = info and info.currentline >= 0 and info.currentline or "unknown"
        local source = info and info.source or ""
        local logMessage = logging.prepareLogMsg(format, line, source, message)
        cprint(level, logMessage) -- cprint is a function defined later
        if level == "ERROR" or level == "FATAL" then
            error(logMessage)
        end
        return true
    end)
end

-- Assign a default logger to the Game table
Game.logger = logging.console()

-- ########################### UTILITY TABLE EXTENSIONS ###########################

-- Add a 'show' function to the table global object (for debugging)
function table.show(obj, name, indent, seen, parentName)
    local function is_empty(t)
        return next(t) == nil
    end

    local function tostring_simple(value)
        local s = tostring(value)
        if type(value) == "function" then
            local info = debug.getinfo(value, "S")
            if info.what == "C" then
                return string.format("%q, C function", s)
            else
                return string.format("%q : Function", s)
            end
        elseif type(value) == "number" then
            return s
        else
            return string.format("%q", s)
        end
    end

    local out = util.StringTree()
    local prefix = ""
    local line = util.StringTree()

    local function dump(obj, name, indent, seen, parentName)
        indent = indent or ""
        seen = seen or {}
        parentName = parentName or name

        line:push(indent)
        line:push(parentName)

        if type(obj) ~= "table" then
            line:pushall(" = ", tostring_simple(obj), ";\n")
            return
        end

        if seen[obj] then
            line:pushall(" = {}; -- ", seen[obj], " (self reference)\n")
            out:pushall(name, " = ", seen[obj], ";\n")
            return
        end

        seen[obj] = name
        if is_empty(obj) then
            line:push(" = {};\n")
        else
            line:push(" = {\n")
            for key, value in pairs(obj) do
                local keyStr = tostring_simple(key)
                local newName = string.format("%s[%s]", name, keyStr)
                local newParentName = string.format("[%s]", keyStr)
                dump(value, newName, indent .. "   ", seen, newParentName)
            end
            line:push(indent, "};\n")
        end
    end

    name = name or "__unnamed__"
    if type(obj) ~= "table" then
        return name .. " = " .. tostring_simple(obj)
    end

    out:push("")
    dump(obj, name, indent, seen)
    line:push(out)
    return line:flatten()
end

-- ########################### DEBUG INFO FUNCTIONS ###########################

-- Display detailed information about any Lua object
function dbg_info(value)
    local s = tostring(value)
    if type(value) == "function" then
        local info = debug.getinfo(value, "S")
        if info.what == "C" then
            return string.format("%q, C function", s)
        else
            return string.format("%q, defined in (%s-%s)%s", s, info.linedefined, info.lastlinedefined, info.source)
        end
    elseif type(value) == "table" then
        return table.show(value, "")
    elseif type(value) == "number" then
        return s
    else
        return string.format("%q", s)
    end
end

-- Check if a function is a C function
function IsCFunction(func)
    if type(func) == "function" then
        local info = debug.getinfo(func, "S")
        return info.what == "C"
    end
    return false
end

-- ########################### DEBUG OVERRIDES ###########################

-- Override certain AI and game functions for debugging purposes
function ai_TurnOnDebugOverRides()
    if IsCFunction(ai_SetScriptedTask) then
        _G.ai_SetScriptedTask = function(...) return ai_SetScriptedTask(...) end
        _G.ai_SetTask = function(...) return ai_SetTask(...) end
        _G.ai_RemoveScriptedTask = function(...) return ai_RemoveScriptedTask(...) end
        _G.ai_SetDefendArea = function(...) return ai_SetDefendArea(...) end
        _G.go_SetMaxHealth = function(...) return go_SetMaxHealth(...) end
    end
end

-- Override front-end functions for debugging
function fe_TurnOnDebugOverRides()
    if IsCFunction(fe_FadeToBlack) then
        _G.fe_FadeToBlack = function(...) return fe_FadeToBlack(...) end
        _G.fe_ShowHUD = function(...)
            print("fe_ShowHUD(", ..., ") ", util_FunctionSourceLine())
            return fe_ShowHUD(...)
        end
        _G.fe_HideHUDElements = function(...)
            print("fe_HideHUDElements(", ...)
            return fe_HideHUDElements(...)
        end
    end
end

-- Get the source file and line number of the calling function
function util_FunctionSourceLine()
    local info = debug.getinfo(3)
    if type(info) == "table" then
        return "Line[" .. info.currentline .. "] " .. info.source
    else
        return ""
    end
end

-- ########################### TABLE UTILITY FUNCTIONS ###########################

-- Deep copy a table with handling for self-references and Vector types
function table.copy(original, seen)
    if original == nil then
        return nil
    end
    seen = seen or {}
    local copy = {}
    if seen[original] then
        return seen[original]
    end
    seen[original] = copy

    for key, value in pairs(original) do
        if type(key) == "table" then
            key = table.copy(key, seen)
        end
        if type(value) == "Vector" then
            copy[key] = Vector(value.x, value.y, value.z)
        elseif type(value) ~= "table" then
            copy[key] = value
        else
            if seen[value] then
                copy[key] = seen[value]
            else
                copy[key] = table.copy(value, seen)
            end
        end
    end
    return setmetatable(copy, getmetatable(original))
end

-- String utility functions: trim, ltrim, rtrim, subst
function string.trim(s)
    return s:gsub("^%s*(.-)%s*$", "%1")
end

function string.ltrim(s)
    return s:gsub("^%s*", "")
end

function string.rtrim(s)
    local n = #s
    while n > 0 and s:find("^%s", n) do
        n = n - 1
    end
    return s:sub(1, n)
end

function string.subst(str, table)
    return str:gsub("%$%(([%w_]+)%)", function(key)
        local value = table[key]
        return value and tostring(value)
    end)
end

-- ########################### BITWISE OPERATIONS ###########################

-- Implement bitwise operations using Lua tables
local function validate_integer(n)
    if n ~= math.floor(n) then
        error("trying to use bitwise operation on non-integer!")
    end
end

function math.tobits(n)
    validate_integer(n)
    if n < 0 then
        n = math.bnot(math.abs(n)) + 1
    end
    local bits = {}
    local i = 1
    while n > 0 do
        bits[i] = n % 2
        n = (n - bits[i]) / 2
        i = i + 1
    end
    return bits
end

function math.tonumb(bits)
    local n = 0
    local place = 1
    for i = 1, #bits do
        n = n + bits[i] * place
        place = place * 2
    end
    return n
end

function math.bor(a, b)
    local bits_a = math.tobits(a)
    local bits_b = math.tobits(b)
    local result = {}
    local max_len = math.max(#bits_a, #bits_b)
    for i = 1, max_len do
        result[i] = (bits_a[i] == 1 or bits_b[i] == 1) and 1 or 0
    end
    return math.tonumb(result)
end

function math.band(a, b)
    local bits_a = math.tobits(a)
    local bits_b = math.tobits(b)
    local result = {}
    local max_len = math.max(#bits_a, #bits_b)
    for i = 1, max_len do
        result[i] = (bits_a[i] == 1 and bits_b[i] == 1) and 1 or 0
    end
    return math.tonumb(result)
end

-- ... (other bitwise functions: bxor, bnot, brshift, blshift, etc.)

-- Hexadecimal conversion helpers
hex = {}
function hex.to_hex(n)
    if type(n) ~= "number" then error("non-number type passed in.") end
    validate_integer(n)
    if n < 0 then
        n = math.tobits(math.bnot(math.abs(n)) + 1)
        n = math.tonumb(n)
    end
    local hex_chars = {"A", "B", "C", "D", "E", "F"}
    local str = ""
    while n ~= 0 do
        local last = n % 16
        if last < 10 then
            str = tostring(last) .. str
        else
            str = hex_chars[last - 10 + 1] .. str
        end
        n = math.floor(n / 16)
    end
    if str == "" then
        str = "0"
    end
    return "0x" .. str
end

function hex.to_dec(str)
    if type(str) ~= "string" then error("non-string type passed in.") end
    local head = str:sub(1, 2)
    if head ~= "0x" and head ~= "0X" then
        error("wrong hex format, should lead by 0x or 0X.")
    end
    return tonumber(str:sub(3), 16)
end

-- ########################### MATH EXTENSIONS ###########################

-- Determine the number of integer bits on the platform
local i = 1
local count = 0
while i < i + 1 do
    i = i * 2
    count = count + 1
end
_INTEGER_BITS = count

-- Extended math functions
function math.floor(value, precision)
    precision = precision or 0
    local mult = 10 ^ precision
    return math.floor(value * mult) / mult
end

function math.round(value, precision)
    precision = precision or 0
    local mult = 10 ^ precision
    return math.floor(value * mult + 0.5) / mult
end

function math.lerp(a, b, t)
    return a + (b - a) * t
end

function math.clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

-- ########################### VECTOR UTILITY LIBRARY ###########################

vector = {}

function vector.VectorDistance(a, b)
    return a:mag(b - a) -- Using the 'mag' method of the Vector class
end

function vector.VectorAdd(a, b) return a + b end
function vector.VectorSub(a, b) return a - b end
function vector.VectorScale(v, s) return v * s end

function vector.VectorMag(v) return v:mag() end

function vector.VectorNormalize(v)
    local n = Vector(v)
    n:normalize()
    return n
end

function vector.VectorDot(a, b) return a:dot(b) end
function vector.VectorSum(v) return v.x + v.y + v.z end
function vector.VectorMultiplyVector(a, b) return a * b end

function vector.VectorNew(x, y, z)
    return Vector(x, y, z)
end

function vector.VectorPrint(v)
    return "(" .. v.x .. ", " .. v.y .. ", " .. v.z .. ")"
end

function vector.VectorDegreesToRadians(deg) return deg * math.pi / 180 end
function vector.VectorRadiansToDegrees(rad) return rad * 180 / math.pi end

function vector.VectorRotate(v, angles)
    return vector.VectorRotateRadians(v, vector.VectorDegreesToRadians(angles))
end

function vector.VectorRotateRadians(v, angles)
    -- Euler rotation (Z, then X, then Y)
    local cx, cy, cz = math.cos(angles.z), math.cos(angles.x), math.cos(angles.y)
    local sx, sy, sz = math.sin(angles.z), math.sin(angles.x), math.sin(angles.y)
    local x, y, z = v.x, v.y, v.z

    -- Rotate around Z
    local x1, y1 = x * cx - y * sx, x * sx + y * cx
    z = z
    -- Rotate around X
    local y2, z2 = y1 * cy - z * sy, y1 * sy + z * cy
    x1 = x1
    -- Rotate around Y
    local x3, z3 = x1 * cz + z2 * sz, -x1 * sz + z2 * cz
    return Vector(x3, y2, z3)
end

function vector.VectorAnglesXY(v)
    local normal = vector.VectorNormalize(Vector(v.x, 0, v.z))
    local yaw = math.acos(normal.z) * (normal.x < 0 and -1 or 1)
    local up = Vector(0, 1, 0)
    local right = vector.VectorCross(normal, up)
    local pitch = math.acos(v:dot(Vector(0, 1, 0))) * (right.y < 0 and -1 or 1)
    return Vector(pitch, yaw, 0)
end

function vector.VectorAxisRotate(v, axis, angle)
    -- Rodrigues' rotation formula
    local rad = math.rad(angle)
    local k = vector.VectorNormalize(axis)
    local dot = v:dot(k)
    local cross = vector.VectorCross(k, v)
    return v * math.cos(rad) + cross * math.sin(rad) + k * dot * (1 - math.cos(rad))
end

function vector.VectorAngle(a, b)
    return math.deg(math.acos(vector.VectorDot(vector.VectorNormalize(a), vector.VectorNormalize(b))))
end

function vector.VectorCross(a, b) return a:cross(b) end

function vector.RandomVector(minAngle, maxAngle, minElevation, maxElevation, radius)
    local theta = math.rad(minAngle + math.random() * (maxAngle - minAngle) * 2)
    local phi = math.rad(minElevation + math.random() * (maxElevation - minElevation) * 2)
    return Vector(radius * math.cos(theta) * math.cos(phi), radius * math.sin(phi), radius * math.sin(theta) * math.cos(phi))
end

function vector.VtoA(v) return "(" .. v.x .. ", " .. v.y .. ", " .. v.z .. ")" end

function vector.ProjectPointOntoLine(p, a, b)
    if a == b then return 0 end
    local ab = b - a
    return (p - a):dot(ab) / ab:dot(ab)
end

-- ########################### TABLE UTILITY FUNCTIONS (continued) ###########################

-- Combine two tables (optionally removing duplicates)
function table.combine(table1, table2, unique)
    local result = {}
    if unique then
        local lookup = {}
        for _, v in ipairs(table1) do
            if lookup[v] == nil then
                lookup[v] = v
            end
        end
        for _, v in ipairs(table2) do
            if lookup[v] == nil then
                lookup[v] = v
            end
        end
        for _, v in pairs(lookup) do
            table.insert(result, v)
        end
    else
        for _, v in ipairs(table1) do table.insert(result, v) end
        for _, v in ipairs(table2) do table.insert(result, v) end
    end
    return result
end

-- Remove an element from a table by value
function table.removeelement(t, value)
    local found, index = table.search(t, value)
    if found then
        if type(index) == "number" then
            table.remove(t, index)
        else
            t[index] = nil
        end
        return true
    end
    return false
end

-- Search a table for a value
function table.search(t, value)
    if t then
        for k, v in pairs(t) do
            if v == value then
                return true, k
            end
        end
    end
    return false, nil
end

-- Randomize the order of a table
function table.randomize(t, copy)
    local randomized = copy and table.copy(t) or t
    local n = #randomized
    for i = 1, n do
        local j = math.random(i, n)
        randomized[i], randomized[j] = randomized[j], randomized[i]
    end
    return randomized
end

-- Invert a table (reverse the order)
function table.invert(t)
    local inverted = {}
    local n = #t
    for i, v in ipairs(t) do
        inverted[n] = v
        n = n - 1
    end
    return inverted
end

-- Check if a table is empty
function table.isempty(t)
    if t then
        for _, _ in pairs(t) do
            return false
        end
    end
    return true
end

-- Count the number of elements in a table
function table.count(t)
    local n = 0
    if t then
        for _, _ in pairs(t) do
            n = n + 1
        end
    end
    return n
end

-- ########################### RAY-SPHERE INTERSECTION ###########################

-- Calculate the intersection point of a ray and a sphere
function RaySphereIntersection(rayOrigin, rayDir, sphereCenter, sphereRadius)
    local a = rayDir.x ^ 2 + rayDir.y ^ 2 + rayDir.z ^ 2
    local b = 2 * ((rayDir.x * (rayOrigin.x - sphereCenter.x)) +
                   (rayDir.y * (rayOrigin.y - sphereCenter.y)) +
                   (rayDir.z * (rayOrigin.z - sphereCenter.z)))
    local c = ((rayOrigin.x - sphereCenter.x) ^ 2 +
               (rayOrigin.y - sphereCenter.y) ^ 2 +
               (rayOrigin.z - sphereCenter.z) ^ 2 - sphereRadius ^ 2)

    local t = minroot(a, b, c)
    if t then
        return { rayOrigin.x + t * rayDir.x, rayOrigin.y + t * rayDir.y, rayOrigin.z + t * rayDir.z }
    else
        return false
    end
end

-- Find the minimum positive root of a quadratic equation
function minroot(a, b, c)
    if a == 0 then
        return -c / b
    else
        local disc = b ^ 2 - 4 * a * c
        if disc < 0 then
            return false
        else
            local sqrt_disc = math.sqrt(disc)
            local t1 = (-b + sqrt_disc) / (2 * a)
            local t2 = (-b - sqrt_disc) / (2 * a)
            return math.min(t1, t2)
        end
    end
end

-- ########################### GLOBAL CONFIGURATION ###########################

-- Initialize a global 'props' table
props = props or {}
props.config = {}

-- Faction definitions
factions = {}
factions.civilian = "civilian"
factions.military = "military"
factions.infected = "infected"
factions.alexPowered = "powered"
factions.alexHooded = "alex"
factions.commander = "commander"
factions.blackwatch = "blackwatch"

factions.perSecond = {
    militaryVsAlex = 10,
    militaryVsCivilian = 1,
    militaryVsMilitary = -5,
    militaryVsPowered = 1000
}

FACTION_ENEMY = 0
FACTION_ALLY = 1
FACTION_DONTCARE = 2

-- Disguise times
DISGUISE_SCRIPTEDBLOWTIMESHORT = 15
DISGUISE_SCRIPTEDBLOWTIMEMEDIUM = 30
DISGUISE_SCRIPTEDBLOWTIMELONG = 60

-- Camera constants
CAM_0 = 0
CAM_1 = 1
CAM_MB = 2
CM_WORLD_OFFSET = 0
CM_OBJECT_OFFSET = 1
CM_JOINT_OFFSET = 2
CM_FACING_OFFSET = 3
CM_TYPE_CHASE = 0
CM_TYPE_VEHICLE_GROUND = 1
CM_TYPE_VEHICLE_GROUND_GUNNER = 2
CM_TYPE_VEHICLE_AIR = 3
CM_TYPE_VEHICLE_AIR_GUNNER = 4
CM_SHAKE_SMALL = 0
CM_SHAKE_MEDIUM = 1
CM_SHAKE_LARGE = 2
CAM_TANK_DRIVER_BASE_DIST = 10
CAM_TANK_GUNNER_BASE_DIST = 5
CAM_TANK_DRIVER_OFFSET = Vector(0, 4, 0)
CAM_TANK_GUNNER_OFFSET = Vector(0, 0, 0)
CM_DYNAMIC = true
CM_STATIC = false
CM_START_ONLY = false

CUR_CAMERA = CAM_0
function NEXT_CAM()
    CUR_CAMERA = (CUR_CAMERA + 1) % 2
    return CUR_CAMERA
end

camID = {}
framerSequenceUID = nil

-- Character and vehicle template names
COP = "Cop"
COP_PEDESTRIAN = "CopPedestrian"
MARINE = "Soldier"
MARINE_SNIPER = "SniperSoldier"
MARINE_ROCKET = "RocketSoldier"
MARINE_PEDESTRIAN = "SoldierPedestrian"
BLACKWATCH = "Blackwatch"
BLACKWATCH_ROCKET = "RocketBlackwatch"
BLACKWATCH_GRENADE = "GrenadeBlackwatch"
BLACKWATCH_SAW = "SawBlackwatch"
COMMANDER = "Commander"
COMMANDER_KEY = "KeyCommander"
COMMANDER_BW = "BwOfficer"
BW_SCIENTIST = "bw_scientist_2008"
BW_AGENT_1 = "bw_plain_clothes_01"
BW_AGENT_2 = "bw_plain_clothes_02"
TANK_ARMOR = "ARMOR_tank_ram_marine"
TANK = "tank_ram_marine"
TANK_BW = "tank_ram_blackwatch"
TANK_TB = "tank_ram_thermobolic"
TANK_GUNNER = "tank_ram_marine_gunner"
TANK_BW_GUNNER = "tank_ram_blackwatch_gunner"
APC_ARMOR = "ARMOR_apc_m2_marine"
APC = "apc_m2_marine"
APC_BW = "apc_m2_blackwatch"
APC_UAV = "apc_m2_marine_uav"
APC_UAV_BW = "apc_m2_blackwatch_uav"
APC_GUNNER = "apc_m2_marine_gunner"
APC_BW_GUNNER = "apc_m2_blackwatch_gunner"
GUNSHIP_AIR = "AIR_heli_gunship_marine_core"
GUNSHIP = "heli_gunship_marine_core"
GUNSHIP_BW = "heli_gunship_blackwatch"
GUNSHIP_EMPTY = "heli_gunship_marine_core_empty"
GUNSHIP_BW_EMPTY = "heli_gunship_blackwatch_empty"
HELICOPTER_AIR = "AIR_heli_bh_marine"
HELICOPTER = "heli_bh_marine"
HELICOPTER_EMPTY = "heli_bh_marine_empty"
HELICOPTER_ROCKET = "heli_bh_marine_rockets_and_missiles"
HELICOPTER_ROCKET_EMPTY = "heli_bh_marine_rockets_and_missiles_empty"
HELICOPTER_BW = "heli_bh_blackwatch"
HELICOPTER_BW_EMPTY = "heli_bh_blackwatch_empty"
HELICOPTER_BW_ROCKET = "heli_bh_blackwatch_rockets_and_missiles"
HELICOPTER_BW_ROCKET_EMPTY = "heli_bh_blackwatch_rockets_and_missiles_empty"
HELICOPTER_BW_SUPERSOLDIER = "heli_bh_blackwatch_supersoldier"
JET_AIR = "AIR_f45Thunder001Military"
JET = "f45Thunder001Military"
JET_BW = "f45Thunder001Blackwatch"
JET_ARMOR = "ARMOR_f45Thunder001Military"
UAV = "uav"
STATIC_SNIFFER = "snifferTrailer"
SUPERSOLDIER = "SuperSoldier"
GUNTURRET = "gunTurret"
INFECTED1 = "Infected1"
INFECTED1_PEDESTRIAN = "Infected1Pedestrian"
BRAWLER = "Brawler"
LEADER = "LeaderHunter"
HYDRA = "Hydra"
STRIPE = "StripedLeaderHunter"
SUPREME = "supreme_hunter_weak"
SUPREME_HYBRID = "supreme_hunter"
SPECIALIST = "specialist"
MOTHER = "mother"
MISSIONPED = "MissionPed"
DANA = "DanaMercer"
KARENPARKER = "karen_parker"
RAGLANDSUIT = "ragland_suit"
RAGLAND = "ragland_morgue_ingame"
DANA_NIS = "dana_chair"
KAREN_NIS = "karen_chair"
RAGLAND_NIS = "nis_dr_ragland"
SPECIALIST_NIS = "nis_specialist"
BLOODTOXDRILL = "bloodtoxDriller001"
BHDRILLER = "e8m2_bloodtoxdriller_blackhawk"

-- UIDs for character templates
UID_COP = UID(COP)
UID_COP_PEDESTRIAN = UID(COP_PEDESTRIAN)
UID_MARINE = UID(MARINE)
UID_MARINE_SNIPER = UID(MARINE_SNIPER)
UID_MARINE_ROCKET = UID(MARINE_ROCKET)
UID_MARINE_PEDESTRIAN = UID(MARINE_PEDESTRIAN)
UID_BLACKWATCH = UID(BLACKWATCH)
UID_BLACKWATCH_ROCKET = UID(BLACKWATCH_ROCKET)
UID_BLACKWATCH_GRENADE = UID(BLACKWATCH_GRENADE)
UID_BLACKWATCH_SAW = UID(BLACKWATCH_SAW)
UID_COMMANDER = UID(COMMANDER)
UID_COMMANDER_BW = UID(COMMANDER_BW)
UID_PILOT = UID(PILOT)
UID_BW_SCIENTIST = UID(BW_SCIENTIST)
UID_BW_AGENT_1 = UID(BW_AGENT_1)
UID_BW_AGENT_2 = UID(BW_AGENT_2)
UID_TANK = UID(TANK)
UID_TANK_BW = UID(TANK_BW)
UID_TANK_TB = UID(TANK_TB)
UID_APC = UID(APC)
UID_APC_BW = UID(APC_BW)
UID_APC_UAV = UID(APC_UAV)
UID_APC_UAV_BW = UID(APC_UAV_BW)
UID_MLRS = UID(MLRS)
UID_MLRS_BW = UID(MLRS_BW)
UID_GUNSHIP = UID(GUNSHIP)
UID_GUNSHIP_BW = UID(GUNSHIP_BW)
UID_GUNSHIP_EMPTY = UID(GUNSHIP_EMPTY)
UID_GUNSHIP_BW_EMPTY = UID(GUNSHIP_BW_EMPTY)
UID_HELICOPTER = UID(HELICOPTER)
UID_HELICOPTER_EMPTY = UID(HELICOPTER_EMPTY)
UID_HELICOPTER_ROCKET = UID(HELICOPTER_ROCKET)
UID_HELICOPTER_ROCKET_EMPTY = UID(HELICOPTER_ROCKET_EMPTY)
UID_HELICOPTER_BW = UID(HELICOPTER_BW)
UID_HELICOPTER_BW_EMPTY = UID(HELICOPTER_BW_EMPTY)
UID_HELICOPTER_BW_ROCKET = UID(HELICOPTER_BW_ROCKET)
UID_HELICOPTER_BW_ROCKET_EMPTY = UID(HELICOPTER_BW_ROCKET_EMPTY)
UID_HELICOPTER_BW_SUPERSOLDIER = UID(HELICOPTER_BW_SUPERSOLDIER)
UID_JET = UID(JET)
UID_JET_BW = UID(JET_BW)
UID_UAV = UID(UAV)
UID_STATIC_SNIFFER = UID(STATIC_SNIFFER)
UID_SUPERSOLDIER = UID(SUPERSOLDIER)
UID_GUNTURRET = UID(GUNTURRET)
UID_INFECTED1 = UID(INFECTED1)
UID_INFECTED1_PEDESTRIAN = UID(INFECTED1_PEDESTRIAN)
UID_BRAWLER = UID(BRAWLER)
UID_STEALTH = UID(STEALTH)
UID_LEADER = UID(LEADER)
UID_HYDRA = UID(HYDRA)
UID_STRIPE = UID(STRIPE)
UID_SUPREME = UID("SupremeHunterWeak")
UID_SUPREME_HYBRID = UID("SupremeHunter")
UID_SPECIALIST = UID("Specialist")
UID_MOTHER = UID("MotherCore")
UID_MISSIONPED = UID(MISSIONPED)
UID_DANA = UID(DANA)
UID_KARENPARKER = UID(KARENPARKER)
UID_RAGLANDSUIT = UID(RAGLANDSUIT)
UID_RAGLAND = UID(RAGLAND)
UID_BLOODTOXDRILL = UID(BLOODTOXDRILL)

-- Database keys for saving/loading game state
DB_PROTO_VOLATILE_STARTTYPE = "Proto_Volatile_StartType"
DB_PROTO_VOLATILE_CURRENT_ZONE_ID = "Proto_Volatile_CurrentZoneId"
DB_PROTO_VOLATILE_GOTO_MAINMENU = "Proto_Volatile_GotoMainMenu"
DB_PROTO_PROFILE_NEWGAMEPLUS_UNLOCKED = "Proto_Profile_NewGamePlusUnlocked"
DB_PROTO_SAVE_LASTMISSIONSTARTED = "Proto_Save_LastMissionStarted"
DB_PROTO_SAVE_LASTMISSIONCOMPLETED = "Proto_Save_LastMissionCompleted"
DB_PROTO_SAVE_DIFFICULTY = "Proto_Save_Difficulty"
DB_PROTO_SAVE_NEWGAMEPLUS_INPROGRESS = "Proto_Save_NewGamePlusInProgress"
DB_PROTO_SAVE_SPAWNPOSITION = "Proto_Save_SpawnPosition"
DB_PROTO_SAVE_SPAWNFACING = "Proto_Save_SpawnFacing"
DB_PROTO_SAVE_EVOLUTIONPOINTS = "Proto_Save_EvolutionPoints"
DB_PROTO_SAVE_CHARACTEREVOLUTION_LASTEP = "Proto_Save_CharacterEvolution_LastEP"
DB_PROTO_SAVE_CHARACTEREVOLUTION_LOCOMOTION = "Proto_Save_CharacterEvolution_Locomotion"
DB_PROTO_SAVE_CHARACTEREVOLUTION_HEALTHPOOL = "Proto_Save_CharacterEvolution_HealthPool"
DB_PROTO_SAVE_CHARACTEREVOLUTION_HEALTHGAIN = "Proto_Save_CharacterEvolution_HealthGain"
DB_PROTO_SAVE_CHARACTEREVOLUTION_MASS = "Proto_Save_CharacterEvolution_Mass"
DB_PROTO_SAVE_CHARACTEREVOLUTION_STEALTH = "Proto_Save_CharacterEvolution_Stealth"
DB_PROTO_SAVE_CHARACTEREVOLUTION_FINISHERS = "Proto_Save_CharacterEvolution_Finishers"

STARTTYPE_NORMAL = "Normal"
STARTTYPE_DEVSELECT = "DevSelect"

-- ########################### UTILITY FUNCTIONS (Misc) ###########################

-- Door action: open or close a door GOH
function props.door(goh, action)
    if type(goh) ~= "GOH" or not go_IsValid(goh) then
        cprint("/scenario/error", "Door Action: Invalid prop goh. Node", context.event.node)
        return
    end

    if go_QueryState(goh, "final") then
        return -- Door is already in a final state (destroyed)
    end

    if action == "open" then
        if go_QueryState(goh, "open") or go_QueryState(goh, "opening") then
            return -- Already open or opening
        end
        go_SetState(goh, "", "opening", true)
    elseif action == "close" then
        if go_QueryState(goh, "closed") or go_QueryState(goh, "closing") then
            return -- Already closed or closing
        end
        go_SetState(goh, "", "closing", true)
    end
end

-- Start a timer event that posts a local string
function util.StartLocalTimerEvent(time, eventString)
    local localString = util.MakeLocalString(eventString)
    local event = string.format("scenario_PostEventString(\"%s\")", localString)
    return sm_StartTimer(time, event)
end

-- Make a local string by appending the context's game object UID
function util.MakeLocalString(str)
    return tostring(context.gameObject) .. str
end

-- Compare a UID to a local string (for timer events)
function util.CompareUIDtoLocalString(uid, localString)
    local localUID = CreateUID(tostring(context.gameObject) .. localString)
    return uid == localUID
end
util.CompareUIDToLocalTimerString = util.CompareUIDtoLocalString

-- ########################### WAIT FUNCTIONS ###########################

-- Wait for a specified number of seconds (simulation time)
function Wait(time)
    if not time then
        return 0
    end
    local elapsed = 0
    while time > elapsed do
        elapsed = elapsed + time_GetSimulationDelta()
        coroutine.yield()
    end
    return elapsed
end

-- Wait for real-time seconds
function WaitRealTime(time)
    if not time then
        return 0
    end
    local elapsed = 0
    while time > elapsed do
        elapsed = elapsed + time_GetRealTimeDelta()
        coroutine.yield()
    end
    return elapsed
end

-- Wait for a number of frames
function WaitFrames(frames)
    for _ = 0, frames, 1 do
        coroutine.yield()
    end
end

-- ########################### UNIQUE NAME GENERATOR ###########################

uniqueNameCount = 0
function util_GetUniqueName()
    uniqueNameCount = uniqueNameCount + 1
    return "UN" .. uniqueNameCount
end

-- ########################### TAG UTILITY FUNCTIONS ###########################

-- Add a tag to an object (by GOH or name)
function util_AddTag(obj, tag)
    local goh = nil
    local valid = false

    if type(obj) == "string" then
        goh = go_FindGOHByName(obj)
        if go_IsValid(goh) then
            valid = true
        end
    elseif type(obj) == "GOH" and go_IsValid(obj) then
        goh = obj
        valid = true
    end

    if valid then
        go_AddTag(goh, tag)
        return true
    else
        cprint("/mission/error", "Invalid object: ", obj, " passed in to util_AddTag")
        return false
    end
end

-- Remove a tag from an object
function util_RemoveTag(obj, tag)
    local goh = nil
    local valid = false

    if type(obj) == "string" then
        goh = go_FindGOHByName(obj)
        if go_IsValid(goh) then
            valid = true
        end
    elseif type(obj) == "GOH" and go_IsValid(obj) then
        goh = obj
        valid = true
    end

    if valid then
        go_RemoveTag(goh, tag)
        return true
    else
        cprint("/mission/error", "Invalid object: ", obj, " passed in to util_RemoveTag")
        return false
    end
end

-- Get the count of objects with a specific tag
function util_getTaggedCount(tag)
    local tagged = go_GetAllTagged(tag)
    return table.getn(tagged)
end

-- Destroy all objects with a specific tag
function util_DestroyAllTagged(tag)
    local tagged = go_GetAllTagged(tag) or {}
    for _, goh in pairs(tagged) do
        if isValid(goh) then
            go_DestroyObject(goh, false)
        end
    end
end

-- ########################### VOLUME / TRIGGER UTILITY ###########################

-- Check if an object is inside a trigger volume
function IsObjectInVolume(object, volume)
    local goh = nil
    local validObj = false
    local volGOH = nil
    local validVol = false

    if type(object) == "string" then
        goh = go_FindGOHByName(object)
        if go_IsValid(goh) then
            validObj = true
        end
    elseif type(object) == "GOH" and go_IsValid(object) then
        goh = object
        validObj = true
    end

    if type(volume) == "string" then
        volGOH = go_FindGOHByName(volume)
        if go_IsValid(volGOH) then
            validVol = true
        end
    elseif type(volume) == "GOH" and go_IsValid(volume) then
        volGOH = volume
        validVol = true
    end

    if validObj and validVol then
        return tv_IsGOInTrigger(goh, volGOH)
    else
        if not validObj then
            cprint("/mission/error", "Invalid object: ", object, " passed in to IsObjectInVolume")
        end
        if not validVol then
            cprint("/mission/error", "Invalid volume: ", volume, " passed in to IsObjectInVolume")
        end
        return false
    end
end

-- ########################### TIME OF DAY UTILITY ###########################

-- Advance the time of day to a target hour over a specified duration
function util_AdvanceTOD(targetHour, duration)
    local dayLength = tod_GetDayLength()
    local hourLength = dayLength / 24
    local currentHour = tod_GetTimeOfDay()

    if targetHour < currentHour then
        targetHour = 24 + targetHour
    end

    local hoursToAdvance = targetHour - currentHour
    local timeToAdvance = hoursToAdvance * hourLength
    local speedup = timeToAdvance / duration

    print("speedupis:", speedup)
    tod_SetSpeed(speedup)
end

-- ########################### STATS UTILITY FUNCTIONS ###########################

-- Check if a UID corresponds to a Blackwatch marine
function Stats_IsBwMarine(uid)
    return uid == UID_BLACKWATCH
end

-- Check if a UID corresponds to an Infected type 1
function Stats_IsInfected1(uid)
    return uid == UID_INFECTED1
end

-- ########################### PLAYER RESURRECTION ###########################

-- Resurrect the player (reset health, position, visibility, etc.)
function ResurrectPlayer()
    go_SetHealth(PLAYER, go_GetMaxHealth(PLAYER))
    go_Reset(PLAYER)
    go_ShowObject(PLAYER, true, true)
    go_SetVisibility(PLAYER, true, true)
    cm_SetGameCamera(CM_TYPE_CHASE, 0)
end

-- ########################### UTILITY FUNCTIONS (Misc) ###########################

-- Restrict player input by playing a specific motion branch
function util_RestrictPlayerInput(inputRestriction)
    local motionPath
    if inputRestriction == "packAttackOnly" then
        motionPath = "//prototype_scripted/Scripted/packleader_tutorial/attack_only"
    elseif inputRestriction == "packIdleOnly" then
        motionPath = "//prototype_scripted/Scripted/packleader_tutorial/idle_only"
    elseif inputRestriction == "packSummonOnly" then
        motionPath = "//prototype_scripted/Scripted/packleader_tutorial/summon_only"
    elseif inputRestriction == "lookOnly" then
        motionPath = "//prototype_scripted/Scripted/player_restriction/look_only"
    elseif inputRestriction == "shootOnly" then
        motionPath = "//prototype_scripted/Scripted/player_restriction/shoot_only"
    elseif inputRestriction == "huntOnly" then
        motionPath = "//prototype_scripted/Scripted/player_restriction/hunt_only"
    elseif inputRestriction == "crouchOnly" then
        motionPath = "//prototype_scripted/Scripted/mission_specific/story_Intro1/crouch/enter"
    elseif inputRestriction == "goProne" then
        motionPath = "//prototype_scripted/Scripted/mission_specific/story_Intro1/prone"
    elseif inputRestriction == "getUp" then
        motionPath = "//prototype_scripted/Scripted/mission_specific/story_Intro1/getup"
    elseif inputRestriction == "throwOnly" then
        motionPath = "//prototype_scripted/Scripted/player_restriction/throw_only"
    else
        motionPath = "//prototype/opening"
    end
    go_PlayMotionBranchByPath(PLAYER, motionPath, -10, true)
end

-- Play a motion branch on a game object if it's not dead
function util_PlayMotionBranch(goh, motionPath, onlyIfNotDead)
    local onlyIfNotDead = onlyIfNotDead or true
    if not go_IsDead(goh) then
        go_PlayMotionBranchByPath(goh, motionPath, -10, onlyIfNotDead)
    end
end

-- ########################### MODULO 1 ###########################

-- Modulo operation that returns a value in the range [1, n]
function MOD1(value, modulus)
    if value <= 0 then
        value = 1
    end
    if not modulus or modulus <= 0 then
        modulus = 1
    end
    return ((value - 1) % modulus) + 1
end
math.mod1 = MOD1

-- ########################### DIALOGUE FUNCTIONS ###########################

-- Play a dialogue sequence
function PlayDialogueSequence(sequenceTag, listener, emitter)
    listener = listener or sequenceTag
    if not emitter then
        emitter = sequenceTag
    end
    print("***** DialogueSEQUENCE: ", sequenceTag, " :'", listener, "'")
    snd_PlayDialogueSequence(sequenceTag, listener)
end

-- Kill a dialogue sequence by its tag
function KillDialogueSequenceByTag(tag)
    snd_KillDialogueSequenceByTag(tag)
end

-- Play dialogue on a specific character
function PlayDialogueOnCharacter(goh, dialogueName, dialogueTag, dialogueIdentifier, optionalNote)
    local prefix = dialogueName .. "_" .. dialogueTag .. "_01"
    local validGOH

    if type(goh) == "GOH" and go_IsValid(goh) then
        validGOH = goh
    elseif type(goh) == "string" then
        validGOH = go_FindGOHByName(goh)
    end

    if validGOH and go_IsValid(validGOH) then
        snd_PlayDialogueByGOH(validGOH, prefix, dialogueIdentifier or dialogueName, dialogueTag)
        print("+++++ DialogueOnCHARACTER: ", dialogueName, " : ", optionalNote or "", " : ", prefix)
    else
        print("PlayDialogueOnCharacter: Invalid charName: ", goh)
    end
end

-- ########################### PATH UTILITY FUNCTIONS ###########################

-- Set a patrol path for an AI character
function path_SetPath(goh, path, closed, speed)
    local objGOH
    local validObj = false

    if type(goh) == "string" then
        objGOH = go_FindGOHByName(goh)
        if go_IsValid(objGOH) then
            validObj = true
        end
    elseif type(goh) == "GOH" and go_IsValid(goh) then
        objGOH = goh
        validObj = true
    end

    if validObj then
        ai_ClearPatrolPath(objGOH)
        local pathGOH
        local validPath = false

        if type(path) == "table" then
            -- Path is a table of GOHs or names
            local orientation = Vector(0, 0, 0)
            validPath = true
            for _, v in ipairs(path) do
                local pos = go_GetPosition(v)
                ai_AddPatrolPoint(objGOH, pos, orientation, v)
            end
        elseif type(path) == "GOH" or type(path) == "string" then
            -- Path is a single GOH or name
            if type(path) == "GOH" then
                if go_IsValid(path) then
                    pathGOH = path
                    validPath = true
                end
            elseif type(path) == "string" then
                pathGOH = go_FindGOHByName(path)
                if go_IsValid(pathGOH) then
                    validPath = true
                end
            end
            if validPath then
                ai_SetPatrolPath(objGOH, pathGOH)
            end
        end

        if validPath then
            ai_SetPatrolPathClosed(objGOH, closed)
            ai_SetMovementSpeed(objGOH, speed)
            return true
        else
            cprint("/mission/error", "Invalid path: ", path, " passed in to path_SetPath")
            return false
        end
    else
        cprint("/mission/error", "Invalid object: ", goh, " passed in to path_SetPath")
        return false
    end
end

-- Move an AI character to a locator
function path_GoToLocator(goh, locator, autonomous)
    local objGOH
    local validObj = false

    if type(goh) == "string" then
        local objectID = go_FindGOHByName(goh)
        if go_IsValid(objectID) then
            validObj = true
        end
    elseif type(goh) == "GOH" and go_IsValid(goh) then
        objGOH = goh
        validObj = true
    end

    local locatorGOH
    local validLoc = false
    local pos, orient

    if type(locator) == "string" then
        locatorGOH = go_FindGOHByName(locator)
        if go_IsValid(locatorGOH) then
            validLoc = true
        end
    elseif type(locator) == "GOH" and go_IsValid(locator) then
        locatorGOH = locator
        validLoc = true
    end

    if not validObj then
        cprint("/mission/error", "Invalid object: ", goh, " passed in to path_GoToLocator")
    end
    if not validLoc then
        cprint("/mission/error", "Invalid locator: ", locator, " passed in to path_GoToLocator")
    end

    if validObj and validLoc then
        pos = go_GetPosition(locatorGOH)
        orient = go_GetOrientation(locatorGOH)
        ai_SetTask(objGOH, "goto")
        ai_SetFixedDestination(objGOH, pos, orient)
        ai_Autonomous(objGOH, autonomous or false)
        return true
    else
        return false
    end
end

-- Move an AI character to a specific vector
function path_GoToVector(goh, pos, orient, autonomous)
    local objGOH
    local validObj = false

    if type(goh) == "string" then
        local objectID = go_FindGOHByName(goh)
        if go_IsValid(objectID) then
            validObj = true
        end
    elseif type(goh) == "GOH" and go_IsValid(goh) then
        objGOH = goh
        validObj = true
    end

    if not validObj then
        cprint("/mission/error", "Invalid object: ", goh, " passed in to path_GoToVector")
    end

    if validObj then
        ai_SetTask(objGOH, "goto")
        ai_SetFixedDestination(objGOH, pos, orient)
        ai_Autonomous(objGOH, autonomous or false)
        return true
    else
        return false
    end
end

-- ########################### AIR STRIKE FUNCTIONS ###########################

airstrikeData = {
    airStrikeElevationOffset = 200,
    airStrikeBombCount = 30,
    airStrikeDelay = 2,
    maxRadius = 25,
    airStrikeReady = true
}

-- Perform an air strike on the player's current target
function striketeam_AirStrike()
    if airstrikeData.airStrikeReady then
        local target = ai_GetTarget(PLAYER)
        airstrikeData.airStrikeReady = false
        cprint("/brian", "Airstrike vs: ", target)

        Wait(4)

        if not go_IsDead(target) then
            local targetPos = go_GetPosition(target)
            local offset = Vector(0, airstrikeData.airStrikeElevationOffset, 0)
            local spawnPos = targetPos + offset
            local dir = Vector(0, -1, 0)

            local spawnerName = "AirStrikeSpawner" .. util_GetUniqueName()
            local spawner = ai_NonManaged_Spawn(spawnerName, "missilespawner_airstrike", spawnPos, dir)
            cprint("/brian", "bomb:", spawner, " ", spawnPos)

            objective_HintText("Air Strike Called")
            go_BeginShoot(spawner, spawner)

            -- Wait based on unlockable level
            if unlockable_IsAvailable(0, Unlockable.ArtilleryStrike6) then
                Wait(3.5)
            elseif unlockable_IsAvailable(0, Unlockable.ArtilleryStrike5) then
                Wait(2)
            elseif unlockable_IsAvailable(0, Unlockable.ArtilleryStrike4) then
                Wait(2)
            elseif unlockable_IsAvailable(0, Unlockable.ArtilleryStrike3) then
                Wait(1)
            elseif unlockable_IsAvailable(0, Unlockable.ArtilleryStrike2) then
                Wait(1)
            elseif unlockable_IsAvailable(0, Unlockable.ArtilleryStrike1) then
                Wait(0.3)
            end

            go_EndShoot(spawner)
            scenario_PostEventString("airStrikeComplete")
            airstrikeData.airStrikeReady = true
            ai_ReportAirStrike()
            Wait(0.1)
            go_DeleteObject(spawner)
        else
            objective_HintText("Target Already Dead")
            cprint("/brian", "Airstrike vs Dead Target")
            airstrikeData.airStrikeReady = true
        end
    else
        objective_HintText("Air Strike currently unavailable")
        cprint("/brian", "Airstrike unavailable")
    end
end

-- Generate a random offset for air strike bombs
function striketeam_AirStrikeOffset(minRadius, maxRadius)
    local x = math.random(-10, 10)
    local z = math.random(-10, 10)
    local vec = Vector(x, 0, z)
    vec = vector.VectorNormalize(vec)
    local radius = math.random(minRadius, maxRadius)
    return vector.VectorScale(vec, radius)
end

-- ########################### ARTILLERY STRIKE FUNCTIONS ###########################

artilleryStrikeData = {
    artilleryStrikeElevationOffset = 200,
    artilleryStrikeBombCount = 10,
    artilleryStrikeDelay = 2,
    maxRadius = 25,
    artilleryStrikeReady = true
}

-- Perform an artillery strike on a specific target
function striketeam_ArtilleryStrike(target)
    if artilleryStrikeData.artilleryStrikeReady then
        cprint("/brian", "ArtilleryStrike vs: ", target)

        if not go_IsDead(target) then
            local targetPos = go_GetPosition(target)
            local offset = Vector(0, artilleryStrikeData.artilleryStrikeElevationOffset, 0)
            local spawnPos = targetPos + offset
            local dir = Vector(0, -1, 0)

            local spawnerName = "ArtilleryStrikeSpawner" .. util_GetUniqueName()
            local spawner = ai_NonManaged_Spawn(spawnerName, "missilespawner_artillery", spawnPos, dir)
            cprint("/brian", "bomb:", spawner, " ", spawnPos)

            go_Shoot(spawner, spawner)
            scenario_PostEventString("artilleryStrikeComplete")
            Wait(0.1)
            go_DeleteObject(spawner)
        else
            objective_HintText("Target Already Dead")
            cprint("/brian", "ArtilleryStrike vs Dead Target")
        end
    else
        objective_HintText("Air Strike currently unavailable")
        cprint("/brian", "ArtilleryStrike unavailable")
    end
end

-- ########################### NIS / CINEMATIC FUNCTIONS ###########################

-- Lock the player for a cinematic (NIS)
function nis_LockPlayer(lock)
    if lock then
        if gNisLockPlayerParams.playerLocked then
            gNisLockPlayerParams.playerLocked = gNisLockPlayerParams.playerLocked + 1
        else
            gNisLockPlayerParams.playerLocked = 1
            gNisLockPlayerParams.nodeToLock = context.node
            go_SetDamageable(PLAYER, false)
            go_SetNoPushback(PLAYER, true)
            ai_SetTargetable(PLAYER, false)
            disguise_ProtectAlertAgainstNoTarget(PLAYER, true)
            go_ClearCharge(PLAYER)
            go_ClearCharacterIntention(PLAYER)
            go_LockCharacterIntention(PLAYER, true)
            go_SetUninterruptible(PLAYER, true)

            local vehicle = go_GetAttachedTo(PLAYER)
            if ai_IsPlayerInVehicle(PLAYER) and go_IsValid(vehicle) then
                gNisLockPlayerParams.vehicle = vehicle
                go_ForceHeliToHover(vehicle, true)
                go_ForceEBrake(vehicle, true)
                go_SetDamageable(vehicle, false)
            else
                gNisLockPlayerParams.vehicle = nil
            end
        end
    else
        if not gNisLockPlayerParams.playerLocked then
            mms_Error("", "ERROR: nis_LockPlayer(false) player isn't currently locked. Calling node is " .. (context.node or ""))
        else
            gNisLockPlayerParams.playerLocked = gNisLockPlayerParams.playerLocked - 1
            if gNisLockPlayerParams.playerLocked == 0 then
                gNisLockPlayerParams.playerLocked = nil
                gNisLockPlayerParams.nodeToLock = nil
                go_SetDamageable(PLAYER, true)
                go_SetNoPushback(PLAYER, false)
                ai_SetTargetable(PLAYER, true)
                disguise_ProtectAlertAgainstNoTarget(PLAYER, false)
                go_LockCharacterIntention(PLAYER, false)
                go_SetUninterruptible(PLAYER, false)

                if gNisLockPlayerParams.vehicle then
                    if go_IsValid(gNisLockPlayerParams.vehicle) then
                        go_ForceHeliToHover(gNisLockPlayerParams.vehicle, false)
                        go_ForceEBrake(gNisLockPlayerParams.vehicle, false)
                        go_SetDamageable(gNisLockPlayerParams.vehicle, true)
                    end
                    gNisLockPlayerParams.vehicle = nil
                end
            end
        end
    end
end

-- Check if the player is currently locked for a NIS
function nis_IsPlayerLocked()
    return gNisLockPlayerParams.playerLocked and gNisLockPlayerParams.playerLocked > 0
end

-- Get the reference count of the player lock
function nis_GetPlayerLockedRefCount()
    return gNisLockPlayerParams.playerLocked or 0
end

-- Flash the screen to black and back
function nis_FlashBlack(duration)
    nism_FadeToBlack(duration)
    Wait(duration)
    nism_FadeFromBlack(duration)
end

-- Flash the screen to white and back
function nis_FlashWhite(duration)
    nism_FadeToWhite(duration)
    Wait(duration)
    nism_FadeFromWhite(duration)
end

-- Set camera data for a NIS
function nis_SetCameraData(scData)
    -- Stores camera data globally for use during the NIS
end

-- ########################### DEFEND AREA FUNCTIONS ###########################

-- Set an AI character to defend its current position
function defend_CurrentPosition(goh, radius)
    local objGOH
    local valid = false

    if type(goh) == "string" then
        objGOH = go_FindGOHByName(goh)
        if go_IsValid(objGOH) then
            valid = true
        end
    elseif type(goh) == "GOH" and go_IsValid(goh) then
        objGOH = goh
        valid = true
    end

    if valid then
        local pos = go_GetPosition(objGOH)
        local orient = go_GetOrientation(objGOH)
        ai_SetDefendArea(objGOH, pos, orient, radius)
        return true
    else
        cprint("/mission/error", "Invalid object: ", goh, " passed in to defend_CurrentPosition")
        return false
    end
end

-- Set an AI character to defend a specific locator
function defend_Locator(goh, locator, radius)
    local objGOH
    local validObj = false
    local locGOH
    local validLoc = false

    if type(goh) == "string" then
        objGOH = go_FindGOHByName(goh)
        if go_IsValid(objGOH) then
            validObj = true
        end
    elseif type(goh) == "GOH" and go_IsValid(goh) then
        objGOH = goh
        validObj = true
    end

    if type(locator) == "string" then
        locGOH = go_FindGOHByName(locator)
        if go_IsValid(locGOH) then
            validLoc = true
        end
    elseif type(locator) == "GOH" and go_IsValid(locator) then
        locGOH = locator
        validLoc = true
    end

    if validObj and validLoc then
        local pos = go_GetPosition(locGOH)
        local orient = go_GetOrientation(locGOH)
        ai_SetDefendArea(objGOH, pos, orient, radius)
        return true
    else
        if not validObj then
            cprint("/mission/error", "Invalid object: ", goh, " passed in to defend_Locator")
        end
        if not validLoc then
            cprint("/mission/error", "Invalid locator: ", locator, " passed in to defend_Locator")
        end
        return false
    end
end

-- ########################### DISGUISE FUNCTIONS ###########################

-- Blow the disguise of a player or all players
function disguise_BlowDisguise(target, reason)
    if target == PLAYER then
        ai_BlowDisguise(target, reason)
    elseif string.upper(target) == "ALLPLAYERS" then
        ai_BlowDisguise(PLAYER, reason)
    else
        cprint("/mission/error", "Invalid target: ", target, " passed into disguise_BlowDisguise")
    end
end

-- ########################### SPAWN FUNCTIONS ###########################

-- Spawn a character at a smart node
function spawn_AtSmartNode(name, template, node, subType)
    local goh
    if type(node) == "string" then
        goh = go_FindGOHByName(node)
    elseif type(node) == "GOH" then
        goh = node
    end

    if go_IsValid(goh) then
        local pos = smartnode_GetPosition(goh, subType)
        local orient = smartnode_GetOrientation(goh, subType)
        local spawned = ai_NonManaged_Spawn_CPP(name, template, pos, orient)

        if go_IsValid(spawned) then
            return spawned
        else
            cprint("/error/mission", "Error trying to spawn ", name, " of ", template, " at ", locator)
            return nil
        end
    else
        cprint("/error/mission", "Unable to find locator : ", locator, " -- Unable to spawn ", name)
        return nil
    end
end

-- ########################### RADIO / HUD FUNCTIONS ###########################

ShouldUseRadioHQScriptedCamera = true

function UseRadioHQScriptedCamera(shouldUse)
    ShouldUseRadioHQScriptedCamera = shouldUse
end

-- ########################### GLOBAL SYSTEMS STATE ###########################

Game_gsys = {
    city = true,
    outdoor = true
}

-- Refresh the state of global systems (ambient, patrols, strike teams)
function gsys_RefreshGlobalSystemsState(city, outdoor)
    if Game_gsys.city ~= city then
        if city then
            amb_EnableManager(Game_gsys.ambEnabled)
            ai_patrol_Enable(Game_gsys.patrolEnabled)
            ai_EnableStrikeTeams(Game_gsys.stEnabled)
        else
            Game_gsys.ambEnabled = amb_IsEnabledManager()
            Game_gsys.patrolEnabled = ai_patrol_IsEnabled()
            Game_gsys.stEnabled = ai_IsStrikeTeamsEnabled()
            amb_EnableManager(false)
            ai_patrol_Enable(false)
            ai_EnableStrikeTeams(false)
        end
        Game_gsys.city = city
    end

    -- Note: outdoor handling is incomplete in this snippet
    if Game_gsys.outdoor ~= outdoor then
        Game_gsys.outdoor = outdoor
    end
end

-- ########################### FRAMER CAMERA FUNCTIONS ###########################

framerCam = {
    SequenceStartEvent = 0,
    SequenceEndEvent = 1,
    SequenceAbortedEvent = 2,
    ViewStartEvent = 3,
    ViewEndEvent = 4
}

-- Parameters for framing shots based on character type
fcam_ViewParamsForType = {
    alex = {
        near = { framingHeights = {0.5}, focusJoints = {"Head"} },
        mid = { framingHeights = {2}, focusJoints = {"Head"} },
        far = { framingHeights = {4}, focusJoints = {"Motion_Root"} }
    },
    human = {
        near = { framingHeights = {0.5}, focusJoints = {"Head"} },
        mid = { framingHeights = {2}, focusJoints = {"Head"} },
        far = { framingHeights = {4}, focusJoints = {"Motion_Root"} }
    },
    tank = {
        near = { framingHeights = {2.5}, focusJoints = {"cannon_end"} },
        mid = { framingHeights = {4.5}, focusJoints = {"gun_turret"} },
        far = { framingHeights = {7.5}, focusJoints = {"Motion_Root"} }
    },
    apc = {
        near = { framingHeights = {2}, focusJoints = {"cannon_end"} },
        mid = { framingHeights = {4}, focusJoints = {"gun_turret"} },
        far = { framingHeights = {7}, focusJoints = {"Motion_Root"} }
    },
    heli = {
        near = { framingHeights = {2.5, 3}, focusJoints = {"Gun_Turret", "Tail_Wing"} },
        mid = { framingHeights = {5}, focusJoints = {"Grapple_CockpitFront"} },
        far = { framingHeights = {9}, focusJoints = {"Motion_Root"} }
    },
    brawler = {
        near = { framingHeights = {1.25, 0.75}, focusJoints = {"Head", "Claw"} },
        mid = { framingHeights = {2.75}, focusJoints = {"Head"} },
        far = { framingHeights = {4.5}, focusJoints = {"Motion_Root"} }
    },
    vehicle = {
        near = { framingHeights = {3}, focusOffsets = {Vector(0, 1.5, 0)} },
        mid = { framingHeights = {6}, focusOffsets = {Vector(0, 1.5, 0)} },
        far = { framingHeights = {9}, focusOffsets = {Vector(0, 1.5, 0)} }
    }
}

-- Get view parameters for a specific GOH based on its class
function fcam_GetViewParamsForType(goh)
    local classUID = go_GetUIDAttr(goh, UID("className"))
    local paramType = "human"

    if classUID == UID("alex") then
        paramType = "alex"
    elseif classUID == UID("brawler") then
        paramType = "brawler"
    elseif classUID == UID("heli_bh_marine") or classUID == UID("heli_gunship_marine_core") then
        paramType = "heli"
    elseif classUID == UID("tank_ram_marine") or classUID == UID("tank_ram_thermobaric") then
        paramType = "tank"
    elseif classUID == UID("apc_m2_marine") then
        paramType = "apc"
    elseif classUID == UID("gun_turret") then
        paramType = "turret"
    elseif classUID == UID("civilian_car") or classUID == UID("nypd_police_car") or classUID == UID("military_truck") then
        paramType = "vehicle"
    end

    return fcam_ViewParamsForType[paramType]
end

-- ########################### FRAMER CAMERA UTILITY FUNCTIONS ###########################

-- Create mirrored views for object-space framing
function fcm_MakeMirroredViewsObjectSpace(view)
    local mirroredViews = {}
    local left = table.copy(view)
    left.name = left.name .. "_left"
    for _, offset in ipairs(left.posOffsets) do
        offset.x = -offset.x
    end
    local right = table.copy(view)
    right.name = right.name .. "_right"
    mirroredViews[1] = left
    mirroredViews[2] = right
    return mirroredViews
end

-- Create mirrored views for world-space framing
function fcm_MakeMirroredViewsWorldSpace(view, separation)
    local mirroredViews = {}
    local left = table.copy(view)
    left.name = left.name .. "_left"
    for i, offset in ipairs(left.posOffsets) do
        left.posOffsets[i] = offset - separation
    end
    local right = table.copy(view)
    right.name = right.name .. "_right"
    for i, offset in ipairs(right.posOffsets) do
        right.posOffsets[i] = offset + separation
    end
    mirroredViews[1] = left
    mirroredViews[2] = right
    return mirroredViews
end

-- Create a base view for combat framing
function fcm_MakeCombatBaseView()
    local player = go_GetLocalPlayer()
    local view = {
        shotTimes = {500},
        scoreOnRelativeDirection = true,
        zeroScoreCanStillActivate = true,
        viewRejectAngleThreshold = 180,
        focusObjects = {player},
        posRelObject = player,
        framingHeights = {"mid"},
        viewTransitionTime = 0.5,
        doCollision = true
    }
    return view
end

-- Base sequence for combat framing
fcm_CombatBaseSequence = {
    letterBox = false,
    sequenceMethod = "best",
    freezePlayer = false,
    adaptGameCamera = true,
    cameraStick = true,
    blendInTime = 0.5,
    blendOutTime = 0.5,
    ignoreHUDElements = 65535,
    isRealtime = true,
    dampeningFactor = 0.1,
    obstructionHelper = {
        isDynamic = true,
        volumeWidth = 1,
        volumeHeight = 1,
        fadeTypes = {
            peds = true,
            vehicles = true,
            air = true,
            hunters = true,
            tanks = true,
            dead = true,
            props = true,
            displacedProps = true
        }
    }
}

-- Create a simple framer camera shot
function fcm_CreateSimpleFramerCam(params)
    local sequence = {
        freezePlayer = false,
        adaptGameCamera = params.AdaptGameCamera,
        letterBox = false,
        ignoreHUDElements = HUD_ELEMENT.ALL,
        blendInTime = params.BlendIn,
        blendOutTime = params.BlendOut,
        interrupt = true,
        cleanCut = params.BlendIn == 0,
        isRealtime = params.RealTime,
        dampeningFactor = 0.01,
        allowLowHealthEffect = params.AllowLowHealthEffect,
        obstructionHelper = {
            isDynamic = true,
            volumeWidth = 1,
            volumeHeight = 1,
            fadeTypes = {
                vehicles = true,
                air = true,
                tanks = true,
                dead = true,
                props = true
            }
        },
        viewDefs = {
            {
                name = "motion_simpleFramerCam",
                doCollision = true,
                shotTimes = {0, 0},
                posRelObjects = {params.PosObject},
                posOffsets = {params.PosOffsets},
                focusObjects = {params.FocusObject},
                focusOffsets = {params.FocusOffsets},
                fovs = {params.FOVs},
                rollAngles = {params.Roll}
            }
        }
    }
    return cm_CreateFramerCamSequence(sequence)
end

-- ########################### FRAMER CAMERA DEBUGGING ###########################

function fcm_TraceShotTimes(view, viewIndex, delay)
    if type(view.viewDefs[viewIndex]) ~= "table" then
        return
    end

    dbg_fcm = {}
    dbg_fcm.TickCont = time_GetElapsedTime()
    print("TRACING NEW VIEW:", viewIndex)

    local shotList = view.viewDefs[viewIndex].shotTimes
    local transList = view.viewDefs[viewIndex].transitionTimes
    dbg_fcm.shotList = shotList
    dbg_fcm.transList = transList

    local function startShot(shotIndex)
        dbg_fcm.curShot = shotIndex
        dbg_fcm.ShotTime = time_GetElapsedTime()
        local tickCont = string.format("%.2f", time_GetElapsedTime() - dbg_fcm.TickCont)
        local shotCont = string.format("%.2f", time_GetElapsedTime() - dbg_fcm.ShotTime)
        print("Time[", tickCont, "][", shotCont, "] Start shot: ", dbg_fcm.curShot, " duration: ", dbg_fcm.shotList[dbg_fcm.curShot])
        if view then
            -- Print focus objects? (The debug code here is incomplete)
        end

        if dbg_fcm.curShot <= #dbg_fcm.shotList then
            dbg_fcm.ssID = schedule(dbg_fcm.shotList[dbg_fcm.curShot], endShot, dbg_fcm.curShot)
        end
    end

    function endShot(shotIndex, time)
        local tickCont = string.format("%.2f", time_GetElapsedTime() - dbg_fcm.TickCont)
        local shotCont = string.format("%.2f", time_GetElapsedTime() - dbg_fcm.ShotTime)
        print("Time[", tickCont, "][", shotCont, "] End shot: ", shotIndex, " time: ", time, " transition time: ", dbg_fcm.transList[dbg_fcm.curShot])
        if dbg_fcm.curShot <= #dbg_fcm.transList then
            dbg_fcm.ssID = schedule(dbg_fcm.transList[dbg_fcm.curShot], startShot, dbg_fcm.curShot)
        end
    end

    function tickTock(delay)
        local tickCont = string.format("%.2f", time_GetElapsedTime() - dbg_fcm.TickCont)
        local shotCont = string.format("%.2f", time_GetElapsedTime() - dbg_fcm.ShotTime)
        print("Time[", tickCont, "]", "[", shotCont, "]")
        if delay > 0 then
            dbg_fcm.tickTickTickID = schedule(delay, tickTock, delay)
        end
    end

    startShot(0, 0)
    if delay and delay > 0 then
        tickTock(delay)
    end
end

function fcm_EndFcamDebug()
    if dbg_fcm.tickTickTickID then
        unschedule(dbg_fcm.tickTickTickID)
    end
    if dbg_fcm.ssID then
        unschedule(dbg_fcm.ssID)
    end
    if dbg_fcm.autoTransitionID then
        unschedule(dbg_fcm.autoTransitionID)
    end
end

function fcm_AutoTransitionAtEnd(view, viewIndex, targetView)
    local viewDef = view.viewDefs[viewIndex]
    if type(viewDef) ~= "table" or type(viewDef.shotTimes) ~= "table" then
        return
    end

    local totalTime = 0
    for _, v in ipairs(viewDef.shotTimes) do
        totalTime = totalTime + v
    end
    for _, v in ipairs(viewDef.transitionTimes) do
        totalTime = totalTime + v
    end

    dbg_fcm.autoTransitionID = schedule(totalTime, InternalViewChange, targetView)
end

-- ########################### SOUND / VIRTUAL CHARACTERS ###########################

-- Enable virtual characters for dialogue
snd_EnableVirtualCharacter("virtual")
snd_EnableVirtualCharacter("__bw_alerts")
snd_EnableVirtualCharacter("__gentek_alerts")
snd_EnableVirtualCharacter("_blackwatch_striketeam")
snd_EnableVirtualCharacter("_helicopter_pilot")
snd_EnableVirtualCharacter("_tank_blackwatch")
snd_EnableVirtualCharacter("_tank_marine")
snd_EnableVirtualCharacter("_blackwatch_hq")

-- ########################### STEALTH CONSUME WATCHERS ###########################

FailedStealthConsumeWatchers = {}
StealthConsumeWatchersNeedsOwner = coroutine.running()

-- Set up icons for stealth consume watchers
function SetStealthConsumeWatcherIcons()
    for _, goh in ipairs(FailedStealthConsumeWatchers) do
        fes_AddMarker(goh, Marker_Event_StealthWatcher)
    end
    StealthConsumeWatchersNeedsOwner = coroutine.running()
end

-- Clear stealth consume watcher icons (only if called by the owner)
function ClearStealthConsumeWatcherIcons()
    if coroutine.running() == StealthConsumeWatchersNeedsOwner then
        UnconditionalClearStealthConsumeWatcherIcons()
    end
end

-- Unconditionally clear all stealth consume watcher icons
function UnconditionalClearStealthConsumeWatcherIcons()
    for _, goh in ipairs(FailedStealthConsumeWatchers) do
        if go_IsValid(goh) then
            fes_RemoveMarker(goh, Marker_Event_StealthWatcher)
        end
    end
    FailedStealthConsumeWatchers = {}
end

-- ########################### INTERFACE / PRESENTATION ###########################

Interface = {}
PresentationTemplateData = {}

-- ########################### MINIMAP TEXTURE NAMES ###########################

minimapTextureNames = {
    OBJECTIVE_DESTROY = "marker_small_objective_kill.dds",
    OBJECTIVE_PROTECT = "marker_small_objective_protect.dds",
    OBJECTIVE_CONSUME = "marker_small_objective_consume.dds",
    OBJECTIVE_GOTO = "marker_small_objective_goto.dds",
    OBJECTIVE_MISSION = "marker_small_mission_dana_mercer.dds",
    OBJECTIVE_AIRBRIDGE = "marker_small_airbridge.dds",
    OBJECTIVE_WAYPOINT = "marker_small_waypoint.dds",
    AREA_RECTANGLE = "hud_minimap_arearectangle_diffuse.dds",
    AREA_CIRCLE = "hud_minimap_areacircle_diffuse.dds",
    AREA_RING = "hud_minimap_arearing_diffuse.dds",
    AREA_STRIKETEAM = "marker_small_strike_team.dds",
    ENEMY_LARGE = "hud_minimap_enemylarge_diffuse.dds",
    ENEMY_SMALL = "hud_minimap_enemysmall_diffuse.dds",
    STRIKETEAM = "marker_small_strike_team.dds",
    HELICOPTER = "hud_minimap_enemyhelicopter_diffuse.dds",
    OBJECTIVE_KOENIG = "marker_small_mission_anton_koenig.dds",
    OBJECTIVE_BLACKNET = "marker_small_blacknet_generic.dds",
    OBJECTIVE_DANA = "marker_small_mission_dana_mercer.dds",
    OBJECTIVE_ROOKS = "marker_small_mission_douglas_rooks.dds",
    OBJECTIVE_GUERRA = "marker_small_mission_luis_guera.dds",
    OBJECTIVE_GALLOWAY = "marker_small_mission_sabrina_galloway.dds",
    OBJECTIVE_OPENWORLDMISSION = "marker_small_blacknet_access_point.dds",
    COLLECTABLE_LAIR = "marker_small_lair.dds",
    COLLECTABLE_LAIR_DEFEATED = "marker_small_lair_defeated.dds",
    COLLECTABLE_BLACKBOX = "marker_small_blackbox_generic.dds",
    COLLECTABLE_DEATHSQUAD = "marker_small_field_ops_generic.dds",
    EVENT_CONTAINER = "marker_small_event_container.dds",
    EVENT_BARREL = "marker_small_event_barrel.dds",
    EVENT_CR = "marker_small_event_cr.dds",
    EVENT_SP = "marker_small_event_sp.dds",
    EVENT_RR = "marker_small_event_rr.dds",
    EVENT_RA = "marker_small_event_ra.dds",
    EVENT_CD = "marker_small_event_cd.dds",
    STEALTH_CONSUME_WATCHER = "marker_small_stealth_consume_watcher.dds",
    OBJECTIVE_CHASE = "marker_small_objective_chase.dds",
    OBJECTIVE_CONSUME_UPGRADE = "marker_small_objective_consume_upgrade.dds",
    OBJECTIVE_CONSUME_WOI = "marker_small_objective_consume_woi.dds",
    OBJECTIVE_CONSUME_KEY = "marker_small_objective_consume_key.dds",
    OBJECTIVE_INTERACT = "marker_small_objective_interact.dds",
    BLACKNET_CONSUME = "marker_small_blacknet_consume.dds",
    BLACKNET_CONSUME_UPGRADE = "marker_small_blacknet_consume_upgrade.dds",
    BLACKNET_CONSUME_WOI = "marker_small_blacknet_consume_woi.dds",
    BLACKNET_CONSUME_KEY = "marker_small_blacknet_consume_key.dds",
    EVENT_ALERT = "marker_small_event_alert.dds",
    EVENT_MEDAL_PLATINUM = "marker_small_event_medal_platinum.dds",
    EVENT_MEDAL_GOLD = "marker_small_event_medal_gold.dds",
    EVENT_MEDAL_SILVER = "marker_small_event_medal_silver.dds",
    EVENT_MEDAL_BRONZE = "marker_small_event_medal_bronze.dds",
    EXCLAMATION_BLUE = "marker_small_exclamation_blue.dds",
    EXCLAMATION_YELLOW = "marker_small_exclamation_yellow.dds",
    OPTIONAL_INTERACT = "marker_small_optional_interact.dds",
    OBJECTIVE_GOTO_NEXT = "marker_small_objective_goto_next.dds"
}

-- List of offscreen 2D textures for markers
offscreen2DTextures = {
    "marker_small_objective_kill.dds",
    "marker_small_objective_protect.dds",
    "marker_small_objective_consume.dds",
    "marker_small_objective_goto.dds",
    "marker_small_mission_dana_mercer.dds",
    "marker_small_stealth_consume_watcher.dds",
    "marker_small_strike_team.dds",
    "marker_small_chopper_off_screen.dds",
    "marker_small_airbridge.dds",
    "marker_small_waypoint.dds",
    "marker_small_blacknet_generic.dds",
    "marker_small_event_barrel.dds",
    "marker_small_event_container.dds",
    "marker_small_event_cr.dds",
    "marker_small_event_sp.dds",
    "marker_small_event_ra.dds",
    "marker_small_event_rr.dds",
    "marker_small_event_cd.dds",
    "marker_small_mission_douglas_rooks.dds",
    "marker_small_mission_anton_koenig.dds",
    "marker_small_mission_luis_guera.dds",
    "marker_small_mission_sabrina_galloway.dds",
    "marker_small_mission_dana_mercer.dds",
    "marker_small_blacknet_generic.dds",
    "marker_small_blacknet_access_point.dds",
    "marker_small_objective_chase.dds",
    "marker_small_objective_consume_upgrade.dds",
    "marker_small_objective_consume_woi.dds",
    "marker_small_objective_consume_key.dds",
    "marker_small_objective_interact.dds",
    "marker_small_blacknet_consume.dds",
    "marker_small_blacknet_consume_upgrade.dds",
    "marker_small_blacknet_consume_woi.dds",
    "marker_small_blacknet_consume_key.dds",
    "marker_small_lair.dds",
    "marker_small_field_ops_generic.dds",
    "marker_small_blackbox_generic.dds",
    "marker_small_event_alert.dds",
    "marker_small_event_medal_platinum.dds",
    "marker_small_event_medal_gold.dds",
    "marker_small_event_medal_silver.dds",
    "marker_small_event_medal_bronze.dds",
    "marker_small_exclamation_blue.dds",
    "marker_small_exclamation_yellow.dds",
    "marker_small_optional_interact.dds",
    "marker_small_objective_goto_next.dds"
}

-- Register 2D marker textures with the front-end
fe_RegisterMarkerTextures2D(offscreen2DTextures)

-- Constants for 2D texture indices
TEXTURE_2D_DESTROY = 0
TEXTURE_2D_PROTECT = 1
TEXTURE_2D_CONSUME = 2
TEXTURE_2D_GOTO = 3
TEXTURE_2D_MISSION = 4
TEXTURE_2D_UAV = 5
TEXTURE_2D_RADIO = 6
TEXTURE_2D_HELICOPTER = 7
TEXTURE_2D_AIRBRIDGE = 8
TEXTURE_2D_WAYPOINT = 9
TEXTURE_2D_OPENWORLDMISSION = 10
TEXTURE_2D_EVENT_BARREL = 11
TEXTURE_2D_EVENT_CONTAINER = 12
TEXTURE_2D_EVENT_CR = 13
TEXTURE_2D_EVENT_SP = 14
TEXTURE_2D_EVENT_RA = 15
TEXTURE_2D_EVENT_RR = 16
TEXTURE_2D_EVENT_CD = 17
TEXTURE_2D_MISSION_ROOKS = 18
TEXTURE_2D_MISSION_KOENIG = 19
TEXTURE_2D_MISSION_GUERA = 20
TEXTURE_2D_MISSION_GALLOWAY = 21
TEXTURE_2D_MISSION_MERCER = 22
TEXTURE_2D_MISSION_BLACKNET_GENERIC = 23
TEXTURE_2D_MISSION_BLACKNET_ACCESS = 24
TEXTURE_2D_CHASE = 25
TEXTURE_2D_UPGRADE = 26
TEXTURE_2D_WOI = 27
TEXTURE_2D_KEY = 28
TEXTURE_2D_INTERACT = 29
TEXTURE_2D_BLACKNET_CONSUME = 30
TEXTURE_2D_BLACKNET_UPGRADE = 31
TEXTURE_2D_BLACKNET_WOI = 32
TEXTURE_2D_BLACKNET_KEY = 33
TEXTURE_2D_LAIR = 34
TEXTURE_2D_FIELD_OPS = 35
TEXTURE_2D_BLACKBOX = 36
TEXTURE_2D_EVENT_ALERT = 37
TEXTURE_2D_EVENT_MEDAL_PLATINUM = 38
TEXTURE_2D_EVENT_MEDAL_GOLD = 39
TEXTURE_2D_EVENT_MEDAL_SILVER = 40
TEXTURE_2D_EVENT_MEDAL_BRONZE = 41
TEXTURE_2D_EXCLAMATION_BLUE = 42
TEXTURE_2D_EXCLAMATION_YELLOW = 43
TEXTURE_2D_OPTIONAL_INTERACT = 44
TEXTURE_2D_OBJECTIVE_GOTO_NEXT = 45

DEFAULT_MINIMAP_ROTATION = -1
TEXTURE_2D_NONE = -1

-- Register 3D marker resources
fe_Set3DMarkerResourceInfo(MARKER_TYPE.DESTROY, 10, "objectiveKillMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.INTERACT, 5, "objectiveInteractMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.PROTECT, 4, "objectiveProtectMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.CONSUME, 8, "missionConsumeMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.CONSUME_KEY, 1, "objectiveConsumeKeyMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.CONSUME_UPGRADE, 1, "objectiveConsumeUpgradeMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.CONSUME_WOI, 1, "objectiveConsumeWOIMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.GOTO, 4, "gotoMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.CHASE, 4, "objectiveChaseMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.MISSION, 1, "missionDanaMercerMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.MISSION_ROOKS, 1, "missionDouglasRooksMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.MISSION_KOENING, 1, "missionAntonKoenigMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.MISSION_GUERA, 1, "missionLuisGueraMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.MISSION_GALLOWAY, 1, "missionSabrinaGallowayMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.MISSION_MERCER, 1, "missionDanaMercerMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.MISSION_BLACKNET, 1, "blacknetGenericMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.WEBNODE, 1, "objectiveConsumeWOIMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.STEALTH_CONSUME_WATCHER, 10, "stealthConsumeWatcherMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.ENEMY_STRIKETEAM, 4, "strikeTeamMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.RADIO, 1, "strikeTeamMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.INGAMEBUTTON_B, 10, "actionConsumeFinisher")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.INGAMEBUTTON_X, 3, "buttonLeftMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.INGAMEBUTTON_Y, 3, "buttonTopMarker")

-- PC-specific button markers
if RAD_WIN32 then
    fe_Set3DMarkerResourceInfo(MARKER_TYPE.INGAMEBUTTON_BLADE, 3, "bladeMarker")
    fe_Set3DMarkerResourceInfo(MARKER_TYPE.INGAMEBUTTON_CLAWS, 3, "clawsMarker")
    fe_Set3DMarkerResourceInfo(MARKER_TYPE.INGAMEBUTTON_HAMMERFIST, 3, "hammerfistMarker")
    fe_Set3DMarkerResourceInfo(MARKER_TYPE.INGAMEBUTTON_TENDRILS, 3, "tendrilsMarker")
    fe_Set3DMarkerResourceInfo(MARKER_TYPE.INGAMEBUTTON_WHIPFIST, 3, "whipfistMarker")
end

fe_Set3DMarkerResourceInfo(MARKER_TYPE.AIRBRIDGE, 1, "airbridgeMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.WAYPOINT, 1, "waypointMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.OPENWORLD_VEHICLECOMMANDER, 1, "openWorldMissionMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.OPENWORLDMISSION_TERMINAL, 3, "openWorldMissionMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.OPENWORLD_CONSUME, 9, "blacknetConsumeMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.OPENWORLD_CONSUME_KEY, 6, "blacknetConsumeKeyMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.OPENWORLD_CONSUME_UPGRADE, 9, "blacknetConsumeUpgradeMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.OPENWORLD_CONSUME_WOI, 9, "blacknetConsumeWOIMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.EVENT_CONTAINER, 8, "containerMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.EVENT_BARREL, 8, "barrelMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.EVENT_SP, 3, "spMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.EVENT_CR, 3, "crMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.EVENT_RR, 3, "rrMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.EVENT_RA, 3, "raMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.EVENT_CD, 3, "cdMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.COLLECTABLE_LAIR, 3, "lairMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.COLLECTABLE_BLACKBOX, 3, "blackboxGenericMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.COLLECTABLE_DEATHSQUAD, 10, "fieldOpsGenericMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.EVENT_MEDAL_PLATINUM, 3, "eventMedalPlatinumMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.EVENT_MEDAL_GOLD, 3, "eventMedalGoldMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.EVENT_MEDAL_SILVER, 3, "eventMedalSilverMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.EVENT_MEDAL_BRONZE, 3, "eventMedalBronzeMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.EVENT_ALERT, 3, "eventAlertMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.GOTO_NEXT, 4, "gotoNextMarker")
fe_Set3DMarkerResourceInfo(MARKER_TYPE.OPTIONAL_INTERACT, 6, "optionalInteractMarker")

-- PC-specific markers for keyboard controls
if RAD_WIN32 then
    fe_Set3DMarkerResourceInfo(MARKER_TYPE.CONSUME_FINISHER_PC, 1, "consumeFinisherKeyboardMarker")
    fe_Set3DMarkerResourceInfo(MARKER_TYPE.EXCLAMATION_BLUE, 1, "exclamationBlueMarker")
    fe_Set3DMarkerResourceInfo(MARKER_TYPE.EXCLAMATION_YELLOW, 1, "exclamationYellowMarker")
end

-- Initialize 3D marker system
fe_3DMarkerInitialize()

-- ########################### MARKER PROFILES ###########################

-- Helper to create a marker profile (metatable-based inheritance)
function fes_CreateMarkerProfile(baseProfile)
    local profile = {}
    profile.__index = baseProfile
    return setmetatable(profile, profile)
end

-- Base marker profile
Marker_Base_Profile = {
    iconType = MARKER_TYPE.NONE,
    iconTypePC = MARKER_TYPE.NONE,
    displayType = MARKER_DISPLAY_TYPE.DEFAULT,
    markerCallerType = MARKER_CALLER.NONE,
    animType = MARKER_ANIM_2D.PULSE_SLOW,
    displayLayerMap = MARKER_LAYER.HIGH,
    title = "Please give your marker a title",
    description = "",
    maxNumToDisplay = -1,
    displayBudgetType = MARKER_DISPLAY_BUDGET.UNKNOWN,
    serializable = false,
    priority = MARKER_PRIORITY.MIN,
    altPriority = MARKER_PRIORITY.NONE,
    prioritySwitchFrequency = 2,
    iconScaleOnscreen = 0.12,
    arrowScaleOnscreen = 0.085,
    iconOffsetRatioOnscreen = 0.08,
    maxAlphaOnscreen = 1,
    minAlphaOnscreen = 1,
    minAlphaDistanceOnscreen = 25,
    iconMaxAlphaDistance = 200,
    isArrowVisibleOnscreen = true,
    iconOrientsDownwardsWhenOffscreen = true,
    maxVisibleDistance3D = 20,
    markerNearScale3D = 0.5,
    markerFarScale3D = 1.1,
    markerFlashTime3D = 0,
    markerFlashAmount = 0.25,
    maxAlphaDistance3D = 2,
    markerNearAlpha3D = 0,
    markerFarAlpha3D = 1,
    widthMap = 25,
    heightMap = 25,
    rotationMap = DEFAULT_MINIMAP_ROTATION,
    minimapMaxDisplayDistance = 1000000000,
    textureNameMinimap = minimapTextureNames.OBJECTIVE_PROTECT,
    textureNameMinimapPC = nil,
    textureNameIndex2D = TEXTURE_2D_CONSUME,
    textureNameIndex2DPC = TEXTURE_2D_NONE,
    miniMapDisableColorTint = false,
    minimapIntro = false,
    minimapIntroLengthSeconds = 4,
    minimapIntroFrequencyHz = 3,
    minimapIntroScalingDuration = 0,
    minimapIntroScalingFactor = 1,
    minimapFadeOutEndDistance = -1,
    minimapFadeOutStartDistance = -1,
    minimapMinFadeAlpha = 1,
    minimapOutro = false,
    minimapIdleAnimation = false,
    minimapConstantRotate = false,
    renderOrderMap = 20,
    enableColourTinting = false,
    iconColour = {255, 255, 255},
    offsetY = 0.4,
    charcterJoint = "Character_Root",
    enableGrouping = false,
    groupingDistance = 100,
    minGroupCount = 3,
    enableSubscript = false,
    enable3DOverride = false,
    enableAlternating = false,
    checkDistanceInMainMap = false
}

-- Area marker profile
Marker_Area_Profile = fes_CreateMarkerProfile(Marker_Base_Profile)
Marker_Area_Profile.iconType = MARKER_TYPE.RECTANGLE_AREA
Marker_Area_Profile.displayType = MARKER_DISPLAY_TYPE.MINIMAP
Marker_Area_Profile.displayLayerMap = MARKER_LAYER.LOW
Marker_Area_Profile.textureNameMinimap = minimapTextureNames.AREA_RECTANGLE

-- Event marker base profile
Marker_Event_Base = fes_CreateMarkerProfile(Marker_Base_Profile)
Marker_Event_Base.priority = 1
Marker_Event_Base.markerCallerType = MARKER_CALLER.GAMEPLAY_EVENT
Marker_Event_Base.displayType = MARKER_DISPLAY_TYPE.MINIMAP + MARKER_DISPLAY_TYPE.ONSCREEN + MARKER_DISPLAY_TYPE.OFFSCREEN + MARKER_DISPLAY_TYPE.OCCLUDED2D

-- Event: Consume Now
Marker_Event_ConsumeNow = fes_CreateMarkerProfile(Marker_Event_Base)
Marker_Event_ConsumeNow.iconType = MARKER_TYPE.CONSUME
Marker_Event_ConsumeNow.textureNameMinimap = minimapTextureNames.OBJECTIVE_CONSUME
Marker_Event_ConsumeNow.textureNameIndex2D = TEXTURE_2D_CONSUME
Marker_Event_ConsumeNow.markerFlashTime3D = 0.25
Marker_Event_ConsumeNow.iconColour = {126, 204, 221}

-- Event: Stealth Watcher
Marker_Event_StealthWatcher = fes_CreateMarkerProfile(Marker_Event_Base)
Marker_Event_StealthWatcher.markerCallerType = MARKER_CALLER.ENVIRONMENT
Marker_Event_StealthWatcher.iconType = MARKER_TYPE.STEALTH_CONSUME_WATCHER
Marker_Event_StealthWatcher.textureNameMinimap = minimapTextureNames.STEALTH_CONSUME_WATCHER
Marker_Event_StealthWatcher.textureNameIndex2D = TEXTURE_2D_UAV
Marker_Event_StealthWatcher.markerFlashTime3D = 0.25
Marker_Event_StealthWatcher.animType = MARKER_ANIM_2D.PULSE_FAST
Marker_Event_StealthWatcher.markerFlashTime3D = 0.5
Marker_Event_StealthWatcher.markerFlashAmount = 1.25
Marker_Event_StealthWatcher.iconColour = {252, 239, 136}
Marker_Event_StealthWatcher.altPriority = 3
Marker_Event_StealthWatcher.enableAlternating = true

-- Event: No Consume
Marker_Event_NoConsume = fes_CreateMarkerProfile(Marker_Event_Base)
Marker_Event_NoConsume.iconType = MARKER_TYPE.PROTECT
Marker_Event_NoConsume.textureNameMinimap = minimapTextureNames.OBJECTIVE_PROTECT
Marker_Event_NoConsume.textureNameIndex2D = TEXTURE_2D_PROTECT
Marker_Event_NoConsume.markerFlashTime3D = 0.25
Marker_Event_NoConsume.iconColour = {186, 223, 177}

-- Event: Stealth Consume Game Button Y
Marker_Event_StealthConsumeGameButtonY = fes_CreateMarkerProfile(Marker_Event_Base)
Marker_Event_StealthConsumeGameButtonY.iconType = MARKER_TYPE.INGAMEBUTTON_Y
Marker_Event_StealthConsumeGameButtonY.displayType = MARKER_DISPLAY_TYPE.ONSCREEN
Marker_Event_StealthConsumeGameButtonY.description = "It will show a controller button Y!"
Marker_Event_StealthConsumeGameButtonY.iconColour = {255, 255, 255}
Marker_Event_StealthConsumeGameButtonY.markerNearScale3D = 1.25
Marker_Event_StealthConsumeGameButtonY.markerFarScale3D = 2.75
Marker_Event_StealthConsumeGameButtonY.priority = 0
Marker_Event_StealthConsumeGameButtonY.markerCallerType = MARKER_CALLER.PLAYER_ACTION

-- Event: WOI Target
Marker_Event_WOITarget = fes_CreateMarkerProfile(Marker_Event_Base)
Marker_Event_WOITarget.iconType = MARKER_TYPE.CONSUME_WOI
Marker_Event_WOITarget.textureNameMinimap = minimapTextureNames.OBJECTIVE_CONSUME_WOI
Marker_Event_WOITarget.textureNameIndex2D = TEXTURE_2D_WOI
Marker_Event_WOITarget.iconColour = {126, 204, 221}
Marker_Event_WOITarget.description = "$WOI_TARGET"

-- ... (Many other marker profiles are defined similarly: InGameButtonA, InGameButtonB, etc.)

-- ########################### OBJECTIVE MARKERS ###########################

Marker_Objective_Base = fes_CreateMarkerProfile(Marker_Base_Profile)
Marker_Objective_Base.markerCallerType = MARKER_CALLER.MISSION
Marker_Objective_Base.displayType = MARKER_DISPLAY_TYPE.MINIMAP + MARKER_DISPLAY_TYPE.MAINMAP + MARKER_DISPLAY_TYPE.ONSCREEN + MARKER_DISPLAY_TYPE.OFFSCREEN + MARKER_DISPLAY_TYPE.OCCLUDED2D
Marker_Objective_Base.priority = 2
Marker_Objective_Base.title = "$MISSION"

-- Objective: Chase
Marker_Objective_Chase = fes_CreateMarkerProfile(Marker_Objective_Base)
Marker_Objective_Chase.iconType = MARKER_TYPE.CHASE
Marker_Objective_Chase.textureNameMinimap = minimapTextureNames.OBJECTIVE_CHASE
Marker_Objective_Chase.textureNameIndex2D = TEXTURE_2D_CHASE
Marker_Objective_Chase.title = "$InfoBox_Objective_Chase"
Marker_Objective_Chase.iconColour = {186, 223, 177}

-- Objective: Consume Upgrade
Marker_Objective_Consume_Upgrade = fes_CreateMarkerProfile(Marker_Objective_Base)
Marker_Objective_Consume_Upgrade.iconType = MARKER_TYPE.CONSUME_UPGRADE
Marker_Objective_Consume_Upgrade.textureNameMinimap = minimapTextureNames.OBJECTIVE_CONSUME_UPGRADE
Marker_Objective_Consume_Upgrade.textureNameIndex2D = TEXTURE_2D_UPGRADE
Marker_Objective_Consume_Upgrade.title = "$CONSUME_FOR_UPGRADE"
Marker_Objective_Consume_Upgrade.iconColour = {126, 204, 221}

-- Objective: Consume WOI
Marker_Objective_Consume_WOI = fes_CreateMarkerProfile(Marker_Objective_Base)
Marker_Objective_Consume_WOI.iconType = MARKER_TYPE.CONSUME_WOI
Marker_Objective_Consume_WOI.textureNameMinimap = minimapTextureNames.OBJECTIVE_CONSUME_WOI
Marker_Objective_Consume_WOI.textureNameIndex2D = TEXTURE_2D_WOI
Marker_Objective_Consume_WOI.title = "$CONSUME_FOR_MEMORY"
Marker_Objective_Consume_WOI.iconColour = {126, 204, 221}

-- Objective: Consume Key
Marker_Objective_Consume_Key = fes_CreateMarkerProfile(Marker_Objective_Base)
Marker_Objective_Consume_Key.iconType = MARKER_TYPE.CONSUME_KEY
Marker_Objective_Consume_Key.textureNameMinimap = minimapTextureNames.OBJECTIVE_CONSUME_KEY
Marker_Objective_Consume_Key.textureNameIndex2D = TEXTURE_2D_KEY
Marker_Objective_Consume_Key.title = "$CONSUME_FOR_KEY"
Marker_Objective_Consume_Key.iconColour = {126, 204, 221}

-- Objective: Interact
Marker_Objective_Interact = fes_CreateMarkerProfile(Marker_Objective_Base)
Marker_Objective_Interact.iconType = MARKER_TYPE.INTERACT
Marker_Objective_Interact.textureNameMinimap = minimapTextureNames.OBJECTIVE_INTERACT
Marker_Objective_Interact.textureNameIndex2D = TEXTURE_2D_INTERACT
Marker_Objective_Interact.title = "$InfoBox_Objective_Interact"
Marker_Objective_Interact.minAlphaDistanceOnscreen = 1000000
Marker_Objective_Interact.iconMaxAlphaDistance = 1000000
Marker_Objective_Interact.iconColour = {186, 223, 177}

-- ########################### OPTIONAL MARKERS ###########################

Marker_Optional_Base = fes_CreateMarkerProfile(Marker_Base_Profile)
Marker_Optional_Base.markerCallerType = MARKER_CALLER.OPTIONAL_ACTION
Marker_Optional_Base.displayType = MARKER_DISPLAY_TYPE.MINIMAP + MARKER_DISPLAY_TYPE.MAINMAP + MARKER_DISPLAY_TYPE.ONSCREEN + MARKER_DISPLAY_TYPE.OFFSCREEN + MARKER_DISPLAY_TYPE.OCCLUDED2D
Marker_Optional_Base.priority = 2
Marker_Optional_Base.maxAlphaOnscreen = 1
Marker_Optional_Base.minAlphaOnscreen = 0
Marker_Optional_Base.minAlphaDistanceOnscreen = 25
Marker_Optional_Base.iconMaxAlphaDistance = 75
Marker_Optional_Base.displayLayerMap = MARKER_LAYER.MED
Marker_Optional_Base.title = "$OPTIONAL_CONSUME"
Marker_Optional_Base.iconColour = {252, 239, 136}
Marker_Optional_Base.enableAlternating = true
Marker_Optional_Base.checkDistanceInMainMap = true

-- Optional: Consume
Marker_Optional_Consume = fes_CreateMarkerProfile(Marker_Optional_Base)
Marker_Optional_Consume.iconType = MARKER_TYPE.OPENWORLD_CONSUME
Marker_Optional_Consume.textureNameMinimap = minimapTextureNames.BLACKNET_CONSUME
Marker_Optional_Consume.textureNameIndex2D = TEXTURE_2D_BLACKNET_CONSUME
Marker_Optional_Consume.altPriority = 4
Marker_Optional_Consume.priority = 1

-- Optional: Consume WOI
Marker_Optional_Consume_Woi = fes_CreateMarkerProfile(Marker_Optional_Base)
Marker_Optional_Consume_Woi.iconType = MARKER_TYPE.OPENWORLD_CONSUME_WOI
Marker_Optional_Consume_Woi.textureNameMinimap = minimapTextureNames.BLACKNET_CONSUME_WOI
Marker_Optional_Consume_Woi.textureNameIndex2D = TEXTURE_2D_BLACKNET_WOI
Marker_Optional_Consume_Woi.altPriority = 4
Marker_Optional_Consume_Woi.priority = 1
Marker_Optional_Consume_Woi.title = "$BLACKNET_CONSUME"

-- Optional: Interact
Marker_Optional_Interact = fes_CreateMarkerProfile(Marker_Optional_Base)
Marker_Optional_Interact.iconType = MARKER_TYPE.OPTIONAL_INTERACT
Marker_Optional_Interact.textureNameMinimap = minimapTextureNames.OPTIONAL_INTERACT
Marker_Optional_Interact.textureNameIndex2D = TEXTURE_2D_OPTIONAL_INTERACT
Marker_Optional_Interact.title = "$OPTIONAL_INTERACT"

-- Optional: Consume Upgrade
Marker_Optional_Consume_Upgrade = fes_CreateMarkerProfile(Marker_Optional_Base)
Marker_Optional_Consume_Upgrade.iconType = MARKER_TYPE.OPENWORLD_CONSUME_UPGRADE
Marker_Optional_Consume_Upgrade.textureNameMinimap = minimapTextureNames.BLACKNET_CONSUME_UPGRADE
Marker_Optional_Consume_Upgrade.textureNameIndex2D = TEXTURE_2D_BLACKNET_UPGRADE
Marker_Optional_Consume_Upgrade.altPriority = 4
Marker_Optional_Consume_Upgrade.priority = 1
Marker_Optional_Consume_Upgrade.title = "$OPTIONAL_CONSUME_FOR_UPGRADE"

-- ... (Other optional marker profiles: Consume_PreOrder, Consume_Key)

-- ########################### MISSION MARKERS ###########################

Marker_Mission_Base = fes_CreateMarkerProfile(Marker_Base_Profile)
Marker_Mission_Base.markerCallerType = MARKER_CALLER.MISSION
Marker_Mission_Base.displayType = MARKER_DISPLAY_TYPE.MINIMAP + MARKER_DISPLAY_TYPE.MAINMAP + MARKER_DISPLAY_TYPE.ONSCREEN + MARKER_DISPLAY_TYPE.OFFSCREEN + MARKER_DISPLAY_TYPE.OCCLUDED2D
Marker_Mission_Base.priority = 2
Marker_Mission_Base.maxAlphaOnscreen = 1
Marker_Mission_Base.minAlphaOnscreen = 0
Marker_Mission_Base.minimapIntro = true
Marker_Mission_Base.minimapIdleAnimation = true
Marker_Mission_Base.minimapIntroScalingDuration = 1
Marker_Mission_Base.minimapIntroScalingFactor = 2
Marker_Mission_Base.title = "$MISSION"

-- Mission: GoTo
Marker_Mission_GoTo = fes_CreateMarkerProfile(Marker_Mission_Base)
Marker_Mission_GoTo.iconType = MARKER_TYPE.GOTO
Marker_Mission_GoTo.textureNameMinimap = minimapTextureNames.OBJECTIVE_GOTO
Marker_Mission_GoTo.textureNameIndex2D = TEXTURE_2D_GOTO
Marker_Mission_GoTo.minAlphaDistanceOnscreen = 1000000
Marker_Mission_GoTo.iconMaxAlphaDistance = 1000000
Marker_Mission_GoTo.title = "$GOTO"
Marker_Mission_GoTo.iconColour = {186, 223, 177}

-- Mission: Defeat
Marker_Mission_Defeat = fes_CreateMarkerProfile(Marker_Mission_Base)
Marker_Mission_Defeat.iconType = MARKER_TYPE.DESTROY
Marker_Mission_Defeat.textureNameMinimap = minimapTextureNames.OBJECTIVE_DESTROY
Marker_Mission_Defeat.textureNameIndex2D = TEXTURE_2D_DESTROY
Marker_Mission_Defeat.minimapIdleAnimation = false
Marker_Mission_Defeat.title = "$DESTROY"
Marker_Mission_Defeat.enableGrouping = true
Marker_Mission_Defeat.iconColour = {255, 80, 19}
Marker_Mission_Defeat.miniMapDisableColorTint = true

-- ... (Many other mission marker profiles: Defeat_Vehicle, RectangleArea, CircleArea, Protect, Hijack, Consume, Container, Barrel)

-- ########################### STRIKE TEAM MARKERS ###########################

Marker_StrikeTeam_Base = fes_CreateMarkerProfile(Marker_Base_Profile)
Marker_StrikeTeam_Base.markerCallerType = MARKER_CALLER.STRIKE_TEAM
Marker_StrikeTeam_Base.displayType = MARKER_DISPLAY_TYPE.MINIMAP
Marker_StrikeTeam_Base.priority = 3

-- Strike Team: Call
Marker_StrikeTeam_Call = fes_CreateMarkerProfile(Marker_StrikeTeam_Base)
Marker_StrikeTeam_Call.textureNameIndex2D = TEXTURE_2D_RADIO
Marker_StrikeTeam_Call.iconType = MARKER_TYPE.ENEMY_STRIKETEAM
Marker_StrikeTeam_Call.displayType = MARKER_DISPLAY_TYPE.ONSCREEN + MARKER_DISPLAY_TYPE.OFFSCREEN + MARKER_DISPLAY_TYPE.OCCLUDED2D
Marker_StrikeTeam_Call.iconColour = {232, 52, 43}

-- ... (Other strike team markers: Area, Enemy)

-- ########################### PLAYER ACTION MARKERS ###########################

Marker_PlayerAction_Base = fes_CreateMarkerProfile(Marker_Base_Profile)
Marker_PlayerAction_Base.markerCallerType = MARKER_CALLER.PLAYER_ACTION
Marker_PlayerAction_Base.displayType = MARKER_DISPLAY_TYPE.OFFSCREEN + MARKER_DISPLAY_TYPE.ONSCREEN
Marker_PlayerAction_Base.priority = 4

-- ... (Player action markers: Patsy, Ally)

-- ########################### CHARACTER MARKERS ###########################

Marker_Character_Base = fes_CreateMarkerProfile(Marker_Base_Profile)
Marker_Character_Base.markerCallerType = MARKER_CALLER.CHARACTER
Marker_Character_Base.displayType = MARKER_DISPLAY_TYPE.MINIMAP
Marker_Character_Base.renderOrderMap = 2
Marker_Character_Base.priority = 5
Marker_Character_Base.enableColourTinting = true
Marker_Character_Base.title = "$MARKER_CHARACTER_TITLE"
Marker_Character_Base.description = "$MARKER_CHARACTER_DESC"

-- Character: Enemy
Marker_Character_Enemy = fes_CreateMarkerProfile(Marker_Character_Base)
Marker_Character_Enemy.iconType = MARKER_TYPE.DOT
Marker_Character_Enemy.displayLayerMap = MARKER_LAYER.MED
Marker_Character_Enemy.textureNameMinimap = minimapTextureNames.ENEMY_SMALL
Marker_Character_Enemy.renderOrderMap = 3
Marker_Character_Enemy.title = "$ENEMY"

-- ... (Other character markers: Enemy_Large, UAV, Helicopter, Detection_Ring)

-- ########################### FREE ROAM MARKERS ###########################

Marker_FreeRoam_Base = fes_CreateMarkerProfile(Marker_Base_Profile)
Marker_FreeRoam_Base.markerCallerType = MARKER_CALLER.FREE_ROAM
Marker_FreeRoam_Base.displayType = MARKER_DISPLAY_TYPE.MINIMAP + MARKER_DISPLAY_TYPE.MAINMAP
Marker_FreeRoam_Base.minimapIntro = true
Marker_FreeRoam_Base.priority = 1
Marker_FreeRoam_Base.offsetY = 2.5
Marker_FreeRoam_Base.minimapIntro = true
Marker_FreeRoam_Base.iconColour = {202, 225, 255}
Marker_FreeRoam_Base.minimapIdleAnimation = true
Marker_FreeRoam_Base.minimapIntroScalingDuration = 1
Marker_FreeRoam_Base.minimapIntroScalingFactor = 2
Marker_FreeRoam_Base.renderOrderMap = 25

-- Free Roam: Mission Start Location
Marker_FreeRoam_MissionStartLocation = fes_CreateMarkerProfile(Marker_FreeRoam_Base)
Marker_FreeRoam_MissionStartLocation.iconType = MARKER_TYPE.MISSION
Marker_FreeRoam_MissionStartLocation.description = "$MissionStart"
Marker_FreeRoam_MissionStartLocation.textureNameMinimap = minimapTextureNames.OBJECTIVE_MISSION
Marker_FreeRoam_MissionStartLocation.textureNameIndex2D = TEXTURE_2D_MISSION
Marker_FreeRoam_MissionStartLocation.displayType = MARKER_DISPLAY_TYPE.ONSCREEN + MARKER_DISPLAY_TYPE.OFFSCREEN + MARKER_DISPLAY_TYPE.MINIMAP + MARKER_DISPLAY_TYPE.OCCLUDED2D
Marker_FreeRoam_MissionStartLocation.maxAlphaOnscreen = 1
Marker_FreeRoam_MissionStartLocation.minAlphaOnscreen = 0
Marker_FreeRoam_MissionStartLocation.minAlphaDistanceOnscreen = 25
Marker_FreeRoam_MissionStartLocation.iconMaxAlphaDistance = 75
Marker_FreeRoam_MissionStartLocation.iconColour = {126, 204, 221}

-- ... (Many other free roam marker profiles: MissionStartKoenig, MissionStartDana, MissionStartRooks, etc.)

-- ########################### COLLECTIBLE MARKERS ###########################

Marker_Collectable_Base = fes_CreateMarkerProfile(Marker_Base_Profile)
Marker_Collectable_Base.markerCallerType = MARKER_CALLER.COLLECTABLE
Marker_Collectable_Base.displayType = MARKER_DISPLAY_TYPE.MINIMAP + MARKER_DISPLAY_TYPE.MAINMAP
Marker_Collectable_Base.priority = 8
Marker_Collectable_Base.title = "$COLLECTABLE"

-- Collectible: Lair Discovered
Marker_Collectable_LairDiscovered = fes_CreateMarkerProfile(Marker_Collectable_Base)
Marker_Collectable_LairDiscovered.displayType = MARKER_DISPLAY_TYPE.MINIMAP + MARKER_DISPLAY_TYPE.ONSCREEN + MARKER_DISPLAY_TYPE.OFFSCREEN + MARKER_DISPLAY_TYPE.OCCLUDED2D
Marker_Collectable_LairDiscovered.iconType = MARKER_TYPE.COLLECTABLE_LAIR
Marker_Collectable_LairDiscovered.textureNameMinimap = minimapTextureNames.COLLECTABLE_LAIR
Marker_Collectable_LairDiscovered.textureNameIndex2D = TEXTURE_2D_LAIR
Marker_Collectable_LairDiscovered.displayLayerMap = MARKER_LAYER.HIGH
Marker_Collectable_LairDiscovered.rotationMap = 0
Marker_Collectable_LairDiscovered.description = "$COLLECTABLE_LAIR"
Marker_Collectable_LairDiscovered.minimapIntro = true
Marker_Collectable_LairDiscovered.minimapIdleAnimation = false
Marker_Collectable_LairDiscovered.minimapIntroScalingDuration = 1
Marker_Collectable_LairDiscovered.minimapIntroScalingFactor = 2
Marker_Collectable_LairDiscovered.maxAlphaOnscreen = 1
Marker_Collectable_LairDiscovered.minAlphaOnscreen = 0
Marker_Collectable_LairDiscovered.minAlphaDistanceOnscreen = 48
Marker_Collectable_LairDiscovered.iconMaxAlphaDistance = 50
Marker_Collectable_LairDiscovered.iconColour = {255, 241, 187}

-- ... (Other collectible markers: DeathSquadArea, DeathSquadMember, BlackBoxDiscovered, BlackBoxRecovered)

-- ########################### PLAYER / AIRBRIDGE / WAYPOINT MARKERS ###########################

Marker_Player = fes_CreateMarkerProfile(Marker_Base_Profile)
Marker_Player.priority = 99
Marker_Player.iconType = MARKER_TYPE.PLAYER
Marker_Player.markerCallerType = MARKER_CALLER.PLAYER
Marker_Player.displayType = MARKER_DISPLAY_TYPE.MAINMAP
Marker_Player.title = "$PLAYER"
Marker_Player.iconColour = {255, 0, 0}

Marker_AirBridge = fes_CreateMarkerProfile(Marker_Base_Profile)
Marker_AirBridge.priority = 99
Marker_AirBridge.iconType = MARKER_TYPE.AIRBRIDGE
Marker_AirBridge.markerCallerType = MARKER_CALLER.PLAYER
Marker_AirBridge.displayLayerMap = MARKER_LAYER.MED
Marker_AirBridge.displayType = MARKER_DISPLAY_TYPE.ONSCREEN + MARKER_DISPLAY_TYPE.MINIMAP + MARKER_DISPLAY_TYPE.OFFSCREEN + MARKER_DISPLAY_TYPE.OCCLUDED2D
Marker_AirBridge.description = "It will show an airbridge marker!"
Marker_AirBridge.textureNameMinimap = minimapTextureNames.OBJECTIVE_AIRBRIDGE
Marker_AirBridge.textureNameIndex2D = TEXTURE_2D_AIRBRIDGE
Marker_AirBridge.rotationMap = -1
Marker_AirBridge.renderOrderMap = 15
Marker_AirBridge.title = "$AIRBRIDGE"
Marker_AirBridge.maxAlphaOnscreen = 1
Marker_AirBridge.minAlphaOnscreen = 0
Marker_AirBridge.minAlphaDistanceOnscreen = 20
Marker_AirBridge.iconMaxAlphaDistance = 75
Marker_AirBridge.offsetY = 2.5
Marker_AirBridge.iconColour = {209, 214, 191}

Marker_WayPoint = fes_CreateMarkerProfile(Marker_Base_Profile)
Marker_WayPoint.priority = 99
Marker_WayPoint.iconType = MARKER_TYPE.WAYPOINT
Marker_WayPoint.markerCallerType = MARKER_CALLER.PLAYER
Marker_WayPoint.displayType = MARKER_DISPLAY_TYPE.ONSCREEN + MARKER_DISPLAY_TYPE.MINIMAP + MARKER_DISPLAY_TYPE.OFFSCREEN + MARKER_DISPLAY_TYPE.OCCLUDED2D
Marker_WayPoint.description = "It will show an waypoint marker!"
Marker_WayPoint.textureNameMinimap = minimapTextureNames.OBJECTIVE_WAYPOINT
Marker_WayPoint.textureNameIndex2D = TEXTURE_2D_WAYPOINT
Marker_WayPoint.iconColour = {255, 255, 255}
Marker_WayPoint.iconOrientsDownwardsWhenOffscreen = false
Marker_WayPoint.title = "$WAYPOINT"
Marker_WayPoint.offsetY = 8.8
Marker_WayPoint.renderOrderMap = 26
Marker_WayPoint.iconColour = {75, 181, 114}

-- ########################### FRONT-END RENDER BLUR PROFILES ###########################

Interface.FeRenderBlurProfiles = {
    isFeRenderBlurEffectEnabled = false,
    Default = { Blurriness = 0.5, Saturation = 0, BlurSpeed = 1 },
    InGameMainMenu = { Blurriness = 0.5, Saturation = 0, BlurSpeed = 1 },
    PowerWheel = { Blurriness = 1, Saturation = 0, BlurSpeed = 0 },
    InGameScreen = { Blurriness = 0.5, Saturation = 0, BlurSpeed = 0 }
}

-- ########################### UNLOCKABLES / DLC ###########################

-- Define unlockable categories
Interface.Unlockables = {
    All = {},
    Powers = { { startingIndex = Unlockable.Powers_Begin, endingIndex = Unlockable.Powers_End } },
    Abilities = { { startingIndex = Unlockable.Abilities_Begin, endingIndex = Unlockable.Abilities_End } },
    Skills = { { startingIndex = Unlockable.Skills_Begin, endingIndex = Unlockable.Skills_End } },
    Upgrades = { { startingIndex = Unlockable.Upgrades_Begin, endingIndex = Unlockable.Upgrades_End } },
    Missions = { { startingIndex = Unlockable.Mission_Begin, endingIndex = Unlockable.Mission_End } },
    Mutations = { { startingIndex = Unlockable.Mutation_Begin, endingIndex = Unlockable.Mutation_End } },
    Obsolete = { { startingIndex = Unlockable.Obsolete_Begin, endingIndex = Unlockable.Obsolete_End } },
    Tutorial = { { startingIndex = Unlockable.Tutorial_Begin, endingIndex = Unlockable.Tutorial_End } },
    OpStickyRewards = { { startingIndex = Unlockable.Opsticky_Rewards_Begin, endingIndex = Unlockable.Opsticky_Rewards_End } },
    OpStickyCompStats = { { startingIndex = Unlockable.Opsticky_Competitive_Stats_Begin, endingIndex = Unlockable.Opsticky_Competitive_Stats_End } }
}
Interface.UnlockablesOnlyAvailable = { startingIndex = Unlockable.Opsticky_Theme5, endingIndex = Unlockable.Opsticky_Skin_Heller }

-- DLC Video definitions
DLC_Videos = {
    { Label = "$DLC_VIDEO_1", FMVName = "movies/radnet/RAD_DEV_01.bik", AssociatedUnlockable = Unlockable.Opsticky_Video1, Image = "videothumb_01.gfx" },
    { Label = "$DLC_VIDEO_2", FMVName = "movies/radnet/RAD_DEV_02.bik", AssociatedUnlockable = Unlockable.Opsticky_Video2, Image = "videothumb_02.gfx" },
    -- ... (up to 5 videos)
}

-- DLC Cheat definitions
DLC_Cheats = {
    { Label = "$DLC_CHEAT_ANTI_GRAV", AssociatedUnlockable = Unlockable.Opsticky_Cheat_Anti_Grav, Image = "icon_01.gfx" },
    -- ... (many cheats)
    {
        Label = "$DLC_CHEAT_WEAPONS",
        Image = "icon_10.gfx",
        Items = {
            { Label = "$DLC_CHEAT_VIRAL_WEAPON", AssociatedUnlockable = Unlockable.Opsticky_Cheat_Viral_Weapon, Image = "icon_08.gfx" },
            { Label = "$DLC_CHEAT_THERMOBARIC_WEAPON", AssociatedUnlockable = Unlockable.Opsticky_Cheat_Thermobaric, Image = "icon_09.gfx" }
        }
    }
}

-- DLC Skins
DLC_Skins = {
    Label = "$DLC_SKINS",
    Function = "dlc_SetNewSkin",
    GetValueFunction = "dlc_GetActiveSkin",
    Entries = {
        { Label = "$DLC_SKIN_HELLER", Value = PlayerSkins.RegularHeller, AssociatedUnlockable = Unlockable.Opsticky_Skin_Heller, Image = "skinpreview_02.gfx", IsDLCOnly = false },
        -- ... (many skins)
    }
}

-- DLC Themes
DLC_Themes = {
    { Label = "$DLC_THEME_HELLER", ThemeName = ThemeInstall.Heller, AssociatedUnlockable = Unlockable.Opsticky_Theme_Heller, Image = "theme_01.gfx" },
    -- ... (other themes)
}

-- DLC Incentives (Pre-order bonuses)
DLC_Incentives = {
    { Label = "$DLC_INCENTIVE_PUNT_HUMANS", AssociatedUnlockable = Unlockable.Opsticky_PreOrder_AssKicker, AssociatedUnlockableConsumable = Unlockable.Opsticky_PreOrder_AssKicker_Consumable, Image = "preorderincentive_01.gfx" },
    -- ... (other incentives)
}

-- Reward packs
DLC_Themes_RewardPack1 = { Unlockable.Opsticky_Theme_Heller, Unlockable.Opsticky_Theme_Alex_Mercer }
DLC_Themes_RewardPack2 = { Unlockable.Opsticky_Theme_Yellow_Zone_Vista, Unlockable.Opsticky_Theme_Green_Zone_Vista, Unlockable.Opsticky_Theme_Red_Zone_Vista }

DLC_Avatars_RewardPack1 = {
    { Value = AvatarAward.HellerJacket, AssociatedUnlockable = Unlockable.Opsticky_Avatar_Heller_Jacket },
    { Value = AvatarAward.P2LogoHoodie, AssociatedUnlockable = Unlockable.Opsticky_Avatar_P2_Logo_Hoodie }
}

DLC_Avatars_RewardPack2 = {
    { Value = AvatarAward.AlexMercer, AssociatedUnlockable = Unlockable.Opsticky_Avatar_Alex_Mercer },
    { Value = AvatarAward.BladeArm, AssociatedUnlockable = Unlockable.Opsticky_Avatar_Blade_Arm },
    { Value = AvatarAward.P2LogoShirt, AssociatedUnlockable = Unlockable.Opsticky_Avatar_P2_Logo_Shirt }
}

-- ########################### CONTENT CALENDAR ###########################

-- Pre-order incentive info (date)
Interface.PreOrderIncentiveInfo = { date = { 6, 7, 2012 } } -- June 7, 2012

-- Content Calendar packages
Interface.ContentCalendarInfo = {
    package = {
        -- Challenge Pack 1
        ChallengePack1 = {
            releaseOrder = 0,
            name = "$CC_CHALLENGE_PACK_1_NAME",
            type = ContentCalendarPackageType.Earned,
            rewardTitle = "$CC_FINISH_ALL_EVENTS",
            rewardDescription = "$CC_CHALLENGE_PACK_1_REWARD_DESC",
            eventSetId = Unlockable.Event_Set1,
            panelMovie = "contentcalendar_set_cd",
            detailsMovie = "calendarSet_01",
            packRewards = {
                { type = "$CC_CHALLENGE_PACK_MUTATION_REWARD_TYPE", name = "$CC_CHALLENGE_PACK_1_MUTATION_REWARD_NAME" },
                { type = "$CC_CHALLENGE_PACK_COMIC_REWARD_TYPE", name = "$CC_CHALLENGE_PACK_1_COMIC_REWARD_NAME" },
                { type = "$CC_CHALLENGE_PACK_SKIN_REWARD_TYPE", name = "$CC_CHALLENGE_PACK_1_SKIN_REWARD_NAME" }
            },
            day = {
                -- ... (many day entries with events and statistics)
            }
        },
        -- ... (ChallengePack2, DownloadPack1, RewardPack1, etc.)
    }
}

-- ########################### MESSAGE OF THE DAY ###########################

Interface.MessageOfTheDayIndex = 0

-- Multi-language message data
Interface.DLCMessageInfoDbg = {
    languages = {
        english = { ... }, -- 100 strings
        french = { ... },
        -- ... (other languages)
    },
    schedule = {
        -- ... (schedule of messages)
    },
    cycle = {
        -- ... (cycle of messages)
    }
}

-- ########################### MISSION FLOW / STATE MACHINE HELPERS ###########################

-- (Many mission flow related functions: mms_DebugStartMission, mms_DebugCompleteMission, etc.)
-- These are defined in the datainit.lua file but are too numerous to list individually here.

-- ########################### ENCOUNTER SYSTEM ###########################

-- (Encounter system functions: enc_AddNewEncounterAndSpawn, enc_SpawnNewWave, etc.)
-- These are defined in the datainit.lua file but are too numerous to list individually here.

-- ########################### CONSUMABLES SYSTEM ###########################

-- (Consumables system: Manager, Clients, Providers, etc.)
-- These are defined in the datainit.lua file but are too numerous to list individually here.

-- ########################### END OF FILE ###########################

print("datainit.lua loaded successfully.")