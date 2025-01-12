class StageGear::CheckInsController < BackstageController
  before_action :set_check_in, only: %i[show update]
  before_action :set_rental, only: %i[new]

  def index
    @check_ins = StageGear::CheckIn.all
  end

  def show
    render :show
  end

  def new
    @check_in = StageGear::CheckIn.new
  end

  def create
    @check_in = StageGear::CheckIn.new(check_in_params)

    if @check_in.save
      #render json: @check_in, status: :created, location: @check_in
      redirect_to "/stagegear/check_ins"
    else
      render json: @check_in.errors, status: :unprocessable_entity
    end
  end

  def edit
    @check_in
  end

  def update
    if @check_in.update(check_in_params)
      redirect_to @check_in
    else
      render json: @check_in.errors, status: :unprocessable_entity
    end
  end

  private

  def set_check_in
    @check_in = StageGear::CheckIn.find(params[:id])
  end

  def set_rental
    @rental = StageGear::ProjectorRental.find(params[:projector_rental_id])
  end

  # Date should be "day yyyy-mm-dd"
  def check_in_params
    params.require(:stagegear_check_in).permit(
      :projector_rental_id,
      :status_summary,
      :damage_present,
      :damage_description,
      :damage_fees,
      :return_date,
      :late_return,
      :late_fee,
      :lamp_hours,
      :result,
      images: []
    )
  end
end
