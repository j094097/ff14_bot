# 調用在 Gemfile 設定並安裝的 disocrd API 函式庫
require 'discordrb'
# 調用在 Gemfile 設定並安裝的 tradsim 函式庫
# 這個函式庫是用來將中文轉換成簡體中文的
require 'tradsim'
# 調用在 Gemfile 設定並安裝的 csv 函式庫
require 'csv'

# 將你在 Discord 申請的機器人 Token 帶入並實例化機器人
# 記得替換 Bot Token 為你自己的 Bot Token
DISCORD_TOKEN = ENV['DISCORD_TOKEN']

# 在 Discord 頻道中對機器人說話後機器人會回應的行為設定
bot = Discordrb::Commands::CommandBot.new token: DISCORD_TOKEN, prefix: '!'

key_command = '!問灰機 '
default_url = 'https://ff14.huijiwiki.com/wiki/'
error_message = '請輸入正確的指令 !問灰機 幫助 或 !問FF 幫助'
help_message = '!問灰機 類型 名稱'
in_game_items = []
in_game_quests = []
in_game_dungons = []
in_game_types = %w[副本 物品 配方 任務]
in_game_formulas = %w[刻木匠配方列表 锻铁匠配方列表 铸甲匠配方列表 雕金匠配方列表 制革匠配方列表 裁衣匠配方列表 炼金术士配方列表 烹调师配方列表]

CSV.foreach('ff14_item.csv') do |row|
  in_game_items << row
end

CSV.foreach('ff14_quest.csv') do |row|
  in_game_quests << row
end

CSV.foreach('ff14_dungeons.csv') do |row|
  in_game_dungons << row
end

# 將 CSV 讀取的資料中空白的資料清除
in_game_items = in_game_items.compact
in_game_quests = in_game_quests.compact

def search_items(items, name, ask_type, default_url)
  match_items = items.select { |item| item[0].include?(name) }
  results = match_items[0..9].map { |item| "- #{default_url}#{ask_type}:#{Tradsim.to_sim(item[0])}" }.join("\n")
  "#{results}\n共找到 #{match_items.length} 筆結果(僅顯示前 10 筆)"
end

def search_quests(quests, name, ask_type, default_url)
  match_quests = quests.select { |quest| quest[0].include?(name) }
  results = match_quests[0..9].map { |quest| "- #{default_url}#{ask_type}:#{Tradsim.to_sim(quest[0])}" }.join("\n")
  "#{results}\n共找到 #{match_quests.length} 筆結果(僅顯示前 10 筆)"
end

def search_dungeons(dungeons, name, default_url)
  match_dungeons = dungeons.select { |dungeon| dungeon[0].include?(name) }
  results = match_dungeons[0..9].map { |dungeon| "- #{default_url}#{Tradsim.to_sim(dungeon[0])}" }.join("\n")
  "#{results}\n共找到 #{match_dungeons.length} 筆結果(僅顯示前 10 筆)"
end

def list_types(types, key_command)
  types.map { |t| "- #{key_command}#{t}" }.join("\n")
end

def list_formulas(formulas, default_url)
  formulas.map { |f| "- #{default_url}#{f}" }.join("\n")
end

bot.command(:問灰機, aliases: [:問FF]) do |event, type, name|
  ask_type = type.nil? ? nil : Tradsim.to_sim(type)
  ask_name = name.nil? ? nil : Tradsim.to_sim(name)

  results = case type
            when nil then error_message
            when '幫助' then help_message
            when '類型' then list_types(in_game_types, key_command)
            when '配方' then list_formulas(in_game_formulas, default_url)
            when '物品' then ask_name ? search_items(in_game_items, name, ask_type, default_url) : error_message
            when '任務' then ask_name ? search_quests(in_game_quests, name, ask_type, default_url) : error_message
            when '副本' then ask_name ? search_dungeons(in_game_dungons, name, default_url) : "- #{default_url}副本"
            else error_message
            end

  event.respond results
end

# 運行機器人
bot.run
