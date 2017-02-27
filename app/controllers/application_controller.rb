class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def filtered_ip
    blocklist = IP_BLOCKLIST.map { |subnet| IPAddr.new subnet }
    if blocklist.any? { |block| block.include?(request.remote_ip) }
      return true
    end
    return false
  end

end
