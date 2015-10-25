module Killjoy
  class Nullable
    def method_missing(*args)
      Killjoy.logger.debug "Null Object: #{args}"
    end
  end
end
