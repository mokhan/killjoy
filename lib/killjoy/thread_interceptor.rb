module Killjoy
  class ThreadInterceptor
    def intercept(invocation)
      Thread.new do
        puts "thread: #{Thread.current.object_id}"
        invocation.proceed
      end
    end
  end
end
