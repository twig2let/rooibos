function __rooibos_BaseTestReporter_builder()
    instance = {}
    instance.new = function(testRunner as dynamic)
        m.testRunner = invalid
        m.config = invalid
        m.allStats = invalid
        m.testRunner = testRunner
        m.config = testRunner.config
        m.allStats = testRunner.stats
    end function
    instance.reportResults = function(allStats as dynamic)
        'override me
    end function
    instance.testLogInfo = function(text as string)
        'override me
    end function
    instance.testLogError = function(text as string)
        'override me
    end function
    return instance
end function
function rooibos_BaseTestReporter(testRunner as dynamic)
    instance = __rooibos_BaseTestReporter_builder()
    instance.new(testRunner)
    return instance
end function