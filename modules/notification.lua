local GetStringLenght = function(message)
    StringLenght = 0
    for _ in message:gmatch("%S+") do
        StringLenght += 1
    end
    return (StringLenght * 500)
end

ShowNotification = function(data)
    local length = GetStringLenght(data.desc)
    SendNUIMessage({
        action = "addNotify",
        type = data.type,
        maintitle = data.maintitle,
        title = data.title,
        desc = data.desc,
        lenght = (length < 3000 and 5000 or length),
        author = data.author
    })
end

exports('ShowNotification', ShowNotification)