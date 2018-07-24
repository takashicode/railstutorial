class MessagesController < ApplicationController
  def index
    if current_user
      @chats = current_user.chat_with.paginate(page: params[:page])
    else
      redirect_to root_path
    end
  end

  def show
    @messages = current_user.messages_with(params[:id])
  end

  def create

  end

end
