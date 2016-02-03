class GramsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def show
    @gram = Gram.find_by_id(params[:id])
    if @gram.nil?
      render text: "404", status: :not_found
    end
  end

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
