# frozen_string_literal: true

# 調用在 Gemfile 設定並安裝的 disocrd API 函式庫
require 'discordrb'
# 調用在 Gemfile 設定並安裝的 tradsim 函式庫
# 這個函式庫是用來將中文轉換成簡體中文的
require 'tradsim'
# 調用在 Gemfile 設定並安裝的 csv 函式庫
require 'csv'
# pretty-printer
require 'pp'
# 字串比對
require 'string/similarity'

using String::SimilarityRefinements

# require 'webrick'
# Thread.new do
#   server = WEBrick::HTTPServer.new(Port: 10_000)
#   server.mount_proc '/' do |_req, res|
#     res.body = 'Bot is alive!'
#   end
#   server.start
# end

# 將你在 Discord 申請的機器人 Token 帶入並實例化機器人
# 記得替換 Bot Token 為你自己的 Bot Token
DISCORD_TOKEN = ENV['DISCORD_TOKEN']

# 在 Discord 頻道中對機器人說話後機器人會回應的行為設定
bot = Discordrb::Commands::CommandBot.new token: DISCORD_TOKEN, prefix: '!'

key_command = '!問FF '

infomation_url = 'https://docs.google.com/spreadsheets/d/1kQhJL5sa3X-W-AOxpVN1FDuu6RQmE7AaCu016darzCk/edit?gid=1409014202#gid=1409014202'
$default_url = 'https://ff14.huijiwiki.com/wiki/'
$market_url = 'https://universalis.app/market/'
fishcake_url = 'https://fish.ffmomola.com/'
custom_search_url = 'https://ff14.huijiwiki.com/index.php?title=特殊%3A搜索&profile=default&fulltext=1&search='

error_message = '請輸入正確的指令 !問FF 幫助'
help_message = '!問FF 類型 名稱'
$in_game_quests = []
$in_game_dungons = []
in_game_types = %w[副本 物品 配方 任務 查價 搜尋]

CSV.foreach('ff14_quest.csv') do |row|
  $in_game_quests << row
end

CSV.foreach('ff14_dungeons.csv') do |row|
  $in_game_dungons << row
end

$in_game_items = CSV.read('ff14_item.csv', headers: true).map(&:to_h)
$in_game_market_items = CSV.read('ff14_market_item.csv', headers: true).map(&:to_h)
$in_game_item_recipes = CSV.read('ff14_item_recipe.csv', headers: true).map(&:to_h)

# 將 CSV 讀取的資料中空白的資料清除
$in_game_quests = $in_game_quests.compact
$in_game_dungons = $in_game_dungons.compact

def search_similarity(items, name)
  temp = []
  length = name.length

  temp = items.select { 
    |item| item['tc_name'][0, length].levenshtein_distance_to(name) <= 1 || 
            item['sc_name'][0, length].levenshtein_distance_to(Tradsim.to_sim(name)) <= 1 
  }

  temp.any? ? "請問是否在搜尋 #{temp.first['tc_name']} (#{temp.first['sc_name']}) ?" : "查無結果"
end

def search_items(name, ask_type)
  match_items = $in_game_items.select { |item| item['tc_name'].include?(name) || item['sc_name'].include?(Tradsim.to_sim(name)) }
  results = match_items[0..9].map { |item| "- #{$default_url}#{ask_type}:#{item['sc_name']} (#{item['tc_name']})" }.join("\n")

  results.empty? ? search_similarity($in_game_items, name) : "#{results}\n共找到 #{match_items.length} 筆結果(僅顯示前 10 筆)"
end

def search_market(name, vague)
  match_items = case vague
                when 1 then $in_game_market_items.select { |item| item['tc_name'].include?(name) || item['sc_name'].include?(Tradsim.to_sim(name)) }
                when 0 then $in_game_market_items.select { |item| item['tc_name'].eql?(name) || item['sc_name'].eql?(Tradsim.to_sim(name)) }
                end
  results = match_items.to_a[0..9].map { |item| "- [#{item['tc_name']}](#{$market_url}#{item['id']}) (#{item['sc_name']})" }.join("\n")

  results.empty? ? search_similarity($in_game_market_items, name) : "#{results}\n共找到 #{match_items.length} 筆結果(僅顯示前 10 筆)"

  # "#{results}\n共找到  #{match_items.length} 筆結果(僅顯示前 10 筆)"
