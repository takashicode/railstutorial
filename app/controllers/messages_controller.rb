class MessagesController < ApplicationController
  before_action :logged_in_user

  def index
    @relate_users = current_user.following + current_user.followers
    @chats = current_user.chat_with.paginate(page: params[:page])
  end

  def show
    @messages = current_user.messages_with(params[:id])
    if @messages.nil?
      @messages = []
    end
  end

  def create
    @message = Message.create(message_params)
    @messages = current_user.messages_with(params[:id])
    respond_to do |format|
      format.html { render 'show' }
      format.js
    end

    #@micropost = current_user.microposts.build(message_params)
    #if @micropost.save
      #flash[:success] = "Micropost created!"
      #redirect_to root_url
    #else
      #@feed_items = []
      #render 'static_pages/home'
    #end

  end

  private
    def message_params
      params.require(:message).permit(:sender_id, :recipient_id, :content)
    end
end
