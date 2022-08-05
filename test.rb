class NotRandom;
  def rand(*args)
    0
    end
end
p [1, 2, 3, 4].shuffle(random: NotRandom.new) # => [4, 3, 2, 1]
p [1, 2, 3, 4].shuffle(random: NotRandom.new) # => [4, 2, 1, 3]