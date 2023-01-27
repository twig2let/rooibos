' /**
'  * @module TestSuite
'  * @description All brs files that include `'@TestSuite` annotations automatically extend the TestSuite.
'  * The base test suite contains all of the assertions, and utility methods required to writey our tests, as well as being responsible for tracking the state of the tests and groups.
'  */
function __rooibos_BaseTestSuite_builder()
    instance = {}
    'test state
    'set the name to the name of your test
    'special values
    ' special value used in mock arguments
    ' special value used in mock arguments
    'built in any matchers
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    '++ base methods to override
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    instance.new = function()
        m.name = "BaseTestSuite"
        m.filePath = invalid
        m.pkgPath = invalid
        m.isValid = false
        m.hasSoloTests = false
        m.hasIgnoredTests = false
        m.isSolo = false
        m.isIgnored = false
        m.noCatch = false
        m.isNodeTest = false
        m.nodeName = invalid
        m.lineNumber = 1
        m.groups = []
        m.groupsData = []
        m.stats = invalid
        m.currentAssertLineNumber = - 1
        m.valid = false
        m.hasFailures = false
        m.hasSoloGroups = false
        m.isFailingFast = false
        m.stubs = invalid
        m.mocks = invalid
        m.__stubId = - 1
        m.__mockId = - 1
        m.__mockTargetId = - 1
        m.invalidValue = "#ROIBOS#INVALID_VALUE"
        m.ignoreValue = "#ROIBOS#IGNORE_VALUE"
        m.anyStringMatcher = {
            "matcher": Rooibos_Matcher_anyString
        }
        m.anyBoolMatcher = {
            "matcher": Rooibos_Matcher_anyBool
        }
        m.anyNumberMatcher = {
            "matcher": Rooibos_Matcher_anyNumber
        }
        m.anyAAMatcher = {
            "matcher": Rooibos_Matcher_anyAA
        }
        m.anyArrayMatcher = {
            "matcher": Rooibos_Matcher_anyArray
        }
        m.anyNodeMatcher = {
            "matcher": Rooibos_Matcher_anyNode
        }
        m.allowNonExistingMethodsOnMocks = true
        m.isAutoAssertingMocks = true
        m.currentResult = invalid
        m.global = invalid
        m.catchCrashes = false
        data = m.getTestSuitedata()
        if data = invalid
            ? "ERROR RETRIEVING TEST SUITE DATA!! this is a rooibos BUG - please report the suite that resulted in a corrupt test. Thanks"
        else
            m.name = data.name
            m.filePath = data.filePath
            m.pkgPath = data.pkgPath
            m.valid = data.valid
            m.hasFailures = data.hasFailures
            m.hasSoloTests = data.hasSoloTests
            m.hasIgnoredTests = data.hasIgnoredTests
            m.hasSoloGroups = data.hasSoloGroups
            m.isSolo = data.isSolo
            m.isIgnored = data.isIgnored
            m.noCatch = data.noCatch
            m.groupsData = data.testGroups
            m.lineNumber = data.lineNumber
            m.isNodeTest = data.isNodeTest
            m.nodeName = data.nodeName
            m.generatedNodeName = data.generatedNodeName
            m.isFailingFast = false
            m.stats = rooibos_Stats()
        end if
    end function
    instance.getTestSuiteData = function()
        'this will be injected by the plugin
    end function
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    '++ used for entire suite - use annotations to use elsewhere
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    instance.setup = function()
    end function
    instance.tearDown = function()
    end function
    instance.beforeEach = function()
    end function
    instance.afterEach = function()
    end function
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    '++ running
    '++++++++++++++++++++++++++++++++++++?+++++++++++++++++++++++++
    instance.run = function()
        for each groupData in m.groupsData
            'bs:disable-next-line
            group = rooibos_TestGroup(m, groupData)
            ? ""
            ? rooibos_common_fillText(">>>> Describe: " + group.name, ">", 80)
            'bs:disable-next-line
            ? "  Location: file://" + bslib_toString(group.testSuite.filePath.trim()) + ":" + bslib_toString(group.lineNumber)
            ? ""
            'bs:disable-next-line
            m.groups.push(group)
            'bs:disable-next-line
            group.run()
            'bs:disable-next-line
            m.stats.merge(group.stats)
            if m.stats.hasFailures and m.isFailingFast = true
                ? "Terminating suite due to failed group"
                exit for
            end if
        end for
    end function
    instance.runTest = function(test as object)
        ? ""
        ? rooibos_common_fillText(">>>>>> It: " + test.name, ">", 80)
        ? "  Location: file://" + bslib_toString(test.testSuite.filePath.trim()) + ":" + bslib_toString(test.lineNumber)
        ? ""
        m.currentResult = test.result
        if m.catchCrashes and not test.noCatch and not m.noCatch
            try
                test.run()
                if m.isAutoAssertingMocks = true
                    m.AssertMocks()
                    m.CleanMocks()
                    m.CleanStubs()
                end if
            catch error
                'bs:disable-next-line
                m.currentResult.crash("test crashed!", error)
            end try
        else
            test.run()
            if m.isAutoAssertingMocks = true
                m.AssertMocks()
                m.CleanMocks()
                m.CleanStubs()
            end if
        end if
        ? rooibos_common_fillText("<<<< END It: " + test.name + " (" + m.currentResult.getStatusText() + ") ", "<", 80)
    end function
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    '++ Assertions
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name fail
    '  * @function
    '  * @instance
    '  * @description Fail immediately, with the given message
    '  * @param {Dynamic} [msg=""] - message to display in the test report
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.fail = function(msg = "Error" as string) as dynamic
        if m.currentResult.isFail
            return false
        end if
        m.currentResult.fail(msg, m.currentAssertLineNumber)
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertFalse
    '  * @function
    '  * @instance
    '  * @description Fail the test if the expression is true.
    '  * @param {Dynamic} expr - An expression to evaluate.
    '  * @param {Dynamic} [msg=""] - alternate error message
    ' Default value: "Expression evaluates to true"'  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertFalse = function(expr as dynamic, msg = "Expression evaluates to true") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if Rooibos_Common_isBoolean(expr)
                if expr
                    return m.fail(msg)
                end if
            else
                return m.fail("value was not a boolean")
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertTrue
    '  * @function
    '  * @instance
    '  * @description Fail the test unless the expression is true.
    '  * @param {Dynamic} expr - An expression to evaluate.
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertTrue = function(expr, msg = "Expression evaluates to false")
        if m.currentResult.isFail
            return false
        end if
        try
            if Rooibos_Common_isBoolean(expr)
                if not expr
                    return m.fail(msg)
                end if
            else
                return m.fail("value was not a boolean")
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertEqual
    '  * @function
    '  * @instance
    '  * @description Fail if the two objects are unequal as determined by the '<>' operator.
    '  * @param {Dynamic} first - first object to compare
    '  * @param {Dynamic} second - second object to compare
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertEqual = function(first, second, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if not Rooibos_Common_eqValues(first, second)
                if msg = ""
                    first_as_string = Rooibos_Common_asString(first, true)
                    second_as_string = Rooibos_Common_asString(second, true)
                    msg = first_as_string + " != " + second_as_string
                end if
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertLike
    '  * @function
    '  * @instance
    '  * @description does a fuzzy comparison
    '  * @param {Dynamic} first - first object to compare
    '  * @param {Dynamic} second - second object to compare
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertLike = function(first, second, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if not Rooibos_Common_eqValues(first, second, true)
                if msg = ""
                    first_as_string = Rooibos_Common_asString(first)
                    second_as_string = Rooibos_Common_asString(second)
                    msg = first_as_string + " != " + second_as_string
                end if
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertNotEqual
    '  * @function
    '  * @instance
    '  * @description Fail if the two objects are equal as determined by the '=' operator.
    '  * @param {Dynamic} first - first object to compare
    '  * @param {Dynamic} second - second object to compare
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertNotEqual = function(first, second, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if Rooibos_Common_eqValues(first, second)
                if msg = ""
                    first_as_string = Rooibos_Common_asString(first, true)
                    second_as_string = Rooibos_Common_asString(second, true)
                    msg = first_as_string + " == " + second_as_string
                end if
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertInvalid
    '  * @function
    '  * @instance
    '  * @description Fail if the value is not invalid.
    '  * @param {Dynamic} value - value to check - value to check for
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertInvalid = function(value, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if value <> invalid
                if msg = ""
                    expr_as_string = Rooibos_Common_asString(value, true)
                    msg = expr_as_string + " <> Invalid"
                end if
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertNotInvalid
    '  * @function
    '  * @instance
    '  * @description Fail if the value is invalid.
    '  * @param {Dynamic} value - value to check - value to check for
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertNotInvalid = function(value, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if value = invalid
                if msg = ""
                    msg = "Expected value, got invalid"
                end if
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertAAHasKey
    '  * @function
    '  * @instance
    '  * @description Fail if the array doesn't have the key.
    '  * @param {Dynamic} array - target array
    '  * @param {Dynamic} key - key name
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertAAHasKey = function(array, key, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if Rooibos_Common_isAssociativeArray(array)
                if not array.DoesExist(key)
                    if msg = ""
                        msg = "Array doesn't have the '" + key + "' key."
                    end if
                    m.currentResult.fail(msg, m.currentAssertLineNumber)
                    return false
                end if
            else
                msg = "Input value is not an Associative Array."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertAANotHasKey
    '  * @function
    '  * @instance
    '  * @description Fail if the array has the key.
    '  * @param {Dynamic} array - target array
    '  * @param {Dynamic} key - key name
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertAANotHasKey = function(array, key, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if Rooibos_Common_isAssociativeArray(array)
                if array.DoesExist(key)
                    if msg = ""
                        msg = "Array has the '" + key + "' key."
                    end if
                    m.currentResult.fail(msg, m.currentAssertLineNumber)
                    return false
                end if
            else
                msg = "Input value is not an Associative Array."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertAAHasKeys
    '  * @function
    '  * @instance
    '  * @description Fail if the array doesn't have the keys list.
    '  * @param {Dynamic} array - A target associative array.
    '  * @param {Dynamic} keys - Array of key names.
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertAAHasKeys = function(array, keys, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if Rooibos_Common_isAssociativeArray(array) and Rooibos_Common_isArray(keys)
                for each key in keys
                    if not array.DoesExist(key)
                        if msg = ""
                            msg = "Array doesn't have the '" + key + "' key."
                        end if
                        m.currentResult.fail(msg, m.currentAssertLineNumber)
                        return false
                    end if
                end for
            else
                msg = "Input value is not an Associative Array."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertAANotHasKeys
    '  * @function
    '  * @instance
    '  * @description Fail if the array has the keys list.
    '  * @param {Dynamic} array - A target associative array.
    '  * @param {Dynamic} keys - Array of key names.
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertAANotHasKeys = function(array, keys, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if Rooibos_Common_isAssociativeArray(array) and Rooibos_Common_isArray(keys)
                for each key in keys
                    if array.DoesExist(key)
                        if msg = ""
                            msg = "Array has the '" + key + "' key."
                        end if
                        m.currentResult.fail(msg, m.currentAssertLineNumber)
                        return false
                    end if
                end for
            else
                msg = "Input value is not an Associative Array."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertArrayContains
    '  * @function
    '  * @instance
    '  * @description Fail if the array doesn't have the item.
    '  * @param {Dynamic} array - target array
    '  * @param {Dynamic} value - value to check - value to check for
    '  * @param {Dynamic} key - key name in associative array
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertArrayContains = function(array, value, key = invalid, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if Rooibos_Common_isAssociativeArray(array) or Rooibos_Common_isArray(array)
                if not Rooibos_Common_arrayContains(array, value, key)
                    msg = "Array doesn't have the '" + Rooibos_Common_asString(value, true) + "' value."
                    m.currentResult.fail(msg, m.currentAssertLineNumber)
                    return false
                end if
            else
                msg = "Input value is not an Array."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertArrayContainsAAs
    '  * @function
    '  * @instance
    '  * @description Fail if the array does not contain all of the aa's in the values array.
    '  * @param {Dynamic} array - target array
    '  * @param {Dynamic} values - array of aas to look for in target array
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertArrayContainsAAs = function(array, values, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if not Rooibos_Common_isArray(values)
                msg = "values to search for are not an Array."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            if Rooibos_Common_isArray(array)
                for each value in values
                    isMatched = false
                    if not Rooibos_Common_isAssociativeArray(value)
                        msg = "Value to search for was not associativeArray " + Rooibos_Common_asString(value, true)
                        m.currentResult.fail(msg, m.currentAssertLineNumber)
                        return false
                    end if
                    for each item in array
                        if Rooibos_Common_IsAssociativeArray(item)
                            isValueMatched = true
                            for each key in value
                                fieldValue = value[key]
                                itemValue = item[key]
                                if not Rooibos_Common_eqValues(fieldValue, itemValue)
                                    isValueMatched = false
                                    exit for
                                end if
                            end for
                            if isValueMatched
                                isMatched = true
                                exit for
                            end if
                        end if
                    end for ' items in array
                    if not isMatched
                        msg = "array missing value: " + Rooibos_Common_asString(value, true)
                        m.currentResult.fail(msg, m.currentAssertLineNumber)
                        return false
                    end if
                end for 'values to match
            else
                msg = "Input value is not an Array."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertArrayNotContains
    '  * @function
    '  * @instance
    '  * @description Fail if the array has the item.
    '  * @param {Dynamic} array - target array
    '  * @param {Dynamic} array - target array
    '  * @param {Dynamic} value - value to check - Value to check for
    '  * @param {Dynamic} key - A key name for associative array.
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertArrayNotContains = function(array, value, key = invalid, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if Rooibos_Common_isAssociativeArray(array) or Rooibos_Common_isArray(array)
                if Rooibos_Common_arrayContains(array, value, key)
                    msg = "Array has the '" + Rooibos_Common_asString(value, true) + "' value."
                    m.currentResult.fail(msg, m.currentAssertLineNumber)
                    return false
                end if
            else
                msg = "Input value is not an Array."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertArrayContainsSubset
    '  * @function
    '  * @instance
    '  * @description Fail if the array doesn't have the item subset.
    '  * @param {Dynamic} array - target array
    '  * @param {Dynamic} subset - items to check presnece of
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertArrayContainsSubset = function(array, subset, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if (Rooibos_Common_isAssociativeArray(array) and Rooibos_Common_isAssociativeArray(subset)) or (Rooibos_Common_isArray(array) and Rooibos_Common_isArray(subset))
                isAA = Rooibos_Common_isAssociativeArray(subset)
                for each item in subset
                    key = invalid
                    value = item
                    if isAA
                        key = item
                        value = subset[key]
                    end if
                    if not Rooibos_Common_arrayContains(array, value, key)
                        msg = "Array doesn't have the '" + Rooibos_Common_asString(value, true) + "' value."
                        m.currentResult.fail(msg, m.currentAssertLineNumber)
                        return false
                    end if
                end for
            else
                msg = "Input value is not an Array."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertArrayNotContainsSubset
    '  * @function
    '  * @instance
    '  * @description Fail if the array have the item from subset.
    '  * @param {Dynamic} array - target array
    '  * @param {Dynamic} subset - items to check presnece of
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertArrayNotContainsSubset = function(array, subset, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if (Rooibos_Common_isAssociativeArray(array) and Rooibos_Common_isAssociativeArray(subset)) or (Rooibos_Common_isArray(array) and Rooibos_Common_isArray(subset))
                isAA = Rooibos_Common_isAssociativeArray(subset)
                for each item in subset
                    key = invalid
                    value = item
                    if isAA
                        key = item
                        value = item[key]
                    end if
                    if Rooibos_Common_arrayContains(array, value, key)
                        msg = "Array has the '" + Rooibos_Common_asString(value, true) + "' value."
                        m.currentResult.fail(msg, m.currentAssertLineNumber)
                        return false
                    end if
                end for
            else
                msg = "Input value is not an Array."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertArrayCount
    '  * @function
    '  * @instance
    '  * @description Fail if the array items count <> expected count
    '  * @param {Dynamic} array - target array
    '  * @param {Dynamic} count - An expected array items count
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertArrayCount = function(array, count, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if Rooibos_Common_isAssociativeArray(array) or Rooibos_Common_isArray(array)
                if array.Count() <> count
                    msg = "Array items count " + Rooibos_Common_asString(array.Count()) + " <> " + Rooibos_Common_asString(count) + "."
                    m.currentResult.fail(msg, m.currentAssertLineNumber)
                    return false
                end if
            else
                msg = "Input value is not an Array."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertArrayNotCount
    '  * @function
    '  * @instance
    '  * @description Fail if the array items count = expected count.
    '  * @param {Dynamic} array - target array
    '  * @param {Dynamic} count - An expected array items count.
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertArrayNotCount = function(array, count, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if Rooibos_Common_isAssociativeArray(array) or Rooibos_Common_isArray(array)
                if array.Count() = count
                    msg = "Array items count = " + Rooibos_Common_asString(count) + "."
                    m.currentResult.fail(msg, m.currentAssertLineNumber)
                    return false
                end if
            else
                msg = "Input value is not an Array."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertEmpty
    '  * @function
    '  * @instance
    '  * @description Fail if the item is not empty array or string.
    '  * @param {Dynamic} item - item to check
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertEmpty = function(item, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if Rooibos_Common_isAssociativeArray(item) or Rooibos_Common_isArray(item)
                if item.count() > 0
                    msg = "Array is not empty."
                    m.currentResult.fail(msg, m.currentAssertLineNumber)
                    return false
                end if
            else if Rooibos_Common_isString(item)
                if Rooibos_Common_asString(item) <> ""
                    msg = "String is not empty, contains: " + Rooibos_Common_asString(item, true)
                    m.currentResult.fail(msg, m.currentAssertLineNumber)
                    return false
                end if
            else
                msg = "AssertEmpty: Input value was not an array or a string"
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertNotEmpty
    '  * @function
    '  * @instance
    '  * @description Fail if the item is empty array or string.
    '  * @param {Dynamic} item - item to check
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertNotEmpty = function(item, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if Rooibos_Common_isAssociativeArray(item) or Rooibos_Common_isArray(item)
                if item.count() = 0
                    msg = "Array is empty."
                    m.currentResult.fail(msg, m.currentAssertLineNumber)
                    return false
                end if
            else if Rooibos_Common_isString(item)
                if item = ""
                    msg = "Input value is empty."
                    m.currentResult.fail(msg, m.currentAssertLineNumber)
                    return false
                end if
            else
                msg = "Input value is not a string or array."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertArrayContainsOnlyValuesOfType
    '  * @function
    '  * @instance
    '  * @description Fail if the array doesn't contains items of specific type only.
    '  * @param {Dynamic} array - target array
    '  * @param {Dynamic} typeStr - type name - must be String, Array, Boolean, or AssociativeArray
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertArrayContainsOnlyValuesOfType = function(array, typeStr, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if typeStr <> "String" and typeStr <> "Integer" and typeStr <> "Boolean" and typeStr <> "Array" and typeStr <> "AssociativeArray"
                msg = "Type must be Boolean, String, Array, Integer, or AssociativeArray"
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            if Rooibos_Common_isAssociativeArray(array) or Rooibos_Common_isArray(array)
                methodName = "Rooibos_Common_Is" + typeStr
                typeCheckFunction = m.getIsTypeFunction(methodName)
                if typeCheckFunction <> invalid
                    for each item in array
                        if not typeCheckFunction(item)
                            msg = Rooibos_Common_asString(item, true) + " is not a '" + typeStr + "' type."
                            m.currentResult.fail(msg, m.currentAssertLineNumber)
                            return false
                        end if
                    end for
                else
                    msg = "could not find comparator for type '" + typeStr + "' type."
                    m.currentResult.fail(msg, m.currentAssertLineNumber)
                    return false
                end if
            else
                msg = "Input value is not an Array."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    instance.getIsTypeFunction = function(name)
        if name = "Rooibos_Common_IsFunction"
            return Rooibos_Common_isFunction
        else if name = "Rooibos_Common_IsXmlElement"
            return Rooibos_Common_isXmlElement
        else if name = "Rooibos_Common_IsInteger"
            return Rooibos_Common_isInteger
        else if name = "Rooibos_Common_IsBoolean"
            return Rooibos_Common_isBoolean
        else if name = "Rooibos_Common_IsFloat"
            return Rooibos_Common_isFloat
        else if name = "Rooibos_Common_IsDouble"
            return Rooibos_Common_isDouble
        else if name = "Rooibos_Common_IsLongInteger"
            return Rooibos_Common_isLongInteger
        else if name = "Rooibos_Common_IsNumber"
            return Rooibos_Common_isNumber
        else if name = "Rooibos_Common_IsList"
            return Rooibos_Common_isList
        else if name = "Rooibos_Common_IsArray"
            return Rooibos_Common_isArray
        else if name = "Rooibos_Common_IsAssociativeArray"
            return Rooibos_Common_isAssociativeArray
        else if name = "Rooibos_Common_IsSGNode"
            return Rooibos_Common_isSGNode
        else if name = "Rooibos_Common_IsString"
            return Rooibos_Common_isString
        else if name = "Rooibos_Common_IsDateTime"
            return Rooibos_Common_isDateTime
        else if name = "Rooibos_Common_IsUndefined"
            return Rooibos_Common_isUndefined
        else
            return invalid
        end if
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertType
    '  * @function
    '  * @instance
    '  * @description Asserts that the value is a node of designated type
    '  * @param {Dynamic} value - value to check - target node
    '  * @param {Dynamic} typeStr - type name
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertType = function(value, typeStr, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if type(value) <> typeStr
                if msg = ""
                    expr_as_string = Rooibos_Common_asString(value, true)
                    msg = expr_as_string + " was not expected type " + typeStr
                end if
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertSubType
    '  * @function
    '  * @instance
    '  * @description Asserts that the value is a node of designated subtype
    '  * @param {Dynamic} value - value to check - target node
    '  * @param {Dynamic} typeStr - type name
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertSubType = function(value, typeStr, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if type(value) <> "roSGNode"
                if msg = ""
                    expr_as_string = Rooibos_Common_asString(value, true)
                    msg = expr_as_string + " was not a node, so could not match subtype " + typeStr
                end if
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            else if value.subType() <> typeStr
                if msg = ""
                    expr_as_string = Rooibos_Common_asString(value, true)
                    msg = expr_as_string + "( type : " + value.subType() + ") was not of subType " + typeStr
                end if
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    instance.assertClass = function(value, func, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        if rooibos_Common_isFunction(func)
            func = func.toStr().mid(10).replace("_", ".")
        end if
        try
            if not Rooibos_Common_isAssociativeArray(value)
                if msg = ""
                    expr_as_string = Rooibos_Common_asString(value)
                    msg = expr_as_string + " was not an aa, so could not match Class " + func
                end if
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            className = lCase(bslib_toString(value.__classname))
            if className <> lCase(func)
                if msg = ""
                    msg = "Expected class: " + bslib_toString(func) + " got " + bslib_toString(className)
                end if
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    '++ NEW NODE ASSERTS
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertNodeCount
    '  * @function
    '  * @instance
    '  * @description Asserts that the node contains the desginated number of children
    '  * @param {Dynamic} node - target node
    '  * @param {Dynamic} count - expected number of child items
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert w, false otherwise
    '  */
    instance.assertNodeCount = function(node, count, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if type(node) = "roSGNode"
                if node.isSubType("mc_Node")
                    if node.isSubType("mc_Node")
                        childCount = node.length
                    else
                        childCount = node.getChildCount()
                    end if
                    if childCount <> count
                        msg = "node items count <> " + Rooibos_Common_asString(count) + ". Received " + Rooibos_Common_asString(childCount)
                        m.currentResult.fail(msg, m.currentAssertLineNumber)
                        return false
                    end if
                end if
            else
                msg = "Input value is not an node."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertNodeNotCount
    '  * @function
    '  * @instance
    '  * @description Fail if the node items count = expected count.
    '  * @param {Dynamic} node - A target node
    '  * @param {Dynamic} count - Expected item count
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertNodeNotCount = function(node, count, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if type(node) = "roSGNode"
                if node.isSubType("mc_Node")
                    childCount = node.length
                else
                    childCount = node.getChildCount()
                end if
                if childCount = count
                    msg = "node items count = " + Rooibos_Common_asString(count) + "."
                    m.currentResult.fail(msg, m.currentAssertLineNumber)
                    return false
                end if
            else
                msg = "Input value is not an node."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertNodeEmpty
    '  * @function
    '  * @instance
    '  * @description Asserts the node has no children
    '  * @param {Dynamic} node - a node to check
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertNodeEmpty = function(node, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if type(node) = "roSGNode"
                if node.isSubType("mc_Node")
                    childCount = node.length
                else
                    childCount = node.getChildCount()
                end if
                if childCount > 0
                    msg = "node is not empty."
                    m.currentResult.fail(msg, m.currentAssertLineNumber)
                    return false
                end if
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertNodeNotEmpty
    '  * @function
    '  * @instance
    '  * @description Asserts the node has children
    '  * @param {Dynamic} node - a node to check
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertNodeNotEmpty = function(node, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if type(node) = "roSGNode"
                if node.Count() = 0
                    msg = "Array is empty."
                    m.currentResult.fail(msg, m.currentAssertLineNumber)
                    return false
                end if
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertNodeContains
    '  * @function
    '  * @instance
    '  * @description Asserts the node contains the child _value_
    '  * @param {Dynamic} node - a node to check
    '  * @param {Dynamic} value - value to check - value to look for
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertNodeContains = function(node, value, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if type(node) = "roSGNode"
                if not Rooibos_Common_nodeContains(node, value)
                    msg = "Node doesn't have the '" + Rooibos_Common_asString(value, true) + "' value."
                    m.currentResult.fail(msg, m.currentAssertLineNumber)
                    return false
                end if
            else
                msg = "Input value is not an Node."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertNodeContainsOnly
    '  * @function
    '  * @instance
    '  * @description Asserts the node contains only the child _value_
    '  * @param {Dynamic} node - a node to check
    '  * @param {Dynamic} value - value to check - value to look for
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertNodeContainsOnly = function(node, value, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if type(node) = "roSGNode"
                if not Rooibos_Common_nodeContains(node, value)
                    msg = "Node doesn't have the '" + Rooibos_Common_asString(value, true) + "' value."
                    m.currentResult.fail(msg, m.currentAssertLineNumber)
                    return false
                else
                    if node.isSubType("mc_Node")
                        childCount = node.length
                    else
                        childCount = node.getChildCount()
                    end if
                    if childCount <> 1
                        msg = "Node Contains specified value; but other values as well"
                        m.currentResult.fail(msg, m.currentAssertLineNumber)
                        return false
                    end if
                end if
            else
                msg = "Input value is not an Node."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertNodeNotContains
    '  * @function
    '  * @instance
    '  * @description Fail if the node h item.
    '  * @param {Dynamic} node - A target node
    '  * @param {Dynamic} value - value to check - a node child
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertNodeNotContains = function(node, value, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if type(node) = "roSGNode"
                if Rooibos_Common_nodeContains(node, value)
                    msg = "Node has the '" + Rooibos_Common_asString(value, true) + "' value."
                    m.currentResult.fail(msg, m.currentAssertLineNumber)
                    return false
                end if
            else
                msg = "Input value is not an Node."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertNodeContainsFields
    '  * @function
    '  * @instance
    '  * @description Fail if the node doesn't have the item subset.
    '  * @param {Dynamic} node - A target node
    '  * @param {Dynamic} subset - items to check
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertNodeContainsFields = function(node, subset, ignoredFields = invalid, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if (type(node) = "roSGNode" and Rooibos_Common_isAssociativeArray(subset)) or (type(node) = "roSGNode" and Rooibos_Common_isArray(subset))
                isIgnoredFields = Rooibos_Common_isArray(ignoredFields)
                for each key in subset
                    if key <> ""
                        if not isIgnoredFields or not Rooibos_Common_arrayContains(ignoredFields, key)
                            subsetValue = subset[key]
                            nodeValue = node[key]
                            if not Rooibos_Common_eqValues(nodeValue, subsetValue)
                                msg = key + ": Expected '" + Rooibos_Common_asString(subsetValue, true) + "', got '" + Rooibos_Common_asString(nodeValue, true) + "'"
                                m.currentResult.fail(msg, m.currentAssertLineNumber)
                                return false
                            end if
                        end if
                    else
                        ? "Found empty key!"
                    end if
                end for
            else
                msg = "Input value is not an Node."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertNodeNotContainsFields
    '  * @function
    '  * @instance
    '  * @description Fail if the node have the item from subset.
    '  * @param {Dynamic} node - A target node
    '  * @param {Dynamic} subset - the items to check for
    '  * @param {Dynamic} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert w, false otherwise
    ' */
    instance.assertNodeNotContainsFields = function(node, subset, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if (type(node) = "roSGNode" and Rooibos_Common_isAssociativeArray(subset)) or (type(node) = "roSGNode" and Rooibos_Common_isArray(subset))
                isAA = Rooibos_Common_isAssociativeArray(subset)
                for each item in subset
                    key = invalid
                    value = item
                    if isAA
                        key = item
                        value = item[key]
                    end if
                    if Rooibos_Common_nodeContains(node, value)
                        msg = "Node has the '" + Rooibos_Common_asString(value, true) + "' value."
                        m.currentResult.fail(msg, m.currentAssertLineNumber)
                        return false
                    end if
                end for
            else
                msg = "Input value is not an Node."
                m.currentResult.fail(msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    '++ END NODE ASSERTS
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertAAContainsSubset
    '  * @function
    '  * @instance
    '  * @description Asserts the associative array contains the fields contained in subset; while ignoring the fields in the ignoredFields array
    '  * @param {assocarray} array - associative array  to check
    '  * @param {assocarray} subset - associative array of values to check for
    '  * @param {array} ignoredFields - array of fieldnames to ignore while comparing
    '  * @param {string} [msg=""] - alternate error message
    '  * @returns {boolean} - true if the assert was satisfied, false otherwise
    '  */
    instance.assertAAContainsSubset = function(array, subset, ignoredFields = invalid, msg = "") as dynamic
        if m.currentResult.isFail
            return false
        end if
        try
            if Rooibos_Common_isAssociativeArray(array) and Rooibos_Common_isAssociativeArray(subset)
                isIgnoredFields = Rooibos_Common_isArray(ignoredFields)
                for each key in subset
                    if key <> ""
                        if not isIgnoredFields or not Rooibos_Common_arrayContains(ignoredFields, key)
                            subsetValue = subset[key]
                            arrayValue = array[key]
                            if not Rooibos_Common_eqValues(arrayValue, subsetValue)
                                msg = key + ": Expected '" + Rooibos_Common_asString(subsetValue, true) + "', got '" + Rooibos_Common_asString(arrayValue, true) + "'"
                                m.currentResult.fail(msg, m.currentAssertLineNumber)
                                return false
                            end if
                        end if
                    else
                        ? "Found empty key!"
                    end if
                end for
            else
                msg = "Input values are not an Associative Array."
                m.currentResult.fail("Assert failed: " + msg, m.currentAssertLineNumber)
                return false
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Assert failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    '++ Stubbing helpers
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name stub
    '  * @function
    '  * @instance
    '  * @description Creates a stub to replace a real method with
    '  * @param {Dynamic} target - object on which the method to be stubbed is found
    '  * @param {Dynamic} methodName - name of method to stub
    '  * @param {Dynamic} [returnValue=invalid] - value that the stub method will return when invoked
    '  * @param {boolean} [allowNonExistingMethods=false] - if true, then rooibos will only warn if the method did not exist prior to faking
    '  * @returns {Object} - stub that was wired into the real method
    '  */
    instance.stub = function(target, methodName, returnValue = invalid, allowNonExistingMethods = false) as object
        if type(target) <> "roAssociativeArray"
            m.fail("could not create Stub provided target was null")
            return {}
        end if
        if m.stubs = invalid
            m.__stubId = - 1
            m.stubs = {}
        end if
        m.__stubId++
        if m.__stubId > 25
            ? "ERROR ONLY 25 MOCKS PER TEST ARE SUPPORTED!! you're on # "; m.__mockId
            ? " Method was "; methodName
            return invalid
        end if
        id = stri(m.__stubId).trim()
        fake = m.createFake(id, target, methodName, 1, invalid, returnValue)
        m.stubs[id] = fake
        allowNonExisting = m.allowNonExistingMethodsOnMocks = true or allowNonExistingMethods
        isMethodPresent = type(target[methodName]) = "Function" or type(target[methodName]) = "roFunction"
        if isMethodPresent or allowNonExisting
            target[methodName] = m["StubCallback" + id]
            target.__stubs = m.stubs
            ' FIXME: add a log setting for this - and add better detection so that stubs know that they are colliding/don't exist/have correct sigs
            ' if not isMethodPresent
            '   ? "WARNING - stubbing call " ; methodName; " which did not exist on target object"
            ' end if
        else
            ? "ERROR - could not create Stub : method not found  "; target; "."; methodName
        end if
        return fake
    end function
    instance.expectLastCallToThrowError = function(error as dynamic)
        try
            mock = m.mocks[m.__mockId.toStr()]
            mock.toThrow(error)
        catch error
            m.log.error("could not add throw to last call", error)
        end try
    end function
    instance.expectCalled = function(invocation as dynamic, returnValue = invalid as dynamic) as object
        'mock function body - the plugin replaces this
        return invalid
    end function
    instance._expectCalled = function(target, methodName, rootObject = invalid as dynamic, fullPath = invalid as dynamic, expectedArgs = invalid, returnValue = invalid as dynamic) as object
        try
            if type(target) <> "roAssociativeArray" and fullPath <> invalid
                target = rooibos_Common_makePathStubbable(rootObject, fullPath)
            end if
            return m.mock(target, methodName, 1, expectedArgs, returnValue, true)
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Setting up mock failed: " + error.message, m.currentAssertLineNumber)
        end try
        return invalid
    end function
    instance.stubCall = function(invocation as dynamic, returnValue = invalid as dynamic) as object
        'mock function body - the plugin replaces this
        return invalid
    end function
    instance._stubCall = function(target, methodName, rootObject = invalid as dynamic, fullPath = invalid as dynamic, returnValue = invalid as dynamic) as object
        try
            if type(target) <> "roAssociativeArray" and fullPath <> invalid
                target = rooibos_Common_makePathStubbable(rootObject, fullPath)
            end if
            return m.stub(target, methodName, returnValue, true)
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Setting up mock failed: " + error.message, m.currentAssertLineNumber)
            return false
        end try
        return false
    end function
    instance.expectNotCalled = function(invocation as dynamic) as object
        'mock function body - the plugin replaces this
        return invalid
    end function
    instance._expectNotCalled = function(target, methodName, rootObject = invalid as dynamic, fullPath = invalid as dynamic) as object
        try
            if type(target) <> "roAssociativeArray" and fullPath <> invalid
                target = rooibos_Common_makePathStubbable(rootObject, fullPath)
            end if
            return m.mock(target, methodName, 0, invalid, invalid, true)
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Setting up mock failed: " + error.message, m.currentAssertLineNumber)
            return false
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name expectOnce
    '  * @function
    '  * @instance
    '  * @description Creates a stub to replace a real method with, which the framework will track. If it was invoked the wrong number of times, or with wrong arguments, it will result in test failure
    '  * @param {Dynamic} target - object on which the method to be stubbed is found
    '  * @param {Dynamic} methodName - name of method to stub
    '  * @param {Dynamic} [expectedArgs=invalid] - array containing the arguments we expect the method to be invoked with
    '  * @param {Dynamic} [returnValue=invalid] - value that the stub method will return when invoked
    '  * @param {boolean} [allowNonExistingMethods=false] - if true, then rooibos will only warn if the method did not exist prior to faking
    '  * @returns {Object} - mock that was wired into the real method
    '  */
    instance.expectOnce = function(target, methodName, expectedArgs = invalid, returnValue = invalid, allowNonExistingMethods = false) as object
        try
            return m.mock(target, methodName, 1, expectedArgs, returnValue, allowNonExistingMethods)
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Setting up mock failed: " + error.message, m.currentAssertLineNumber)
            return false
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name expectOnceOrNone
    '  * @function
    '  * @instance
    '  * @description Toggles between expectOnce and expectNone, to allow for easy paremeterized expect behaviour
    '  * @param {Dynamic} target - object on which the method to be stubbed is found
    '  * @param {Dynamic} methodName - name of method to stub
    '  * @param {Dynamic} isExpected - if true, then this is the same as expectOnce, if false, then this is the same as expectNone
    '  * @param {Dynamic} [expectedArgs=invalid] - array containing the arguments we expect the method to be invoked with
    '  * @param {Dynamic} [returnValue=invalid] - value that the stub method will return when invoked
    '  * @param {boolean} [allowNonExistingMethods=false] - if true, then rooibos will only warn if the method did not exist prior to faking
    '  * @returns {Object} - mock that was wired into the real method
    '  */
    instance.expectOnceOrNone = function(target, methodName, isExpected, expectedArgs = invalid, returnValue = invalid, allowNonExistingMethods = false) as object
        try
            if isExpected
                return m.expectOnce(target, methodName, expectedArgs, returnValue, allowNonExistingMethods)
            else
                return m.expectNone(target, methodName, allowNonExistingMethods)
            end if
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Setting up mock failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name expectNone
    '  * @function
    '  * @instance
    '  * @description Creates a stub to replace a real method with, which the framework will track. If it was invoked, it will result in test failure
    '  * @param {Dynamic} target - object on which the method to be stubbed is found
    '  * @param {Dynamic} methodName - name of method to stub
    '  * @param {boolean} [allowNonExistingMethods=false] - if true, then rooibos will only warn if the method did not exist prior to faking
    '  * @returns {Object} - mock that was wired into the real method
    '  */
    instance.expectNone = function(target, methodName, allowNonExistingMethods = false) as object
        try
            return m.mock(target, methodName, 0, invalid, invalid, allowNonExistingMethods)
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Setting up mock failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name expect
    '  * @function
    '  * @instance
    '  * @description Creates a stub to replace a real method with, which the framework will track. If it was invoked the wrong number of times, or with wrong arguments, it will result in test failure
    '  * @param {Dynamic} target - object on which the method to be stubbed is found
    '  * @param {Dynamic} methodName - name of method to stub
    '  * @param {Dynamic} [expectedInvocations=1] - number of invocations we expect
    '  * @param {Dynamic} [expectedArgs=invalid] - array containing the arguments we expect the method to be invoked with
    '  * @param {Dynamic} [returnValue=invalid] - value that the stub method will return when invoked
    '  * @param {boolean} [allowNonExistingMethods=false] - if true, then rooibos will only warn if the method did not exist prior to faking
    '  * @returns {Object} - mock that was wired into the real method
    '  */
    instance.expect = function(target, methodName, expectedInvocations = 1, expectedArgs = invalid, returnValue = invalid, allowNonExistingMethods = false) as object
        try
            return m.mock(target, methodName, expectedInvocations, expectedArgs, returnValue, allowNonExistingMethods)
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Setting up mock failed: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name mock
    '  * @function
    '  * @instance
    '  * @description Creates a stub to replace a real method with, which the framework will track. If it was invoked the wrong number of times, or with wrong arguments, it will result in test failure
    '  * @param {Dynamic} target - object on which the method to be stubbed is found
    '  * @param {Dynamic} methodName - name of method to stub
    '  * @param {Dynamic} expectedInvocations - number of invocations we expect
    '  * @param {Dynamic} [expectedArgs=invalid] - array containing the arguments we expect the method to be invoked with
    '  * @param {Dynamic} [returnValue=invalid] - value that the stub method will return when invoked
    '  * @param {boolean} [allowNonExistingMethods=false] - if true, then rooibos will only warn if the method did not exist prior to faking
    '  * @returns {Object} - mock that was wired into the real method
    '  */
    instance.mock = function(target, methodName, expectedInvocations = 1, expectedArgs = invalid, returnValue = invalid, allowNonExistingMethods = false) as object
        lineNumber = m.currentAssertLineNumber
        'check params
        if not Rooibos_Common_isAssociativeArray(target)
            methodName = ""
            m.mockFail(lineNumber, "", "mock args: target was not an AA")
        else if not Rooibos_Common_isString(methodName)
            methodName = ""
            m.mockFail(lineNumber, "", "mock args: methodName was not a string")
        else if not Rooibos_Common_isNumber(expectedInvocations)
            m.mockFail(lineNumber, methodName, "mock args: expectedInvocations was not an int")
        else if not Rooibos_Common_isArray(expectedArgs) and Rooibos_Common_isValid(expectedArgs)
            m.mockFail(lineNumber, methodName, "mock args: expectedArgs was not invalid or an array of args")
        else if Rooibos_Common_isUndefined(expectedArgs)
            m.mockFail(lineNumber, methodName, "mock args: expectedArgs undefined")
        else if Rooibos_Common_isUndefined(returnValue)
            m.mockFail(lineNumber, methodName, "mock args: returnValue undefined")
        end if
        if m.currentResult.isFail
            ? "ERROR! Cannot create MOCK. method "; methodName; " " str(lineNumber); " "; m.currentResult.message
            return {}
        end if
        if m.mocks = invalid
            m.__mockId = - 1
            m.__mockTargetId = - 1
            m.mocks = {}
        end if
        fake = invalid
        if not target.doesExist("__rooibosTargetId")
            m.__mockTargetId++
            target["__rooibosTargetId"] = m.__mockTargetId
        end if
        'ascertain if mock already exists
        for i = 0 to m.__mockId
            id = stri(i).trim()
            mock = m.mocks[id]
            if mock <> invalid and mock.methodName = methodName and mock.target.__rooibosTargetId = target.__rooibosTargetId
                fake = mock
                fake.lineNumbers.push(lineNumber)
                exit for
            end if
        end for
        if fake = invalid
            m.__mockId++
            id = stri(m.__mockId).trim()
            if m.__mockId > 25
                ? "ERROR ONLY 25 MOCKS PER TEST ARE SUPPORTED!! you're on # "; m.__mockId
                ? " Method was "; methodName
                return invalid
            end if
            fake = m.createFake(id, target, methodName, expectedInvocations, expectedArgs, returnValue)
            m.mocks[id] = fake 'this will bind it to m
            allowNonExisting = m.allowNonExistingMethodsOnMocks = true or allowNonExistingMethods
            isMethodPresent = type(target[methodName]) = "Function" or type(target[methodName]) = "roFunction"
            if isMethodPresent or allowNonExisting
                target[methodName] = m["MockCallback" + id]
                target.__mocks = m.mocks
                if not isMethodPresent
                    ' ? "WARNING - mocking call " ; methodName; " which did not exist on target object"
                end if
            else
                ? "ERROR - could not create Mock : method not found  "; target; "."; methodName
            end if
        else
            m.combineFakes(fake, m.createFake(id, target, methodName, expectedInvocations, expectedArgs, returnValue))
        end if
        return fake
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name createFake
    '  * @function
    '  * @instance
    '  * @description Creates a stub to replace a real method with. This is used internally.
    '  * @param {Dynamic} target - object on which the method to be stubbed is found
    '  * @param {Dynamic} methodName - name of method to stub
    '  * @param {Dynamic} [expectedInvocations=1] - number of invocations we expect
    '  * @param {Dynamic} [expectedArgs=invalid] - array containing the arguments we expect the method to be invoked with
    '  * @param {Dynamic} [returnValue=invalid] - value that the stub method will return when invoked
    '  * @returns {Object} - stub that was wired into the real method
    '  */
    instance.createFake = function(id, target, methodName, expectedInvocations = 1, expectedArgs = invalid, returnValue = invalid) as object
        expectedArgsValues = []
        lineNumber = m.currentAssertLineNumber
        hasArgs = Rooibos_Common_isArray(expectedArgs)
        defaultValue = m.ignoreValue
        if hasArgs
            defaultValue = m.invalidValue
        else
            expectedArgs = []
        end if
        lineNumbers = [
            lineNumber
        ]
        for i = 0 to 9
            if hasArgs and expectedArgs.count() > i
                'guard against bad values
                value = expectedArgs[i]
                if not Rooibos_Common_isUndefined(value)
                    if Rooibos_Common_isAssociativeArray(value) and Rooibos_Common_isValid(value.matcher)
                        if not Rooibos_Common_isFunction(value.matcher)
                            ? "[ERROR] you have specified a matching function; but it is not in scope!"
                            expectedArgsValues.push("#ERR-OUT_OF_SCOPE_MATCHER!")
                        else
                            expectedArgsValues.push(expectedArgs[i])
                        end if
                    else
                        expectedArgsValues.push(expectedArgs[i])
                    end if
                else
                    expectedArgsValues.push("#ERR-UNDEFINED!")
                end if
            else
                expectedArgsValues.push(defaultValue)
            end if
        end for
        'todo - make into a class
        fake = {
            id: id
            target: target
            errorToThrow: invalid
            methodName: methodName
            returnValue: returnValue
            lineNumbers: lineNumbers
            isCalled: false
            invocations: 0
            invokedArgs: [
                invalid
                invalid
                invalid
                invalid
                invalid
                invalid
                invalid
                invalid
                invalid
            ]
            expectedArgs: expectedArgsValues
            expectedInvocations: expectedInvocations
            callback: function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
                ' ? "FAKE CALLBACK CALLED FOR " ; m.methodName
                'bs:disable-next-line
                if m.allInvokedArgs = invalid
                    'bs:disable-next-line
                    m.allInvokedArgs = []
                end if
                'bs:disable-next-line
                m.invokedArgs = [
                    arg1
                    arg2
                    arg3
                    arg4
                    arg5
                    arg6
                    arg7
                    arg8
                    arg9
                    arg10
                    arg11
                    arg12
                    arg13
                    arg14
                    arg15
                ]
                'bs:disable-next-line
                m.allInvokedArgs.push([
                    arg1
                    arg2
                    arg3
                    arg4
                    arg5
                    arg6
                    arg7
                    arg8
                    arg9
                    arg10
                    arg11
                    arg12
                    arg13
                    arg14
                    arg15
                ])
                'bs:disable-next-line
                m.isCalled = true
                'bs:disable-next-line
                m.invocations++
                if m.errorToThrow <> invalid
                    throw m.errorToThrow
                end if
                'bs:disable-next-line
                if type(m.returnValue) = "roAssociativeArray" and m.returnValue.doesExist("multiResult")
                    'bs:disable-next-line
                    returnValues = m.returnValue["multiResult"]
                    'bs:disable-next-line
                    returnIndex = m.invocations - 1
                    if type(returnValues) = "roArray" and returnValues.count() > 0
                        'bs:disable-next-line
                        if returnValues.count() <= m.invocations
                            returnIndex = returnValues.count() - 1
                            print "Multi return values all used up - repeating last value"
                        end if
                        return returnValues[returnIndex]
                    else
                        ? "Multi return value was specified; but no array of results were found"
                        return invalid
                    end if
                else
                    'bs:disable-next-line
                    return m.returnValue
                end if
            end function
            toThrow: function(error)
                m.errorToThrow = error
            end function
        }
        return fake
    end function
    instance.combineFakes = function(fake, otherFake)
        'add on the expected invoked args
        lineNumber = m.currentAssertLineNumber
        if type(fake.expectedArgs) <> "roAssociativeArray" or not fake.expectedArgs.doesExist("multiInvoke")
            currentExpectedArgsArgs = fake.expectedArgs
            fake.expectedArgs = {
                "multiInvoke": [
                    currentExpectedArgsArgs
                ]
            }
        end if
        for i = 1 to otherFake.expectedInvocations
            fake.expectedArgs.multiInvoke.push(otherFake.expectedArgs)
        end for
        'add on the expected return values
        if type(fake.returnValue) <> "roAssociativeArray" or not fake.returnValue.doesExist("multiResult")
            currentReturnValue = fake.returnValue
            fake.returnValue = {
                "multiResult": [
                    currentReturnValue
                ]
            }
        end if
        for i = 1 to otherFake.expectedInvocations
            fake.returnValue.multiResult.push(otherFake.returnValue)
        end for
        fake.lineNumbers.push(lineNumber)
        fake.expectedInvocations += otherFake.expectedInvocations
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name assertMocks
    '  * @function
    '  * @instance
    '  * @description Will check all mocks that have been created to ensure they were invoked the expected amount of times, with the expected args.
    '  */
    instance.assertMocks = function() as void
        if m.__mockId = invalid or not Rooibos_Common_isAssociativeArray(m.mocks)
            return
        end if
        for each id in m.mocks
            mock = m.mocks[id]
            methodName = mock.methodName
            if mock.expectedInvocations <> mock.invocations
                m.mockFail(mock.lineNumbers[0], methodName, "Wrong number of calls. (" + stri(mock.invocations).trim() + " / " + stri(mock.expectedInvocations).trim() + ")")
                m.cleanMocks()
                return
            else if mock.expectedInvocations > 0 and (Rooibos_Common_isArray(mock.expectedArgs) or (type(mock.expectedArgs) = "roAssociativeArray" and Rooibos_Common_isArray(mock.expectedArgs.multiInvoke)))
                isMultiArgsSupported = type(mock.expectedArgs) = "roAssociativeArray" and Rooibos_Common_isArray(mock.expectedArgs.multiInvoke)
                for invocationIndex = 0 to mock.invocations - 1
                    invokedArgs = mock.allInvokedArgs[invocationIndex]
                    if isMultiArgsSupported
                        expectedArgs = mock.expectedArgs.multiInvoke[invocationIndex]
                    else
                        expectedArgs = mock.expectedArgs
                    end if
                    for i = 0 to expectedArgs.count() - 1
                        value = invokedArgs[i]
                        expected = expectedArgs[i]
                        didNotExpectArg = Rooibos_Common_isString(expected) and expected = m.invalidValue
                        if didNotExpectArg
                            expected = invalid
                        end if
                        isUsingMatcher = Rooibos_Common_isAssociativeArray(expected) and Rooibos_Common_isFunction(expected.matcher)
                        if isUsingMatcher
                            if not expected.matcher(value)
                                m.mockFail(mock.lineNumbers[invocationIndex], methodName, "on Invocation #" + stri(invocationIndex).trim() + ", expected arg #" + stri(i).trim() + "  to match matching function '" + Rooibos_Common_asString(expected.matcher) + "' got '" + Rooibos_Common_asString(value, true) + "')")
                                m.cleanMocks()
                            end if
                        else
                            if not (Rooibos_Common_isString(expected) and expected = m.ignoreValue) and not Rooibos_Common_eqValues(value, expected)
                                if expected = invalid
                                    expected = "[INVALID]"
                                end if
                                m.mockFail(mock.lineNumbers[invocationIndex], methodName, "on Invocation #" + stri(invocationIndex).trim() + ", expected arg #" + stri(i).trim() + "  to be '" + Rooibos_Common_asString(expected, true) + "' got '" + Rooibos_Common_asString(value, true) + "')")
                                m.cleanMocks()
                                return
                            end if
                        end if
                    end for
                end for
            end if
        end for
        m.cleanMocks()
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name cleanMocks
    '  * @function
    '  * @instance
    '  * @description Cleans up all tracking data associated with mocks
    '  */
    instance.cleanMocks = function() as void
        if m.mocks = invalid
            return
        end if
        for each id in m.mocks
            mock = m.mocks[id]
            mock.target.__mocks = invalid
        end for
        m.mocks = invalid
    end function
    ' /**
    '  * @memberof module:BaseTestSuite
    '  * @name cleanStubs
    '  * @function
    '  * @instance
    '  * @description Cleans up all tracking data associated with stubs
    '  */
    instance.cleanStubs = function() as void
        if m.stubs = invalid
            return
        end if
        for each id in m.stubs
            stub = m.stubs[id]
            stub.target.__stubs = invalid
        end for
        m.stubs = invalid
    end function
    instance.mockFail = function(lineNumber, methodName, message) as dynamic
        if m.currentResult.isFail
            return false
        end if
        m.currentResult.fail("mock failure on '" + methodName + "' : " + message, lineNumber)
        return false
    end function
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    '++ Fake Stub callback functions - this is required to get scope
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    instance.stubCallback0 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["0"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback1 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["1"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback2 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["2"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback3 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["3"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback4 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["4"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback5 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["5"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback6 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["6"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback7 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["7"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback8 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["8"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback9 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["9"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback10 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["10"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback11 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["11"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback12 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["12"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback13 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["13"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback14 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["14"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback15 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["15"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback16 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["16"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback17 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["17"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback18 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["18"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback19 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["19"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback20 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["20"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback21 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["21"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback22 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["22"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback23 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["23"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback24 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["24"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.stubCallback25 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__Stubs["25"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    '++ Fake Mock callback functions - this is required to get scope
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    instance.mockCallback0 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["0"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback1 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["1"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback2 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["2"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback3 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["3"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback4 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["4"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback5 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["5"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback6 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["6"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback7 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["7"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback8 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["8"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback9 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["9"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback10 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["10"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback11 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["11"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback12 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["12"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback13 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["13"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback14 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["14"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback15 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["15"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback16 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["16"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback17 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["17"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback18 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["18"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback19 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["19"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback20 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["20"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback21 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["21"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback22 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["22"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback23 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["23"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    instance.mockCallback24 = function(arg1 = invalid, arg2 = invalid, arg3 = invalid, arg4 = invalid, arg5 = invalid, arg6 = invalid, arg7 = invalid, arg8 = invalid, arg9 = invalid, arg10 = invalid, arg11 = invalid, arg12 = invalid, arg13 = invalid, arg14 = invalid, arg15 = invalid) as dynamic
        'bs:disable-next-line
        fake = m.__mocks["24"]
        return fake.callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)
    end function
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    '++ crude async support
    '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ' /**
    '  * @member waitForField
    '  * @memberof module:TestUtils
    '  * @instance
    '  * @function
    '  * @description observeField doesn't work in regular unit tests, so we have to wait for the result. We can use this to wait for a network task, foe example, and pass the result directly to a handler. Note - we wait for the value TO CHANGE - so make sure that will be the case, or you'll get stuck forever :)
    '  * @param {any} target to observe
    '  * @param {string} field to observe
    '  * @param {int} delay for each wait
    '  * @param {int} max attempts
    '  */
    instance.waitForField = function(target, fieldName, delay = 500, maxAttempts = 10)
        attempts = 0
        if target = invalid
            return false
        end if
        initialValue = target[fieldName]
        while target[fieldName] = initialValue
            port = CreateObject("roMessagePort")
            wait(delay, port)
            attempts++
            if attempts = maxAttempts
                return false
            end if
            ? "waiting for signal field '"; fieldName "' - "; attempts
        end while
        return true
    end function
    instance.wait = function(delay = 1)
        port = CreateObject("roMessagePort")
        wait(delay, port)
    end function
    instance.assertAsyncField = function(target, fieldName, delay = 500, maxAttempts = 10)
        try
            if m.currentResult.isFail
                return false
            end if
            if target = invalid
                m.fail("Target was invalid")
            end if
            result = m.waitForField(target, fieldName, delay, maxAttempts)
            if not result
                return m.fail("Timeout waiting for targetField " + fieldName + " to be set on target")
            end if
            return true
        catch error
            'bs:disable-next-line
            m.currentResult.fail("Error while waiting: " + error.message, m.currentAssertLineNumber)
        end try
        return false
    end function
    instance.createNodeClass = function(clazz, useClassAsTop = true, nodeTop = rooibos_utils_MockNode("top"), nodeGlobal = rooibos_utils_MockNode("top"))
        'bs:disable-next-line
        instance = tests_maestro_nodeClassUtils_createNodeClass(clazz, nodeTop, nodeGlobal)
        if instance <> invalid and useClassAsTop
            'note - we use the clazz itself as TOP, so that we don't have to write tests that do
            'thing.top.value, thing.top.value2, etc all over the place
            instance.append(nodeTop)
            instance.top = instance
            instance.__rooibosSkipFields = {
                "top": true
            }
        end if
        return instance
    end function
    instance.createMockViews = function(instance as dynamic, bundlePath as string, viewsPath = "views" as string)
        bundle = m.global.testStyleManager.callfunc("loadBundle", bundlePath)
        'bs:disable-next-line
        ids = mv_getIdsFromStyleJson(mc_getArray(bundle, viewsPath))
        for each id in ids
            instance[id] = {
                id: id
            }
        end for
    end function
    return instance
end function
function rooibos_BaseTestSuite()
    instance = __rooibos_BaseTestSuite_builder()
    instance.new()
    return instance
end function