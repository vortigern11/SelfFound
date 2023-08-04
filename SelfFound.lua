local SelfFound = CreateFrame("Frame")

-- Check which game expansion
function SelfFound:Expansion()
    local _, _, _, client = GetBuildInfo()
    client = client or 11200

    -- detect client expansion
    if client >= 20000 and client <= 20400 then
        return "tbc"
    elseif client >= 30000 and client <= 30300 then
        return "wotlk"
    else
        return "vanilla"
    end
end

-- Print function
function SelfFound:Print(msg)
    print("|cff3ffca4SelfFound: " .. msg)
end

-- Check if list contains an item
function SelfFound:Contains(arr, el)
    for _, val in ipairs(arr) do
        if val == el then return true end
    end

    return false
end

-- Info and mode change messages
function SelfFound:SuccessPrint()
    SelfFound:Print("Addon is in " .. SF_CONFIG.mode .. " mode")
    SelfFound:Print("Mail is available from lvl " .. SF_CONFIG.mailLvl)
    SelfFound:Print("Auction House is available from lvl " .. SF_CONFIG.ahLvl)
    SelfFound:Print("Trading is available from lvl " .. SF_CONFIG.tradeLvl)
end

-- Chat commands
SLASH_SELFFOUND1 = "/selffound";
SlashCmdList["SELFFOUND"] = function(msg)
    local args = {};
    local word;
    for word in string.gfind(msg, "[^%s]+") do
        table.insert(args, word)
    end
    local cmd = args[1]

    local isNotLvl1 = UnitLevel("player") ~= 1
    local isChangeModeCmd = SelfFound:Contains(SelfFound.modeCmds, cmd)

    if (isNotLvl1 and not SF_CONFIG) then
        SelfFound:Print("SelfFound is disabled for this character.")
        SelfFound:Print("It can only be activated from lvl 1.")
        return
    end

    if (isNotLvl1 and isChangeModeCmd) then
        SelfFound:Print("Addon mode can't be changed past level 1")
        return
    end

    local isBankMode = SF_CONFIG.mode == "bank"

    if (isBankMode and isChangeModeCmd) then
        SelfFound:Print("Bank character's addon mode can't be changed")
        return
    end

    if cmd == "info" then
        SelfFound:SuccessPrint()
    elseif cmd == "sane" then
        SF_CONFIG = SelfFound.saneMode
        SelfFound:SuccessPrint()
    elseif cmd == "max" then
        SF_CONFIG = SelfFound.maxMode
        SelfFound:SuccessPrint()
    elseif cmd == "hardcore" then
        SF_CONFIG = SelfFound.hardcoreMode
        SelfFound:SuccessPrint()
    elseif cmd == "bank" then
        SF_CONFIG = SelfFound.bankMode
        SelfFound:SuccessPrint()
    end
end

function SelfFound:PLAYER_ENTERING_WORLD()
    local expansion = SelfFound:Expansion()
    local maxLvl = 60

    if (expansion == "tbc") then
        maxLvl = 70
    elseif (expansion == "wotlk") then
        maxLvl = 80
    end

    local saneLvl = math.floor(maxLvl * 3 / 4)

    SelfFound.saneMode = { mode = "sane", mailLvl = saneLvl, ahLvl = saneLvl, tradeLvl = saneLvl }
    SelfFound.maxMode = { mode = "max", mailLvl = maxLvl, ahLvl = maxLvl, tradeLvl = maxLvl }
    SelfFound.hardcoreMode = { mode = "hardcore", mailLvl = 9000, ahLvl = 9000, tradeLvl = 9000 }
    SelfFound.bankMode = { mode = "bank", mailLvl = 1, ahLvl = 9000, tradeLvl = 9000 }
    SelfFound.modeCmds = { "sane", "max", "hardcore", "bank" }

    local isLvl1 = UnitLevel("player") == 1

    if isLvl1 then
        if not SF_CONFIG then SF_CONFIG = SelfFound.saneMode end

        SelfFound:Print("-----------------------------------------------------------")
        SelfFound:Print("!!! Addon mode can only be changed at level 1 !!!")
        SelfFound:Print("Read the README file in the addon's folder for important info")
        SelfFound:Print("To see which mode you are currently using, type '/selffound info'")
        SelfFound:Print("-----------------------------------------------------------")
    end
