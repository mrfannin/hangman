require "yaml"

class Game

  MIN_LENGTH = 5
  MAX_LENGTH = 12
  NUMBER_OF_GUESSES = 6

  def initialize
    @word = ""
    @current_guesses = 0
    @guessed_letters = []
    @guessed_word = "_" * @word.length
    @player = Player.new
  end

  def game_menu
    choice = ""
    
    until (choice == "3")
      system "clear"

      puts "Welcome to Hangman!"
      puts
      puts "1. Start a new game"
      puts "2. Load a saved game"
      puts "3. Exit game"
      puts
      
      choice = @player.get_input(/^[123]$/, "Enter your choice: ")

      if (choice == "1")
        play_game("new")
      elsif(choice == "2")
        play_game("load")
      end
    end
  end

  private

  def save_game()
    system "clear"

    filename = @player.get_input(/[a-zA-Z0-9]+/,"What would you like to call this save? ")
    

    save_data = {word: @word,
                 guessed_letters: @guessed_letters,
                 guessed_word: @guessed_word,
                 current_guesses: @current_guesses}
    
    File.open("saves/#{filename}.yml", "w") { |file| file.write(save_data.to_yaml)}
  end

  def play_game(game_type)

    system "clear"

    if (game_type == "new")
      reset_game
    elsif (game_type == "load")
      load_game
    end

    until (game_has_ended?)
      system "clear"

      display_info

      guess = @player.get_input(/^[a-z1]$/,"Enter a letter to guess, or enter '1' to save and exit: ")

      if (guess == "1")
        save_game
        exit
      end

      check_guess(guess)

    end

    system "clear"

    puts @current_guesses >= NUMBER_OF_GUESSES ? "You lost!" : "You won!"
    puts
    puts "The word was... #{@word}!"
    puts
    print "Press any key to continue.."

    gets
  end

  def load_game()

    puts "Saved Games"
    puts
    Dir.each_child("saves") {|file| puts file.sub(".yml", "")}

    filename = ""

    save_dir = Dir.new("saves")

    until (save_dir.children.include?("#{filename}.yml"))
      filename = @player.get_input(/[a-zA-Z0-9]+/, "What save would you like to open? ")
    end

    save_data = YAML.load(File.read("saves/#{filename}.yml"))

    @word = save_data[:word]
    @current_guesses = save_data[:current_guesses]
    @guessed_letters = save_data[:guessed_letters]
    @guessed_word = save_data[:guessed_word]
  end

  def reset_game
    @word = find_word(load_dictionary("5desk.txt"))
    @current_guesses = 0
    @guessed_letters = []
    @guessed_word = "_" * @word.length
  end

  def display_info

    guessed_word_display = @guessed_word.split("").join(" ")

    puts guessed_word_display

    puts

    puts "Guesses Left - #{NUMBER_OF_GUESSES - @current_guesses}"

    puts

    puts "Guessed Letters - #{@guessed_letters.join(" ")}"

    puts

  end

  def check_guess(guess)

    found_letter = false

    @word.each_char.with_index do |char, index|
      if (char.downcase == guess)
        found_letter = true
        @guessed_word[index] = guess
      end
    end

    unless found_letter || @guessed_letters.include?(guess)
      @guessed_letters.push(guess)
      @current_guesses += 1
    end
  end 

  def game_has_ended?
    @word.downcase == @guessed_word || @current_guesses >= NUMBER_OF_GUESSES
  end

  def load_dictionary(filename)
    if (File.exist?(filename))

      File.open(filename) do |file|
        return file.read.split("\n")
      end

    else

      puts "Dictionary file does not exist!"
      exit(1)
    end
  end

  def find_word(dictionary)
    word = ""

    until (word.length >= MIN_LENGTH && word.length <= MAX_LENGTH)
      word = dictionary.sample().chomp
    end

    return word
  end

end

class Player

  def initialize
  end

  def get_input(input_regex, input_text)
    print input_text
    
    guess = gets.chomp.downcase

    until (!(guess =~ input_regex).nil?)
      print "Enter a valid input: "
      guess = gets.chomp.downcase
    end

    return guess
  end

end

test = Game.new
test.game_menu
