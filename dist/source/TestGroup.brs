' /**
'  * @module TestSuite
'  * @description All brs files that include `'@TestSuite` annotations automatically extend the TestSuite.
'  * The base test suite contains all of the assertions, and utility methods required to write our tests, as well as being responsible for tracking the state of the tests and groups.
'  */
function __rooibos_TestGroup_builder()
    instance = {}
    'test state
    instance.new = function(testSuite, data)
        m.name = "Unnamed Suite"
        m.testSuite = invalid
        m.setupFunctionName = invalid
        m.tearDownFunctionName = invalid
        m.beforeEachFunctionName = invalid
        m.afterEachFunctionName = invalid
        m.isSolo = false
        m.isLegacy = false
        m.isIgnored = false
        m.stats = invalid
        m.scene = invalid
        m.lineNumber = 00
        m.top = invalid
        m.valid = false
        m.hasFailures = false
        m.isNodeTest = false
        m.nodeName = invalid
        m.testsData = invalid
        m.tests = []
        m.testSuite = testSuite
        m.name = data.name
        m.valid = data.valid
        m.hasFailures = testSuite.hasFailures
        m.isSolo = data.isSolo
        m.isIgnored = data.isIgnored
        m.testsData = data.testCases
        m.isNodeTest = false
        m.nodeName = invalid
        m.setupFunctionName = data.setupFunctionName
        m.tearDownFunctionName = data.tearDownFunctionName
        m.beforeEachFunctionName = data.beforeEachFunctionName
        m.afterEachFunctionName = data.afterEachFunctionName
        m.lineNumber = data.lineNumber
        'bs:disable-next-line
        m.global = testSuite.global
        m.top = testSuite.top
        m.scene = testSuite.scene
        m.stats = rooibos_Stats()
    end function
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    '++ running
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    instance.run = function()
        isOk = m.runSuiteFunction(m.setupFunctionName, "setup")
        if isOk
            for each testData in m.testsData
                test = rooibos_Test(m, testData)
                m.tests.push(test)
                isOk = m.runSuiteFunction(m.beforeEachFunctionName, "beforeEach", test)
                if isOk
                    m.testSuite.runTest(test)
                end if
                m.runSuiteFunction(m.afterEachFunctionName, "afterEach", test)
                m.stats.appendTestResult(test.result)
                if m.stats.hasFailures and m.testSuite.isFailingFast
                    ? "Terminating group due to failed test"
                    exit for
                end if
            end for
        else
            ? "ERROR running test setup function"
        end if
        m.runSuiteFunction(m.tearDownFunctionName, "tearDown")
    end function
    instance.runSuiteFunction = function(methodName, defaultMethodName, test = invalid)
        if methodName = invalid or methodName = ""
            methodName = defaultMethodName
        end if
        if m.testSuite.catchCrashes and not m.testSuite.noCatch and not (test <> invalid and test.noCatch)
            try
                m.testSuite[methodName]()
                return true
            catch error
                if test <> invalid
                    'bs:disable-next-line
                    test.result.crash("function " + methodName + "crashed!", error)
                end if
            end try
        else
            m.testSuite[methodName]()
            return true
        end if
        'bs:disable-next-line
        return false
    end function
    return instance
end function
function rooibos_TestGroup(testSuite, data)
    instance = __rooibos_TestGroup_builder()
    instance.new(testSuite, data)
    return instance
end function