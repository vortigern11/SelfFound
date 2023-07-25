local MAX_LEVEL = 60
local SelfFound = CreateFrame("Frame")

-- Disable trading
function SelfFound:TRADE_SHOW()
    if UnitLevel("player") == MAX_LEVEL then return end
    print("SelfFound mode is enabled, trade access is blocked.")
    CloseTrade()
end

-- Disable mail
function SelfFound:MAIL_SHOW()
    if UnitLevel("player") == MAX_LEVEL then return end
    print("SelfFound mode is enabled, mailbox access is blocked.")
    CloseMail()
end

-- Disable auction house
function SelfFound:AUCTION_HOUSE_SHOW()
    if UnitLevel("player") == MAX_LEVEL then return end
    print("SelfFound mode is enabled, auction house access is blocked.")
    CloseAuctionHouse()
end

-- Start the addon
SelfFound:RegisterEvent("TRADE_SHOW")
SelfFound:RegisterEvent("MAIL_SHOW")
SelfFound:RegisterEvent("AUCTION_HOUSE_SHOW")

SelfFound:SetScript("OnEvent", function()
    if event == "TRADE_SHOW" then
        SelfFound:TRADE_SHOW()
    elseif event == "MAIL_SHOW" then
        SelfFound:MAIL_SHOW()
    elseif event == "AUCTION_HOUSE_SHOW" then
        SelfFound:AUCTION_HOUSE_SHOW()
    end
end)
