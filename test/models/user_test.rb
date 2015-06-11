require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
  	@user = User.new(name: "Example User", email: "example@email.com")
  end

  test "should be valid" do
  	assert @user.valid? 
  end

  test "name should be present" do
  	@user.name = ""
  	assert_not @user.valid?
  end

  test "email should be present" do
  	@user.email = ""
  	assert_not @user.valid?
  end 

  test "email should be unique" do
  	dup_user = @user.dup
  	@user.save
  	assert_not dup_user.valid?
  end

  test "case should not impact email uniqueness" do
  	dup_user = @user.dup
  	dup_user.email = dup_user.email.upcase
  	@user.save
  	assert_not dup_user.valid?
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
end