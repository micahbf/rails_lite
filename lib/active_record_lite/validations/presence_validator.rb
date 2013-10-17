class PresenceValidator
  def validate(field)
    unless field.nil? || field.empty?
      return true
    else
      return false
    end
  end
end