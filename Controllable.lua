--- @mixin Controllable
--- For things that want to listen for specific control events.

local Controllable = {
    static = {}
}

function Controllable:included( klass )
    klass.static.controls = {}
end

--- Must be called by the including class in its constructor.
function Controllable:initializeControllable()
end

--- Must be called by the including class in its destructor.
function Controllable:destroyControllable()
end

--- Map the given control to a method.
--
-- Implicitly registers the control.
--
-- @param controlName
-- @param[type=function] method
-- @see control.pushControllable
--
function Controllable.static:mapControl( controlName, method )
    local controls = self.static.controls
    assert(not controls[controlName], controlName..' has already been mapped!')
    controls[controlName] = method
end

--- Is called by @{control}.
-- @internal
-- @param controlName
-- @param ...
-- Parameters which passed to the controls method.
function Controllable:triggerControlEvent( controlName, ... )
    local controls = self.class.controls
    local method = controls[controlName]
    if method then
        method(self, ...)
        return true
    else
        return false
    end
end


return Controllable
