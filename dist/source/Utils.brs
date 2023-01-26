function __rooibos_utils_MockNode_builder()
    instance = {}
    instance.new = function(id = "", subType = "Node")
        m.id = invalid
        m.name = invalid
        m.createdNodes = []
        m.createdChildren = []
        m.children = []
        m._subType = "Node"
        m._parent = invalid
        m.id = id
        m._subType = subType
    end function
    instance.subType = function()
        return m._subType
    end function
    instance.createObject = function(nodeType)
        node = rooibos_utils_MockNode("", nodeType)
        m.createdNodes.push(node)
        return node
    end function
    instance.createChild = function(nodeType)
        node = rooibos_utils_MockNode("", nodeType)
        m.createdChildren.push(node)
        return node
    end function
    instance.appendChild = function(child)
        m.children.push(child)
    end function
    instance.getParent = function()
        if m._parent = invalid
            m._parent = rooibos_utils_MockNode("_generated_parent")
        end if
        return m._parent
    end function
    instance.addFields = function(fields)
        m.append(fields)
    end function
    instance.setField = function(field, value)
        m[field] = value
    end function
    instance.setFields = function(fields)
        m.append(fields)
    end function
    instance.observeField = function(field, callback)
    end function
    instance.getChildren = function(offset, count)
        return m.children
    end function
    instance.removeChildren = function(children)
    end function
    instance.observeFieldScoped = function(field, callback)
    end function
    return instance
end function
function rooibos_utils_MockNode(id = "", subType = "Node")
    instance = __rooibos_utils_MockNode_builder()
    instance.new(id, subType)
    return instance
end function