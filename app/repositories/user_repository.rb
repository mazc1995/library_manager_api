class UserRepository
  def list_users
    User.all
  end

  def show_user(id)
    User.find(id)
  end
end