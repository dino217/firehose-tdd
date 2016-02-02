class GramsController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
  end

  def new
    @gram = Gram.new
  end

  def create
    @gram = current_user.grams.create(gram_params)
    unless @gram.valid?
      render :new, status: :unprocessable_entity
    else
      redirect_to root_path
    end
  end

  private

  def gram_params
    params.require(:gram).permit(:message)
  end
end
