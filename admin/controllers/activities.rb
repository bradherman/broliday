Admin.controllers :activities do

  get :index do
    @activities = Activity.all
    render 'activities/index'
  end

  get :new do
    @activity = Activity.new
    render 'activities/new'
  end

  post :create do
    @activity = Activity.new(params[:activity])
    if @activity.save
      flash[:notice] = 'Activity was successfully created.'
      redirect url(:activities, :edit, :id => @activity.id)
    else
      render 'activities/new'
    end
  end

  get :edit, :with => :id do
    @activity = Activity.get(params[:id])
    render 'activities/edit'
  end

  put :update, :with => :id do
    @activity = Activity.get(params[:id])
    if @activity.update(params[:activity])
      flash[:notice] = 'Activity was successfully updated.'
      redirect url(:activities, :edit, :id => @activity.id)
    else
      render 'activities/edit'
    end
  end

  delete :destroy, :with => :id do
    activity = Activity.get(params[:id])
    if activity.destroy
      flash[:notice] = 'Activity was successfully destroyed.'
    else
      flash[:error] = 'Unable to destroy Activity!'
    end
    redirect url(:activities, :index)
  end
end
