require 'jumpstart_auth'
require 'bitly'


class MicroBlogger
  attr_reader :client
  
  def initialize
    puts "Initializing MicroBlogger"
    @client = JumpstartAuth.twitter
  end
  
  
  def tweet(message)
    (message.length > 140) ? (puts "Message contains more than max of 140 characters") : @client.update(message)
    
  end
  
  def dm(target, message)  
    puts "Trying to send #{target} this direct message:"
    puts message
    message = "d @#{target} #{message}"
    
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name}
    screen_names.include? target ? tweet(message) : (puts "You may only DM users who follow your account.  Aborting send... ")
    
  end
  
  def follower_list #still to test
    screen_names = []
    @client.followers.each { |follower| screen_names << @client.user(follower).screen_name}
    screen_names.empty? ? (puts "Ummm, you dont have any followers :(") : (puts screen_names) #for testing 
    screen_names
  end
  
  def spam_my_friends(message) #test
    followers = follower_list
    followers.each { |target| dm(target,message)} 
  end
  

  def everyones_last_tweet
    friends_obj = @client.friends
    friends=[]
    friends_list = []
    friends_obj.each do |friend|
      friends << @client.user(friend)
    end
    friends.sort_by!{|a| a.screen_name.downcase}
    friends.each do |a|
      timestamp = a.status.created_at
      puts "#{a.screen_name} said this on #{timestamp.strftime("%A, %b %d")}..."
      puts "     #{a.status.text}"
      puts ""
    end
  end
    

  def shorten(url)
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    return bitly.shorten(url).short_url
  end
        
  
  def run
    puts "Welcome to the JSL Twitter Client"
    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
        when 'q' then puts "Goodbye"
        when 't' then tweet(parts[1..-1].join(' '))
        when 'dm' then dm(parts[1], parts[2..-1].join(' '))
        when 'spam' then spam_my_friends(parts[1..-1].join(' '))
        when 'elt' then everyones_last_tweet
        when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
        else
          puts "Sorry, I don't know how to #{command}"
        end
    end
  
  end
  end
  

blogger = MicroBlogger.new

blogger.run


