# frozen_string_literal: true
require 'pry'
require 'pry-nav'

module Mastermind
  CODE_PEGS = {
    '1' => 'RED',
    '2' => 'GREEN',
    '3' => 'BLUE',
    '4' => 'YELLOW',
    '5' => 'BRONZE',
    '6' => 'ORANGE',
    '7' => 'BLACK',
    '8' => 'WHITE'
  }.freeze

  KEY_PEGS = {
    spot_match: 'R',
    color_match: 'W',
    no_match: ' '
  }.freeze

  BOARD_HEADERS = %w[PEG1 PEG2 PEG3 PEG4 KEYS].freeze

  def self.generate_random_code(no_dupes: true)
    code = []
    colors = CODE_PEGS.values

    4.times do
      color = colors.sample
      code << color
      colors.delete(color) if no_dupes
    end

    code
  end

  def self.play_again?
    puts 'Wanna play again? (Y/N)'
    play_again = gets.chomp
    until play_again.downcase.match?(/y|n|yes|no/)
      puts 'Please select a valid choice (y, n, yes, no):'
      play_again = gets.chomp
    end

    play_again.match?(/y|yes/)
  end

  class Game
    def initialize(codemaker, codebreaker, no_dupes: false)
      @codemaker   = codemaker
      @codebreaker = codebreaker

      @code     = @codemaker.code
      @guesses  = []
      @feedback = []

      @code_cracked = false
      @turns_remaining = 12
    end

    attr_reader :code, :codebreaker
    attr_accessor :guesses, :feedback

    def game_over?
      code_cracked || turns_remaining.zero?
    end

    # private

    attr_accessor :turns_remaining, :code_cracked

    def format_pegs(pegs)
      pegs.map { |peg| "(#{CODE_PEGS.key(peg)})#{peg.ljust(6, ' ')}" }.join(' | ')
    end

    def print_board
      puts "| #{BOARD_HEADERS.map { |header| header.ljust(9, ' ') }.join(' | ')} |"
      print_guesses
    end

    def print_guesses
      guesses.zip(feedback).each do |guess, fb|
        puts "| #{format_pegs(guess)} | #{fb.join.ljust(9, ' ')} |"
      end
    end

    def print_outcome
      print_board

      if code_cracked
        puts "Congrats! You've cracked the code!"
      else
        puts "Sorry, you're out of turns..."
      end

      puts "The code was:"
      puts "| #{format_pegs(self.code)} |"
    end

    def print_selection_menu
      puts "Enter the number corresponding to each color, separated by spaces (e.g., 1 2 3 4):"
      CODE_PEGS.each { |key, color| puts "#{key}: #{color}"}
    end

    def collect_guess
      guess = gets.chomp.split
      until valid_guess?(guess)
        puts 'Invalid guess... try again'
        guess = gets.chomp.split
      end
      guess
    end

    def add_codebreaker_guess
      print_selection_menu
      guess = collect_guess

      turn_feedback = check_guess_for_match(guess)
      self.guesses << guess.map { |peg_key| CODE_PEGS[peg_key] }
      self.feedback << turn_feedback
      self.turns_remaining -= 1
    end

    def valid_guess?(guess)
      valid_selections = CODE_PEGS.keys
      guess.size.eql?(4) && guess.all? { |peg| valid_selections.include? peg }
    end

    def create_key_pegs(outcome)
      outcome.inject([]) do |accum, (key, count)|
        accum += Array.new(count, KEY_PEGS[key])
      end
    end

    def check_guess_for_match(guess)
      outcome = { spot_match: 0, color_match: 0, no_match: 0 }
      guess.each_with_index do |peg, index|
        peg = CODE_PEGS[peg]
        if peg == code[index]
          outcome[:spot_match] += 1
        elsif code.include?(peg)
          outcome[:color_match] += 1
        else
          outcome[:no_match] += 1
        end
      end

      self.code_cracked = true if outcome[:spot_match].eql? 4
      create_key_pegs(outcome)
    end
  end

  class Player
    # TBD
  end

  class Codemaker
    def initialize(code = nil)
      @code = code
    end

    attr_reader :code
  end

  class Codebreaker
    def initialize
      @guess = nil
    end

    attr_reader :guess
  end
end

code = Mastermind.generate_random_code()
codemaker = Mastermind::Codemaker.new(code)
codebreaker = Mastermind::Codebreaker.new


loop do
  game = Mastermind::Game.new(codemaker, codebreaker)

  until game.game_over?
    game.print_board
    game.add_codebreaker_guess
  end

  game.print_outcome
  break unless Mastermind.play_again?
end
