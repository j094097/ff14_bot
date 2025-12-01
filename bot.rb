# 調用在 Gemfile 設定並安裝的 disocrd API 函式庫
require 'discordrb'

# 將你在 Discord 申請的機器人 Token 帶入並實例化機器人
# 記得替換 Bot Token 為你自己的 Bot Token
bot = Discordrb::Bot.new token: '你的 Bot Token'

# 在 Discord 頻道中對機器人說話後機器人會回應的行為設定
# 下方程式碼中 content: 'Ping' 就是代表聊天室收到信息內容為 Ping! 時
# 會觸發事件並產生回覆內容 Pong!
bot.message(content: 'Ping!') do |event|
  event.respond 'Pong!'
end

# 運行機器人
bot.run