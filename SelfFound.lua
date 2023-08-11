local SelfFound = CreateFrame("Frame")
local SelfFound_OrigAuctionHouseOnTabClick

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
        SelfFound:Print("You can't change away from bank mode")
        return
    end

    if cmd == "info" then
        SelfFound:SuccessPrint()
    elseif cmd == "normal" then
        SF_CONFIG = SelfFound.normalMode
        SelfFound:SuccessPrint()
    elseif cmd == "hardcore" then
        SF_CONFIG = SelfFound.hardcoreMode
        SelfFound:SuccessPrint()
    elseif cmd == "collector" then
        SF_CONFIG = SelfFound.collectorMode
        SelfFound:SuccessPrint()
    elseif cmd == "bank" then
        SF_CONFIG = SelfFound.bankMode
        SelfFound:SuccessPrint()
    end
end

-- Limit auction house
function SelfFound_AuctionHouseOnTabClick(index)
    if (not index) then index = this:GetID(); end

    local isNotSellTab = index == 1 or index == 2
    local isHighEnoughLvl = UnitLevel("player") >= SF_CONFIG.ahLvl

    if (isHighEnoughLvl or isNotSellTab) then
        SelfFound_OrigAuctionHouseOnTabClick(index)
    else
        SelfFound:Print("Addon is in " .. SF_CONFIG.mode .. " mode")
        SelfFound:Print("Auction House selling is available from lvl " .. SF_CONFIG.ahLvl)
        CloseAuctionHouse()
    end
end

-- Limit mail
function SelfFound:MAIL_SHOW()
    local isHighEnoughLvl = UnitLevel("player") >= SF_CONFIG.mailLvl

    if isHighEnoughLvl then return end

    SelfFound:Print("Addon is in " .. SF_CONFIG.mode .. " mode")
    SelfFound:Print("Mail is available from lvl " .. SF_CONFIG.mailLvl)
    CloseMail()
end

-- Limit trading
TradeFrameTradeButton:SetScript("OnClick", function()
    local isHighEnoughLvl = UnitLevel("player") >= SF_CONFIG.tradeLvl
    local isInInstance, _ = IsInInstance()
    local noMoneyToBeReceived = tonumber(GetTargetTradeMoney()) == 0

    if (isHighEnoughLvl or (isInInstance and noMoneyToBeReceived)) then
        AcceptTrade()
    else
        SelfFound:Print("Addon is in " .. SF_CONFIG.mode .. " mode")
        SelfFound:Print("Trading is available from lvl " .. SF_CONFIG.tradeLvl .. " or in instances")
        CloseTrade()
    end
end)

function SelfFound:ADDON_LOADED()
    -- Substitute functionality from the original Auction House addon
    if (string.lower(arg1) == "blizzard_auctionui") then
        SelfFound_OrigAuctionHouseOnTabClick = AuctionFrameTab_OnClick
        AuctionFrameTab_OnClick = SelfFound_AuctionHouseOnTabClick
    end
end

function SelfFound:PLAYER_ENTERING_WORLD()
    -- Set max lvl
    local expansion = SelfFound:Expansion()
    local maxLvl = 60

    if (expansion == "tbc") then
        maxLvl = 70
    elseif (expansion == "wotlk") then
        maxLvl = 80
    end

    -- Addon modes
    SelfFound.normalMode = { mode = "normal", mailLvl = maxLvl / 2, ahLvl = maxLvl, tradeLvl = maxLvl }
    SelfFound.hardcoreMode = { mode = "hardcore", mailLvl = maxLvl, ahLvl = 9000, tradeLvl = 9000 }
    SelfFound.collectorMode = { mode = "collector", mailLvl = 9000, ahLvl = 9000, tradeLvl = 9000 }
    SelfFound.bankMode = { mode = "bank", mailLvl = 1, ahLvl = 9000, tradeLvl = 9000 }
    SelfFound.modeCmds = { "normal", "hardcore", "collector", "bank" }

    -- Set default addon mode
    local isLvl1 = UnitLevel("player") == 1

    if isLvl1 then
        if not SF_CONFIG then SF_CONFIG = SelfFound.normalMode end

        SelfFound:Print("-----------------------------------------------------------")
        SelfFound:Print("!!! Addon mode can only be changed at level 1 !!!")
        SelfFound:Print("Read the README file in the addon's folder for important info")
        SelfFound:Print("To see which mode you are currently using, type '/selffound info'")
        SelfFound:Print("-----------------------------------------------------------")
    else
        if not SF_CONFIG then SF_CONFIG = SelfFound.collectorMode end
    end
end

-- Notify player on new functionality
function SelfFound:PLAYER_LEVEL_UP(newLvl)
    if not SF_CONFIG then return end

    local isBankMode = SF_CONFIG.mode == "bank"

    if (isBankMode and newLvl == 2) then
        SF_CONFIG = SelfFound.collectorMode
        SelfFound:Print("Your bank character has leveled up.")
        SelfFound:Print("Addon is changed to collector mode")
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

-- function SelfFound:AUCTION_HOUSE_SHOW()
--     local isHighEnoughLvl = UnitLevel("player") >= SF_CONFIG.ahLvl

--     if isHighEnoughLvl then return end

--     SelfFound:Print("Addon is in " .. SF_CONFIG.mode .. " mode")
--     SelfFound:Print("Auction House is available from lvl " .. SF_CONFIG.ahLvl)
--     CloseAuctionHouse()
-- end

-- There is an issue with receiving party invite for some reason...
-- function SelfFound:TRADE_SHOW()
--     if UnitLevel("player") == MAX_LVL then return end
--     SelfFound:Print("trade access is blocked.")
--     CloseTrade()
-- end

-- Start the addon
SelfFound:RegisterEvent("ADDON_LOADED")
SelfFound:RegisterEvent("PLAYER_ENTERING_WORLD")
SelfFound:RegisterEvent("PLAYER_LEVEL_UP")
SelfFound:RegisterEvent("MAIL_SHOW")
-- SelfFound:RegisterEvent("AUCTION_HOUSE_SHOW")
-- SelfFound:RegisterEvent("TRADE_SHOW")

SelfFound:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" then
        SelfFound:ADDON_LOADED()
    elseif event == "PLAYER_ENTERING_WORLD" then
        SelfFound:PLAYER_ENTERING_WORLD()
    elseif event == "PLAYER_LEVEL_UP" then
        SelfFound:PLAYER_LEVEL_UP()
    elseif event == "MAIL_SHOW" then
        SelfFound:MAIL_SHOW()
    -- elseif event == "AUCTION_HOUSE_SHOW" then
    --     SelfFound:AUCTION_HOUSE_SHOW()
    -- elseif event == "TRADE_SHOW" then
    --     SelfFound:TRADE_SHOW()
    end
end)
