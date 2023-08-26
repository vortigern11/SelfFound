local SelfFound = CreateFrame("Frame")
local SelfFound_AuctionHouseOnTabClick_Orig

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

-- Limit auction house
function SelfFound_AuctionHouseOnTabClick(index)
    if (not index) then index = this:GetID(); end

    local isNotSellTab = index == 1
    local isHighEnoughLvl = UnitLevel("player") >= SelfFound.ahLvl

    if (isHighEnoughLvl or isNotSellTab) then
        SelfFound_AuctionHouseOnTabClick_Orig(index)
    else
        SelfFound:Print("Auction House selling is available from lvl " .. SelfFound.ahLvl)
        CloseAuctionHouse()
    end
end

-- Limit trading
TradeFrameTradeButton:SetScript("OnClick", function()
    local isHighEnoughLvl = UnitLevel("player") >= SelfFound.tradeLvl
    local isInInstance, _ = IsInInstance()
    local noMoneyToBeReceived = tonumber(GetTargetTradeMoney()) == 0

    if (isHighEnoughLvl or (isInInstance and noMoneyToBeReceived)) then
        AcceptTrade()
    else
        SelfFound:Print("Trading is available from lvl " .. SelfFound.tradeLvl .. " or in instances")
        CloseTrade()
    end
end)

function SelfFound:ADDON_LOADED()
    -- Substitute functionality from the original Auction House addon
    if (string.lower(arg1) == "blizzard_auctionui") then
        SelfFound_AuctionHouseOnTabClick_Orig = AuctionFrameTab_OnClick
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

    SelfFound.ahLvl = maxLvl
    SelfFound.tradeLvl = maxLvl
end

-- Notify player on new functionality
function SelfFound:PLAYER_LEVEL_UP(newLvl)
    if not SelfFound then return end

    if (newLvl == SelfFound.ahLvl) then
        SelfFound:Print("Congrats! You can now use Auction House!")
    end
    if (newLvl == SelfFound.tradeLvl) then
        SelfFound:Print("Congrats! You can now use Trading!")
    end
end

-- Start the addon
SelfFound:RegisterEvent("ADDON_LOADED")
SelfFound:RegisterEvent("PLAYER_ENTERING_WORLD")
SelfFound:RegisterEvent("PLAYER_LEVEL_UP")

SelfFound:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" then
        SelfFound:ADDON_LOADED()
    elseif event == "PLAYER_ENTERING_WORLD" then
        SelfFound:PLAYER_ENTERING_WORLD()
    elseif event == "PLAYER_LEVEL_UP" then
        SelfFound:PLAYER_LEVEL_UP()
    end
end)
