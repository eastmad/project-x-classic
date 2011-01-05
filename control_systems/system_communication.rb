class SystemCommunication < ShipSystem 
  Operation.register_sys(:communication)
  def self.cursor_str
      "comms:"
  end
end
