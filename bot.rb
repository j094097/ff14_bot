# 調用在 Gemfile 設定並安裝的 disocrd API 函式庫
require 'discordrb'
# 調用在 Gemfile 設定並安裝的 tradsim 函式庫
require 'tradsim'

# 將你在 Discord 申請的機器人 Token 帶入並實例化機器人
# 記得替換 Bot Token 為你自己的 Bot Token
DISCORD_TOKEN = ENV['DISCORD_TOKEN']
default_url = 'https://ff14.huijiwiki.com/wiki/'

# 在 Discord 頻道中對機器人說話後機器人會回應的行為設定
# 下方程式碼中 content: 'Ping' 就是代表聊天室收到信息內容為 Ping! 時
# 會觸發事件並產生回覆內容 Pong!
bot = Discordrb::Commands::CommandBot.new token: DISCORD_TOKEN, prefix: '!'

bot.command :問灰機 do |event, type, name|
  ask_type = type
  ask_name = name
  result_url = default_url + ask_type + ':' + ask_name
  event.respond result_url
end

# 運行機器人
bot.run
