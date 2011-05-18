class SystemSecurity < ShipSystem 
  Operation.register_sys(:security)
  
  def _release(args = nil)
     @@rq.enq @@ship.release_docking_clamp()
     {:success => true}
  end

  def self.to_s
    "Security system"
  end
  
  def self.cursor_str
      "security:"
  end
end
