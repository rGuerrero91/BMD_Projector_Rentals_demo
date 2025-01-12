class StageGear::ProjectorsController < BackstageController
  before_action :set_projector, only: %i[show update destroy edit]

  def index
    @projectors = StageGear::Projector.order(unit_number: :desc)
    @projectors
  end

  def show
    @projector
  end

  def new
    @projector = StageGear::Projector.new
  end

  def create
    @projector = StageGear::Projector.new(projector_params)

    if @projector.save
      params[:images].each { |image| @projector.images.attach(image) } if params[:images].present?
      redirect_to "StageGear/projectors"
    else
      @projector.errors
    end
  end

  def update
    if @projector.update(projector_params)
      @projector.image.attach(params[:images]) if params[:images].present?
      redirect_to @projector
    else
      render json: @projector.errors, status: :unprocessable_entity
    end
  end

  def edit
    @projector
  end

  # DELETE /projectors/1
  def destroy
    @projector
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_projector
    @projector = StageGear::Projector.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def projector_params
    params.require(:stagegear_projector).permit(
      :projector_type,
      :status,
      :unit_number,
      :manual,
      :serial_number,
      :lens_serial_number,
      :thumbnail_image
    )
  end
end
