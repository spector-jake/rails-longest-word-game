require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
    session[:score] |= 0
  end

  def score
    # render plain: "Add to DB games '#{params[:word]}'"
    # raise
    @response = run_game(params[:attempt], params[:grid])

    session[:score] += @response[:score]
  end

  def generate_grid(grid_size)
    charset = Array('a'..'z')
    Array.new(grid_size) { charset.sample }
  end

  def run_game(attempt, grid)
    result = { score: 0, message: 'well done' }
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    word_seralized = open(url).read
    word = JSON.parse(word_seralized)

    unless word['found']
      result[:message] = "Sorry but #{attempt} does not seem to be a valid English word..."
      return result
    end

    grid_count = grid.downcase.each_char.with_object(Hash.new(0)) { |character, hash| hash[character] += 1 }
    attempt.downcase.each_char do |character|
      grid_count[character] -= 1
      result[:message] = "Sorry but #{attempt} can't be built out of #{grid}" if grid_count[character].negative?
    end

    result[:score] = word['length']**2 unless grid_count.value?(-1)
    result[:message] = "Congratulations! #{attempt} is a valid word!"
    return result
  end
end
