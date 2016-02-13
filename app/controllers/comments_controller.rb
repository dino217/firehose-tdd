class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_gram_by_id, only: [:create]

  def create
    return render_not_found if @gram.nil?
    @comment = @gram.comments.create(comment_params)
    redirect_to root_path if @comment.valid?
  end

  private

  def find_gram_by_id
    @gram = Gram.find_by_id(params[:gram_id])
  end

  def comment_params
    params.require(:comment).permit(:message, :gram_id)
  end

  def render_not_found(status = :not_found)
    render text: "#{status.to_s.titleize} :(", status: status
  end
end
