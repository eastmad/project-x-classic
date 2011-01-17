require "contract.rb"

Shoes.app do
  coffee = Item.new("coffee", "Still a legal stimulent in most markets", :commodity, [:dry])
  gold = Item.new("gold", "Valuable and shiny metal", :rare)
  eye = Item.new("Eye of Horus", "Alien artifact of uknown origin", :unique, [:controlled, :asgaard])
  
  sink_contract = Contract.new(:sink, coffee)
  source_contract = Contract.new(:source, coffee, "Mars")
  
  info "sink = #{sink_contract}"
  info "source = #{source_contract}"
  
  consignment_coffee = Consignment.new(coffee, "Earth") 
  consignment_gold = Consignment.new(gold, "Earth")
  consignment_eye = Consignment.new(gold, "Earth")
  
  begin
    Consignment.new(eye, 2, "Earth")
  rescue => ex
    info "multiple size unique? #{ex}"
  end
  
  source_consignment = source_contract.accept
  
  info "source consignment = #{source_consignment}"
  
  
  begin
    sink_contract.fulfil(consignment_coffee, source_contract)
    info "FAIL - consignment not from source"
  rescue => ex
    info "consignment not from source? #{ex}"
  end
  
  begin
    sink_contract.fulfil(consignment_gold, source_contract)
    info "FAIL - wrong item passed"
  rescue => ex
      info "wrong item passed? #{ex}"
  end
  
  sink_contract.fulfil(source_consignment, source_contract)
  
  info "sink contract = #{sink_contract}"
  
  info "source_consignment = #{source_consignment}"
  
  source_consignment.amount += 1
  
  begin
    sink_contract.fulfil(source_consignment, source_contract)
    info "FAIL - already fulfilled"
  rescue => ex
    info "contract already fulfild? #{ex}"
  end
    
end