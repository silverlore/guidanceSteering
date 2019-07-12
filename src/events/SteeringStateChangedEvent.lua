--
-- SteeringStateChangedEvent
--
-- AB point push event to handle point creation on other clients.
--
-- Copyright (c) Wopster, 2019

SteeringStateChangedEvent = {}
local SteeringStateChangedEvent_mt = Class(SteeringStateChangedEvent, Event)

InitEventClass(SteeringStateChangedEvent, "SteeringStateChangedEvent")

function SteeringStateChangedEvent:emptyNew()
    local self = Event:new(SteeringStateChangedEvent_mt)

    return self
end

function SteeringStateChangedEvent:new(vehicle, isSteeringIsActive)
    local self = SteeringStateChangedEvent:emptyNew()

    self.vehicle = vehicle
	self.isSteeringIsActive = isSteeringIsActive

    return self
end

function SteeringStateChangedEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.vehicle)
	streamWriteBool(streamId, self.isSteeringIsActive)
end

function SteeringStateChangedEvent:readStream(streamId, connection)
    self.vehicle = NetworkUtil.readNodeObject(streamId)
	self.isSteeringIsActive = streamReadBool(streamId)
    self:run(connection)
end

function SteeringStateChangedEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(self, false, connection, self.vehicle)
    end

    self.vehicle:onSteeringStateChanged(self.isSteeringIsActive, true)
end

function SteeringStateChangedEvent.sendEvent(vehicle, isSteeringIsActive, noEventSend)
    if noEventSend == nil or not noEventSend then
        if g_server ~= nil then
            g_server:broadcastEvent(SteeringStateChangedEvent:new(vehicle, isSteeringIsActive), nil, nil, vehicle)
        else
            g_client:getServerConnection():sendEvent(SteeringStateChangedEvent:new(vehicle, isSteeringIsActive))
        end
    end
end
