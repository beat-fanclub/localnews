require 'rails_helper'

RSpec.describe "comments/new", type: :view do
  before(:each) do
    assign(:comment, Comment.new(
      post: nil,
      body: "MyText",
      user: nil,
      edited: false,
      parent: nil
    ))
  end

  it "renders new comment form" do
    render

    assert_select "form[action=?][method=?]", comments_path, "post" do

      assert_select "input[name=?]", "comment[post_id]"

      assert_select "textarea[name=?]", "comment[body]"

      assert_select "input[name=?]", "comment[user_id]"

      assert_select "input[name=?]", "comment[edited]"

      assert_select "input[name=?]", "comment[parent_id]"
    end
  end
end
