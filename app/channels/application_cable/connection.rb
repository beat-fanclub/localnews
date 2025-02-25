module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :session_id

    def connect
      self.session_id = cookies.encrypted[:session_id]
    end

    def current_user
      @current_user ||= User.find_by(id: cookies.encrypted[:user_id])
    end
  end
end
