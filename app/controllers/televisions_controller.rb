class TelevisionsController < ApplicationController
  before_action :set_television, only: [:show, :edit, :update, :destroy]

  # GET /televisions
  # GET /televisions.json
  def index
    @televisions = Television.all
  end

  # GET /televisions/1
  # GET /televisions/1.json
  def show
  end

  # GET /televisions/new
  def new
    @television = Television.new
  end

  # GET /televisions/1/edit
  def edit
  end

  # POST /televisions
  # POST /televisions.json
  def create
    @television = Television.new(television_params)

    respond_to do |format|
      if @television.save
        format.html { redirect_to @television, notice: 'Television was successfully created.' }
        format.json { render :show, status: :created, location: @television }
      else
        format.html { render :new }
        format.json { render json: @television.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /televisions/1
  # PATCH/PUT /televisions/1.json
  def update
    respond_to do |format|
      if @television.update(television_params)
        format.html { redirect_to @television, notice: 'Television was successfully updated.' }
        format.json { render :show, status: :ok, location: @television }
      else
        format.html { render :edit }
        format.json { render json: @television.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /televisions/1
  # DELETE /televisions/1.json
  def destroy
    @television.destroy
    respond_to do |format|
      format.html { redirect_to televisions_url, notice: 'Television was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_television
      @television = Television.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def television_params
      params.require(:television).permit(:name, :description, :price)
    end
end
