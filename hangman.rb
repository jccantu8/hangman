require 'yaml'

class Match
    attr_reader :dictionary, :bodyParts
    attr_accessor :result, :chosenWord, :guessedLetters, :chancesRemaining, :bodyPartsSoFar,
        :wrongAnswers, :wrongLetters, :rightAnswer

    @@dictionary = File.readlines("dictionary.txt")
    @@bodyParts = ['o', '|', '/', '\\', '/', '\\']

    def initialize
        @chosenWord = nil
        @bodyPartsSoFar = [' ',' ',' ',' ',' ',' ']
        @chancesRemaining = 0
        @result = nil
        @wrongAnswers = 0
        @wrongLetters = []
        @rightAnswer = false
        getWord
        load_game
        play
    end

    def checkGuess(guess)
        if (@chosenWord.include?(guess))
            puts "Good guess!"
            puts
            for i in (0...@chosenWord.length)
                if @chosenWord[i] == guess
                    @guessedLetters[i] = guess
                end
            end
        else
            puts "Nope!"
            puts
            @wrongAnswers += 1
            @bodyPartsSoFar[@chancesRemaining] = @@bodyParts[@chancesRemaining]
            @chancesRemaining += 1
            @wrongLetters.push(guess)
        end
    end

    def getWord
        while (!@chosenWord)
            randomWord = @@dictionary[rand(1..61406)].rstrip #rstrip since readlines added /n
            if (randomWord.length > 4 and randomWord.length < 12)
                @chosenWord = randomWord.downcase
            end
        end

        @guessedLetters = "-" * @chosenWord.length
    end

    def drawBoard
        puts "     __ "
        puts "    #{@bodyPartsSoFar[0]}  |"
        puts "   #{@bodyPartsSoFar[2]}#{@bodyPartsSoFar[1]}#{@bodyPartsSoFar[3]} |"
        puts "   #{@bodyPartsSoFar[4]} #{@bodyPartsSoFar[5]} |"
        puts "    ___|"
        puts
        puts @guessedLetters
        puts
        puts
        puts "Wrong letters: #{@wrongLetters.sort.join(',')}"
    end

    def load_game
        while (true)
            puts "Would you like to load your previous game? (y/n)"
            answer = gets.chomp.downcase

            if (answer == 'y' or answer == 'yes')
                loadedGame = YAML.load(File.read('game.rb'))
                @chosenWord = loadedGame.chosenWord
                @bodyPartsSoFar = loadedGame.bodyPartsSoFar
                @chancesRemaining = loadedGame.chancesRemaining
                @result = loadedGame.result
                @wrongAnswers = loadedGame.wrongAnswers
                @wrongLetters = loadedGame.wrongLetters
                @rightAnswer = loadedGame.rightAnswer
                return
            elsif (answer == 'n' or answer == 'no')
                return
            end
        end


    end

    def play
        while (@result != 'winner' and @result != 'loser')
            save_game

            if (@wrongAnswers > 6)
                @result = 'loser'
            elsif (@guessedLetters == @chosenWord)
                @result = 'winner'
            else
                getGuess
                drawBoard
            end
        end

        drawBoard
        puts "You are a #{@result}"
        puts
        puts "The word was #{@chosenWord}"
    end

    def getGuess
        guessFlag = false
        while (!guessFlag)
            puts "Pick a letter!"
            guess = gets.chomp.downcase
            
            if (!guess.match(/[a-z]/))
                puts "Letters only!"
                puts
            elsif (guess.length > 1 or guess.length < 1)
                puts "One letter only!"
                puts
            elsif (@wrongLetters.include?(guess))
                puts "You've already guessed that letter!"
                puts
            else
                guessFlag = true
            end
        end

        checkGuess(guess)
    end

    def save_game
        while (true)
            puts "Would you like to save your game? (y/n)"
            answer = gets.chomp.downcase

            if (answer == 'y' or answer == 'yes')
                File.open('game.rb', 'w') { |f| f.write(YAML.dump(self))}
                exit
            elsif (answer == 'n' or answer == 'no')
                return
            end
        end
    end   

end

game = Match.new()