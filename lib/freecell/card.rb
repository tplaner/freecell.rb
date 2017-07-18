module Freecell
  # A playing card
  class Card
    attr_reader :rank, :suit

    SUITS = %i[hearts diamonds spades clubs].freeze

    PRETTY = true;

    def initialize(rank, suit)
      @rank = rank
      @suit = suit
    end

    def ==(other)
      %i[rank suit].all? { |v| send(v) == other.send(v) }
    end

    def black?
      %i[clubs spades].include?(suit)
    end

    def red?
      %i[hearts diamonds].include?(suit)
    end

    def opposite_color?(other)
      red = %i[hearts diamonds]
      red.include?(suit) ^ red.include?(other.suit)
    end

    def suit_abbr
      if PRETTY
        case @suit.to_s
        when "clubs"
          "♣"
        when "spades"
          "♠"
        when "hearts"
          "♥"
        when "diamonds"
          "♦"
        end
      else
        suit.to_s[0]
      end
    end
  end

  # Used for printing
  class EmptyCard
    def black?
      false
    end

    def red?
      false
    end
  end
end
