require 'argon2'

module Models
  class User < Sequel::Model
    def password=(password)
      self.crypted_password = Argon2::Password.create(password)
    end

    def matches_password?(password)
      if crypted_password
        Argon2::Password.verify_password(password, crypted_password)
      else
        false
      end
    end
  end
end