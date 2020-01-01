module Views
  class UserContext < Context
    def initialize(user)
      @user = user
    end

    def context_title
      "User"
    end

    def title
      @user.name
    end

    def url
      "/users/#{@user.id}/edit"
    end
  end
end