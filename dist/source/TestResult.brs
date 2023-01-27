function __rooibos_TestResult_builder()
    instance = {}
    instance.new = function(test)
        m.isFail = false
        m.isCrash = false
        m.message = ""
        m.lineNumber = - 1
        m.test = invalid
        m.time = 0
        m.error = invalid
        m.test = test
    end function
    instance.reset = function() as void
        m.isFail = false
        m.isCrash = false
        m.time = 0
        m.message = ""
        m.lineNumber = - 1
    end function
    instance.fail = function(message as string, lineNumber = - 1)
        if message <> "" and not m.isFail
            if not m.isFail
                m.lineNumber = lineNumber
                m.isFail = true
                m.message = message
            end if
        end if
    end function
    instance.crash = function(message as string, error)
        if message <> "" and not m.isCrash
            if not m.isCrash
                m.error = error
                m.message = "test crashed!"
                m.isFail = true
                m.isCrash = true
            end if
        end if
    end function
    instance.getMessage = function() as string
        if m.isFail
            if m.message <> invalid
                return m.message
            else
                return "unknown test failure"
            end if
        else if m.isCrash
            if m.message <> invalid
                return m.message
            else
                return "unknown test crash"
            end if
        else
            return ""
        end if
    end function
    instance.getStatusText = function()
        if m.isCrash
            return "CRASH"
        else if m.isFail
            return "FAIL"
        else
            return "PASS"
        end if
    end function
    return instance
end function
function rooibos_TestResult(test)
    instance = __rooibos_TestResult_builder()
    instance.new(test)
    return instance
end function