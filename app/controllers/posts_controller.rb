class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :log_request, only: %i[ index show create update destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)

    puts "Post Params: #{post_params.inspect}"
    
    respond_to do |format|
      if @post.save
        format.html { redirect_to post_url(@post), notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to post_url(@post), notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body, :avatar)
    end

    def log_request
      client_ip = request.remote_ip

      # Get user agent
      user_agent = request.user_agent

      # Get request method (GET, POST, etc.)
      request_method = request.method

      # Prepare log payload
      log_payload = {
        "controller" => controller_name,
        "action" => action_name,
        "params" => params.to_unsafe_h,
        "client_ip" => client_ip,
        "user_agent" => user_agent,
        "request_method" => request_method
      }

      # Initialize Fluentd Logger
      log = Fluent::Logger::FluentLogger.new(nil, host: 'localhost', port: 24224)

      # Post the log
      log.post("myapp.access", log_payload)
    rescue => e
      Rails.logger.error("Failed to log to Fluentd: #{e.message}")
    end
end
