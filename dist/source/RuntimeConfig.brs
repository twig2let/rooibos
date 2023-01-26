function __rooibos_RuntimeConfig_builder()
    instance = {}
    instance.new = sub()
    end sub
    instance.getVersionText = function()
    end function
    instance.getRuntimeConfig = function()
    end function
    instance.getTestSuiteClassWithName = function(name)
    end function
    instance.getAllTestSuitesNames = function()
    end function
    instance.getIgnoredTestInfo = function()
    end function
    return instance
end function
function rooibos_RuntimeConfig()
    instance = __rooibos_RuntimeConfig_builder()
    instance.new()
    return instance
end function