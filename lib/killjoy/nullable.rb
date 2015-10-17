module Killjoy
  class Nullable
    def method_missing(*args)
      puts "Null Object: #{args}"
    end
  end
end
