class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :new_bot_action

  def new_bot_action
    if current_user.present?
      @bot_action = BotAction.new
      @bot_chat = current_user.bot_actions.last(2)
    end
  end
end