end

-- Notify player on new functionality
function SelfFound:PLAYER_LEVEL_UP(newLvl)
    if not SF_CONFIG then return end

    local isBankMode = SF_CONFIG.mode == "bank"

    if (isBankMode and newLvl == 2) then
        SF_CONFIG = nil
        SelfFound:Print("Your bank character has leveled up.")
        SelfFound:Print("The SelfFound addon is now disabled.")
        return
    end

    if (newLvl == SF_CONFIG.mailLvl) then
        SelfFound:Print("Congrats! You can now use Mail!")
    end
    if (newLvl == SF_CONFIG.ahLvl) then
        SelfFound:Print("Congrats! You can now use Auction House!")
    end
    if (newLvl == SF_CONFIG.tradeLvl) then
        SelfFound:Print("Congrats! You can now use Trading!")
    end
end

-- Limit mail
function SelfFound:MAIL_SHOW()
    local isBankChar = SF_CONFIG.mode == "bank" and UnitLevel("player") == 1
    local isHighEnoughLvl = UnitLevel("player") >= SF_CONFIG.mailLvl

    if (isBankChar or isHighEnoughLvl) then return end

    if isBankChar then
        SelfFound:Print("Mail can only be used if player lvl is " .. SF_CONFIG.mailLvl)
    else
        SelfFound:Print("Mail can only be used if player lvl >= " .. SF_CONFIG.mailLvl)
    end

    CloseMail()
end

-- Limit auction house
function SelfFound:AUCTION_HOUSE_SHOW()
    local isHighEnoughLvl = UnitLevel("player") >= SF_CONFIG.ahLvl

    if isHighEnoughLvl then return end

    SelfFound:Print("Auction House can only be used if player lvl >= " .. SF_CONFIG.ahLvl)
    CloseAuctionHouse()
end

-- Limit trading
TradeFrameTradeButton:SetScript("OnClick", function()
    local isHighEnoughLvl = UnitLevel("player") >= SF_CONFIG.tradeLvl
    local isInInstance, _ = IsInInstance()

    if (isInInstance or isHighEnoughLvl) then
        AcceptTrade()
    else
        SelfFound:Print("Trading can only be used in instances or if player lvl >= " .. SF_CONFIG.tradeLvl)
        CloseTrade()
    end
end)

-- There is an issue with receiving party invite for some reason...
-- function SelfFound:TRADE_SHOW()
--     if UnitLevel("player") == MAX_LVL then return end
--     SelfFound:Print("trade access is blocked.")
--     CloseTrade()
-- end

-- Start the addon
SelfFound:RegisterEvent("PLAYER_ENTERING_WORLD")
SelfFound:RegisterEvent("PLAYER_LEVEL_UP")
SelfFound:RegisterEvent("MAIL_SHOW")
SelfFound:RegisterEvent("AUCTION_HOUSE_SHOW")
-- SelfFound:RegisterEvent("TRADE_SHOW")

SelfFound:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
        SelfFound:PLAYER_ENTERING_WORLD()
    elseif event == "PLAYER_LEVEL_UP" then
        SelfFound:PLAYER_LEVEL_UP()
    elseif event == "MAIL_SHOW" then
        SelfFound:MAIL_SHOW()
    elseif event == "AUCTION_HOUSE_SHOW" then
        SelfFound:AUCTION_HOUSE_SHOW()
    -- elseif event == "TRADE_SHOW" then
    --     SelfFound:TRADE_SHOW()
    end
end)
