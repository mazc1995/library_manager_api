class UserRepository
  def show_user(id)
    User.find(id)
  end
end