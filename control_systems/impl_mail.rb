class ImplMail
  attr_reader :mail
   
  def initialize
    @mails = []
    @new = false
    @position = 0
    @current = nil
  end
  
  def accept_mail txt, from     
    @mails << Mail.new(txt, from)
    @new = true
  end
  
  def read_mail opts = {}
    opts ||= {}
    return nil if  opts[:position] == :new and @new == false
    
    mail = @mails.last
    mail = @mails.first if opts[:position] == :first
    if opts[:direction] == :next
      index = mails.index(@current)
      mail = mails[index + 1]
    end  
    
    unless opts[:consume] == false
      @new = false
      mail.consume unless mail.nil?
    end
    
    @current = mail
  end
end