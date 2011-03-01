class ResponseQueue
   def initialize
      @queue = []
   end

   def enq obj
      @queue << obj
   end

   def deq
      @queue.shift
   end

   def peek
      @queue.last
   end
end 