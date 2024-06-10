local console = {}
local internal = {}

internal.warn = warn
internal.print = print
internal.project = game
internal.require = require
internal.workspace = internal.project:GetService('Workspace')
internal.confExistance = internal.workspace:FindFirstChild('VSDS_CONFIGURATION')

function console.log(...)
    if internal.confExistance then
        internal.conf = internal.require(
                            internal.workspace['VSDS_CONFIGURATION'])

        if internal.conf['VSDS_PLUGIN_DEBUG'] then
            if internal.conf['VSDS_PLUGIN_DEBUG'] == true then
                internal.warn(':: VSDS [PLUGIN] ::', ...)
            end

        end
    end
end

function console.info(...)
    local ConfigAvailable = false

    if internal.confExistance then
        internal.conf = internal.require(
                            internal.workspace['VSDS_CONFIGURATION'])
        if internal.conf['VSDS_PLUGIN_DEBUG'] then ConfigAvailable = true end
    end

    if not ConfigAvailable then internal.print(':: VSDS [PLUGIN] ::', ...) end
end

return console