end

def serach_recipe(name)
  match_items = $in_game_market_items.select { |item| item['tc_name'].eql?(name) || item['sc_name'].eql?(Tradsim.to_sim(name)) }

  if match_items.any?
    match_recipes = $in_game_item_recipes.select { |recipe| recipe['item_id']&.eql?(match_items[0]['id']) }
    results = ''
    (0..7).each do |i|
      next unless match_recipes[0]["item_ingredient_#{i}"].to_i.positive?

      id = match_recipes[0]["item_ingredient_#{i}"]
      amount = match_recipes[0]["amount_ingredient_#{i}"]
      temp_item = $in_game_market_items.select { |item| item['id']&.eql? id }
      results += "- [#{temp_item[0]['tc_name']} #{amount}個](#{$market_url}#{id})\n"

      results += sub_search_recipe(id, 1)
    end
    "#{results}\n"
  else
    '請輸入正確配方名稱'
  end
end

def sub_search_recipe(id, level)
  match_recipes = $in_game_item_recipes.select { |recipe| recipe['item_id']&.eql?(id) }
  results = ''
  if match_recipes.any?
    (0..5).each do |i|
      next unless match_recipes[0]["item_ingredient_#{i}"].to_i.positive?

      temp_id = match_recipes[0]["item_ingredient_#{i}"]
      amount = match_recipes[0]["amount_ingredient_#{i}"]
      temp_item = $in_game_market_items.select { |item| item['id']&.eql? temp_id }
      results += "* [#{temp_item[0]['tc_name']} #{amount}個](#{$market_url}#{temp_id})\n".prepend('  ' * level)
      results += sub_search_recipe(temp_id, level + 1)
    end
  end
  results
end


def list_types(types, key_command)
  types.map { |t| "- #{key_command}#{t}" }.join("\n")
end

def search_quests(name, ask_type)
  match_quests = $in_game_quests.select { |quest| quest[0].include?(name) }
  results = match_quests[0..9].map { |quest| "- #{$default_url}#{ask_type}:#{Tradsim.to_sim(quest[0])}" }.join("\n")
  "#{results}\n共找到 #{match_quests.length} 筆結果(僅顯示前 10 筆)"
end

def search_dungeons(name)
  match_dungeons = $in_game_dungons.select { |dungeon| dungeon[0].include?(name) }
  results = match_dungeons[0..9].map { |dungeon| "- #{$default_url}#{Tradsim.to_sim(dungeon[0])}" }.join("\n")
  "#{results}\n共找到 #{match_dungeons.length} 筆結果(僅顯示前 10 筆)"
end


bot.command(:問灰機, aliases: %i[問FF 問ff FF ff]) do |event, type, name, vague|
  vague = vague.nil? ? 1 : vague.to_i
  ask_type = type.nil? ? nil : Tradsim.to_sim(type)
  ask_name = name.nil? ? nil : name

  results = case type
            when nil then error_message
            when '幫助' then help_message
            when '類型' then list_types(in_game_types, key_command)
            when '配方' then if ask_name
                             serach_recipe(name)
                           else
                             error_message
                           end
            when '表單' then infomation_url
            when '魚糕' then fishcake_url
            when '查價', '價格', 'M', 'm' then if ask_name
                                             search_market(name, vague)
                                           else
                                             error_message
                                           end
            when '物品' then ask_name ? search_items(name, ask_type) : error_message
            when '任務' then ask_name ? search_quests(name, ask_type) : error_message
            when '副本' then ask_name ? search_dungeons(name) : "- #{$default_url}副本"
            when '搜尋' then ask_name ? "- #{custom_search_url}#{name}" : error_message
            else "- #{custom_search_url}#{type}"
            end

  event.respond results
end

# 運行機器人
bot.run
