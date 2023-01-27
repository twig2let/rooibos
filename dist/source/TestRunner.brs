' /**
'  * @module TestRunner
'  */
' /**
'  * @memberof module:TestRunner
'  * @name Rooibos_TestRunner
'  * @function
'  * @description Creates an instance of the test runner
'  */
function __rooibos_TestRunner_builder()
    instance = {}
    instance.new = function(testScene, nodeContext)
        m.testScene = invalid
        m.testReporter = invalid
        m.nodeContext = invalid
        m.config = invalid
        m.testSuites = []
        m.runtimeConfig = invalid
        m.stats = invalid
        m.top = invalid
        m.testScene = testScene
        if nodeContext.top = invalid
            nodeContext.top = testScene
        end if
        nodeContext.scene = testScene
        m.nodeContext = nodeContext
        m.stats = rooibos_Stats()
        m.runtimeConfig = rooibos_RuntimeConfig()
        m.config = m.runtimeConfig.getRuntimeConfig()
        'TODO - allow providing different reporters via config
        m.testReporter = rooibos_ConsoleTestReporter(m)
    end function
    ' /**
    '  * @memberof module:TestRunner
    '  * @name Run
    '  * @function
    '  * @instance
    '  * @description Executes all tests for a project, as per the config
    '  */
    instance.run = function()
        rooibosTimer = createObject("roTimespan")
        rooibosTimer.mark()
        suiteNames = m.runtimeConfig.getAllTestSuitesNames()
        isFailed = false
        failedText = ""
        i = 0
        numSuites = suiteNames.count()
        testSuite = invalid
        for each name in suiteNames
            i++
            'bs:disable-next-line
            suiteClass = m.runtimeConfig.getTestSuiteClassWithName(name)
            testSuite = invalid
            if suiteClass <> invalid
                testSuite = suiteClass()
                testSuite.global = m.nodeContext.global
                testSuite.context = m.nodeContext
                testSuite.top = m.nodeContext.top
                testSuite.scene = m.nodeContext.global.testsScene
                testSuite.catchCrashes = m.config.catchCrashes
                testSuite.scene.testText = "Running Suite " + bslib_toString(i) + " of " + bslib_toString(numSuites) + ": " + bslib_toString(name)
                m.runTestSuite(testSuite)
                if m.stats.hasFailures = true
                    if not isFailed
                        isFailed = true
                        testSuite.scene.statusColor = "#DA3633"
                    end if
                    if m.config.failFast = true
                        exit for
                    end if
                end if
                if testSuite.stats.hasFailures
                    failedText = name + chr(10) + failedText
                    testSuite.scene.failedText = "Failed Suites: " + chr(10) + failedText
                end if
            else
                ? "ERROR! could not create test for suite : "; name
                failedText = "COULD NOT CREATE suite " + name + chr(10) + failedText
                testSuite.scene.failedText = "Failed Suites: " + chr(10) + failedText
            end if
        end for
        if not isFailed and testSuite <> invalid
            testSuite.scene.statusColor = "#238636"
        end if
        if testSuite = invalid
            m.nodeContext.global.testsScene.failedText = "No tests were found"
        end if
        m.stats.time = rooibosTimer.totalMilliseconds()
        rooibosResult = {
            stats: m.stats
            testSuites: m.testSuites
        }
        m.nodeContext.global.testsScene.rooibosTestResult = rooibosResult
        m.testReporter.reportResults(m.stats)
        'code coverage is not enabled in rooibos 4.0.0 - will get added again in future
        ' if Rooibos.Common.isFunction(RBS_reportCodeCoverage)
        '   'bs:disable-next-line
        '   RBS_reportCodeCoverage()
        '   if m.config.printLcov = true
        '     Coverage.printLCovInfo()
        '   end if
        ' end if
        if m.config.sendHomeOnFinish <> false
            m.sendHomeKeypress()
        end if
    end function
    instance.runInNodeMode = function(nodeTestName)
        'bs:disable-next-line
        suiteClass = m.runtimeConfig.getTestSuiteClassWithName(nodeTestName)
        testSuite = invalid
        if suiteClass <> invalid
            testSuite = suiteClass()
            testSuite.global = m.nodeContext.global
            testSuite.node = m.nodeContext
            testSuite.top = m.nodeContext.top
            testSuite.scene = m.nodeContext.global.testsScene
            testSuite.catchCrashes = m.config.catchCrashes
        end if
        if testSuite <> invalid
            testSuite.run()
            return {
                stats: testSuite.stats
                tests: testSuite.tests
            }
        else
            ? "[ERROR] could not create test suite "; nodeTestName
        end if
        ? "ERROR! executing node test " + nodeTestName + " was unsuccessful."
        return invalid
    end function
    instance.runTestSuite = function(testSuite) as void
        if testSuite.groupsData <> invalid and testSuite.groupsData.count() > 0
            ? ""
            ? Rooibos_Common_fillText("> SUITE: " + testSuite.name, ">", 80)
            m.testSuites.push(testSuite)
            if testSuite.isNodeTest
                m.runNodeTest(testSuite)
            else
                testSuite.run()
            end if
            m.stats.merge(testSuite.stats)
        end if
    end function
    instance.runNodeTest = function(testSuite) as void
        if testSuite.generatedNodeName <> ""
            ? " +++++RUNNING NODE TEST"
            ? " node type is "; testSuite.generatedNodeName
            node = m.testScene.createChild(testSuite.generatedNodeName)
            if type(node) = "roSGNode"
                nodeResults = node.rooibosTestResult
                if nodeResults <> invalid
                    testSuite.stats = nodeResults.stats
                    testSuite.testCases = nodeResults.testCases
                else
                    ? " ERROR! The node test"; testSuite.name; " did not return a result from from the rooibos_runNodeTestSuite method. This usually means you are not importing rooibos.brs and the required test file. Please refer to : https://github.com/georgejecook/rooibos/blob/master/docs/index.md#testing-scenegraph-nodes"
                end if
                m.testScene.removeChild(node)
                return
            else
                ? " ERROR!! - could not create node required to execute tests for "; testSuite.name
                ? " Node of type "; testSuite.generatedNodeName; " was not found/could not be instantiated"
            end if
        else
            ? " ERROR!! - could not create node required to execute tests for "; testSuite.name
            ? " No node type was provided"
        end if
        testSuite.stats.hasFailures = true
        testSuite.failedCount += testSuite.testsData.count()
    end function
    instance.sendHomeKeypress = function()
        ut = createObject("roUrlTransfer")
        ut.SetUrl("http://localhost:8060/keypress/Home")
        ut.PostFromString("")
    end function
    return instance
end function
function rooibos_TestRunner(testScene, nodeContext)
    instance = __rooibos_TestRunner_builder()
    instance.new(testScene, nodeContext)
    return instance
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ This code is called inside of the node
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function rooibos_createTestNode(nodeType) as object
    node = createObject("roSGNode", nodeType)
    if type(node) = "roSGNode" and node.subType() = nodeType
        m.top.AppendChild(node)
        return node
    else
        ? " Error creating test node of type "; nodeType
        return invalid
    end if
end function

function rooibos_runNodeTestSuite(name)
    nodeRunner = rooibos_TestRunner(m.top.getScene(), m)
    return nodeRunner.runInNodeMode(name)
end function