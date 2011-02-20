class ImplMail
  attr_reader :mail
   
  def initialize
    @mails = []
    @new = false
  end
  
  def accept_mail txt, from     
    @mails << Mail.new(txt, from)
    @new = true
  end
  
  def read_mail opts = {}
    return nil if  opts[:position] == :new and @new == false
    
    mail = @mails.last
    
    unless opts[:consume] == false
      @new = false
      mail.consume unless mail.nil?
    end
    
    mail
  end
end

class Mail
  attr_reader :txt, :from, :read  
    
  def initialize txt, from
    @txt = txt
    @from = from
    @read = false       
  end
  
  def consume
    @read = true
  end
end
