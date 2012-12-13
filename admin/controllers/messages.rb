Admin.controllers :messages do

  get :index do
    @messages = Message.all
    render 'messages/index'
  end

  get :new do
    @message = Message.new
    render 'messages/new'
  end

  post :create do
    @message = Message.new(params[:message])
    if @message.save
      flash[:notice] = 'Message was successfully created.'
      redirect url(:messages, :edit, :id => @message.id)
    else
      render 'messages/new'
    end
  end

  get :edit, :with => :id do
    @message = Message.get(params[:id])
    render 'messages/edit'
  end

  put :update, :with => :id do
    @message = Message.get(params[:id])
    if @message.update(params[:message])
      flash[:notice] = 'Message was successfully updated.'
      redirect url(:messages, :edit, :id => @message.id)
    else
      render 'messages/edit'
    end
  end

  delete :destroy, :with => :id do
    message = Message.get(params[:id])
    if message.destroy
      flash[:notice] = 'Message was successfully destroyed.'
    else
      flash[:error] = 'Unable to destroy Message!'
    end
    redirect url(:messages, :index)
  end
end
