class GramsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :find_gram_by_id, only: [:update, :edit, :show]

  def show
    return render_not_found if @gram.nil?
  end

  def edit
    return render_not_found if @gram.nil?
    return render_not_found(:forbidden) if @gram.user != current_user
  end

  def index
    @grams = Gram.all
  end

  def new
    @gram = Gram.new
  end

  def update
    return render_not_found if @gram.nil?
    return render_not_found(:forbidden) if @gram.user != current_user

    @gram.update_attributes(gram_params)
    redirect_to root_path if @gram.valid?

    render :edit, status: :unprocessable_entity
  end

  def create
    @gram = current_user.grams.create(gram_params)
    if ! @gram.valid?
      render :new, status: :unprocessable_entity
    else
      redirect_to root_path
    end
  end

  def destroy
    @gram = Gram.find_by_id(params[:id])
    return render_not_found if @gram.nil?
    return render_not_found(:forbidden) if @gram.user != current_user
    @gram.destroy
    redirect_to root_path
  end

  private

  def find_gram_by_id
    @gram = Gram.find_gram_by_id(params[:id])
  end

  def gram_params
    params.require(:gram).permit(:message, :picture)
  end

  def render_not_found(status = :not_found)
    render text: "#{status.to_ s.titleize} :(", status: status
  end
end
