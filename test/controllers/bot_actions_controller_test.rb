require 'test_helper'

class BotActionsControllerTest < ActionDispatch::IntegrationTest
  test "should get process_user_input" do
    get bot_actions_process_user_input_url
    assert_response :success
  end

end
