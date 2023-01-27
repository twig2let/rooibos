function __rooibos_ConsoleTestReporter_builder()
    instance = __rooibos_BaseTestReporter_builder()
    instance.super0_new = instance.new
    instance.new = function(testRunner)
        m.super0_new()
        m.lineWidth = 60
        'bs:disable-next-line
        m.super0_new(testRunner)
        if m.config.lineWidth <> invalid
            m.lineWidth = m.config.lineWidth
        else
            m.lineWidth = 60
        end if
    end function
    instance.super0_reportResults = instance.reportResults
    instance.reportResults = function(allStats)
        m.allStats = allStats
        m.startReport()
        for each testSuite in m.testRunner.testSuites
            if not m.allStats.hasFailures or ((not m.config.showOnlyFailures) or testSuite.stats.failedCount > 0 or testSuite.stats.crashedCount > 0)
                m.printSuiteStart(testSuite)
                for each testGroup in testSuite.groups
                    m.printGroup(testGroup)
                end for
            end if
        end for
        m.printLine()
        'bs:disable-next-line
        ignoredInfo = m.testRunner.runtimeConfig.getIgnoredTestInfo()
        m.printLine(0, "Total: " + Rooibos_Common_AsString(m.allStats.ranCount))
        m.printLine(0, "  Passed: " + Rooibos_Common_AsString(m.allStats.passedCount))
        m.printLine(0, "  Crashed: " + Rooibos_Common_AsString(m.allStats.crashedCount))
        m.printLine(0, "  Failed: " + Rooibos_Common_AsString(m.allStats.failedCount))
        'bs:disable-next-line
        m.printLine(0, "  Ignored: " + Rooibos_Common_AsString(ignoredInfo.count))
        m.printLine(0, "  Time: " + Rooibos_Common_AsString(m.allStats.time) + "ms")
        m.printLine()
        m.printLine()
        if ignoredInfo.count > 0
            m.printLine(0, "IGNORED TESTS:")
            for each ignoredItemName in ignoredInfo.items
                m.printLine(1, ignoredItemName)
            end for
            m.printLine()
            m.printLine()
        end if
        overrallResult = ""
        if m.allStats.hasFailures
            overrallResult = "Fail"
        else
            overrallResult = "Success"
        end if
        m.printLine(0, "RESULT: " + overrallResult)
        m.endReport()
    end function
    instance.printGroup = function(testGroup)
        isGroupPrinted = false
        for each test in testGroup.tests
            if not m.allStats.hasFailures or ((not m.config.showOnlyFailures) or test.result.isFail)
                if not isGroupPrinted
                    m.printGroupStart(testGroup)
                    isGroupPrinted = true
                end if
                m.printTest(test)
            end if
        end for
        if isGroupPrinted
            m.printLine(0, " |")
        end if
    end function
    instance.printTest = function(test)
        testLocationLine = StrI(test.lineNumber).trim()
        locationLine = invalid
        testChar = ""
        if test.result.isCrash
            testChar = "|"
            locationLine = StrI(test.lineNumber).trim()
        else if test.result.isFail
            testChar = "-"
            locationLine = StrI(test.result.lineNumber + 1).trim()
        else
            testChar = "|"
            locationLine = StrI(test.lineNumber).trim()
        end if
        testLocationText = "file://" + test.testSuite.filePath.trim() + ":" + testLocationLine
        timeText = ""
        if m.config.printTestTimes = true
            timeText = " (" + stri(test.result.time).trim() + "ms)"
        end if
        insetText = ""
        if test.isParamTest <> true
            messageLine = Rooibos_Common_fillText(" " + testChar + " |--" + test.name + " : ", ".", m.lineWidth)
            m.printLine(0, messageLine + test.result.getStatusText() + timeText)
            m.printLine(0, " | " + insetText + "  |--Test : " + testLocationText)
        else if test.paramTestIndex = 0
            name = test.name
            if len(name) > 1 and right(name, 1) = "0"
                name = left(name, len(name) - 1)
            end if
            m.printLine(0, " " + testChar + " |--" + name + " : ")
            m.printLine(0, " | " + insetText + "  |--Test : " + testLocationText)
        end if
        locationText = "file://" + test.testSuite.filePath.trim() + ":" + locationLine
        if test.isParamTest = true
            insetText = "  "
            rawParams = invalid
            if type(test.rawParams) = "roAssociativeArray"
                rawParams = {}
                for each key in test.rawParams
                    if type(test.rawParams[key]) <> "Function" and type(test.rawParams[key]) <> "roFunction"
                        rawParams[key] = test.rawParams[key]
                    end if
                end for
            else
                rawParams = test.rawParams
            end if
            messageLine = Rooibos_Common_fillText(" " + testChar + insetText + " |--" + formatJson(rawParams) + " : ", ".", m.lineWidth)
            m.printLine(0, messageLine + test.result.getStatusText() + timeText)
        end if
        if test.result.isCrash
            m.printLine(0, " | " + insetText + "  |--Crashed at: " + locationText)
            m.printStackTrace(insetText, test.result.error)
            m.printLine(0, " | ")
        else if test.result.isFail
            m.printLine(0, " | " + insetText + "  |--Failed at: " + locationText)
            if test.isParamTest = true
                m.printLine(0, " | " + insetText + "  |--Param Line: " + StrI(test.paramLineNumber - 1).trim())
            end if
            m.printLine(0, " | " + insetText + "  |--Error Message: " + test.result.message)
            m.printLine(0, " | ")
        end if
    end function
    instance.printStackTrace = function(insetText, error)
        m.printLine(0, " | " + insetText + "  |")
        m.printLine(0, " | " + insetText + "  |--Message: " + error.message)
        m.printLine(0, " | " + insetText + "  |--Stack trace: ")
        for i = error.backTrace.count() - 1 to 0 step - 1
            e = error.backTrace[i]
            if e.filename.instr("pkg:/source/rooibos") = - 1
                m.printLine(0, " | " + insetText + "    " + e.filename + "(" + stri(e.line_number).trim() + ")")
            end if
        end for
    end function
    instance.startReport = function()
        m.printLine()
        m.printLine(0, "[START TEST REPORT]")
        m.printLine()
    end function
    instance.endReport = function()
        m.printLine()
        m.printLine(0, "[END TEST REPORT]")
        m.printLine()
    end function
    instance.printSuiteStart = function(testSuite)
        m.printLine(0, " " + testSuite.name + " file://" + testSuite.filePath.trim() + ":" + str(testSuite.lineNumber).trim())
    end function
    instance.printGroupStart = function(testGroup)
        m.printLine(0, " |-" + testGroup.name)
    end function
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    '++ printing
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    instance.super0_testLogInfo = instance.testLogInfo
    instance.testLogInfo = function(text)
        ? "INFO "; text
    end function
    instance.super0_testLogError = instance.testLogError
    instance.testLogError = function(text)
        ? "ERROR "; text
    end function
    instance.printLine = function(depth = 0, text = "")
        ? " "; text
    end function
    return instance
end function
function rooibos_ConsoleTestReporter(testRunner)
    instance = __rooibos_ConsoleTestReporter_builder()
    instance.new(testRunner)
    return instance
end function