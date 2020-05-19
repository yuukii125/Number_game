
require "io/console"  #入力した数字を隠すライブラリ

#ヒアドキュメントを用いて開始メッセージを表示するメソッド
def first_message
  puts <<-TEXT
  #################################
  ###  ヌメロン風数字当てゲーム ###
  ###        スタート！         ###
  #################################\n
  TEXT
  sleep(0.5)
end

#重複なしかつ3桁の数字、1文字ずつに分割するメソッド
def unique_three_digits?(num)
  num.match(/\A\d{3}\z/) && num.split("").uniq.length == 3  
end

# 手札を決めるメソッド
def input_hand(name)
  print "プレイヤー#{name}さん　あなたの手札を好きな数字3桁で入力してください\n入力受付中=>"
  hand = STDIN.noecho(&:gets).chop  #入力した数字を表示しない
  puts "\n\n"
  
  until unique_three_digits?(hand)  #条件を満たすまで
    print "無効な入力です。もう一度入力してください\n入力受付中=>"
    hand  = STDIN.noecho(&:gets).chop    
    puts "\n\n"
  end
  
  puts "--------入力完了--------"
  puts "\n\n"
  
  sleep(0.5)  #0.5s出力を遅らせる
  hand
end

#履歴を表示するメソッド
def called_histroy(list)
  puts "##### これまでのコール履歴 ######"
  list.each do |hash|
    puts "# 第#{hash[:turn]}ターン：#{hash[:call]}=> #{hash[:judgement]} #"
  end
  puts "#################################\n\n"
end

#コールする数字を入力するメソッド
def input_call
  print "コールする数字を入力してください\n入力受付中=>"
  call = gets.chomp
  puts "\n\n"
  
  until unique_three_digits?(call)
    print "無効な入力です。もう一度入力してください\n入力受付中=>"
    call  = gets.chomp    
    puts "\n\n"
  end
  call
end

#EAT-BITE判定のメソッド
def judgement_eat_bite(call_array, hand_array)
  eat = bite = 0  #eat,biteの初期値は0
  
  #手札とコールした数字の比較
  #数字と桁が合っていればeatに+1,数字だけあっていればbiteに+1
  3.times do |i|
    3.times do |j|
      if call_array[i] == hand_array[j] && i == j
        eat += 1
      elsif call_array[i] == hand_array[j]
        bite += 1
      end
    end
  end
  
  #3EATならゲーム終了
  if eat == 3
    judgement = "[3]EAT! 見事相手の手札を見破りました！"
  else
    judgement = "[#{eat}EAT-#{bite}BITE]"
  end
  
  judgement #返り値
end


#コールターンのメソッド
def call_turn(name, turn, hand_array, list)
  puts "プレイヤー#{name}さんの第#{turn}ターンです\n\n"
  if list.length > 0
    called_histroy(list)
  end

  call = input_call
  
  print "『#{call}』ですね。結果は"
  3.times do
    sleep(0.5)
    print "."
  end
  puts "\n\n"
  
  call_array = call.split("")
  
  judgement = judgement_eat_bite(call_array, hand_array)

  puts "#{judgement}\n\n"
  
  sleep(0.5)
  
  puts "--------ターン終了--------\n\n\n"
  
  sleep(0.5)
  {turn: turn, call: call, judgement: judgement}
end

#3EATがあるか判定
def three_eat?(list)
  three_eat = "[3]EAT! 見事相手の手札を見破りました！"
  
  #1つでも当てはまればtrue
  list.any? do |hash|
    hash.value?(three_eat)  #引数と同じ値があるならtrue
  end
end

#出力開始
first_message
a_hand = input_hand("A")
a_hand_array = a_hand.split("")

b_hand = input_hand("B")
b_hand_array = b_hand.split("")

turn = 1
a_called_list = []
b_called_list = []

while true
  a_call = call_turn("A", turn, b_hand_array, a_called_list)
  a_called_list.push(a_call)
  
  
  b_call = call_turn("B", turn, a_hand_array, b_called_list)
  b_called_list.push(b_call)

  #該当するものがあれば抜ける
  if three_eat?(a_called_list) || three_eat?(b_called_list)
    break
  end
  turn += 1
end

if three_eat?(a_called_list) && three_eat?(b_called_list)
  puts "ゲーム終了！　最終結果は『引き分け』です！\n\n"
elsif three_eat?(a_called_list)
  puts "ゲーム終了！　最終結果は『プレイヤーAさんの勝ち』です！\n\n"
elsif three_eat?(b_called_list)
  puts "ゲーム終了！　最終結果は『プレイヤーBさんの勝ち』です！\n\n"
end
