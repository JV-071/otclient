-- IMPORTANTE: Lembre-se de definir o código do OPCODE na constante ExtendedIds em modules\gamelib\const.lua
-- O valor padrão é SoundServer = 150

-- IMPORTANTE 2: Adicione os canais existentes no seu servidor na constante SoundChannels em modules\corelib\const.lua
-- Os canais são utilizados para que seja possível reproduzir diferentes audios simultaneamente. Caso não deseje utilizar, apenas envie do server o audio no mesmo canal.
-- Valor padrão da constante para ser compatível:
-- SoundChannels = {
--     Music = 1,
--     Ambient = 2,
--     Effect = 3,
--     TargetSpell = 4,
--     AreaSpell = 5,
--     BeamSpell = 6,
--     SpecialSpell = 7,
-- }

local effectChannel = nil
local soundSource = nil
if g_sounds then
    effectChannel = g_sounds.getChannel(SoundChannels.Effect)
end
function init()
    ProtocolGame.registerExtendedOpcode(ExtendedIds.SoundServer, onExtendedSound)
end
function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.SoundServer)
end
-- Script para reproduzir áudio no Mehah OTClient recebendo mensagem do servidor
-- Recebe o Nome do arquivo no root ou diretório a partir do root
-- Channel recebe uma das constantes de SoundChannels disponíveis em modules\corelib\const.lua
function onPlayAudio(audioPath, volume, fadeTime, pitch, channel)

    if g_sounds and channel ~= nil and tonumber(channel) ~= nil then
        effectChannel = g_sounds.getChannel(tonumber(channel))
    end

    if (audioPath == " ") then
        effectChannel:stop()
        return false
    end

    if audioPath ~= nil or #audioPath <= 0 then
        local fullPath = "/data/sounds/" .. audioPath
        soundSource = effectChannel:play(fullPath, tonumber(fadeTime), tonumber(volume), tonumber(pitch))
        if (soundSource == nil) then
            return false
        end

        soundSource:setLooping(false)
        soundSource:play()
    else
        print("Erro: Arquivo de audio inválido. Valor: " .. tostring(audioPath))
    end
end

function onExtendedSound(protocol, opcode, buffer)
    if (opcode == ExtendedIds.SoundServer) then
        -- Caso a opção "ATIVAR AUDIO" das configurações esteja inativa, o áudio não será reproduzido
        if not g_sounds.isAudioEnabled() then
            return
        end
        local path, volume, fadeTime, pitch, channel = buffer:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)")
        onPlayAudio(path, volume, fadeTime, pitch, channel)
    end
end
