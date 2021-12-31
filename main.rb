# frozen_string_literal: true

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
    'spot_match' => 'R',
    'color_match' => 'W',
    'no_match' => ' '
  }.freeze

  BOARD_HEADERS = %w[1 2 3 4 KEYS].freeze

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

  class Game
    def initialize(codemaker, codebreaker, no_dupes: false)
      @codemaker   = codemaker
      @codebreaker = codebreaker

      @code     = @codemaker.code || Mastermind.generate_random_code(no_dupes)
      @guesses  = []
      @feedback = []

      @code_cracked = false
      @turns_remaining = 12
    end

    attr_reader :code, :codebreaker
    attr_accessor :guesses, :feedback

    private

    attr_accessor :turns_remaining, :code_cracked

    def print_board
      puts "| #{BOARD_HEADERS.map { |header| header.ljust(6, ' ') }}"
      print_guesses
    end

    def print_guesses
      guesses.zip(feedback).each do |guess, fb|
        puts "| #{guess.map { |peg| peg.ljust(6, ' ') }.join(' | ')} | #{fb.join}"
      end
    end

    # not sure I love this
    def game_over?
      code_cracked || turns_remaining.zero?
    end

    def collect_guess
      puts "What's the code?"
      guess = gets.chomp.split
      until valid_guess?(player.guess)
        puts 'Invalid guess... try again'
        guess = gets.chomp.split
      end

      turn_feedback = check_guess_for_match(guess)
      guesses << guess.map { |peg_key| CODE_PEGS[peg_key] }
      feedback << turn_feedback
    end

    def valid_guess?(guess)
      valid_selections = CODE_PEGS.keys
      guess.all? { |peg| valid_selections.include? peg }
    end

    def create_key_pegs(outcome)
      outcome.each_with_object([]) do |(key, count), accum|
        accum += Array.new(count, KEY_PEGS[key])
      end
    end

    def check_guess_for_match(guess)
      outcome = { 'spot_match': 0, 'color_match': 0, 'no_match': 0 }
      guess.each_with_index do |peg, index|
        if peg == code[index]
          outcome['spot_match'] += 1
        elsif code.include?(peg)
          outcome['color_match'] += 1
        else
          outcome['no_match'] += 1
        end
      end

      self.code_cracked = true if outcome['spot_match'].eql? 4
      create_key_pegs(outcome)
    end
  end

  class Player
    # TBD
  end

  class Codemaker
    # TBD
  end

  class Codebreaker
    def initialize
      @guess = nil
    end

    attr_reader :guess
  end
end
